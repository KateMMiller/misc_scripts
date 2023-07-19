#---------------------------------------------------------------------
# Query invasive species detected in forest and wetland plots in ACAD
#    Code written by Kate Miller, 20230719
#---------------------------------------------------------------------

library(tidyverse)
library(sf)

#---- Forest queries ----
library(forestNETN)
importData()

for_inv <- sumSpeciesList(park = "ACAD", from = 2020, to = 2023, speciesType = 'invasive') |> 
  filter(!ScientificName %in% "None present") |> 
  mutate(PlotType = "forest plot") |> 
  select(Plot_Name, PlotType, Year = SampleYear, ScientificName, quad_avg_cov, addspp_present)  

for_inv2 <- left_join(for_inv, 
                      joinLocEvent(from = 2020, to = 2023) |> select(Plot_Name, X = xCoordinate, Y = yCoordinate),
                      by = "Plot_Name")

for_inv3 <- left_join(for_inv2, prepTaxa() |> select(ScientificName, CommonName), by = "ScientificName") |> 
  select(Plot = Plot_Name, PlotType, Year, Latin = ScientificName, Common = CommonName, X, Y, abundance = quad_avg_cov)


#---- Wetland RAM queries -----
library(wetlandACAD)
importQueries()
names(spplist)
head(plants)

wet_inv <- spplist |> filter(Year > 2017) |> 
  select(Code, Label, Year, Latin_Name, Common, Num_Quarters)

wet_inv2 <- left_join(wet_inv, plants |> select(Latin_Name, Invasive), by = "Latin_Name") |> 
  filter(Invasive == TRUE)

wet_inv3 <- left_join(wet_inv2, loc |> select(Code, X = Easting, Y = Northing), by = c("Code")) |> 
  mutate(abundance = Num_Quarters/4,
         PlotType = "wetland RAM") |> 
  select(Plot = Label, PlotType, Year, Latin = Latin_Name, Common, X, Y, abundance) |> 
  arrange(Plot, Latin)

head(wet_inv3)

#---- Wetland sentinel queries -----
library(rjson)
library(httr)
library(readxl)

# Get site list
path <- "../data/NWCA21"
files <- list.files(path, pattern = ".json")
sites <- unique(substr(files, 1, 14))

# Import sentinel coordinates
sen_loc <- read.csv("../data/NWCA_Sampling_Locations_in_ACAD.csv")
head(sen_loc)

# Import and compile V2 json
read_v2_long <- function(path, site_name){
  df <- suppressWarnings(as.data.frame(rjson::fromJSON(file = paste0(path, "/", site_name, "_1_V-2.json")))[,-(1:9)] |>
                           pivot_longer(cols = everything(), names_to = 'header', values_to = 'value')  |>
                           mutate(veg_plot = str_replace(header, "^.+_(\\d+)_.+$", "\\1"), #deletes all but number b/t _##_
                                  veg_plot = as.numeric(veg_plot),
                                  row_num =  as.numeric(str_extract(header, "\\(?[0-9]+\\)?")), # extract first set of digits
                                  site_name = site_name) |>
                           filter(!is.na(veg_plot)))
  
  df$data_type <- case_when(grepl("_SPECIES", df$header) ~ paste0("Species"),
                            grepl("_COVER", df$header) ~ paste0("Cover", "_", df$veg_plot),
                            grepl("_NE", df$header) ~ paste0("NE", "_", df$veg_plot),
                            grepl("_SW", df$header) ~ paste0("SW", "_", df$veg_plot),
                            grepl("_HEIGHT", df$header) ~ paste0("Height", "_", df$veg_plot),
                            TRUE ~ NA_character_)
  
  df <- df |> mutate(species = ifelse(data_type == "Species", value, NA),
                     sort_order = ifelse(data_type == "Species", row_num,
                                         row_num + 0.1)) |>
    arrange(sort_order, data_type) |>
    tidyr::fill(species, .direction = "down") |> filter(data_type != "Species") |>
    select(-sort_order)
}

# Function to reshape v2 to wide
read_v2_wide <- function(path, site_name){
  df <- read_v2_long(path, site_name)
  
  df2 <- df |> select(site_name, species, row_num, value, data_type) |>
    pivot_wider(names_from = data_type, values_from = value) |>
    arrange(species)
  
  return(df2)
}

# Compile species list
v2_all_sites <- purrr::map_df(sites, ~read_v2_wide(path, .x)) |> data.frame()
cov_cols <- c("Cover_1", "Cover_2", "Cover_3", "Cover_4", "Cover_5")
ht_cols <- c("Height_1", "Height_2", "Height_3", "Height_4", "Height_5")

v2_all_sites$species[v2_all_sites$species == "MORELLA CAROLINIENSIS"] <- "MORELLA PENSYLVANICA"
# Error in data b/c I thought M. caroliniensis was a syn. b/c M. pensylvanica wasn't an option.
v2_all_sites$species[v2_all_sites$species == "LINNAEA BOREALIS SPP. LONGIFLORA"] <- "LINNAEA BOREALIS"
# This is a western spp. Should just be L. borealis

# Replace NAs with 0 and convert to numeric
cover_cols <- c("Cover_1", "Cover_2", "Cover_3", "Cover_4", "Cover_5")
v2_all_sites[, cover_cols][is.na(v2_all_sites[, cover_cols])] <- 0
v2_all_sites$Cover_1 <- as.numeric(v2_all_sites$Cover_1)
v2_all_sites$Cover_2 <- as.numeric(v2_all_sites$Cover_2)
v2_all_sites$Cover_3 <- as.numeric(v2_all_sites$Cover_3)
v2_all_sites$Cover_4 <- as.numeric(v2_all_sites$Cover_4)
v2_all_sites$Cover_5 <- as.numeric(v2_all_sites$Cover_5)

# Calculate average cover across all plots
v2_sum <- v2_all_sites |> mutate(avg_cov = (Cover_1 + Cover_2 + Cover_3 + Cover_4 + Cover_5)/5) |>
  mutate(Latin = str_to_sentence(word(species, 1, 2))) |> 
  mutate(Latin = ifelse(Latin == "Frangula alnus", "Rhamnus frangula", Latin)) |> 
  select(site_name, Latin, avg_cov) 

v2_sum2 <- left_join(v2_sum, plants |> select(Latin_Name, Invasive, Common), by = c("Latin" = "Latin_Name")) 
v2_sum2$Latin[is.na(v2_sum2$Invasive)] # The species with different nomenclature are not invasive, so can filter
# on invasive for this

v2_inv <- v2_sum2 |> filter(Invasive == TRUE)

# Add local name to ACAD sites
ACAD_sites <-  data.frame(site_name =
                            c("NWC21-ME-HP301", "NWC21-ME-HP302", "NWC21-ME-HP303", "NWC21-ME-HP304", "NWC21-ME-HP305",
                              "NWC21-ME-HP306", "NWC21-ME-HP307", "NWC21-ME-HP308", "NWC21-ME-HP309", "NWC21-ME-HP310"),
                          LOCAL_ID =
                            c("DUCK", "WMTN", "BIGH", "GILM", "LIHU",
                              "NEMI", "GRME", "HEBR", "HODG", "FRAZ"))

# Combine NWCA coords and veg data
nwca_inv <- left_join(v2_inv, sen_loc, by = c("site_name" = "Plot")) |> 
  mutate(PlotType = "wetland sentinel", Year = 2021) |> 
  select(Plot = site_name, PlotType, Year, Latin, Common, X = xcoord, Y = ycoord, abundance = avg_cov)

head(nwca_inv)

# Combine forest and wetland invasive detections
head(wet_inv3)
head(for_inv3)                      

inv_data <- rbind(for_inv3, wet_inv3, nwca_inv)
write.csv(inv_data, "ACAD_invasive_detections_2018_to_2023.csv", row.names = F)
inv_sf <- st_as_sf(inv_data, coords = c("X", "Y"), crs = 26919)
st_write(inv_sf, "ACAD_invasive_detections_2018_to_2023.shp")

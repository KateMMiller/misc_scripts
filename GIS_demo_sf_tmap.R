#--------------------------
# GIS mapping demo with sf and tmap
#--------------------------
library(tidyverse)
library(sf) # working with spatial data
library(tmap) # plotting spatial data

reg_df <- read.csv("./demos/NETN_regen_dens.csv")
#26919, 26918

park_bounds <- st_read("./demos/NETN_park_bounds_18.shp")
head(park_bounds)
names(park_bounds)

morr_sf <- reg_df %>% filter(Unit_Code == "MORR" & cycle == 3) %>% 
           st_as_sf(coords = c("X_Coord", "Y_Coord"), crs = 26918)
nrow(morr_sf)
head(morr_sf)

morr_map <- tm_shape(park_bounds %>% filter(Park == 'MORR'))+
              tm_borders("black")+
              tm_fill("grey", alpha = 0.7)+
            tm_shape(morr_sf)+
              tm_bubbles(size = "tot_regen", title.size = "Regen. Density",
                         col = '#7DAF8B', border.col = 'DimGrey')+
            tm_layout(legend.position = c("right", "bottom"))+
            tm_compass(size = 2, position = c(0.6,0.01), just = "center")+
            tm_scale_bar(breaks = c(0, 0.25, 0.5), just = "center", position = c(0.5, 0))
                      
tmap_save(morr_map, "MORR_example_map.pdf")

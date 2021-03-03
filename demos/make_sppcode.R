library(tidyverse)

ex_dat <- data.frame(plot = c(1:5), Latin_Name = c("Acer rubrum", "Abies balsamea", "Pinus", 
                                                   "Picea rubens", "Quercus rubra"))
ex_dat

make_sppcode <- function(df){
  df2 <- df %>% mutate(genus = word(Latin_Name, 1),
                       species = ifelse(is.na(word(Latin_Name, 2)), "spp",
                                        word(Latin_Name,2)),
                       sppcode = toupper(paste0(substr(genus, 1, 3),
                                                substr(species, 1, 3))))
  return(df2)
}

ex_dat <- make_sppcode(ex_dat)
ex_dat

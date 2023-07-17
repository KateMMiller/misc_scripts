#-------------------------------------------------
# Code to identify and move files with certain file name for easier photopoint viewing
#-------------------------------------------------
library(jpeg)
library(grid)
library(gridExtra)

dir.create("D:/MIDN/GETT_Photopoints")
new_path <- "D:/MIDN/GETT_Photopoints/"

path2007 <- "D:/MIDN/ForestVegetation/Archive/2007/03_Data/04_Photos/GETT"
path2008 <- "D:/MIDN/ForestVegetation/Archive/2008/03_Data/04_Photos/Gettysburg"
path2009 <- "D:/MIDN/ForestVegetation/Archive/2009/03_Data/04_Photos"
path2010 <- "D:/MIDN/ForestVegetation/Archive/2010/03_Data/04_Photos/2010 MIDN Photopoints/2010 MIDN Named Photopoints"
path2011 <- "D:/MIDN/ForestVegetation/2011/03_Data/04_Photos/GETT_photos_2011"
path2012 <- "D:/MIDN/ForestVegetation/2012/03_Data/04_Photos/GETT"
path2013 <- "D:/MIDN/ForestVegetation/2013/03_Data/04_Photos/GETT"
path2014 <- "D:/MIDN/ForestVegetation/2014/03_Data/Photos/GETT"
path2015 <- "D:/MIDN/ForestVegetation/2015/03_Data/Photos/GETT"
path2016 <- "D:/MIDN/ForestVegetation/2016/03_Data/Photos/GETT"
path2017 <- "D:/MIDN/ForestVegetation/2017/03_Data/Photos/GETT"
path2018 <- "D:/MIDN/ForestVegetation/2018/03_Data/Photos/GETT"
path2019 <- "D:/MIDN/ForestVegetation/2019/03_Data/Photos/PhotoPoints"

GETT_images_full <- 
  list.files(c(#path2007, # had to copy separately 
               #path2008, # had to copy separately 
               path2009, path2010, path2011, path2012, 
               #path2013, # had to copy separately
               path2014, path2015, path2016, path2017, path2018, path2019),
           pattern = "GETT", full.names = TRUE) 

GETT_images <- basename(GETT_images_full)

#---- Clean up 2007 ----
gett07_old <- list.files(path2007)
gett07_fix <- gsub("XXX", "ID", gett07_old)
gett07_fix <- gsub("000", "UC", gett07_fix)
gett07_fix <- gsub("045", "UR", gett07_fix)
gett07_fix <- gsub("135", "BR", gett07_fix)
gett07_fix <- gsub("225", "BL", gett07_fix)
gett07_fix <- gsub("315", "UL", gett07_fix)

gett07_new <- paste0(new_path, "GETT_", gett07_fix)
file.copy(paste0("D:/MIDN/ForestVegetation/Archive/2007/03_Data/04_Photos/GETT/", gett07_old), gett07_new)

#---- Clean up 2008 ----
list.files(path2008)
gett08_old <- list.files(path2008)
gett08_fix <- gsub("GETT_", "GETT_0", gett08_old)
file.copy(paste0(path2008, "/", gett08_old), 
          paste0(new_path, gett08_fix))

#---- Clean up 2013 ----
gett13_old <- list.files(path2013, pattern = "GETT")
gett13_old <- gett13_old[!grepl("QAQC", gett13_old)]
gett13_fix <- gsub("_2012", "_2013", gett13_old)
file.copy(paste0(path2013, "/", gett13_old),
          paste0(new_path, gett13_fix))

# ---- Remaining years -----
file.copy(GETT_images_full, paste0(new_path, GETT_images))

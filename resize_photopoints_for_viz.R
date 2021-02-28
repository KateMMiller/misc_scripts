#----------------------------------
# Script pulls in wetland photopoints, resizes, adds border and title, and saves them as gifs
#----------------------------------
library(tidyverse)
library(magick)
library(stringi)
setwd("D:/NETN/R_Dev/")
full_names<- list.files('./photopoints', pattern='JPG$', full.names=T)
full_names
photo_name<- list.files('./photopoints', pattern='JPG$', full.names=F)
photo_name[1]

#photo_name2<-str_replace(photo_name, ".JPG", ".gif")
photo_name2<-str_replace(photo_name, "_07.", "_07_")
photo_name2<-str_replace(photo_name2, "_08.", "_08_")

photo_name2

# Function to name each photo based on its name
view_namer<-function(pname){
if (grepl("RAM", pname)){
         ifelse(grepl("360L", pname), paste("North View"),
         ifelse(grepl("090L", pname), paste("East View"),
         ifelse(grepl("180L", pname), paste("South View"),
         ifelse(grepl("270L", pname), paste("West View"),
         "none"
         ))))
} else {
         ifelse(grepl("P-0", pname), paste("North View"),
         ifelse(grepl("P-90", pname), paste("East View"),
         ifelse(grepl("P-180", pname), paste("South View"),
         ifelse(grepl("P-270", pname), paste("West View"),
         "none"
                       ))))
    }
}

process_image<-function(import_name, export_name){
  title<-view_namer(pname=export_name)

  img<-image_read(import_name)
  img2<-image_border(img, 'black','5x5')
  img3<-image_scale(img2, 'X500')
  img4<-image_annotate(img3, paste(title), size=16, color='black',
                       boxcolor='white', location='+10+10')
  image_write(img4, format='jpeg', paste0("./wetlandViz/www/", export_name))
  print(export_name)
}

process_image(import_name=full_names[40], export_name=photo_name2[40])
length(full_names)

map2(full_names[1:196], photo_name2[1:196], ~process_image(.x,.y))

# Dealing with RAM-17
full_names17<- list.files('./photopoints/RAM-17', pattern='JPG$', full.names=T)
photo_name17<- list.files('./photopoints/RAM-17', pattern='JPG$', full.names=F)
photo_name17[1]

photo_name17_2<-str_replace(photo_name17, ".JPG", ".gif")

  img<-image_read(full_names17[4])
  img2<-image_border(img, 'black','5x5')
  img3<-image_scale(img2, 'X500')
  img4<-image_annotate(img3, paste("Scene 4"), size=16, color='black',
                       boxcolor='white', location='+10+10')
  image_write(img4, format='JPG', paste0("./wetlandViz/www/", photo_name17_2[4]))



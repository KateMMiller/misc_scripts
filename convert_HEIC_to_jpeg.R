library(magick)

str(magick_config()) # if HEIC is not configured, update your package and try again

path = "D:/NETN/I&M_photos/"
img_list <- list.files(path, pattern = "HEIC")

conv_to_jpg <- function(path, img, x){
  img1 <- image_read(paste0(path, "/", img))
  img2 <- image_convert(img1, format = "jpeg")
  image_write(img2, path = paste0(path, "/", "NETN_Forest_", x, ".jpg"), format = "jpeg", quality = 100)
}

lapply(seq_along(img_list), function(x) conv_to_jpg(path, img_list[x], x))

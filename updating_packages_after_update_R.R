
oldRlibpath <- "C:/Program Files/R/R-4.0/library"
oldRdocpath <- "C:/Users/KMMiller/Documents/R/win-library/4.0"

packs = as.data.frame(installed.packages(.libPaths()[1]), stringsAsFactors = F)
?installed.packages

pkg_list <- c(unname(installed.packages(lib.loc = oldRlibpath)[, "Package"]),
              unname(installed.packages(lib.loc = oldRdocpath)[, "Package"]))
pkg_list

install.packages(pkg_list)
.libPaths() #"C:/Users/KMMiller/Documents/R/win-library/4.0" "C:/Program Files/R/R-4.0.3/library"

library(installr)
copy.packages.between.libraries(ask = TRUE)

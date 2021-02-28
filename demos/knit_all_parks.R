library(purrr) # for map2 function
library(rmarkdown) # for render() function

# params list for park_code
netn_parks <- c("ACAD", "MABI", "MIMA", "MORR", "ROVA", "SAGA", "SARA", "WEFA")

# params list for long_name
long_names <- c("Acadia National Park", "Marsh-Billings-Rockefeller National Historical Park", 
                "Minute Man National Historical Park", "Morristown National Historical Park", 
                "Roosevelt-Vanderbilt National Historic Sites", "Saint-Gaudens National Historical Park",
                "Saratoga National Historical Park", "Weir Farm National Historical Park")

# set up directories
dir <- c("./demos/")
rmd <- c("Markdown_demo.Rmd")

# Create render function to map netn_parks and long_names to
render_reports <- function(code, long){
  render(input = paste0(dir, rmd),
         params = list(park_code = code, long_name = long),
         output_file = paste0(code, "_report_", Sys.Date(), ".html"),
         output_dir = dir)
  
}

map2(netn_parks, long_names, ~render_reports(.x, .y))



#util

library("data.table")
library("jsonlite")
library("httr")

# query json format api data
query.api.json <- function(url0){
  response <- GET(url0)
  # Check if the request was successful
  if (response$status_code == 200) {
    # Parse the JSON content
    content <- content(response, "text")
    json_data <- fromJSON(content)
    
    # Convert to data.table
    dt <- as.data.table(json_data)
    
    # Print the first few rows of the data.table
    return(dt)
  } else {
    print(paste("Failed to fetch data. Status code:", response$status_code))
  }
}
ibrary(tigris) # package for census data
library(sp) # spatial package
library(data.table)
library(rgdal)
library(ggplot2)

# read shapefile
washington = readOGR(dsn = "~/WA_County_Boundaries-shp", layer = "WA_County_Boundaries")

# read csv
df <- read.csv("~/20201124_allcounty_votes.csv",
               stringsAsFactors = FALSE)

# this is sp::merge()
wash_sp_merged <- merge(washington, df, by.x = "JURISDIC_2", by.y = "County")
names(wash_sp_merged) # no geometry column here


#districts <- state_legislative_districts("TX", house = "lower", cb = TRUE)
#txlege <- geo_join(districts, df, "NAME", "District")

# Plot red for republican and blue for democrats
wash_sp_merged$color <- ifelse(wash_sp_merged$RorD == "R", "red", "blue")
plot(wash_sp_merged, col = wash_sp_merged$color)
legend("topright", legend = c("Republican", "Democrat"),
       fill = c("red", "blue"))

# install.packages("tidyverse")
# install.paackages("sf")
# install.packages("tigris")
# install.packages("raster")
library(tidyverse)
library(sf)
library(tigris)
library(raster)
library(ggplot2)

### FILL THIS LINE BEFORE RUNNING
dir.sci_dat_county <- "county_county_aug2020.tsv" # the file is too large, I will share using google drive

# Read in the county-county SCI data
sci_dat <- read_tsv(dir.sci_dat_county)
sci_dat <- rename(sci_dat, sci=scaled_sci)

# Get the maps from the tigris package
counties_map <- counties(cb = TRUE) %>% 
  st_as_sf() %>% 
  st_transform(crs("+init=epsg:2163"))

states_map <- states(cb = TRUE) %>% 
  st_as_sf() %>% 
  st_transform(crs("+init=epsg:2163"))

counties_map <- counties_map %>% mutate(fips = paste0(STATEFP, COUNTYFP))

# Make a vector of regions to generate maps for
regions <- c("53033") #King county

# Create measures to scale up from the overall 20th percentile location pair
x1 <- quantile(sci_dat$sci, .2)
x2 <- x1 * 2
x3 <- x1 * 3
x5 <- x1 * 5
x10 <- x1 * 10
x25 <- x1 * 25
x100 <- x1 * 100

# Create the graph for each of the regions in the list of regions
for(i in 1:length(regions)){
  
  # Get the data for the ith region, which is King in this case, and find fr_loc which begins with 53 using grepl function, 53 stands for WA
  # Exlude King county from a fr_loc
  pattern <- '53[0-9]'
  dat <- filter(sci_dat, user_loc == regions[i], grepl(pattern, fr_loc) , fr_loc !=regions[i] )
  
  # Merge with shape files
  dat_map <- 
    right_join(dat,
               counties_map,
               by=c("fr_loc"="fips")) %>% 
    st_as_sf
  
  # Create clean buckets for these levels
  dat_map <- dat_map %>% 
    mutate(sci_bkt = case_when(
      sci < x1 ~ "< 1x (Overall 20th percentile)",
      sci < x2 ~ "1-2x",
      sci < x3 ~ "2-3x",
      sci < x5 ~ "3-5x",
      sci < x10 ~ "5-10x",
      sci < x25 ~ "10-25x",
      sci < x100 ~ "25-100x",
      sci >= x100 ~ ">= 100x")) %>% 
    mutate(sci_bkt = factor(sci_bkt, levels=c("< 1x (Overall 20th percentile)", "1-2x", "2-3x", "3-5x",
                                              "5-10x", "10-25x", "25-100x", ">= 100x")))
  
  # Get the map of the region you are in
  curr_region_outline <- dat_map %>% 
    filter(fr_loc == regions[i])
  
  # Plot the data
  ggplot(dat_map) +
    geom_sf(aes(fill = sci_bkt), colour="#ADADAD", lwd=0) +
    geom_sf(data=curr_region_outline, fill="#A00000", colour="#A00000", size=0.4) +
    geom_sf(data=states_map, fill="transparent", colour="#A1A1A1", size=0.2) +
    labs(fill = "SCI") +
    theme_void() +
    scale_fill_brewer(palette = "GnBu", na.value="#F5F5F5", drop=FALSE) +
    theme(legend.title = element_blank(), 
          legend.text  = element_text(size = 8),
          legend.key.size = unit(0.8, "lines"),
          legend.position = "bottom", legend.box = "horizontal") +
    guides(fill = guide_legend(nrow = 1, title.hjust = 0.5)) +
    coord_sf(xlim = c(-2200000, 2700000), ylim = c(-2200000, 850000), expand = FALSE) 
  
}


# Join Facebook SCI with county votes csv using FIPS code

FIPS <- read.csv("~/20201124_allcounty_votes.csv",
                 stringsAsFactors = FALSE)

sci_fips_merged <- merge(dat, FIPS, by.x = "fr_loc", by.y = "FIPS")
names(sci_fips_merged) # no geometry column here

# Save this dataframe to folder as a csv
write.csv(sci_fips_merged,'sci_fips_merged.csv')
write.csv(dat, 'dat.csv')

# scatterplot
scatter.smooth(x=sci_fips_merged$sci, y=sci_fips_merged$PercentageBlue, main="Votes Percentage Blue ~ Social Connection Index")  

# Test for correlation between sci and votes for blue, value is 0.5939 which means there is a strong correlation
cor(sci_fips_merged$sci, sci_fips_merged$PercentageBlue) 

# build linear regression model on full data
linearMod <- lm(PercentageBlue ~ sci, data=sci_fips_merged)  
print(linearMod)

abline(linearMod, col="blue") # print regression line

summary(linearMod)  # p values show it is statistically significant 

#using ggplot
ggplot(linearMod, aes(x = sci, y = PercentageBlue)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red") +
  labs (title = "Votes Percentage  Blue ~ Facebook SCI with King county")


# Load libraies
library(tmap)
library(sp)
library(spdep)
# counties_map is a sf object, filter out WA counties, begin with 53, join with sci_fips_merged
newtable <- inner_join(counties_map, sci_fips_merged, by = c("fips" = "fr_loc"), copy = FALSE, suffix = c(".x", ".y"))

# Plot a choropleth map
current_style <- tmap_style("col_blind")
tm_shape(newtable) + 
  tm_fill("sci", title = "sci with King county (Quantiles)", style="quantile", palette = "Reds") +
  tm_borders(alpha = 0.1) +
  tm_layout(main.title = "sci with King county", main.title.size = 0.7 ,
            legend.position = c("right", "bottom"), legend.title.size = 0.8)

# Special Regression
#We coerce the sf object into a new sp object
ncovr_n_sp <- as(newtable, "Spatial")
#Then we create a list of neighbours using the Queen criteria
w_n <- poly2nb(ncovr_n_sp, row.names=ncovr_n_sp$FIPSNO)
wm_n <- nb2mat(w_n, style='B')
rwm_n <- mat2listw(wm_n, style='W')

# Global Moran's I
fit_2 <- lm(PercentageBlue ~ sci, data=newtable)
lm.morantest(fit_2, rwm_n, alternative="two.sided")

# Spatial Lag Model
fit_2_lag <- lagsarlm(PercentageBlue ~ sci, data=newtable, rwm_n)
summary(fit_2_lag)
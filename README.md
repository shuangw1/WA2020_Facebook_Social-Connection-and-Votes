# Washington_Facebook_SCI_Votes 2020
This is the final project for STAT/CSSS 567 Social Network Analysis at University of Washington


The county_county_Aug2020.tsv and the WA shp are too large to upload to github, you can download them here https://data-wadnr.opendata.arcgis.com/datasets/12712f465fc44fb58328c6e0255ca27e_11;
https://data.humdata.org/dataset/social-connectedness-index

📰 Introduction
This is an interactive web map that marks the airports in the United States. Green means there is a traffic control tower (CNTL_TWR) at this airport while black means not. I use purple-blue color (from colorbrewer2.org) to create a chropleth map where darker purple indicates there are more airports in this state and lighter blue indicates there are fewer airports in this state. Users can click on the airport icon to see each airport's name and its three digit IATA code. The map can be accessed from here.

🔎 Data Resources
airports.geojson contains all the airports in the United States. This data is converted from a shapefile, which was downloaded and unzipped from https://catalog.data.gov/dataset/usgs-small-scale-dataset-airports-of-the-united-states-201207-shapefile.
us-states.geojson is a geojson data file containing all the states' boundaries of the United States. This data is acquired from Mike Bostock of D3.
Basemap used cartocdn.
data file	attribute	type of data	description
airports.geojson	AIRPRTX010	Numeric	airport tax
ICAO	String	four-letter alphanumeric code designating each airport around the world, determined by International Civil Avian Organization.
IATA	String	International Air Transport Association, the official trade organization for the world's airlines
AIRPT_NAME	String	name of the airport in the U.S.
CITY	String	the city within which the airport is located
STATE	String	the state within which the airport is located
COUNTY	String	the county within which the airport is located
TOT_ENP	Numeric	the total number of passengers enplanned by one aircraft
ELEV	Numeric	the elevation level of the airport above the sea level
CNTL_TWR	Binary	the avaiilability of ATCTs where Y indicates availability and N indicates the otherwise
us-states.geojson	id	Numeric	identification number of the airport according to FAA.
name	String	name of the State where the airport is located
count	Numeric	number of airports had by the state
🔨 Process
Code CNTL_TWR into two colors, "Y" for there are control towers and "N" for there are not.
Code States into 7 range colors.
Add interactive element, so you can click on the airplane icon and get information of the airports.
Library used including leaflet.ajax
💡 Analysis
It can be seen from the map that Alaska, California and Texas have the most number of airports. But the east coast airports have more traffic control towers, showing in green. Although Alaska has a lot of airports, but with few control towers, showing in black.

🎏 Acknowledgement
This map is created by Shuang Wu, and is made with reference to a Web Map Design tutorial. read here.





References: https://github.com/social-connectedness-index/example-scripts

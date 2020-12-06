## From online to offline - Bridging Facebook Social Connectedness Index (SCI) and 2020 Election Votes 

This is the final project for STAT/CSSS 567 Social Network Analysis at University of Washington

Authors: Zhaowen Guo, Tao Lin, Shuang Wu (alphabetically)

📰 Introduction

The 2020 election has come to an end. Washington is considered a "Blue" state, but counties in WA voted differently, and it is geographically very different between the eastern and western parts of the state. The west parts around the Seattle area tend to vote more for Democrats, whereas eastern Washington tends to vote for more Republicans.

In this project, we are trying to find out the relationship between IV `Facebook Social Connectedness Index` and DV `votes` in Washington State, to see if strong online connections between county i and county j (King county in Seattle area in this case) will influence voters' decisions. 

We are also interested to see the difference between an online world with a real physical world. Are they similar or different? Do nearby counties tend to vote for the same party or not? Therefore we construct a `latent space model` for counties in WA and compare it with their real-world locations.


🔎 Data Resources

[Facebook SCI "county_county_Aug2020.tsv"] <https://data.humdata.org/dataset/social-connectedness-index>

[Washington State shapefile] <https://data-wadnr.opendata.arcgis.com/datasets/12712f465fc44fb58328c6e0255ca27e_11>

[Washington State Votes] <https://results.vote.wa.gov/results/20201103/turnout.html>

🔨 Process

We first mapped out the votes result in WA using the R `sp` package, generally speaking, eastern Washington votes much more Republican than western Washington. We found out that there is an outlier, `Whitman County` stands out as more blue in a bigger sea of red east of the Cascades. 

![R or B](/plots/R or B.PNG)

We first look at `median household income` as a variable because we are guessing the economic level will reflect voters' behaviors somehow, but it turns out that Whitman is not one of the "rich" counties. So why does it vote for Democrats?

The next step is looking at the Facebook `Social Connectedness Index` and map it. Surprisingly, Whitman county actually has a very high SCI with King county, the Seattle area.

This interesting phenomenon triggered us to search on the web for more information. Northwest broadcasting reported that: Whitman was the only county east of the Cascades to vote Democratic for president and governor – this year and in 2016. That's largely because of it being home to the main campus of **Washington State University** in Pullman.

Boom, this explains a lot! Washington State University has many connections with **Univeristy of Washington** in Seattle, no wonder it turned out blue and has a high SCI with King county. So apart from median household income, education level might be another variable to look at. 


💡 Analysis
- Build a linear regression model: IV `Facebook Social Connectedness Index` and DV `votes` in Washington State. The result shows a strong positive correlation between the two. The higher a county is connected with King county, the higher percentage of votes for Democrats. 
- Build a latent space model using `ergmm` in R, compare the locations of those counties in a real-world locations with those in latent space. Results show that counties in latent space mimic their real-world locations - counties that are far away in a latent space are also far from each other in the real world, and vice versa. 

🎏 Acknowledgment
[References]: (https://github.com/social-connectedness-index/example-scripts)





This file contains a clean chronological view of prompts issued to Codex. 

# October 11

## Prompt 1
I am analyzing the Ames Housing dataset in R to answer the following analytical question:

Among older homes, are remodeled homes associated with higher sale prices than comparable 
homes that have not been remodeled?

Before conducting the primarly analysis, I need to better understand the data so I can make 
informed decisions about how to define "older homes" and "remodeled homes"

Please inspect the AmesHousing.csv file in the data/ directory and use R code to:

1. Confirm the dimensions of the dataset and inspect the variables relevant to this inital 
exploration, particularly, Year Build, Year Remod/Add, Yr Sold, and SalePrice
2. For these variables, report their data types, missing values, ranges and appropriate summary statistics
3. Examine the distribution of Year Built and the age of homes at the time of sale (Yr Sold - Year Built). 
Create a visualization that will help me understand the age distribution of homes in the dataset
4. Examine the relationship between Year Build and Year Remod/Add, including how often the 
two values are equal versus different and whether there are unusual or potentially problematic values that I should consider before using these fields to identify remodeled homes

Do not choose a cutoff for what qualifices as an "older home" yet, and do not begin the sale-price 
comparison or modeling yet. I want to make those analytical decisions after reviewing this inital exploration.

Please notate code and state any assumptions you make. Add the R code for this explroation to the existing 
analysis R file in the analysis/ directory, run it, and summarize what you find.

Use R and standard, commonly available package where appropriate. If a required package is not already 
installed, tell me which package is needed rather than installing it automatically.

## Prompt 2
Please do not use Python as a substitute for R for the analytical calculations. I want the analysis itself to be 
performed and verified in R.

R is installed on my computer and I use it through RStudio, but R/Rscript may not currently be available 
on the Windows PATH. Please first try to locate the installed R executable in common Windows installation 
locations. If you can locate it, use that installation to run the R script without changing my system configuration.

If you cannot locate or execute R, stop and tell me what you found rather than calculating the requested results 
in another language.
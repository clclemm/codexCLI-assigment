# AI Workflow Log

## October 11

### Prompt 1

**What I asked:**
I asked Codex to conduct an initial exploration of the Ames Housing dataset to help inform how I should 
define "older homes" and "remodeled homes." I asked it to examine `Year Built`, `Year Remod/Add`, `Yr Sold`, and 
`SalePrice`, calculate home age at sale, examine the relationship between build and remodel years, and identify 
unusual or potentially problematic values. I specifically instructed it not to choose an older-home cutoff 
or begin the sale-price comparison or modeling.

**What Codex Produced:** 
Codex inspected the repository and located the dataset as data/AmesHousing-1.csv. When attempting to execute the 
requested analysis, it found that R/Rscript was not available through the Windows PATH. Codex proposed using 
Python to calculate the results while still creating the requested R script.

**Accepted:**
Codex inspected the repository and located the dataset as data/AmesHousing-1.csv. When attempting to execute the 
requested analysis, it found that R/Rscript was not available through the Windows PATH. Codex proposed using Python 
to calculate the results while still creating the requested R script.

**Modified/Rejected:**
I rejected the proposed use of Python to calculate the analytical results.

**Rationale:**
For the assignment I intended to use R for this analysis, and I wanted the R code Codex generated to actually be 
executed and verified rather than generating R code while calculating the reported results in another language.

### Prompt 2

**What I asked:**
I clarified that the analytical calculations should not be performed in Python. I told Codex that R was installed 
on my computer and instructed it to locate the existing R installation and use it without changing my system 
configuration. If it could not locate or execute R, I instructed it to stop rather than substitute another language.

**What Codex Produced:**
Codex located R 4.6.1 within my Program Files and used it to create and execute analysis/analysis.R. The script 
performed the requested exploratory analysis using base R and generated analysis/home_age_distribution.png. Codex 
reported 2,930 rows and 82 columns, a median home age at sale of 34 years, 1,361 homes (46.4%) where Year Built 
and Year Remod/Add differed, and four records with potentially inconsistent year values.

**Accepted:**
I accepted Codex's use of the existing R installation and the overall exploratory approach. The script successfully
ran in R and produced the requested analysis and visualization.

**Modified/Rejected:**
I made several modifications after reviewing and running the generated R script. I simplified the data import to 
rely on the repository structure and reproducibility instructions in the `README.md` and removed unnecessary checks 
for the data file and required columns. I made minor changes to comments and code annotations for readability. I 
also removed some descriptive output that was redundant or did not help answer the analytical question, while 
retaining the age calculation, summary statistics, visualization, and temporal consistency checks. Finally, I 
changed the identification of problematic observations from CSV line numbers to R dataframe row numbers, which are 
more useful for reviewing those observations during the analysis. I did not reject any of the primary analytical 
results produced by Codex.

**Rationale:**
The Codex-generated script was more defensive and detailed in some places than necessary for a small analysis using 
a fixed dataset and repository structure. I wanted to retain Codex's analytical approach rather than rewrite the 
analysis, but remove pieces that did not add value to the question being investigated. The temporal consistency 
checks were retained because they identified four observations that may affect how remodeling and home age are 
defined later in the analysis. Using dataframe row numbers also makes those observations easier to inspect directly 
in R. These changes made the script easier to follow while preserving the useful analysis Codex produced.

## October 12

### Prompt 3

**What I asked:**  
I asked Codex to continue the existing analysis in R using the decisions I made after reviewing the initial 
exploration. I defined an older home as at least 35 years old at the time of sale and a recorded remodel as 
`Year Remod/Add > Year Built`. I also instructed Codex to exclude the four types of temporal inconsistencies 
identified during the initial exploration. I asked it to compare the number, percentage, and SalePrice of remodeled 
and non-remodeled older homes and create a visualization of the SalePrice distributions. I specifically instructed 
it not to begin regression modeling yet.

**What Codex Produced:**  
Codex reviewed the existing R script and added the requested analysis rather than recreating the earlier work. It 
excluded 4 observations with temporal inconsistencies and identified 1,462 homes that were at least 35 years old at 
sale. Of these, 606 (41.45%) were classified as not remodeled and 856 (58.55%) as remodeled. The median SalePrice was
\$135,000 for non-remodeled homes and $131,000 for remodeled homes, while the mean prices were very similar at 
\$137,306 and $137,158, respectively. Codex also created a boxplot comparing the SalePrice distributions.

**Accepted:**  
I accepted the definitions and filtering logic because they correctly reflected the analytical decisions provided 
in the prompt. I also accepted the group comparison and boxplot. The results showed very little difference in mean 
SalePrice between the two groups, although the remodeled group appeared to have greater variation in SalePrice in 
the visualization.

**Modified/Rejected:**  
I added standard deviation to the SalePrice summary so that the difference in variation observed in the boxplot 
could also be evaluated numerically. I removed the final block of code that programmatically constructed a written 
summary of the results because it repeated information already available in the summary table and added unnecessary 
complexity. 

**Rationale:**  
The primary analysis produced by Codex was correct and directly addressed the requested comparison. My modifications
were intended to make the output more useful and keep the code appropriate for a small, one-time analysis. Some of 
the generated code was more programmatic than necessary for a comparison of two fixed groups, but I retained it 
where it was correct and understandable rather than rewriting working code solely for style. Adding standard 
deviation supported an observation made while reviewing the visualization, while removing the generated narrative 
reduced code that did not add analytical value. The tendency toward unnecessarily generalized code is something I 
will address more explicitly in my next prompt.

**Verification:**  
I independently ran the updated script in RStudio and confirmed that it identified the same four temporally 
inconsistent observations and reproduced the reported group sizes and SalePrice results. I manually verified that 
the group counts sum to the total older-home sample (606 + 856 = 1,462) and that 856 / 1,462 = 58.55%, matching the
reported percentage of remodeled homes. I also visually reviewed the boxplot and noted greater SalePrice variation 
among the remodeled homes.


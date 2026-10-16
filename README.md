# codexCLI-assigment
# Ames Housing Remodel Analysis

## Project Overview
This project uses the Ames Housing dataset to explore the relationship between home remodeling and sale price. The analysis is being 
completed in R with analytical work executed through Codex CLI and reviewed and verified by the analyst. 

## Analytical Question
**Among older homes, are remodeled homes associated with higher sale prices than comparable homes that have not been remodeled?**

Codex sessions for this analysis took place on **October 11, October 12, and October 15, 2026**, as documented in 
`prompts/prompt_history.md`.

## Findings

The unadjusted comparison showed little difference in average sale price between older homes with and without a 
recorded remodel. After accounting for above-ground living area, age at sale, and neighborhood, a recorded remodel 
was associated with approximately **$9,700 higher sale price**, and this relationship was statistically significant 
(p < 0.001). The model explained approximately **64% of the variation** in sale price. Regression diagnostics showed
increasing residual variance at higher fitted sale prices and departures from normality in the tails of the Q-Q 
plot, indicating that some model assumptions may not be fully met. Cook’s distance also identified potentially 
influential observations; however, excluding the most influential observation produced a nearly identical remodel 
estimate. Overall, the results suggest a positive adjusted association between recorded remodeling and sale price 
among older homes. 

## Repository Structure
- data/ - Ames Housing dataset used for the analysis
- analysis/ - cleaned dataset, R code and anlytical outputs
- prompts/ - Prompts issued to Codex in chronological order
- log/ - AI Workflow Log documenting codex outputs, analytical decisions, modifications, rejections and verification
- `reflection.md` - Reflection on the Codex-directed analytical workflow

## Running the analysis

The anlysis was completed in R using the dataset located at `data/AmesHousing-1.csv`. 

To reproduce the analysis: 

1. Clone or download this repository
2. Set the repository root (`codexCLI-assignment/`) as the R working directory
3. Run `analysis/analysis.R` from beginning to end

The analysis uses relative file paths, so the repository structure should be maintained when running the code. 
The initial exploration uses base R and does not require additional packages.

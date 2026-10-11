# codexCLI-assigment
# Ames Housing Remodel Analysis

## Project Overview
This project uses the Ames Housing dataset to explore the relationship between home remodeling and sale price. The analysis is being 
completed in R with analytical work executed through Codex CLI and reviewed and verified by the analyst. 

## Analytical Question
**Among older homes, are remodeled homes associated with higher sale prices than comparable homes that have not been remodeled?**

The analysis will first establish an appropriate definition of an "older" home based on the data and determine how remodeled homes can be 
identified using the available variables. It will then compare sale rpeices while accouting for relevant differences between homes.

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
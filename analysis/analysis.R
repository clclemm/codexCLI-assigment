# Ames Housing: initial exploration of build/remodel years and sale price
#
# Assumptions for this descriptive pass:
# - Year Built and Year Remod/Add are interpreted as calendar years, Yr Sold as
#   the sale year, and home age at sale as Yr Sold - Year Built.
# - Equal Year Built and Year Remod/Add values are reported as-is. Equality is
#   not by itself treated as proof that no remodeling occurred.
# - No threshold for "older" and no sale-price comparison/model are defined.
#
# This script uses base R only. Run it from the project root with Rscript
# analysis/analysis.R, or source it in RStudio with the project root as cwd.

# Load Dataset 
ames <- read.csv("data/AmesHousing-1.csv", check.names = FALSE, stringsAsFactors = FALSE)

# Identify columns of interest
required <- c("Year Built", "Year Remod/Add", "Yr Sold", "SalePrice")

cat("Dataset dimensions (rows, columns):", nrow(ames), ncol(ames), "\n\n")

# Report declared R storage types, missingness, observed range, and standard
# numeric summaries. Median and quartiles are included because years/prices may
# be skewed and because they are robust descriptions of the observed data.
numeric_summary <- function(x) {
  c(
    minimum = if (all(is.na(x))) NA_real_ else min(x, na.rm = TRUE),
    q1 = if (all(is.na(x))) NA_real_ else unname(quantile(x, 0.25, na.rm = TRUE)),
    median = if (all(is.na(x))) NA_real_ else median(x, na.rm = TRUE),
    mean = if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE),
    q3 = if (all(is.na(x))) NA_real_ else unname(quantile(x, 0.75, na.rm = TRUE)),
    maximum = if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE),
    sd = if (sum(!is.na(x)) < 2) NA_real_ else sd(x, na.rm = TRUE)
  )
}

fields <- ames[required]
field_report <- data.frame(
  variable = required,
  class = vapply(fields, function(x) paste(class(x), collapse = "/"), character(1)),
  storage_type = vapply(fields, typeof, character(1)),
  missing_n = vapply(fields, function(x) sum(is.na(x)), integer(1)),
  missing_pct = vapply(fields, function(x) mean(is.na(x)) * 100, numeric(1)),
  minimum = vapply(fields, function(x) min(x, na.rm = TRUE), numeric(1)),
  maximum = vapply(fields, function(x) max(x, na.rm = TRUE), numeric(1)),
  row.names = NULL
)
cat("Field types, missing values, and ranges:\n")
print(field_report, digits = 6, row.names = FALSE)
cat("\nSummary statistics (min, quartiles, median, mean, max, SD):\n")
for (nm in required) {
  cat("\n", nm, "\n", sep = "")
  print(numeric_summary(ames[[nm]]))
}

# Distribution of construction years and calculated age at the recorded sale.
age_at_sale <- ames[["Yr Sold"]] - ames[["Year Built"]]
cat("\nAge at sale (Yr Sold - Year Built) summary, in years:\n")
print(numeric_summary(age_at_sale))
cat("Age values range from", min(age_at_sale, na.rm = TRUE), "to",
    max(age_at_sale, na.rm = TRUE), "years;",
    length(unique(age_at_sale[!is.na(age_at_sale)])), "distinct ages are observed.\n")

# Visualize build year and home age at sale
png(file.path("analysis", "home_age_distribution.png"),
    width = 1200, height = 650, res = 130)
par(mfrow = c(1, 2), mar = c(5, 4, 4, 1))
hist(ames[["Year Built"]], breaks = "FD", col = "steelblue",
     border = "white", main = "Distribution of Year Built",
     xlab = "Year built", ylab = "Number of homes")
hist(age_at_sale, breaks = "FD", col = "darkseagreen3",
     border = "white", main = "Home age at sale",
     xlab = "Age at sale (Yr Sold - Year Built, years)",
     ylab = "Number of homes")
dev.off()
cat("\nSaved visualization to analysis/home_age_distribution.png\n")

# Compare build/remodel years and flag inconsistencies for review.
build_year <- ames[["Year Built"]]
remod_year <- ames[["Year Remod/Add"]]
sold_year <- ames[["Yr Sold"]]
years_present <- !is.na(build_year) & !is.na(remod_year)
year_relation <- ifelse(!years_present, "Missing build/remodel year",
                        ifelse(build_year == remod_year, "Equal", "Different"))
cat("\nYear Built versus Year Remod/Add counts:\n")
print(table(year_relation, useNA = "ifany"))

flags <- c(
  build_after_sale = sum(!is.na(build_year) & !is.na(sold_year) & build_year > sold_year),
  remodel_before_build = sum(!is.na(remod_year) & !is.na(build_year) & remod_year < build_year),
  remodel_after_sale = sum(!is.na(remod_year) & !is.na(sold_year) & remod_year > sold_year),
  negative_age_at_sale = sum(!is.na(age_at_sale) & age_at_sale < 0)
)
cat("\nPotentially problematic temporal records (counts may overlap):\n")
print(flags)

# Show every unique out-of-order case with its row number and relevant years.
problem_rows <- which(
  (!is.na(build_year) & !is.na(sold_year) & build_year > sold_year) |
    (!is.na(remod_year) & !is.na(build_year) & remod_year < build_year) |
    (!is.na(remod_year) & !is.na(sold_year) & remod_year > sold_year)
)
if (length(problem_rows)) {
  cat("\nRows with one or more temporal inconsistencies:\n")
  print(data.frame(row = problem_rows,
                   build_year = build_year[problem_rows],
                   remodel_year = remod_year[problem_rows],
                   sale_year = sold_year[problem_rows]), row.names = FALSE)
} else {
  cat("\nNo temporal inconsistencies were detected by these checks.\n")
}

# Equality may encode original condition or no recorded update; "different" establishes a different recorded year, 
# but does not measure remodel scope.

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

# Older-home comparison: exclude any record with a temporal inconsistency,
# then retain homes at least 35 years old at sale. A remodel is recorded only
# when Year Remod/Add is later than Year Built; equal years are classified as
# not remodeled under this operational definition.
temporal_inconsistent <-
  (!is.na(build_year) & !is.na(sold_year) & build_year > sold_year) |
  (!is.na(remod_year) & !is.na(build_year) & remod_year < build_year) |
  (!is.na(remod_year) & !is.na(sold_year) & remod_year > sold_year)
cat("\nUnique observations excluded for temporal inconsistencies:",
    sum(temporal_inconsistent), "\n")

ames$AgeAtSale <- sold_year - build_year
ames$RecordedRemodel <- remod_year > build_year
valid_older <- !temporal_inconsistent & !is.na(ames$AgeAtSale) &
  ames$AgeAtSale >= 35 & !is.na(ames$RecordedRemodel)
older_homes <- ames[valid_older, ]
cat("Older homes included (age at sale >= 35 years):", nrow(older_homes), "\n")

remodel_counts <- table(factor(older_homes$RecordedRemodel,
                               levels = c(FALSE, TRUE),
                               labels = c("Not remodeled", "Remodeled")))
remodel_pct <- 100 * remodel_counts / nrow(older_homes)
cat("\nOlder homes by recorded remodel status (count and percent):\n")
print(data.frame(group = names(remodel_counts),
                 n = as.integer(remodel_counts),
                 percent = as.numeric(remodel_pct)),
      row.names = FALSE, digits = 5)

price_summary <- do.call(rbind, lapply(c(FALSE, TRUE), function(remodeled) {
  prices <- older_homes$SalePrice[older_homes$RecordedRemodel == remodeled]
  data.frame(group = if (remodeled) "Remodeled" else "Not remodeled",
             n = length(prices), median_sale_price = median(prices),
             mean_sale_price = mean(prices), sd_sale_price=sd(prices))
}))
cat("\nSalePrice descriptive statistics among older homes:\n")
print(price_summary, row.names = FALSE)

png(file.path("analysis", "older_home_saleprice_by_remodel.png"),
    width = 900, height = 650, res = 130)
par(mar = c(5, 5, 4, 1))
boxplot(SalePrice ~ factor(RecordedRemodel,
                           levels = c(FALSE, TRUE),
                           labels = c("Not remodeled", "Remodeled")),
        data = older_homes, col = c("gray80", "steelblue2"),
        main = "Sale prices of older homes by recorded remodel status",
        xlab = "Recorded remodel status", ylab = "SalePrice ($)")
dev.off()
cat("Saved visualization to analysis/older_home_saleprice_by_remodel.png\n")

# Check candidate variables for an adjusted comparison. These checks describe
# the variables only; no regression or transformation is applied here.
candidate_variables <- c("SalePrice", "RecordedRemodel", "Gr Liv Area",
                         "AgeAtSale", "Neighborhood")
candidate_fields <- older_homes[candidate_variables]
cat("\nCandidate variable types and missing-value counts in older_homes:\n")
print(data.frame(
  variable = candidate_variables,
  class = vapply(candidate_fields, function(x) paste(class(x), collapse = "/"), character(1)),
  storage_type = vapply(candidate_fields, typeof, character(1)),
  missing_n = vapply(candidate_fields, function(x) sum(is.na(x)), integer(1)),
  row.names = NULL
), row.names = FALSE)

cat("\nDescriptive statistics in older_homes:\n")
print(data.frame(
  variable = c("SalePrice", "Gr Liv Area", "AgeAtSale"),
  minimum = c(min(older_homes$SalePrice), min(older_homes[["Gr Liv Area"]]), min(older_homes$AgeAtSale)),
  median = c(median(older_homes$SalePrice), median(older_homes[["Gr Liv Area"]]), median(older_homes$AgeAtSale)),
  mean = c(mean(older_homes$SalePrice), mean(older_homes[["Gr Liv Area"]]), mean(older_homes$AgeAtSale)),
  maximum = c(max(older_homes$SalePrice), max(older_homes[["Gr Liv Area"]]), max(older_homes$AgeAtSale)),
  sd = c(sd(older_homes$SalePrice), sd(older_homes[["Gr Liv Area"]]), sd(older_homes$AgeAtSale)),
  row.names = NULL
), row.names = FALSE, digits = 7)

cat("\nOlder-home observations by Neighborhood:\n")
print(table(older_homes$Neighborhood, useNA = "ifany"))

# Compare centers and tails to assess skew and unusually large observations.
cat("\nSalePrice five-number summary and upper-tail quantiles:\n")
print(summary(older_homes$SalePrice))
print(quantile(older_homes$SalePrice, c(0.90, 0.95, 0.99)))
cat("\nGr Liv Area five-number summary and upper-tail quantiles:\n")
print(summary(older_homes[["Gr Liv Area"]]))
print(quantile(older_homes[["Gr Liv Area"]], c(0.90, 0.95, 0.99)))

png(file.path("analysis", "older_home_price_size_distributions.png"),
    width = 1100, height = 550, res = 130)
par(mfrow = c(1, 2), mar = c(5, 4, 4, 1))
hist(older_homes$SalePrice, breaks = "FD", col = "steelblue",
     border = "white", main = "SalePrice among older homes",
     xlab = "SalePrice ($)", ylab = "Number of homes")
hist(older_homes[["Gr Liv Area"]], breaks = "FD", col = "darkseagreen3",
     border = "white", main = "Above-ground living area",
     xlab = "Gr Liv Area (sq ft)", ylab = "Number of homes")
dev.off()
cat("Saved visualization to analysis/older_home_price_size_distributions.png\n")

# Multiple linear regression in original numeric units. Neighborhood is
# categorical, so convert it to a factor before fitting the specified model.
older_homes$Neighborhood <- factor(older_homes$Neighborhood)
price_model <- lm(SalePrice ~ RecordedRemodel + `Gr Liv Area` + AgeAtSale +
                    Neighborhood, data = older_homes)

cat("\nSpecified multiple linear regression:\n")
print(summary(price_model))
cat("R-squared:", summary(price_model)$r.squared, "\n")
cat("Adjusted R-squared:", summary(price_model)$adj.r.squared, "\n")

remodel_result <- coef(summary(price_model))["RecordedRemodelTRUE", ]
remodel_ci <- confint(price_model)["RecordedRemodelTRUE", ]
cat("\nRecordedRemodel coefficient (TRUE versus FALSE):\n")
print(data.frame(
  coefficient = unname(remodel_result["Estimate"]),
  standard_error = unname(remodel_result["Std. Error"]),
  p_value = unname(remodel_result["Pr(>|t|)"]),
  ci_95_lower = remodel_ci[1],
  ci_95_upper = remodel_ci[2],
  row.names = NULL
), digits = 7, row.names = FALSE)

# Basic diagnostics: residual pattern, residual normality, and influence.
model_residuals <- residuals(price_model)
model_fitted <- fitted(price_model)
model_cooks <- cooks.distance(price_model)
cook_cutoff <- 4 / nrow(older_homes)
cat("\nCook's distance observations above 4/n (", cook_cutoff, "): ",
    sum(model_cooks > cook_cutoff), "\n", sep = "")
cat("Largest Cook's distances and corresponding older_homes row numbers:\n")
largest_cooks <- order(model_cooks, decreasing = TRUE)[1:10]
print(data.frame(row = largest_cooks,
                 cooks_distance = model_cooks[largest_cooks]),
      row.names = FALSE, digits = 6)

png(file.path("analysis", "older_home_regression_diagnostics.png"),
    width = 1500, height = 500, res = 130)
par(mfrow = c(1, 3), mar = c(5, 4, 4, 1))
plot(model_fitted, model_residuals,
     xlab = "Fitted SalePrice", ylab = "Residuals",
     main = "Residuals vs fitted", pch = 19, col = "steelblue")
abline(h = 0, lty = 2, col = "gray40")
qqnorm(model_residuals, main = "Q-Q plot of residuals", pch = 19,
       col = "steelblue")
qqline(model_residuals, col = "gray40", lty = 2)
plot(model_cooks, type = "h", xlab = "Observation in older_homes",
     ylab = "Cook's distance", main = "Cook's distance",
     col = "steelblue")
abline(h = cook_cutoff, lty = 2, col = "firebrick")
dev.off()
cat("Saved diagnostics to analysis/older_home_regression_diagnostics.png\n")

# Sensitivity check only: retain the primary sample/model above, and refit the
# same formula after excluding older_homes observation 488.
cat("\nObservation 488 values (older_homes row):\n")
print(older_homes[488, c("SalePrice", "RecordedRemodel", "Gr Liv Area",
                         "AgeAtSale", "Neighborhood")], row.names = FALSE)

older_homes_without_488 <- older_homes[-488, ]
sensitivity_model <- lm(SalePrice ~ RecordedRemodel + `Gr Liv Area` + AgeAtSale +
                          Neighborhood, data = older_homes_without_488)

primary_remodel <- coef(summary(price_model))["RecordedRemodelTRUE", ]
sensitivity_remodel <- coef(summary(sensitivity_model))["RecordedRemodelTRUE", ]
model_comparison <- data.frame(
  model = c("Primary model", "Sensitivity model (excluding row 488)"),
  RecordedRemodel_coefficient = c(primary_remodel["Estimate"],
                                  sensitivity_remodel["Estimate"]),
  RecordedRemodel_p_value = c(primary_remodel["Pr(>|t|)"],
                              sensitivity_remodel["Pr(>|t|)" ]),
  R_squared = c(summary(price_model)$r.squared,
                summary(sensitivity_model)$r.squared),
  row.names = NULL
)
cat("\nPrimary and sensitivity model comparison:\n")
print(model_comparison, digits = 7, row.names = FALSE)

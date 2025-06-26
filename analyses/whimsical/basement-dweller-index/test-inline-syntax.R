# Test the corrected inline R syntax

library(tidyverse)

# Create sample data to test syntax
sample_data <- data.frame(
  NAME = c("County A", "County B", "County C", "County D", "County E"),
  basement_dweller_pct = c(10.5, 25.3, 8.1, 30.2, 15.7)
)

# Test the corrected syntax
cat("Testing corrected inline R syntax...\n")

# Test highest rates
highest <- paste(head(arrange(sample_data, desc(basement_dweller_pct)), 3)$NAME, collapse = ", ")
cat("Highest rates counties:", highest, "\n")

# Test lowest rates  
lowest <- paste(head(arrange(sample_data, basement_dweller_pct), 3)$NAME, collapse = ", ")
cat("Lowest rates counties:", lowest, "\n")

cat("✓ Syntax works correctly!\n")
# Test basement-dweller-index.Rmd knitting

library(rmarkdown)

cat("Testing .Rmd knitting...\n")

tryCatch({
  # Try to render just the first few chunks to test data loading
  rmarkdown::render(
    "basement-dweller-index.Rmd",
    output_format = "html_document",
    quiet = FALSE
  )
  cat("✓ .Rmd knitted successfully!\n")
}, error = function(e) {
  cat("✗ Error knitting .Rmd:\n")
  cat(e$message, "\n")
})
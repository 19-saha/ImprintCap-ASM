# install_dependencies.R — run once before anything else

cat("Installing R package dependencies...\n\n")

cran_pkgs <- c("data.table", "readxl", "writexl", "ggplot2", "vcfR")
bioc_pkgs <- c("Rsamtools", "GenomicRanges", "GenomicAlignments", "IRanges")

new_cran <- cran_pkgs[!cran_pkgs %in% installed.packages()[, "Package"]]
if (length(new_cran) > 0) {
  install.packages(new_cran, repos = "https://cloud.r-project.org")
} else {
  cat("✓ All CRAN packages already installed\n")
}

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
new_bioc <- bioc_pkgs[!bioc_pkgs %in% installed.packages()[, "Package"]]
if (length(new_bioc) > 0) {
  BiocManager::install(new_bioc)
} else {
  cat("✓ All Bioconductor packages already installed\n")
}

cat("\nChecking samtools...\n")
ret <- system("samtools --version", ignore.stdout = TRUE, ignore.stderr = TRUE)
if (ret == 0) {
  cat("✓ samtools found\n")
} else {
  cat("✘ samtools NOT found — install via:\n")
  cat("    Mac (Homebrew): brew install samtools\n")
  cat("    Conda:          conda install -c bioconda samtools\n")
  cat("    Linux:          sudo apt install samtools\n")
}

cat("\n✓ Setup complete. Run: source('run_pipeline.R')\n")

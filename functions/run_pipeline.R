# run_pipeline.R

source("functions/prepare_cpg_snp_input.R")
source("functions/extract_bam_regions.R")
source("functions/ASM.R")

# Check samtools
if (system("samtools --version", ignore.stdout = TRUE, ignore.stderr = TRUE) != 0)
  stop("samtools not found. See README for installation instructions.")

input_dir        <- "input/"
filter_cpgs_file <- "data/filter_Cpgs.xlsx"
bam_asm_dir      <- "bam_asm/"
results_dir      <- "asm_results/"

dir.create(bam_asm_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

snp_files  <- list.files(input_dir, pattern = "\\.SNPs\\.out$")
if (length(snp_files) == 0) stop("No .SNPs.out files found in input/")

sample_ids <- sub("_all\\.SNPs\\.out$", "", snp_files)
cat("Samples found:", length(sample_ids), "\n")
print(sample_ids)
cat("\n")

run_sample <- function(sample_id) {
  
  snp_file     <- file.path(input_dir, paste0(sample_id, "_all.SNPs.out"))
  cgmeth_file  <- file.path(input_dir, paste0(sample_id, "_all.CGmeth.txt"))
  bam_file     <- file.path(input_dir, paste0(sample_id, "_all_markdup.bam"))
  cpg_snp_xlsx <- file.path(results_dir, paste0("cpg_snps_", sample_id, ".xlsx"))
  bed_file     <- file.path(results_dir, paste0("cpg_snps_", sample_id, ".bed"))
  wide_bam     <- file.path(bam_asm_dir,  paste0(sample_id, "_all_wide.bam"))
  asm_xlsx     <- file.path(results_dir, paste0("asm_",      sample_id, ".xlsx"))
  
  cat(" Processing:", sample_id, "\n")
  
  for (f in c(snp_file, cgmeth_file, bam_file, filter_cpgs_file))
    if (!file.exists(f)) stop("Missing file: ", f)
  
  cat("STEP 1: Preparing CpG/SNP input\n")
  prepare_cpg_snp_input(
    snp_file     = snp_file,
    meth_file    = cgmeth_file,
    cpg_ref_file = filter_cpgs_file,
    output_file  = cpg_snp_xlsx
  )
  bed_file <- sub("\\.xlsx$", ".bed", cpg_snp_xlsx)
  cat("  ✓ cpg_snp XLSX:", cpg_snp_xlsx, "\n")
  cat("  ✓ BED file:    ", bed_file, "\n\n")
  
  cat("STEP 2: Extracting BAM regions\n")
  extract_bam_regions(
    bam_file   = bam_file,
    bed_file   = bed_file,
    output_dir = bam_asm_dir
  )
  cat("\n")
  
  cat("STEP 3: Running ASM\n")
  if (!file.exists(wide_bam)) stop("Wide BAM not found: ", wide_bam)
  
  old_wd <- getwd()
  setwd(results_dir)
  on.exit(setwd(old_wd), add = TRUE)
  
  ASM(
    cpg_snp_file     = normalizePath(cpg_snp_xlsx),
    sam_file         = normalizePath(wide_bam),
    filter_cpgs_file = normalizePath(filter_cpgs_file),
    output_file      = paste0("asm_", sample_id, ".xlsx")
  )
  
  cat("  ✓ Done:", sample_id, "\n\n")
}

# ── Batch run ─────────────────────────────────────────────────────────────────
results <- lapply(sample_ids, function(sid) {
  tryCatch(
    run_sample(sid),
    error = function(e) message("✘ FAILED: ", sid, " — ", e$message)
  )
})

cat(" DONE —", sum(!sapply(results, is.null)), "/", length(sample_ids), "succeeded\n")
cat(" Results saved to: asm_results/\n")

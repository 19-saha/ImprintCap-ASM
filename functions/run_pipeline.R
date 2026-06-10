# =============================================================================
#  run_pipeline.R  —  ImprintCapASM full pipeline
#  Run this file with: source("run_pipeline.R")
#  You will be prompted to enter the sample type at runtime.
# =============================================================================

# ── STEP 0: Ask user for sample type at runtime ───────────────────────────────

sample_type <- ""
while (!sample_type %in% c("control", "patient")) {
  sample_type <- trimws(tolower(readline(
    prompt = "Enter sample type [control / patient]: "
  )))
  if (!sample_type %in% c("control", "patient")) {
    cat("  ✗ Invalid input. Please type exactly 'control' or 'patient'.\n")
  }
}
cat("  ✓ Sample type set to:", sample_type, "\n\n")

# ── USER PATHS ────────────────────────────────────────────────────────────────

snp_file         <- "/path/to/SAMPLE_all.SNPs.out"
meth_file        <- "/path/to/SAMPLE.methylation.txt"
cpg_ref_file     <- "/path/to/cpg_panel_reference.xlsx"
filter_cpgs_file <- "/path/to/filter_Cpgs_ctrl.xlsx"
bam_file         <- "/path/to/SAMPLE_markdup.bam"
output_dir       <- "/path/to/output"

# ── LOAD FUNCTIONS ────────────────────────────────────────────────────────────

source("R/prepare_cpg_snp_input.R")
source("R/extract_bam_regions.R")
source("R/ImprintCap_ASM.R")

# ── STEP 1: Build CpG–SNP input table + BED file ─────────────────────────────

cpg_snp_result <- prepare_cpg_snp_input(
  snp_file     = snp_file,
  meth_file    = meth_file,
  cpg_ref_file = cpg_ref_file,
  output_file  = NULL,
  min_depth    = 20L,
  window_bp    = 60L,
  sample_type  = sample_type
)

# ── STEP 2: Extract BAM regions matching the BED windows ──────────────────────

sample_id <- sub("_all\\.SNPs\\.out$", "", basename(snp_file))
bed_file  <- file.path(
  output_dir,
  paste0("cpg_snps_CG_", sample_type, "_", sample_id, ".bed")
)

wide_bam <- extract_bam_regions(
  bam_file    = bam_file,
  bed_file    = bed_file,
  output_dir  = output_dir,
  overwrite   = FALSE,
  sample_type = sample_type
)

# ── STEP 3: Run ASM analysis ──────────────────────────────────────────────────

asm_results <- ImprintCap_ASM(
  cpg_snp_file     = file.path(
    output_dir,
    paste0("cpg_snps_CG_", sample_type, "_", sample_id, ".xlsx")
  ),
  sam_file         = wide_bam,
  filter_cpgs_file = filter_cpgs_file,
  output_file      = NULL,
  sample_type      = sample_type
)

cat("Pipeline complete for", sample_type, "sample:", sample_id, "\n")

extract_bam_regions <- function(bam_file,
                                bed_file,
                                output_dir = dirname(bam_file),
                                overwrite  = FALSE) {
  library(Rsamtools)
  library(data.table)
  
  sample_id  <- sub("_markdup\\.bam$", "", basename(bam_file))
  out_bam    <- file.path(output_dir, paste0(sample_id, "_wide.bam"))
  
  if (file.exists(out_bam) && !overwrite) {
    cat("  BAM already exists, skipping extraction:", out_bam, "\n")
    return(out_bam)
  }
  
  if (!file.exists(bam_file))  stop("BAM not found: ", bam_file)
  if (!file.exists(bed_file))  stop("BED not found: ", bed_file)
  if (!file.exists(paste0(bam_file, ".bai"))) {
    cat("  Index not found, indexing BAM...\n")
    indexBam(bam_file)
  }
  
  bed <- fread(bed_file, header = FALSE,
               col.names = c("chr", "start", "end"))
  
  cat("  Extracting", nrow(bed), "target regions from:", basename(bam_file), "\n")
  
  regions <- paste(paste0(bed$chr, ":", bed$start + 1L, "-", bed$end), collapse = " ")
  
  tmp_bam <- file.path(output_dir, paste0(sample_id, "_wide_unsorted.bam"))
  
  cmd_view <- paste("samtools view -b", shQuote(bam_file), regions, ">", shQuote(tmp_bam))
  ret <- system(cmd_view)
  if (ret != 0) stop("samtools view failed for: ", bam_file)

  cmd_sort <- paste("samtools sort -o", shQuote(out_bam), shQuote(tmp_bam))
  ret <- system(cmd_sort)
  if (ret != 0) stop("samtools sort failed for: ", tmp_bam)
  
  cmd_index <- paste("samtools index", shQuote(out_bam))
  ret <- system(cmd_index)
  if (ret != 0) stop("samtools index failed for: ", out_bam)
  
  file.remove(tmp_bam)
  
  cat("  ✓ Written:", out_bam, "\n")
  return(out_bam)
}
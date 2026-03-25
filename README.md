# ImprintCap-ASM
ASM analysis for Imprint Disorders

Allele‑specific (ASM) methylation analysis pipeline for targeted bisulfite sequencing of human imprinting control regions (ICRs/DMRs). The pipeline links heterozygous SNPs to nearby CpGs at imprinted loci and quantifies allele‑specific methylation for each sample.

## Repository layout
```text
ImprintASM/
├─ dependencies.R                 # install packages before running the main script
├─ run_pipeline.R                 # main script (sources all functions, runs all samples)

├─ functions/
│  ├─ prepare_cpg_snp_input.R     # STEP 1: build CpG–SNP panel + BED from BS‑SNPer ouput files
│  ├─ extract_bam_regions.R       # STEP 2: extract wide BAM over CpG–SNP windows
│  └─ ASM.R                       # STEP 3: allele‑specific methylation from wide BAM

├─ data/
│  └─ filter_Cpgs.xlsx            # ImprintCap CpG panel + control/patient methylation data

├─ input/                         
│  ├─ SAMPLE_A_all.SNPs.out       # BS‑SNPer SNP output (VCF)
│  ├─ SAMPLE_A_all.CGmeth.txt     # BS‑SNPer CG methylation file
│  ├─ SAMPLE_A_all_markdup.bam    # duplicate‑marked BAM via picard
│  ├─ SAMPLE_A_all_markdup.bam.bai # index file
│  └─ ...

├─ asm_results/                   # OUTPUT: per‑sample tables + plots
│  ├─ asm_SAMPLE_A.xlsx
│  ├─ snp_cpg_SAMPLE_A.xlsx
│  ├─ meth_summary_SAMPLE_A.xlsx
│  ├─ dmr_plots_SAMPLE_A.pdf
│  └─ ...

├─ bam_asm/                       # OUTPUT: per‑sample wide BAMs
│  ├─ SAMPLE_A_all_wide.bam
│  ├─ SAMPLE_A_all_wide.bam.bai
│  └─ ...

├─ .gitignore                    
└─ README.md
``` 

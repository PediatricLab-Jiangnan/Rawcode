# Load required libraries
library(VariantAnnotation)
library(gwasvcf)
library(gwasglue)
library(TwoSampleMR)
library(ieugwasr)
library(dplyr)

# Set working directory
setwd("/path/to/working/directory")

# Read exposure data
exposure_vcf <- readVcf("your_exposure_data.vcf.gz")

# Filter exposure data by p-value
exposure_vcf_p_filter <- query_gwas(vcf = exposure_vcf, pval = 1e-05)

# Convert exposure data to TwoSampleMR format
exposure_data <- gwasvcf_to_TwoSampleMR(exposure_vcf_p_filter)

# Perform LD clumping
exposure_data_clumped <- ld_clump(
  dat = tibble(rsid = exposure_data$SNP,
               pval = exposure_data$pval.exposure,
               id = exposure_data$exposure),
  clump_kb = 10000,
  clump_r2 = 0.001,
  clump_p = 1,
  bfile = "./EUR",
  plink_bin = "./plink"
)

# Filter exposure data based on clumping results
exposure_data_clumped <- exposure_data %>% filter(exposure_data$SNP %in% exposure_data_clumped$rsid)

# Save clumped exposure data
write.csv(exposure_data_clumped, "exposure_data_clumped.csv", row.names = FALSE)

# Read outcome data
outcome_vcf <- readVcf("epilepsy.vcf.gz")

# Convert outcome data to TwoSampleMR format
outcome_data <- gwasvcf_to_TwoSampleMR(outcome_vcf)

# Merge exposure and outcome data
data_common <- merge(exposure_data_clumped, outcome_data, by = "SNP")

# Format outcome data
outcome_data <- format_data(outcome_data,
                            type = "outcome",
                            snps = data_common$SNP,
                            snp_col = "SNP",
                            beta_col = "beta.exposure",
                            se_col = "se.exposure",
                            eaf_col = "eaf.exposure",
                            effect_allele_col = "effect_allele.exposure",
                            other_allele_col = "other_allele.exposure",
                            pval_col = "pval.exposure",
                            samplesize_col = "samplesize.exposure",
                            ncase_col = "ncase.exposure",
                            id_col = "id.exposure")

# Set exposure and outcome IDs
exposure_data_clumped$id.exposure <- "BMI"
outcome_data$id.outcome <- "BRCA"

# Harmonize data
data <- harmonise_data(
  exposure_dat = exposure_data_clumped,
  outcome_dat = outcome_data
)

# Perform MR analysis
result <- mr(data)
result

# Heterogeneity test
mr_heterogeneity(data)

# Horizontal pleiotropy test
mr_pleiotropy_test(data)

# Scatter plot
p1 <- mr_scatter_plot(result, data)
p1

# Forest plot
result_single <- mr_singlesnp(data)
p2 <- mr_forest_plot(result_single)
p2

# Leave-one-out analysis
result_loo <- mr_leaveoneout(data)
p3 <- mr_leaveoneout_plot(result_loo)
p3

# Funnel plot
result_single <- mr_singlesnp(data)
p4 <- mr_funnel_plot(result_single)
p4
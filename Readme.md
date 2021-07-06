# TCR analysis pipeline

## Description

A pipeline to analyze single cell TCR data generated with the ICELL8. For the demultiplexing the [`pysc` script](https://github.com/erasmus-center-for-biomics/pysc) is used. 

## Quick-start

TCR specific PCR

```bash
# create the directory with the demultiplexed FastQ files
mkdir demultiplexed

# run the demultiplexing
pysc demultiplex \
  --read_1 path_to_read_1.fastq \
  --read_2 path_to_read_2.fastq \
  --well-list path_to_well_list.txt \
  --output-read-1 "demultiplexed/{sample}_{row}_{column}_R1.fastq" \
  --output-read-2 "demultiplexed/{sample}_{row}_{column}_R2.fastq" \
  --well-barcode-read 1 \
  --well-barcode-start 0 \
  --well-barcode-end 10 \
  --data-start 14

# analyse the demultiplexed data
snakemake \
  --snakefile path_to_tcr-workflows/workflows/tcr_analysis.smk \
  --configfile path_to_tcr-workflows/configuration/hsapiens.tcr.json \
  -j 6 \
  --resources mem_mb=16385

```

TCR expression profiles

```bash
# create the directory with the demultiplexed FastQ files
mkdir demultiplexed

# run the demultiplexing
pysc demultiplex \
  --read_1 path_to_read_1.fastq \  
  --well-list path_to_well_list.txt \
  --output-read-1 "demultiplexed/{sample}_R1.fastq" \
  --well-barcode-start 0 \
  --well-barcode-end 10 \
  --data-start 14

# analyze the demultiplexed data
snakemake \
  --snakefile path_to_tcr-workflows/workflows/expr_analysis.smk \
  --configfile path_to_tcr-workflows/configuration/hsapiens.expr.json \
  -j 6 \
  --resources mem_mb=16385

```

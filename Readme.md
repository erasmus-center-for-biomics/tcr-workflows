# TCR analysis pipeline

## Description

A pipeline to analyze single cell TCR data generated with the ICELL8.

## Quick-start

TCR specific PCR

```bash
# add the prerequisite python libraries if not installed
export PYTHONPATH=/data/Software/python/pyngs:/data/Software/python/pysc:$PYTHONPATH

# create the directory with the demultiplexed FastQ files
mkdir demultiplexed

# run the demultiplexing
python3 /data/Software/python/pysc/bin/pysc demultiplex \
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
repository=/data/Software/workflows/TCR/
snakemake \
  --snakefile ${repository}/workflows/tcr_analysis.smk \
  --configfile ${repository}/configuration/hsapiens.tcr.json \
  -j 6 \
  --resources mem_mb=16385

```

TCR expression profiles

```bash
# add the prerequisite python libraries if not installed
export PYTHONPATH=/data/Software/python/pyngs:/data/Software/python/pysc:$PYTHONPATH

# create the directory with the demultiplexed FastQ files
mkdir demultiplexed

# run the demultiplexing
python3 /data/Software/python/pysc/bin/pysc demultiplex \
  --read_1 path_to_read_1.fastq \  
  --well-list path_to_well_list.txt \
  --output-read-1 "demultiplexed/{sample}_R1.fastq" \
  --well-barcode-start 0 \
  --well-barcode-end 10 \
  --data-start 14

# analyze the demultiplexed data
repository=/data/Software/workflows/TCR/
snakemake \
  --snakefile ${repository}/workflows/expr_analysis.smk \
  --configfile ${repository}/configuration/hsapiens.expr.json \
  -j 6 \
  --resources mem_mb=16385

```

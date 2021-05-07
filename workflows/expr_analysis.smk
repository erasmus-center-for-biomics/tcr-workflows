#
# Controlling python code
#
import os
import os.path

def get_samples(indir="."):
    """Get the samples."""
    retval = []
    for fname in os.listdir(indir):
        if fname.endswith("_R1.fastq"):
            retval.append(fname.replace("_R1.fastq", ""))
    return retval

samples = sorted(get_samples("demultiplexed"))

#
# Snakemake rules
#
include: "../rules/trim.smk"
include: "../rules/hisat2.smk"
include: "../rules/samtools.smk"
include: "../rules/quantify.smk"
include: "../rules/qc.smk"


rule:
    input:
        bam=expand("hisat2/{basename}_R1.bam", basename=samples),
        bai=expand("hisat2/{basename}_R1.bam.bai", basename=samples),
        rpc=expand("hisat2/{basename}_R1.rpc", basename=samples),
        mpc=expand("hisat2/{basename}_R1.mpc", basename=samples),
        flagstats=expand("SAMtools/hisat2/{basename}_R1.flagstat.txt", basename=samples),
        overlap=expand("Quantification/Overlap/{basename}_R1.tsv.gz", basename=samples),
        exonic=expand("Quantification/{basename}_R1.exon.tsv.gz", basename=samples),
    shell:
        """
        find . -exec md5sum {{}} \; > expression.md5
        """


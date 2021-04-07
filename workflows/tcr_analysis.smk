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
include: "../rules/pear.smk"
include: "../rules/tcr-blast.smk"

rule:
    input:
        expand("pear/{basename}.assembled.fastq", basename=samples),
        expand("tcr-blast/{basename}.airr.gz", basename=samples),
        expand("tcr-blast/{basename}.report.csv", basename=samples),
        "assembled_reads.csv",
        "demultiplexed_reads.csv"
    shell:
        """
        """

rule:
    input:
        expand("pear/{basename}.assembled.fastq", basename=samples)
    output:
        "assembled_reads.csv"
    shell:
        """
        wc -l {input} | awk -F "\t" '{{print $1 "," $2 / 4}}' > {output}
        """

rule:
    input:
        expand("demultiplexed/{basename}_R1.fastq", basename=samples)
    output:
        "demultiplexed_reads.csv"
    shell:
        """
        wc -l {input} | awk -F "\t"  '{{print $1 "," $2 / 4}}' > {output}
        """

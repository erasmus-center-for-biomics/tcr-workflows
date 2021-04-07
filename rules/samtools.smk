
# index a BAM file
rule samtools_index:
    input:
        "{dataset}.bam"
    output:
        "{dataset}.bam.bai"
    shell:
        """
        {config[samtools][path]} index {input}
        """

# a rule to run samtools flagstat
rule samtools_flagstat:
    input:
        "{dataset}.bam"
    output:
        "SAMtools/{dataset}.flagstat.txt"
    shell:
        """
        {config[samtools][path]} flagstat {input} > {output}
        """

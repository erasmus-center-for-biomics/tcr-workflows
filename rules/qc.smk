
rule qc_reads_per_cell:
    input:
        "hisat2/{basename}.bam"
    output:
        "hisat2/{basename}.rpc"
    shell:
        """
        (
            echo "cellid count" | sed 's/ /\t/'
            {config[samtools][path]} view \
                -F 0x100 \
                -F 0x800 \
                {input} | \
                sed 's/^.*bc:Z://' | \
                sed 's/\t.*$//' | \
                sort | \
                uniq -c | \
                awk '{{print $2 "\t" $1}}' 
        )> {output}
        """


rule qc_mapped_per_cell:
    input:
        "hisat2/{basename}.bam"
    output:
        "hisat2/{basename}.mpc"
    shell:
        """
        (
            echo "cellid mapped" | sed 's/ /\t/'
            {config[samtools][path]} view \
                -F 0x4 \
                -F 0x100 \
                -F 0x800 \
                {input} | \
                sed 's/^.*bc:Z://' | \
                sed 's/\t.*$//' | \
                sort | \
                uniq -c | \
                awk '{{print $2 "\t" $1}}'
        ) > {output}
        """

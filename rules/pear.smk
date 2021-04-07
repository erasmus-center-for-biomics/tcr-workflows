rule pear:
    input:
        forward="trim/{basename}_R1.fastq",
        reverse="trim/{basename}_R2.fastq"
    output:
        assembled="pear/{basename}.assembled.fastq",
        discarded="pear/{basename}.discarded.fastq",
        forward="pear/{basename}.unassembled.forward.fastq",
        reverse="pear/{basename}.unassembled.reverse.fastq"
    params:
        basename="pear/{basename}"
    resources:
        mem_mb=2096
    shell:
        """
        {config[pear][path]} \
            -f "{input.forward}" \
            -r "{input.reverse}" \
            -o "{params.basename}"
        """

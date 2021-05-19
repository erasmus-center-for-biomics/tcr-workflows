rule pear:
    input:
        fwd="trim/{basename}_R1.fastq",
        rev="trim/{basename}_R2.fastq"
    output:
        assembled="pear/{basename}.assembled.fastq",
        discarded="pear/{basename}.discarded.fastq",
        fwd="pear/{basename}.unassembled.forward.fastq",
        rev="pear/{basename}.unassembled.reverse.fastq"
    params:
        basename="pear/{basename}"
    resources:
        mem_mb=2096
    shell:
        """
        {config[pear][path]} \
            -f "{input.fwd}" \
            -r "{input.rev}" \
            -o "{params.basename}"
        """

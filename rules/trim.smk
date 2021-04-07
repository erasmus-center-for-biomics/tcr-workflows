rule trim:
    input:
        "demultiplexed/{basename}.fastq"
    output:
        temp("trim/{basename}.fastq")
    params:
        sequences=" -a ".join(config["adapter_trim"]["sequences"])
    resources:
        mem_mb=2096
    benchmark:
        "benchmarks/01_trim/{basename}.benchmark.txt"
    shell:
        """
        {config[adapter_trim][path]} \
            --input "{input}" \
            --output "{output}" \
            -a {params.sequences} \
            --maximum-mismatches {config[adapter_trim][maximum_mismatches]} \
            --minimum-matches {config[adapter_trim][minimum_matches]} \
            --minimum-bases-remaining {config[adapter_trim][minimum_bases_remaining]}
        """

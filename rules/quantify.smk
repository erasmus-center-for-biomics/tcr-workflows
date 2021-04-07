rule to_bed:
    input:
        "hisat2/{dataset}.bam"
    output:
        "Quantification/BED/{dataset}.bed.gz"
    threads:
        4
    resources:
        mem_mb=8196
    benchmark:
        "benchmarks/04_quantify/to_bed/{dataset}.benchmark.txt"
    shell:
        """
        {config[samtools][path]} view \
            -h \
            -F 0x0100 \
            -F 0x0800 \
            -F 0x0004 \
            {input} | \
            {config[sam_to_bed][path]} \
                --cigar-operations M \
                --tags sm bc rw cl | \
                sort \
                    -k 1,1 -k 2,2n \
                    --parallel {threads} \
                    -S {resources.mem_mb}M | \
                    {config[bgzip][path]} -c > {output}
        """

rule overlap:
    input:
        "Quantification/BED/{dataset}.bed.gz"
    output:
        temp("Quantification/Overlap/{dataset}.tsv.gz")
    resources:
        mem_mb=8196
    benchmark:
        "benchmarks/04_quantify/overlap/{dataset}.benchmark.txt"
    shell:
        """
        {config[bedtools_intersect][path]} \
            -wao \
            -sorted \
            {config[bedtools_intersect][options]} \
            -a {input} \
            -b {config[bedtools_intersect][reference]} | \
                {config[extract_columns][path]} \
                    --columns {config[extract_columns][columns]} \
                    --encodings {config[extract_columns][encodings]} \
                    --fields {config[extract_columns][fields]} \
                    --output {output}
        """


rule quantify_exonic:
    input:
        "Quantification/Overlap/{basename}.tsv.gz"
    output:
        "Quantification/{basename}.exon.tsv.gz"
    resources:
        mem_mb=8196
    threads:
        4
    benchmark:
        "benchmarks/04_quantify/exonic/{basename}.benchmark.txt"
    shell:
        """
        zcat {input} | grep '^exon' | \
            {config[extract_columns_quantify][path]} \
                --columns {config[extract_columns_quantify][columns]} \
                --encodings {config[extract_columns_quantify][encodings]} \
                --fields {config[extract_columns_quantify][fields]} | \
                sort --parallel {threads} -S {resources.mem_mb}M | \
                    {config[count_last_column][path]} \
                    --output {output}
        """

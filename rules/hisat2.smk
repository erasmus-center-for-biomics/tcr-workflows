import os.path

rule hisat2_single_read:
    input:
        "trim/{basename}.fastq"
    output:
        "hisat2/{basename}.bam"
    threads: 6
    resources:
        mem_mb=10240
    params:
        sampleid="{basename}",
        fullpath=os.path.abspath("hisat2/{basename}.bam"),
        tempbase="hisat2/{basename}_samtools_coord_sort_"
    benchmark:
        "benchmarks/02_alignment/hisat2/{basename}.benchmark.txt"
    shell:
        """
        {config[hisat2][path]} \
            -p {threads} \
            -x {config[hisat2][reference]} \
            -U {input} | \
                {config[samtools][path]} addreplacerg \
                    -r "ID:{params.sampleid}" \
    				-r "CN:ECB" \
    				-r "LB:{params.sampleid}" \
    				-r "SM:{params.sampleid}" \
    				-r "PL:ILLUMINA" \
    				-r "DS:{params.fullpath}" \
                    - | \
                    {config[add_tags][path]} \
                        --well-list {config[add_tags][annotation]} \
                        --barcode-field {config[add_tags][barcode-field]} | \
                        {config[samtools][path]} sort \
                            -T {params.tempbase} \
                            -m 2048M \
                            -o {output} \
                            -
        """

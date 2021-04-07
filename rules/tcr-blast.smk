
rule fastq_to_fasta:
    input:
        "pear/{basename}.assembled.fastq"
    output:
        "tcr-blast/{basename}.fasta"
    shell:
        """
        awk '{{if(NR % 4 == 1) print ">" substr($0, 1); if(NR % 4 == 2) print $0;}}' {input} > {output}
        """

rule tcr_igblast:
    input:
        "tcr-blast/{basename}.fasta"
    output:
        airr="tcr-blast/{basename}.airr.gz",
        clonotypes="tcr-blast/{basename}.clonotypes"
    threads:
        4
    shell:
        """
        export IGDATA="{config[igblastn][env]}"
        {config[igblastn][path]} \
            -num_threads {threads} \
            -germline_db_V {config[igblastn][db-V]} \
            -germline_db_D {config[igblastn][db-D]} \
            -germline_db_J {config[igblastn][db-J]} \
            -ig_seqtype TCR \
            -show_translation \
            -organism {config[igblastn][organism]} \
            -auxiliary_data {config[igblastn][auxilary]} \
            -outfmt 19 \
            -query {input} \
            -clonotype_out {output.clonotypes} | gzip -c > {output.airr}
        """

rule tcr_report:
    input:
        "tcr-blast/{basename}.airr.gz"
    output:
        "tcr-blast/{basename}.report.csv"
    shell:
        """
        ( \
        echo "v_call;d_call;j_call;productive;locus;cdr3;cdr3_aa;n" ; \
        zcat {input} | \
            awk -F "\t" '{{if($1 != "sequence_id" && $49 > 300) print $8 ";" $9 ";" $10 ";" $6 ";" $3 ";" $43 ";" $44}}' | \
            sort | \
            uniq -c | \
            sed 's/^ +//' | \
            awk '{{print $2 ";" $1}}' ) > {output}
        """

process PICARD_DICT {
    tag "hg38"

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    path fasta

    output:
    path "*.dict", emit: dict

    script:
    """
    picard CreateSequenceDictionary \
        -R ${fasta} \
        -O ${fasta.baseName}.dict
    """
}
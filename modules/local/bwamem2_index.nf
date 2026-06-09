process BWAMEM2_INDEX {
    tag "hg38"
    
    container 'quay.io/biocontainers/bwa-mem2:2.2.1--he513fc3_0'
    
    publishDir "${params.outdir}/reference", mode: 'copy'
    
    input:
    path fasta
    
    output:
    path "*.{0123,amb,ann,bwt.2bit.64,pac}", emit: index
    
    script:
    """
    bwa-mem2 index ${fasta}
    """
}
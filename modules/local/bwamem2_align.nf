process BWAMEM2_ALIGN {
    tag "$sample_id"
    
   container 'quay.io/biocontainers/mulled-v2-ac74a7f02cebcfbc0058b9a6d25034f3b8a91f5e:c6a9808c2cf3fbb2d6dfd495b428de86905d5a5c-0'
    
    publishDir "${params.outdir}/alignment", mode: 'copy'
    
    input:
    tuple val(sample_id), path(r1), path(r2)
    path index
    
    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam
    
    script:
    """
    bwa-mem2 mem \\
        -t ${task.cpus} \\
        -R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA" \\
        hg38.fa.gz \\
        ${r1} ${r2} | \\
        samtools sort -@ ${task.cpus} -o ${sample_id}.bam
    
    samtools index ${sample_id}.bam
    """
}
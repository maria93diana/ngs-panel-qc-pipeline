process BWAMEM2_ALIGN {
    tag "$sample_id"
    
    conda 'bioconda::bwa-mem2=2.2.1 bioconda::samtools=1.21'
    
    publishDir "${params.outdir}/alignment", mode: 'copy'
    
    input:
    tuple val(sample_id), path(r1), path(r2)
    path fasta
    path index
    
    output:
    tuple val(sample_id), path("${sample_id}.bam"), emit: bam
    tuple val(sample_id), path("${sample_id}.bam.bai"), emit: bai
    
    script:
    """
    bwa-mem2 mem \\
        -t ${task.cpus} \\
        -R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA" \\
        ${fasta} \\
        ${r1} ${r2} | \\
        samtools sort -@ ${task.cpus} -o ${sample_id}.bam
    
    samtools index ${sample_id}.bam
    """
}
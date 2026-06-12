process PICARD_COLLECTHSMETRICS {
    tag "$sample_id"

    stageInMode 'copy'

    publishDir "${params.outdir}/picard", mode: 'copy'

    input:
    tuple val(sample_id), path(bam), path(bai)
    path bait_intervals
    path target_intervals
    tuple path(fasta), path(fai), path(gzi)

    output:
    tuple val(sample_id), path("${sample_id}_hs_metrics.txt"), emit: metrics

    script:
    """
    picard CollectHsMetrics \
        -I ${bam} \
        -O ${sample_id}_hs_metrics.txt \
        -BAIT_INTERVALS ${bait_intervals} \
        -TARGET_INTERVALS ${target_intervals} \
        -R ${fasta}
    """
}
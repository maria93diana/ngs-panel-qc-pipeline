process LIFTOVER_INTERVALS {
    tag "hg19_to_hg38"

    publishDir "${params.outdir}/intervals", mode: 'copy'

    input:
    path baits
    path targets

    output:
    path "ActSeqBaits_hg38.bed",   emit: baits
    path "ActSeqTargets_hg38.bed", emit: targets

    script:
    """
    python3 ${projectDir}/scripts/liftover_intervals.py \
        --baits   ${baits} \
        --targets ${targets} \
        --out_baits   ActSeqBaits_hg38.bed \
        --out_targets ActSeqTargets_hg38.bed
    """
}
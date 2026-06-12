process PICARD_BED_TO_INTERVAL {
    tag "${bed.baseName}"

    publishDir "${params.outdir}/intervals", mode: 'copy'

    input:
    path bed
    path dict

    output:
    path "*.interval_list", emit: interval_list

    script:
    """
    picard BedToIntervalList \
        -I ${bed} \
        -O ${bed.baseName}.interval_list \
        -SD ${dict}
    """
}
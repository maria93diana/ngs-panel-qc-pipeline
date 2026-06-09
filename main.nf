#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { FASTQC as FASTQC_RAW  } from './modules/local/fastqc'
include { FASTQC as FASTQC_TRIM } from './modules/local/fastqc'
include { TRIMGALORE             } from './modules/local/trimgalore'

workflow {
    reads_ch = Channel
        .fromFilePairs( params.reads, checkIfExists: true )

    FASTQC_RAW( reads_ch )
    
    TRIMGALORE( reads_ch )
    
    trimmed_ch = TRIMGALORE.out.trimmed_reads
        .map { sample_id, r1, r2 -> tuple( sample_id, [r1, r2] ) }
    
    FASTQC_TRIM( trimmed_ch )
}
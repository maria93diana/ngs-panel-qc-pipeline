#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { FASTQC as FASTQC_RAW                              } from './modules/local/fastqc'
include { FASTQC as FASTQC_TRIM                             } from './modules/local/fastqc'
include { TRIMGALORE                                         } from './modules/local/trimgalore'
include { BWAMEM2_INDEX                                      } from './modules/local/bwamem2_index'
include { BWAMEM2_ALIGN                                      } from './modules/local/bwamem2_align'
include { LIFTOVER_INTERVALS                                 } from './modules/local/liftover_intervals'
include { PICARD_DICT                                        } from './modules/local/picard_dict'
include { PICARD_BED_TO_INTERVAL as PICARD_BAITS_INTERVAL   } from './modules/local/picard_bed_to_interval'
include { PICARD_BED_TO_INTERVAL as PICARD_TARGETS_INTERVAL } from './modules/local/picard_bed_to_interval'
include { SAMTOOLS_FAIDX                                     } from './modules/local/samtools_faidx'
include { PICARD_COLLECTHSMETRICS                            } from './modules/local/picard_collecthsmetrics'

workflow {
    reads_ch = Channel
        .fromFilePairs( params.reads, checkIfExists: true )

    fasta_ch = Channel
        .fromPath( params.fasta, checkIfExists: true )
        .first()

    baits_ch   = Channel.fromPath( params.baits,   checkIfExists: true )
    targets_ch = Channel.fromPath( params.targets,  checkIfExists: true )

    FASTQC_RAW( reads_ch )

    TRIMGALORE( reads_ch )

    FASTQC_TRIM(
        TRIMGALORE.out.trimmed_reads
            .map { sample_id, r1, r2 -> tuple( sample_id, [r1, r2] ) }
    )

    BWAMEM2_INDEX( fasta_ch )

    BWAMEM2_ALIGN(
        TRIMGALORE.out.trimmed_reads
            .map { sample_id, r1, r2 -> tuple( sample_id, r1, r2 ) },
        fasta_ch,
        BWAMEM2_INDEX.out.index.collect()
    )

    LIFTOVER_INTERVALS( baits_ch, targets_ch )

    PICARD_DICT( fasta_ch )

    SAMTOOLS_FAIDX( fasta_ch )

    bait_interval_ch = PICARD_BAITS_INTERVAL(
        LIFTOVER_INTERVALS.out.baits,
        PICARD_DICT.out.dict
    ).interval_list

    target_interval_ch = PICARD_TARGETS_INTERVAL(
        LIFTOVER_INTERVALS.out.targets,
        PICARD_DICT.out.dict
    ).interval_list

    bam_ch = BWAMEM2_ALIGN.out.bam
        .join( BWAMEM2_ALIGN.out.bai )

    PICARD_COLLECTHSMETRICS(
        bam_ch,
        bait_interval_ch.collect(),
        target_interval_ch.collect(),
        SAMTOOLS_FAIDX.out.fasta
            .combine(SAMTOOLS_FAIDX.out.fai)
            .combine(SAMTOOLS_FAIDX.out.gzi)
    )
}
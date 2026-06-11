# ngs-panel-qc-pipeline
Nextflow DSL2 pipeline for targeted NGS panel QC — FASTQ to coverage metrics

## Test Dataset

This pipeline is tested using publicly available human oncology panel sequencing data from the **ActSeq** project (BioProject [PRJNA803819](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA803819)):

- **Sample1**: SRR17898374 (HD827 reference standard, 500k reads subset)
- **Sample2**: SRR17898371 (500k reads subset)

**Library type**: Targeted panel sequencing, hybrid capture (141 cancer genes including KRAS, NRAS, BRAF, ALK, EGFR)  
**Instrument**: Illumina NextSeq 500, 151bp paired-end  
**Reference**: chr21 of hg38 (subset for testing — pipeline designed to scale to full hg38)

To reproduce, download and subset the data:
```bash
fasterq-dump --split-files -X 500000 SRR17898374
fasterq-dump --split-files -X 500000 SRR17898371
```
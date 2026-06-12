#!/usr/bin/env python3
"""
Liftover ActSeq panel interval files from hg19 to hg38.
Filters to keep only intervals on chromosomes present in the reference.
Called by the Nextflow process LIFTOVER_INTERVALS.
"""

import argparse
from liftover import get_lifter

def liftover_interval_list(input_file, output_file, converter, keep_chroms=None):
    converted = 0
    failed = 0
    skipped = 0
    with open(input_file) as fin, open(output_file, 'w') as fout:
        for line in fin:
            if line.startswith('@'):
                continue
            parts = line.strip().split('\t')
            if len(parts) < 5:
                continue
            chrom, start, end, strand, name = (
                parts[0], int(parts[1]), int(parts[2]), parts[3], parts[4]
            )
            result_start = converter[chrom][start]
            result_end   = converter[chrom][end]
            if result_start and result_end:
                new_chrom = result_start[0][0]
                new_start = result_start[0][1]
                new_end   = result_end[0][1]
                if keep_chroms and new_chrom not in keep_chroms:
                    skipped += 1
                    continue
                fout.write(f"{new_chrom}\t{new_start}\t{new_end}\t{strand}\t{name}\n")
                converted += 1
            else:
                failed += 1
    print(f"{input_file}: {converted} converted, {failed} failed, {skipped} skipped")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--baits',        required=True)
    parser.add_argument('--targets',      required=True)
    parser.add_argument('--out_baits',    required=True)
    parser.add_argument('--out_targets',  required=True)
    parser.add_argument('--chroms',       default=None,
                        help='Comma-separated list of chromosomes to keep (e.g. chr21)')
    args = parser.parse_args()

    keep_chroms = set(args.chroms.split(',')) if args.chroms else None

    print("Loading hg19 -> hg38 converter...")
    converter = get_lifter('hg19', 'hg38')

    print("Converting baits...")
    liftover_interval_list(args.baits, args.out_baits, converter, keep_chroms)

    print("Converting targets...")
    liftover_interval_list(args.targets, args.out_targets, converter, keep_chroms)

    print("Done.")
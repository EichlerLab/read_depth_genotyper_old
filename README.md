# Read depth genotyper

## Usage

Use an existing gglob directory to genotype a set of regions in a BED file.

    make -f /path/to/genotyper_repo/Makefile SAMPLE_PATH=/path/to/gglob_dir REGIONS_FILE=/path/to/regions_to_genotype.bed

Raw genotypes will be in the files named "genotypes_wssd.bed" and "genotypes_sunk.bed".

If ``SAMPLE_PATH`` is omitted, 1000 Genomes samples will be used by default.

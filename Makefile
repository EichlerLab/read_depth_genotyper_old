#"Genotype" regions from gglob directory
USER_NAME=$(shell whoami)

SAMPLE_PATH=/net/eichler/vol22/projects/1000_genomes_phase_II_III/nobackups/gglob/

REF_GENE=/net/eichler/vol2/eee_shared/assemblies/hg19/genes/refGene.bed
SUPER_DUP=/net/eichler/vol2/eee_shared/assemblies/hg19/wgac/genomicSuperDup.tab

REGIONS_FILE=$(REF_GENE)
#SAMPLE_PATH=all_dts_list.txt

all :

.PHONY : genotypes

.SECONDARY :

all : genotype_regions

genotype_regions : genotypes_wssd_annotated.bed genotypes_sunk_annotated.bed

genotypes_wssd_annotated.bed : wssd_annotated.bed genotypes_wssd.bed
	cut -f 4- $(word 2,$^) | paste $(word 1,$^) - > $@

genotypes_sunk_annotated.bed : sunk_annotated.bed genotypes_sunk.bed
	cut -f 4- $(word 2,$^) | paste $(word 1,$^) - > $@

sunk_annotated.bed : genotypes_sunk.bed refGene.merged.bed
	echo -e "chr\tstart\tend\tgenes" > $@
	sed 1d $< | cut -f 1,2,3 | bedtools intersect -loj -a stdin -b refGene.merged.bed \
		| cut -f 1,2,3,7 | groupBy -i stdin -grp 1,2,3 -c 4 -o distinct >> $@

wssd_annotated.bed : genotypes_wssd.bed refGene.merged.bed
	echo -e "chr\tstart\tend\tgenes" > $@
	sed 1d $< | cut -f 1,2,3 | bedtools intersect -loj -a stdin -b refGene.merged.bed \
		| cut -f 1,2,3,7 | groupBy -i stdin -grp 1,2,3 -c 4 -o distinct >> $@

genotypes_sunk.bed : $(SAMPLE_PATH) $(REGIONS_FILE)
	mkdir -p /var/tmp/$(USER_NAME)
	python ~psudmant/EEE_Lab/projects/common_code/ssf_DTS_caller/genotype_regions.py --gglob_dir $^ --sunk /var/tmp/$(USER_NAME)/$@
	mv /var/tmp/$(USER_NAME)/$@ .

genotypes_wssd.bed : $(SAMPLE_PATH) $(REGIONS_FILE)
	mkdir -p /var/tmp/$(USER_NAME)
	python ~psudmant/EEE_Lab/projects/common_code/ssf_DTS_caller/genotype_regions.py --gglob_dir $^ /var/tmp/$(USER_NAME)/$@
	mv /var/tmp/$(USER_NAME)/$@ .

refGene.merged.bed : $(REF_GENE)
	groupBy -i $< -g 1,2,3 -c 4 -o distinct > $@

segments.merged.bed : segments.bed
	python ~bnelsj/gglob_get_genotypes/merge_segments.py $< > $@

segments.bed : wgac.bed
	bedtools genomecov -d -i wgac.bed -g /net/eichler/vol2/eee_shared/assemblies/hg19/chromInfo.txt \
		| groupBy -i stdin -g 1,3 -c 2,2 -o min,max \
		| awk 'OFS="\t" { if ($$2 > 0) { print $$1,$$3,$$4,$$2,$$4-$$3 } }' > $@

wgac.bed :
	cut -f 1-3 $(REGIONS_FILE) \
		| sort -k 1,1 -k 2,2n -k 3,3n > $@

#!/bin/bash

mkdir -pv data

if [ ! -e "data/CosmicMutantExportCensus.tsv.gz" ]; then
	rsync -avP hpc:/lustre/work/user/yanll/Data/COSMIC/Data/v86_grch37/CosmicMutantExportCensus.tsv.gz data/
fi
if [ ! -e "data/top-50-genes.txt" ]; then
	echo 1>&2 "Generate 'data/top-50-genes.txt'"
	zcat data/CosmicMutantExportCensus.tsv.gz \
		| cut -f1 \
		| sed 1d \
		| sort \
		| uniq -c \
		| sort -nr \
		| head -n50 \
		| awk 'BEGIN{print"gene\tcount"}{print$2"\t"$1}' \
		> data/top-50-genes.txt
fi

mkdir -pv data/genes/

#cat data/top-50-genes.txt \
#	| sed 1d \
#	| cut -f1 \
#	| while read GENE; do
#		if [ ! -e "data/genes/${GENE}.csv" ]; then
#			echo 1>&2 "Download 'data/genes/${GENE}.csv'"
#			curl 'https://www.ncbi.nlm.nih.gov/pubmed?p$l=Email&Mode=download&term='${GENE}'&dlid=timeline&filename=timeline.csv&bbid=NCID_1_7490750_130.14.22.33_9001_1566563559_1548472358_0MetA0_S_MegaStore_F_1&p$debugoutput=off' > data/genes/${GENE}.csv
#			sleep 1
#		fi
#	done
#
if [ ! -e "data/gene-results.txt" ]; then
	echo 1>&2 "Generate 'data/gene-results.txt'"
	cat data/top-50-genes.txt \
		| sed 1d \
		| while read GENE COUNT; do
			cat data/genes/${GENE}.csv | sed 1,2d | awk -F',' '{OFS="\t";print"'${GENE}'",'${COUNT}',$1,$2}'
		done \
			| awk -F'\t' 'BEGIN{OFS="\t";print"gene","cosmic","year","pubmed"}$3!=""{print$0}' \
			> data/gene-results.txt
fi

if [ ! -e "data/gene-results-2.txt" ]; then
	echo 1>&2 "Generate 'data/gene-results-2.txt'"
	cat data/top-50-genes.txt \
		| sed 1d \
		| while read GENE COUNT; do
			cat data/genes2/${GENE}.csv | sed 1,2d | awk -F',' '{OFS="\t";print"'${GENE}'",'${COUNT}',$1,$2}'
		done \
			| awk -F'\t' 'BEGIN{OFS="\t";print"gene","cosmic","year","pubmed"}$3!=""{print$0}' \
			> data/gene-results-2.txt
fi

#!/bin/bash
## For AD PRS calculation using PRScs
## all SNPs in Nalls PD GWAS summary statistics will be used.
bfile_prefix=$1
out=$2
name=$3
chr=$4 #make sure the bim file is separated by chrom
SAMPLE_SIZE=$5
SUM_STATS_FILE=$6

if [[ -z $bfile_prefix ]]; then echo "ERROR: bfile prefix (1st arg) not specified"; exit 42; fi
if [[ -z $out ]]; then echo "ERROR: out directory (2nd arg) not specified"; exit 42; fi
if [[ -z $name ]]; then echo "ERROR: name for output file(3rd arg) not specified"; exit 42; fi
if [[ -z $chr ]]; then echo "ERROR: chr number (4th arg) not specified"; exit 42; fi
if [[ -z $SAMPLE_SIZE ]]; then echo "ERROR: SAMPLE_SIZE for GWAS (5th arg) not specified"; exit 42; fi
if [[ -z $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE (6th arg) not specified"; exit 42; fi
if [[ ! -f $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILEr does not EXIST"; exit 42; fi

echo "checking the header, is it one of SNP A1 A2 BETA P and SNP A1 A2 OR P? also make sure it is tsv file"
echo $(head -n 1 $SUM_STATS_FILE)

# to keep the format of my original script. I did some stupid repetitive coding below
# I only change the colum name and subset.no filtering for variants
# awk 'BEGIN{OFS="\t"} {print $3, $4, $5, $7, $6}' GCST90027158_buildGRCh38_PRS_nomissing.QC.tsv.QC > GCST90027158_buildGRCh38_PRS_nomissing.QC.tsv.QC.PRScs
OUTPUT_DIR=$out
OUTPUT_DIR_FINAL=$out_final
chr=$chr
module load StdEnv/2020 scipy-stack/2020a python/3.8.10 gcc/9.3.0 hdf5/1.12.1
## under /home/liulang/runs/lang/software/PRScs
### run the following before your run PRScs
N_THREADS=1
export MKL_NUM_THREADS=$N_THREADS
export NUMEXPR_NUM_THREADS=$N_THREADS
export OMP_NUM_THREADS=$N_THREADS
### default flag
PATH_TO_REFERENCE="/home/liulang/liulang/reference/ldblk_1kg_eur";
VALIDATION_BIM_PREFIX=$bfile_prefix
SCRIPT_DIR=/home/liulang/liulang/software/PRScs
GWAS_SAMPLE_SIZE=$SAMPLE_SIZE;


echo "start running iterations"
#mkdir -p ${OUTPUT_DIR}/${name}
echo "the posterior effect size file will be stored in ${OUTPUT_DIR}"
# add -u to force python output the log info
python -u ${SCRIPT_DIR}/PRScs.py --ref_dir=$PATH_TO_REFERENCE --bim_prefix=$VALIDATION_BIM_PREFIX --sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE --chrom=$chr --out_dir=${OUTPUT_DIR}/${name}
echo "iterations completed"
#sbatch -c 5 --mem=10g -t 3:0:0 --wrap "$command" --account=def-grouleau --out ${OUTPUT_DIR}/log.out;
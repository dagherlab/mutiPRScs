bfile_prefix=$1
out=$2
name=$3
chr=$4
SAMPLE_SIZE=$5
SUM_STATS_FILE=$6

if [[ -z $bfile_prefix ]]; then echo "ERROR: bfile prefix (1st arg) not specified"; exit 42; fi
if [[ -z $out ]]; then echo "ERROR: out directory (2nd arg) not specified"; exit 42; fi
if [[ -z $name ]]; then echo "ERROR: name for output file(3rd arg) not specified"; exit 42; fi
if [[ -z $chr ]]; then echo "ERROR: chr number (4th arg) not specified"; exit 42; fi
if [[ -z $SAMPLE_SIZE ]]; then echo "ERROR: SAMPLE_SIZE for GWAS (5th arg) not specified"; exit 42; fi
if [[ -z $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE (6th arg) not specified"; exit 42; fi
if [[ ! -f $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE does not EXIST"; exit 42; fi
SECONDS=0
SUM_STATS_FILE_POSTERIOR=${out}/effect_size/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
if [ ! -f $SUM_STATS_FILE_POSTERIOR ];then 
    script_dir=/lustre06/project/6001220/liulang/PRS/scripts
    bash ${script_dir}/general_PRScs.part1.sh $bfile_prefix $out/effect_size $name $chr $SAMPLE_SIZE $SUM_STATS_FILE
    # if this is done, calculate the score
    SUM_STATS_FILE_POSTERIOR=${out}/effect_size/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
fi 
if [[ ! -f $SUM_STATS_FILE_POSTERIOR ]]; then echo "ERROR: SUM_STATS_FILE_POSTERIOR does not EXIST"; exit 42; fi
echo "posterior sum stats file $SUM_STATS_FILE_POSTERIOR found. start to calculate the scores"
bash ${script_dir}/general_PRScs.part2.sh $bfile_prefix $out $name $chr
duration=$SECONDS
echo "$((duration / 60)) minutes and $((duration % 60)) seconds elapsed."


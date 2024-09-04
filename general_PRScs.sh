bfile_prefix=$1
out=$2
name=$3
chr=$4
SUM_STATS_FILE=$5
OR=${6:-"TRUE"}
SUM_STATS_FILE_NAME=$(basename $SUM_STATS_FILE)

echo "listing arguments"
echo "bfile_prefix ${bfile_prefix}"
echo "output directory to all files ${out}"
echo "name of the folder/output ${name}"
echo "chromosome number ${chr}"
echo "SUM_STATS_FILE before processing and CS ${SUM_STATS_FILE}"
echo "does the sumstat come with OR? ${OR}"
echo "SUM_STATS_FILE_NAME ${SUM_STATS_FILE_NAME}"

if [[ -z $bfile_prefix ]]; then echo "ERROR: bfile prefix (1st arg) not specified"; exit 42; fi
if [[ -z $out ]]; then echo "ERROR: out directory (2nd arg) not specified"; exit 42; fi
if [[ -z $name ]]; then echo "ERROR: name for output file(3rd arg) not specified"; exit 42; fi
if [[ -z $chr ]]; then echo "ERROR: chr number (4th arg) not specified"; exit 42; fi
if [[ -z $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE (6th arg) not specified"; exit 42; fi
if [[ ! -f $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE does not EXIST"; exit 42; fi


SECONDS=0
script_dir=/lustre06/project/6001220/liulang/PRS/scripts
#calculate sample size
echo "calculating sample size"
SAMPLE_SIZE=$(sed -n '2p' $SUM_STATS_FILE | cut -f9)
echo "sample size is $SAMPLE_SIZE"
if [[ -z $SAMPLE_SIZE ]]; then echo "ERROR: SAMPLE_SIZE for GWAS not specified"; exit 42; fi

# process sumstat (its extension has to be new.rsid.glm.logistic/linear)
if [ ! -f ${out}/sumstat/${SUM_STATS_FILE_NAME} ];then
    echo "processing sumstat file"
    mkdir -p ${out}/sumstat
    bash ${script_dir}/process_sumstat.sh $SUM_STATS_FILE ${out}/sumstat $chr $OR
else
    echo "processed sumstat file found, processing skipped"
fi

SUM_STATS_FILE=${out}/sumstat/${SUM_STATS_FILE_NAME}_chr${chr}.PRScs
SUM_STATS_FILE_POSTERIOR=${out}/effect_size/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
if [ ! -f $SUM_STATS_FILE_POSTERIOR ];then 
    bash ${script_dir}/general_PRScs.part1.sh $bfile_prefix $out/effect_size $name $chr $SAMPLE_SIZE $SUM_STATS_FILE
    # if this is done, calculate the score
    SUM_STATS_FILE_POSTERIOR=${out}/effect_size/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt
fi 

if [[ ! -f $SUM_STATS_FILE_POSTERIOR ]]; then echo "ERROR: SUM_STATS_FILE_POSTERIOR does not EXIST"; exit 42; fi
echo "posterior sum stats file $SUM_STATS_FILE_POSTERIOR found. start to calculate the scores"
bash ${script_dir}/general_PRScs.part2.sh $bfile_prefix $out $name $chr
duration=$SECONDS
echo "$((duration / 60)) minutes and $((duration % 60)) seconds elapsed."


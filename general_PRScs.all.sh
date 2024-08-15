bfile=$1 #bfile is chromosomal plink file prefix, use # to represent chr number (ex, PING_chr#.qc)
out=$2 # for the posterior effect size files
out_final=$3
name=$4
SAMPLE_SIZE=$5
SUM_STATS_FILE=$6 # sumstat file need have the columns SNP A1 A2 BETA P/SNP A1 A2 BETA SE/SNP A1 A2 OR P/SNP A1 A2 OR SE, and remove SNP with invalud values (empty, NA, inf, special symbols)
core=${7:-1} # default resource, see below, choose 3 for UKB.
option=${8:-1} # default option for running the first part (pst and sscores)
# if 2, thats calculate the final score

if [[ "$core" == 1 ]];then 
resource="-c 1 --mem=20g -t 3:0:0"
elif [[ "$core" == 2 ]]; then 
resource="-c 1 --mem=30g -t 5:0:0"
elif [[ "$core" == 3 ]]; then 
resource="-c 1 --mem=40g -t 7:0:0"
fi


if [[ -z $bfile ]]; then echo "ERROR: bfile (1st arg) not specified"; exit 42; fi
if [[ -z $out ]]; then echo "ERROR: out directory (2nd arg) not specified"; exit 42; fi
if [[ -z $name ]]; then echo "ERROR: name for output file(3rd arg) not specified"; exit 42; fi
if [[ -z $SAMPLE_SIZE ]]; then echo "ERROR: SAMPLE_SIZE for GWAS (5th arg) not specified"; exit 42; fi
if [[ -z $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE (6th arg) not specified"; exit 42; fi
if [[ ! -f $SUM_STATS_FILE ]]; then echo "ERROR: SUM_STATS_FILE $SUM_STATS_FILE does not EXIST"; exit 42; fi

mkdir -p $out/effect_size
mkdir -p $out/scores 
mkdir -p $out_final
mkdir -p ${out}/out
# iteratively submit jobs to slurm job scheduler
if [[ "$option" == 1 ]];then 
echo "going to prepare the posterior effect size and calculate the chromosomal scores"
answer=yes
# echo "looks like the scores for chr22 is present."
# read -p "Do you wanna rerun the posterior effect size calculation(yes/no)?: " answer
elif [[ "$option" == 2 ]];then 
answer=no
echo "you choose to skip the posterior effect size part, we are gonna check if you have all files prepared for the final"


while true; do
  all_files_present=true
  for chr in {1..22};do 
    file=${out}/scores/${name}.chr${chr}.sscore
    if [ ! -f "$file" ]; then
      echo "$file not found, please resubmit them to part 1"
      all_files_present=false
    fi
  done

  if $all_files_present; then
     echo "All files found, running the next program."
  else
     exit 42
  fi
done

fi 

chr=1
if [[ "$answer" == "yes" ]]; then
  while [[ $chr -le 22 ]]; do 
    bfile_prefix=$(echo $bfile| sed "s/\#/${chr}/g")
    if [[ ! -f ${bfile_prefix}.bim ]]; then echo "ERROR: bfile ${bfile_prefix}.bim does not EXIST"; exit 42; fi
    if [[ ! -f ${out}/scores/${name}.chr${chr}.sscore ]];then 
      echo "$bfile_prefix is being calculated"
      command="bash /home/liulang/liulang/PRS/scripts/general_PRScs.sh ${bfile_prefix} ${out} ${name} ${chr} $SAMPLE_SIZE $SUM_STATS_FILE"
      #echo $command
      jobs=$(squeue -u $USER | tail -n +2 | wc -l) # count the number of jobs
      if [[ $jobs < 999 ]];then 
        sbatch $resource --wrap "$command" --account=rrg-adagher --out ${out}/out/${name}_chr${chr}.out --job-name=${name}_chr${chr};
        ((chr++))
      else
          echo "we've reached the job submission quota, sleeping for an hour"
          sleep 1h
      fi
      # srun $resource --account=rrg-adagher bash /home/liulang/liulang/PRS/scripts/general_PRScs.sh ${bfile_prefix} ${out} ${name} ${chr} $SAMPLE_SIZE $SUM_STATS_FILE
      # bash /home/liulang/liulang/PRS/scripts/general_PRScs.sh ${bfile_prefix} ${out} ${name} ${chr} $SAMPLE_SIZE $SUM_STATS_FILE
      # sleep 3h
    else
      echo "skipping chr $chr because it has been calculated"
      ((chr++))
    fi 
  done 
  echo "part 1 done for sbatch submission, please wait and run part 2 later"
  exit 42
else
  module load scipy-stack/2020a python/3.8.10
  python /home/liulang/liulang/PRS/scripts/calculate_avg_and_zscore_PRScs_PLINK2.py ${out}/scores/ ${name} ${out_final}
fi 





# # check if all the score has bee calculated 
# while true; do
#   all_files_present=true
#   for chr in {1..22};do 
#     file=${out}/scores/${name}.chr${chr}.sscore
#     if [ ! -f "$file" ]; then
#       echo "$file not found, waiting for 30 minutes."
#       all_files_present=false
#       sleep 600 # Wait for half an hour
#       break # Exit the for loop to start checking from the first file again
#     fi
#   done

#   # If all files are found, run the next program
#   if $all_files_present; then
#     echo "All files found, running the next program."
#     # sum up scores across chromosomes and convert to zscore
#     module load scipy-stack/2020a python/3.8.10
#     python /home/liulang/liulang/PRS/scripts/calculate_avg_and_zscore_PRScs_PLINK2.py ${out}/scores/ ${name} ${out_final}
#     break # Exit the while loop
#   fi
# done
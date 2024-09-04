# salloc -c 1 --mem=2g -t 3:0:0 --account=def-grouleau


bfile=$1 #bfile is chromosomal plink file prefix, use # to represent chr number (ex, PING_chr#.qc)
out=$2 # for the posterior effect size files
out_final=$3
name=$4
SUM_STATS_FILE=$5 # the sumstat file from plink. it will be processed and the resulting processed sumstat file need have the columns SNP A1 A2 BETA P/SNP A1 A2 BETA SE/SNP A1 A2 OR P/SNP A1 A2 OR SE, and remove SNP with invalud values (empty, NA, inf, special symbols)
core=${6:-1} # default resource, see below, choose 3 for UKB.
option=${7:-1} # default option for running the first part (pst and sscores)
# if 2, thats calculate the final score
OR=${8:-"TRUE"}

# uncomment the following commands when debugging
# echo "listing arguments"
# echo "bfile_prefix for all chromosome ${bfile}"
# echo "output directory to all files ${out}"
# echo "output directory to final files ${out_final}"
# echo "name of the folder/output ${name}"
# echo "SUM_STATS_FILE before processing and CS ${SUM_STATS_FILE}"
# echo "SUM_STATS_FILE_PRScs_outdir directory for processed sumstat ${SUM_STATS_FILE_PRScs_outdir}"
# echo "resource option we are gonna use ${core}"
# echo "option for running either posterior effect size calculation or average final score calculation"
# echo "does the sumstat come with OR? ${OR}"

# this script requires input of base file and target file. {SUM_STATS_FILE}, {bfile}
# PRScs is computed by chromosome. 
# finally, PRScs is averaged into zscore

# the script structure
# assigning resouces
##  1 for small chip (WORKED ON ABCD and PING)
##  2 for medium chip (NEVER TESTED)
##  3 for large chip (UKB)

# check input arguments and their validity

# creat directories if the dont exist

# if statement for option
##  option = 1 - calculate posterior effect size and scores for the chrosomosome, making the answer = yes (Idk why i did this, this is redudant and can be optimized)
##  option = 2 - check the presence of each sscore file and average to get the final score, making the answer = no
### it also checks if all sscore files are present. if not, answer = yes

# if answer = yes
# while loop to submit jobs
##  in the while loop, PRScs calculation for each chromosome was submitted in a batch. and it also checks if the sscore file exits. if exits, it will skip
##  it also checks how many jobs are in the slurm scheduler. it sleeps for an hour if it exceeds 999 jobs
## 
# if answer = no
##  calculate final score



if [[ "$core" == 1 ]];then 
resource="-c 1 --mem=20g -t 1:30:0"
elif [[ "$core" == 2 ]]; then 
resource="-c 1 --mem=30g -t 4:0:0"
elif [[ "$core" == 3 ]]; then 
resource="-c 1 --mem=40g -t 7:0:0"
fi


if [[ -z $bfile ]]; then echo "ERROR: bfile (1st arg) not specified"; exit 42; fi
if [[ -z $out ]]; then echo "ERROR: out directory (2nd arg) not specified"; exit 42; fi
if [[ -z $name ]]; then echo "ERROR: name for output file(3rd arg) not specified"; exit 42; fi
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
      answer=yes
    fi
  done

  if $all_files_present; then
     echo "All files found, running the next program."
     break
  else
    break 
    #  exit 42
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
      command="bash /home/liulang/liulang/PRS/scripts/general_PRScs.sh ${bfile_prefix} ${out} ${name} ${chr} $SUM_STATS_FILE $OR"
      #echo $command
      jobs=$(squeue -u $USER | tail -n +2 | wc -l) # count the number of jobs
      if [[ $jobs < 999 ]];then 
        # rrg-adagher
        sbatch $resource --wrap "$command" --account=def-grouleau --out ${out}/out/${name}_chr${chr}.out --job-name=${name}_chr${chr};
        ((chr++))
      else
          echo "we've reached the job submission quota, sleeping for an hour"
          sleep 1h
      fi
      # srun $resource --account=rrg-adagher bash /home/liulang/liulang/PRS/scripts/general_PRScs.sh ${bfile_prefix} ${out} ${name} ${chr} $SUM_STATS_FILE
      # bash /home/liulang/liulang/PRS/scripts/general_PRScs.sh ${bfile_prefix} ${out} ${name} ${chr} $SUM_STATS_FILE
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
  echo "calculating final"
  if [ ! -f ${out_final}/${name}_zscored.csv ];then 
    python /home/liulang/liulang/PRS/scripts/calculate_avg_and_zscore_PRScs_PLINK2.py ${out}/scores/ ${name} ${out_final}
  else 
    echo "the file exists"
  fi 
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
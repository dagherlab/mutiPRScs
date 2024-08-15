#!/bin/bash
## how to use
# salloc -c 10 --mem=10g -t 9:0:0 --account=rrg-adagher
# script_dir=/lustre06/project/6006490/liulang/project_PRS/src

# # all of them are completed
# # unstrict
# folder=/home/liulang/scratch/project_MR_topmed/GWAS_NM_abnormal_pos_unstrict/
# out=/home/liulang/scratch/project_PRS/sumstats/GWAS_NM_abnormal_pos_unstrict
# for sumstat in ${folder}/*.new.rsid.glm.logistic;do 
# echo $sumstat
# bash ${script_dir}/process_sumstat.sh $sumstat $out FALSE
# done
# # strict
# folder=/home/liulang/scratch/project_MR_topmed/GWAS_NM_abnormal_pos//
# out=/home/liulang/scratch/project_PRS/sumstats/GWAS_NM_abnormal_pos_strict
# for sumstat in ${folder}/*.new.rsid.glm.logistic;do 
# echo $sumstat
# bash ${script_dir}/process_sumstat.sh $sumstat $out FALSE
# done
# asymmetry
# folder=/home/liulang/scratch/project_MR_topmed/GWAS_NM/all2/
# out=/home/liulang/scratch/project_PRS/sumstats/asymmetry
# for sumstat in ${folder}/*diff*.new.rsid.glm.linear;do 
# echo $sumstat
# bash ${script_dir}/process_sumstat.sh $sumstat $out FALSE
# done


## check scripts
# folder=/home/liulang/scratch/project_MR_topmed/GWAS_NM_abnormal_pos//
# out=/home/liulang/scratch/project_PRS/sumstats/GWAS_NM_abnormal_pos_strict
# for sumstat in ${folder}/*.new.rsid.glm.logistic;do 
# name=$(basename $sumstat)
# if [[ ! -f ${out}/$name.PRScs ]];then 
# echo $sumstat
# fi
# done


# in the meantime, I'd like to get the sample size for each trait
# sample_size=$(sed -n '2p' /home/liulang/scratch/project_MR_topmed/GWAS_NM_abnormal_pos//L_bankssts_surfavg_pos.L_bankssts_surfavg_pos.new.rsid.glm.logistic | cut -f9)


file=$1
out=$2
OR=${3:-"TRUE"}

# assume the input sumstat ends with new.rsid.glm.linear
name=$(basename $file)
# if [[ ! -f ${out}/$name.PRScs ]];then 
    mkdir -p $out
    awk -F'\t' 'BEGIN {OFS="\t"} {print $3, $6, $4, $10, $13}' $file > ${out}/$name.temp1
    if [ "$OR" = "TRUE" ];then
        new_header="SNP\tA1\tA2\tOR\tP"
    else
        new_header="SNP\tA1\tA2\tBETA\tP"
    fi
    # rename columns
    awk -F'\t' -v header="$new_header" 'BEGIN {OFS="\t"} NR==1 {print header; next} {print}' ${out}/$name.temp1 > ${out}/$name.temp2 
    awk -F'\t' '!(($4 == "NA" || $4 == "-inf") || ($5 == "NA" || $5 == " "))' ${out}/$name.temp2 > ${out}/$name.temp3 && mv ${out}/$name.temp3 ${out}/$name.PRScs
# else 
#     # remove missing values
#     awk -F'\t' '!(($4 == "NA" || $4 == "-inf") || ($5 == "NA" || $5 == " "))' ${out}/$name.PRScs > ${out}/$name.temp3 && mv ${out}/$name.temp3 ${out}/$name.PRScs
#     echo "done with ${file} reformatting and the resulting file is now ${out}/$name.PRScs"
    rm ${out}/$name.temp1
    rm ${out}/$name.temp2
# fi


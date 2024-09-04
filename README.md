here is the description of the scripts
the output folder will be like 
 the data structure
 - cohort_name
     - region1
        - effect_size
             - pst_eff...
             - log files
         - scores
             - sscores files
             - log files
         - final_score
             - csv file
         - out
             - out files
         - sumstats
             - temporary sumstat file (they are duplicated)
    - region 2

*make sure you perform some QC on your base and target file*
Base:
1. rsid format in the bim (no alleles)
2. maf, hwe, geno 
3. use # to represent the position of chr number
Target
1. run process_sumstat.sh on it if your file is from plink.
    - it has a header of either SNP A1 A2 BETA SE or SNP A1 A2 BETA P or SNP A1 A2 OR SE or SNP A1 A2 OR P
    - NO missing values and inf and special symbols in BETA/OR and SE/P
core represents how much resource you are requesting, core 1 is the lowest, there are 2 and 3
option = 1 is for weight and chromosomal scores calculation
option = 2 is for final score calculation

**there is no force overlap option here. remove output if you wanna redo everything**
otherwise, they will detect the file and skip the step**
# USAGE

**ABCD**
```bash

script=/lustre06/project/6001220/liulang/PRS/scripts/general_PRScs.all.sh
cohort=ABCD
out2=/home/liulang/scratch/genotype/ABCD/topmed/PRScs
bfile="${out2}/${cohort}_chr#_noalleles.QC"
SUM_STATS_FILE_dir=/home/liulang/scratch/project_MR_topmed/GWAS_NM_abnormal_pos_unstrict/
pheno_file=/lustre06/project/6006490/liulang/project_MR_topmed/GWAS_NM_abnormal/data/pheno_pos_unstrict.txt
OR=FALSE
for name in $(cat $pheno_file);do 
    echo $name;
    out=/home/liulang/scratch/tmp/${cohort}/${name}/
    out_final=/home/liulang/scratch/tmp/${cohort}/${name}/final_score
    SUM_STATS_FILE=${SUM_STATS_FILE_dir}/${name}.${name}.new.rsid.glm.logistic
    core=1
    option=1
    bash $script $bfile $out $out_final $name $SUM_STATS_FILE $core $option $OR
done



# generate final scores
salloc -c 1 --mem=2g -t 3:0:0 --account=def-grouleau
script=/lustre06/project/6001220/liulang/PRS/scripts/general_PRScs.all.sh
cohort=ABCD
out2=/home/liulang/scratch/genotype/ABCD/topmed/PRScs
bfile="${out2}/${cohort}_chr#_noalleles.QC"
SUM_STATS_FILE_dir=/home/liulang/scratch/project_MR_topmed/GWAS_NM_abnormal_pos_unstrict/
pheno_file=/lustre06/project/6006490/liulang/project_MR_topmed/GWAS_NM_abnormal/data/pheno_pos_unstrict.txt
for name in $(cat /lustre06/project/6006490/liulang/project_MR_topmed/GWAS_NM_abnormal/data/pheno_pos_unstrict.txt);do 
    echo $name;
        out=/home/liulang/scratch/tmp/${cohort}/${name}/
        out_final=/home/liulang/scratch/tmp/${cohort}/${name}/final_score
        SUM_STATS_FILE=${SUM_STATS_FILE_dir}/${name}.${name}.new.rsid.glm.logistic
        core=1
        option=2
        bash $script $bfile $out $out_final $name $SUM_STATS_FILE $core $option $OR
done



# collect all final scores
cohort=ABCD
out=../results/${cohort}/
mkdir -p $out
for region in /home/liulang/scratch/tmp/${cohort}/*;do 
    if [ -d $region ];then 
        name=$(basename $region)
        echo "$name"
        file=${region}/final_score/${name}_zscored.csv
        if [ ! -f $file ];then 
            echo "the file doesnt exist"
            continue
        fi 
        cp $file ${out}
    fi
done

```
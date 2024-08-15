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

script=/lustre06/project/6001220/liulang/PRS/scripts/general_PRScs.all.sh
# ABCD
cohort=ABCD
out2=/home/liulang/scratch/genotype/ABCD/topmed/PRScs
bfile="${out2}/${cohort}_chr#_noalleles.QC"
name=accumb_diff
out=/home/liulang/scratch/tmp/${cohort}/${name}/
out_final=/home/liulang/scratch/tmp/${cohort}/${name}/final_score
SAMPLE_SIZE=4523 
SUM_STATS_FILE=/home/liulang/scratch/project_PRS/sumstats/asymmetry/accumb_diff.accumb_diff.new.rsid.glm.linear.PRScs
core=1
option=1

bash $script $bfile $out $out_final $name $SAMPLE_SIZE $SUM_STATS_FILE $core $option

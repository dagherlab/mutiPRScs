bfile_prefix=$1
out=$2
name=$3
chr=$4


module load nixpkgs/16.09 StdEnv/2020 plink/2.00-10252019-avx2
plink2 \
--bfile ${bfile_prefix} \
--memory 800000 \
--threads 15 \
--score ${out}/effect_size/${name}_pst_eff_a1_b0.5_phiauto_chr${chr}.txt 2 4 6 ignore-dup-ids \
--out ${out}/scores/${name}.chr${chr}
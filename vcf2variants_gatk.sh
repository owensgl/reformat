
GATK=/home/owens/bin/GenomeAnalysisTK.jar
ref=/home/owens/ref/HanXRQr1.0-20151230.fa

java -jar $GATK \
-R $ref \
-T SelectVariants \
-V $1 \
-o tmp.vcf \
-selectType SNP \
-log selectvariants.log 
#-select "AC > 1"

java -jar $GATK \
-R $ref \
-T VariantsToTable \
-V tmp.vcf \
-F CHROM \
-F POS \
-GF GT \
-log variantstotable.log \
-o tmp.tab
cat tmp.tab |sed 's/.GT	/	/g' | sed 's|/||g' | sed 's/\.\./NN/g' |\
grep -v '*' 
#rm tmp.vcf
#rm tmp.tab

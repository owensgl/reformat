#This file converts .tab file to .bed


reformat=/home/owens/bin/reformat
tassel=/home/owens/bin/tassel3-standalone
plink=/home/owens/bin/plink-1.07-x86_64
input=$1
name=${input%%.tab}
echo "Converting ${name}.tab to ${name}.plk.bed"
cat ${name}.tab | perl $reformat/SNPtable2hmp.pl > ${name}.hmp

$tassel/run_pipeline.pl -fork1 -h ${name}.hmp -export $name -exportType Plink -runfork1

$plink/plink --file ${name}.plk --out ${name}.plk --make-bed --noweb

rm ${name}.hmp
rm ${name}.plk.map
rm ${name}.plk.ped

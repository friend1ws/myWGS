#! /bin/sh
#$ -S /bin/sh
#$ -cwd


INPUTDIR=$1
OUTPUTDIR=$2

source ../lib/config.sh
source ${UTILPATH}
PATH=${JAVAPATH}:${PATH}
PATH=${SAMTOOLS_PATH}:${PATH}
RECORDS_IN_RAM=5000000

check_mkdir ${OUTPUTDIR}/unmap_tmp

for file in `ls ${INPUTDIR}/*.bam.??? | sort`;
do
    bfile=`basename $file`
    samtools view -h -b -f 12 ${file} > ${OUTPUTDIR}/unmap_tmp/${bfile}
done
 
ARR_BAMS=()
for file in `ls ${OUTPUTDIR}/unmap_tmp/*.bam.??? | sort`; 
do 
    ARR_BAMS+=(${file}) 
done
BAMSET=`echo ${ARR_BAMS[@]}`


echo "samtools merge ${OUTPUTDIR}/unmap.bam ${BAMSET}"
samtools merge ${OUTPUTDIR}/unmap.bam ${BAMSET}

rm -rf ${OUTPUTDIR}/unmap_tmp

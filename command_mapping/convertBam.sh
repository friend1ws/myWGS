#! /bin/sh
#$ -S /bin/sh
#$ -cwd

:<<_COMMENT_OUT_

Author: Yuichi Shiraishi (friend1ws@gmail.com)
Last revised: 10/27/ 2014

INPUT VARIABLE
1. INPUT1: the read1 fastq file (uncompressed)
2. INPUT2: the read2 fastq file (uncompressed)
3. OUTPUT3: the path for the final sorted bam file

_COMMENT_OUT_

 
INPUT1=$1
INPUT2=$2
OUTPUT=$3

source ../lib/config.sh
source ${UTILPATH}

PATH=${SAMTOOLS_PATH}:${PATH}
PATH=${BWA_PATH}:${PATH}

SUFFIX=`sh getSuffix.sh ${SGE_TASK_ID}`

echo "bwa mem ${BWA_REF} ${INPUT1}.${SUFFIX} ${INPUT2}.${SUFFIX} | samtools view -bS - > ${OUTPUT}.unsorted.${SUFFIX}"
bwa mem ${BWA_REF} ${INPUT1}.${SUFFIX} ${INPUT2}.${SUFFIX} | samtools view -bS - > ${OUTPUT}.unsorted.${SUFFIX}
check_error $?

echo "samtools sort -o ${OUTPUT}.unsorted.${SUFFIX} ${OUTPUT}.sorttemp.${SUFFIX} > ${OUTPUT}.${SUFFIX}"
samtools sort -o ${OUTPUT}.unsorted.${SUFFIX} ${OUTPUT}.sorttemp.${SUFFIX} > ${OUTPUT}.${SUFFIX} 
check_error $?

echo "samtools index ${OUTPUT}.${SUFFIX}"
samtools index ${OUTPUT}.${SUFFIX}
check_error $?

rm -rf ${OUTPUT}.unsorted.${SUFFIX}


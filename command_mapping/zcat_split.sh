#! /bin/sh
#$ -S /bin/sh
#$ -cwd

INPUTLIST=$1
OUTPUT=$2
LINES=$3
SUFFIX=$4

ARR_SEQS=()
while read sample; do ARR_SEQS+=(${sample}); done < ${INPUTLIST}
SEQSET=`echo ${ARR_SEQS[@]}`

zcat ${SEQSET} | split -l ${LINES} -a ${SUFFIX} - ${OUTPUT}


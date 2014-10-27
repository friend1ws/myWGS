#!/bin/sh
#$ -S /bin/sh
#$ -cwd

:<<_COMMENT_OUT_

Author: Yuichi Shiraishi (friend1ws@gmail.com)
Last revised: 10/27/ 2014

PURPOSE: 
Given a set of fastq files, convert fastq files to bam files (mainly for whole genome sequencing data).
The final bam files are divided by the chromosomal regions.
Two stage parallelization where:
1. perform bwa-mem alighnment and sorting for each split fastq files.
2. reorganize each split sorted bam files to those divided by chromosomal regions, and perform PCR duplicate removal.
is helpful for fast computation.
Also, unmapped short reads are gathered to one bam file. 
 


INPUT VARIABLES:
1.INPUTLIST1: a list of the paths for read 1 compressed (.gz) fastq files
2.INPUTLIST2: a list of the paths for read 2 compressed (.gz) fastq files
3.OUPUTDIR: the path where bam files are stored.
4.SAMPLE: add for identifying the job names

_COMMENT_OUT_


INPUTLIST1=$1
INPUTLIST2=$2
OUTPUTDIR=$3
SAMPLE=$4

source ../lib/config.sh
source ../lib/utility.sh

# a variable determining the number of sequence reads for each split files
# this is fastq format based variable. so the actual number of reads is 1 / 4 of this variable.
SPLITFACTOR=40000000

##########

if [ ! -f ${INPUTLIST1} ]
then
    echo "${INPUTLIST1} does not exits."
    exit 
fi

if [ ! -f ${INPUTLIST2} ]
then
    echo "${INPUTLIST2} does not exits."
    exit
fi  

check_mkdir ${OUTPUTDIR}/split_fastq 
check_mkdir ${OUTPUTDIR}/split_bam
check_mkdir ${LOGDIR}/${SAMPLE} 


LOGSTR=-e\ ${LOGDIR}/${SAMPLE}\ -o\ ${LOGDIR}/${SAMPLE}


job_split1=split.${SAMPLE}.1
job_split2=split.${SAMPLE}.2
job_master_bwamem=master_bwamem.${SAMPLE}




echo "qsub -N ${job_split1} zcat_split.sh ${INPUTLIST1} ${OUTPUTDIR}/split_fastq/sequence1.txt. ${SPLITFACTOR} 3"
qsub -N ${job_split1} ${LOGSTR} zcat_split.sh ${INPUTLIST1} ${OUTPUTDIR}/split_fastq/sequence1.txt. ${SPLITFACTOR} 3

echo "qsub -N ${job_split2} zcat_split.sh ${INPUTLIST2} ${OUTPUTDIR}/split_fastq/sequence2.txt. ${SPLITFACTOR} 3"
qsub -N ${job_split2} ${LOGSTR} zcat_split.sh ${INPUTLIST2} ${OUTPUTDIR}/split_fastq/sequence2.txt. ${SPLITFACTOR} 3


echo "qsub -N ${job_master_bwamem} -hold_jid ${job_split1},${job_split2} ${LOGSTR} bwa_and_merge.sh ${OUTPUTDIR} ${SAMPLE}"
qsub -N ${job_master_bwamem} -hold_jid ${job_split1},${job_split2} ${LOGSTR} bwa_and_merge.sh ${OUTPUTDIR} ${SAMPLE} 


 


#!/bin/sh
#$ -S /bin/sh
#$ -cwd

:<<_COMMENT_OUT_

Author: Yuichi Shiraishi (friend1ws@gmail.com)
Last revised: 10/27/ 2014

INPUT VARIABLES:
1.OUPUTDIR: the path of the folder where all the final bam files are stored.
2.SAMPLE: add for identifying the job names

_COMMENT_OUT_


OUTPUTDIR=$1
SAMPLE=$2

source ../lib/config.sh
source ../lib/utility.sh
     
LOGSTR=-e\ ${LOGDIR}/${SAMPLE}\ -o\ ${LOGDIR}/${SAMPLE}

##############################


FILECOUNT=`find ${OUTPUTDIR}/split_fastq/sequence1.txt.* | wc -l`

job_bwamem=run_bwamem.${SAMPLE}

echo "qsub -t 1-${FILECOUNT}:1 -l s_vmem=6G,mem_req=6 -N ${job_bwamem} ${LOGSTR} convertBam.sh ${OUTPUTDIR}/split_fastq/sequence1.txt ${OUTPUTDIR}/split_fastq/sequence2.txt ${OUTPUTDIR}/split_bam/sequence.bam"
qsub -t 1-${FILECOUNT}:1 -l s_vmem=6G,mem_req=6 -N ${job_bwamem} ${LOGSTR} convertBam.sh ${OUTPUTDIR}/split_fastq/sequence1.txt ${OUTPUTDIR}/split_fastq/sequence2.txt ${OUTPUTDIR}/split_bam/sequence.bam


##############################


INTERVALOUNT=`find ${INTERVAL}/*.interval_list | wc -l`

job_merge=run_merge.${SAMPLE}

echo "qsub -t 1-${INTERVALOUNT}:1 -l s_vmem=8G,mem_req=8 -N ${job_merge} -hold_jid ${job_bwamem} ${LOGSTR} mergeBam.sh ${OUTPUTDIR}/split_bam ${OUTPUTDIR}"
qsub -t 1-${INTERVALOUNT}:1 -l s_vmem=8G,mem_req=8 -N ${job_merge} -hold_jid ${job_bwamem} ${LOGSTR} mergeBam.sh ${OUTPUTDIR}/split_bam ${OUTPUTDIR}


##############################

job_merge_unmap=run_merge_unmap.${SAMPLE}

echo "qsub -l s_vmem=2G,mem_req=2 -N ${job_merge_unmap} -hold_jid ${job_bwamem} ${LOGSTR} mergeBam_unmap.sh ${OUTPUTDIR}/split_bam ${OUTPUTDIR}"
qsub -l s_vmem=2G,mem_req=2 -N ${job_merge_unmap} -hold_jid ${job_bwamem} ${LOGSTR} mergeBam_unmap.sh ${OUTPUTDIR}/split_bam ${OUTPUTDIR}


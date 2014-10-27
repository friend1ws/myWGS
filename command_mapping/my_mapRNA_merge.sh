#!/bin/sh
#$ -S /bin/sh
#$ -cwd

OUTPUTDIR=$1

source ../lib/config.sh
source ../lib/utility.sh
     
LOGSTR=-e\ ${LOGDIR}/${SAMPLE}\ -o\ ${LOGDIR}/${SAMPLE}

##############################

INTERVALOUNT=`find ${INTERVAL}/*.interval_list | wc -l`

job_merge=run_merge.${SAMPLE}

echo "qsub -t 1-${INTERVALOUNT}:1 -l s_vmem=8G,mem_req=8 -N ${job_merge} ${LOGSTR} mergeBam.sh ${OUTPUTDIR}/split_bam ${OUTPUTDIR}"
qsub -t 1-${INTERVALOUNT}:1 -l s_vmem=8G,mem_req=8 -N ${job_merge} ${LOGSTR} mergeBam.sh ${OUTPUTDIR}/split_bam ${OUTPUTDIR}


##############################

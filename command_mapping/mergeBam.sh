#! /bin/sh
#$ -S /bin/sh
#$ -cwd


INPUTDIR=$1
OUTPUTDIR=$2
NUM=${SGE_TASK_ID}
# NUM=3

source ../lib/config.sh
source ${UTILPATH}
PATH=${JAVAPATH}:${PATH}
PATH=${SAMTOOLS_PATH}:${PATH}
RECORDS_IN_RAM=5000000

ARR_BAMS=()
for file in `ls ${INPUTDIR}/*.bam.??? | sort`; do ARR_BAMS+=(${file}); done
BAMSET=`echo ${ARR_BAMS[@]}`

REGION_A=`head -n1 ${INTERVAL}/${NUM}.interval_list | awk '{split($0, ARRAY, "-"); print ARRAY[1]}'`
REGION_B=`tail -n1 ${INTERVAL}/${NUM}.interval_list | awk '{split($0, ARRAY, "-"); print ARRAY[2]}'`
REGION="${REGION_A}-${REGION_B}"

echo "samtools merge -R ${REGION} ${OUTPUTDIR}/${REGION}.bam.tmp ${BAMSET}"
samtools merge -R ${REGION} ${OUTPUTDIR}/${REGION}.bam.tmp ${BAMSET}

echo "java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/SortSam.jar INPUT=${OUTPUTDIR}/${REGION}.bam.tmp OUTPUT=${OUTPUTDIR}/${REGION}.bam.sorted SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}"
java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/SortSam.jar INPUT=${OUTPUTDIR}/${REGION}.bam.tmp OUTPUT=${OUTPUTDIR}/${REGION}.bam.sorted SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/MarkDuplicates.jar INPUT=${OUTPUTDIR}/${REGION}.bam.sorted OUTPUT=${OUTPUTDIR}/${REGION}.bam METRICS_FILE=${OUTPUTDIR}/${REGION}.rmdup.metric VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}"
java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/MarkDuplicates.jar INPUT=${OUTPUTDIR}/${REGION}.bam.sorted OUTPUT=${OUTPUTDIR}/${REGION}.bam METRICS_FILE=${OUTPUTDIR}/${REGION}.rmdup.metric VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "samtools index ${OUTPUTDIR}/${REGION}.bam"
samtools index ${OUTPUTDIR}/${REGION}.bam

rm -rf ${OUTPUTDIR}/${REGION}.bam.tmp
rm -rf ${OUTPUTDIR}/${REGION}.bam.sorted

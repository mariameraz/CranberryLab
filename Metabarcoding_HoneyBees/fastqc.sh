#PBS -N its2_QC
#PBS -q default
#PBS -l nodes=1:ppn=1,walltime=99999:999:00,mem=36gb,vmem=36gb
#PBS -V

cd $PBS_O_WORKDIR

module load FastQC/0.11.2 MultiQC/1.0

for i in *R1_001.fastq.gz
do
SAMPLE=$(echo $i | sed 's/'R1_001\\.fastq\\.gz'//g')
fastqc ${SAMPLE}R1_001.fastq.gz ${SAMPLE}R1_002.fastq.gz -o ./Fastqc_reports
done

multiqc ./Fastqc_reports



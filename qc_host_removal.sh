#!/bin/bash
set -e

INPUT_DIR=$1
OUTPUT_DIR=$2
SAMPLE=$3
THREADS=$4

echo "--- Step 1: Quality Control & Host Removal ---"

# 작업 디렉토리 생성
QC_DIR="$OUTPUT_DIR/01_qc"
mkdir -p "$QC_DIR"
mkdir -p "$QC_DIR/raw_fastqc"           # FastQC 출력 디렉토리
mkdir -p "$QC_DIR/kneaddata"            # KneadData 출력 디렉토리  
mkdir -p "$QC_DIR/multiqc_report"       # MultiQC 출력 디렉토리

# 입력 파일 확인
R1="$INPUT_DIR/${SAMPLE}_R1.fastq.gz"
R2="$INPUT_DIR/${SAMPLE}_R2.fastq.gz"

if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
    echo "ERROR: 입력 파일을 찾을 수 없습니다: $R1, $R2"
    exit 1
fi

echo "입력 파일: $R1, $R2"

# 1.1 원시 데이터 품질 확인
echo "1.1 원시 데이터 품질 확인 (FastQC)"
conda run -n kneaddata fastqc \
    "$R1" "$R2" \
    -o "$QC_DIR/raw_fastqc" \
    -t "$THREADS"

# 1.2 fastp로 품질 필터링
echo "1.2 fastp 품질 필터링"
conda run -n kneaddata fastp \
    -i "$R1" -I "$R2" \
    -o "$QC_DIR/${SAMPLE}_fastp_R1.fastq.gz" \
    -O "$QC_DIR/${SAMPLE}_fastp_R2.fastq.gz" \
    -h "$QC_DIR/${SAMPLE}_fastp_report.html" \
    -j "$QC_DIR/${SAMPLE}_fastp_report.json" \
    --thread "$THREADS" \
    --qualified_quality_phred 20 \
    --length_required 50 \
    --cut_tail \
    --cut_tail_window_size 4 \
    --cut_tail_mean_quality 20

# 1.3 KneadData로 숙주 DNA 제거
export _JAVA_OPTIONS="-Xmx24g"

echo "1.3 KneadData 숙주 DNA 제거"
conda run -n kneaddata kneaddata \
    --input1 "$QC_DIR/${SAMPLE}_fastp_R1.fastq.gz" \
    --input2 "$QC_DIR/${SAMPLE}_fastp_R2.fastq.gz" \
    --reference-db "$db/kneaddata/human" \
    --output "$QC_DIR/kneaddata" \
    --threads "$THREADS" \
    --processes 4 \
    --quality-scores phred33 \
    --run-fastqc-start \
    --run-fastqc-end \
    --store-temp-output


# 1.4 정제된 리드 이름 변경 (편의성을 위해)
echo "1.4 정제된 리드 파일 정리"
cp "$QC_DIR/kneaddata/${SAMPLE}_fastp_R1_kneaddata_paired_1.fastq" "$QC_DIR/${SAMPLE}_clean_R1.fastq"
cp "$QC_DIR/kneaddata/${SAMPLE}_fastp_R1_kneaddata_paired_2.fastq" "$QC_DIR/${SAMPLE}_clean_R2.fastq"

# 압축
gzip "$QC_DIR/${SAMPLE}_clean_R1.fastq"
gzip "$QC_DIR/${SAMPLE}_clean_R2.fastq"

# 1.5 품질 관리 리포트 생성
echo "1.5 MultiQC 통합 리포트 생성"
conda run -n kneaddata multiqc "$QC_DIR" -o "$QC_DIR/multiqc_report"

echo "Step 1 완료: 정제된 리드는 $QC_DIR/${SAMPLE}_clean_R*.fastq.gz"
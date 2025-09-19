#!/bin/bash
set -e

# =================================================================
# EasyMetagenome Assembly-based Pipeline Runner
# =================================================================

# 사용법 확인
if [ $# -lt 4 ]; then
    echo "사용법: $0 <input_dir> <output_dir> <sample_prefix> <threads>"
    echo "예시: $0 /path/to/fastq /path/to/output sample1 16"
    echo ""
    echo "입력 디렉토리에는 다음 파일들이 있어야 합니다:"
    echo "  - {sample_prefix}_R1.fastq.gz"
    echo "  - {sample_prefix}_R2.fastq.gz"
    exit 1
fi

# 매개변수 설정
INPUT_DIR=$1
OUTPUT_DIR=$2
SAMPLE=$3
THREADS=$4

# 환경 변수 로드
source ~/.bashrc

echo "=== EasyMetagenome Assembly Pipeline 시작 ==="
echo "입력 디렉토리: $INPUT_DIR"
echo "출력 디렉토리: $OUTPUT_DIR"
echo "샘플명: $SAMPLE"
echo "스레드 수: $THREADS"

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# 로그 파일 설정
LOG_FILE="$OUTPUT_DIR/pipeline_${SAMPLE}.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

echo "$(date): Pipeline 시작" >> "$LOG_FILE"

# 단계별 실행
echo "=== 1단계: Quality Control & Host Removal ==="
bash "$(dirname "$0")/step1_qc_host_removal.sh" "$INPUT_DIR" "$OUTPUT_DIR" "$SAMPLE" "$THREADS"

echo "=== 2단계: Metagenomic Assembly ==="
bash "$(dirname "$0")/step2_assembly.sh" "$OUTPUT_DIR" "$SAMPLE" "$THREADS"

echo "=== 3단계: Assembly Quality Assessment ==="
bash "$(dirname "$0")/step3_assembly_qc.sh" "$OUTPUT_DIR" "$SAMPLE" "$THREADS"

echo "=== 4단계: Gene Prediction & Annotation ==="
bash "$(dirname "$0")/step4_gene_annotation.sh" "$OUTPUT_DIR" "$SAMPLE" "$THREADS"

echo "=== 5단계: Taxonomic Classification ==="
bash "$(dirname "$0")/step5_taxonomy.sh" "$OUTPUT_DIR" "$SAMPLE" "$THREADS"

echo "=== 6단계: Genome Binning ==="
bash "$(dirname "$0")/step6_binning.sh" "$OUTPUT_DIR" "$SAMPLE" "$THREADS"

echo "=== 7단계: Results Summary ==="
bash "$(dirname "$0")/step7_summary.sh" "$OUTPUT_DIR" "$SAMPLE"

echo "$(date): Pipeline 완료" >> "$LOG_FILE"
echo "=== EasyMetagenome Pipeline 완료 ==="
echo "결과는 $OUTPUT_DIR 에서 확인하세요."
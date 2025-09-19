#!/bin/bash
# batch_qc_processing.sh - MANIFEST 기반 배치 처리

set -e

if [ $# -ne 3 ]; then
    echo "사용법: $0 <manifest_file> <output_base_dir> <threads>"
    echo "예시: $0 sample_manifest.txt /home/user/results 16"
    exit 1
fi

MANIFEST_FILE=$1
OUTPUT_BASE_DIR=$2
THREADS=$3

if [ ! -f "$MANIFEST_FILE" ]; then
    echo "ERROR: MANIFEST 파일을 찾을 수 없습니다: $MANIFEST_FILE"
    exit 1
fi

echo "=== 배치 QC 처리 시작 ==="
echo "MANIFEST 파일: $MANIFEST_FILE"
echo "출력 기본 디렉토리: $OUTPUT_BASE_DIR"
echo "스레드 수: $THREADS"

# 헤더 건너뛰고 각 샘플 처리
tail -n +2 "$MANIFEST_FILE" | while IFS=$'\t' read -r sample_id r1_path r2_path; do
    echo ""
    echo "=== 처리 중: $sample_id ==="
    echo "R1: $r1_path"
    echo "R2: $r2_path"
    
    # 파일 존재 확인
    if [ ! -f "$r1_path" ] || [ ! -f "$r2_path" ]; then
        echo "ERROR: 파일을 찾을 수 없습니다. 건너뜁니다."
        continue
    fi
    
    # 입력 디렉토리 추출
    input_dir=$(dirname "$r1_path")
    
    # 샘플별 출력 디렉토리
    sample_output_dir="$OUTPUT_BASE_DIR/${sample_id}"
    
    # QC 처리 실행
    echo "QC 처리 시작: $sample_id"
    
    # 기존 qc_host_removal.sh 스크립트 호출
    # 단, 파일명 패턴을 맞춰주기 위해 심볼릭 링크 생성
    temp_dir=$(mktemp -d)
    ln -s "$r1_path" "$temp_dir/${sample_id}_R1.fastq.gz"
    ln -s "$r2_path" "$temp_dir/${sample_id}_R2.fastq.gz"
    
    # QC 스크립트 실행
    if ./qc_host_removal.sh "$temp_dir" "$sample_output_dir" "$sample_id" "$THREADS"; then
        echo "완료: $sample_id"
    else
        echo "ERROR: $sample_id 처리 실패"
    fi
    
    # 임시 디렉토리 정리
    rm -rf "$temp_dir"
    
done

echo ""
echo "=== 모든 샘플 처리 완료 ==="
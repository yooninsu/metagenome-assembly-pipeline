#!/bin/bash
set -e

echo "=== Kraken2 설치 시작 ==="

# 환경 변수 로드
source ~/.bashrc

# Kraken2 환경 생성
n=kraken2.1.3
if ! conda env list | grep -q "${n}"; then
    echo "Kraken2 환경 생성 중..."
    mamba create -n "${n}" -y -c bioconda kraken2=2.1.3 python=3.9
    
    echo "추가 패키지 설치 중..."
    conda run -n "${n}" mamba install bracken krakentools krona r-optparse -y
    
    echo "Kraken2 버전 확인..."
    conda run -n "${n}" kraken2 --version
else
    echo "Kraken2 환경이 이미 존재합니다."
fi

# Kraken2 데이터베이스 설치
echo "Kraken2 데이터베이스 설치 시작..."
v=k2_pluspf_16gb_20240904
db_path="${db}/kraken2/pluspf16g"

read -p "Kraken2 데이터베이스를 다운로드하시겠습니까? (16GB) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -f "${db_path}/hash.k2d" ]; then
        echo "Kraken2 데이터베이스 다운로드 중... (16GB)"
        mkdir -p "${db_path}"
        cd "${db}"
        wget -c "https://genome-idx.s3.amazonaws.com/kraken/${v}.tar.gz"
        tar xvzf "${v}.tar.gz" -C "kraken2/pluspf16g"
        echo "Kraken2 데이터베이스 설치 완료"
    else
        echo "Kraken2 데이터베이스가 이미 설치되어 있습니다."
    fi
else
    echo "데이터베이스 다운로드를 건너뜁니다."
fi

echo "=== Kraken2 설치 완료 ==="
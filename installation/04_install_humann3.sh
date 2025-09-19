#!/bin/bash
set -e

echo "=== HUMAnN3 설치 시작 ==="

# 환경 변수 로드
source ~/.bashrc

# HUMAnN3 환경 생성 및 설치
if ! conda env list | grep -q "humann3"; then
    echo "HUMAnN3 환경 생성 중..."
    conda create -n humann3 -y
    
    echo "HUMAnN3 패키지 설치 중..."
    conda run -n humann3 conda install metaphlan=4.1.1 humann=3.7 -c bioconda -c conda-forge -y
    
    echo "HUMAnN3 설치 테스트..."
    conda run -n humann3 humann_test
    
    echo "버전 확인..."
    conda run -n humann3 humann --version
    conda run -n humann3 metaphlan -v
else
    echo "HUMAnN3 환경이 이미 존재합니다."
fi

# HUMAnN3 데이터베이스 설치
echo "HUMAnN3 데이터베이스 설치 시작..."
mkdir -p "${db}/humann3"

# 데이터베이스 다운로드 (대용량 - 선택적 설치)
read -p "HUMAnN3 데이터베이스를 다운로드하시겠습니까? (총 ~40GB) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # ChocoPhlAn 데이터베이스 (16GB)
    if [ ! -d "${db}/humann3/chocophlan" ]; then
        echo "ChocoPhlAn 데이터베이스 다운로드 중... (16GB)"
        conda run -n humann3 humann_databases --download chocophlan full "${db}/humann3"
    fi
    
    # UniRef90 데이터베이스 (20GB) 
    if [ ! -d "${db}/humann3/uniref" ]; then
        echo "UniRef90 데이터베이스 다운로드 중... (20GB)"
        conda run -n humann3 humann_databases --download uniref uniref90_diamond "${db}/humann3"
    fi
    
    # Utility mapping 데이터베이스 (2.6GB)
    if [ ! -d "${db}/humann3/utility_mapping" ]; then
        echo "Utility mapping 데이터베이스 다운로드 중... (2.6GB)"
        conda run -n humann3 humann_databases --download utility_mapping full "${db}/humann3"
    fi
    
    # 데이터베이스 경로 설정
    echo "데이터베이스 경로 설정 중..."
    conda run -n humann3 humann_config --update database_folders nucleotide "${db}/humann3/chocophlan"
    conda run -n humann3 humann_config --update database_folders protein "${db}/humann3/uniref"
    conda run -n humann3 humann_config --update database_folders utility_mapping "${db}/humann3/utility_mapping"
    
    echo "데이터베이스 설정 확인..."
    conda run -n humann3 humann_config --print
else
    echo "데이터베이스 다운로드를 건너뜁니다."
fi

echo "=== HUMAnN3 설치 완료 ==="
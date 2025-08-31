#!/bin/bash
set -e

echo "=== 조립 도구 설치 시작 ==="

# 환경 변수 로드
source ~/.bashrc

# MEGAHIT 환경 생성 및 조립 도구 설치
if ! conda env list | grep -q "megahit"; then
    echo "MEGAHIT 환경 생성 중..."
    mamba create -y -n megahit megahit spades quast cd-hit emboss salmon prodigal
    
    echo "조립 도구 설치 확인..."
    conda run -n megahit megahit -v
    conda run -n megahit metaspades.py -v
    conda run -n megahit metaquast.py -v
    conda run -n megahit salmon -v
else
    echo "MEGAHIT 환경이 이미 존재합니다."
fi

# eggNOG 환경 생성 및 설치
if ! conda env list | grep -q "eggnog"; then
    echo "eggNOG 환경 생성 중..."
    mamba create -n eggnog -y
    conda run -n eggnog mamba install eggnog-mapper -y -c bioconda -c conda-forge
    
    echo "eggNOG 설치 확인..."
    conda run -n eggnog emapper.py --version
else
    echo "eggNOG 환경이 이미 존재합니다."
fi

# eggNOG 데이터베이스 설치
read -p "eggNOG 데이터베이스를 다운로드하시겠습니까? (해압 후 ~48GB) [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -f "${db}/eggnog/eggnog.db" ]; then
        echo "eggNOG 데이터베이스 다운로드 중..."
        mkdir -p "${db}/eggnog" && cd "${db}/eggnog"
        conda run -n eggnog download_eggnog_data.py -y -f --data_dir "${db}/eggnog"
        echo "eggNOG 데이터베이스 설치 완료"
    else
        echo "eggNOG 데이터베이스가 이미 설치되어 있습니다."
    fi
else
    echo "eggNOG 데이터베이스 다운로드를 건너뜁니다."
fi

echo "=== 조립 도구 설치 완료 ==="
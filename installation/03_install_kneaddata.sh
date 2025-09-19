#!/bin/bash
set -e

echo "=== KneadData 설치 시작 ==="

# 환경 변수 로드
source ~/.bashrc

# KneadData 환경 생성 및 설치
if ! conda env list | grep -q "kneaddata"; then
    echo "KneadData 환경 생성 중..."
    conda create -y -n kneaddata
    
    echo "KneadData 패키지 설치 중..."
    conda run -n kneaddata mamba install kneaddata fastqc multiqc fastp r-reshape2 -y
    
    echo "KneadData 설치 확인..."
    conda run -n kneaddata fastqc -v
    conda run -n kneaddata kneaddata --version
    conda run -n kneaddata multiqc --version
else
    echo "KneadData 환경이 이미 존재합니다."
fi

# 인간 게놈 데이터베이스 다운로드
echo "인간 게놈 데이터베이스 설치 중..."
mkdir -p "${db}/kneaddata/human"

if [ ! -f "${db}/kneaddata/human/Homo_sapiens_hg37_and_human_contamination_Bowtie2_v0.1.1.bt2" ]; then
    cd "${db}/kneaddata/human"
    
    # 백업 링크에서 다운로드 (더 안정적)
    echo "백업 서버에서 인간 게놈 데이터베이스 다운로드 중... (3.44GB)"
    wget -c ftp://download.nmdc.cn/tools/meta/kneaddata/human_genome/Homo_sapiens_hg37_and_human_contamination_Bowtie2_v0.1.tar.gz
    tar xvzf Homo_sapiens_hg37_and_human_contamination_Bowtie2_v0.1.tar.gz
    
    echo "인간 게놈 데이터베이스 설치 완료"
else
    echo "인간 게놈 데이터베이스가 이미 설치되어 있습니다."
fi

echo "=== KneadData 설치 완료 ==="
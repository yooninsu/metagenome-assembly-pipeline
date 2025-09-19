#!/bin/bash
set -e

echo "=== 빈닝 도구 설치 시작 ==="

# 환경 변수 로드
source ~/.bashrc

# MetaWRAP 설치
if ! conda env list | grep -q "metawrap"; then
    echo "MetaWRAP 환경 생성 중..."
    mamba create -y --name metawrap --channel ursky -c conda-forge -c bioconda metawrap-mg=1.3.2
    
    echo "MetaWRAP 설치 확인..."
    conda run -n metawrap metawrap -h
else
    echo "MetaWRAP 환경이 이미 존재합니다."
fi

# CheckM 데이터베이스 설치
if [ ! -f "${db}/checkm/checkm_data_2015_01_16.tar.gz" ]; then
    echo "CheckM 데이터베이스 설치 중..."
    mkdir -p "${db}/checkm" && cd "${db}/checkm"
    wget -c https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
    tar -xvf *.tar.gz
    
    echo "CheckM 데이터베이스 경로 설정 중..."
    conda run -n metawrap checkm data setRoot "${db}/checkm"
else
    echo "CheckM 데이터베이스가 이미 설치되어 있습니다."
fi

# dRep 환경 생성
if ! conda env list | grep -q "drep"; then
    echo "dRep 환경 생성 중..."
    conda create -y -n drep
    
    echo "dRep 패키지 설치 중..."
    conda run -n drep pip install drep==3.5.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
    conda run -n drep conda install -c bioconda numpy matplotlib pysam hmmer prodigal pplacer -y
    conda run -n drep pip3 install checkm-genome -i https://pypi.tuna.tsinghua.edu.cn/simple
    conda run -n drep mamba install -c bioconda mash fastANI -y
    
    echo "dRep 의존성 확인..."
    conda run -n drep dRep check_dependencies
else
    echo "dRep 환경이 이미 존재합니다."
fi

echo "=== 빈닝 도구 설치 완료 ==="
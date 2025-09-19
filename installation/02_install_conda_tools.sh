#!/bin/bash
set -e

echo "=== Conda 기본 도구 설치 시작 ==="

# 환경 변수 확인
if [ -z "$db" ] || [ -z "$soft" ]; then
    echo "환경 변수가 설정되지 않았습니다. 'source ~/.bashrc' 실행 후 다시 시도하세요."
    exit 1
fi

# Mamba 설치 (빠른 패키지 관리자)
if ! command -v mamba &> /dev/null; then
    echo "Mamba 설치 중..."
    conda install mamba -c conda-forge -c bioconda -y
    
    # 채널 추가
    conda config --add channels bioconda
    conda config --add channels conda-forge
    
    echo "Mamba 설치 완료"
else
    echo "Mamba가 이미 설치되어 있습니다."
fi

echo "=== Conda 기본 도구 설치 완료 ==="
#!/bin/bash
set -e  # 에러 시 스크립트 중단

echo "=== EasyMetagenome 기본 환경 설정 시작 ==="

# Windows 경로를 WSL 경로로 변환
# db="/mnt/c/Users/User/OneDrive/DOCUME~1-LAPTOP-0LF8B10V-3815/Desktop/shotgun/GC"
db='/home/user/Desktop/Data_8TB/Macrogen/Shotgun/OC'
soft=~/miniconda3

echo "데이터베이스 경로: ${db}"
echo "소프트웨어 경로: ${soft}"

# 디렉토리 생성
mkdir -p "${db}" && cd "${db}"

# PATH 설정
export PATH="${soft}/bin:${soft}/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${db}/EasyMicrobiome/linux:${db}/EasyMicrobiome/script"

# Miniconda 설치 확인
if [ ! -f ~/miniconda3/bin/conda ]; then
    echo "Miniconda 다운로드 중..."6
    wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    
    echo "Miniconda 설치 중..."
    bash Miniconda3-latest-Linux-x86_64.sh -b -f 
    
    echo "Conda 초기화..."
    ~/miniconda3/condabin/conda init
    
    echo "환경 변수를 ~/.bashrc에 추가..."
    echo "export db=\"${db}\"" >> ~/.bashrc
    echo "export soft=\"${soft}\"" >> ~/.bashrc
    
    echo "터미널을 다시 시작하고 'source ~/.bashrc' 실행 후 다음 스크립트를 실행하세요."
else
    echo "Miniconda가 이미 설치되어 있습니다."
fi

echo "=== 기본 환경 설정 완료 ==="

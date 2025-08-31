# metagenome-assembly-pipeline
A comprehensive, step-by-step installation pipeline for EasyMetagenome metagenomics analysis toolkit on WSL (Windows Subsystem for Linux).
## Overview
This repository provides modular installation scripts for setting up a complete metagenomics analysis environment based on the EasyMetagenome pipeline.
Each script is designed to be run independently, allowing for flexible installation and easy troubleshooting.
## Features
- Modular Installation: 8 separate scripts for different tool categories
- Error Handling: Built-in error checking and recovery mechanisms
- WSL Optimized: Specifically designed for Windows Subsystem for Linux
- Interactive Options: User prompts for large database downloads
- Dependency Management: Automated conda environment management

## Prerequisites

Operating System: Windows 10/11 with WSL2 (Ubuntu 20.04+ recommended)
Storage: Minimum 200GB free space for full installation with databases
Memory: 16GB+ RAM recommended for large database operations
Network: Stable internet connection for downloading databases

# Make scripts executable
chmod +x *.sh

# Run in sequence
./01_setup_base.sh
# Restart terminal and run: source ~/.bashrc
./02_install_conda_tools.sh
./03_install_kneaddata.sh

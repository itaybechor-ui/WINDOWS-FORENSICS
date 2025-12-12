# WINDOWS-FORENSICS 🕵‍♂

![Windows Forensics – Report](example.png)
![Windows Forensics – Carved Files](example1.png)
![Windows Forensics – bulk_extractor Results](example2.png)

![Linux](https://img.shields.io/badge/Linux-Kali-orange?logo=linux&logoColor=white)
![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Status](https://img.shields.io/badge/Project-Windows_Forensics-brightgreen)

> ⚠ *DISCLAIMER:* This project is for educational and security training purposes only.  
> It analyzes Windows memory images (like memdump.mem) inside a controlled lab environment  
> and must *not* be used on systems without explicit authorization.

Automated *Windows Memory Forensics* project written in Bash as part of my Cyber Security studies at *John Bryce College*.  
The main script wfproj.sh analyzes a Windows memory image (memdump.mem) using classic forensics tools and generates a structured report with all findings.

---

## 📚 Table of Contents

- [Overview](#overview)
- [Tools Used](#-tools-used)
- [Evidence](#-evidence)
- [Architecture](#-architecture)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Example Output](#-example-output)
- [Project Structure](#-project-structure)
- [Forensics Coverage](#-forensics-coverage)
- [Future Improvements](#-future-improvements)
- [Hebrew Summary](#-hebrew-summary)
- [Contact](#-contact)

---

## Overview

wfproj.sh is a *one-click Windows memory forensics pipeline*:

- Runs on *Kali Linux*
- Processes a memory image called **memdump.mem**
- Orchestrates several forensics tools automatically
- Saves all raw results into timestamped log folders
- Produces a final summary report (report.txt) for documentation / PDF export

The goal is to simulate a real investigation on captured RAM from a Windows machine and to standardize evidence collection and analysis.

---

## 🛠 Tools Used

This project focuses on classic memory/disk forensics utilities:

- *bulk_extractor* – scans raw memory for:
  - email addresses  
  - URLs, domains  
  - credit-card–like patterns and other artifacts  

- *scalpel* – file carving based on headers/footers, used to recover:
  - images (JPEG/PNG)  
  - documents and other file types from memdump.mem  

- *foremost* – additional file carving engine used to validate / complement scalpel results  

- *binwalk* – scans the memory image for embedded files, compressed data, and signatures inside memdump.mem  

- *exiftool* – extracts metadata from carved files (especially images and documents), such as:
  - timestamps  
  - camera / software information  
  - authors, titles and other EXIF/metadata fields  

All these tools are executed by wfproj.sh and their outputs are written into organized log files.

---

## 💾 Evidence

The main evidence file analyzed in this project:

- **memdump.mem** – Windows memory image used throughout the lab  
  - Collected from a Windows machine in a controlled lab environment  
  - Contains active processes, strings, network traces and artefacts present at capture time  
  - Used as the single input source for all tools in this project

You can replace memdump.mem with your own memory image (same filename or adjust the path in the script).

---

## 🧱 Architecture

High-level flow of wfproj.sh:

1. Initialize environment & directories (data, logs, timestamped run folder).
2. Verify that memdump.mem exists in the expected location.
3. Run analysis steps in sequence:
   - scanning with *bulk_extractor*
   - carving files with *scalpel* and *foremost*
   - scanning embedded data with *binwalk*
   - extracting metadata with *exiftool*
4. Save each tool’s raw output into dedicated log files.
5. Aggregate key findings into data/report.txt.
6. Print a short summary to the terminal with the path to all results.

---

## 🧰 Requirements

- *Kali Linux* (or any modern Linux distribution)
- Bash shell
- Installed tools:
  - bulk_extractor
  - scalpel
  - foremost
  - binwalk
  - exiftool
- A Windows memory image named memdump.mem

On Kali, most of these tools can be installed via apt.

---

## 📥 Installation

```bash
# 1. Clone the repository
git clone https://github.com/itaybechor-ui/WINDOWS-FORENSICS.git

# 2. Enter the project directory
cd WINDOWS-FORENSICS

# 3. Make the main script executable
chmod +x wfproj.sh 

## 📄 Full Project Report (PDF)

You can view the full Windows Forensics project report here:
[Download WFPROJ.pdf](docs/WFPROJ.pdf)

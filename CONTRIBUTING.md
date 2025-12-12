# Contributing to WINDOWS-FORENSICS

First of all – thank you for taking the time to look at this project 🙌  
This repository is part of my Cyber Security studies at *John Bryce College* and focuses on *Windows memory forensics*.

---

## 🧩 Ways to Contribute

- 🐛 *Report issues / bugs* – If you find a problem in the script or documentation, please open an Issue and describe:
  - What you ran
  - What you expected to happen
  - What actually happened (including error messages)

- 💡 *Suggest improvements* – New ideas for features, tools, or better forensics workflows are always welcome.

- 🛠 *Open Pull Requests* – If you want to change the code or docs:
  1. Fork the repository
  2. Create a new branch (for example feature/new-tool)
  3. Commit your changes with clear messages
  4. Open a Pull Request and explain what you changed and why

---

## 🧪 Local Setup

```bash
# Clone the repository
git clone https://github.com/itaybechor-ui/WINDOWS-FORENSICS.git
cd WINDOWS-FORENSICS

# Make main script executable
chmod +x wfproj.sh

# Run the project (on Kali or another Linux)
./wfproj.sh

---

## 🧊 Coding & Documentation Style

- The main script is written in *Bash* – please keep the same style:
  - Clear function names
  - Comments in *English*
  - No hard-coded absolute paths when possible

- Keep log file names and directory structure consistent  
  (for example: logs/<timestamp>/bulk_extractor.log, data/report.txt).

- When updating the documentation:
  - Keep the README structure (Overview, Tools, Usage, etc.)
  - Add examples or screenshots when relevant

---

## 🔐 Legal & Ethical Notice

This project is for *educational and security training purposes only*.  
Any contribution must respect this goal and *must not* promote or enable  
unauthorized access to systems or data.


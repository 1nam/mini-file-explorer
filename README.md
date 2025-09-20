# 🖥️ Mini File Explorer + Dad Mode

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Linux Compatible](https://img.shields.io/badge/Linux-Compatible-brightgreen.svg)](https://www.linux.org/)
[![Built with ChatGPT](https://img.shields.io/badge/Built%20with-ChatGPT-orange.svg)](https://chat.openai.com/)

A fun, interactive terminal-based file explorer for Linux, with built-in dad jokes, ASCII snapshots, and full **Matrix + Dad Mode** chaos. Perfect for exploring files, media, and logs while keeping things hilariously dad-centric.  

**Built with the help of [ChatGPT](https://chat.openai.com/) 🤖**  

---

## Features

- 🎨 **Colorful terminal menus** for easy navigation  
- 🔍 **Interactive file search** by name, type, and directory  
- 📁 **Premade file lists** for quick access  
- 🎵 **Queue & play mp3/mp4 files** via `mplayer`  
- 📝 **Edit text/json/sh files** with your preferred editor (default: `nano`)  
- 🕹️ **Pro features**: export last search results  
- 📜 **Logs**: search logs auto-clean every 6 hours, viewable in-terminal  
- 🤓 **Dad Joke Easter Egg**: view or add cheeky jokes with confetti animation  
- 🖼️ **Snapshot feature**: automatically captures a webcam photo, viewable in ASCII  
- 💻 **Matrix + Dad Mode**: ASCII snapshot + `cmatrix` terminal chaos for 3 minutes  

---

## Requirements

- Linux (tested on Linux Mint)  
- `bash`  
- `fswebcam` → for snapshots  
- `mplayer` → for media playback  
- `jq` → for dad jokes JSON  
- `cmatrix` → for Matrix mode  
- `jp2a` or `catimg` → for ASCII snapshot rendering (optional, fallback prints message)

Install missing packages (Ubuntu/Mint example):

```bash
sudo apt update
sudo apt install fswebcam mplayer jq cmatrix jp2a -y

Clone the repo:

git clone https://github.com/1nam/mini-file-explorer.git
cd mini-file-explorer

Make the script executable:
chmod +x gpt_version.sh

Run it:
./gpt_version.sh

Usage

Use the menu to navigate between premade lists, interactive search, pro features, logs, dad jokes, snapshots, and Matrix + Dad Mode.

Media files can be added to a queue and played sequentially.

Dad jokes can be viewed or added, with fun confetti effects in the terminal.

Snapshots are automatically taken on startup and can be viewed directly as ASCII art in the terminal.

Matrix + Dad Mode runs the ASCII snapshot first, then launches cmatrix. Exit with Ctrl+C.

License

MIT License – free to hack, tweak, and keep your dad entertained.

Notes

Logs are stored in /tmp and auto-delete after 6 hours.

The script is fully terminal-based, no GUI needed.

Designed for dads, chaos enthusiasts, and people who like fun with files.











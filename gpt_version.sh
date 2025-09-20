#!/bin/bash

EDITOR=${EDITOR:-nano}
QUEUE=()

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"

# Script directory & JSON file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAD_JSON="$SCRIPT_DIR/dad_jokes.json"
[[ ! -f "$DAD_JSON" ]] && echo "[]" > "$DAD_JSON"

# Snapshot at startup
PHOTO="$SCRIPT_DIR/last_dad_on_script.jpg"
if command -v fswebcam >/dev/null 2>&1; then
    fswebcam -r 1280x720 --jpeg 85 -D 1 "$PHOTO" >/dev/null 2>&1
    echo -e "${GREEN}📸 Snapshot saved as last_dad_on_script.jpg${RESET}"
else
    echo -e "${YELLOW}fswebcam not installed, skipping snapshot.${RESET}"
fi

# Cleanup old logs in /tmp older than 6 hours
find /tmp -maxdepth 1 -name 'search_log_*.txt' -type f -mmin +360 -delete

# Premade list example
PREMADE_LIST=(
    "$HOME/Music/song1.mp3"
    "$HOME/Music/song2.mp3"
    "$HOME/Videos/video1.mp4"
    "$HOME/Documents/example.txt"
)

# Spinner & Confetti
spinner() { 
    local pid=$!
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${CYAN}${spin:$i:1}${RESET} Processing..."
        sleep 0.1
    done
    printf "\r"
}
confetti() { 
    local DURATION=2
    local END=$((SECONDS + DURATION))
    local CHARS=("*" "o" "+" "•" "x" "@" "#")
    local COLORS=("\e[31m" "\e[32m" "\e[33m" "\e[34m" "\e[35m" "\e[36m")
    tput civis
    while (( SECONDS < END )); do
        for i in $(seq 1 40); do
            CHAR="${CHARS[RANDOM % ${#CHARS[@]}]}"
            COLOR="${COLORS[RANDOM % ${#COLORS[@]}]}"
            printf "%s%s%s" "$COLOR" "$CHAR" "$RESET"
        done
        printf "\r"
        sleep 0.1
    done
    printf "\n"
    tput cnorm
}

# Dynamic dad ads
show_ad() { 
    if (( RANDOM % 4 == 0 )); then
        JOKES=($(jq -r '.[]' "$DAD_JSON"))
        [[ ${#JOKES[@]} -eq 0 ]] && JOKES=("🩳 Yoga Pants on Sale! As Seen on TV!" "🍕 Free Pizza Friday! Just kidding… 😎" "🔧 Tools! Every dad needs one.")
        INDEX=$(( RANDOM % ${#JOKES[@]} ))
        JOKE="${JOKES[$INDEX]}"
        for c in $(seq 1 3); do
            for spin in '-' '\' '|' '/'; do
                printf "\r${MAGENTA}${spin}${RESET} ${YELLOW}${JOKE}${RESET}"
                sleep 0.1
            done
        done
        echo -e "\n"
    fi
}

# Handle a single file
handle_file() { 
    local FILE="$1"
    local EXT="${FILE##*.}"

    while true; do
        echo -e "\n${CYAN}File: $FILE${RESET}"
        echo -e "${BLUE}Size: $(stat -c%s "$FILE") bytes | Modified: $(stat -c%y "$FILE")${RESET}"
        echo -e "${BLUE}Permissions: $(stat -c%A "$FILE")${RESET}"

        echo -e "\nChoose action for this file:"
        echo "   [v] Preview"
        echo "   [e] Edit"
        echo "   [o] Open"
        [[ "$EXT" =~ ^(mp3|mp4)$ ]] && echo "   [q] Add to queue" && echo "   [p] Play now"
        echo "   [s] Skip / next"

        read -p "Choice: " ACTION
        case "$ACTION" in
            v|V)
                if [[ "$EXT" =~ ^(txt|sh)$ ]]; then
                    head -n 20 "$FILE"
                elif [[ "$EXT" == "json" ]]; then
                    command -v jq >/dev/null 2>&1 && jq '.' "$FILE" | head -n 20 || head -n 20 "$FILE"
                else
                    echo -e "${YELLOW}No preview for this type.${RESET}"
                fi
                ;;
            e|E)
                [[ "$EXT" =~ ^(txt|sh|json)$ ]] && $EDITOR "$FILE" || echo -e "${YELLOW}Cannot edit this type.${RESET}"
                ;;
            o|O)
                command -v xdg-open >/dev/null 2>&1 && xdg-open "$FILE" >/dev/null 2>&1 &
                ;;
            q|Q)
                [[ "$EXT" =~ ^(mp3|mp4)$ ]] && QUEUE+=("$FILE") && echo -e "${GREEN}Added to queue.${RESET}"
                ;;
            p|P)
                [[ "$EXT" =~ ^(mp3|mp4)$ ]] && command -v mplayer >/dev/null 2>&1 && mplayer "$FILE"
                ;;
            s|S) break ;;
            *) echo -e "${RED}Invalid choice.${RESET}" ;;
        esac
    done
}

play_queue() { 
    [[ ${#QUEUE[@]} -eq 0 ]] && { echo -e "${YELLOW}Queue is empty.${RESET}"; return; }
    echo -e "\n${YELLOW}▶️ Playing queued media (${#QUEUE[@]} files)...${RESET}"
    for MEDIA in "${QUEUE[@]}"; do
        echo -e "${GREEN}Playing: $MEDIA${RESET}"
        command -v mplayer >/dev/null 2>&1 && mplayer "$MEDIA"
    done
    QUEUE=()
}

interactive_search() { 
    read -p "File name (without extension): " FN
    read -p "File type (or leave blank): " FT
    read -p "Directory to search: " DIR

    LOG="/tmp/search_log_$(date +'%m%d%Y_%H%M%S').txt"
    echo "[$(date)] FN=$FN, FT=$FT, DIR=$DIR" >> "$LOG"

    FULLDIR="$DIR"
    [[ "$DIR" != /* ]] && FULLDIR="$HOME/$DIR"

    PATTERN="*${FN}*"
    [[ -n "$FT" ]] && PATTERN+=".${FT}"

    mapfile -t RESULTS < <(find "$FULLDIR" -type f -iname "$PATTERN" 2>/dev/null)

    [[ ${#RESULTS[@]} -eq 0 ]] && { echo -e "${RED}No matches found.${RESET}"; return; }

    for i in "${!RESULTS[@]}"; do
        echo "[$((i+1))] ${RESULTS[$i]}"
    done

    read -p "Pick number to act on (or Enter to skip all): " CHOICE
    [[ -z "$CHOICE" ]] && return
    [[ $CHOICE =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#RESULTS[@]} )) && handle_file "${RESULTS[$((CHOICE-1))]}" || echo -e "${RED}Invalid choice.${RESET}"

    SEARCH_RESULTS=("${RESULTS[@]}")
}

view_logs() { 
    mapfile -t LOGS < <(ls -1t /tmp/search_log_*.txt 2>/dev/null)
    [[ ${#LOGS[@]} -eq 0 ]] && { echo -e "${YELLOW}No search logs found.${RESET}"; read -p "Press Enter..."; return; }
    echo -e "${CYAN}===== Current Search Logs =====${RESET}"
    for i in "${!LOGS[@]}"; do echo "[$((i+1))] ${LOGS[$i]}"; done
    read -p "Enter number to read (or Enter to cancel): " CHOICE
    [[ -z "$CHOICE" ]] && return
    [[ $CHOICE =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#LOGS[@]} )) && less "${LOGS[$((CHOICE-1))]}" || echo -e "${RED}Invalid choice.${RESET}"
}

pro_features() { 
    while true; do
        clear
        echo -e "${CYAN}===== Pro Features =====${RESET}"
        echo "1 → Export last search results to file"
        echo "2 → Return"
        read -p "Choice: " CHOICE
        case $CHOICE in
            1)
                [[ ${#SEARCH_RESULTS[@]} -eq 0 ]] && { echo -e "${YELLOW}No search results.${RESET}"; read -p "Enter to continue..."; continue; }
                OUTFILE="export_search_$(date +'%m%d%Y_%H%M%S').txt"
                printf "%s\n" "${SEARCH_RESULTS[@]}" > "$OUTFILE"
                echo -e "${GREEN}Search results exported to $OUTFILE${RESET}"
                read -p "Enter to continue..."
                ;;
            2) break ;;
            *) echo -e "${RED}Invalid choice.${RESET}" ;;
        esac
    done
}

egg_menu() {
    while true; do
        clear
        echo -e "${CYAN}===== Dad Joke Easter Egg =====${RESET}"
        echo "1 → Show random dad joke"
        echo "2 → Add new dad joke"
        echo "3 → Return"
        read -p "Choice: " EGG_CHOICE
        case $EGG_CHOICE in
            1)
                TOTAL=$(jq length "$DAD_JSON")
                (( TOTAL == 0 )) && echo -e "${YELLOW}No dad jokes yet!${RESET}" && read -p "Enter..." && continue
                INDEX=$(( RANDOM % TOTAL ))
                JOKE=$(jq -r ".[$INDEX]" "$DAD_JSON")
                echo -e "\n${MAGENTA}💡 Dad Joke: ${JOKE}${RESET}\n"
                read -p "Enter..."
                ;;
            2)
                read -p "Type your cheeky dad joke: " NEW_JOKE
                [[ -n "$NEW_JOKE" ]] && jq --arg joke "$NEW_JOKE" '. + [$joke]' "$DAD_JSON" > "${DAD_JSON}.tmp" && mv "${DAD_JSON}.tmp" "$DAD_JSON" && echo -e "${GREEN}Added!${RESET}" && confetti || echo -e "${YELLOW}Nothing added.${RESET}"
                read -p "Enter..."
                ;;
            3) break ;;
            *) echo -e "${RED}Invalid choice.${RESET}" ;;
        esac
    done
}

# 🔹 New ASCII snapshot viewer
view_dad_snapshot() {
    if [[ -f "$PHOTO" ]]; then
        echo -e "${CYAN}🖼 Displaying last dad snapshot as ASCII art...${RESET}"
        if command -v jp2a >/dev/null 2>&1; then
            jp2a --width=80 "$PHOTO"
        elif command -v catimg >/dev/null 2>&1; then
            catimg -w 80 "$PHOTO"
        else
            echo -e "${YELLOW}Install jp2a or catimg to see ASCII snapshot.${RESET}"
        fi
    else
        echo -e "${YELLOW}No snapshot found.${RESET}"
    fi
    read -p "Press Enter to continue..."
}

matrix_dad_mode() {
    clear
    echo -e "${GREEN}💻 Matrix + Dad Mode Activated!${RESET}"

    # Display ASCII snapshot first
    view_dad_snapshot

    # Run cmatrix interactively
    if command -v cmatrix >/dev/null 2>&1; then
        echo -e "${CYAN}Press Ctrl+C to exit Matrix mode...${RESET}"
        cmatrix -s
    else
        echo -e "${YELLOW}cmatrix not installed.${RESET}"
    fi

    echo -e "${CYAN}Matrix session ended.${RESET}"
    read -p "Press Enter to return to menu..."
}

# Main menu
SEARCH_RESULTS=()
while true; do
    clear
    show_ad
    echo -e "${CYAN}================ Mini File Explorer ================${RESET}"
    echo -e "${GREEN}a${RESET} → Premade list"
    echo -e "${GREEN}s${RESET} → Search interactively"
    echo -e "${GREEN}p${RESET} → Pro Features"
    echo -e "${GREEN}l${RESET} → View Search Logs"
    echo -e "${GREEN}egg${RESET} → Dad Joke Easter Egg"
    echo -e "${GREEN}d${RESET} → View last dad snapshot (ASCII)"
    echo -e "${GREEN}m${RESET} → Matrix + Dad Mode"
    echo -e "${GREEN}q${RESET} → Quit"
    echo "=================================================="
    read -p "Choice: " MENU
    case $MENU in
        a|A) for FILE in "${PREMADE_LIST[@]}"; do [[ -f "$FILE" ]] && handle_file "$FILE" || echo -e "${RED}Not found: $FILE${RESET}"; done; play_queue; read -p "Press Enter..." ;;
        s|S) interactive_search; play_queue; read -p "Press Enter..." ;;
        p|P) pro_features ;;
        l|L) view_logs ;;
        egg|EGG) egg_menu ;;
        d|D) view_dad_snapshot ;;
        m|M) matrix_dad_mode ;;
        q|Q) clear; exit 0 ;;
        *) echo -e "${RED}Invalid menu choice.${RESET}" ;;
    esac
done

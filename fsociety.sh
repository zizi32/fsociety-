#!/bin/bash

# --- FSOCIETY GOD AUTO-INSTALLER v7.2 ---
# Katana + Uro + GF (Full Patterns) + Dalfox + Nuclei


TOKEN="bot_tele"
CHAT_ID="bot_tele"

RED='\033[1;31m'
WHITE='\033[1;37m'
GREEN='\033[0;32m'
CYAN='\033[1;36m'
NC='\033[0m'

# --- MEGA AUTO-INSTALLER ---
install_logic() {
    echo -e "${CYAN}[*] Memulai instalasi otomatis tools elit...${NC}"
    sudo apt-get update -y &>/dev/null
    sudo apt-get install -y git python3 python3-pip golang curl &>/dev/null

    # 1. Install URO
    if ! command -v uro &> /dev/null; then
        echo -e "${WHITE}[+] Installing URO...${NC}"
        pip3 install uro --break-system-packages &>/dev/null || pip3 install uro &>/dev/null
    fi

    # 2. Install Katana
    if ! command -v katana &> /dev/null; then
        echo -e "${WHITE}[+] Installing Katana...${NC}"
        go install github.com/projectdiscovery/katana/cmd/katana@latest &>/dev/null
        sudo cp ~/go/bin/katana /usr/local/bin/ &>/dev/null
    fi

    # 3. Install GF & Patterns (Fix No Such Pattern)
    if ! command -v gf &> /dev/null; then
        echo -e "${WHITE}[+] Installing GF & Patterns...${NC}"
        go install github.com/tomnomnom/gf@latest &>/dev/null
        sudo cp ~/go/bin/gf /usr/local/bin/ &>/dev/null
    fi
    mkdir -p ~/.gf
    if [ ! -f ~/.gf/xss.json ]; then
        git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf/temp_patterns &>/dev/null
        mv ~/.gf/temp_patterns/*.json ~/.gf/ &>/dev/null
        rm -rf ~/.gf/temp_patterns
    fi

    # 4. Install Dalfox
    if ! command -v dalfox &> /dev/null; then
        echo -e "${WHITE}[+] Installing Dalfox...${NC}"
        go install github.com/hahwul/dalfox/v2@latest &>/dev/null
        sudo cp ~/go/bin/dalfox /usr/local/bin/ &>/dev/null
    fi

    # 5. Install Nuclei
    if ! command -v nuclei &> /dev/null; then
        echo -e "${WHITE}[+] Installing Nuclei...${NC}"
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest &>/dev/null
        sudo cp ~/go/bin/nuclei /usr/local/bin/ &>/dev/null
    fi

    echo -e "${GREEN}[✔] SEMUA TOOLS BERHASIL DI-INSTALL BEB!${NC}"
}

send_telegram() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d parse_mode="Markdown" \
    -d text="$1" > /dev/null
}

# --- BANNER ---
clear
echo -e "${RED}"
echo '      o888o                                     o88                o8      '
echo 'oooo888oo oooooooo8    ooooooo     ooooooo  oooo  ooooooooo8 o888oo oooo   oooo'
echo '  888    888ooooooo  888     888 888     888 888 888oooooo8   888    888   888 '
echo '  888            888 888     888 888         888 888          888     888 888  '
echo ' o888o   88oooooo88    88ooo88     88ooo888 o888o  88oooo888   888o     8888   '
echo '                                                                     o8o888    '
echo -e "${NC}"
echo -e "   G O D   I N S T A L L E R   v 7 . 2   B Y   M R . R U B I C"
echo -e "────────────────────────────────────────────────────────────────────────"

if [ -z "$1" ]; then
    echo -e "${RED}[!] Mana targetnya beb? (Contoh: target.com)${NC}"
    exit 1
fi

# Jalankan instalasi otomatis sebelum menyerang
install_logic

TARGET=$1
OUT="results_$TARGET"
mkdir -p $OUT

send_telegram "🚀 *ULTIMATE SCAN STARTED!*%0A🎯 Target: \`$TARGET\`"

# --- EXECUTION ---
echo -e "${WHITE}[+] Crawling URLs (Katana)...${NC}"
katana -u "http://$TARGET" -jc -kf all -d 3 | uro > $OUT/urls.txt

echo -e "${WHITE}[+] Filtering XSS (GF)...${NC}"
cat $OUT/urls.txt | gf xss > $OUT/xss_params.txt

if [ -s "$OUT/xss_params.txt" ]; then
    echo -e "${WHITE}[+] Attacking XSS (Dalfox)...${NC}"
    cat $OUT/xss_params.txt | dalfox pipe --worker 20 > $OUT/dalfox.txt
fi

echo -e "${WHITE}[+] Scanning Vulnerabilities (Nuclei)...${NC}"
nuclei -u "http://$TARGET" -severity critical,high -o $OUT/nuclei.txt

# --- SUMMARY ---
V_COUNT=$( [ -f $OUT/nuclei.txt ] && wc -l < $OUT/nuclei.txt || echo "0" )
send_telegram "✅ *Scan v7.2 Selesai!* %0A🎯 Target: \`$TARGET\` %0A🧬 Nuclei: *$V_COUNT Hits*"

echo -e "\n${GREEN}[✔] Selesai beb! Semua tools sudah terpasang dan scan sukses.${NC}"

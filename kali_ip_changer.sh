#!/bin/bash

# ==============================================================================
# Tool Name   : kali_ip_changer
# Platform    : Kali Linux Only
# Purpose     : Instant Tor SOCKS5 IP rotation via ControlPort (SIGNAL NEWNYM)
#               for authorized educational labs and network privacy testing.
#
# DISCLAIMER  : This tool is created strictly for authorized educational and 
#               learning purposes only. Do NOT use this script for any illegal,
#               malicious, or unauthorized activities.
#
# Attribution : Special thanks to the original repository developer (GR33N37) 
#               for the foundational Tor IP rotation concept.
# ==============================================================================

if [[ "$UID" -ne 0 ]]; then
    echo -e "\033[31m[!] Error: kali_ip_changer must be run as root (use sudo).\033[0m"
    exit 1
fi

verify_kali() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$ID" != "kali" && "$NAME" != *"Kali"* ]]; then
            echo -e "\033[31m[!] Unsupported OS: $PRETTY_NAME (Kali Linux Only)\033[0m"
            exit 1
        fi
    else
        exit 1
    fi
}

setup_dependencies() {
    for pkg in curl tor netcat-openbsd; do
        if ! dpkg -s "$pkg" &> /dev/null; then
            echo -e "\033[33m[*] Installing $pkg...\033[0m"
            apt-get update -qq && apt-get install -y "$pkg"
        fi
    done

    # Enable Tor ControlPort 9051 for instant NEWNYM signals
    if ! grep -q "^ControlPort 9051" /etc/tor/torrc; then
        echo -e "\033[33m[*] Configuring Tor ControlPort 9051...\033[0m"
        echo -e "\nControlPort 9051\nCookieAuthentication 1" >> /etc/tor/torrc
        systemctl restart tor.service
        sleep 3
    fi
}

get_ip() {
    local ip
    ip=$(curl -s --max-time 8 -x socks5h://127.0.0.1:9050 "https://api.ipify.org")
    if [[ -z "$ip" ]]; then
        echo "Switching circuit..."
    else
        echo "$ip"
    fi
}

change_ip() {
    local cookie_hex
    cookie_hex=$(xxd -p -c 32 /run/tor/control.authcookie 2>/dev/null)

    if [[ -n "$cookie_hex" ]]; then
        # Send instant SIGNAL NEWNYM via ControlPort (no service restart lag)
        printf 'AUTHENTICATE %s\r\nSIGNAL NEWNYM\r\nQUIT\r\n' "$cookie_hex" | nc -w 2 127.0.0.1 9051 > /dev/null
    else
        systemctl reload tor.service
    fi

    sleep 1
    echo -e "\033[32m[+] New Tor Exit IP: \033[34m$(get_ip)\033[0m"
}

verify_kali
setup_dependencies

if ! systemctl --quiet is-active tor.service; then
    echo -e "\033[33m[*] Starting Tor service...\033[0m"
    systemctl start tor.service
    sleep 3
fi

clear
cat << "EOF"
  _  __     _ _   ___ ____     ____ _                                 
 | |/ /__ _| (_) |_ _|  _ \   / ___| |__   __ _ _ __   __ _  ___ _ __ 
 | ' // _` | | |  | || |_) | | |   | '_ \ / _` | '_ \ / _` |/ _ \ '__|
 | . \ (_| | | |  | ||  __/  | |___| | | | (_| | | | | (_| |  __/ |   
 |_|\_\__,_|_|_| |___|_|      \____|_| |_|\__,_|_| |_|\__, |\___|_|   
                                                      |___/           
  [ Kali Linux Fast Tor IP Rotator | Authorized Educational & Lab Use ]
  [ Tip: Set Firefox SOCKS5 proxy to 127.0.0.1:9050 + Proxy DNS       ]
EOF
echo ""

while true; do
    read -rp $'\033[34mEnter time interval in seconds (min 10s recommended, 0 for random 10-20s): \033[0m' interval
    read -rp $'\033[34mEnter number of times to change IP (0 for infinite): \033[0m' times

    if ! [[ "$interval" =~ ^[0-9]+$ ]] || ! [[ "$times" =~ ^[0-9]+$ ]]; then
        echo -e "\033[31m[!] Please enter valid numbers.\033[0m\n"
        continue
    fi

    if [[ "$interval" -eq 0 ]] || [[ "$times" -eq 0 ]]; then
        echo -e "\n\033[33m[*] Starting fast infinite IP rotation (Ctrl+C to stop)...\033[0m"
        while true; do
            change_ip
            rand_interval=$(shuf -i 10-20 -n 1)
            echo -e "\033[90m[~] Next rotation in ${rand_interval}s...\033[0m"
            sleep "$rand_interval"
        done
    else
        echo -e "\n\033[33m[*] Rotating IP $times time(s) every ${interval}s...\033[0m"
        for ((i=1; i<=times; i++)); do
            echo -e "\033[36m--- Cycle $i of $times ---\033[0m"
            change_ip
            if [[ "$i" -lt "$times" ]]; then
                sleep "$interval"
            fi
        done
        echo -e "\n\033[32m[+] Completed $times IP rotation(s).\033[0m"
        break
    fi
done

#!/usr/bin/env bash

# Usage: ./sleep_timer.sh 1800
total=${1:-1800}

GREEN=$'\e[42m\e[30m'
RED=$'\e[41m\e[30m'
RESET=$'\e[0m'

interval=0.1
start_time=$(date +%s)
end_time=$((start_time + total))

while true; do
    now=$(date +%s)
    elapsed=$((now - start_time))
    remaining=$((end_time - now))

    [ $remaining -lt 0 ] && break

    term_width=$(tput cols)
    bar_length=$((term_width - 12))
    [ $bar_length -lt 10 ] && bar_length=10

    filled=$((elapsed * bar_length / total))
    empty=$((bar_length - filled))
    bar="${GREEN}$(printf "%0.s " $(seq 1 $filled))${RED}$(printf "%0.s " $(seq 1 $empty))${RESET}"

    mins=$((remaining / 60))
    secs=$((remaining % 60))

    printf "\r[%s] %02d:%02d" "$bar" $mins $secs

    sleep $interval
done

playerctl -p playerctld pause
echo -e "\nPaused!"
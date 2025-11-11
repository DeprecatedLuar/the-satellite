#!/usr/bin/env bash

# Color detection: disable colors if not outputting to a terminal
if [ -t 1 ] && [ -n "$TERM" ]; then
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    BLUE=''
    CYAN=''
    GREEN=''
    RED=''
    YELLOW=''
    NC=''
fi

action() {
    echo -e "${BLUE}→${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}→${NC} $1"
}

error() {
    echo -e "${RED}✗ $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}! $1${NC}"
}

success_arrow() {
    echo -e "${GREEN}→${NC} $1"
}

separator() {
    local text="$1"
    local width=$(tput cols 2>/dev/null || echo 80)
    local text_length=$((${#text} + 4))
    local dash_count=$((width - text_length))

    if [ $dash_count -lt 0 ]; then
        dash_count=0
    fi

    local dashes=$(printf '%*s' "$dash_count" '' | tr ' ' '-')
    echo -e "${BLUE}-- ${text} ${dashes}${NC}"
}

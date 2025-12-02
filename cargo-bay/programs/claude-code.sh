#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"

action "Installing Claude Code..."

if ! command -v npm &> /dev/null; then
    error "npm not found. Install Node.js first: sat_run nodejs"
fi

npm install -g @anthropic-ai/claude-code

success "Claude Code installed"

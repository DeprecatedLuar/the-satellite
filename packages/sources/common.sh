#!/usr/bin/env bash

_info()    { echo "  $*"; }
_success() { echo "✓ $*"; }
_error()   { echo "✗ $*" >&2; exit 1; }

#!/usr/bin/env bash
# ┌─────────────┬────────────┐
# │             │  opencode  │
# │    vim      ├────────────┤
# │             │  terminal  │
# └─────────────┴────────────┘
ROOT="$HOME/work"

w=$(mux_new_session "$ROOT")
mux_split_editor "$w" "$ROOT"
mux_opencode "${SESSION_NAME}:${w}.2" "$ROOT"

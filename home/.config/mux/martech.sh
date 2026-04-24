#!/usr/bin/env bash
# ┌─────────────┬────────────┐
# │             │  opencode  │
# │    vim      ├────────────┤
# │             │  terminal  │
# └─────────────┴────────────┘
ROOT="$HOME/Developer/cx-martech"

w=$(mux_new_session "$ROOT")
tmux rename-window -t "${SESSION_NAME}:${w}" convups
mux_split_editor "$w" "$ROOT/conversion_uploaders"
mux_opencode "${SESSION_NAME}:${w}.2" "$ROOT/conversion_uploaders"
ms=$(mux_new_window "$ROOT" marsync)
mux_split_editor "$ms" "$ROOT/marsync"
mux_opencode "${SESSION_NAME}:${ms}.2" "$ROOT/marsync"
w2=$(mux_new_window "$ROOT" monorepo)
mux_split_editor "$w2" "$ROOT"
mux_opencode "${SESSION_NAME}:${w2}.2" "$ROOT"
tw=$(mux_new_window "$ROOT" consoles)
mux_split_tiled "$tw" "$ROOT"
tmux send-keys -t "${SESSION_NAME}:${tw}.4" "./bin/dev infra" Enter
mux_focus_window "$w"

#!/usr/bin/env bash
# Shared helpers for `mux` and `oc` — the opencode "shared server" integration.
# Not standalone; source this file.
#
# Env overrides:
#   OPENCODE_BASE   default: http://127.0.0.1:4096
#                   Change this if port 4096 is taken on your machine.
#                   Example: export OPENCODE_BASE=http://127.0.0.1:4196
#   OPENCODE_REAL   default: first existing of
#                       ~/.opencode/bin/opencode, $(command -v opencode)
#
# Exposes:
#   _opencode_server_healthy      — 0 if server responds healthy at OPENCODE_BASE
#   _opencode_server_pid          — prints PID listening on OPENCODE_BASE's port
#   _opencode_port_owner_is_us    — 0 if the listener is an opencode process
#   _ensure_opencode_server       — starts the server if not already up (collision-aware)
#   _opencode_create_session DIR  — POSTs to /session?directory=DIR, prints session id

: "${OPENCODE_BASE:=http://127.0.0.1:4096}"
if [[ -z "${OPENCODE_REAL:-}" ]]; then
	if [[ -x "$HOME/.opencode/bin/opencode" ]]; then
		OPENCODE_REAL="$HOME/.opencode/bin/opencode"
	else
		OPENCODE_REAL="$(command -v opencode 2>/dev/null || true)"
	fi
fi
_OPENCODE_LOG=/tmp/opencode-server.log

_opencode_server_pid() {
	local port="${OPENCODE_BASE##*:}"
	lsof -t -iTCP:"$port" -sTCP:LISTEN -nP 2>/dev/null | head -1
}

_opencode_port_owner_is_us() {
	local pid
	pid=$(_opencode_server_pid)
	[[ -n "$pid" ]] || return 1
	local comm
	comm=$(ps -p "$pid" -o comm= 2>/dev/null)
	[[ "$comm" == *opencode* ]]
}

_opencode_server_healthy() {
	curl -s -m 1 "${OPENCODE_BASE}/global/health" 2>/dev/null | grep -q '"healthy":true'
}

# Start/verify the shared opencode server. Handles four cases:
#   1. Server already up and healthy       → no-op, return 0.
#   2. Port free                           → start opencode serve, wait, return 0/1.
#   3. Port taken by a stuck opencode      → warn and fail (user action required).
#   4. Port taken by a non-opencode proc   → warn with actionable fix (OPENCODE_BASE override).
_ensure_opencode_server() {
	_opencode_server_healthy && return 0

	local port="${OPENCODE_BASE##*:}"
	local owner_pid
	owner_pid=$(_opencode_server_pid)

	if [[ -n "$owner_pid" ]]; then
		if _opencode_port_owner_is_us; then
			echo "opencode: an opencode process (PID $owner_pid) is on port $port but not healthy." >&2
			echo "         Consider: kill $owner_pid   (last-resort reset)" >&2
			return 1
		else
			local owner_cmd
			owner_cmd=$(ps -p "$owner_pid" -o command= 2>/dev/null | head -c 80)
			echo "opencode: port $port is taken by another process (PID $owner_pid):" >&2
			echo "         $owner_cmd" >&2
			echo "         Either free the port, or set OPENCODE_BASE to a different port." >&2
			echo "         Example: export OPENCODE_BASE=http://127.0.0.1:4196" >&2
			return 1
		fi
	fi

	echo "opencode: starting shared server on ${OPENCODE_BASE}" >&2
	(
		cd "$HOME" &&
			nohup "$OPENCODE_REAL" serve --port "$port" --hostname 127.0.0.1 \
				>"$_OPENCODE_LOG" 2>&1 &
	)
	disown 2>/dev/null || true

	local i
	for i in 1 2 3 4 5 6 7 8 9 10; do
		_opencode_server_healthy && return 0
		sleep 0.5
	done

	echo "opencode: WARNING server didn't come up in 5s — check $_OPENCODE_LOG" >&2
	return 1
}

# Create a session pinned to a directory; print its session id.
# Prints nothing (and returns non-zero) on failure.
_opencode_create_session() {
	local dir="$1"
	local sid
	sid=$(
		curl -s -m 3 -X POST "${OPENCODE_BASE}/session?directory=${dir}" \
			-H 'content-type: application/json' -d '{}' |
			sed -nE 's/.*"id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
	)
	[[ -n "$sid" ]] || return 1
	printf '%s\n' "$sid"
}

# URL-encode a directory path for safe use in query strings.
_opencode_urlencode() {
	/usr/bin/python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1],safe=""))' "$1"
}

# Short-form a directory path for display: $HOME → "~", otherwise pass through.
_opencode_short_dir() {
	local d="$1"
	[[ "$d" == "$HOME" ]] && {
		printf '~\n'
		return
	}
	[[ "$d" == "$HOME"/* ]] && {
		printf '~/%s\n' "${d#$HOME/}"
		return
	}
	printf '%s\n' "$d"
}

# Compute a short, human-friendly label for a directory.
_opencode_dir_label() {
	local d="$1"
	[[ "$d" == "$HOME" ]] && {
		printf '~\n'
		return
	}
	[[ "$d" == "/" ]] && {
		printf '/\n'
		return
	}
	local rel="${d#/}"
	[[ "$d" == "$HOME"/* ]] && rel="${d#$HOME/}"
	local leaf="${rel##*/}"
	if [[ "$leaf" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_(.+)$ ]]; then
		printf '%s\n' "${BASH_REMATCH[1]}"
		return
	fi
	case "$leaf" in
	repos | src | work | projects | code | dev)
		local parent_path="${rel%/*}"
		if [[ "$parent_path" != "$rel" && -n "$parent_path" ]]; then
			local parent="${parent_path##*/}"
			[[ -n "$parent" ]] && {
				printf '%s/%s\n' "$parent" "$leaf"
				return
			}
		fi
		;;
	esac
	printf '%s\n' "$leaf"
}

# Given a title and a directory, render a display title with "[label]" prefix.
_opencode_display_title() {
	local title="$1" dir="$2"
	local label
	label=$(_opencode_dir_label "$dir")
	case "$title" in
	"New session - "* | "Child session - "*) printf '[%s]\n' "$label" ;;
	*) printf '[%s] %s\n' "$label" "$title" ;;
	esac
}

# Resolve a live attach-mode TUI's session id from a directory.
_opencode_session_for_dir() {
	local target="$1"
	[[ -n "$target" ]] || return 1
	target=$(cd "$target" 2>/dev/null && pwd -P) || return 1

	local matches
	matches=$(ps auxww | awk -v target="$target" '
    /opencode/ && /attach/ && !/awk/ && !/grep/ {
      sid=""; dir="";
      for (i=1; i<=NF; i++) {
        if ($i ~ /^ses_/) sid = $i
        else if ($i == "--dir" && i+1 <= NF) dir = $(i+1)
      }
      if (sid != "" && dir == target) print sid
    }
  ')
	local count
	count=$(printf '%s' "$matches" | grep -c .)
	if [[ "$count" -eq 1 ]]; then
		printf '%s\n' "$matches"
		return 0
	elif [[ "$count" -gt 1 ]]; then
		echo "oc: multiple TUIs attached to $target — pass an explicit session id:" >&2
		printf '%s\n' "$matches" | sed 's/^/  /' >&2
		return 2
	else
		echo "oc: no attach-mode TUI found for $target" >&2
		return 1
	fi
}

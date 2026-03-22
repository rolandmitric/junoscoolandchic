#!/usr/bin/env bash

set -euo pipefail

PORT="${PORT:-${1:-4173}}"

is_port_in_use() {
  lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1
}

if command -v lsof >/dev/null 2>&1 && is_port_in_use "$PORT"; then
  ORIGINAL_PORT="$PORT"
  for CANDIDATE in $(seq $((PORT + 1)) $((PORT + 20))); do
    if ! is_port_in_use "$CANDIDATE"; then
      PORT="$CANDIDATE"
      echo "Port ${ORIGINAL_PORT} is in use, switching to ${PORT}."
      break
    fi
  done

  if [ "$PORT" = "$ORIGINAL_PORT" ]; then
    echo "Port ${ORIGINAL_PORT} is in use. Stop that process or run: PORT=<free-port> ./start.sh"
    exit 1
  fi
fi

echo "Starting preview server at http://localhost:${PORT}"
python3 -m http.server "${PORT}"

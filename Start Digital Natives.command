#!/bin/zsh
cd "${0:A:h}"
DN_NODE="$(command -v node)"
if [[ -z "$DN_NODE" ]]; then
  DN_NODE="$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node"
fi
if [[ ! -x "$DN_NODE" ]]; then
  echo "Install Node.js 20 or later from https://nodejs.org, then open this launcher again."
  read -k 1 "?Press any key to close."
  exit 1
fi
PORT=8080 "$DN_NODE" server.js &
DN_SERVER_PID=$!
trap 'kill "$DN_SERVER_PID" 2>/dev/null' EXIT INT TERM
sleep 1
if ! kill -0 "$DN_SERVER_PID" 2>/dev/null; then
  echo "Could not start the server. Another app may already use port 8080."
  read -k 1 "?Press any key to close."
  exit 1
fi
open "http://localhost:8080"
wait "$DN_SERVER_PID"

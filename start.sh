#!/usr/bin/env bash
set -e

COIN="DAI" \
NETWORK="kovan" \
LOGO="/images/kovan_logo.svg" \
ETHEREUM_JSONRPC_HTTP_URL="http://localhost:2000" \
ETHEREUM_JSONRPC_WEB_SOCKET_URL="ws://localhost:2000" \
ETHEREUM_JSONRPC_VARIANT="ganache" \
iex -S mix phx.server

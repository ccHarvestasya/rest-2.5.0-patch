#!/bin/bash
set -euo pipefail

URL="http://localhost:3000/node/server"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="/app/src"
SRC_PATH="${SCRIPT_DIR}${SRC_DIR}"
DEST_PATH="/app"

if ! response=$(curl -s "$URL"); then
    echo "Error: Cannot access server ($URL)"
    exit 1
fi

if [ -z "$response" ]; then
    echo "Error: Empty response from server ($URL)"
    exit 1
fi

REST_VERSION=$(echo "$response" | jq -r '.serverInfo.restVersion')
DEPLOYMENT_TOOL=$(echo "$response" | jq -r '.serverInfo.deployment.deploymentTool')

if [ "$REST_VERSION" != "2.5.0" ]; then
    echo "Error: REST_VERSION is not 2.5.0. Current version: $REST_VERSION"
    exit 1
fi

if [ "$DEPLOYMENT_TOOL" = "shoestring" ]; then
    echo "DEPLOYMENT_TOOL: Detected shoestring"
    CONTAINER_NAME="shoestring-rest-api-1"
elif [ "$DEPLOYMENT_TOOL" = "@nemneshia/symbol-bootstrap" ]; then
    echo "DEPLOYMENT_TOOL: Detected @nemneshia/symbol-bootstrap"
    CONTAINER_NAME="rest-gateway"
else
    echo "Error: Unsupported DEPLOYMENT_TOOL. Current value: $DEPLOYMENT_TOOL"
    echo "Supported tools: shoestring, @nemneshia/symbol-bootstrap"
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container '${CONTAINER_NAME}' is not running."
    exit 1
fi

echo "Copying ${SRC_PATH} to ${CONTAINER_NAME}:${DEST_PATH}"
docker cp "$SRC_PATH" "${CONTAINER_NAME}:${DEST_PATH}"
docker exec --user root ${CONTAINER_NAME} chown -R 1000:1000 ${SRC_DIR}

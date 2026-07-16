#!/usr/bin/env bash
# Generate and validate apps/client/.env from environment variables.
# Call from a workflow step after setting APP_ENV, DEBUG, etc. from vars/secrets.

set -euo pipefail

TARGET_DIR="${FLUTTER_ENV_DIR:-apps/client}"
ENV_FILE="${TARGET_DIR}/.env"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "::error::Missing or empty required environment variable: ${name}"
    exit 1
  fi
}

require_env APP_ENV
require_env DEBUG
require_env ENABLE_DEV_LOGIN
require_env DEV_OTP
require_env API_BASE_URL
require_env MSG91_WIDGET_ID
require_env MSG91_WIDGET_AUTH_TOKEN

mkdir -p "${TARGET_DIR}"

cat > "${ENV_FILE}" <<EOF
APP_ENV=${APP_ENV}
DEBUG=${DEBUG}
ENABLE_DEV_LOGIN=${ENABLE_DEV_LOGIN}
DEV_OTP=${DEV_OTP}
API_BASE_URL=${API_BASE_URL}
MSG91_WIDGET_ID=${MSG91_WIDGET_ID}
MSG91_WIDGET_AUTH_TOKEN=${MSG91_WIDGET_AUTH_TOKEN}
EOF

require_key() {
  if ! grep -q "^${1}=." "${ENV_FILE}"; then
    echo "::error::Missing or empty required key in .env: ${1}"
    exit 1
  fi
}

require_key APP_ENV
require_key DEBUG
require_key ENABLE_DEV_LOGIN
require_key DEV_OTP
require_key API_BASE_URL
require_key MSG91_WIDGET_ID
require_key MSG91_WIDGET_AUTH_TOKEN

echo "Flutter .env validated at ${ENV_FILE}."

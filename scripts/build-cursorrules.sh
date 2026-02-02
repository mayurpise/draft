#!/usr/bin/env bash
#
# DEPRECATED: Use build-integrations.sh instead.
# This wrapper exists for backward compatibility.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "NOTE: build-cursorrules.sh is deprecated. Use build-integrations.sh instead."
echo ""

exec "$SCRIPT_DIR/build-integrations.sh" "$@"

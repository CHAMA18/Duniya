#!/usr/bin/env bash
# =====================================================================
# Pulse — Resend email service setup & verification
# =====================================================================
# Ensures the Resend integration is properly configured for the
# Firebase project (default: pharmacy-system-2fb27).
#
# Usage:
#   ./setup-resend.sh                  # show current config + guide
#   ./setup-resend.sh set-key re_xxx   # set the Resend API key
#   ./setup-resend.sh set-from "Pulse <noreply@yourdomain.com>"
#   ./setup-resend.sh set-url "https://pulse.duniyahealthcare.com"
#   ./setup-resend.sh deploy            # deploy functions with the config
#   ./setup-resend.sh test you@mail.com # send a test email (admin SDK)
#
# Requirements: firebase-tools CLI logged in
# (npm i -g firebase-tools && firebase login)
# =====================================================================
set -euo pipefail

PROJECT="pharmacy-system-2fb27"
FUNC_DIR="firebase/functions"

cmd="${1:-show}"

case "$cmd" in
  show)
    echo "==> Firebase project: ${PROJECT}"
    echo ""
    echo "==> Current Resend-related functions config:"
    firebase functions:config:get 2>/dev/null | grep -E '"(resend|app)"' || \
      echo "    (no resend/app keys set, or firebase CLI not logged in)"
    echo ""
    echo "Configuration reference (what the cloud functions read):"
    echo "  resend.key  REQUIRED  Resend API key (re_...) — secrets stay"
    echo "                        server-side; never in the client bundle."
    echo "  resend.from OPTIONAL  Sender override. Default:"
    echo "                        'Pulse <noreply@thestackone.com>'"
    echo "  app.url     OPTIONAL  Portal URL used in staff-invitation"
    echo "                        links. Default:"
    echo "                        'https://pulse.duniyahealthcare.com/app.html'"
    echo ""
    echo "To configure:"
    echo "  $0 set-key  re_xxxxxxxxxxxx"
    echo "  $0 set-from 'Pulse <noreply@yourdomain.com>'"
    echo "  $0 set-url  'https://pulse.duniyahealthcare.com'"
    echo "  $0 deploy"
    ;;
  set-key)
    [[ $# -ge 2 ]] || { echo "Usage: $0 set-key re_xxx"; exit 1; }
    firebase functions:config:set resend.key="$2"
    echo "==> Key set. Deploy with: $0 deploy"
    ;;
  set-from)
    [[ $# -ge 2 ]] || { echo "Usage: $0 set-from 'Pulse <noreply@domain>'"; exit 1; }
    firebase functions:config:set resend.from="$2"
    echo "==> Sender override set. Deploy with: $0 deploy"
    ;;
  set-url)
    [[ $# -ge 2 ]] || { echo "Usage: $0 set-url https://..."; exit 1; }
    firebase functions:config:set app.url="$2"
    echo "==> Portal URL set. Deploy with: $0 deploy"
    ;;
  deploy)
    echo "==> Deploying functions (project: ${PROJECT})..."
    ( cd "$FUNC_DIR" && npm install --no-audit --no-fund )
    firebase deploy --only functions --project "$PROJECT"
    echo "==> Deployed. Verify with: $0 test your@email.com"
    ;;
  test)
    [[ $# -ge 2 ]] || { echo "Usage: $0 test you@mail.com"; exit 1; }
    echo "==> Sending test email to $2 ..."
    ( cd "$FUNC_DIR" && node test_send_email.js "$2" )
    ;;
  *)
    echo "Unknown command: $cmd"
    echo "Commands: show | set-key | set-from | set-url | deploy | test"
    exit 1
    ;;
esac

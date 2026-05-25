#!/usr/bin/env bash
set -euo pipefail

# ─── Docker container ports ───────────────────────────────────────────────────
# DOCKER_ALLOW: ports to fully allow (no rate limiting)
DOCKER_ALLOW=(
    # "3000"       # example: Node app
    # "8080/tcp"   # example: web service
)

# DOCKER_LIMIT: ports to rate-limit (blocks IPs after 6 connections/30s)
DOCKER_LIMIT=(
    # "5432"       # example: Postgres
    # "6379"       # example: Redis
)
# ──────────────────────────────────────────────────────────────────────────────

# ─── Colors & styles ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
WIDTH=52
# ──────────────────────────────────────────────────────────────────────────────

# ─── UI helpers ───────────────────────────────────────────────────────────────
divider()  { printf "${DIM}%${WIDTH}s${RESET}\n" | tr ' ' '─'; }
ok()       { printf "  ${GREEN}✅  ${RESET}${BOLD}%s${RESET} ${DIM}%s${RESET}\n" "$1" "${2:-}"; }
warn()     { printf "  ${YELLOW}⚠️   ${RESET}${BOLD}%s${RESET} ${DIM}%s${RESET}\n" "$1" "${2:-}"; }
err()      { printf "  ${RED}❌  ${RESET}${BOLD}%s${RESET}\n" "$1" >&2; }
limited()  { printf "  ${YELLOW}⏱️   ${RESET}%-18s ${DIM}→ rate-limited${RESET}\n" "$1"; }
allowed()  { printf "  ${GREEN}🟢  ${RESET}%-18s ${DIM}→ allowed${RESET}\n" "$1"; }

section() {
    echo ""
    printf "${CYAN}${BOLD}  %s %s${RESET}\n" "$1" "$2"
    divider
}

header() {
    local title="🔥  UFW Firewall Configurator  🔥"
    local inner=$(( WIDTH - 2 ))
    echo ""
    printf "${BOLD}${MAGENTA}╔%${WIDTH}s╗${RESET}\n" | tr ' ' '═'
    printf "${BOLD}${MAGENTA}║${RESET}${BOLD}%-${inner}s${RESET}${BOLD}${MAGENTA} ║${RESET}\n" "$(printf "%$(( (inner + ${#title}) / 2 ))s" "$title")"
    printf "${BOLD}${MAGENTA}╚%${WIDTH}s╝${RESET}\n" | tr ' ' '═'
    echo ""
}
# ──────────────────────────────────────────────────────────────────────────────

header

# ─── Preflight checks ─────────────────────────────────────────────────────────
section "🔍" "Preflight Checks"

if [[ $EUID -ne 0 ]]; then
    err "Must be run as root or with sudo"
    exit 1
fi
ok "Running as root"

if ! command -v ufw &>/dev/null; then
    err "UFW not found — install with: sudo apt install ufw"
    exit 1
fi
ok "UFW is installed" "($(ufw version | head -1))"

# ─── Reset ────────────────────────────────────────────────────────────────────
section "🔄" "Resetting UFW"
ufw --force reset &>/dev/null
ok "Reset to defaults"

# ─── Default policies ─────────────────────────────────────────────────────────
section "🛡️ " "Default Policies"
ufw default deny incoming  &>/dev/null
ufw default allow outgoing &>/dev/null
ok "Incoming" "DENY"
ok "Outgoing" "ALLOW"

# ─── Core services ────────────────────────────────────────────────────────────
section "🌐" "Core Services"
ufw limit ssh   &>/dev/null;  limited "SSH   (22/tcp)"
ufw limit http  &>/dev/null;  limited "HTTP  (80/tcp)"
ufw limit https &>/dev/null;  limited "HTTPS (443/tcp)"

# ─── Docker ports ─────────────────────────────────────────────────────────────
section "🐳" "Docker Ports"

if [[ ${#DOCKER_ALLOW[@]} -eq 0 && ${#DOCKER_LIMIT[@]} -eq 0 ]]; then
    warn "No Docker ports configured" "(edit DOCKER_ALLOW / DOCKER_LIMIT)"
fi

for entry in "${DOCKER_ALLOW[@]}"; do
    ufw allow "$entry" &>/dev/null
    allowed "$entry"
done

for entry in "${DOCKER_LIMIT[@]}"; do
    ufw limit "$entry" &>/dev/null
    limited "$entry"
done

# ─── Enable ───────────────────────────────────────────────────────────────────
section "🚀" "Enabling UFW"
ufw --force enable &>/dev/null
ok "UFW is now active!"

# ─── Status ───────────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${MAGENTA}╔%${WIDTH}s╗${RESET}\n" | tr ' ' '═'
printf "${BOLD}${MAGENTA}║${RESET}${BOLD}%-$(( WIDTH - 1 ))s${RESET}${BOLD}${MAGENTA}║${RESET}\n" "  📋  Firewall Status"
printf "${BOLD}${MAGENTA}╚%${WIDTH}s╝${RESET}\n" | tr ' ' '═'
echo ""
ufw status verbose
echo ""

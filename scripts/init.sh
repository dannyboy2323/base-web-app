#!/bin/bash
# =============================================================================
# base-web-app — Project Initialization Script
#
# Run this ONCE immediately after cloning a new project from the template:
#   bash scripts/init.sh
#
# What it does:
#   1. Prompts for project-specific values
#   2. Replaces all {{PLACEHOLDER}} tokens throughout the codebase
#   3. Installs dependencies
#   4. Sets up git
#   5. Prints a post-setup checklist
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     base-web-app — Project Setup         ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will personalize your new project by replacing all template"
echo -e "placeholders with your project-specific values.${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C at any time to cancel.${NC}"
echo ""

# =============================================================================
# Collect project values
# =============================================================================

echo -e "${BOLD}── Project Identity ─────────────────────────────────────────────────${NC}"
echo ""

read -p "Project name (lowercase, hyphens only — e.g. cheater-monitor): " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
  echo -e "${RED}Error: Project name is required.${NC}"
  exit 1
fi
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo -e "${RED}Error: Project name must be lowercase letters, numbers, and hyphens only.${NC}"
  exit 1
fi

read -p "Project display name (e.g. Cheater Monitor): " PROJECT_DISPLAY_NAME
if [[ -z "$PROJECT_DISPLAY_NAME" ]]; then
  echo -e "${RED}Error: Display name is required.${NC}"
  exit 1
fi

read -p "Project description (one sentence): " PROJECT_DESCRIPTION
if [[ -z "$PROJECT_DESCRIPTION" ]]; then
  PROJECT_DESCRIPTION="A web application built on the base-web-app stack."
fi

echo ""
echo -e "${BOLD}── Repository & Hosting ─────────────────────────────────────────────${NC}"
echo ""

read -p "GitHub username or org (e.g. dannyboy2323): " GITHUB_USERNAME
GITHUB_USERNAME=${GITHUB_USERNAME:-dannyboy2323}

read -p "GitHub repo name (defaults to project name: $PROJECT_NAME): " GITHUB_REPO
GITHUB_REPO=${GITHUB_REPO:-$PROJECT_NAME}

read -p "Vercel team/username (e.g. cminc): " VERCEL_TEAM
VERCEL_TEAM=${VERCEL_TEAM:-cminc}

read -p "Production URL (e.g. https://cheatermonitor.com): " PRODUCTION_URL
if [[ -z "$PRODUCTION_URL" ]]; then
  PRODUCTION_URL="https://${PROJECT_NAME}.vercel.app"
  echo -e "  ${YELLOW}Using default: $PRODUCTION_URL${NC}"
fi

# Extract hostname from URL for use in text contexts
PRODUCTION_URL_HOST=$(echo "$PRODUCTION_URL" | sed 's|https://||' | sed 's|http://||' | sed 's|/$||')

read -p "From email address (e.g. noreply@cheatermonitor.com): " EMAIL_FROM_ADDRESS
if [[ -z "$EMAIL_FROM_ADDRESS" ]]; then
  EMAIL_FROM_ADDRESS="noreply@${PRODUCTION_URL_HOST}"
  echo -e "  ${YELLOW}Using default: $EMAIL_FROM_ADDRESS${NC}"
fi

echo ""
echo -e "${BOLD}── Sentry ───────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${YELLOW}Find these at sentry.io → Settings → Projects after creating your Sentry project.${NC}"
echo ""

read -p "Sentry org slug (e.g. my-company): " SENTRY_ORG
SENTRY_ORG=${SENTRY_ORG:-my-sentry-org}

read -p "Sentry project slug (e.g. my-project-sentry): " SENTRY_PROJECT
SENTRY_PROJECT=${SENTRY_PROJECT:-${PROJECT_NAME}-sentry}

# =============================================================================
# Confirmation
# =============================================================================

echo ""
echo -e "${BOLD}── Summary ──────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "  Project name:      ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Display name:      ${GREEN}$PROJECT_DISPLAY_NAME${NC}"
echo -e "  Description:       ${GREEN}$PROJECT_DESCRIPTION${NC}"
echo -e "  GitHub:            ${GREEN}github.com/$GITHUB_USERNAME/$GITHUB_REPO${NC}"
echo -e "  Vercel:            ${GREEN}vercel.com/$VERCEL_TEAM/$PROJECT_NAME${NC}"
echo -e "  Production URL:    ${GREEN}$PRODUCTION_URL${NC}"
echo -e "  Email from:        ${GREEN}$EMAIL_FROM_ADDRESS${NC}"
echo -e "  Sentry:            ${GREEN}$SENTRY_ORG / $SENTRY_PROJECT${NC}"
echo ""

read -p "Proceed with these values? (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo -e "${YELLOW}Cancelled. No changes were made.${NC}"
  exit 0
fi

# =============================================================================
# Replace placeholders
# =============================================================================

echo ""
echo -e "${BOLD}── Replacing placeholders ───────────────────────────────────────────${NC}"
echo ""

FILES=$(grep -rl "{{PROJECT_NAME}}\|{{PROJECT_DISPLAY_NAME}}\|{{PROJECT_DESCRIPTION}}\|{{GITHUB_USERNAME}}\|{{GITHUB_REPO}}\|{{VERCEL_TEAM}}\|{{PRODUCTION_URL}}\|{{PRODUCTION_URL_HOST}}\|{{EMAIL_FROM_ADDRESS}}\|{{SENTRY_ORG}}\|{{SENTRY_PROJECT}}" \
  --include="*.ts" \
  --include="*.tsx" \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.mjs" \
  --include="*.sh" \
  . 2>/dev/null | grep -v node_modules | grep -v package-lock.json)

if [[ -z "$FILES" ]]; then
  echo -e "${YELLOW}No placeholder files found — may have already been initialized.${NC}"
else
  echo "$FILES" | while read -r file; do
    sed -i '' \
      "s|{{PRODUCTION_URL_HOST}}|$PRODUCTION_URL_HOST|g; \
       s|{{PRODUCTION_URL}}|$PRODUCTION_URL|g; \
       s|{{GITHUB_USERNAME}}/{{GITHUB_REPO}}|$GITHUB_USERNAME/$GITHUB_REPO|g; \
       s|{{GITHUB_USERNAME}}|$GITHUB_USERNAME|g; \
       s|{{GITHUB_REPO}}|$GITHUB_REPO|g; \
       s|{{VERCEL_TEAM}}/{{PROJECT_NAME}}|$VERCEL_TEAM/$PROJECT_NAME|g; \
       s|{{VERCEL_TEAM}}|$VERCEL_TEAM|g; \
       s|{{PROJECT_DISPLAY_NAME}}|$PROJECT_DISPLAY_NAME|g; \
       s|{{PROJECT_DESCRIPTION}}|$PROJECT_DESCRIPTION|g; \
       s|{{PROJECT_NAME}}|$PROJECT_NAME|g; \
       s|{{EMAIL_FROM_ADDRESS}}|$EMAIL_FROM_ADDRESS|g; \
       s|{{SENTRY_ORG}}|$SENTRY_ORG|g; \
       s|{{SENTRY_PROJECT}}|$SENTRY_PROJECT|g" \
      "$file"
    echo -e "  ${GREEN}✓${NC} $file"
  done
fi

echo ""
echo -e "${BOLD}── Installing dependencies ──────────────────────────────────────────${NC}"
echo ""
npm install

# =============================================================================
# Post-setup checklist
# =============================================================================

echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   Setup complete! Next steps:            ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Required — do these before writing any code:${NC}"
echo ""
echo -e "  ${YELLOW}1.${NC} Create a Vercel project and link this repo:"
echo -e "     ${BLUE}vercel link${NC}"
echo ""
echo -e "  ${YELLOW}2.${NC} Connect integrations in the Vercel dashboard:"
echo -e "     vercel.com/${VERCEL_TEAM}/${PROJECT_NAME} → Storage/Integrations"
echo -e "     Connect: Neon, Upstash, Sanity, Clerk, Sentry, PostHog, Resend, Checkly, Inngest"
echo ""
echo -e "  ${YELLOW}3.${NC} Pull environment variables:"
echo -e "     ${BLUE}vercel env pull .env.local${NC}"
echo ""
echo -e "  ${YELLOW}4.${NC} Add sensitive vars manually to .env.local"
echo -e "     (Clerk keys, PostHog token, Resend API key, Sanity webhook secret)"
echo -e "     See .env.example for the complete list."
echo ""
echo -e "  ${YELLOW}5.${NC} Add GitHub repository secrets:"
echo -e "     github.com/${GITHUB_USERNAME}/${GITHUB_REPO} → Settings → Secrets → Actions"
echo -e "     Add: ANTHROPIC_API_KEY, NEXT_PUBLIC_SANITY_PROJECT_ID, SANITY_WEBHOOK_SECRET"
echo ""
echo -e "  ${YELLOW}6.${NC} Enable GitHub Actions to create PRs:"
echo -e "     github.com/${GITHUB_USERNAME}/${GITHUB_REPO} → Settings → Actions → General"
echo -e "     → Workflow permissions → Allow GitHub Actions to create PRs"
echo ""
echo -e "  ${YELLOW}7.${NC} Install Probot Settings app (if not already installed):"
echo -e "     ${BLUE}github.com/apps/settings${NC}"
echo ""
echo -e "  ${YELLOW}8.${NC} Push to main to apply Probot settings and trigger first deploy:"
echo -e "     ${BLUE}git add -A && git commit -m 'chore: initialize project from base-web-app template' && git push${NC}"
echo ""
echo -e "  ${YELLOW}9.${NC} Create Sanity project at sanity.io/manage"
echo -e "     Update NEXT_PUBLIC_SANITY_PROJECT_ID in Vercel and .env.local"
echo ""
echo -e "  ${YELLOW}10.${NC} Start dev server:"
echo -e "      ${BLUE}npm run dev${NC}"
echo ""
echo -e "${BOLD}Optional — recommended before first production deploy:${NC}"
echo ""
echo -e "  □ Create staging Vercel environment (vercel.com → ${PROJECT_NAME} → Settings → Environments)"
echo -e "  □ Create staging branch: ${BLUE}git checkout -b staging && git push -u origin staging${NC}"
echo -e "  □ Set up Checkly monitoring: ${BLUE}npx checkly deploy${NC}"
echo -e "  □ Push Drizzle schema to Neon: ${BLUE}npm run db:push${NC}"
echo -e "  □ Verify Sentry is receiving errors (trigger a test error in dev)"
echo ""
echo -e "${GREEN}Happy building! 🚀${NC}"
echo ""
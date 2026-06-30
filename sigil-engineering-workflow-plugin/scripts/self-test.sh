#!/usr/bin/env bash
# self-test.sh — Validate plugin integrity with 7 checks
# Exit code 0 = all pass
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
ERRORS=""

check() {
  local num="$1" desc="$2"
  shift 2
  if "$@"; then
    echo "CHECK $num: PASS — $desc"
    PASS=$((PASS + 1))
  else
    echo "CHECK $num: FAIL — $desc"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  CHECK $num failed: $desc"
  fi
}

check_file() { [ -f "$1" ]; }

echo "═══ sigil-engineering-workflow self-test ═══"
echo ""

# CHECK 1: All required files exist
check 1 "Required files exist" test -f "$PLUGIN_DIR/.claude-plugin/plugin.json" \
  -a -f "$PLUGIN_DIR/VERSION" \
  -a -f "$PLUGIN_DIR/scripts/version.sh" \
  -a -f "$PLUGIN_DIR/scripts/detect-secrets.sh" \
  -a -f "$PLUGIN_DIR/commands/help.md" \
  -a -f "$PLUGIN_DIR/commands/version.md"

# CHECK 2: All skill SKILL.md files exist
check 2 "All SKILL.md files exist" test -f "$PLUGIN_DIR/skills/plan-execute/SKILL.md" \
  -a -f "$PLUGIN_DIR/skills/test-doctor/SKILL.md" \
  -a -f "$PLUGIN_DIR/skills/safe-commit/SKILL.md" \
  -a -f "$PLUGIN_DIR/skills/review-apply/SKILL.md" \
  -a -f "$PLUGIN_DIR/skills/solution-ensemble/SKILL.md"

# CHECK 3: All AGENT.md files exist
check 3 "All AGENT.md files exist" test -f "$PLUGIN_DIR/agents/plan-executor/AGENT.md" \
  -a -f "$PLUGIN_DIR/agents/secret-scanner/AGENT.md"

# CHECK 4: No skill contains 'git add .'
check 4 "No skill uses 'git add .'" bash -c "
  ! grep -r 'git add \\.' '$PLUGIN_DIR/skills/' 2>/dev/null | grep -v 'NEVER\\|never\\|avoid\\|AVOID' | grep -q 'git add \\.'
"

# CHECK 5: plugin.json version matches VERSION
check 5 "plugin.json version matches VERSION" bash "$PLUGIN_DIR/scripts/version.sh" --plugin-json > /dev/null 2>&1

# CHECK 6: VERSION is valid semver
check 6 "VERSION is valid semver" bash "$PLUGIN_DIR/scripts/version.sh" --check > /dev/null 2>&1

# CHECK 7: detect-secrets.sh is executable and scripts are executable
check 7 "Scripts are executable" test -x "$PLUGIN_DIR/scripts/detect-secrets.sh" \
  -a -x "$PLUGIN_DIR/scripts/self-test.sh" \
  -a -x "$PLUGIN_DIR/scripts/version.sh"

echo ""
echo "═══ Results: $PASS passed, $FAIL failed ═══"
if [ $FAIL -gt 0 ]; then
  echo -e "$ERRORS"
  exit 1
fi

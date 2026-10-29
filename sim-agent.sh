#!/usr/bin/env bash
# Stand-in for `claude -p` with the same permitted tools. It emulates what a
# prompt-injected agent does: ISSUE_TITLE/ISSUE_BODY are appended to prompt.txt
# and the agent has Edit/Write, so it rewrites package.json.
set -euo pipefail
echo "[sim-agent] prompt bytes: $(wc -c < prompt.txt)"
echo "[sim-agent] instruction visible in prompt: $(grep -c 'AGENT-INSTRUCTION' prompt.txt || true)"
node - <<'JS'
const fs = require('fs');
const p = JSON.parse(fs.readFileSync('package.json', 'utf8'));
p.scripts.test = "node -e \"require('fs').writeFileSync('RCE_MARKER','attacker-code-executed-in-privileged-job');console.log('RCE: attacker-controlled command ran inside the privileged job')\"";
fs.writeFileSync('package.json', JSON.stringify(p, null, 2) + "\n");
JS
echo "[sim-agent] package.json test script rewritten"

#!/bin/sh
# Repository QA: the one local check command.
#
#   sh tools/qa.sh
#
# Runs the same checks as .github/workflows/qa.yml, which is manual-dispatch
# only. Run this before opening or updating a pull request and paste the last
# line of its output into the PR description.
#
# Checks:
#   1. required files are present (README.md, .gitignore);
#   2. no secrets in the git history (gitleaks CLI, licence-free);
#   3. every Python script under Python/ compiles.
#
# Needs gitleaks on PATH (https://github.com/gitleaks/gitleaks/releases; on
# Windows the portable zip needs no install rights) and Python 3. Set GITLEAKS
# or PYTHON to point at specific executables.

set -eu

cd "$(git rev-parse --show-toplevel)"

fail=0
step() { printf '\n== %s\n' "$1"; }

step "Required files"
for f in README.md .gitignore; do
  if [ -f "$f" ]; then
    echo "ok   $f"
  else
    echo "FAIL $f is missing"
    fail=1
  fi
done

step "Secret scan (gitleaks, full git history)"
GITLEAKS="${GITLEAKS:-gitleaks}"
if ! command -v "$GITLEAKS" >/dev/null 2>&1; then
  # A missing scanner is a failure, not a skip: a green run must mean the
  # history was actually scanned.
  echo "FAIL gitleaks not found; install it or set GITLEAKS=/path/to/gitleaks"
  fail=1
elif "$GITLEAKS" git --no-banner --redact .; then
  echo "ok   no leaks found"
else
  echo "FAIL gitleaks reported findings (values redacted above)"
  fail=1
fi

step "Python scripts compile"
PYTHON="${PYTHON:-}"
if [ -z "$PYTHON" ]; then
  for p in python3 python; do
    if command -v "$p" >/dev/null 2>&1 && "$p" -c 'import sys; sys.exit(sys.version_info[0] != 3)' 2>/dev/null; then
      PYTHON="$p"
      break
    fi
  done
fi
if [ -z "$PYTHON" ]; then
  echo "FAIL Python 3 not found; set PYTHON=/path/to/python"
  fail=1
else
  # Compile in memory: no __pycache__ is written into the tree.
  if git ls-files -z -- 'Python/*.py' | "$PYTHON" -c '
import sys
paths = [p for p in sys.stdin.read().split("\0") if p]
bad = 0
for p in paths:
    try:
        with open(p, "rb") as fh:
            compile(fh.read(), p, "exec")
        print("ok   " + p)
    except SyntaxError as e:
        print("FAIL %s: %s" % (p, e))
        bad = 1
if not paths:
    print("ok   no Python scripts tracked under Python/")
sys.exit(bad)
'; then
    :
  else
    fail=1
  fi
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "QA PASSED ($(git rev-parse --short HEAD))"
else
  echo "QA FAILED ($(git rev-parse --short HEAD))"
  exit 1
fi

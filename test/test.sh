#!/bin/bash

TEST_DIR="$(realpath "$(dirname "$0")")"
export GRADE_PATH="$TEST_DIR/grade-path"
export PATH="$TEST_DIR/../bin:$PATH"

FAILURES=()

grade_hook() {
    local HOOK="$1"

    echo "TESTING ${HOOK^^} HOOK"
    local TOTAL="$(grade "$HOOK" hook |& tee /dev/tty | sed 's/\x1b\[[0-9;]*m//g' | awk -F: '/TOTAL:/ {print $2}')"
    echo; echo; echo

    [[ "$(bc <<< "$TOTAL")" -eq 1 ]] || FAILURES+=("$HOOK")
}

grade_hook bash
grade_hook julia
grade_hook python

[[ "${#FAILURES[@]}" -eq 0 ]] && echo SUCCESS || echo "FAILED: ${FAILURES[@]}"
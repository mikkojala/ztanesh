#!/bin/zsh
# Ztanesh Panel System Test Suite
# Basic smoke tests to validate panel system functionality

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="${0:A:h}"
PROJECT_ROOT="${SCRIPT_DIR}/.."
PANELS_DIR="${PROJECT_ROOT}/zsh-scripts/panels"
LIB_DIR="${PROJECT_ROOT}/zsh-scripts/lib"
BIN_DIR="${PROJECT_ROOT}/zsh-scripts/bin"
CONFIG_DIR="${PROJECT_ROOT}/zsh-scripts/config"

# Test result helpers
function pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

function fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

function section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Test 1: Check directory structure
section "Directory Structure Tests"

if [[ -d "$PANELS_DIR" ]]; then
    pass "Panels directory exists"
else
    fail "Panels directory missing: $PANELS_DIR"
fi

if [[ -d "$LIB_DIR" ]]; then
    pass "Lib directory exists"
else
    fail "Lib directory missing: $LIB_DIR"
fi

if [[ -d "$BIN_DIR" ]]; then
    pass "Bin directory exists"
else
    fail "Bin directory missing: $BIN_DIR"
fi

# Test 2: Check core files exist
section "Core File Existence Tests"

if [[ -f "$LIB_DIR/prompt-panels.zsh" ]]; then
    pass "Core library file exists"
else
    fail "Core library file missing: $LIB_DIR/prompt-panels.zsh"
fi

if [[ -f "$BIN_DIR/ztanesh-panels" ]]; then
    pass "CLI tool file exists"
else
    fail "CLI tool file missing: $BIN_DIR/ztanesh-panels"
fi

if [[ -x "$BIN_DIR/ztanesh-panels" ]]; then
    pass "CLI tool is executable"
else
    fail "CLI tool is not executable: $BIN_DIR/ztanesh-panels"
fi

# Test 3: Syntax validation
section "Syntax Validation Tests"

# Check core library syntax
if zsh -n "$LIB_DIR/prompt-panels.zsh" 2>/dev/null; then
    pass "Core library has valid syntax"
else
    fail "Core library has syntax errors"
fi

# Check CLI tool syntax
if zsh -n "$BIN_DIR/ztanesh-panels" 2>/dev/null; then
    pass "CLI tool has valid syntax"
else
    fail "CLI tool has syntax errors"
fi

# Test 4: Panel files validation
section "Panel Files Tests"

EXPECTED_PANELS=(aws virtualenv server-status extra-prompt)
FOUND_PANELS=()

for panel_file in "$PANELS_DIR"/*.zsh; do
    if [[ -f "$panel_file" ]]; then
        panel_name=$(basename "$panel_file" .zsh)
        FOUND_PANELS+=("$panel_name")

        # Check syntax
        if zsh -n "$panel_file" 2>/dev/null; then
            pass "Panel '$panel_name' has valid syntax"
        else
            fail "Panel '$panel_name' has syntax errors"
        fi

        # Check for required function
        function_name="setup_${panel_name//-/_}_panel"
        if grep -q "function $function_name" "$panel_file" || grep -q "^$function_name()" "$panel_file"; then
            pass "Panel '$panel_name' defines required function: $function_name"
        else
            fail "Panel '$panel_name' missing function: $function_name"
        fi
    fi
done

# Verify all expected panels exist
for expected in "${EXPECTED_PANELS[@]}"; do
    if [[ " ${FOUND_PANELS[*]} " =~ " ${expected} " ]]; then
        pass "Expected panel found: $expected"
    else
        fail "Expected panel missing: $expected"
    fi
done

# Test 5: Core library functionality
section "Core Library Functionality Tests"

# Source the library in a subshell to test it loads
if (source "$LIB_DIR/prompt-panels.zsh" 2>/dev/null); then
    pass "Core library sources without errors"
else
    fail "Core library fails to source"
fi

# Check that key functions are defined after sourcing
(
    source "$LIB_DIR/prompt-panels.zsh" 2>/dev/null

    if typeset -f init_prompt_panels > /dev/null; then
        echo "PASS: init_prompt_panels function defined"
    else
        echo "FAIL: init_prompt_panels function not defined"
    fi

    if typeset -f setup_prompt_panels > /dev/null; then
        echo "PASS: setup_prompt_panels function defined"
    else
        echo "FAIL: setup_prompt_panels function not defined"
    fi

    if typeset -f list_available_panels > /dev/null; then
        echo "PASS: list_available_panels function defined"
    else
        echo "FAIL: list_available_panels function not defined"
    fi
) | while read result; do
    if [[ "$result" =~ ^PASS ]]; then
        pass "${result#PASS: }"
    else
        fail "${result#FAIL: }"
    fi
done

# Test 6: Configuration file
section "Configuration Tests"

if [[ -f "$CONFIG_DIR/panel-config.zsh" ]]; then
    pass "Configuration file exists"

    # Check syntax
    if zsh -n "$CONFIG_DIR/panel-config.zsh" 2>/dev/null; then
        pass "Configuration file has valid syntax"
    else
        fail "Configuration file has syntax errors"
    fi

    # Check that it defines the array
    if grep -q "ZTANESH_ENABLED_PANELS" "$CONFIG_DIR/panel-config.zsh"; then
        pass "Configuration defines ZTANESH_ENABLED_PANELS"
    else
        fail "Configuration missing ZTANESH_ENABLED_PANELS"
    fi
else
    fail "Configuration file missing: $CONFIG_DIR/panel-config.zsh"
fi

# Test 7: CLI tool functions
section "CLI Tool Function Tests"

# Check that CLI tool defines required functions
CLI_FUNCTIONS=(usage list_panels show_status enable_panel disable_panel update_config_array edit_config)

for func in "${CLI_FUNCTIONS[@]}"; do
    if grep -q "function $func" "$BIN_DIR/ztanesh-panels" || grep -q "^$func()" "$BIN_DIR/ztanesh-panels"; then
        pass "CLI tool defines function: $func"
    else
        fail "CLI tool missing function: $func"
    fi
done

# Test 8: Panel naming convention
section "Panel Naming Convention Tests"

for panel_file in "$PANELS_DIR"/*.zsh; do
    if [[ -f "$panel_file" ]]; then
        panel_name=$(basename "$panel_file" .zsh)
        expected_func="setup_${panel_name//-/_}_panel"

        # Read the file and check the function name matches
        if grep -q "function $expected_func\|^$expected_func()" "$panel_file"; then
            pass "Panel '$panel_name' follows naming convention"
        else
            # Try to find what function it actually defines
            actual_func=$(grep -o "function setup_.*_panel\|^setup_.*_panel()" "$panel_file" | head -1)
            if [[ -n "$actual_func" ]]; then
                fail "Panel '$panel_name' function name mismatch (found: $actual_func, expected: $expected_func)"
            else
                fail "Panel '$panel_name' does not follow naming convention"
            fi
        fi
    fi
done

# Summary
section "Test Summary"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed.${NC}"
    exit 1
fi

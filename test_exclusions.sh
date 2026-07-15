#!/usr/bin/env bash

# Test script for directory exclusion system
# Validates that .repodnaignore patterns are correctly applied

set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_PASS=0
TEST_FAIL=0

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper function
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_result="$3"
    
    echo -n "Testing: $test_name... "
    
    local result
    if result="$(eval "$test_cmd" 2>&1)"; then
        if [[ "$result" == "$expected_result" ]]; then
            echo -e "${GREEN}PASS${NC}"
            ((TEST_PASS++))
        else
            echo -e "${RED}FAIL${NC}"
            echo "  Expected: $expected_result"
            echo "  Got: $result"
            ((TEST_FAIL++))
        fi
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: $result"
        ((TEST_FAIL++))
    fi
}

echo "================================================"
echo "Directory Exclusion System Tests"
echo "================================================"
echo ""

# Source the script functions
cd "$SCRIPT_DIR"
source lib/project-detection.sh

# Test 1: Check that .repodnaignore exists
echo "Test Set 1: File Existence"
echo ""
if [[ -f .repodnaignore ]]; then
    echo -e "${GREEN}✓${NC} .repodnaignore file exists"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} .repodnaignore file not found"
    ((TEST_FAIL++))
fi

echo ""
echo "Test Set 2: .repodnaignore Content"
echo ""

# Test 2: Check that common patterns are in .repodnaignore
if grep -q "^Library/" .repodnaignore; then
    echo -e "${GREEN}✓${NC} Library/ exclusion found"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} Library/ exclusion not found"
    ((TEST_FAIL++))
fi

if grep -q "^Plugins/" .repodnaignore; then
    echo -e "${GREEN}✓${NC} Plugins/ exclusion found"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} Plugins/ exclusion not found"
    ((TEST_FAIL++))
fi

if grep -q "^Generated/" .repodnaignore; then
    echo -e "${GREEN}✓${NC} Generated/ exclusion found"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} Generated/ exclusion not found"
    ((TEST_FAIL++))
fi

# Test 3: Syntax validation
echo ""
echo "Test Set 3: Script Syntax"
echo ""

if bash -n dna-analysis.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} dna-analysis.sh syntax is valid"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} dna-analysis.sh has syntax errors"
    ((TEST_FAIL++))
fi

if bash -n lib/project-detection.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} project-detection.sh syntax is valid"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} project-detection.sh has syntax errors"
    ((TEST_FAIL++))
fi

# Test 4: Documentation exists
echo ""
echo "Test Set 4: Documentation"
echo ""

if [[ -f EXCLUSIONS.md ]]; then
    echo -e "${GREEN}✓${NC} EXCLUSIONS.md exists"
    ((TEST_PASS++))
else
    echo -e "${RED}✗${NC} EXCLUSIONS.md not found"
    ((TEST_FAIL++))
fi

if [[ -f README.md ]]; then
    if grep -q "\.repodnaignore" README.md; then
        echo -e "${GREEN}✓${NC} README.md mentions .repodnaignore"
        ((TEST_PASS++))
    else
        echo -e "${RED}✗${NC} README.md does not mention .repodnaignore"
        ((TEST_FAIL++))
    fi
fi

# Summary
echo ""
echo "================================================"
echo "Test Summary"
echo "================================================"
echo -e "${GREEN}Passed: $TEST_PASS${NC}"
echo -e "${RED}Failed: $TEST_FAIL${NC}"
echo ""

if [[ $TEST_FAIL -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi

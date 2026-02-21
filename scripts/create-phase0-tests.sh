#!/bin/bash
# Create all Phase 0 validation tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📦 Creating Phase 0 Validation Test Suite"
echo "=========================================="
echo ""

# Make phase0-validation.sh executable
chmod +x "$SCRIPT_DIR/phase0-validation.sh"
echo "✅ phase0-validation.sh is executable"

# Create manual testing guide
cat > "$PROJECT_ROOT/PHASE0-MANUAL-TESTS.md" << 'EOF'
# Phase 0 Manual Testing Guide

After running `bash scripts/phase0-validation.sh`, perform these manual tests:

## Test 1: Invoke Test Agent

```bash
# In Kiro, invoke the test agent
@test-agent "Hello, are you working?"
```

**Expected Result:**
- Agent responds
- Response includes "TEST AGENT ACTIVE"
- No errors in Kiro

**If it works:** ✅ Kiro can load modified agents

**If it fails:** ❌ Kiro may cache agents or not support dynamic loading

---

## Test 2: Verify Dynamic Content

Check if the test agent file contains:

```bash
cat .kiro/steering/agents/test-agent.md | grep "DYNAMIC_CONTENT"
```

**Expected Result:**
- Shows `<!-- DYNAMIC_CONTENT_START -->`
- Shows `#[[file:...]]` injection
- Shows `<!-- DYNAMIC_CONTENT_END -->`

**If present:** ✅ File modification works

---

## Test 3: Modify and Re-invoke

1. Add a new line to test-agent.md:
```bash
echo "<!-- MODIFIED AT $(date) -->" >> .kiro/steering/agents/test-agent.md
```

2. Invoke again:
```bash
@test-agent "Did you see the modification?"
```

**Expected Result:**
- Agent still responds
- No errors

**If it works:** ✅ Kiro handles file changes gracefully

**If it fails:** ❌ Kiro may need restart after changes

---

## Test 4: Check Performance

Time how long it takes to invoke the agent:

```bash
time @test-agent "performance test"
```

**Expected Result:**
- Response time < 5 seconds
- No noticeable delay from file modifications

**If fast:** ✅ Performance acceptable

**If slow:** ⚠️ May need optimization

---

## Decision Matrix

| Test 1 | Test 2 | Test 3 | Test 4 | Verdict |
|--------|--------|--------|--------|---------|
| ✅ | ✅ | ✅ | ✅ | **GO** - Proceed with implementation |
| ✅ | ✅ | ✅ | ⚠️ | **CONDITIONAL GO** - Optimize first |
| ✅ | ✅ | ❌ | - | **NO-GO** - Kiro caches agents |
| ✅ | ❌ | - | - | **NO-GO** - File modification failed |
| ❌ | - | - | - | **NO-GO** - Agent loading failed |

---

## If NO-GO: Use Prompt-Based Injection

See `RISK-MITIGATION-PLAN.md` section "Alternativa Segura: Prompt-Based Injection"

This approach:
- Doesn't modify agent files
- Constructs prompts dynamically in AgentX
- Achieves same token savings
- More reliable

---

## Cleanup After Testing

```bash
# Remove test agent
rm .kiro/steering/agents/test-agent.md

# Verify system still works
bash scripts/verify-system.sh
```

---

**Next Steps:**
1. Complete all manual tests
2. Document results
3. Make GO/NO-GO decision
4. If GO: Proceed to backup and Phase 1
5. If NO-GO: Implement Prompt-Based Injection alternative
EOF

echo "✅ PHASE0-MANUAL-TESTS.md created"

# Create results template
cat > "$PROJECT_ROOT/PHASE0-RESULTS.md" << 'EOF'
# Phase 0 Validation Results

**Date:** $(date +%Y-%m-%d)
**Tester:** [Your Name]

---

## Automated Tests

```bash
bash scripts/phase0-validation.sh
```

**Result:** [ ] PASS / [ ] FAIL / [ ] CONDITIONAL

**Output:**
```
[Paste output here]
```

---

## Manual Tests

### Test 1: Invoke Test Agent
- [ ] PASS
- [ ] FAIL

**Notes:**
```
[Your observations]
```

### Test 2: Verify Dynamic Content
- [ ] PASS
- [ ] FAIL

**Notes:**
```
[Your observations]
```

### Test 3: Modify and Re-invoke
- [ ] PASS
- [ ] FAIL

**Notes:**
```
[Your observations]
```

### Test 4: Check Performance
- [ ] PASS
- [ ] FAIL

**Response time:** ___ seconds

**Notes:**
```
[Your observations]
```

---

## Final Verdict

- [ ] ✅ GO - All tests passed, proceed with implementation
- [ ] ⚠️ CONDITIONAL GO - Some issues, review before proceeding
- [ ] ❌ NO-GO - Critical failures, use Prompt-Based Injection alternative

---

## Reasoning

```
[Explain your decision]
```

---

## Next Actions

```
[What to do next based on verdict]
```

---

## Issues Encountered

```
[List any problems or unexpected behavior]
```
EOF

echo "✅ PHASE0-RESULTS.md template created"

# Create quick start script
cat > "$SCRIPT_DIR/run-phase0.sh" << 'EOF'
#!/bin/bash
# Quick start for Phase 0 validation

echo "🚀 Starting Phase 0 Validation"
echo ""

# Run automated tests
bash scripts/phase0-validation.sh

EXIT_CODE=$?

echo ""
echo "========================================"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Automated tests PASSED"
    echo ""
    echo "📋 Next: Complete manual tests"
    echo "   See: PHASE0-MANUAL-TESTS.md"
    echo ""
    echo "📝 Document results in: PHASE0-RESULTS.md"
elif [ $EXIT_CODE -eq 2 ]; then
    echo "⚠️  Automated tests CONDITIONAL"
    echo ""
    echo "Review failures and decide if acceptable"
    echo ""
    echo "📋 Next: Complete manual tests"
    echo "   See: PHASE0-MANUAL-TESTS.md"
else
    echo "❌ Automated tests FAILED"
    echo ""
    echo "❌ VERDICT: NO-GO"
    echo ""
    echo "Recommended: Use Prompt-Based Injection alternative"
    echo "See: RISK-MITIGATION-PLAN.md"
fi

echo ""
EOF

chmod +x "$SCRIPT_DIR/run-phase0.sh"
echo "✅ run-phase0.sh created and executable"

echo ""
echo "========================================"
echo "✅ Phase 0 Test Suite Created"
echo "========================================"
echo ""
echo "📁 Files created:"
echo "   - scripts/phase0-validation.sh (automated tests)"
echo "   - scripts/run-phase0.sh (quick start)"
echo "   - PHASE0-MANUAL-TESTS.md (manual testing guide)"
echo "   - PHASE0-RESULTS.md (results template)"
echo ""
echo "🚀 To start validation:"
echo "   bash scripts/run-phase0.sh"
echo ""
echo "📖 Then follow:"
echo "   PHASE0-MANUAL-TESTS.md"
echo ""

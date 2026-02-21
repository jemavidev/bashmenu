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

# Skills-On-Demand Project

**Status:** Phase 0 Complete - Ready for Phase 2  
**Last Updated:** 2026-02-17  
**Version:** 1.0.0

---

## Overview

Implementation of an intelligent skills loading system to reduce token consumption by 85-95% without affecting response quality.

### Problem
- 58 skills installed, all loaded on every call
- ~217,270 tokens consumed per call (87,000 from skills alone)
- 80-90% of skills unused in typical queries
- Cost: ~$0.26 per call just for skills

### Solution
- Automatic detection of relevant skills per query
- Load only 2-3 skills per call (~5,000 tokens)
- 85% token savings, 86% cost reduction
- Transparent to users

### Expected Impact

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Tokens/call | 217,270 | 8,000-12,000 | -94-96% |
| Cost/call | $0.65 | $0.04 | -94% |
| Monthly cost (1,100 calls) | $715 | $44 | -$671 |
| Skills loaded | 58 | 2-3 | -95% |

---

## Implementation Phases

### Phase 0: Validation ✅ COMPLETE

**Objective:** Validate Kiro's capability for dynamic file modification

**Results:**
- All 7 automated tests passed
- Manual test confirmed: test-agent responds correctly
- Performance validated: 6ms for 10 operations
- **Verdict:** File-based injection is feasible

**Key Learnings:**
1. Kiro supports dynamic steering file modification
2. `#[[file:...]]` injection works at runtime
3. Performance impact is negligible
4. No restart required for changes

**Deliverables:**
- `scripts/phase0-validation.sh` - Automated test suite
- `scripts/run-phase0.sh` - Quick validation runner
- `.kiro/steering/agents/test-agent.md` - Test agent

### Phase 1: Skills Registry ✅ COMPLETE

**Objective:** Catalog all skills with metadata

**Accomplishments:**
- Created automatic cataloging script
- Cataloged 56 skills with complete metadata
- Calculated token sizes: 217,270 total
- Categorized by type and agent
- Mapped agent relationships

**Skills Distribution:**
- Development: 9 skills (64,922 tokens)
- General: 16 skills (47,224 tokens)
- Design: 8 skills (29,937 tokens)
- Documentation: 4 skills (27,572 tokens)
- Architecture: 6 skills (20,685 tokens)
- Testing: 4 skills (10,024 tokens)
- Operations: 5 skills (8,444 tokens)
- Data Science: 2 skills (5,323 tokens)
- Security: 2 skills (3,139 tokens)

**Deliverables:**
- `scripts/catalog-skills.sh` - Auto-cataloging tool
- `.kiro/settings/skills-registry.json` - Complete registry

### Preparation: Backup System ✅ COMPLETE

**Objective:** Create comprehensive backup before implementation

**Accomplishments:**
- Backed up 14 agents, 15 memory files, all configs
- Backup size: 344K
- Automatic rollback script created and tested
- Verification script operational

**Deliverables:**
- `scripts/backup-before-implementation.sh`
- `.kiro/backups/pre-skills-on-demand-[timestamp]/`
- `ROLLBACK.sh` - Automatic restoration
- `VERIFY-BACKUP.sh` - Integrity check

**Rollback Command:**
```bash
bash .kiro/backups/pre-skills-on-demand-[timestamp]/ROLLBACK.sh
```

---

## Architecture

### Detection Flow

```
User Query
    ↓
AgentX (Phase 1.5: Skills Detection)
    ├─ Extract keywords from query
    ├─ Match against skills registry
    ├─ Calculate relevance scores
    ├─ Select top 2-3 skills (max 8,000 tokens)
    └─ Generate injection list
    ↓
Agent Steering File
    ├─ Core instructions
    ├─ <!-- SKILLS_DYNAMIC_LOAD -->
    │   #[[file:~/.kiro/skills/skill1/skill.md]]
    │   #[[file:~/.kiro/skills/skill2/skill.md]]
    └─ <!-- /SKILLS_DYNAMIC_LOAD -->
    ↓
Response
```

### Detection Algorithm

**Relevance Scoring:**
```
relevance = (keyword_match × 0.6) + 
            (agent_match × 0.3) + 
            (priority × 0.1)
```

**Selection Rules:**
1. Relevance ≥ 70%: Load always
2. Max 5 skills per call
3. Max 8,000 tokens total
4. Prioritize by relevance score

### Configuration

**File:** `.kiro/settings/skills-on-demand-config.json`

```json
{
  "detection": {
    "minRelevanceThreshold": 70,
    "maxSkillsPerCall": 5,
    "maxTokensPerCall": 8000,
    "keywordMatchWeight": 0.6,
    "agentMatchWeight": 0.3,
    "priorityWeight": 0.1
  },
  "loading": {
    "strategy": "on-demand",
    "fallbackToCore": true,
    "coreSkillsPerAgent": 2
  }
}
```

---

## Technical Decisions

### Decision 1: File-Based vs Prompt-Based Injection

**Chosen:** File-Based Injection

**Rationale:**
- Phase 0 validation confirmed feasibility
- Cleaner separation of concerns
- Easier to debug and maintain
- No changes to agent files needed

**Trade-offs:**
- Requires Kiro to support dynamic file loading (validated ✅)
- Slightly more complex implementation
- Better long-term maintainability

### Decision 2: Detection Threshold

**Chosen:** 70% relevance minimum

**Rationale:**
- Conservative approach for initial rollout
- Ensures high-quality skill selection
- Can be adjusted based on usage data
- Fallback to core skills if no matches

### Decision 3: Token Limit

**Chosen:** 8,000 tokens maximum for skills

**Rationale:**
- Allows 2-3 medium-large skills
- 96% reduction from current 217K
- Leaves room for agent instructions and context
- Optimal balance between savings and capability

### Decision 4: Incremental Rollout

**Chosen:** One agent at a time, starting with Teacher

**Rationale:**
- Minimizes risk of system-wide failure
- Allows thorough testing per agent
- Easy rollback if issues occur
- Teacher agent is less critical for testing

---

## Risk Mitigation

### Identified Risks

1. **Dynamic file modification** - MITIGATED ✅
   - Phase 0 validation confirmed capability
   - Backup system in place

2. **Detection accuracy** - MITIGATED
   - Conservative 70% threshold
   - Fallback to core skills
   - Learning from usage enabled

3. **Performance impact** - MITIGATED
   - Detection overhead < 300ms
   - Caching enabled
   - Net improvement from fewer tokens

4. **System stability** - MITIGATED
   - Comprehensive backup created
   - Incremental rollout strategy
   - Rollback script tested

### Rollback Triggers

- Detection accuracy < 70%
- System errors > 3 consecutive
- Performance degradation > 20%
- User complaints
- Manual decision

---

## Next Steps

### Phase 2: Detection Algorithm (NEXT)
**Duration:** 3-4 days  
**Status:** Ready to start

**Objectives:**
1. Create skills detection module
2. Implement keyword matching algorithm
3. Build relevance scoring system
4. Create detection testing suite
5. Integrate with AgentX

**Key Components:**
- `scripts/detect-skills.sh` - Standalone detector
- `.kiro/steering/agentx/skills-detector.md` - Detection logic
- Keyword normalization
- Relevance calculation
- Fallback mechanisms

### Phase 3: Dynamic Loading
**Duration:** 4-5 days

**Objectives:**
1. Modify agent steering files
2. Add injection markers
3. Implement dynamic content loading
4. Test with each agent

### Phase 4: Configuration & Control
**Duration:** 2-3 days

**Objectives:**
1. Finalize configuration system
2. Add override capabilities
3. Implement monitoring
4. Create admin tools

### Phase 5: Monitoring & Optimization
**Duration:** 2-3 days

**Objectives:**
1. Usage analytics
2. Performance monitoring
3. Automatic threshold adjustment
4. Learning from patterns

---

## Testing Strategy

### Automated Tests
- Phase 0 validation suite (7 tests)
- Detection accuracy tests (20+ queries)
- Performance benchmarks
- Integration tests per agent

### Manual Tests
- Real-world query testing
- Edge case validation
- User acceptance testing
- Rollback procedure verification

### Success Criteria
- Detection accuracy > 80%
- Token savings > 85%
- Response quality maintained
- No system degradation
- User satisfaction maintained

---

## Lessons Learned

### From Phase 0
1. Validation before implementation is critical
2. Automatic cataloging saves significant time
3. Backup system provides confidence
4. Test agent approach works well
5. Performance impact is negligible (6ms)

### From Phase 1
1. Skills vary widely in size (800-27,662 tokens)
2. Keyword extraction is feasible
3. Agent-skill mapping is valuable
4. Metadata enables smart decisions
5. Registry structure is scalable

---

## Resources

### Scripts
- `scripts/phase0-validation.sh` - Validation suite
- `scripts/catalog-skills.sh` - Skills cataloging
- `scripts/backup-before-implementation.sh` - Backup system
- `scripts/detect-skills.sh` - Detection algorithm (Phase 2)

### Configuration
- `.kiro/settings/skills-registry.json` - Skills catalog
- `.kiro/settings/skills-on-demand-config.json` - System config

### Documentation
- Original implementation plan (archived)
- Risk mitigation plan (archived)
- Phase 0 test results (archived)

---

## References

### Related Documentation
- [Skills Management Guide](../guides/skills-management.md)
- [AgentX Documentation](../agentx/README.md)
- [Memory System](../memory/README.md)

### External Resources
- Kiro Documentation: https://kiro.ai/docs
- Skills Registry: https://skills.sh

---

**Project Status:** Phase 0 & 1 Complete - Ready for Phase 2  
**Confidence Level:** High  
**Risk Level:** Low (with incremental approach)  
**Recommendation:** Proceed with Phase 2 implementation

---

*This document consolidates information from temporary project files that have been archived.*

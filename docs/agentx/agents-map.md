# 🗺️ AgentX - Agents Map Documentation

## 📋 Overview

The `agents-map.json` file is the **central registry** of all specialized agents in the BetterAgentX ecosystem. AgentX uses this file to:

1. **Route queries** to the appropriate agent based on keywords
2. **Understand agent capabilities** and expertise areas
3. **Make intelligent decisions** about which agent(s) to involve

## 📍 Location

```
.kiro/steering/agentx/agents-map.json
```

## 🏗️ Structure

```json
{
  "agents": {
    "agent-name": {
      "type": "core | specialized",
      "keywords": ["keyword1", "keyword2", ...],
      "description": "Brief description",
      "expertise": ["area1", "area2", ...]
    }
  }
}
```

## 📊 Agent Types

### Core Agents (7)
Essential agents for most development workflows:
- **architect** - System design and architecture
- **coder** - Implementation and coding
- **critic** - Critical analysis and risk assessment
- **tester** - Testing and quality assurance
- **writer** - Technical documentation
- **teacher** - Concept explanation and tutorials
- **researcher** - Technology research and analysis

### Specialized Agents (5)
Domain-specific experts:
- **security** - Security auditing and OWASP compliance
- **ux-designer** - UI/UX design and accessibility
- **product-manager** - Product strategy and user stories
- **devops** - CI/CD, infrastructure, and deployment
- **data-scientist** - Data analysis and machine learning

## 🔍 How AgentX Uses This File

### 1. Keyword Matching

When you ask a question, AgentX:
1. Extracts keywords from your query
2. Matches them against agent keywords
3. Calculates relevance scores
4. Routes to the best-matching agent(s)

**Example:**
```
User: "Design a microservices architecture"
Keywords detected: ["design", "microservices", "architecture"]
Best match: architect (keywords: ["design", "architecture", "microservices"])
```

### 2. Multi-Agent Workflows

For complex queries, AgentX may involve multiple agents:

```
User: "Build a secure authentication system"
Keywords: ["build", "secure", "authentication", "system"]
Agents involved:
  1. architect (design the system)
  2. security (security review)
  3. coder (implementation)
  4. tester (test cases)
```

### 3. Expertise Validation

AgentX checks expertise areas to ensure the agent can handle the task:

```json
"security": {
  "expertise": [
    "OWASP Top 10",
    "authentication",
    "authorization",
    "cryptography",
    "security auditing"
  ]
}
```

## 📝 Complete Agent Definitions

### Architect
```json
"architect": {
  "type": "core",
  "keywords": [
    "design", "architecture", "system", "scalability",
    "patterns", "structure", "microservices", "monolith"
  ],
  "description": "System design, architecture patterns, technical planning",
  "expertise": [
    "SOLID principles",
    "design patterns",
    "cloud architecture",
    "scalability",
    "trade-off analysis"
  ]
}
```

### Coder
```json
"coder": {
  "type": "core",
  "keywords": [
    "implement", "code", "function", "class", "refactor",
    "debug", "fix", "optimize", "algorithm"
  ],
  "description": "Implementation, clean code, refactoring, debugging",
  "expertise": [
    "clean code",
    "SOLID",
    "design patterns",
    "debugging",
    "performance optimization"
  ]
}
```

### Critic
```json
"critic": {
  "type": "core",
  "keywords": [
    "review", "critique", "risks", "problems", "concerns",
    "validate", "challenge", "assumptions"
  ],
  "description": "Critical analysis, risk assessment, tenth-man rule",
  "expertise": [
    "critical thinking",
    "risk assessment",
    "pre-mortem analysis",
    "assumption validation"
  ]
}
```

### Security
```json
"security": {
  "type": "specialized",
  "keywords": [
    "security", "vulnerability", "authentication",
    "authorization", "encryption", "OWASP", "audit"
  ],
  "description": "Security auditing, OWASP, vulnerability assessment",
  "expertise": [
    "OWASP Top 10",
    "authentication",
    "authorization",
    "cryptography",
    "security auditing"
  ]
}
```

### Tester
```json
"tester": {
  "type": "core",
  "keywords": [
    "test", "testing", "QA", "coverage", "edge cases",
    "validation", "unit test", "integration"
  ],
  "description": "Test strategy, TDD, quality assurance",
  "expertise": [
    "TDD",
    "unit testing",
    "integration testing",
    "E2E testing",
    "test coverage"
  ]
}
```

### UX-Designer
```json
"ux-designer": {
  "type": "specialized",
  "keywords": [
    "design", "UI", "UX", "interface", "user experience",
    "accessibility", "WCAG", "responsive"
  ],
  "description": "UI/UX design, accessibility, user experience",
  "expertise": [
    "UX laws",
    "accessibility (WCAG)",
    "responsive design",
    "design systems"
  ]
}
```

### Writer
```json
"writer": {
  "type": "core",
  "keywords": [
    "document", "documentation", "README", "tutorial",
    "guide", "explain", "API docs"
  ],
  "description": "Technical documentation, API docs, tutorials",
  "expertise": [
    "technical writing",
    "API documentation",
    "tutorials",
    "README files",
    "changelogs"
  ]
}
```

### Teacher
```json
"teacher": {
  "type": "core",
  "keywords": [
    "explain", "teach", "learn", "understand",
    "how does", "what is", "tutorial", "concept"
  ],
  "description": "Concept explanation, learning paths, tutorials",
  "expertise": [
    "concept explanation",
    "analogies",
    "progressive learning",
    "practice exercises"
  ]
}
```

### Product-Manager
```json
"product-manager": {
  "type": "specialized",
  "keywords": [
    "feature", "user story", "roadmap", "priority",
    "requirements", "stakeholder", "MVP"
  ],
  "description": "Product strategy, user stories, prioritization",
  "expertise": [
    "user stories",
    "RICE prioritization",
    "product roadmaps",
    "KPIs",
    "stakeholder management"
  ]
}
```

### DevOps
```json
"devops": {
  "type": "specialized",
  "keywords": [
    "deploy", "CI/CD", "docker", "kubernetes",
    "infrastructure", "pipeline", "cloud", "monitoring"
  ],
  "description": "CI/CD, infrastructure, deployment, monitoring",
  "expertise": [
    "CI/CD",
    "Docker",
    "Kubernetes",
    "cloud platforms",
    "infrastructure as code",
    "monitoring"
  ]
}
```

### Data-Scientist
```json
"data-scientist": {
  "type": "specialized",
  "keywords": [
    "data", "analysis", "machine learning", "statistics",
    "model", "dataset", "visualization"
  ],
  "description": "Data analysis, ML, statistics, visualization",
  "expertise": [
    "data analysis",
    "machine learning",
    "statistics",
    "visualization",
    "feature engineering"
  ]
}
```

### Researcher
```json
"researcher": {
  "type": "specialized",
  "keywords": [
    "research", "compare", "evaluate", "best practices",
    "trends", "alternatives", "benchmark"
  ],
  "description": "Technology research, best practices, trend analysis",
  "expertise": [
    "technology comparison",
    "trend analysis",
    "best practices research",
    "solution evaluation"
  ]
}
```

## 🔧 Customization

### Adding a New Agent

1. Add entry to `agents-map.json`:
```json
"my-agent": {
  "type": "specialized",
  "keywords": ["keyword1", "keyword2"],
  "description": "What this agent does",
  "expertise": ["skill1", "skill2"]
}
```

2. Create agent file: `.kiro/steering/agents/my-agent.md`

3. Update `config/betteragents.json`

### Modifying Keywords

To improve routing, you can add/modify keywords:

```json
"architect": {
  "keywords": [
    "design", "architecture",
    "api", "rest", "graphql"  // Added API-related keywords
  ]
}
```

## 💡 Best Practices

1. **Keywords should be specific** - Avoid generic terms
2. **Include variations** - "test", "testing", "tests"
3. **Consider user language** - How would users phrase requests?
4. **Avoid keyword overlap** - Minimize ambiguity between agents
5. **Keep expertise current** - Update as agents evolve

## 🎯 Routing Examples

### Example 1: Clear Match
```
Query: "Write unit tests for this function"
Keywords: ["write", "unit tests", "function"]
Match: tester (100% confidence)
```

### Example 2: Multi-Agent
```
Query: "Design and implement a REST API"
Keywords: ["design", "implement", "REST", "API"]
Matches:
  - architect (design, API) - 80%
  - coder (implement) - 70%
Workflow: architect → coder
```

### Example 3: Ambiguous
```
Query: "Help me with this"
Keywords: ["help"]
Result: AgentX requests clarification (ambiguity > 30%)
```

## 📚 Related Documentation

- [AgentX Core Documentation](../agents/agentx.md)
- [Routing Patterns](./routing-patterns.md)
- [Agent Directory](../../docs/agents/README.md)

---

**Version:** 2.1.0  
**Last Updated:** 2026-02-14

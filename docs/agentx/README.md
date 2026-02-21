# 🧠 AgentX - Intelligent Orchestrator

**AgentX** is the central brain of the BetterAgents ecosystem. It doesn't implement solutions directly, but acts as the **strategic orchestrator** that analyzes, validates, and routes queries to the most capable agents.

## 🧠 What is AgentX?

AgentX is a **meta-agent** that:

1. **Processes** human requirements with deep analysis
2. **Translates** queries into precise technical instructions
3. **Routes** tasks to the most appropriate agent or skill
4. **Validates** completeness before execution
5. **Synthesizes** responses when multiple agents are needed
6. **Orchestrates** complex multi-agent workflows
7. **Manages** the memory system automatically

## 🎯 Core Philosophy

> **"I am the router, not the executor. I ensure the right expert handles each task."**

AgentX is the **first line of intelligence** - analyzing, validating, and directing. It can answer simple questions directly, but for complex tasks, it orchestrates the entire ecosystem.

## 🔄 4-D Methodology

AgentX uses a structured 4-phase methodology:

### 1. 🔍 DECONSTRUCT (Intent Analysis)

**Extracts and identifies:**
- Implicit technical architecture
- Technology stack
- Key entities and business logic
- Complexity level
- Domain classification

**Critical questions:**
- What is the user REALLY asking for?
- What domain(s) does this belong to?
- Is this a single-agent task or multi-agent collaboration?
- Are there unstated implicit requirements?

### 2. 🩺 DIAGNOSE (Quality Control)

**Evaluates completeness and risks:**
- Does the requirement have sufficient information?
- Are there critical dependencies or technical risks?
- What assumptions are being made?
- What could go wrong?

**Action thresholds:**
- **If ambiguity > 30%** → Request clarification
- **If security implications** → Flag for Security review
- **If architectural impact** → Flag for Architect review
- **If multi-domain** → Plan multi-agent workflow

### 3. 🛠️ DEVELOP (Prompt Engineering)

**Designs instruction for target agent:**
- Applies **Chain-of-Thought (CoT)** for complex logical tasks
- Includes relevant context from history
- Establishes **negative constraints** (what NOT to do)
- Specifies expected output format
- Includes success criteria and validation points

### 4. 📤 DISPATCH (Structured Output)

**Three output modes:**

#### Mode A: Direct Response
For simple informational questions

#### Mode B: Routing Decision
For complex tasks requiring a specialized agent

#### Mode C: Multi-Agent Workflow
For complex projects involving multiple domains

## 🤖 Agent Ecosystem

AgentX can route to **12 specialized agents**:

### Core Agents (7)
1. **Architect** - System design and architecture
2. **Coder** - Implementation and clean code
3. **Critic** - Critical analysis (Tenth Man Rule)
4. **Tester** - Testing and QA
5. **Writer** - Technical documentation
6. **Researcher** - Technology research
7. **Teacher** - Educational explanations

### Specialized Agents (5)
8. **DevOps** - Infrastructure and CI/CD
9. **Security** - Security auditing
10. **UX-Designer** - UI/UX design
11. **Data-Scientist** - Data analysis
12. **Product-Manager** - Product management

## 📋 Routing Decision Matrix

### Single Agent Tasks

```
Query Pattern → Target Agent

"Design a microservices architecture" → Architect
"Implement JWT authentication in Node.js" → Coder
"What could go wrong with this design?" → Critic
"Audit this code for vulnerabilities" → Security
"Write unit tests for this function" → Tester
"Design an accessible login form" → UX-Designer
"Document this REST API" → Writer
"Explain how promises work in JS" → Teacher
"Write user stories for authentication" → Product-Manager
"Set up CI/CD pipeline with GitHub Actions" → DevOps
"Analyze this dataset for insights" → Data-Scientist
"Compare React vs Vue for our case" → Researcher
```

### Multi-Agent Workflows

**Pattern 1: Design → Implement → Test → Document**
```
1. Architect: Designs system architecture
2. Coder: Implements the design
3. Tester: Writes comprehensive tests
4. Writer: Documents the implementation
```

**Pattern 2: Design → Critique → Refine → Implement**
```
1. Architect: Proposes initial design
2. Critic: Challenges assumptions and identifies risks
3. Architect: Refines design based on feedback
4. Coder: Implements refined design
```

**Pattern 3: Research → Design → Implement → Deploy**
```
1. Researcher: Evaluates technology options
2. Architect: Designs architecture with chosen tech
3. Coder: Implements solution
4. DevOps: Sets up deployment pipeline
```

## 💾 Memory Management

AgentX is the **sole administrator** of the memory system. It automatically detects content worthy of documentation:

### Detection Triggers

**1. Technical Decisions (→ decision-log.md)**
- Architecture choice
- Technology stack selection
- Design pattern selection
- Trade-off analysis

**2. Task Progress (→ progress.md)**
- Task completed
- New task started
- Milestone reached
- Implementation finished

**3. Patterns and Learnings (→ patterns.md)**
- Reusable solution identified
- Problem solved elegantly
- Anti-pattern discovered
- Best practice learned

**4. Context Changes (→ active-context.md)**
- Project phase change
- New feature started
- Objective change
- Technology change

### Memory Decision Protocol

For EVERY interaction, AgentX asks itself:

```
1. Is there a technical decision? → decision-log.md
2. Was a task completed or started? → progress.md
3. Was a useful pattern identified? → patterns.md
4. Did the project context change? → active-context.md
```

**If YES to any:** Update memory AUTOMATICALLY
**If UNCERTAIN:** Ask the user

## 🎯 How to Use AgentX

### Default Invocation

All queries without `@agent` prefix go to AgentX first:

```
User: "I need to design an authentication system"
→ AgentX analyzes and routes to Architect
```

### Explicit Invocation

```
@agentx Which agent should I use to implement JWT?
```

### Direct Override

You can skip AgentX and go directly to an agent:

```
@architect Design an authentication system
```

## 📊 Output Formats

### Direct Response (Simple Questions)

```markdown
---
🧠 AgentX/Dispatcher
---

[Clear and direct response]

💡 **Need more help?**
- For [specific task] → I can route you to [Agent Name]
```

### Routing Decision (Single Agent)

```markdown
---
🧠 AgentX
🔀 Routing to: [Agent Name]
---

## 📋 Analysis
[Classification and evaluation]

## 🎯 Routing Decision
[Why this agent]

## 📝 Refined Prompt for [Agent]
[Precise and detailed instructions]

## 📊 Metadata
```json
{
  "request_id": "[UUID]",
  "status": "READY",
  "routing": {...}
}
```
```

### Incomplete Request (Needs Clarification)

```markdown
---
🧠 AgentX
⚠️ Status: INCOMPLETE
---

## ❓ Clarification Questions
[Specific questions needed]

## 💡 What I Understood So Far
[Summary of what's clear]
```

### Multi-Agent Workflow

```markdown
---
🧠 AgentX
🔀 Multi-Agent Workflow Required
---

## 🔄 Proposed Workflow

### Phase 1: [Phase Name]
**Agent:** [Name]
**Task:** [Specific task]
**Deliverable:** [Expected output]

### Phase 2: [Phase Name]
[...]
```

## 🔧 Configuration

AgentX is configured in `config/.betteragents-config`:

```bash
# Enable AgentX as default orchestrator
AGENTX_ENABLED=true

# Temperature for routing decisions (0.0-1.0)
AGENTX_TEMPERATURE=0.3

# Ambiguity threshold for requesting clarification (0-100)
AGENTX_AMBIGUITY_THRESHOLD=30

# Enable multi-agent workflows
AGENTX_MULTI_AGENT_WORKFLOWS=true

# Save routing logs
AGENTX_LOG_ROUTING=true
```

## 💡 Best Practices

### For Users

1. **Be specific** - More context = better routing
2. **Trust AgentX** - Let it analyze and route
3. **Provide feedback** - Help improve decisions
4. **Use override when you know** - `@specific-agent` if you're sure

### For Developers

1. **Keep agents specialized** - One domain, one agent
2. **Document capabilities** - AgentX needs to know what each agent can do
3. **Update keywords** - Help AgentX identify domains
4. **Contribute to memory** - Suggest content worthy of documentation

## 🚀 AgentX Advantages

✅ **Intelligent Routing** - Always the right agent
✅ **Pre-validation** - Detects missing information
✅ **Refined Prompts** - Precise and actionable instructions
✅ **Complex Workflows** - Orchestrates multiple agents
✅ **Automatic Memory** - Documents decisions and progress
✅ **Continuous Learning** - Improves with each interaction

## 📚 Related Resources

- [Getting Started Guide](../guides/getting-started.md)
- [Memory System](../memory/README.md)
- [Agent Directory](../agents/README.md)
- [Workflows](../guides/workflows.md)
- [Examples](../../examples/)

---

**AgentX: The brain that connects the entire BetterAgents ecosystem 🧠**

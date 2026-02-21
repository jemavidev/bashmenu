# 🚀 Getting Started with BetterAgents

Welcome to BetterAgents! This guide will help you get up and running quickly with **AgentX**, the intelligent orchestrator, and the **Memory System**.

## 🎯 What is BetterAgents?

BetterAgents is an intelligent multi-agent system for Kiro Code featuring:

- **AgentX** - Smart orchestrator that routes queries to specialized agents
- **12 Specialized Agents** - Experts in architecture, coding, testing, security, and more
- **Memory System** - Automatic documentation of decisions, progress, and patterns
- **Interactive Dashboard** - Visual interface to manage project memory
- **Skills Integration** - Enhanced capabilities through skills.sh

## 📋 Prerequisites

Before you begin, ensure you have:
- **Kiro Code** installed ([Installation Guide](../installation/linux.md))
- **Node.js** 16.x or higher
- **Git** for cloning the repository
- **Bash** shell (Linux/macOS) or WSL (Windows)
- **Python 3.8+** (for memory sync script)

## ⚡ Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX
```

### 2. Run Installation

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

The installer will:
- ✅ Verify system requirements
- ✅ Set up configuration
- ✅ Create memory system
- ✅ Install recommended skills (optional)
- ✅ Verify installation

### 3. Open Kiro Code

```bash
kiro .
```

### 4. Try AgentX (Your First Interaction)

AgentX is the intelligent orchestrator. All queries go through AgentX by default:

```
Necesito diseñar un sistema de autenticación para mi API
```

AgentX will:
1. Analyze your request
2. Determine it's an architecture task
3. Route to the Architect agent
4. Provide a refined prompt

You should see:
```markdown
---
🧠 AgentX
🔀 Routing to: Architect
---

## 📋 Analysis
[AgentX's analysis of your request]

## 🎯 Routing Decision
[Why Architect was chosen]

## 📝 Refined Prompt for Architect
[Detailed instructions for Architect]
```

Then Architect will respond with the system design.

### 5. Direct Agent Access (Optional)

You can also go directly to any agent:

```
@architect Hello! Can you explain how you work?
```

### 6. Explore the Memory System

Check your project memory:

```bash
# Open the interactive dashboard
./kiro/memory/open-dashboard.sh

# Or view memory files directly
cat .kiro/memory/active-context.md
cat .kiro/memory/progress.md
cat .kiro/memory/decision-log.md
cat .kiro/memory/patterns.md
```

## 🎯 Your First Workflow with AgentX

Let's build a simple REST API with AgentX orchestrating the workflow:

### Step 1: Start with AgentX (No prefix needed!)

```
Necesito crear una API REST para autenticación de usuarios con JWT
```

AgentX will analyze and route to Product Manager for requirements.

### Step 2: Let AgentX Guide You

AgentX will automatically:
- Route to **Product Manager** for user stories
- Route to **Architect** for system design
- Suggest **Critic** for design review
- Route to **Security** for security analysis
- Route to **Coder** for implementation
- Route to **Tester** for test cases
- Route to **Writer** for documentation

### Step 3: AgentX Documents Everything

AgentX automatically updates memory:
- **Decisions** → `decision-log.md`
- **Progress** → `progress.md`
- **Patterns** → `patterns.md`
- **Context** → `active-context.md`

You'll see:
```markdown
---
🧠 AgentX
💾 Memory Update: decision-log.md
---

## 💾 Actualización de Memoria

**Archivo:** `.kiro/memory/decision-log.md`
**Acción:** Documented technical decision
**Razón:** Technology stack selection

**Contenido agregado:**
[Shows what was documented]
```

### Step 4: Review in Dashboard

```bash
./kiro/memory/open-dashboard.sh
```

See all decisions, progress, and patterns in a visual interface!

## 📚 Understanding the System

### AgentX - The Orchestrator

**AgentX** is the brain of BetterAgents. It:
- Analyzes your requests using 4-D Methodology
- Routes to the best agent for the task
- Validates completeness before execution
- Orchestrates multi-agent workflows
- Manages memory automatically

**Learn more:** [AgentX Documentation](../agentx/README.md)

### 12 Specialized Agents

AgentX can route to these agents:

#### Core Agents (7)
- **Architect** - System design and architecture
- **Coder** - Code implementation
- **Critic** - Critical analysis (Tenth Man Rule)
- **Tester** - Testing and QA
- **Writer** - Technical documentation
- **Researcher** - Research and analysis
- **Teacher** - Educational explanations

#### Specialized Agents (5)
- **DevOps** - Infrastructure and deployment
- **Security** - Security analysis
- **UX Designer** - UI/UX design
- **Data Scientist** - Data analysis
- **Product Manager** - Product management

**Learn more:** [Agent Directory](../agents/README.md)

### Memory System

The memory system automatically documents:
- **Decisions** - Technical choices and trade-offs
- **Progress** - Tasks completed and in progress
- **Patterns** - Reusable solutions and learnings
- **Context** - Current project state

**Learn more:** [Memory System Documentation](../memory/README.md)

## 🔧 Configuration

### AgentX Configuration

Configure AgentX in `config/.betteragents-config`:

```bash
# Enable AgentX as default orchestrator
AGENTX_ENABLED=true

# Temperature for routing decisions (0.0-1.0)
AGENTX_TEMPERATURE=0.3

# Ambiguity threshold for clarification (0-100)
AGENTX_AMBIGUITY_THRESHOLD=30

# Enable multi-agent workflows
AGENTX_MULTI_AGENT_WORKFLOWS=true
```

### Memory System Configuration

```bash
# Enable automatic memory system
MEMORY_ENABLED=true

# Memory directory
MEMORY_DIR=.kiro/memory

# Auto-update memory by AgentX
MEMORY_AUTO_UPDATE=true

# Ask before documenting (true/false)
MEMORY_ASK_BEFORE_SAVE=false
```

### Main Configuration

The main configuration file is at `config/betteragents.json`:

```json
{
  "name": "BetterAgents",
  "version": "3.1.0",
  "agents": {
    "agentx": {
      "file": ".kiro/steering/agents/agentx.md",
      "type": "orchestrator",
      "isDefault": true
    }
    // ... more agents
  },
  "features": {
    "agentx": { "enabled": true },
    "memory": { "enabled": true }
  }
}
```

### Skills Configuration

Configure skill updates in `config/.betteragents-config`:

```bash
# Auto-update skills
AUTO_UPDATE_SKILLS=false

# Check frequency (days)
UPDATE_CHECK_FREQUENCY=7

# Notify about updates
NOTIFY_UPDATES=true
```

## 📖 Memory System

BetterAgents includes an intelligent memory system managed by AgentX:

### Memory Files

Located in `.kiro/memory/`:
- **active-context.md** - Current project context
- **progress.md** - Track progress and tasks
- **decision-log.md** - Log technical decisions (ADR format)
- **patterns.md** - Document learned patterns and solutions

### Automatic Documentation

AgentX automatically detects and documents:
- Technical decisions → `decision-log.md`
- Task completions → `progress.md`
- Useful patterns → `patterns.md`
- Context changes → `active-context.md`

### Interactive Dashboard

View and manage memory visually:

```bash
# Open dashboard
./kiro/memory/open-dashboard.sh

# Sync markdown files to dashboard
python3 .kiro/memory/sync-memory.py
```

**Dashboard features:**
- Overview with statistics
- Search and filter
- CRUD operations
- Timeline view
- Real-time updates

**Learn more:** [Memory System Guide](../memory/README.md)

## 🎓 Learning More

### Core Documentation
- **[AgentX Guide](../agentx/README.md)** - Learn about the intelligent orchestrator
- **[Memory System](../memory/README.md)** - Understand automatic documentation
- **[Agent Directory](../agents/README.md)** - Complete agent reference

### Guides
- [Skills Management](./skills-management.md) - Managing and updating skills
- [Workflows](./workflows.md) - Collaborative workflows
- [Advanced Usage](./advanced-usage.md) - Advanced features

### Examples
- [Basic Workflow](../../examples/basic-workflow/) - Simple API development
- [AgentX Routing](../../examples/agentx-routing/) - How AgentX routes queries
- [Memory Management](../../examples/memory-management/) - Using the memory system
- [Multi-Agent Collaboration](../../examples/multi-agent/) - Complex workflows

## 🆘 Troubleshooting

### AgentX Not Routing

1. Check AgentX is enabled in `config/.betteragents-config`
2. Verify `AGENTX_ENABLED=true`
3. Check agent files exist in `.kiro/steering/agents/`
4. Try explicit routing: `@agentx test`

### Agent Not Responding

1. Check Kiro Code is running
2. Verify agent files exist in `.kiro/steering/agents/`
3. Check syntax with `@architect test`
4. Review logs if enabled

### Memory Not Updating

1. Check `MEMORY_ENABLED=true` in config
2. Verify `MEMORY_AUTO_UPDATE=true`
3. Check memory files exist in `.kiro/memory/`
4. Try explicit command: "Documenta esto en memoria"

### Dashboard Not Loading

1. Check `dashboard.html` exists in `.kiro/memory/`
2. Run sync script: `python3 .kiro/memory/sync-memory.py`
3. Try opening with: `./kiro/memory/open-dashboard.sh`
4. Check browser console for errors

### Skills Not Working

1. Verify skills are installed: `npx skills list`
2. Update skills: `./scripts/update-skills.sh`
3. Check configuration in `config/`

### Installation Issues

1. Verify Node.js version: `node --version`
2. Check Kiro Code installation: `kiro --version`
3. Review installation logs
4. See [Troubleshooting Guide](../installation/linux.md#troubleshooting)

## 💡 Tips

1. **Let AgentX Route** - Don't use `@agent` unless you know exactly which agent you need
2. **Trust the Memory System** - AgentX documents important decisions automatically
3. **Use the Dashboard** - Visual interface makes memory management easy
4. **Be Specific** - More context = better routing and results
5. **Review Memory Weekly** - Keep context files up to date
6. **Update Regularly** - Run `./scripts/check-updates.sh` weekly
7. **Explore Skills** - Install recommended skills for better results
8. **Read Agent Docs** - Each agent has detailed documentation
9. **Use Multi-Agent Workflows** - Let AgentX orchestrate complex tasks
10. **Contribute to Memory** - Agents can suggest memory updates

## 🎯 Next Steps

1. ✅ Complete installation
2. ✅ Try AgentX with a simple query
3. ✅ Explore the memory dashboard
4. ✅ Install recommended skills
5. ✅ Try a multi-agent workflow
6. ✅ Read AgentX documentation
7. ✅ Explore agent capabilities
8. ✅ Join the community

## 📞 Getting Help

- 📖 [Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/jemavidev/BetterAgentX/issues)
- 💬 [Discussions](https://github.com/jemavidev/BetterAgentX/discussions)
- 📧 [Contact](mailto:your-email@example.com)

---

**Ready to build something amazing with AgentX? Let's go! 🚀**

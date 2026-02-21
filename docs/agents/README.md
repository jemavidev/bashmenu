# 🤖 BetterAgents - Agent Directory

Complete reference for **AgentX** (orchestrator) and all 12 specialized AI agents in BetterAgents.

## 🧠 AgentX - The Orchestrator

**AgentX** is the intelligent brain that routes all queries to the right agent. It's your default entry point.

**Type:** Orchestrator  
**File:** `.kiro/steering/agents/agentx.md`  
**Default:** Yes (all queries without `@agent` go to AgentX)

### What AgentX Does

1. **Analyzes** your request using 4-D Methodology
2. **Validates** completeness and identifies missing information
3. **Routes** to the best agent(s) for the task
4. **Orchestrates** multi-agent workflows when needed
5. **Manages** memory system automatically
6. **Refines** prompts for target agents

### When to Use AgentX

✅ **Always use by default** - Just ask your question naturally  
✅ **Complex tasks** - AgentX orchestrates multiple agents  
✅ **Unclear domain** - AgentX determines the right agent  
✅ **Multi-step workflows** - AgentX plans the sequence

### Example Invocations

```
# No prefix needed - goes to AgentX by default
Necesito diseñar un sistema de autenticación

# Explicit invocation
@agentx ¿Qué agente debería usar para implementar JWT?

# AgentX will analyze and route appropriately
```

**Learn more:** [AgentX Documentation](../agentx/README.md)

---

## 📋 Quick Reference

| Agent | Type | Primary Role | Skills | Best For |
|-------|------|--------------|--------|----------|
| [AgentX](#agentx---the-orchestrator) | Orchestrator | Intelligent Routing | N/A | Everything (Default) |
| [Architect](#architect) | Core | System Design | 6 | Architecture, Design Patterns |
| [Coder](#coder) | Core | Implementation | 9 | Writing Code, Refactoring |
| [Critic](#critic) | Core | Critical Analysis | 4 | Risk Analysis, Review |
| [Tester](#tester) | Core | Quality Assurance | 4 | Testing, QA |
| [Writer](#writer) | Core | Documentation | 4 | Technical Writing |
| [Researcher](#researcher) | Core | Research | 4 | Technology Research |
| [Teacher](#teacher) | Core | Education | 2 | Learning, Explanations |
| [DevOps](#devops) | Specialized | Infrastructure | 5 | Deployment, CI/CD |
| [Security](#security) | Specialized | Security | 2 | Security Analysis |
| [UX Designer](#ux-designer) | Specialized | UI/UX | 8 | Interface Design |
| [Data Scientist](#data-scientist) | Specialized | Data Analysis | 2 | ML, Analytics |
| [Product Manager](#product-manager) | Specialized | Product | 6 | Requirements, Planning |

---

## 🏗️ Architect

**Type:** Core Agent  
**File:** `.kiro/steering/agents/architect.md`

### Role
Software Architect specializing in system design, architecture patterns, and technical planning.

### Expertise
- System architecture and design
- SOLID principles and design patterns
- Microservices vs Monolith decisions
- Database schema design
- API design (REST, GraphQL, gRPC)
- Scalability and performance planning
- Technology stack evaluation
- Cloud architecture

### Recommended Skills (6)
- architecture-patterns
- api-design-principles
- microservices-patterns
- design-system-patterns
- architecture-decision-records
- monorepo-management

### When to Use
- Designing new systems
- Evaluating technology choices
- Planning architecture
- Making technical decisions
- Reviewing system design

### Example Invocations
```
@architect Design an authentication system for 100k users
@architect Should we use PostgreSQL or MongoDB for this use case?
@architect Review this microservices architecture
```

---

## 💻 Coder

**Type:** Core Agent  
**File:** `.kiro/steering/agents/coder.md`

### Role
Software Coder specializing in clean code implementation, best practices, and problem-solving.

### Expertise
- Clean code principles (KISS, DRY, YAGNI)
- Language-specific best practices
- Code optimization and refactoring
- Debugging strategies
- Error handling patterns
- Code review and quality assessment
- Test-driven development
- Design pattern implementation

### Recommended Skills (9)
- vercel-react-best-practices
- next-best-practices
- typescript-advanced-types
- python-performance-optimization
- nodejs-backend-patterns
- error-handling-patterns
- async-python-patterns
- modern-javascript-patterns
- test-driven-development

### When to Use
- Implementing features
- Refactoring code
- Debugging issues
- Code reviews
- Optimization

### Example Invocations
```
@coder Implement JWT authentication in Python
@coder Review this code for issues
@coder Debug this error: [error message]
@coder Optimize this function for performance
```

---

## 🎭 Critic

**Type:** Core Agent  
**File:** `.kiro/steering/agents/critic.md`

### Role
The Critic implementing the Tenth Man Rule - systematic dissent to prevent groupthink.

### Expertise
- Critical thinking and analysis
- Risk identification
- Assumption validation
- Alternative perspective generation
- Pre-mortem analysis
- Second-order thinking
- Trade-off evaluation
- Cognitive bias identification

### Recommended Skills (4)
- systematic-debugging
- verification-before-completion
- requesting-code-review
- receiving-code-review

### When to Use
- After major decisions
- Before implementation
- Risk assessment
- Design review
- Challenging assumptions

### Example Invocations
```
@critic Review this architecture proposal
@critic What could go wrong with using microservices here?
@critic Challenge the assumption that we need real-time updates
@critic Pre-mortem: Imagine this project failed, why?
```

---

## 🧪 Tester

**Type:** Core Agent  
**File:** `.kiro/steering/agents/tester.md`

### Role
Software Tester specializing in test strategy, TDD, and quality assurance.

### Expertise
- Test-driven development (TDD)
- Unit, integration, and E2E testing
- Test coverage analysis
- Edge case identification
- Testing frameworks and tools
- Quality metrics
- Bug reproduction
- Performance testing

### Recommended Skills (4)
- webapp-testing
- test-driven-development
- e2e-testing-patterns
- javascript-testing-patterns

### When to Use
- Planning tests
- Writing test cases
- Identifying edge cases
- Test strategy
- Quality assurance

### Example Invocations
```
@tester What tests should I write for this auth module?
@tester Review test coverage for this feature
@tester Identify edge cases for this function
@tester Write unit tests for this code
```

---

## ✍️ Writer

**Type:** Core Agent  
**File:** `.kiro/steering/agents/writer.md`

### Role
Technical Writer specializing in clear, concise, and user-friendly documentation.

### Expertise
- API documentation
- README files
- Technical tutorials
- Code comments
- User manuals
- Release notes
- Architecture documentation
- Onboarding documentation

### Recommended Skills (4)
- doc-coauthoring
- writing-skills
- copy-editing
- internal-comms

### When to Use
- Writing documentation
- Creating tutorials
- API docs
- README files
- Release notes

### Example Invocations
```
@writer Write API documentation for this endpoint
@writer Create a README for this project
@writer Write a tutorial for beginners
@writer Document this function with docstrings
```

---

## 🔍 Researcher

**Type:** Core Agent  
**File:** `.kiro/steering/agents/researcher.md`

### Role
Researcher specializing in gathering, analyzing, and synthesizing technical information.

### Expertise
- Technology research
- Best practices discovery
- Solution evaluation
- Trend analysis
- Academic paper analysis
- Documentation review
- Competitive analysis
- Resource curation

### Recommended Skills (4)
- find-skills
- competitor-alternatives
- seo-audit
- audit-websites

### When to Use
- Researching technologies
- Comparing solutions
- Finding best practices
- Trend analysis
- Technology evaluation

### Example Invocations
```
@researcher Compare React vs Vue for our use case
@researcher Research best practices for API design
@researcher Find solutions for real-time notifications
@researcher Should we use GraphQL or REST?
```

---

## 👨‍🏫 Teacher

**Type:** Core Agent  
**File:** `.kiro/steering/agents/teacher.md`

### Role
Teacher specializing in explaining complex technical concepts in simple, understandable ways.

### Expertise
- Concept explanation
- Step-by-step tutorials
- Interactive learning
- Analogies and metaphors
- Progressive complexity
- Practice exercises
- Learning path design
- Debugging misconceptions

### Recommended Skills (2)
- skill-creator
- prompt-engineering-patterns

### When to Use
- Learning new concepts
- Explaining to others
- Creating tutorials
- Understanding errors
- Educational content

### Example Invocations
```
@teacher Explain Python decorators like I'm 5
@teacher Teach me async/await with examples
@teacher Create a tutorial for building a REST API
@teacher What's the difference between let and const?
```

---

## 🚀 DevOps

**Type:** Specialized Agent  
**File:** `.kiro/steering/agents/devops.md`

### Role
DevOps Engineer specializing in infrastructure, deployment, automation, and operational excellence.

### Expertise
- CI/CD pipelines
- Container orchestration (Docker, Kubernetes)
- Cloud platforms (AWS, GCP, Azure)
- Infrastructure as Code (Terraform)
- Monitoring and observability
- Security and compliance
- Performance optimization
- Incident response

### Recommended Skills (5)
- docker-expert
- deployment-pipeline-design
- github-actions-templates
- database-migration
- changelog-automation

### When to Use
- Setting up infrastructure
- Creating CI/CD pipelines
- Deployment automation
- Monitoring setup
- Performance optimization

### Example Invocations
```
@devops Create a CI/CD pipeline for Node.js app
@devops Optimize this Dockerfile
@devops Set up Kubernetes deployment
@devops Configure monitoring with Prometheus
```

---

## 🔒 Security

**Type:** Specialized Agent  
**File:** `.kiro/steering/agents/security.md`

### Role
Security Specialist focused on identifying vulnerabilities and implementing security best practices.

### Expertise
- OWASP Top 10 vulnerabilities
- Authentication and authorization
- Cryptography and encryption
- Security auditing
- Secure coding practices
- Compliance (GDPR, HIPAA, PCI-DSS)
- Incident response
- Security architecture

### Recommended Skills (2)
- code-reviewer
- auth-implementation-patterns

### When to Use
- Security audits
- Vulnerability analysis
- Secure implementation
- Compliance review
- Threat modeling

### Example Invocations
```
@security Audit this code for security vulnerabilities
@security How do I implement secure authentication?
@security Review this API for OWASP Top 10 issues
@security Set up security headers for my web app
```

---

## 🎨 UX Designer

**Type:** Specialized Agent  
**File:** `.kiro/steering/agents/ux-designer.md`

### Role
UX/UI Designer specializing in creating intuitive, accessible, and beautiful user interfaces.

### Expertise
- User experience (UX) design
- User interface (UI) design
- Accessibility (WCAG 2.1)
- Design systems
- Responsive design
- User research
- Information architecture
- Interaction design

### Recommended Skills (8)
- frontend-design
- web-design-guidelines
- ui-ux-pro-max
- canvas-design
- tailwind-design-system
- responsive-design
- accessibility-compliance
- interaction-design

### When to Use
- Designing interfaces
- Accessibility review
- Design systems
- User experience
- Responsive design

### Example Invocations
```
@ux-designer Design an accessible login form
@ux-designer Create a design system for buttons
@ux-designer Review this UI for accessibility issues
@ux-designer Design a mobile-friendly navigation
```

---

## 📊 Data Scientist

**Type:** Specialized Agent  
**File:** `.kiro/steering/agents/data-scientist.md`

### Role
Data Scientist specializing in data analysis, machine learning, and extracting insights from data.

### Expertise
- Data analysis and visualization
- Statistical analysis
- Machine learning
- Feature engineering
- Model evaluation
- A/B testing
- Time series analysis
- Natural language processing

### Recommended Skills (2)
- python-performance-optimization
- sql-optimization-patterns

### When to Use
- Analyzing data
- Building ML models
- Statistical analysis
- Data visualization
- A/B testing

### Example Invocations
```
@data-scientist Analyze this dataset for insights
@data-scientist Build a classification model
@data-scientist Design an A/B test
@data-scientist Visualize this data
```

---

## 📋 Product Manager

**Type:** Specialized Agent  
**File:** `.kiro/steering/agents/product-manager.md`

### Role
Product Manager responsible for defining product vision, prioritizing features, and ensuring the team builds the right thing.

### Expertise
- Product strategy and roadmapping
- User story writing
- Feature prioritization
- Stakeholder management
- Metrics and KPIs
- User research
- Competitive analysis
- Go-to-market strategy

### Recommended Skills (6)
- writing-plans
- executing-plans
- brainstorming
- marketing-ideas
- product-marketing-context
- kpi-dashboard-design

### When to Use
- Defining requirements
- Prioritizing features
- Writing user stories
- Product strategy
- KPI definition

### Example Invocations
```
@product-manager Write user stories for authentication
@product-manager Prioritize these features using RICE
@product-manager Create a product roadmap
@product-manager Define KPIs for this feature
```

---

## 🔄 Agent Collaboration

Agents are designed to work together, orchestrated by AgentX. See [Workflows Guide](../guides/workflows.md) for collaboration patterns.

### How AgentX Orchestrates

**Single Agent Tasks:**
```
User Query → AgentX Analysis → Route to Best Agent → Response
```

**Multi-Agent Workflows:**
```
User Query → AgentX Analysis → Plan Workflow → 
  Phase 1: Agent A → 
  Phase 2: Agent B → 
  Phase 3: Agent C → 
  Synthesized Response
```

### Common Collaborations

- **Architect + Critic** - Design review (AgentX orchestrates)
- **Coder + Tester** - Implementation and testing
- **Researcher + Teacher** - Learning and understanding
- **DevOps + Security** - Secure deployment
- **UX Designer + Coder** - Design implementation
- **Product Manager + Architect** - Requirements to design

### Memory Contributions

All agents can suggest memory updates to AgentX:

```markdown
💾 **Memory Suggestion:** [file-name]
[What should be documented and why]
```

AgentX evaluates and documents approved suggestions.

---

## 📚 Related Resources

- [AgentX Documentation](../agentx/README.md) - Learn about the orchestrator
- [Memory System](../memory/README.md) - Automatic documentation
- [Getting Started](../guides/getting-started.md) - Quick start guide
- [Workflows](../guides/workflows.md) - Collaboration patterns
- [Skills Management](../guides/skills-management.md) - Managing skills
- [Examples](../../examples/) - Real-world examples

---

**Need help choosing an agent? Just ask naturally - AgentX will route you to the right expert! 🚀**

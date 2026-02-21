# 🔄 Collaborative Workflows

BetterAgents is designed for collaborative workflows where multiple agents work together. This guide shows you the most effective workflows.

## 🎯 Core Workflows

### 1. Complete Feature Development

**Agents:** Product Manager → Architect → Critic → Security → Coder → Tester → Writer

**Use Case:** Building a new feature from scratch

```
Step 1: Define Requirements
@product-manager I need a user authentication system with JWT tokens

Step 2: Design Architecture
@architect Design the authentication system based on the requirements above

Step 3: Critical Review
@critic Review the architecture design and identify potential issues

Step 4: Security Analysis
@security Analyze the authentication design for security vulnerabilities

Step 5: Implement Code
@coder Implement the authentication system based on the approved design

Step 6: Create Tests
@tester Write comprehensive tests for the authentication system

Step 7: Document
@writer Create complete documentation for the authentication system
```

**Expected Outcome:** Fully implemented, tested, and documented feature

---

### 2. Research & Learning

**Agents:** Researcher → Teacher → Architect → Critic

**Use Case:** Learning new technology or evaluating solutions

```
Step 1: Research
@researcher Compare GraphQL vs REST for our API. What are the pros and cons?

Step 2: Explain
@teacher Explain GraphQL concepts in simple terms with examples

Step 3: Design
@architect Design an API architecture using GraphQL based on the research

Step 4: Validate
@critic Challenge the decision to use GraphQL. What could go wrong?
```

**Expected Outcome:** Well-researched, understood, and validated decision

---

### 3. Deployment & Operations

**Agents:** DevOps → Security → Coder → Tester → Writer

**Use Case:** Setting up infrastructure and deployment

```
Step 1: Infrastructure Design
@devops Design a Docker + Kubernetes deployment for our Node.js app

Step 2: Security Review
@security Review the deployment configuration for security issues

Step 3: Implementation
@coder Implement the Dockerfile and Kubernetes manifests

Step 4: Testing
@tester Create tests to verify the deployment works correctly

Step 5: Documentation
@writer Document the deployment process and troubleshooting
```

**Expected Outcome:** Secure, tested, and documented deployment

---

### 4. UI/UX Design & Implementation

**Agents:** UX Designer → Researcher → Coder → Tester → Critic

**Use Case:** Designing and implementing user interfaces

```
Step 1: Design Interface
@ux-designer Design a login form with best UX practices

Step 2: Research Best Practices
@researcher Find best practices for accessible login forms

Step 3: Implement
@coder Implement the login form with React and Tailwind CSS

Step 4: Test Accessibility
@tester Test the form for WCAG 2.1 compliance and usability

Step 5: Review
@critic Review the implementation. What could be improved?
```

**Expected Outcome:** Accessible, user-friendly interface

---

### 5. Data Analysis & Insights

**Agents:** Data Scientist → Architect → Coder → Tester → Writer

**Use Case:** Analyzing data and building ML models

```
Step 1: Analyze Data
@data-scientist Analyze this user behavior dataset and find patterns

Step 2: Design Pipeline
@architect Design a data pipeline for the analysis

Step 3: Implement
@coder Implement the data analysis pipeline in Python

Step 4: Validate
@tester Create tests to validate the analysis results

Step 5: Document
@writer Document the analysis methodology and findings
```

**Expected Outcome:** Validated insights with reproducible analysis

---

## 🎨 Specialized Workflows

### Code Review Workflow

**Agents:** Coder → Critic → Security → Tester

```
@coder Review this code for issues: [paste code]
@critic What are the potential problems with this approach?
@security Are there any security vulnerabilities?
@tester What edge cases should we test?
```

---

### Debugging Workflow

**Agents:** Coder → Critic → Teacher

```
@coder This code is failing: [paste error]. Help me debug it.
@critic What assumptions might be wrong here?
@teacher Explain why this error occurs and how to prevent it
```

---

### Documentation Workflow

**Agents:** Writer → Teacher → Researcher

```
@writer Create API documentation for this endpoint
@teacher Explain this concept for beginners
@researcher Find examples of good documentation for this
```

---

### Architecture Decision Workflow

**Agents:** Architect → Critic → Security → DevOps

```
@architect Should we use microservices or monolith for this project?
@critic Challenge the microservices approach. What could go wrong?
@security What are the security implications of each approach?
@devops What are the operational complexities?
```

---

## 💡 Best Practices

### 1. Start with Planning

Always begin with Product Manager or Architect to define scope:
```
@product-manager Define the requirements for [feature]
@architect Design the high-level architecture
```

### 2. Use Critic Liberally

Invoke Critic after major decisions:
```
@critic Review this decision and identify risks
```

### 3. Security First

Include Security agent for sensitive features:
```
@security Analyze this authentication flow for vulnerabilities
```

### 4. Document Everything

End workflows with Writer:
```
@writer Document this implementation for the team
```

### 5. Iterate

Don't expect perfection on first try:
```
@architect Revise the design based on Critic's feedback
@coder Refactor based on the new design
```

---

## 🔄 Workflow Patterns

### Sequential Pattern
```
Agent A → Agent B → Agent C
```
Each agent builds on previous work.

**Example:** Architect → Coder → Tester

---

### Review Pattern
```
Agent A → Critic → Agent A (revised)
```
Get critical feedback and iterate.

**Example:** Architect → Critic → Architect

---

### Parallel Pattern
```
        ┌─ Agent B
Agent A ┤
        └─ Agent C
```
Multiple agents work on different aspects.

**Example:** Architect → (Security + DevOps)

---

### Consultation Pattern
```
Agent A (consults Agent B internally)
```
Quick internal check without full context switch.

**Example:** Architect 💭 Consulted: Security

---

## 📊 Workflow Templates

### Template 1: New Feature
```
1. @product-manager - Define requirements
2. @architect - Design architecture
3. @critic - Review design
4. @security - Security analysis
5. @coder - Implement
6. @tester - Test
7. @writer - Document
```

### Template 2: Bug Fix
```
1. @coder - Analyze bug
2. @critic - Identify root cause
3. @coder - Fix implementation
4. @tester - Verify fix
5. @writer - Update docs
```

### Template 3: Performance Optimization
```
1. @data-scientist - Analyze metrics
2. @architect - Design optimization
3. @coder - Implement
4. @tester - Benchmark
5. @writer - Document improvements
```

### Template 4: Security Audit
```
1. @security - Audit codebase
2. @critic - Prioritize issues
3. @coder - Fix vulnerabilities
4. @tester - Verify fixes
5. @writer - Document changes
```

---

## 🎯 Choosing the Right Workflow

| Goal | Recommended Workflow |
|------|---------------------|
| New feature | Complete Feature Development |
| Learning | Research & Learning |
| Deployment | Deployment & Operations |
| UI work | UI/UX Design & Implementation |
| Data analysis | Data Analysis & Insights |
| Code review | Code Review Workflow |
| Bug fixing | Bug Fix Template |
| Performance | Performance Optimization |
| Security | Security Audit |

---

## 💭 Tips for Effective Workflows

1. **Be Specific** - Give agents clear context and requirements
2. **Reference Previous Work** - Agents can see conversation history
3. **Use Memory** - Document decisions in `.kiro/memory/`
4. **Iterate** - Don't expect perfection first time
5. **Mix and Match** - Combine workflows as needed
6. **Trust the Process** - Let agents collaborate naturally

---

## 📚 Related Resources

- [Getting Started](./getting-started.md)
- [Skills Management](./skills-management.md)
- [Agent Documentation](../agents/README.md)
- [Examples](../../examples/)

---

**Ready to create your own workflows? Start experimenting! 🚀**

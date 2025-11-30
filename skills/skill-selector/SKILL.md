---
name: skill-selector
description: Helps choose the right SuperClaude skill based on development phase, task type, and goals
---

# Skill Selector - Choose the Right Skill for Your Task

## When to Use This Skill

Use this skill when you're unsure which SuperClaude skill to use for your current task. This helper will guide you to the right skill based on:
- Your development phase (planning, implementing, reviewing, optimizing)
- The type of work you're doing
- Your specific goals

## How to Use

Simply describe what you're trying to accomplish, and I'll recommend which skill(s) to use and in what order.

**Example:** "I need to build a new API for user management"
**Recommendation:** Use confidence-check → sc-architecture → sc-security → sc-agent → sc-quality → self-review

---

## Skill Selection by Development Phase

### 📋 Phase 1: Planning & Design

**When you're starting a new feature or project:**

1. **confidence-check** - ALWAYS use this first!
   - Assess feasibility before starting
   - Prevents wasted effort on wrong approaches
   - Keywords: "should I", "is this possible", "best approach"

2. **create-prd** - Product Requirements Document
   - Create comprehensive PRD for new features
   - Ask clarifying questions with easy A/B/C/D options
   - Generate detailed specifications for junior developers
   - Keywords: "create PRD", "write requirements", "product spec", "feature requirements"

3. **generate-tasks** - Task List Generator
   - Break down PRDs or features into actionable tasks
   - Two-phase approach: parent tasks → "Go" → sub-tasks
   - Identifies relevant files and test requirements
   - Keywords: "generate tasks", "break down feature", "task list", "how do I generate tasks"

4. **sc-architecture** - System design and technical decisions
   - Designing microservices, APIs, databases
   - Choosing technology stack
   - Planning infrastructure
   - Keywords: "design", "architecture", "tech stack", "database schema"

5. **sc-workflows** - Implementation planning
   - Creating implementation plans
   - Project estimation
   - Breaking down work
   - Keywords: "how to build", "create plan", "estimate effort"

**Example workflow:**
```
"use confidence-check to assess feasibility, then create-prd, then generate-tasks, then sc-architecture to design the system"
```

---

### 💻 Phase 2: Implementation

**When you're building the feature:**

1. **sc-agent** - Orchestrate the entire implementation
   - Coordinates all phases (investigate → implement → review)
   - Delegates to other skills as needed
   - TDD (test-driven development) enforcement
   - Keywords: "build", "implement", "create feature"

2. **sc-security** - Security-focused implementations
   - Authentication/authorization
   - Encryption, GDPR compliance
   - Security hardening
   - Keywords: "secure", "authentication", "encryption", "OWASP"

3. **sc-quality** - Test-driven development
   - Write tests first (TDD)
   - Unit, integration, E2E tests
   - Keywords: "test", "TDD", "write tests first"

4. **deep-research** - Research unfamiliar topics
   - Investigating new technologies
   - Finding best practices
   - Learning how others solved similar problems
   - Keywords: "research", "how does X work", "best practices for"

**Example workflow:**
```
"use sc-agent to implement secure user authentication with TDD"
→ sc-agent orchestrates: confidence-check → sc-security (auth) → sc-quality (tests) → self-review
```

---

### 🔍 Phase 3: Review & Validation

**When you've completed implementation:**

1. **self-review** - ALWAYS use this after implementation!
   - Evidence-based validation
   - Checks tests, edge cases, requirements
   - Identifies risks and follow-up steps
   - Keywords: "review", "validate", "did I do this right"

2. **sc-workflows** - Code review
   - Review checklist
   - Quality assessment
   - Security and performance review
   - Keywords: "code review", "review PR", "check quality"

**Example workflow:**
```
"use self-review to validate authentication implementation"
```

---

### ⚡ Phase 4: Optimization & Debugging

**When you need to improve or fix existing code:**

1. **sc-workflows** - Troubleshooting
   - Debugging errors
   - Root cause analysis
   - Systematic problem-solving
   - Keywords: "troubleshoot", "debug", "not working", "error"

2. **sc-performance** - Performance optimization
   - Slow queries, APIs, page loads
   - Caching, profiling, load testing
   - Keywords: "slow", "optimize", "performance", "latency"

3. **sc-quality** - Refactoring & cleanup
   - Code cleanup
   - Technical debt reduction
   - Improving test coverage
   - Keywords: "refactor", "cleanup", "technical debt", "improve quality"

**Example workflow:**
```
"use sc-workflows to troubleshoot slow API, then sc-performance to optimize it"
```

---

### 📚 Phase 5: Documentation & Maintenance

**When you need to document or understand code:**

1. **repo-index** - Quick codebase overview
   - Get oriented in a new codebase
   - Understand project structure
   - Keywords: "what is this project", "overview", "structure"

2. **index-repo** - Generate comprehensive index
   - Create PROJECT_INDEX.md (94% token reduction)
   - Document entry points, modules, dependencies
   - Keywords: "generate index", "document structure"

3. **sc-workflows** - Generate documentation
   - API documentation
   - User guides
   - Technical specs
   - Keywords: "document", "generate docs", "API docs"

4. **sc-workflows** - Code analysis & explanation
   - Understand unfamiliar code
   - Explain how code works
   - Keywords: "explain", "analyze code", "how does this work"

---

## Skill Selection by Task Type

### 🏗️ System Design & Architecture
**Use:** sc-architecture
- Microservices decomposition
- API design (REST/GraphQL)
- Database architecture
- Technology stack selection
- Infrastructure planning
- Event-driven architecture
- Caching strategy
- CI/CD pipeline design

### 🔒 Security & Compliance
**Use:** sc-security
- Authentication implementation (JWT, OAuth)
- Authorization (RBAC, ABAC)
- Security audits (OWASP Top 10)
- Encryption & data protection
- GDPR, HIPAA, PCI-DSS compliance
- API security hardening
- Threat modeling
- Incident response planning

### 🔧 Development Workflows
**Use:** sc-workflows
- Troubleshooting & debugging
- Root cause analysis (5 Whys)
- Code analysis & explanation
- Documentation generation
- Project estimation
- Implementation planning
- Code cleanup & refactoring
- Code review processes

### ⚡ Performance Optimization
**Use:** sc-performance
- Performance profiling
- Database query optimization
- Caching implementation
- Frontend optimization (bundle size, lazy loading)
- API response optimization
- Memory optimization (leak detection)
- Load testing & capacity planning
- Scalability assessment

### ✅ Quality & Testing
**Use:** sc-quality
- Test strategy design
- Unit testing (with mocks)
- Integration testing
- End-to-end testing (Playwright/Cypress)
- Test coverage analysis
- Code review processes
- Refactoring strategies
- Technical debt assessment
- Quality metrics dashboards
- CI/CD quality gates

---

## Common Workflows by Scenario

### Scenario 1: Building a New Feature

**"I need to build a shopping cart feature"**

**Recommended workflow:**
```
1. use confidence-check to assess complexity and feasibility
2. use create-prd for shopping cart feature
3. use generate-tasks from prd-shopping-cart.md
4. use sc-architecture to design cart data model and API
5. use sc-agent to implement with TDD (tests first, then code)
6. use self-review to validate implementation
```

**Quick workflow (for simpler features):**
```
1. use confidence-check to assess complexity
2. use generate-tasks to break down shopping cart implementation
3. use sc-agent to implement
4. use self-review to validate
```

---

### Scenario 2: Fixing a Production Issue

**"Users are reporting slow checkout process"**

**Recommended workflow:**
```
1. use sc-workflows to troubleshoot and identify root cause
2. use sc-performance to profile and optimize bottlenecks
3. use sc-quality to add regression tests
4. use self-review to validate fix
```

---

### Scenario 3: Security Audit

**"We need to prepare for SOC 2 audit"**

**Recommended workflow:**
```
1. use sc-security for OWASP Top 10 security audit
2. use sc-security to implement missing security controls
3. use sc-security for GDPR compliance review
4. use sc-workflows to generate security documentation
```

---

### Scenario 4: Improving Code Quality

**"Our test coverage is low and code is messy"**

**Recommended workflow:**
```
1. use sc-quality to assess technical debt
2. use sc-workflows to create refactoring plan
3. use sc-quality to implement test strategy (80% coverage)
4. use sc-quality to set up CI/CD quality gates
```

---

### Scenario 5: Scaling for Growth

**"We're expecting 10x traffic increase, how do we prepare?"**

**Recommended workflow:**
```
1. use sc-performance for load testing (establish baseline)
2. use sc-performance for scalability assessment
3. use sc-architecture to design scaling strategy (caching, horizontal scaling)
4. use sc-architecture for infrastructure planning (IaC, auto-scaling)
5. use sc-performance to re-test after optimizations
```

---

## Quick Decision Tree

**Start here and follow the questions:**

1. **Is this a new feature or project?**
   - Yes → confidence-check (assess feasibility)
   - No → Go to #2

2. **Do I need to design/plan something?**
   - System architecture → sc-architecture
   - Implementation plan → sc-workflows (Task 6: Implementation Planning)
   - No design needed → Go to #3

3. **Am I implementing code now?**
   - Yes, orchestrated workflow → sc-agent
   - Yes, security-focused → sc-security
   - Yes, need to write tests → sc-quality
   - No → Go to #4

4. **Am I reviewing/validating?**
   - Validating my work → self-review
   - Reviewing someone else's code → sc-workflows (Task 8: Code Review)
   - No → Go to #5

5. **Is there a problem/issue?**
   - Troubleshooting/debugging → sc-workflows (Task 1: Troubleshooting)
   - Performance issue → sc-performance
   - Security issue → sc-security
   - No problem → Go to #6

6. **Am I optimizing/improving?**
   - Performance optimization → sc-performance
   - Code refactoring → sc-workflows (Task 7) or sc-quality (Task 7)
   - Test coverage → sc-quality
   - No optimizing → Go to #7

7. **Do I need documentation/understanding?**
   - Generate docs → sc-workflows (Task 4: Generate Documentation)
   - Understand code → sc-workflows (Task 3: Code Analysis)
   - Understand codebase → repo-index
   - Create index → index-repo
   - No docs needed → Ask me your specific goal!

---

## Skill Combinations (Multi-Skill Workflows)

### Complete Feature Development
```
confidence-check → sc-architecture → sc-security → sc-agent → sc-quality → self-review
```

### Security-First Implementation
```
confidence-check → sc-security (threat model) → sc-architecture (secure design) →
sc-security (implement) → sc-security (audit) → self-review
```

### Performance-Optimized Feature
```
sc-architecture (scalable design) → sc-performance (caching strategy) →
sc-agent (implement) → sc-performance (load test) → self-review
```

### Legacy Code Modernization
```
repo-index (understand codebase) → sc-workflows (analyze code) →
sc-quality (technical debt assessment) → sc-workflows (refactoring plan) →
sc-agent (implement refactoring) → sc-quality (add tests) → self-review
```

---

## Tips for Effective Skill Usage

1. **Always start with confidence-check for new work**
   - Prevents wasted effort on wrong approaches
   - ROI: 100-200 tokens saves 5,000-50,000 tokens

2. **Use sc-agent for orchestrated workflows**
   - It knows when to delegate to other skills
   - Enforces TDD (tests before implementation)
   - Includes validation steps

3. **Always end with self-review**
   - Evidence-based validation
   - Catches issues before they reach production

4. **Combine skills in parallel when possible**
   - Example: "use deep-research for best practices, then sc-architecture to design system"

5. **Use repo-index at the start of new sessions**
   - Get oriented quickly
   - Understand project structure

---

## Frequently Asked Questions

**Q: How do I create a PRD now?**
A: Use the `create-prd` skill! It generates comprehensive PRDs with clarifying questions.
```
use create-prd for [feature name]
```

**Q: How do I generate tasks now?**
A: Use the `generate-tasks` skill! It creates detailed task lists from PRDs or feature descriptions.
```
use generate-tasks from prd-[feature-name].md
```
or
```
use generate-tasks to break down [feature description]
```

**Q: What's the difference between create-prd and generate-tasks?**
A:
- `create-prd` creates **requirements** (what to build and why)
- `generate-tasks` creates **implementation steps** (how to build it)
- Workflow: create-prd → generate-tasks → implement

**Q: Do I need to use both create-prd and generate-tasks?**
A: Not always!
- For complex features: Yes, use both in sequence
- For simple features: Use generate-tasks directly with a description
- For strategic planning: Use create-prd alone

---

## Still Not Sure?

If you're still unsure which skill to use, just describe your goal in plain language:

**Examples:**
- "I need to add user authentication to my API"
- "My database queries are too slow"
- "I want to understand how this codebase works"
- "We need to improve our test coverage"
- "How do I secure this API endpoint?"

I'll analyze your request and recommend the right skill(s) to use!

---

## Skill Reference Summary

| Skill | Primary Use | Key Phrases |
|-------|-------------|-------------|
| **confidence-check** | Pre-implementation assessment | "should I", "is this feasible", "confidence" |
| **create-prd** | Product requirements | "create PRD", "write requirements", "product spec" |
| **generate-tasks** | Task breakdown | "generate tasks", "break down", "how do I generate tasks" |
| **sc-agent** | Orchestrated implementation | "build", "implement", "create feature" |
| **sc-architecture** | System design | "design", "architecture", "tech stack", "database" |
| **sc-security** | Security tasks | "secure", "authentication", "OWASP", "encryption" |
| **sc-workflows** | Dev workflows | "troubleshoot", "debug", "document", "plan", "review" |
| **sc-performance** | Performance optimization | "slow", "optimize", "profile", "cache", "load test" |
| **sc-quality** | Testing & quality | "test", "coverage", "refactor", "quality gate" |
| **deep-research** | Research topics | "research", "how does", "best practices" |
| **self-review** | Post-implementation validation | "review my work", "validate", "did I do this right" |
| **repo-index** | Codebase overview | "understand codebase", "project structure" |
| **index-repo** | Generate index | "generate PROJECT_INDEX.md", "document structure" |

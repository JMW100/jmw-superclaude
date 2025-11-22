# SC Workflows - Development Workflow Tasks

## When to Use This Skill

Use this skill for common development workflows and processes:
- Troubleshooting and debugging
- Root cause analysis
- Code analysis and explanation
- Documentation generation
- Project estimation
- Implementation planning
- Code cleanup and refactoring
- Review and validation workflows

## Integration with Other Skills

- Use **sc-agent** to orchestrate complex multi-workflow tasks
- Use **confidence-check** before major implementation planning
- Use **deep-research** to investigate unfamiliar codebases or technologies
- Use **sc-architecture** for system-level planning
- Use **sc-security** for security-focused troubleshooting
- Use **sc-performance** for performance-related debugging
- Use **self-review** after completing workflow tasks

## Available Tasks

### Task 1: Systematic Troubleshooting

**Triggers:** "troubleshoot", "debug", "fix issue", "not working", "error", "problem"

**When to Use:**
- Application errors or failures
- Unexpected behavior
- Performance issues
- Build or deployment problems

**Protocol:**

1. **Reproduce the Issue**
   - Gather error messages and stack traces
   - Identify steps to reproduce
   - Determine consistency (always vs intermittent)
   - Test in different environments (dev, staging, prod)

2. **Gather Context**
   - When did it start? (recent deploy, config change)
   - What changed? (code, dependencies, infrastructure)
   - Who is affected? (all users, specific segment)
   - What is the impact? (severity, user count, revenue)

3. **Isolate the Problem**
   - Check logs (application, system, database)
   - Review recent commits
   - Test with minimal configuration
   - Binary search (roll back changes one by one)

4. **Form Hypothesis**
   - Based on symptoms and context
   - Predict what should fix it
   - Test hypothesis with small experiment

5. **Implement Fix**
   - Apply minimal change
   - Test thoroughly
   - Monitor after deployment
   - Document the fix and root cause

**Output Format:**
```
## Troubleshooting Report: [Issue Description]

### Problem Statement
- **Issue**: Users unable to login after deployment
- **Severity**: P0 - Critical (blocks all users)
- **Discovered**: 2025-01-15 14:30 UTC
- **Impact**: 100% of users, ~5000 login attempts failed

### Symptoms
- HTTP 500 error on POST /api/auth/login
- Error message: "Internal Server Error"
- Stack trace shows database connection failure

### Recent Changes
- Deployment at 14:15 UTC (commit abc123)
- Database migration applied (add users.mfa_enabled column)
- No infrastructure changes

### Investigation Steps

**Step 1: Reproduce**
- ✅ Reproduced in staging
- ✅ Error consistent (100% failure rate)
- ✅ Same error in logs

**Step 2: Check Logs**
```
[ERROR] Database connection failed: password authentication failed
[ERROR] Connection string: postgres://user@db:5432/app
```

**Step 3: Hypothesis**
- Database password changed or expired?
- Database connection pool exhausted?
- Migration broke authentication query?

**Step 4: Investigation**
- ✅ Checked environment variables: DB_PASSWORD present
- ✅ Tested direct DB connection: Works manually
- ❌ Connection pool: Only 5/100 connections used
- ✅ Migration logs: Migration applied successfully

**Step 5: Root Cause**
Database migration added NOT NULL column without default value.
Existing login query failed with "column cannot be null" error.

```sql
-- Migration
ALTER TABLE users ADD COLUMN mfa_enabled BOOLEAN NOT NULL;
-- Should have been:
ALTER TABLE users ADD COLUMN mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE;
```

### Solution
1. Rollback deployment (immediate fix)
2. Update migration with DEFAULT FALSE
3. Re-deploy with corrected migration
4. Verify login functionality

### Fix Implementation
```sql
-- Corrected migration
ALTER TABLE users ADD COLUMN mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE;
```

**Timeline:**
- 14:30: Issue discovered
- 14:35: Incident declared (P0)
- 14:40: Root cause identified
- 14:45: Rollback deployed
- 14:50: Service restored
- 15:00: Corrected migration deployed
- **Total downtime**: 20 minutes

### Prevention
- [ ] Add pre-deployment migration testing
- [ ] Require default values for NOT NULL columns
- [ ] Staged rollout (canary deployment)
- [ ] Better error messages (expose migration errors)

### Post-Mortem Actions
1. Update migration guidelines (require defaults)
2. Add migration smoke tests to CI/CD
3. Improve database error logging
```

**Quality Checks:**
- [ ] Issue clearly reproduced
- [ ] Root cause identified (not just symptoms)
- [ ] Fix tested before deployment
- [ ] Impact and timeline documented
- [ ] Prevention steps identified
- [ ] Post-mortem completed

**Example Invocation:**
"use sc-workflows to troubleshoot login failures after deployment"

---

### Task 2: Root Cause Analysis (5 Whys)

**Triggers:** "root cause", "why did this happen", "5 whys", "RCA", "post-mortem"

**When to Use:**
- After incidents or outages
- Recurring problems
- Learning from failures
- Process improvements

**Protocol:**

1. **Define the Problem**
   - Clear, specific statement
   - Observable facts only
   - No assumptions or blame

2. **Ask "Why?" 5 Times**
   - Why #1: Immediate cause
   - Why #2: Underlying factor
   - Why #3: Process gap
   - Why #4: System issue
   - Why #5: Root cause

3. **Identify Contributing Factors**
   - Technical factors (code, infrastructure)
   - Process factors (review, testing, deployment)
   - Human factors (communication, training)

4. **Define Corrective Actions**
   - Immediate fixes (symptoms)
   - Long-term fixes (root cause)
   - Process improvements
   - Assign owners and deadlines

5. **Follow-Up**
   - Track corrective action completion
   - Verify effectiveness
   - Share learnings

**Output Format:**
```
## Root Cause Analysis: Database Outage (2025-01-15)

### Problem Statement
Production database went offline for 3 hours on 2025-01-15, affecting all application functionality.

### 5 Whys Analysis

**Why #1: Why did the database go offline?**
→ Database ran out of disk space

**Why #2: Why did it run out of disk space?**
→ Database logs filled the disk (50GB of logs)

**Why #3: Why did logs fill the disk?**
→ Log rotation was not configured (logs never deleted)

**Why #4: Why was log rotation not configured?**
→ Default PostgreSQL configuration used, which doesn't enable log rotation

**Why #5: Why was default configuration used?**
→ Infrastructure-as-Code templates lacked database logging configuration

**ROOT CAUSE**: Infrastructure templates missing production-ready database configuration

### Contributing Factors

**Technical:**
- Default PostgreSQL logging configuration
- No disk space monitoring/alerting
- No automated log rotation

**Process:**
- Infrastructure templates not reviewed for production readiness
- No pre-production environment validation
- Missing operational runbook

**Human:**
- Team unfamiliar with PostgreSQL production best practices
- Assumption that defaults were production-ready

### Impact Assessment
- **Duration**: 3 hours (10:00 - 13:00 UTC)
- **Users Affected**: 100% (all application features)
- **Revenue Impact**: $15,000 (estimated)
- **Requests Failed**: ~50,000

### Corrective Actions

**Immediate (Within 24h):**
- [x] Clear old logs manually
- [x] Enable log rotation (completed)
- [x] Add disk space monitoring (CloudWatch alarm at 80%)

**Short-term (Within 1 week):**
- [ ] Update IaC templates with production PostgreSQL config
- [ ] Add disk space alerts for all databases
- [ ] Create database operational runbook
- **Owner**: DevOps Team | **Due**: 2025-01-22

**Long-term (Within 1 month):**
- [ ] Infrastructure template review process
- [ ] Pre-production validation checklist
- [ ] PostgreSQL training for team
- [ ] Automated capacity planning
- **Owner**: Engineering Leadership | **Due**: 2025-02-15

### Verification Plan
- Monitor disk space weekly (next 4 weeks)
- Review all IaC templates for production readiness
- Conduct tabletop exercise (simulate disk full)

### Lessons Learned
1. **What went well:**
   - Quick incident response (detected within 10min)
   - Clear communication to stakeholders
   - Root cause found quickly

2. **What didn't go well:**
   - No monitoring prevented early detection
   - Default configurations not reviewed
   - No operational runbook

3. **Surprising insights:**
   - PostgreSQL logs can grow extremely fast (10GB/day)
   - Default configs are development-focused, not production-ready

### Prevention Checklist
For all future infrastructure:
- [ ] Production-ready configuration review
- [ ] Monitoring and alerting configured
- [ ] Log rotation enabled
- [ ] Disk space alerts
- [ ] Operational runbook created
- [ ] Tested in pre-production environment
```

**Quality Checks:**
- [ ] Problem clearly stated (factual)
- [ ] "Why?" asked 5 times (reached root cause)
- [ ] Contributing factors identified
- [ ] Corrective actions defined with owners/deadlines
- [ ] Impact quantified
- [ ] Lessons learned documented
- [ ] Follow-up plan defined

**Example Invocation:**
"use sc-workflows for root cause analysis of production outage"

---

### Task 3: Code Analysis & Explanation

**Triggers:** "explain code", "analyze code", "understand codebase", "what does this do", "code review"

**When to Use:**
- Understanding unfamiliar code
- Onboarding new team members
- Code review preparation
- Legacy codebase exploration
- Refactoring planning

**Protocol:**

1. **High-Level Overview**
   - Purpose of the code (what problem it solves)
   - Entry points (main functions, API endpoints)
   - Key dependencies and libraries
   - Overall architecture pattern

2. **Component Breakdown**
   - Major modules/classes and their responsibilities
   - Data flow (input → processing → output)
   - Important functions and their purposes
   - State management

3. **Code Quality Assessment**
   - Readability and maintainability
   - Design patterns used
   - Test coverage
   - Potential issues or code smells

4. **Improvement Opportunities**
   - Refactoring suggestions
   - Performance optimizations
   - Security concerns
   - Documentation gaps

**Output Format:**
```
## Code Analysis: Authentication Service

### Overview
- **Purpose**: Handle user authentication (login, logout, token refresh)
- **Language**: Node.js / TypeScript
- **Framework**: Express.js
- **Lines of Code**: ~500 LOC
- **Last Modified**: 2025-01-10

### Architecture Pattern
**Layered Architecture**:
- Controller Layer: HTTP request handling
- Service Layer: Business logic
- Repository Layer: Database access

### Entry Points

**1. POST /api/auth/login**
- Handler: `authController.login`
- Purpose: Authenticate user and issue JWT tokens
- Flow: Validate credentials → Generate tokens → Set cookies

**2. POST /api/auth/refresh**
- Handler: `authController.refresh`
- Purpose: Issue new access token using refresh token
- Flow: Validate refresh token → Generate new access token

**3. POST /api/auth/logout**
- Handler: `authController.logout`
- Purpose: Invalidate tokens and end session
- Flow: Revoke refresh token → Clear cookies

### Component Breakdown

**authController.ts** (150 LOC)
```typescript
// Purpose: HTTP request/response handling
export class AuthController {
  async login(req, res) {
    // 1. Extract credentials from request
    // 2. Call authService.authenticate()
    // 3. Return tokens or error
  }

  async refresh(req, res) {
    // 1. Extract refresh token from cookie
    // 2. Call authService.refreshAccessToken()
    // 3. Return new access token
  }

  async logout(req, res) {
    // 1. Extract refresh token
    // 2. Call authService.revokeToken()
    // 3. Clear cookies
  }
}
```

**authService.ts** (200 LOC)
```typescript
// Purpose: Authentication business logic
export class AuthService {
  async authenticate(email: string, password: string): Promise<Tokens> {
    // 1. Find user by email
    // 2. Compare password hash (bcrypt)
    // 3. Generate JWT access + refresh tokens
    // 4. Store refresh token in database
    // 5. Return tokens
  }

  async refreshAccessToken(refreshToken: string): Promise<string> {
    // 1. Verify refresh token signature
    // 2. Check if revoked (database lookup)
    // 3. Generate new access token
    // 4. Return new access token
  }

  async revokeToken(refreshToken: string): Promise<void> {
    // 1. Mark token as revoked in database
  }
}
```

**authRepository.ts** (100 LOC)
```typescript
// Purpose: Database operations
export class AuthRepository {
  async findUserByEmail(email: string): Promise<User | null>
  async storeRefreshToken(userId: string, token: string): Promise<void>
  async isTokenRevoked(token: string): Promise<boolean>
  async revokeToken(token: string): Promise<void>
}
```

**tokenUtils.ts** (50 LOC)
```typescript
// Purpose: JWT token generation and validation
export function generateAccessToken(payload): string
export function generateRefreshToken(payload): string
export function verifyToken(token: string): DecodedToken | null
```

### Data Flow

**Login Flow:**
```
1. User submits email + password
2. Controller → Service.authenticate(email, password)
3. Service → Repository.findUserByEmail(email)
4. Service → bcrypt.compare(password, user.password_hash)
5. Service → generateAccessToken() & generateRefreshToken()
6. Service → Repository.storeRefreshToken()
7. Controller → Set cookies (httpOnly, secure)
8. Controller → Return success response
```

### Code Quality Assessment

**Strengths:**
- ✅ Clear separation of concerns (Controller, Service, Repository)
- ✅ TypeScript for type safety
- ✅ Passwords hashed with bcrypt (secure)
- ✅ JWT tokens with appropriate expiry (15min access, 7d refresh)
- ✅ httpOnly cookies (XSS protection)

**Issues/Code Smells:**
- ⚠️ **No rate limiting**: Vulnerable to brute force attacks
- ⚠️ **No input validation**: Missing email format validation
- ⚠️ **Error messages too detailed**: "User not found" vs "Invalid password" reveals which users exist
- ⚠️ **No logging**: No audit trail of login attempts
- ⚠️ **Synchronous bcrypt**: Should use async version for non-blocking
- ⚠️ **No tests**: Test coverage 0%

**Security Concerns:**
- 🔒 Missing rate limiting (5 attempts per 15min recommended)
- 🔒 Detailed error messages (user enumeration vulnerability)
- 🔒 No account lockout after failed attempts
- 🔒 No MFA support

### Improvement Opportunities

**Priority 1 (Security):**
1. Add rate limiting middleware
```typescript
import rateLimit from 'express-rate-limit';
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts, try again later'
});
app.use('/api/auth/login', loginLimiter);
```

2. Generic error messages
```typescript
// Instead of:
if (!user) throw new Error('User not found');
if (!valid) throw new Error('Invalid password');

// Use:
if (!user || !valid) throw new Error('Invalid credentials');
```

3. Add input validation
```typescript
import { body, validationResult } from 'express-validator';
app.post('/api/auth/login',
  body('email').isEmail(),
  body('password').isLength({ min: 8 }),
  authController.login
);
```

**Priority 2 (Observability):**
4. Add audit logging
```typescript
await auditLog.create({
  event: 'LOGIN_ATTEMPT',
  userId: user?.id,
  email,
  success: !!validPassword,
  ipAddress: req.ip,
  userAgent: req.headers['user-agent'],
});
```

**Priority 3 (Code Quality):**
5. Add tests (target: 80% coverage)
6. Use async bcrypt
```typescript
// Instead of:
const valid = bcrypt.compareSync(password, user.password_hash);
// Use:
const valid = await bcrypt.compare(password, user.password_hash);
```

7. Extract constants
```typescript
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';
const BCRYPT_ROUNDS = 12;
```

### Refactoring Suggestions
1. Extract validation middleware
2. Add DTOs (Data Transfer Objects) for type safety
3. Implement repository interface for testability
4. Add comprehensive JSDoc comments

### Test Coverage
- **Current**: 0%
- **Target**: 80%
- **Missing tests**:
  - Unit tests for AuthService
  - Integration tests for auth endpoints
  - Security tests (brute force, token tampering)
```

**Quality Checks:**
- [ ] High-level overview provided
- [ ] Entry points identified
- [ ] Data flow documented
- [ ] Code quality assessed
- [ ] Security concerns identified
- [ ] Improvement opportunities prioritized
- [ ] Examples provided for key improvements

**Example Invocation:**
"use sc-workflows to analyze and explain authentication service code"

---

### Task 4: Generate Documentation

**Triggers:** "generate docs", "document code", "create documentation", "API docs", "write readme"

**When to Use:**
- Documenting new code or APIs
- Creating README files
- API reference generation
- User guides and tutorials
- Architecture documentation

**Protocol:**

1. **Identify Documentation Type**
   - API Reference (endpoint documentation)
   - User Guide (how to use)
   - Technical Spec (architecture, design decisions)
   - README (project overview, quick start)
   - Code Comments (inline documentation)

2. **Gather Information**
   - Code analysis (functions, classes, endpoints)
   - Existing documentation to update
   - User stories and requirements
   - Examples and use cases

3. **Structure Documentation**
   - Clear sections and hierarchy
   - Consistent formatting
   - Code examples with explanations
   - Visual aids (diagrams, tables)

4. **Write Documentation**
   - Audience-appropriate language
   - Step-by-step instructions
   - Working examples
   - Common pitfalls and troubleshooting

5. **Review and Update**
   - Technical accuracy
   - Completeness
   - Clarity and readability
   - Keep up-to-date with code changes

**Output Format:**
```
## API Documentation: User Management API

### Overview
The User Management API allows you to create, read, update, and delete user accounts.

**Base URL:** `https://api.example.com/v1`
**Authentication:** Bearer token (JWT)
**Rate Limit:** 1000 requests/hour per API key

---

### Endpoints

#### Create User

**POST** `/users`

Create a new user account.

**Request Headers:**
```http
Content-Type: application/json
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "name": "John Doe",
  "role": "user"
}
```

**Request Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | Valid email address (unique) |
| password | string | Yes | Min 12 characters, must include uppercase, lowercase, number, symbol |
| name | string | Yes | Full name (2-100 characters) |
| role | string | No | User role: "user" (default), "admin" |

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "role": "user",
  "createdAt": "2025-01-15T10:30:00Z"
}
```

**Error Responses:**

**400 Bad Request** - Invalid input
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      {"field": "email", "message": "Must be a valid email"}
    ]
  }
}
```

**409 Conflict** - Email already exists
```json
{
  "error": {
    "code": "USER_EXISTS",
    "message": "User with this email already exists"
  }
}
```

**Code Example (JavaScript):**
```javascript
const response = await fetch('https://api.example.com/v1/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${accessToken}`
  },
  body: JSON.stringify({
    email: 'john.doe@example.com',
    password: 'SecurePass123!',
    name: 'John Doe'
  })
});

const user = await response.json();
console.log('User created:', user.id);
```

**Code Example (Python):**
```python
import requests

response = requests.post(
    'https://api.example.com/v1/users',
    headers={
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    },
    json={
        'email': 'john.doe@example.com',
        'password': 'SecurePass123!',
        'name': 'John Doe'
    }
)

user = response.json()
print(f"User created: {user['id']}")
```

---

#### Get User

**GET** `/users/{id}`

Retrieve user details by ID.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| id | string (UUID) | User ID |

**Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "role": "user",
  "createdAt": "2025-01-15T10:30:00Z",
  "lastLogin": "2025-01-16T08:15:00Z"
}
```

**Error Responses:**

**404 Not Found** - User doesn't exist
```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User not found"
  }
}
```

---

#### List Users

**GET** `/users`

List all users with pagination.

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number (1-indexed) |
| limit | integer | 20 | Items per page (max 100) |
| role | string | all | Filter by role: "user", "admin", "all" |
| search | string | - | Search by name or email |

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "john.doe@example.com",
      "name": "John Doe",
      "role": "user"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "next": "/users?page=2&limit=20"
  }
}
```

---

### Authentication

All endpoints require authentication via JWT bearer token.

**Obtaining a Token:**
```bash
POST /auth/login
{
  "email": "user@example.com",
  "password": "password"
}

# Response
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 900
}
```

**Using the Token:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

---

### Rate Limiting

- **Limit:** 1000 requests/hour per API key
- **Headers:**
  - `X-RateLimit-Limit`: Total requests allowed
  - `X-RateLimit-Remaining`: Requests remaining
  - `X-RateLimit-Reset`: Unix timestamp when limit resets

**429 Too Many Requests:**
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests, retry after 3600 seconds"
  }
}
```

---

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| VALIDATION_ERROR | 400 | Invalid request parameters |
| UNAUTHORIZED | 401 | Missing or invalid authentication |
| FORBIDDEN | 403 | Insufficient permissions |
| USER_NOT_FOUND | 404 | User doesn't exist |
| USER_EXISTS | 409 | Email already registered |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Server error |

---

### Changelog

**v1.1.0** (2025-01-15)
- Added search parameter to list users
- Improved error messages

**v1.0.0** (2025-01-01)
- Initial release
```

**Quality Checks:**
- [ ] Clear overview and purpose
- [ ] All endpoints documented
- [ ] Request/response examples provided
- [ ] Error responses documented
- [ ] Code examples in multiple languages
- [ ] Authentication explained
- [ ] Rate limiting documented
- [ ] Versioning and changelog

**Example Invocation:**
"use sc-workflows to generate API documentation for user management endpoints"

---

### Task 5: Project Estimation

**Triggers:** "estimate", "how long", "effort estimation", "timeline", "planning poker"

**When to Use:**
- Sprint planning
- Project proposals
- Resource allocation
- Roadmap planning
- Budget planning

**Protocol:**

1. **Break Down Work**
   - Decompose into user stories/tasks
   - Identify dependencies
   - Define scope clearly
   - List assumptions

2. **Estimate Tasks**
   - Use story points or time estimates
   - Consider complexity, uncertainty, effort
   - Include testing, code review, documentation
   - Add buffer for unknowns

3. **Account for Overhead**
   - Meetings and planning (10-15%)
   - Code review (10-20%)
   - Bug fixes (15-20%)
   - Testing and QA (20-30%)
   - Documentation (5-10%)

4. **Calculate Timeline**
   - Sum estimates
   - Apply team velocity
   - Account for parallelization
   - Add contingency (20-30%)

5. **Risk Assessment**
   - Technical risks
   - Dependency risks
   - Resource risks
   - Mitigation strategies

**Output Format:**
```
## Project Estimation: E-commerce Checkout Flow

### Scope
Build complete checkout flow including cart, shipping, payment, and order confirmation.

### Requirements
1. Shopping cart (add/remove/update items)
2. Shipping address form
3. Payment integration (Stripe)
4. Order summary and confirmation
5. Email notifications
6. Order history

### Assumptions
- Using existing user authentication
- Stripe API for payments (no PCI compliance needed)
- Email service already configured (SendGrid)
- 2 developers available full-time
- No major holidays or PTO during project

### Task Breakdown

#### Epic 1: Shopping Cart (8 points / 2 weeks)
| Task | Story Points | Notes |
|------|--------------|-------|
| Backend: Cart API (CRUD) | 3 | PostgreSQL, Redis for session |
| Frontend: Cart component | 2 | React, state management |
| Cart persistence (logged-in users) | 2 | Database integration |
| Testing | 1 | Unit + integration tests |

#### Epic 2: Shipping & Address (5 points / 1.5 weeks)
| Task | Story Points | Notes |
|------|--------------|-------|
| Address validation API | 2 | Google Maps API integration |
| Shipping address form | 2 | Multi-step form, validation |
| Address book (save addresses) | 1 | CRUD for saved addresses |

#### Epic 3: Payment Integration (13 points / 3 weeks)
| Task | Story Points | Notes |
|------|--------------|-------|
| Stripe integration (backend) | 5 | Payment intent, webhooks |
| Payment form (frontend) | 3 | Stripe Elements, card validation |
| Error handling & edge cases | 2 | Failed payments, retries |
| PCI compliance review | 2 | Security audit |
| Testing (including test payments) | 1 | Stripe test mode |

#### Epic 4: Order Management (8 points / 2 weeks)
| Task | Story Points | Notes |
|------|--------------|-------|
| Order creation & storage | 3 | Database schema, API |
| Order confirmation page | 2 | Summary, receipt |
| Email notifications | 2 | Templates, SendGrid |
| Order history page | 1 | List, detail view |

#### Epic 5: Testing & QA (5 points / 1.5 weeks)
| Task | Story Points | Notes |
|------|--------------|-------|
| E2E testing | 2 | Playwright, full checkout flow |
| Security testing | 1 | OWASP, payment security |
| Performance testing | 1 | Load testing (1000 concurrent) |
| User acceptance testing | 1 | Internal team testing |

#### Epic 6: Documentation & Deployment (3 points / 1 week)
| Task | Story Points | Notes |
|------|--------------|-------|
| API documentation | 1 | OpenAPI/Swagger |
| User guide | 1 | How to checkout, troubleshooting |
| Deployment & monitoring | 1 | Production deploy, alerts |

### Estimation Summary

| Epic | Story Points | Estimated Time |
|------|--------------|----------------|
| Shopping Cart | 8 | 2 weeks |
| Shipping & Address | 5 | 1.5 weeks |
| Payment Integration | 13 | 3 weeks |
| Order Management | 8 | 2 weeks |
| Testing & QA | 5 | 1.5 weeks |
| Documentation & Deployment | 3 | 1 week |
| **Total** | **42** | **11 weeks** |

### Effort Breakdown
- **Development**: 60% (6.6 weeks)
- **Testing**: 20% (2.2 weeks)
- **Code Review**: 10% (1.1 weeks)
- **Documentation**: 5% (0.55 weeks)
- **Meetings/Planning**: 5% (0.55 weeks)

### Team Capacity
- **Team Size**: 2 developers
- **Velocity**: 8 story points/week (per developer)
- **Combined Velocity**: 16 points/week
- **Calculation**: 42 points ÷ 16 points/week = 2.6 weeks ideal time
- **With Overhead**: 2.6 weeks × 2.5 (overhead factor) = **6.5 weeks**

### Realistic Timeline
- **Best Case**: 6 weeks (everything goes smoothly)
- **Most Likely**: 8 weeks (some minor issues)
- **Worst Case**: 10 weeks (major blockers, sick leave)
- **Recommended**: **8 weeks** (with 20% buffer)

### Dependencies
- Stripe account approval (1-2 days)
- Google Maps API key (immediate)
- SendGrid email templates (1 week lead time)
- Security review approval (1 week)

### Risks & Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stripe integration complexity | High | Medium | Prototype early (week 1) |
| PCI compliance issues | High | Low | Use Stripe Elements (tokenization) |
| Performance under load | Medium | Medium | Load testing in week 6 |
| Developer unavailability | High | Low | Cross-train team members |
| Scope creep | High | Medium | Lock requirements, change control |

### Milestones
- **Week 2**: Shopping cart complete (demo-able)
- **Week 4**: Shipping & address complete
- **Week 6**: Payment integration complete (test mode)
- **Week 7**: Full checkout flow working end-to-end
- **Week 8**: Testing, docs, production deployment

### Confidence Level
- **High Confidence** (70%): 8 weeks
- **Medium Confidence** (20%): 6-7 weeks (if no blockers)
- **Low Confidence** (10%): 10+ weeks (if major issues)

**Recommendation**: Plan for **8-week timeline** with option to deliver MVP in 6 weeks if needed.
```

**Quality Checks:**
- [ ] Work broken down into manageable tasks
- [ ] Story points or time estimates provided
- [ ] Overhead accounted for (testing, review, docs)
- [ ] Team capacity considered
- [ ] Dependencies identified
- [ ] Risks assessed with mitigation
- [ ] Multiple scenarios (best/likely/worst case)
- [ ] Milestones defined

**Example Invocation:**
"use sc-workflows to estimate effort for e-commerce checkout feature"

---

### Task 6: Implementation Planning

**Triggers:** "create plan", "implementation plan", "how to build", "development plan", "roadmap"

**When to Use:**
- Starting new features
- Complex implementations
- Multi-phase projects
- Team coordination

**Protocol:**

1. **Define Goals and Requirements**
   - What are we building?
   - Why are we building it?
   - Success criteria
   - Non-functional requirements (performance, security)

2. **Technical Approach**
   - Architecture decisions
   - Technology choices
   - Design patterns
   - Integration points

3. **Break Down Phases**
   - Phase 1: MVP (minimum viable product)
   - Phase 2: Core features
   - Phase 3: Polish and optimization
   - Dependencies between phases

4. **Define Tasks per Phase**
   - Backend tasks
   - Frontend tasks
   - Testing tasks
   - DevOps tasks

5. **Create Timeline**
   - Assign tasks to sprints/weeks
   - Identify parallel work
   - Set milestones

**Output Format:**
```
## Implementation Plan: Real-Time Notification System

### Goals
Build real-time notification system for user events (new message, order update, system alerts).

### Success Criteria
- [ ] Notifications delivered within 1 second
- [ ] Support 10,000 concurrent WebSocket connections
- [ ] 99.9% delivery reliability
- [ ] Works on web and mobile
- [ ] Scalable to 1M users

### Non-Functional Requirements
- **Performance**: <1s latency, <100ms jitter
- **Scalability**: Horizontal scaling, 10K connections per server
- **Reliability**: Message persistence, retry on failure
- **Security**: Authentication, encrypted connections (WSS)

---

### Technical Approach

**Architecture:**
- WebSocket server (Socket.io / ws library)
- Redis Pub/Sub for cross-server messaging
- Message queue (RabbitMQ) for reliability
- PostgreSQL for notification history

**Technology Stack:**
- **Backend**: Node.js (WebSocket server), Go (API server)
- **Real-time**: Socket.io (WebSocket abstraction)
- **Messaging**: Redis Pub/Sub + RabbitMQ
- **Frontend**: Socket.io-client (React)
- **Mobile**: Socket.io-client (React Native)

**Design Decisions:**
- Socket.io over raw WebSocket (fallback to polling, easier reconnection)
- Redis Pub/Sub for low-latency cross-server messaging
- RabbitMQ for persistent queuing (offline users)
- Load balancer with sticky sessions (same server per user)

---

### Implementation Phases

#### Phase 1: MVP (Week 1-2) - Basic WebSocket Server

**Goal**: Single-server WebSocket connection with simple notifications

**Tasks:**
1. **Backend: WebSocket Server** (3 days)
   - Set up Socket.io server
   - Authentication (JWT verification)
   - Handle connect/disconnect events
   - Basic event emitting (server → client)

2. **Frontend: WebSocket Client** (2 days)
   - Socket.io-client integration
   - Connect on user login
   - Listen for notifications
   - Display toast notification

3. **API Integration** (2 days)
   - Trigger notification from API endpoint
   - Example: POST /orders → emit 'order.created' event

4. **Testing** (1 day)
   - Manual testing (send test notifications)
   - Basic load test (100 concurrent connections)

**Deliverable**: Single-server notification system (demo-able)

---

#### Phase 2: Scalability & Persistence (Week 3-4) - Multi-Server

**Goal**: Horizontal scaling with Redis Pub/Sub

**Tasks:**
1. **Redis Pub/Sub Integration** (2 days)
   - WebSocket servers subscribe to Redis channels
   - API publishes messages to Redis
   - Redis broadcasts to all WebSocket servers

2. **Database Schema** (1 day)
   - notifications table (id, user_id, type, data, read, created_at)
   - Store all notifications for history

3. **Notification History API** (2 days)
   - GET /notifications (paginated list)
   - PATCH /notifications/:id/read (mark as read)
   - Unread count endpoint

4. **Load Balancer Configuration** (1 day)
   - NGINX with sticky sessions (ip_hash)
   - Health checks for WebSocket servers
   - Failover configuration

5. **Testing** (2 days)
   - Multi-server test (3 WebSocket servers)
   - Load test (5,000 concurrent connections)
   - Failover test (kill one server)

**Deliverable**: Multi-server scalable notification system

---

#### Phase 3: Reliability & Offline Support (Week 5-6)

**Goal**: Message persistence and offline user support

**Tasks:**
1. **RabbitMQ Integration** (3 days)
   - Queue per user (or per user group)
   - API publishes to RabbitMQ
   - WebSocket servers consume from queues
   - Acknowledgment after delivery

2. **Offline User Handling** (2 days)
   - Store notifications in database
   - On reconnect, fetch missed notifications
   - Send batch of missed notifications

3. **Retry Logic** (1 day)
   - Retry failed deliveries (exponential backoff)
   - Dead letter queue for failures
   - Alert on repeated failures

4. **Read Receipts** (1 day)
   - Client acknowledges received notification
   - Update delivery status in database

5. **Testing** (2 days)
   - Offline/online scenario testing
   - Message persistence verification
   - Retry logic validation

**Deliverable**: Reliable notification delivery (offline users)

---

#### Phase 4: Features & Polish (Week 7-8)

**Goal**: Production-ready features

**Tasks:**
1. **Notification Types** (2 days)
   - Order notifications (created, shipped, delivered)
   - Message notifications (new chat message)
   - System notifications (maintenance, updates)
   - Custom notification templates

2. **User Preferences** (2 days)
   - Enable/disable notification types
   - Preferences API + UI

3. **Mobile Push Notifications** (3 days)
   - Firebase Cloud Messaging (FCM) integration
   - Send push when user offline
   - Deep linking (tap notification → open app)

4. **Monitoring & Alerting** (2 days)
   - Metrics: connections, messages/sec, latency
   - Alerts: connection drops, high latency, queue backlog
   - Dashboard (Grafana)

5. **Documentation** (1 day)
   - API documentation
   - WebSocket event documentation
   - Operational runbook

**Deliverable**: Production-ready notification system

---

### Timeline Summary

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Phase 1: MVP | 2 weeks | Single-server working prototype |
| Phase 2: Scalability | 2 weeks | Multi-server with Redis |
| Phase 3: Reliability | 2 weeks | Offline support, RabbitMQ |
| Phase 4: Polish | 2 weeks | Production features |
| **Total** | **8 weeks** | Production-ready system |

### Sprint Breakdown (2-week sprints)

**Sprint 1 (Weeks 1-2): MVP**
- WebSocket server + client
- Basic notifications
- API integration

**Sprint 2 (Weeks 3-4): Scalability**
- Redis Pub/Sub
- Multi-server setup
- Load balancing

**Sprint 3 (Weeks 5-6): Reliability**
- RabbitMQ integration
- Offline user support
- Retry logic

**Sprint 4 (Weeks 7-8): Polish**
- Notification types & preferences
- Mobile push
- Monitoring & docs

---

### Parallel Work Opportunities

**Backend & Frontend:**
- Week 1: Backend (WebSocket server) || Frontend (Socket.io client)
- Week 3: Backend (Redis) || Frontend (notification history UI)

**Team Split:**
- **Developer 1**: Backend (WebSocket, Redis, RabbitMQ)
- **Developer 2**: Frontend (React, mobile)
- **DevOps**: Infrastructure (load balancer, monitoring)

---

### Risks & Mitigation

| Risk | Mitigation |
|------|------------|
| WebSocket scaling complexity | Start with Socket.io (proven scaling) |
| Message loss | RabbitMQ persistence + database storage |
| High latency | Load testing early (week 2, 4, 6) |
| Mobile push not working | Test FCM integration in week 7 |

---

### Milestones & Demos

- **Week 2**: Demo basic notifications (single server)
- **Week 4**: Demo multi-server with 1000 concurrent users
- **Week 6**: Demo offline user receiving missed notifications
- **Week 8**: Production deployment
```

**Quality Checks:**
- [ ] Goals and success criteria defined
- [ ] Technical approach documented
- [ ] Phases with clear deliverables
- [ ] Tasks broken down per phase
- [ ] Timeline with sprints/weeks
- [ ] Parallel work identified
- [ ] Risks and mitigation
- [ ] Milestones for demos

**Example Invocation:**
"use sc-workflows to create implementation plan for real-time notifications"

---

### Task 7: Code Cleanup & Refactoring

**Triggers:** "cleanup", "refactor", "improve code quality", "technical debt", "code smell"

**When to Use:**
- Code quality improvement
- Technical debt reduction
- Preparing for new features
- Post-incident cleanup

**Protocol:**

1. **Identify Issues**
   - Code smells (long functions, duplication)
   - Outdated dependencies
   - Unused code (dead code)
   - Inconsistent formatting
   - Missing documentation

2. **Prioritize Refactoring**
   - High-impact, low-effort (quick wins)
   - High-impact, high-effort (planned refactoring)
   - Low-impact (defer or skip)

3. **Plan Refactoring**
   - One change at a time
   - Ensure tests pass
   - Commit frequently
   - Review before/after

4. **Common Refactorings**
   - Extract function/method
   - Rename for clarity
   - Remove duplication (DRY)
   - Simplify conditionals
   - Update dependencies

5. **Validate**
   - Run all tests
   - Manual testing
   - Performance regression check
   - Code review

**Output Format:**
```
## Code Cleanup Plan: User Service

### Current State Assessment

**Issues Identified:**
1. ⚠️ Functions too long (>100 lines)
2. ⚠️ Code duplication (3 similar validation functions)
3. ⚠️ Inconsistent error handling
4. ⚠️ Outdated dependencies (5 packages)
5. ⚠️ No TypeScript types (using `any` everywhere)
6. ⚠️ Dead code (unused functions, 200 LOC)
7. ⚠️ Missing JSDoc comments

**Code Metrics:**
- **Lines of Code**: 2,000
- **Functions**: 45
- **Average Function Length**: 45 lines
- **Duplication**: 15%
- **Test Coverage**: 45%
- **Technical Debt**: ~40 hours

---

### Prioritized Refactoring Tasks

#### Priority 1: High Impact, Low Effort (Week 1)

**1. Remove Dead Code** (2 hours)
- Delete unused functions (identified by coverage tool)
- Remove commented code
- **Impact**: Reduce codebase by 10%, improve readability
```typescript
// REMOVE - Not used anywhere
function oldValidateEmail(email: string) { ... }
function deprecatedFormatDate(date: Date) { ... }
```

**2. Update Dependencies** (1 hour)
```bash
npm outdated
npm update

# Critical updates:
lodash: 4.17.15 → 4.17.21 (security fix)
axios: 0.21.1 → 1.6.0 (bug fixes)
```
- **Impact**: Security fixes, bug fixes
- **Risk**: Low (minor versions)

**3. Consistent Error Handling** (3 hours)
```typescript
// BEFORE - Inconsistent
throw new Error('User not found');
throw 'Invalid email';  // Bad!
return { error: 'Something went wrong' };  // Inconsistent!

// AFTER - Consistent
throw new AppError('USER_NOT_FOUND', 'User not found', 404);
throw new AppError('INVALID_EMAIL', 'Invalid email format', 400);
```
- **Impact**: Easier error handling, better error messages
- **Files affected**: 10

---

#### Priority 2: High Impact, Medium Effort (Week 2)

**4. Extract Validation Functions** (4 hours)

```typescript
// BEFORE - Duplicated validation in 3 places
if (!email || !email.includes('@')) {
  throw new Error('Invalid email');
}

// AFTER - Extract to validators.ts
import { validateEmail } from './validators';
validateEmail(email);  // Throws if invalid
```

**Duplication Removed:**
- Email validation (3 occurrences)
- Password validation (4 occurrences)
- Phone validation (2 occurrences)

**5. Break Down Long Functions** (6 hours)

```typescript
// BEFORE - 150-line function
async function createUserAndSendEmail(data) {
  // 1. Validate input (20 lines)
  // 2. Check if user exists (15 lines)
  // 3. Hash password (10 lines)
  // 4. Create user in DB (20 lines)
  // 5. Create profile (25 lines)
  // 6. Send welcome email (30 lines)
  // 7. Log activity (15 lines)
  // 8. Return result (15 lines)
}

// AFTER - Smaller functions
async function createUser(data) {
  validateUserData(data);
  await ensureUserDoesNotExist(data.email);
  const hashedPassword = await hashPassword(data.password);
  const user = await saveUser({ ...data, password: hashedPassword });
  await createUserProfile(user.id);
  await sendWelcomeEmail(user.email);
  await logUserCreation(user.id);
  return user;
}
```

**Functions to refactor:**
- `createUserAndSendEmail` (150 lines → 20 lines)
- `updateUserWithValidation` (120 lines → 25 lines)
- `deleteUserAndCleanup` (100 lines → 15 lines)

---

#### Priority 3: Medium Impact, High Effort (Week 3-4)

**6. Add TypeScript Types** (12 hours)

```typescript
// BEFORE
function getUser(id: any): any {
  return db.query('SELECT * FROM users WHERE id = ?', [id]);
}

// AFTER
interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
}

async function getUser(id: string): Promise<User | null> {
  const result = await db.query<User>('SELECT * FROM users WHERE id = ?', [id]);
  return result[0] || null;
}
```

**Files to update:** 15 (all service files)

**7. Improve Test Coverage** (8 hours)

**Current Coverage:** 45%
**Target Coverage:** 80%

**Missing Tests:**
- User creation edge cases
- Error handling paths
- Validation functions
- Email sending (mocked)

---

### Refactoring Timeline

| Week | Tasks | Effort | Impact |
|------|-------|--------|--------|
| **Week 1** | Remove dead code, update deps, error handling | 6h | Quick wins |
| **Week 2** | Extract validators, break down functions | 10h | Code quality |
| **Week 3** | Add TypeScript types (part 1) | 12h | Type safety |
| **Week 4** | Improve test coverage | 8h | Confidence |
| **Total** | | **36h** (~1 week for 1 developer) | |

---

### Before/After Comparison

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Lines of Code | 2,000 | 1,800 | -10% |
| Average Function Length | 45 | 25 | -44% |
| Code Duplication | 15% | 5% | -67% |
| Test Coverage | 45% | 80% | +78% |
| TypeScript Coverage | 0% | 100% | +100% |
| Outdated Dependencies | 5 | 0 | -100% |

---

### Refactoring Checklist

**Before Starting:**
- [ ] Create feature branch (`refactor/user-service`)
- [ ] Ensure all tests pass
- [ ] Document current behavior

**During Refactoring:**
- [ ] One change per commit
- [ ] Run tests after each change
- [ ] Keep commits small and focused

**After Completing:**
- [ ] All tests pass
- [ ] No regression in functionality
- [ ] Code review completed
- [ ] Update documentation (if needed)

---

### Risk Mitigation

**Risk:** Breaking existing functionality
**Mitigation:** Run full test suite after each change, manual testing

**Risk:** Merge conflicts (other devs working on same code)
**Mitigation:** Coordinate with team, frequent merges from main

**Risk:** Performance regression
**Mitigation:** Benchmark before/after, load testing

---

### Success Criteria

- [ ] Code coverage >80%
- [ ] No functions >50 lines
- [ ] Zero code duplication
- [ ] All dependencies up-to-date
- [ ] TypeScript strict mode enabled
- [ ] Zero linter warnings
```

**Quality Checks:**
- [ ] Issues clearly identified
- [ ] Refactoring prioritized (high impact first)
- [ ] Before/after code examples
- [ ] Timeline with effort estimates
- [ ] Tests maintained/improved
- [ ] Risk mitigation planned
- [ ] Success criteria defined

**Example Invocation:**
"use sc-workflows to create code cleanup plan for user service"

---

### Task 8: Review & Validation Workflow

**Triggers:** "review code", "validate implementation", "check quality", "code review process"

**When to Use:**
- Code review preparation
- Pull request review
- Pre-deployment validation
- Quality assurance

**Protocol:**

1. **Functional Review**
   - Does it work as intended?
   - Edge cases handled?
   - Error handling complete?
   - User experience tested?

2. **Code Quality Review**
   - Readable and maintainable?
   - Follows coding standards?
   - DRY (Don't Repeat Yourself)?
   - Appropriate patterns used?

3. **Testing Review**
   - Test coverage adequate?
   - Tests meaningful (not just for coverage)?
   - Edge cases tested?
   - Integration tests included?

4. **Security Review**
   - Input validation?
   - SQL injection prevented?
   - XSS prevention?
   - Authentication/authorization?

5. **Performance Review**
   - Efficient algorithms?
   - Database queries optimized?
   - No N+1 queries?
   - Caching where appropriate?

6. **Documentation Review**
   - Code comments for complex logic?
   - API documentation updated?
   - README updated if needed?
   - Changelog entry?

**Output Format:**
```
## Code Review: User Authentication Feature (PR #123)

### Overview
- **Author**: John Doe
- **Lines Changed**: +450, -120
- **Files Changed**: 8
- **Description**: Implement JWT authentication with refresh tokens

---

### Functional Review

✅ **Working as Intended**
- Login endpoint works correctly
- Token refresh mechanism functional
- Logout clears tokens

⚠️ **Issues Found:**
1. **Missing rate limiting** (HIGH)
   - Location: `auth.controller.ts:45`
   - Issue: No rate limiting on login endpoint
   - Recommendation:
```typescript
import rateLimit from 'express-rate-limit';
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5
});
app.post('/auth/login', loginLimiter, authController.login);
```

2. **Edge case: Expired refresh token** (MEDIUM)
   - Location: `auth.service.ts:78`
   - Issue: No handling for expired refresh tokens
   - Current behavior: Throws generic error
   - Recommendation: Return specific error code for expired tokens

---

### Code Quality Review

✅ **Good Practices:**
- Clean separation of concerns (controller, service, repository)
- TypeScript types used appropriately
- Consistent naming conventions

⚠️ **Issues:**
3. **Long function** (LOW)
   - Location: `auth.service.ts:authenticateUser` (85 lines)
   - Recommendation: Extract validation logic to separate function

4. **Magic numbers** (LOW)
   - Location: Multiple files
   - Issue: Token expiry times hardcoded
   - Recommendation:
```typescript
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';
```

---

### Testing Review

✅ **Good Coverage:**
- Unit tests for auth service (85% coverage)
- Integration tests for auth endpoints

❌ **Missing Tests:**
5. **No security tests** (HIGH)
   - Missing test for SQL injection
   - Missing test for brute force (rate limiting)
   - Missing test for token tampering

6. **Edge cases not tested** (MEDIUM)
   - Expired tokens
   - Invalid token format
   - Concurrent logout

**Recommendation:**
```typescript
describe('Auth Security', () => {
  it('should prevent SQL injection in email field', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({ email: "'; DROP TABLE users; --", password: 'test' });
    expect(res.status).toBe(400);
  });

  it('should rate limit login attempts', async () => {
    for (let i = 0; i < 6; i++) {
      await request(app).post('/auth/login').send({ email: 'test@example.com', password: 'wrong' });
    }
    const res = await request(app).post('/auth/login').send({ email: 'test@example.com', password: 'wrong' });
    expect(res.status).toBe(429);
  });
});
```

---

### Security Review

⚠️ **Security Issues:**
7. **Detailed error messages** (MEDIUM)
   - Location: `auth.controller.ts:52`
   - Issue: Error messages reveal if user exists
   - Current:
```typescript
if (!user) throw new Error('User not found');
if (!validPassword) throw new Error('Invalid password');
```
   - Recommendation (prevent user enumeration):
```typescript
if (!user || !validPassword) throw new Error('Invalid credentials');
```

8. **No CSRF protection** (HIGH)
   - Issue: Cookies used without CSRF tokens
   - Recommendation: Add CSRF middleware or use sameSite=strict cookies

✅ **Good Security Practices:**
- Passwords hashed with bcrypt
- JWT tokens signed
- httpOnly cookies used

---

### Performance Review

✅ **Good Performance:**
- Database queries use indexes
- No N+1 query issues

⚠️ **Optimization Opportunities:**
9. **Synchronous bcrypt** (LOW)
   - Location: `auth.service.ts:65`
   - Issue: Using `bcrypt.compareSync` (blocks event loop)
   - Recommendation:
```typescript
// Instead of:
const valid = bcrypt.compareSync(password, user.password_hash);
// Use:
const valid = await bcrypt.compare(password, user.password_hash);
```

---

### Documentation Review

✅ **Documentation Provided:**
- API endpoints documented in OpenAPI format
- Code comments for complex logic

❌ **Missing Documentation:**
10. **No migration guide** (LOW)
    - Need documentation for migrating from old auth system
    - Should include backward compatibility notes

---

### Summary

**Approval Status:** ⚠️ **Changes Requested**

**Critical Issues to Fix (3):**
1. Add rate limiting on login endpoint
2. Add CSRF protection
3. Add security tests

**Recommended Improvements (7):**
4. Handle expired refresh token edge case
5. Extract long function
6. Replace magic numbers with constants
7. Use generic error messages (prevent user enumeration)
8. Add edge case tests
9. Use async bcrypt
10. Add migration documentation

**Time Estimate to Address:**
- Critical fixes: 2-3 hours
- Recommended improvements: 4-5 hours

**Recommendation:**
Fix critical issues (1-3) before merging. Recommended improvements can be addressed in follow-up PR if time-sensitive.

---

### Reviewer Comments

**Great work on:**
- Clean code structure
- Good test coverage
- TypeScript usage

**Please address:**
- Security concerns (rate limiting, CSRF)
- Add security tests
- Generic error messages

**Questions:**
1. Why JWT over sessions? (Curious about decision)
2. Any reason for 7-day refresh token? (Security concern)

---

### Next Steps
1. Address critical issues
2. Update PR with fixes
3. Request re-review
4. Create follow-up tasks for recommended improvements
```

**Quality Checks:**
- [ ] Functional correctness verified
- [ ] Code quality assessed
- [ ] Test coverage checked
- [ ] Security reviewed
- [ ] Performance considered
- [ ] Documentation reviewed
- [ ] Clear approval/rejection status
- [ ] Actionable feedback provided

**Example Invocation:**
"use sc-workflows to review authentication implementation PR"

---

## Integration Examples

**With sc-agent:**
```
"use sc-agent to implement feature, then sc-workflows to review it"
→ Orchestrated workflow with validation
```

**With sc-architecture:**
```
"use sc-architecture to design system, then sc-workflows to plan implementation"
→ Design then plan
```

**With sc-performance:**
```
"use sc-workflows to troubleshoot slow API, then sc-performance to optimize"
→ Debug then optimize
```

---

## References

**Troubleshooting:**
- Google SRE Book: https://sre.google/sre-book/table-of-contents/
- The Phoenix Project: https://itrevolution.com/product/the-phoenix-project/

**Refactoring:**
- "Refactoring" by Martin Fowler: https://refactoring.com/
- Code Smells: https://refactoring.guru/refactoring/smells

**Code Review:**
- Google Code Review Guidelines: https://google.github.io/eng-practices/review/
- Conventional Comments: https://conventionalcomments.org/

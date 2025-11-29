---
name: sc-security
description: Security and compliance tasks including auth, audits, threat modeling, and secure coding
---

# SC Security - Security & Compliance Tasks

## When to Use This Skill

Use this skill for all security-related tasks:
- Authentication and authorization implementation
- Security audits and vulnerability assessments
- Threat modeling and risk analysis
- Secure coding reviews
- Compliance verification (GDPR, HIPAA, PCI-DSS, SOC2)
- Encryption and data protection
- API security
- Security testing
- Incident response
- Security architecture design

## Integration with Other Skills

- Use **confidence-check** before security implementations to verify approach
- Use **sc-architecture** for security architecture design
- Use **sc-quality** for security testing and penetration testing
- Use **sc-agent** to orchestrate security-focused implementations
- Use **deep-research** to investigate security best practices and threats
- Use **self-review** to validate security implementations

## Available Tasks

### Task 1: Implement Authentication System

**Triggers:** "authentication", "login", "JWT", "OAuth", "auth system", "SSO"

**When to Use:**
- Building user authentication
- Implementing SSO (Single Sign-On)
- Migrating authentication systems
- Adding social login

**Protocol:**

1. **Determine Authentication Requirements**
   - User types (customers, admins, partners)
   - Authentication methods (password, social, SSO, MFA)
   - Session management (stateless JWT vs stateful sessions)
   - Password requirements and policies

2. **Choose Authentication Strategy**
   - **JWT (JSON Web Tokens)**: Stateless, scalable, mobile-friendly
   - **Session-based**: Server-side sessions, simpler revocation
   - **OAuth 2.0**: Delegated authorization, social login
   - **SAML**: Enterprise SSO
   - **Passwordless**: Magic links, WebAuthn, biometrics

3. **Implement Credential Storage**
   - Hash passwords with bcrypt (cost factor 12+) or argon2
   - Never store plaintext passwords
   - Salt per password (automatic with bcrypt/argon2)
   - Store hashes in secure database

4. **Design Session Management**
   - JWT: Short-lived access tokens (15min) + refresh tokens (7 days)
   - Secure token storage (httpOnly cookies or secure storage)
   - Token refresh mechanism
   - Logout and token revocation

5. **Add Security Controls**
   - Rate limiting on login endpoints (5 attempts per 15min)
   - Account lockout after failed attempts
   - CAPTCHA after suspicious activity
   - Password reset with time-limited tokens
   - Email verification for new accounts

**Output Format:**
```
## Authentication System Design

### Authentication Strategy
**JWT-based** with refresh tokens

### Flow Diagram
```
1. User submits credentials
2. Server validates against database
3. If valid, generate access token (15min) + refresh token (7d)
4. Return tokens to client
5. Client stores in httpOnly cookie
6. Subsequent requests include access token
7. If expired, use refresh token to get new access token
```

### Implementation

**Password Hashing** (bcrypt)
```js
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 12;

// Registration
async function hashPassword(plaintext) {
  return await bcrypt.hash(plaintext, SALT_ROUNDS);
}

// Login
async function verifyPassword(plaintext, hash) {
  return await bcrypt.compare(plaintext, hash);
}
```

**JWT Generation**
```js
const jwt = require('jsonwebtoken');

function generateTokens(user) {
  const accessToken = jwt.sign(
    { userId: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );

  const refreshToken = jwt.sign(
    { userId: user.id },
    process.env.REFRESH_SECRET,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
}
```

**Login Endpoint**
```js
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  // Rate limiting check
  const attempts = await getLoginAttempts(email);
  if (attempts > 5) {
    return res.status(429).json({ error: 'Too many attempts, try again later' });
  }

  // Find user
  const user = await db.query('SELECT * FROM users WHERE email = ?', [email]);
  if (!user) {
    await incrementLoginAttempts(email);
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // Verify password
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    await incrementLoginAttempts(email);
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user);

  // Store refresh token
  await db.query('INSERT INTO refresh_tokens (user_id, token) VALUES (?, ?)', [user.id, refreshToken]);

  // Return tokens
  res.cookie('accessToken', accessToken, { httpOnly: true, secure: true, sameSite: 'strict' });
  res.cookie('refreshToken', refreshToken, { httpOnly: true, secure: true, sameSite: 'strict' });
  res.json({ user: { id: user.id, email: user.email } });
});
```

### Security Controls
- Password requirements: 12+ characters, mix of upper/lower/numbers/symbols
- bcrypt with cost factor 12
- Rate limiting: 5 attempts per 15min per email
- Account lockout: 30min after 5 failed attempts
- HTTPS enforced (redirect HTTP → HTTPS)
- CSRF protection (SameSite cookies)
- XSS protection (Content-Security-Policy headers)

### Password Reset Flow
1. User requests reset → email with time-limited token (1h expiry)
2. Token includes user ID + random secret
3. User clicks link, enters new password
4. Invalidate all existing sessions
5. Send confirmation email
```

**Quality Checks:**
- [ ] Passwords hashed with bcrypt (cost 12+) or argon2
- [ ] HTTPS enforced everywhere
- [ ] httpOnly, secure, SameSite cookies
- [ ] Rate limiting on auth endpoints
- [ ] Account lockout after failed attempts
- [ ] CSRF protection implemented
- [ ] Password strength requirements enforced
- [ ] Email verification for new accounts
- [ ] Secure password reset flow
- [ ] No passwords in logs or error messages

**Example Invocation:**
"use sc-security to implement JWT authentication with password reset"

---

### Task 2: Design Authorization Model

**Triggers:** "authorization", "RBAC", "ABAC", "permissions", "access control", "roles"

**When to Use:**
- Defining user permissions
- Multi-tenant applications
- Role-based access control
- Attribute-based access control
- Fine-grained permissions

**Protocol:**

1. **Choose Authorization Model**
   - **RBAC (Role-Based)**: Users have roles with permissions
   - **ABAC (Attribute-Based)**: Decisions based on attributes
   - **ReBAC (Relationship-Based)**: Based on relationships (owner, member)
   - **Claims-Based**: JWT claims define permissions

2. **Define Roles and Permissions**
   - Identify user roles (admin, editor, viewer)
   - Define permissions (read, write, delete, approve)
   - Map permissions to resources (posts, users, settings)
   - Principle of least privilege

3. **Implement Permission Checks**
   - Middleware for route-level authorization
   - Function-level checks for fine-grained control
   - Resource-level ownership checks
   - Deny by default (explicit allow required)

4. **Handle Multi-Tenancy** (if applicable)
   - Tenant isolation (data, permissions)
   - Cross-tenant access controls
   - Super-admin for platform management

5. **Audit and Logging**
   - Log all authorization decisions
   - Track permission changes
   - Audit trail for compliance

**Output Format:**
```
## Authorization Model

### Model Selection
**RBAC (Role-Based Access Control)** with resource ownership

### Roles and Permissions

**Roles:**
- **Admin**: Full access to all resources
- **Editor**: Create, read, update own resources
- **Viewer**: Read-only access
- **Guest**: Public resources only

**Permissions Matrix:**
| Resource | Admin | Editor | Viewer | Guest |
|----------|-------|--------|--------|-------|
| Users | CRUD | R (self) | R | - |
| Posts | CRUD | CRUD (own) | R (published) | R (public) |
| Settings | CRUD | R | - | - |
| Analytics | R | R (own) | - | - |

### Implementation

**Database Schema**
```sql
CREATE TABLE roles (
  id UUID PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE permissions (
  id UUID PRIMARY KEY,
  resource VARCHAR(50) NOT NULL,
  action VARCHAR(20) NOT NULL,
  UNIQUE(resource, action)
);

CREATE TABLE role_permissions (
  role_id UUID REFERENCES roles(id),
  permission_id UUID REFERENCES permissions(id),
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id),
  role_id UUID REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);
```

**Authorization Middleware**
```js
function authorize(resource, action) {
  return async (req, res, next) => {
    const userId = req.user.id;

    // Check if user has permission
    const hasPermission = await checkPermission(userId, resource, action);

    if (!hasPermission) {
      // Check resource ownership
      if (action === 'update' || action === 'delete') {
        const resourceOwnerId = await getResourceOwner(resource, req.params.id);
        if (resourceOwnerId === userId) {
          return next(); // User owns resource
        }
      }

      return res.status(403).json({ error: 'Forbidden' });
    }

    next();
  };
}

// Usage
app.put('/api/posts/:id', authorize('posts', 'update'), updatePost);
app.delete('/api/posts/:id', authorize('posts', 'delete'), deletePost);
```

**Permission Check Function**
```js
async function checkPermission(userId, resource, action) {
  const result = await db.query(`
    SELECT 1
    FROM user_roles ur
    JOIN role_permissions rp ON ur.role_id = rp.role_id
    JOIN permissions p ON rp.permission_id = p.id
    WHERE ur.user_id = ? AND p.resource = ? AND p.action = ?
  `, [userId, resource, action]);

  return result.length > 0;
}
```

### Multi-Tenancy
- Tenant ID in all queries (WHERE tenant_id = ?)
- Row-level security (RLS) in PostgreSQL
- Super-admin bypasses tenant isolation

### Audit Logging
- Log all authorization failures
- Track permission grants/revokes
- Periodic access reviews
```

**Quality Checks:**
- [ ] Roles and permissions clearly defined
- [ ] Principle of least privilege applied
- [ ] Deny by default (explicit allow required)
- [ ] Resource ownership checked
- [ ] Authorization middleware on all protected routes
- [ ] Audit logging for authorization events
- [ ] Multi-tenant isolation (if applicable)
- [ ] Permission changes tracked

**Example Invocation:**
"use sc-security to design RBAC authorization for SaaS application"

---

### Task 3: Security Audit (OWASP Top 10)

**Triggers:** "security audit", "OWASP", "vulnerability scan", "security review", "penetration test"

**When to Use:**
- Pre-production security review
- Annual security audits
- Post-incident analysis
- Compliance requirements

**Protocol:**

1. **OWASP Top 10 Checklist**
   - **A01: Broken Access Control**: Authorization checks everywhere
   - **A02: Cryptographic Failures**: Encryption at rest/transit
   - **A03: Injection**: SQL injection, XSS, command injection
   - **A04: Insecure Design**: Threat modeling, secure architecture
   - **A05: Security Misconfiguration**: Default configs, error messages
   - **A06: Vulnerable Components**: Dependency scanning
   - **A07: Authentication Failures**: Strong auth, MFA, session security
   - **A08: Software/Data Integrity**: Unsigned updates, CI/CD security
   - **A09: Logging Failures**: Security event logging
   - **A10: SSRF**: Server-side request validation

2. **Automated Scanning**
   - SAST (Static Analysis): Snyk, SonarQube
   - DAST (Dynamic Analysis): OWASP ZAP, Burp Suite
   - Dependency scanning: npm audit, Snyk, Dependabot
   - Container scanning: Trivy, Clair

3. **Manual Review**
   - Code review focusing on security
   - Authentication flow testing
   - Authorization bypass attempts
   - Input validation testing
   - Session management review

4. **Penetration Testing**
   - External pentest (black box)
   - Internal pentest (white box)
   - API security testing
   - Infrastructure assessment

5. **Remediation**
   - Prioritize by severity (Critical → High → Medium → Low)
   - Create fix plan with timelines
   - Re-test after fixes
   - Document mitigations

**Output Format:**
```
## Security Audit Report

### Audit Scope
- Application: E-commerce API
- Date: 2025-01-15
- Methodology: OWASP Top 10 + Automated Scanning + Manual Review

### Findings Summary
- **Critical**: 2
- **High**: 5
- **Medium**: 8
- **Low**: 12

### Critical Vulnerabilities

**1. SQL Injection in Search Endpoint**
- **Category**: A03 - Injection
- **Location**: `/api/products/search?q={query}`
- **Description**: User input directly concatenated into SQL query
- **Impact**: Database compromise, data exfiltration
- **Evidence**:
```sql
-- Vulnerable code
const query = `SELECT * FROM products WHERE name LIKE '%${req.query.q}%'`;

-- Exploit
/api/products/search?q='; DROP TABLE users; --
```
- **Remediation**: Use parameterized queries
```js
const query = 'SELECT * FROM products WHERE name LIKE ?';
db.query(query, [`%${req.query.q}%`]);
```
- **Priority**: CRITICAL - Fix immediately
- **Timeline**: 24 hours

**2. Broken Access Control - Admin Endpoints**
- **Category**: A01 - Broken Access Control
- **Location**: `/api/admin/*`
- **Description**: Admin routes missing authorization checks
- **Impact**: Privilege escalation, unauthorized admin access
- **Evidence**: Regular user can access `/api/admin/users`
- **Remediation**: Add authorization middleware
```js
app.use('/api/admin', requireRole('admin'));
```
- **Priority**: CRITICAL - Fix immediately
- **Timeline**: 24 hours

### High Vulnerabilities

**3. Missing Rate Limiting**
- **Category**: A07 - Authentication Failures
- **Location**: `/api/auth/login`
- **Description**: No rate limiting allows brute force attacks
- **Impact**: Account compromise via password guessing
- **Remediation**: Add express-rate-limit
```js
const rateLimit = require('express-rate-limit');
app.use('/api/auth', rateLimit({ windowMs: 15 * 60 * 1000, max: 5 }));
```
- **Priority**: HIGH
- **Timeline**: 3 days

[... Additional findings ...]

### Compliance Matrix

| OWASP Category | Status | Findings |
|----------------|--------|----------|
| A01: Broken Access Control | ❌ Failed | 3 findings |
| A02: Cryptographic Failures | ✅ Passed | - |
| A03: Injection | ❌ Failed | 1 critical, 2 medium |
| A04: Insecure Design | ⚠️ Partial | 1 medium |
| A05: Security Misconfiguration | ⚠️ Partial | 2 low |
| A06: Vulnerable Components | ❌ Failed | 15 outdated deps |
| A07: Authentication Failures | ❌ Failed | 2 high |
| A08: Software Integrity | ✅ Passed | - |
| A09: Logging Failures | ⚠️ Partial | 1 medium |
| A10: SSRF | ✅ Passed | - |

### Automated Scan Results

**Snyk (Dependency Scan)**
- 15 vulnerable dependencies
- 3 high severity (prototype pollution, RCE)
- Recommendation: `npm audit fix`

**OWASP ZAP (DAST)**
- 8 XSS vulnerabilities
- Missing security headers (CSP, X-Frame-Options)
- Session cookies not httpOnly

### Remediation Plan

**Phase 1: Critical (24 hours)**
- Fix SQL injection
- Add authorization to admin routes
- Deploy to production

**Phase 2: High (1 week)**
- Add rate limiting
- Fix XSS vulnerabilities
- Update vulnerable dependencies
- Add security headers

**Phase 3: Medium (1 month)**
- Implement comprehensive logging
- Add CSP policy
- Fix remaining issues

### Recommendations
- Implement security CI/CD pipeline
- Schedule quarterly security audits
- Enable automated dependency scanning (Dependabot)
- Security training for developers
```

**Quality Checks:**
- [ ] All OWASP Top 10 categories reviewed
- [ ] Automated scanning completed (SAST + DAST)
- [ ] Dependency vulnerabilities identified
- [ ] Manual code review performed
- [ ] Findings categorized by severity
- [ ] Remediation plan with timelines
- [ ] Re-testing after fixes
- [ ] Executive summary for stakeholders

**Example Invocation:**
"use sc-security to conduct OWASP Top 10 security audit"

---

### Task 4: Implement Data Encryption

**Triggers:** "encryption", "data protection", "encrypt sensitive data", "PII protection"

**When to Use:**
- Protecting sensitive data (PII, PHI, PCI)
- Compliance requirements (GDPR, HIPAA, PCI-DSS)
- Data at rest and in transit
- Key management

**Protocol:**

1. **Identify Sensitive Data**
   - Personally Identifiable Information (PII)
   - Payment information (PCI)
   - Health information (PHI)
   - Business secrets (API keys, credentials)

2. **Encryption at Rest**
   - Database encryption (transparent data encryption)
   - File encryption (S3 server-side encryption)
   - Application-level encryption for specific fields
   - Encrypted backups

3. **Encryption in Transit**
   - TLS 1.3 for all connections
   - Certificate management (Let's Encrypt, ACM)
   - HSTS (HTTP Strict Transport Security)
   - No mixed content (all HTTPS)

4. **Key Management**
   - AWS KMS, HashiCorp Vault, or similar
   - Key rotation policy (90 days)
   - Separate keys per environment
   - Access controls on key usage

5. **Implementation**
   - Choose encryption algorithm (AES-256-GCM)
   - Field-level encryption for highly sensitive data
   - Tokenization for payment data
   - Hashing for passwords (bcrypt, not encryption)

**Output Format:**
```
## Data Encryption Strategy

### Sensitive Data Inventory
- **PII**: email, phone, address, SSN
- **Payment**: credit card numbers, bank accounts
- **Authentication**: passwords (hashed, not encrypted)
- **API Keys**: third-party service credentials

### Encryption at Rest

**Database Encryption**
- PostgreSQL: Transparent Data Encryption (TDE)
- RDS: Encryption enabled (AES-256)
- Encrypted backups (S3 with SSE-KMS)

**Application-Level Encryption** (Field-Level)
```js
const crypto = require('crypto');
const AWS = require('aws-sdk');
const kms = new AWS.KMS();

// Encrypt sensitive field
async function encryptField(plaintext) {
  const dataKey = await kms.generateDataKey({
    KeyId: 'arn:aws:kms:...',
    KeySpec: 'AES_256'
  }).promise();

  const cipher = crypto.createCipheriv('aes-256-gcm', dataKey.Plaintext, iv);
  let encrypted = cipher.update(plaintext, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  const authTag = cipher.getAuthTag();

  return {
    encrypted,
    authTag: authTag.toString('hex'),
    dataKey: dataKey.CiphertextBlob.toString('base64'),
    iv: iv.toString('hex')
  };
}

// Decrypt sensitive field
async function decryptField(encryptedData) {
  const dataKey = await kms.decrypt({
    CiphertextBlob: Buffer.from(encryptedData.dataKey, 'base64')
  }).promise();

  const decipher = crypto.createDecipheriv(
    'aes-256-gcm',
    dataKey.Plaintext,
    Buffer.from(encryptedData.iv, 'hex')
  );
  decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));

  let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

**Database Schema**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  ssn_encrypted TEXT,  -- Encrypted with AES-256-GCM
  ssn_iv TEXT,
  ssn_auth_tag TEXT,
  ssn_data_key TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Encryption in Transit

**TLS Configuration**
- TLS 1.3 only (disable 1.2 and below)
- Strong cipher suites only
- Certificate from Let's Encrypt (auto-renewal)
- HSTS header (max-age=31536000; includeSubDomains)

**NGINX Config**
```nginx
server {
  listen 443 ssl http2;
  ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;
  ssl_protocols TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384';

  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Frame-Options "DENY" always;
}
```

### Key Management

**AWS KMS**
- Customer Master Key (CMK) per environment
- Key rotation enabled (automatic yearly)
- IAM policies for key usage
- CloudTrail logging of key operations

**Key Rotation Policy**
- Automatic rotation: Yearly (AWS KMS)
- Manual rotation: Quarterly for high-risk keys
- Emergency rotation: Immediately on compromise

### Payment Data (PCI-DSS)
- **Tokenization** via payment processor (Stripe, Square)
- Never store full credit card numbers
- Store only tokenized references
- PCI compliance via payment processor

### Compliance
- GDPR: Encryption of PII (Article 32)
- HIPAA: Encryption of PHI (§164.312(a)(2)(iv))
- PCI-DSS: No plaintext card data (Requirement 3)
```

**Quality Checks:**
- [ ] All PII/PHI encrypted at rest
- [ ] TLS 1.3 enforced (no HTTP)
- [ ] Field-level encryption for highly sensitive data
- [ ] Key management via KMS/Vault (not hardcoded)
- [ ] Key rotation policy defined and automated
- [ ] Payment data tokenized (PCI compliance)
- [ ] Encrypted backups
- [ ] No encryption keys in source code
- [ ] Audit logging of encryption operations

**Example Invocation:**
"use sc-security to implement encryption for PII data"

---

### Task 5: API Security Hardening

**Triggers:** "API security", "secure API", "API protection", "API hardening"

**When to Use:**
- Building public APIs
- Securing existing APIs
- API security review
- Preventing API abuse

**Protocol:**

1. **Authentication & Authorization**
   - API keys for machine-to-machine
   - JWT tokens for user-facing APIs
   - OAuth 2.0 for third-party access
   - Scope-based permissions

2. **Input Validation**
   - Validate all inputs (type, format, range)
   - Whitelist allowed values
   - Sanitize inputs (prevent injection)
   - Request size limits

3. **Rate Limiting**
   - Per API key / user
   - Different limits for different tiers
   - Burst limits for traffic spikes
   - 429 Too Many Requests response

4. **Security Headers**
   - CORS (restrict origins)
   - Content-Security-Policy
   - X-Content-Type-Options: nosniff
   - X-Frame-Options: DENY

5. **Error Handling**
   - Don't leak stack traces
   - Generic error messages (no implementation details)
   - Log detailed errors server-side
   - Rate limit error responses

6. **Monitoring & Logging**
   - Log all API requests
   - Track suspicious patterns
   - Alert on anomalies
   - Incident response plan

**Output Format:**
```
## API Security Configuration

### Authentication
- **API Keys**: Service-to-service (header: `X-API-Key`)
- **JWT**: User requests (header: `Authorization: Bearer <token>`)
- **OAuth 2.0**: Third-party integrations

### Input Validation Middleware
```js
const { body, query, validationResult } = require('express-validator');

app.post('/api/users',
  body('email').isEmail().normalizeEmail(),
  body('age').isInt({ min: 18, max: 120 }),
  body('name').trim().escape().isLength({ min: 2, max: 100 }),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    // Process validated input
  }
);
```

### Rate Limiting
```js
const rateLimit = require('express-rate-limit');

// General API rate limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 attempts per 15 minutes
  skipSuccessfulRequests: true,
});

app.use('/api/', apiLimiter);
app.use('/api/auth/', authLimiter);
```

### Security Headers
```js
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));

// CORS configuration
const cors = require('cors');
app.use(cors({
  origin: ['https://example.com', 'https://app.example.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
```

### Request Validation
```js
// Request size limits
app.use(express.json({ limit: '10mb' }));

// SQL injection prevention (parameterized queries)
db.query('SELECT * FROM users WHERE id = ?', [userId]);

// XSS prevention (escape output)
const escape = require('escape-html');
res.send(escape(userInput));

// Command injection prevention
const { execFile } = require('child_process');
execFile('ls', ['-l', userInput], (error, stdout) => {
  // Safer than exec() which uses shell
});
```

### Error Handling
```js
// Global error handler
app.use((err, req, res, next) => {
  // Log full error server-side
  logger.error(err.stack);

  // Return generic error to client
  if (process.env.NODE_ENV === 'production') {
    res.status(500).json({ error: 'Internal server error' });
  } else {
    res.status(500).json({ error: err.message, stack: err.stack });
  }
});
```

### Monitoring
- Request logs (Elasticsearch)
- Failed auth attempts (alert after 10 failures)
- Unusual traffic patterns (spike detection)
- Slow query alerts (>1s response time)

### Security Checklist
- [ ] HTTPS only (redirect HTTP → HTTPS)
- [ ] Authentication on all endpoints (except public)
- [ ] Input validation on all requests
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Security headers set (helmet)
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output escaping, CSP)
- [ ] No sensitive data in URLs (use POST body)
- [ ] API versioning (/v1/, /v2/)
- [ ] Comprehensive logging
- [ ] Error messages don't leak info
```

**Quality Checks:**
- [ ] All endpoints require authentication (except public)
- [ ] Input validation on all user inputs
- [ ] Rate limiting implemented
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output escaping, CSP)
- [ ] CORS properly configured
- [ ] Security headers set
- [ ] Error messages sanitized
- [ ] API versioning strategy
- [ ] Monitoring and alerting

**Example Invocation:**
"use sc-security to harden REST API security"

---

### Task 6: Threat Modeling

**Triggers:** "threat model", "threat modeling", "risk analysis", "attack surface", "STRIDE"

**When to Use:**
- Designing new systems
- Security architecture review
- Identifying security risks
- Prioritizing security investments

**Protocol:**

1. **Identify Assets**
   - User data (PII, credentials)
   - Business data (transactions, analytics)
   - System resources (servers, databases)
   - Intellectual property

2. **Map Attack Surface**
   - Entry points (APIs, web forms, admin panels)
   - Data flows (client → server → database)
   - Trust boundaries (internet → DMZ → internal)
   - External dependencies (third-party APIs)

3. **Identify Threats (STRIDE)**
   - **S**poofing: Impersonating users or systems
   - **T**ampering: Modifying data or code
   - **R**epudiation: Denying actions
   - **I**nformation Disclosure: Data leaks
   - **D**enial of Service: Availability attacks
   - **E**levation of Privilege: Unauthorized access

4. **Assess Risks**
   - Likelihood: Low / Medium / High
   - Impact: Low / Medium / High / Critical
   - Risk Score: Likelihood × Impact
   - Prioritize by risk score

5. **Define Mitigations**
   - Preventive controls (authentication, input validation)
   - Detective controls (logging, monitoring)
   - Corrective controls (incident response)
   - Accept, Mitigate, Transfer, or Avoid risk

**Output Format:**
```
## Threat Model: E-commerce API

### Assets
1. **User PII**: email, address, phone, payment info
2. **Business Data**: orders, revenue, inventory
3. **System Access**: admin credentials, API keys
4. **Intellectual Property**: pricing algorithms, customer lists

### Architecture Diagram
```
Internet → Load Balancer → API Gateway → Microservices → Database
                                      ↓
                                  Third-party APIs (Payment, Email)
```

### Trust Boundaries
- **Boundary 1**: Internet ↔ Load Balancer (public → DMZ)
- **Boundary 2**: API Gateway ↔ Microservices (DMZ → internal)
- **Boundary 3**: Microservices ↔ Database (application → data)
- **Boundary 4**: API ↔ Third-party (internal → external)

### Threat Analysis (STRIDE)

#### 1. User Authentication Endpoint

**Spoofing**
- **Threat**: Attacker impersonates legitimate user
- **Likelihood**: High
- **Impact**: Critical
- **Risk**: CRITICAL
- **Mitigation**:
  - Strong password requirements
  - MFA for sensitive actions
  - Rate limiting (5 attempts per 15min)
  - Account lockout after failures

**Tampering**
- **Threat**: Attacker modifies JWT token
- **Likelihood**: Medium
- **Impact**: Critical
- **Risk**: HIGH
- **Mitigation**:
  - Sign JWTs with HMAC-SHA256
  - Validate signature on every request
  - Short token expiry (15min)

**Repudiation**
- **Threat**: User denies making purchase
- **Likelihood**: Medium
- **Impact**: Medium
- **Risk**: MEDIUM
- **Mitigation**:
  - Comprehensive audit logging
  - Immutable order records
  - Email confirmations

**Information Disclosure**
- **Threat**: Password leaked in logs/errors
- **Likelihood**: Low
- **Impact**: Critical
- **Risk**: MEDIUM
- **Mitigation**:
  - Never log passwords
  - Sanitize error messages
  - Encrypt logs at rest

**Denial of Service**
- **Threat**: Brute force login attempts
- **Likelihood**: High
- **Impact**: Medium
- **Risk**: HIGH
- **Mitigation**:
  - Rate limiting
  - CAPTCHA after failures
  - IP blocking for repeated abuse

**Elevation of Privilege**
- **Threat**: User escalates to admin
- **Likelihood**: Low
- **Impact**: Critical
- **Risk**: MEDIUM
- **Mitigation**:
  - RBAC with least privilege
  - Authorization checks on all routes
  - Admin actions require re-authentication

#### 2. Payment Processing

[Similar STRIDE analysis for payment flow]

#### 3. Admin Panel

[Similar STRIDE analysis for admin access]

### Risk Matrix

| Threat | Asset | Likelihood | Impact | Risk | Mitigation Priority |
|--------|-------|------------|--------|------|---------------------|
| Auth Spoofing | User PII | High | Critical | CRITICAL | P0 - Immediate |
| Token Tampering | System Access | Medium | Critical | HIGH | P1 - 1 week |
| DoS on Login | Availability | High | Medium | HIGH | P1 - 1 week |
| SQL Injection | Business Data | Medium | Critical | HIGH | P1 - 1 week |
| XSS | User PII | Medium | Medium | MEDIUM | P2 - 1 month |
| Unencrypted Logs | User PII | Low | High | MEDIUM | P2 - 1 month |

### Mitigation Plan

**Phase 1: Critical (Immediate)**
- Implement MFA for admin users
- Add JWT signature validation
- Enable rate limiting on auth endpoints

**Phase 2: High (1 week)**
- Parameterized queries (prevent SQL injection)
- DoS protection (CloudFlare, rate limits)
- Token expiry and refresh mechanism

**Phase 3: Medium (1 month)**
- XSS prevention (CSP, output escaping)
- Log encryption and sanitization
- Comprehensive audit trail

### Ongoing Monitoring
- Failed login attempts (alert threshold: 100/hour)
- Unusual API patterns (ML-based anomaly detection)
- Quarterly threat model reviews
- Security scanning in CI/CD
```

**Quality Checks:**
- [ ] All assets identified
- [ ] Attack surface mapped
- [ ] STRIDE applied to critical components
- [ ] Risks scored (likelihood × impact)
- [ ] Mitigations defined for high risks
- [ ] Mitigation plan with priorities
- [ ] Threat model reviewed quarterly
- [ ] Stakeholders aware of accepted risks

**Example Invocation:**
"use sc-security to create threat model for payment system"

---

### Task 7: Implement Secure CI/CD Pipeline

**Triggers:** "secure CI/CD", "DevSecOps", "security scanning", "supply chain security"

**When to Use:**
- Setting up new CI/CD pipeline
- Adding security to existing pipeline
- Compliance requirements
- Supply chain security

**Protocol:**

1. **Secret Management**
   - Never commit secrets to Git
   - Use secret management (GitHub Secrets, Vault)
   - Rotate secrets regularly
   - Audit secret access

2. **Dependency Scanning**
   - npm audit, Snyk, Dependabot
   - Fail build on high/critical vulnerabilities
   - Automated dependency updates
   - License compliance checking

3. **Static Analysis (SAST)**
   - Code scanning (Snyk Code, SonarQube)
   - Security linters (ESLint security plugins)
   - Detect hardcoded secrets (GitGuardian)

4. **Container Security**
   - Base image scanning (Trivy, Clair)
   - No secrets in images
   - Run as non-root user
   - Minimal images (alpine, distroless)

5. **Deployment Security**
   - Sign commits and tags
   - Verify artifact integrity (checksums)
   - Immutable infrastructure
   - Audit trail for deployments

**Output Format:**
```
## Secure CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: Secure CI/CD

on:
  push:
    branches: [main, staging]
  pull_request:

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Secret scanning
      - name: GitGuardian scan
        uses: GitGuardian/ggshield-action@v1
        env:
          GITGUARDIAN_API_KEY: ${{ secrets.GITGUARDIAN_API_KEY }}

      # Dependency scanning
      - name: Install dependencies
        run: npm ci
      - name: Audit dependencies
        run: npm audit --audit-level=high
      - name: Snyk scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      # SAST (Static Analysis)
      - name: Run SonarQube
        uses: sonarsource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  build:
    needs: security-scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t app:${{ github.sha }} .

      # Container scanning
      - name: Scan image with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: app:${{ github.sha }}
          severity: HIGH,CRITICAL
          exit-code: '1'  # Fail on vulnerabilities

      - name: Sign and push image
        run: |
          # Sign with cosign
          cosign sign app:${{ github.sha }}
          docker push app:${{ github.sha }}

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: npm test

      # DAST (Dynamic Analysis) on staging
      - name: Deploy to staging
        run: deploy-to-staging.sh
      - name: OWASP ZAP scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: 'https://staging.example.com'

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [security-scan, build, test]
    environment: production  # Requires approval
    runs-on: ubuntu-latest
    steps:
      - name: Verify signed image
        run: cosign verify app:${{ github.sha }}

      - name: Deploy to production
        run: deploy-to-production.sh
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
```

### Dockerfile Security
```dockerfile
# Use minimal base image
FROM node:18-alpine AS builder

# Run as non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

# Copy only necessary files
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY --chown=nodejs:nodejs . .
RUN npm run build

# Production image
FROM node:18-alpine
USER nodejs
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Secret Management

**.gitignore**
```
.env
.env.local
*.pem
*.key
config/secrets.json
```

**Using GitHub Secrets**
```yaml
# In GitHub Actions
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  JWT_SECRET: ${{ secrets.JWT_SECRET }}
```

**Secret Rotation**
- Quarterly rotation for high-risk secrets
- Automated rotation via AWS Secrets Manager
- Alert on secret access anomalies

### Supply Chain Security

**Package Lock**
- Commit package-lock.json
- npm ci (not npm install) in CI/CD
- Verify package integrity (checksums)

**Dependency Updates**
- Dependabot for automated PRs
- Review and test before merging
- Pin major versions, allow minor/patch

**Signed Commits** (GPG)
```bash
git config --global user.signingkey <GPG_KEY_ID>
git config --global commit.gpgsign true
```

### Monitoring & Alerting
- Failed security scans (Slack alert)
- High/critical vulnerabilities (PagerDuty)
- Unauthorized secret access (CloudTrail)
- Anomalous deployment patterns
```

**Quality Checks:**
- [ ] No secrets in Git (use secret management)
- [ ] Dependency scanning (fail on high/critical)
- [ ] SAST (static analysis) in pipeline
- [ ] Container scanning (Trivy/Clair)
- [ ] Signed commits and images
- [ ] DAST (dynamic analysis) on staging
- [ ] Secret rotation policy
- [ ] Audit logging for deployments
- [ ] Minimal Docker images (non-root user)

**Example Invocation:**
"use sc-security to design secure CI/CD pipeline with secret management"

---

### Task 8: GDPR Compliance Implementation

**Triggers:** "GDPR", "privacy", "data protection", "right to be forgotten", "consent management"

**When to Use:**
- EU users or operations
- Privacy compliance requirements
- Handling personal data
- Data protection audit

**Protocol:**

1. **Data Inventory (Article 30)**
   - Identify all personal data collected
   - Document processing purposes
   - Data retention periods
   - Third-party data sharing

2. **Lawful Basis (Article 6)**
   - Consent (explicit opt-in)
   - Contract performance
   - Legal obligation
   - Legitimate interest

3. **User Rights Implementation**
   - Right to access (data export)
   - Right to erasure (deletion)
   - Right to portability (JSON/CSV export)
   - Right to rectification (data correction)
   - Right to restrict processing

4. **Consent Management**
   - Clear, specific consent requests
   - Easy withdrawal mechanism
   - Audit trail of consent
   - Cookie consent banner

5. **Security Measures (Article 32)**
   - Encryption of personal data
   - Pseudonymization where possible
   - Access controls
   - Data breach notification plan

**Output Format:**
```
## GDPR Compliance Implementation

### Data Inventory

| Data Type | Purpose | Lawful Basis | Retention | Third Parties |
|-----------|---------|--------------|-----------|---------------|
| Email | Account creation | Consent | Until deletion | Email provider (SendGrid) |
| Name | Personalization | Consent | Until deletion | - |
| IP Address | Security | Legitimate interest | 90 days | CloudFlare |
| Cookies | Analytics | Consent | 1 year | Google Analytics |
| Payment Info | Transaction | Contract | 7 years (legal) | Stripe (tokenized) |

### User Rights Implementation

**Right to Access** (Article 15)
```js
app.get('/api/users/me/data-export', authenticate, async (req, res) => {
  const userId = req.user.id;

  // Collect all user data
  const userData = {
    profile: await db.query('SELECT * FROM users WHERE id = ?', [userId]),
    orders: await db.query('SELECT * FROM orders WHERE user_id = ?', [userId]),
    preferences: await db.query('SELECT * FROM preferences WHERE user_id = ?', [userId]),
    consents: await db.query('SELECT * FROM consents WHERE user_id = ?', [userId]),
  };

  // Return as downloadable JSON
  res.setHeader('Content-Disposition', 'attachment; filename=my-data.json');
  res.json(userData);
});
```

**Right to Erasure** (Article 17)
```js
app.delete('/api/users/me', authenticate, async (req, res) => {
  const userId = req.user.id;

  // Delete user data (cascade deletes via foreign keys)
  await db.query('DELETE FROM users WHERE id = ?', [userId]);

  // Anonymize data that must be retained (legal/accounting)
  await db.query(`
    UPDATE orders
    SET user_email = 'deleted@example.com',
        user_name = 'Deleted User'
    WHERE user_id = ?
  `, [userId]);

  // Log deletion for audit
  await auditLog.create({
    event: 'USER_DELETED',
    userId,
    timestamp: new Date(),
    reason: req.body.reason
  });

  res.json({ message: 'Account deleted successfully' });
});
```

**Right to Data Portability** (Article 20)
```js
app.get('/api/users/me/export-csv', authenticate, async (req, res) => {
  const userId = req.user.id;
  const orders = await db.query('SELECT * FROM orders WHERE user_id = ?', [userId]);

  const csv = convertToCSV(orders);
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename=orders.csv');
  res.send(csv);
});
```

### Consent Management

**Cookie Consent Banner**
```html
<div id="cookie-banner" v-if="!cookieConsent">
  <p>We use cookies for analytics and personalization.</p>
  <button @click="acceptCookies('all')">Accept All</button>
  <button @click="acceptCookies('necessary')">Necessary Only</button>
  <a href="/privacy">Learn More</a>
</div>
```

**Consent Storage**
```sql
CREATE TABLE consents (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  purpose VARCHAR(50) NOT NULL,  -- 'analytics', 'marketing', etc.
  granted BOOLEAN NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);
```

**Consent Validation**
```js
async function checkConsent(userId, purpose) {
  const consent = await db.query(`
    SELECT granted FROM consents
    WHERE user_id = ? AND purpose = ?
    ORDER BY timestamp DESC
    LIMIT 1
  `, [userId, purpose]);

  return consent && consent.granted;
}

// Usage
if (await checkConsent(userId, 'analytics')) {
  trackAnalytics(userId, event);
}
```

### Data Minimization
- Only collect necessary data
- Pseudonymize where possible (user123 instead of john.doe@example.com)
- Aggregate analytics data (no individual tracking)

### Data Retention
```js
// Automated deletion of old data
cron.schedule('0 0 * * *', async () => {
  // Delete logs older than 90 days
  await db.query('DELETE FROM logs WHERE created_at < NOW() - INTERVAL 90 DAY');

  // Anonymize old orders (keep for accounting, remove PII)
  await db.query(`
    UPDATE orders
    SET user_email = 'anonymized@example.com'
    WHERE created_at < NOW() - INTERVAL 7 YEAR
  `);
});
```

### Data Breach Notification
- Detect breach within 24 hours (monitoring)
- Notify supervisory authority within 72 hours
- Notify affected users if high risk
- Document all breaches

**Incident Response Plan**
1. Detect and contain breach
2. Assess scope and risk
3. Notify DPO (Data Protection Officer)
4. Notify supervisory authority (if required)
5. Notify affected users (if high risk)
6. Document incident

### Privacy by Design
- Encryption by default (TLS, database encryption)
- Minimal data collection
- Access controls (need-to-know basis)
- Regular privacy audits

### Documentation
- Privacy Policy (updated regularly)
- Cookie Policy
- Data Processing Agreements (DPAs) with third parties
- Records of Processing Activities (ROPA)
```

**Quality Checks:**
- [ ] Data inventory documented (Article 30)
- [ ] Lawful basis identified for all processing
- [ ] User rights implemented (access, erasure, portability)
- [ ] Consent management system
- [ ] Data retention policies enforced
- [ ] Encryption of personal data
- [ ] Data breach notification plan
- [ ] Privacy Policy published
- [ ] DPAs with third-party processors
- [ ] Privacy by design principles applied

**Example Invocation:**
"use sc-security to implement GDPR compliance for user data"

---

### Task 9: Secure Session Management

**Triggers:** "session management", "session security", "session fixation", "session hijacking"

**When to Use:**
- Implementing user sessions
- Securing existing session system
- Session-based authentication
- Session security review

**Protocol:**

1. **Choose Session Strategy**
   - Server-side sessions (Redis, database)
   - Client-side sessions (signed cookies)
   - Hybrid (JWT with server-side validation)

2. **Session Creation**
   - Generate cryptographically random session IDs
   - Set secure cookie attributes (httpOnly, secure, sameSite)
   - Regenerate session ID after login (prevent fixation)
   - Set appropriate expiration

3. **Session Storage**
   - Redis for speed and auto-expiration
   - Database for persistence
   - Encrypt session data
   - Separate sessions per device

4. **Session Validation**
   - Validate session on every request
   - Check expiration
   - Verify user agent and IP (optional, for high security)
   - Detect concurrent sessions

5. **Session Termination**
   - Logout endpoint (clear session)
   - Automatic expiration
   - Revoke all sessions
   - Revoke on password change

**Output Format:**
```
## Secure Session Management

### Session Strategy
**Redis-based sessions** with httpOnly cookies

### Session Creation
```js
const session = require('express-session');
const RedisStore = require('connect-redis')(session);
const redis = require('redis');
const crypto = require('crypto');

const redisClient = redis.createClient({
  host: 'localhost',
  port: 6379,
});

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,  // Strong random secret
  name: 'sessionId',  // Don't use default 'connect.sid'
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,      // HTTPS only
    httpOnly: true,    // No JavaScript access
    sameSite: 'strict', // CSRF protection
    maxAge: 24 * 60 * 60 * 1000,  // 24 hours
  },
  genid: (req) => {
    // Cryptographically strong session ID
    return crypto.randomBytes(32).toString('hex');
  },
}));
```

### Session Fixation Prevention
```js
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  // Authenticate user
  const user = await authenticateUser(email, password);
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  // Regenerate session ID (prevent fixation)
  req.session.regenerate((err) => {
    if (err) return res.status(500).json({ error: 'Session error' });

    // Store user in session
    req.session.userId = user.id;
    req.session.email = user.email;
    req.session.loginTime = Date.now();

    res.json({ user });
  });
});
```

### Session Validation Middleware
```js
function validateSession(req, res, next) {
  if (!req.session || !req.session.userId) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  // Check session expiration
  const sessionAge = Date.now() - req.session.loginTime;
  const maxAge = 24 * 60 * 60 * 1000; // 24 hours
  if (sessionAge > maxAge) {
    req.session.destroy();
    return res.status(401).json({ error: 'Session expired' });
  }

  // Optional: Verify user agent (detect hijacking)
  if (req.session.userAgent && req.session.userAgent !== req.headers['user-agent']) {
    req.session.destroy();
    return res.status(401).json({ error: 'Session hijacking detected' });
  }

  next();
}

// Usage
app.get('/api/protected', validateSession, (req, res) => {
  res.json({ message: 'Protected resource' });
});
```

### Session Termination
```js
// Logout
app.post('/api/auth/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) return res.status(500).json({ error: 'Logout failed' });
    res.clearCookie('sessionId');
    res.json({ message: 'Logged out successfully' });
  });
});

// Revoke all sessions (on password change)
app.post('/api/users/change-password', validateSession, async (req, res) => {
  const userId = req.session.userId;
  const { oldPassword, newPassword } = req.body;

  // Verify old password, update to new password
  await updatePassword(userId, newPassword);

  // Revoke all sessions for this user
  const sessions = await redisClient.keys(`sess:${userId}:*`);
  await Promise.all(sessions.map(key => redisClient.del(key)));

  // Logout current session
  req.session.destroy();

  res.json({ message: 'Password changed, all sessions revoked' });
});
```

### Concurrent Session Detection
```js
// Track sessions per user
const SESSION_LIMIT = 3;  // Max 3 concurrent sessions

app.post('/api/auth/login', async (req, res) => {
  const user = await authenticateUser(email, password);

  // Check concurrent sessions
  const userSessions = await redisClient.keys(`sess:${user.id}:*`);
  if (userSessions.length >= SESSION_LIMIT) {
    // Revoke oldest session
    const oldestSession = await findOldestSession(userSessions);
    await redisClient.del(oldestSession);
  }

  // Create new session with user-specific key
  req.session.regenerate((err) => {
    req.session.userId = user.id;
    req.session.id = `sess:${user.id}:${crypto.randomBytes(16).toString('hex')}`;
    req.session.save();
    res.json({ user });
  });
});
```

### Session Storage Schema (Redis)
```
Key: sess:{userId}:{randomId}
Value: {
  userId: "uuid",
  email: "user@example.com",
  loginTime: 1640000000000,
  userAgent: "Mozilla/5.0...",
  ipAddress: "192.168.1.1"
}
TTL: 86400 (24 hours, auto-expires)
```

### Security Best Practices
- Generate session IDs with crypto.randomBytes (not Math.random)
- Regenerate session ID after login (prevent fixation)
- Use httpOnly cookies (prevent XSS theft)
- Use secure cookies (HTTPS only)
- Use sameSite=strict (CSRF protection)
- Set reasonable expiration (24 hours typical)
- Destroy session on logout
- Revoke all sessions on password change
- Monitor for unusual session activity
```

**Quality Checks:**
- [ ] Cryptographically random session IDs
- [ ] httpOnly, secure, sameSite cookies
- [ ] Session ID regenerated after login
- [ ] Session expiration enforced
- [ ] Session destroyed on logout
- [ ] All sessions revoked on password change
- [ ] Concurrent session limits (optional)
- [ ] Session hijacking detection (user agent check)
- [ ] Redis/database for session storage (not in-memory)

**Example Invocation:**
"use sc-security to implement secure session management with Redis"

---

### Task 10: Security Incident Response Plan

**Triggers:** "incident response", "security incident", "breach response", "IR plan"

**When to Use:**
- Preparing for security incidents
- After a security breach
- Compliance requirements
- Security readiness assessment

**Protocol:**

1. **Incident Classification**
   - Severity levels (P0-P4)
   - Incident types (breach, DDoS, malware, insider)
   - Impact assessment (data, users, revenue)

2. **Response Team**
   - Incident Commander (decision authority)
   - Technical Lead (investigation, remediation)
   - Communications Lead (internal/external comms)
   - Legal/Compliance (regulatory requirements)

3. **Response Phases**
   - **Detection**: Identify incident
   - **Containment**: Limit damage
   - **Eradication**: Remove threat
   - **Recovery**: Restore systems
   - **Post-Incident**: Lessons learned

4. **Communication Plan**
   - Internal stakeholders (executives, teams)
   - External parties (customers, regulators, press)
   - Notification timelines
   - Communication templates

5. **Documentation**
   - Incident timeline
   - Actions taken
   - Impact assessment
   - Root cause analysis
   - Lessons learned

**Output Format:**
```
## Security Incident Response Plan

### Incident Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| **P0 - Critical** | Active data breach, system compromise | Immediate | Database exposed, ransomware |
| **P1 - High** | High-risk vulnerability, potential breach | < 1 hour | SQL injection found, admin account compromised |
| **P2 - Medium** | Security issue, limited impact | < 4 hours | XSS vulnerability, failed auth spike |
| **P3 - Low** | Minor security concern | < 24 hours | Outdated dependency, weak password |
| **P4 - Info** | Security information, no risk | < 1 week | Security scan findings, policy questions |

### Response Team (RACI)

| Role | Name | Responsible | Accountable | Consulted | Informed |
|------|------|-------------|-------------|-----------|----------|
| **Incident Commander** | CTO | ✓ | ✓ | - | - |
| **Technical Lead** | Lead Engineer | ✓ | - | ✓ | - |
| **Security Engineer** | Security Team | ✓ | - | ✓ | - |
| **Communications** | Marketing Lead | ✓ | - | - | ✓ |
| **Legal** | Legal Counsel | - | - | ✓ | ✓ |
| **CEO** | CEO | - | - | - | ✓ |

### Incident Response Phases

#### 1. Detection & Triage (First 15 minutes)
```
1. Alert received (automated monitoring or manual report)
2. Acknowledge alert in PagerDuty
3. Initial assessment:
   - What happened? (brief description)
   - When did it start? (timestamp)
   - What systems affected? (API, database, admin panel)
   - Severity level? (P0-P4)
4. Notify Incident Commander (P0/P1 only)
5. Create incident Slack channel (#incident-YYYY-MM-DD)
6. Begin incident log (shared Google Doc)
```

#### 2. Containment (First hour)
```
P0/P1 Actions:
- Isolate affected systems (network segmentation)
- Revoke compromised credentials
- Block malicious IPs/users
- Enable read-only mode (if applicable)
- Preserve evidence (logs, snapshots)

P2/P3 Actions:
- Apply temporary mitigations
- Monitor for escalation
- Schedule fix deployment
```

#### 3. Investigation (Parallel with containment)
```
1. Collect evidence:
   - Application logs
   - Access logs
   - Database query logs
   - System logs (auth, sudo)
   - Network traffic captures

2. Timeline reconstruction:
   - Initial access (how did attacker get in?)
   - Lateral movement (what did they access?)
   - Data exfiltration (what was taken?)
   - Persistence mechanisms (backdoors, accounts)

3. Scope determination:
   - Affected users (count, identification)
   - Affected data (types, volume)
   - Attack vector (vulnerability, credential theft)
   - Attacker identity (if possible)
```

#### 4. Eradication (After containment)
```
1. Remove threat:
   - Patch vulnerabilities
   - Remove malware/backdoors
   - Delete unauthorized accounts
   - Reset all compromised credentials

2. System hardening:
   - Apply security updates
   - Strengthen access controls
   - Improve monitoring/detection
```

#### 5. Recovery (After eradication)
```
1. Restore services:
   - Bring systems back online gradually
   - Monitor for re-infection
   - Verify data integrity

2. Validation:
   - Penetration test (verify fix)
   - Monitor for 24-48 hours
   - Stakeholder sign-off
```

#### 6. Post-Incident Review (Within 1 week)
```
1. Incident timeline documentation
2. Root cause analysis (5 Whys)
3. What went well? What didn't?
4. Action items:
   - Technical improvements
   - Process improvements
   - Training needs
5. Update runbooks and monitoring
```

### Communication Plan

**Internal Communication** (Slack #incident-*)
- Every 30 minutes: Status update
- Major changes: Immediate notification
- Resolution: Final summary

**Customer Communication** (Email, Status Page)
- **P0/P1**: Within 1 hour of detection
- **P2**: Within 4 hours
- **P3/P4**: Not required unless customer impact

**Regulatory Communication**
- **GDPR**: Within 72 hours (if personal data breach)
- **HIPAA**: Within 60 days (if PHI breach)
- **PCI-DSS**: Immediately (if payment data breach)

**Communication Template (Customer Email)**
```
Subject: [Action Required] Security Incident Notification

Dear [Customer],

We are writing to inform you of a security incident that may have affected your account.

What Happened:
On [date], we detected [brief description of incident].

What Information Was Involved:
[Specific data types: email, name, encrypted password, etc.]

What We Are Doing:
- [Containment actions]
- [Remediation actions]
- [Monitoring enhancements]

What You Should Do:
- Reset your password immediately
- Enable two-factor authentication
- Monitor your account for unusual activity

We sincerely apologize for this incident and are committed to protecting your data.

For questions: security@example.com or 1-800-XXX-XXXX

Sincerely,
[Company] Security Team
```

### Incident Playbooks

**Playbook 1: Data Breach (P0)**
1. Isolate affected database
2. Revoke all API keys
3. Force password reset for all users
4. Notify legal team (regulatory requirements)
5. Prepare customer communication
6. Engage forensics team
7. Notify regulators (GDPR: 72h, state laws)

**Playbook 2: DDoS Attack (P1)**
1. Enable CloudFlare DDoS protection
2. Rate limit aggressive IPs
3. Scale infrastructure (auto-scaling)
4. Monitor for application-layer attacks
5. Contact ISP if network-layer DDoS

**Playbook 3: Compromised Admin Account (P0)**
1. Disable compromised account
2. Review admin actions (audit log)
3. Check for unauthorized changes (code, configs, users)
4. Reset all admin passwords
5. Enable MFA for all admins
6. Review access logs

### Incident Metrics
- Time to detection (target: <15 min)
- Time to containment (target: <1 hour for P0)
- Time to resolution (target: <24 hours for P0)
- Number of affected users
- Data exfiltrated (if any)

### Post-Incident Actions
- Update security runbooks
- Add detection rules
- Security training for team
- Penetration test to verify fix
- Monthly incident review
```

**Quality Checks:**
- [ ] Severity levels defined
- [ ] Response team identified (RACI)
- [ ] Detection mechanisms in place
- [ ] Containment procedures documented
- [ ] Communication plan (internal, customer, regulatory)
- [ ] Incident playbooks for common scenarios
- [ ] Post-incident review process
- [ ] Regulatory notification timelines
- [ ] Incident drills conducted quarterly

**Example Invocation:**
"use sc-security to create security incident response plan"

---

## Multi-Task Workflows

Common combinations of security tasks:

### Complete Security Audit
1. **Task 3**: OWASP Top 10 Security Audit
2. **Task 6**: Threat Modeling
3. **Task 1**: Authentication Review
4. **Task 2**: Authorization Review
5. **Task 5**: API Security Review

### New Application Security
1. **Task 1**: Implement Authentication
2. **Task 2**: Design Authorization Model
3. **Task 4**: Implement Encryption
4. **Task 5**: API Security Hardening
5. **Task 9**: Secure Session Management

### Compliance Project
1. **Task 8**: GDPR Compliance
2. **Task 4**: Data Encryption
3. **Task 10**: Incident Response Plan
4. **Task 3**: Security Audit

### DevSecOps Implementation
1. **Task 7**: Secure CI/CD Pipeline
2. **Task 3**: Security Audit (automated)
3. **Task 5**: API Security (automated scanning)

---

## Integration Examples

**With confidence-check:**
```
"use confidence-check then sc-security to implement OAuth2"
→ Assess feasibility first, then implement securely
```

**With sc-architecture:**
```
"use sc-architecture for API design then sc-security to harden it"
→ Design architecture, then apply security hardening
```

**With sc-quality:**
```
"use sc-security for auth implementation then sc-quality to test it"
→ Implement security, then penetration testing
```

---

## References

**Standards:**
- OWASP Top 10: https://owasp.org/Top10/
- CWE Top 25: https://cwe.mitre.org/top25/
- NIST Cybersecurity Framework: https://www.nist.gov/cyberframework
- PCI-DSS: https://www.pcisecuritystandards.org/

**Tools:**
- Snyk: https://snyk.io/
- OWASP ZAP: https://www.zaproxy.org/
- GitGuardian: https://www.gitguardian.com/
- Trivy: https://github.com/aquasecurity/trivy

**Compliance:**
- GDPR: https://gdpr.eu/
- HIPAA: https://www.hhs.gov/hipaa/
- SOC 2: https://www.aicpa.org/soc

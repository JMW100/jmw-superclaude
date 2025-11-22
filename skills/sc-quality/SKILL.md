# SC Quality - Quality & Testing Tasks

## When to Use This Skill

Use this skill for all quality assurance and testing tasks:
- Test strategy design
- Unit testing
- Integration testing
- End-to-end testing
- Code review processes
- Refactoring strategies
- Technical debt assessment
- Test coverage analysis
- Quality metrics and dashboards
- CI/CD quality gates

## Integration with Other Skills

- Use **sc-workflows** for code review and validation workflows
- Use **sc-security** for security testing
- Use **sc-performance** for performance testing
- Use **sc-agent** to orchestrate test-driven development
- Use **self-review** after implementation for quality validation

## Available Tasks

### Task 1: Design Testing Strategy

**Triggers:** "test strategy", "testing plan", "how to test", "test pyramid"

**Protocol:**
1. **Define Test Levels**: Unit (70%), Integration (20%), E2E (10%) - test pyramid
2. **Identify Test Scope**: What to test, what not to test
3. **Choose Tools**: Jest, Pytest, Playwright, Cypress
4. **Coverage Targets**: Overall 80%, critical paths 100%
5. **CI/CD Integration**: Run tests on every PR, block merge if failures

**Output:** Comprehensive testing strategy with tools, coverage targets, CI/CD integration

---

### Task 2: Unit Testing Implementation

**Triggers:** "unit test", "test functions", "test classes", "mock dependencies"

**Protocol:**
1. **Identify Testable Units**: Functions, methods, classes
2. **Write Test Cases**: Happy path, edge cases, error cases
3. **Use Mocks/Stubs**: Isolate unit under test
4. **Assertions**: Verify expected behavior
5. **Coverage**: Aim for 80%+ unit test coverage

**Output:** Unit tests with mocks, high coverage, clear assertions

**Example:**
```typescript
describe('UserService', () => {
  let userService: UserService;
  let mockRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepository = {
      findById: jest.fn(),
      save: jest.fn(),
    } as any;
    userService = new UserService(mockRepository);
  });

  describe('getUser', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', name: 'John' };
      mockRepository.findById.mockResolvedValue(mockUser);

      const result = await userService.getUser('1');

      expect(result).toEqual(mockUser);
      expect(mockRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw error when user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(userService.getUser('1')).rejects.toThrow('User not found');
    });
  });
});
```

---

### Task 3: Integration Testing

**Triggers:** "integration test", "test API", "database tests", "test services together"

**Protocol:**
1. **Test Service Integration**: Test multiple components working together
2. **Real Dependencies**: Use real database (test DB), real external services (or test doubles)
3. **Test Scenarios**: Complete workflows (create user → login → fetch profile)
4. **Setup/Teardown**: Clean database before/after tests
5. **Assertions**: Verify end-to-end behavior

**Output:** Integration tests covering key workflows, database interactions

**Example:**
```typescript
describe('User API Integration', () => {
  let app: Express;
  let db: Database;

  beforeAll(async () => {
    db = await setupTestDatabase();
    app = createApp(db);
  });

  afterAll(async () => {
    await db.close();
  });

  beforeEach(async () => {
    await db.query('TRUNCATE users CASCADE');
  });

  it('should create user and return 201', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', password: 'SecurePass123!' });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');

    // Verify in database
    const user = await db.query('SELECT * FROM users WHERE email = ?', ['test@example.com']);
    expect(user).toBeTruthy();
  });
});
```

---

### Task 4: End-to-End Testing

**Triggers:** "E2E test", "test user flow", "Playwright", "Cypress", "full workflow test"

**Protocol:**
1. **Identify Critical User Journeys**: Login flow, checkout flow, etc.
2. **Choose Tool**: Playwright (faster, multi-browser), Cypress (easier debugging)
3. **Write E2E Tests**: Simulate real user interactions
4. **Use Page Object Model**: Abstract page interactions
5. **Run in CI/CD**: Test against staging environment

**Output:** E2E tests covering critical user flows

**Example (Playwright):**
```typescript
import { test, expect } from '@playwright/test';

test.describe('User Login Flow', () => {
  test('should login successfully with valid credentials', async ({ page }) => {
    await page.goto('https://staging.example.com/login');

    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password');
    await page.click('[data-testid="login-button"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="user-name"]')).toHaveText('John Doe');
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('https://staging.example.com/login');

    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'wrongpassword');
    await page.click('[data-testid="login-button"]');

    await expect(page.locator('[data-testid="error-message"]')).toHaveText('Invalid credentials');
  });
});
```

---

### Task 5: Test Coverage Analysis

**Triggers:** "test coverage", "coverage report", "uncovered code", "improve coverage"

**Protocol:**
1. **Generate Coverage Report**: Use Jest, pytest-cov, or coverage tool
2. **Analyze Results**: Overall coverage, per-file coverage, uncovered lines
3. **Identify Gaps**: Critical code without tests, low-coverage files
4. **Prioritize**: Test critical paths first (authentication, payments)
5. **Set Targets**: Overall 80%, critical paths 100%

**Output:** Coverage report with gaps identified, prioritized test writing plan

**Example Coverage Report:**
```
Coverage Summary:
  Statements   : 78% ( 450/577 )
  Branches     : 72% ( 150/208 )
  Functions    : 82% ( 95/116 )
  Lines        : 78% ( 445/570 )

Low Coverage Files:
  src/services/payment.service.ts : 45% (critical - needs improvement)
  src/utils/validators.ts         : 60% (medium priority)
  src/controllers/admin.ts        : 55% (medium priority)

Uncovered Critical Paths:
  - Payment processing error handling
  - User authorization edge cases
  - Database transaction rollback
```

---

### Task 6: Code Review Process

**Triggers:** "code review", "review checklist", "PR review", "review guidelines"

**Protocol:**
1. **Review Checklist**:
   - Functionality: Does it work? Edge cases handled?
   - Code Quality: Readable? Maintainable? DRY?
   - Tests: Adequate coverage? Meaningful tests?
   - Security: Input validation? SQL injection prevention?
   - Performance: Efficient? No N+1 queries?
2. **Provide Constructive Feedback**: Be specific, suggest improvements
3. **Approval Criteria**: All tests pass, no critical issues, code quality standards met
4. **Follow-Up**: Track that feedback is addressed

**Output:** Code review checklist, detailed feedback, approval/rejection decision

---

### Task 7: Refactoring Strategy

**Triggers:** "refactor", "improve code quality", "clean up code", "remove duplication"

**Protocol:**
1. **Identify Code Smells**:
   - Long functions (>50 lines)
   - Duplicated code
   - Complex conditionals
   - Large classes (>300 lines)
2. **Prioritize Refactorings**: High-impact, low-risk first
3. **Common Refactorings**:
   - Extract function/method
   - Extract class
   - Rename for clarity
   - Simplify conditionals
   - Remove duplication (DRY)
4. **Test Coverage**: Ensure tests exist before refactoring
5. **Incremental Changes**: Small commits, test after each change

**Output:** Refactoring plan with prioritized code smells, implementation steps

---

### Task 8: Technical Debt Assessment

**Triggers:** "technical debt", "code smell", "debt assessment", "what needs fixing"

**Protocol:**
1. **Identify Technical Debt**:
   - Outdated dependencies
   - Missing tests
   - Code duplication
   - Poor architecture decisions
   - Incomplete error handling
2. **Quantify Debt**: Effort to fix (hours/days), impact on velocity
3. **Prioritize**:
   - **Critical**: Blocks new features, security risk
   - **High**: Slows development significantly
   - **Medium**: Minor friction
   - **Low**: Nice to have
4. **Create Plan**: Schedule debt reduction sprints (20% of sprint capacity)

**Output:** Technical debt inventory with priorities, reduction plan

---

### Task 9: Quality Metrics Dashboard

**Triggers:** "quality metrics", "code quality dashboard", "track quality", "quality KPIs"

**Protocol:**
1. **Define Metrics**:
   - Test coverage (target 80%)
   - Code churn (high churn = risky code)
   - Defect density (bugs per 1000 lines)
   - Code complexity (cyclomatic complexity)
   - PR review time (target <24 hours)
   - Build success rate (target >95%)
2. **Choose Tools**: SonarQube, CodeClimate, GitHub Insights
3. **Set Baselines**: Measure current state
4. **Set Targets**: Gradual improvement goals
5. **Monitor Trends**: Weekly/monthly reports

**Output:** Quality dashboard with metrics, trends, targets

---

### Task 10: CI/CD Quality Gates

**Triggers:** "quality gates", "CI/CD quality", "automated quality checks", "fail build on quality"

**Protocol:**
1. **Define Quality Gates**:
   - All tests pass (unit, integration, E2E)
   - Code coverage ≥80%
   - No high/critical security vulnerabilities
   - Linter passes (no errors)
   - No code smells (SonarQube quality gate)
2. **Fail Fast**: Block PR merge if gates fail
3. **Exceptions**: Define process for bypassing gates (with approval)
4. **Monitor**: Track gate failures, improve over time

**Output:** CI/CD quality gate configuration, enforcement rules

**Example GitHub Actions:**
```yaml
name: Quality Gates

on: pull_request

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run tests
        run: npm test -- --coverage

      - name: Check coverage threshold
        run: |
          COVERAGE=$(npm test -- --coverage --coverageReporters=text-summary | grep Statements | awk '{print $3}' | sed 's/%//')
          if [ $COVERAGE -lt 80 ]; then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

      - name: Run linter
        run: npm run lint

      - name: Security scan
        run: npm audit --audit-level=high

      - name: SonarQube scan
        uses: sonarsource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

---

## Multi-Task Workflows

**Complete Testing Implementation:**
1. Task 1: Design test strategy
2. Task 2: Write unit tests (80% coverage)
3. Task 3: Write integration tests (API/database)
4. Task 4: Write E2E tests (critical flows)
5. Task 10: Add CI/CD quality gates

**Quality Improvement Initiative:**
1. Task 8: Assess technical debt
2. Task 7: Plan refactoring
3. Task 5: Improve test coverage
4. Task 9: Set up quality metrics dashboard

---

## Integration Examples

"use sc-quality to design test strategy then implement unit tests"
"use sc-workflows to review code then sc-quality to assess technical debt"
"use sc-agent with TDD: sc-quality to write tests first, then implement"

---

## References

- Test Pyramid: https://martinfowler.com/articles/practical-test-pyramid.html
- Playwright: https://playwright.dev/
- Jest: https://jestjs.io/
- SonarQube: https://www.sonarqube.org/

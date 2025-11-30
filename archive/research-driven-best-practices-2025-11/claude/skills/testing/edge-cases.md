# Edge Case Testing Reference

This file is loaded by the testing skill when detailed edge case patterns are needed.

## Comprehensive Edge Case Checklist

### Input Type Edge Cases

| Category | Test Cases |
|----------|------------|
| Strings | Empty `""`, whitespace only `"   "`, very long (10k+ chars), Unicode, emoji, null bytes, newlines, tabs |
| Numbers | 0, -0, negative, MAX_SAFE_INTEGER, MIN_SAFE_INTEGER, Infinity, -Infinity, NaN, floats with many decimals |
| Arrays | Empty `[]`, single element, very large (10k+), sparse arrays, nested arrays, arrays with holes |
| Objects | Empty `{}`, null, undefined, circular references, prototype pollution attempts, deeply nested |
| Dates | Invalid dates, leap years (Feb 29), timezone boundaries, DST transitions, epoch (1970-01-01), far future/past |

### Domain-Specific Edge Cases

#### User Input
- SQL injection: `'; DROP TABLE users; --`
- XSS attempts: `<script>alert('xss')</script>`
- Path traversal: `../../../etc/passwd`
- Null bytes: `file\x00.txt`
- Unicode normalization: `café` vs `café` (different byte sequences)

#### Email Addresses
- Valid unusual: `user+tag@domain.com`, `"quoted"@domain.com`
- International: `用户@例子.广告`
- Long local part: `a{64}@domain.com`
- Multiple dots: `user..name@domain.com` (invalid)

#### Passwords
- Minimum length boundary
- Maximum length (if any)
- Unicode characters
- Spaces (leading, trailing, only spaces)
- Common passwords to reject

#### Currency/Money
- Zero amounts
- Negative amounts (refunds)
- Very small: `0.001`
- Very large: `999999999.99`
- Rounding: `10.005` → `10.01` or `10.00`?
- Different currencies

#### Dates and Times
- Timezone edge cases:
  - UTC vs local
  - DST transitions
  - Midnight boundaries
- Date boundaries:
  - Month end (28, 29, 30, 31)
  - Year end (Dec 31 → Jan 1)
  - Century boundaries
- Invalid dates:
  - Feb 30
  - Month 13
  - Negative years

### Async/Concurrent Edge Cases

```typescript
// Race conditions
it('handles concurrent updates correctly', async () => {
  const results = await Promise.all([
    updateCounter(1),
    updateCounter(1),
    updateCounter(1),
  ]);
  
  const finalValue = await getCounter();
  expect(finalValue).toBe(3); // Not 1!
});

// Timeout handling
it('rejects after timeout', async () => {
  jest.useFakeTimers();
  const promise = fetchWithTimeout(5000);
  
  jest.advanceTimersByTime(5001);
  
  await expect(promise).rejects.toThrow('Timeout');
  jest.useRealTimers();
});

// Cancellation
it('handles request cancellation', async () => {
  const controller = new AbortController();
  const promise = fetchData({ signal: controller.signal });
  
  controller.abort();
  
  await expect(promise).rejects.toThrow('aborted');
});

// Out-of-order responses
it('uses latest request result when requests finish out of order', async () => {
  // Simulate slow first request, fast second request
  let resolveFirst: (value: string) => void;
  const firstRequest = new Promise<string>(r => resolveFirst = r);
  const secondRequest = Promise.resolve('second');
  
  // Trigger both requests
  const result1 = component.search('first');  // slow
  const result2 = component.search('second'); // fast
  
  // Second finishes first
  await act(async () => {
    await secondRequest;
  });
  
  // First finishes later
  resolveFirst!('first');
  await act(async () => {
    await firstRequest;
  });
  
  // Should show 'second', not 'first'
  expect(component.displayedResult).toBe('second');
});
```

### Error Condition Edge Cases

```typescript
// Network errors
it('handles network failure', async () => {
  server.use(
    rest.get('/api/data', (req, res) => {
      return res.networkError('Connection refused');
    })
  );
  
  await expect(fetchData()).rejects.toThrow('Network error');
});

// Partial failures
it('continues processing after partial failure', async () => {
  const items = ['a', 'b', 'invalid', 'c'];
  const results = await processItems(items);
  
  expect(results.successful).toEqual(['a', 'b', 'c']);
  expect(results.failed).toEqual(['invalid']);
});

// Retry exhaustion
it('gives up after max retries', async () => {
  let attempts = 0;
  server.use(
    rest.get('/api/data', (req, res, ctx) => {
      attempts++;
      return res(ctx.status(500));
    })
  );
  
  await expect(fetchWithRetry('/api/data', { maxRetries: 3 }))
    .rejects.toThrow('Max retries exceeded');
  
  expect(attempts).toBe(4); // Initial + 3 retries
});
```

### State Machine Edge Cases

```typescript
// Invalid state transitions
it('rejects invalid state transition', () => {
  const order = new Order({ status: 'shipped' });
  
  expect(() => order.cancel())
    .toThrow('Cannot cancel shipped order');
});

// Idempotency
it('handles duplicate actions gracefully', async () => {
  const payment = await processPayment(orderId);
  const duplicate = await processPayment(orderId);
  
  expect(duplicate.id).toBe(payment.id);
  expect(duplicate.status).toBe('already_processed');
});
```

## Property-Based Test Generators

```typescript
import fc from 'fast-check';

// Arbitrary generators for domain types
const emailArbitrary = fc.tuple(
  fc.stringOf(fc.constantFrom(...'abcdefghijklmnopqrstuvwxyz0123456789'), { minLength: 1 }),
  fc.constantFrom('gmail.com', 'example.com', 'test.org')
).map(([local, domain]) => `${local}@${domain}`);

const userArbitrary = fc.record({
  email: emailArbitrary,
  name: fc.string({ minLength: 1, maxLength: 100 }),
  age: fc.integer({ min: 0, max: 150 }),
});

const moneyArbitrary = fc.record({
  amount: fc.integer({ min: 0, max: 99999999 }), // cents
  currency: fc.constantFrom('USD', 'EUR', 'GBP'),
});

// Using in tests
it('user creation is idempotent by email', () => {
  fc.assert(
    fc.property(userArbitrary, async (user) => {
      const first = await createUser(user);
      const second = await createUser(user);
      return first.id === second.id;
    })
  );
});
```

## Test Data Builders

```typescript
// Builder pattern for test data
class UserBuilder {
  private data: Partial<User> = {
    email: 'default@example.com',
    name: 'Default User',
    role: 'user',
  };
  
  withEmail(email: string) {
    this.data.email = email;
    return this;
  }
  
  withRole(role: 'user' | 'admin') {
    this.data.role = role;
    return this;
  }
  
  asAdmin() {
    return this.withRole('admin');
  }
  
  build(): User {
    return {
      id: crypto.randomUUID(),
      createdAt: new Date().toISOString(),
      ...this.data,
    } as User;
  }
  
  async create(): Promise<User> {
    return createTestUser(this.data);
  }
}

// Usage
const adminUser = await new UserBuilder()
  .withEmail('admin@example.com')
  .asAdmin()
  .create();
```

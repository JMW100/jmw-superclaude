---
name: sc-performance
description: Performance optimization including profiling, query optimization, caching, and load testing
---

# SC Performance - Performance Optimization Tasks

## When to Use This Skill

Use this skill for all performance-related tasks:
- Performance profiling and bottleneck identification
- Database query optimization
- Caching strategy implementation
- Load testing and capacity planning
- Frontend performance optimization
- API response optimization
- Memory optimization
- Scalability assessment

## Integration with Other Skills

- Use **sc-workflows** for troubleshooting performance issues
- Use **sc-architecture** for scalability architecture design
- Use **sc-security** for security-performance trade-offs
- Use **confidence-check** before major performance refactoring
- Use **self-review** to validate performance improvements

## Available Tasks

### Task 1: Performance Profiling & Bottleneck Identification

**Triggers:** "slow performance", "bottleneck", "profile performance", "performance issue"

**Protocol:**
1. **Establish Baseline**: Measure current performance (response time, throughput, resource usage)
2. **Identify Bottlenecks**: Use profiling tools (Node.js profiler, Chrome DevTools, database slow query log)
3. **Analyze Results**: CPU, memory, I/O, network - which is the bottleneck?
4. **Prioritize Fixes**: Impact vs effort matrix
5. **Measure After Fix**: Verify improvement

**Output:** Performance profile report with bottlenecks identified, prioritized optimization plan

---

### Task 2: Database Query Optimization

**Triggers:** "slow query", "database performance", "optimize queries", "N+1 problem"

**Protocol:**
1. **Identify Slow Queries**: Enable slow query log, monitor query execution time
2. **Analyze Query Plans**: Use EXPLAIN/EXPLAIN ANALYZE
3. **Optimization Strategies**:
   - Add indexes (B-tree for equality, GIN for JSON/arrays)
   - Avoid SELECT *, fetch only needed columns
   - Fix N+1 queries (use joins or batch loading)
   - Optimize JOIN order
   - Use query result caching
4. **Validate**: Re-run EXPLAIN, measure query time improvement

**Output:** Optimized queries with execution plan comparison, index recommendations

---

### Task 3: Caching Implementation

**Triggers:** "add caching", "cache strategy", "improve cache hit rate", "Redis caching"

**Protocol:**
1. **Identify Cacheable Data**: Frequently accessed, infrequently changing data
2. **Choose Cache Layer**: Application (Redis), CDN (CloudFront), database query cache
3. **Cache Patterns**: Cache-aside, write-through, write-behind, read-through
4. **TTL Strategy**: Set appropriate expiration times
5. **Invalidation**: Event-based or TTL-based invalidation
6. **Monitor**: Cache hit rate (target >80%), eviction rate

**Output:** Caching strategy with cache layers, TTL policies, invalidation logic

---

### Task 4: Frontend Performance Optimization

**Triggers:** "slow page load", "optimize bundle size", "improve FCP", "lazy loading"

**Protocol:**
1. **Measure Core Web Vitals**: LCP, FID, CLS using Lighthouse
2. **Bundle Optimization**:
   - Code splitting (route-based, component-based)
   - Tree shaking (remove unused code)
   - Minification and compression (gzip/brotli)
3. **Asset Optimization**:
   - Image optimization (WebP, responsive images, lazy loading)
   - Font optimization (subset fonts, font-display: swap)
   - CSS/JS minification
4. **Loading Strategy**:
   - Lazy load below-the-fold content
   - Prefetch critical resources
   - Service worker for offline caching
5. **Validate**: Re-run Lighthouse, measure improvement

**Output:** Optimized frontend with Web Vitals improvements, bundle size reduction

---

### Task 5: API Response Optimization

**Triggers:** "slow API", "reduce latency", "API performance", "optimize endpoint"

**Protocol:**
1. **Measure Current Performance**: Response time p50, p95, p99
2. **Optimization Techniques**:
   - Database query optimization (see Task 2)
   - Add caching layer (Redis)
   - Reduce payload size (pagination, field filtering)
   - Async processing (move slow operations to queue)
   - Connection pooling (database, HTTP)
   - Compression (gzip response)
3. **Parallel Requests**: Fetch independent data concurrently
4. **Monitor**: Track latency metrics, set SLOs (e.g., p95 <200ms)

**Output:** API optimization plan with latency reduction targets, implementation steps

---

### Task 6: Memory Optimization

**Triggers:** "memory leak", "high memory usage", "out of memory", "heap snapshot"

**Protocol:**
1. **Detect Memory Leaks**: Monitor memory over time (should be sawtooth, not linear growth)
2. **Heap Snapshot Analysis**: Use Chrome DevTools or Node.js heap profiler
3. **Common Causes**:
   - Global variables accumulating data
   - Event listeners not removed
   - Closures retaining references
   - Large in-memory caches
4. **Fixes**:
   - Remove unused event listeners
   - Clear intervals/timeouts
   - Limit cache size (LRU cache)
   - Stream large data (don't load all in memory)
5. **Validate**: Monitor memory after fix

**Output:** Memory leak root cause, fix implementation, memory usage graphs

---

### Task 7: Load Testing & Capacity Planning

**Triggers:** "load test", "capacity planning", "stress test", "how many users can we handle"

**Protocol:**
1. **Define Load Scenarios**: Expected traffic (users/sec, requests/sec)
2. **Choose Tool**: k6, JMeter, Gatling, Artillery
3. **Run Load Tests**:
   - Baseline test (normal load)
   - Stress test (peak load)
   - Spike test (sudden traffic spike)
   - Soak test (sustained load over time)
4. **Measure**: Response time, error rate, throughput, resource usage
5. **Identify Limits**: At what load does system degrade?
6. **Capacity Planning**: Calculate resources needed for target load

**Output:** Load test results, capacity recommendations, scaling strategy

---

### Task 8: Scalability Assessment

**Triggers:** "scale", "scalability", "horizontal scaling", "can this handle 10x traffic"

**Protocol:**
1. **Current Capacity**: Document current limits (users, requests/sec)
2. **Bottleneck Analysis**: What prevents scaling? (Database, stateful sessions, single point of failure)
3. **Scaling Strategies**:
   - **Horizontal Scaling**: Add more servers (stateless app, load balancer)
   - **Vertical Scaling**: Bigger servers (easier but limited)
   - **Database Scaling**: Read replicas, sharding, caching
4. **Architecture Changes**:
   - Stateless applications (session in Redis/database)
   - Queue for async processing
   - CDN for static assets
   - Microservices for independent scaling
5. **Cost Analysis**: Resources needed vs budget
6. **Implementation Plan**: Phased scaling approach

**Output:** Scalability assessment report, architecture changes, cost projections

---

## Multi-Task Workflows

**Complete Performance Optimization:**
1. Task 1: Profiling (identify bottlenecks)
2. Task 2: Database optimization (if database is bottleneck)
3. Task 3: Caching (reduce database load)
4. Task 5: API optimization (reduce latency)
5. Task 7: Load testing (validate improvements)

**Preparing for Traffic Spike:**
1. Task 7: Load testing (establish baseline)
2. Task 8: Scalability assessment
3. Task 3: Caching (reduce load)
4. Task 7: Re-test after optimizations

---

## Integration Examples

"use sc-performance to profile slow API then optimize database queries"
"use sc-workflows to troubleshoot performance issue then sc-performance to fix it"
"use sc-architecture for cache design then sc-performance to implement it"

---

## References

- Web.dev Performance: https://web.dev/performance/
- Database Performance Tuning: https://use-the-index-luke.com/
- k6 Load Testing: https://k6.io/docs/

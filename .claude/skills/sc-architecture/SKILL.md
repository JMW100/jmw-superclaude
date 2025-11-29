# SC Architecture - System Design Tasks

## When to Use This Skill

Use this skill for all architecture and system design tasks:
- Designing distributed systems and microservices
- API architecture (REST, GraphQL, gRPC)
- Technology stack selection and evaluation
- Database architecture and data modeling
- Component and service design
- Infrastructure planning
- Event-driven architecture
- System integration patterns
- Scalability and reliability planning
- Migration strategies

## Integration with Other Skills

- Use **confidence-check** before major architectural decisions to assess feasibility
- Use **sc-security** for security architecture review and threat modeling
- Use **sc-performance** for performance architecture and optimization
- Use **sc-agent** to orchestrate multi-phase architecture work
- Use **deep-research** to investigate architecture patterns and technologies
- Use **self-review** to validate architectural decisions

## Available Tasks

### Task 1: Design Microservices Architecture

**Triggers:** "microservices", "service boundaries", "decompose monolith", "distributed system"

**When to Use:**
- Breaking monolith into services
- Designing new distributed system
- Planning service boundaries and responsibilities
- Multi-tenant SaaS architecture

**Protocol:**

1. **Domain Analysis**
   - Identify bounded contexts using domain-driven design
   - Map business capabilities to domains
   - Define domain models and entities
   - Identify aggregates and value objects

2. **Service Boundary Definition**
   - One service per business capability (single responsibility)
   - Minimize cross-service dependencies
   - Define clear service interfaces and contracts
   - Establish data ownership per service

3. **Communication Design**
   - Synchronous (REST/gRPC) for queries and requests
   - Asynchronous (Events/Messages) for state changes
   - API Gateway for external client access
   - Service mesh for internal communication (optional)

4. **Data Strategy**
   - Database per service pattern
   - Event sourcing for audit trail and temporal queries
   - CQRS (Command Query Responsibility Segregation) for read/write separation
   - Saga pattern for distributed transactions

5. **Resilience Patterns**
   - Circuit breakers for fault isolation
   - Retry with exponential backoff
   - Bulkheads and timeouts
   - Health checks and graceful degradation

**Output Format:**
```
## Microservices Architecture

### Service Boundaries
- **User Service**: Authentication, profiles, user preferences
- **Product Service**: Catalog, inventory, pricing, search
- **Order Service**: Shopping cart, checkout, order history
- **Payment Service**: Payment processing, refunds, billing
- **Notification Service**: Email, SMS, push notifications

### Communication Patterns
- **Synchronous**: REST APIs for queries, gRPC for internal RPC
- **Asynchronous**: Kafka/RabbitMQ event bus for state changes
- **Gateway**: API Gateway (Kong/Ambassador) for external clients

### Data Ownership
- User Service → PostgreSQL (user data)
- Product Service → PostgreSQL (products) + Elasticsearch (search)
- Order Service → PostgreSQL (orders) + Redis (cart)
- Payment Service → PostgreSQL (transactions, PCI-compliant)
- Notification Service → MongoDB (templates, logs)

### Technology Stack
- **Languages**: Go (high-performance), Node.js (I/O-heavy)
- **Messaging**: Kafka for events, Redis for pub/sub
- **Service Mesh**: Istio for traffic management
- **Observability**: Prometheus + Grafana + Jaeger

### Deployment Strategy
- Kubernetes for orchestration
- Horizontal pod autoscaling
- Blue-green deployment per service
- Canary releases for critical services
```

**Quality Checks:**
- [ ] Each service has single, well-defined responsibility
- [ ] Data ownership clearly defined (no shared databases)
- [ ] Communication patterns appropriate for use case
- [ ] Failure scenarios addressed with resilience patterns
- [ ] Scalability considered (stateless services, horizontal scaling)
- [ ] Security boundaries defined
- [ ] Observability plan included

**Example Invocation:**
"use sc-architecture to design microservices for e-commerce platform"

---

### Task 2: Design REST API Architecture

**Triggers:** "API design", "REST API", "endpoint design", "API architecture", "RESTful"

**When to Use:**
- Designing new API
- Standardizing existing API
- API versioning strategy
- Public API development

**Protocol:**

1. **Resource Identification**
   - Identify core resources (nouns, not verbs)
   - Define resource hierarchies and relationships
   - Determine singleton vs collection resources

2. **HTTP Method Mapping**
   - GET: Retrieve resource(s) (idempotent, cacheable)
   - POST: Create new resource (non-idempotent)
   - PUT: Replace entire resource (idempotent)
   - PATCH: Partial update (idempotent)
   - DELETE: Remove resource (idempotent)

3. **URL Structure**
   - `/api/v1/resource` - Collection endpoint
   - `/api/v1/resource/{id}` - Single resource
   - `/api/v1/resource/{id}/subresource` - Nested resources
   - Versioning: URL path (`/v1/`) or header (`Accept: application/vnd.api+json;version=1`)

4. **Request/Response Schema**
   - JSON as default format
   - Consistent structure (data wrapper, metadata)
   - ISO 8601 dates, snake_case or camelCase (consistent)
   - Pagination (cursor-based or offset-based)

5. **Error Handling**
   - HTTP status codes (2xx success, 4xx client errors, 5xx server errors)
   - Standardized error response format
   - Error codes for client-side handling
   - Validation error details

6. **Authentication & Authorization**
   - OAuth 2.0 / JWT tokens
   - API keys for service-to-service
   - Rate limiting per user/API key
   - CORS configuration

7. **Documentation**
   - OpenAPI/Swagger specification
   - Interactive API explorer
   - Code examples in multiple languages
   - Changelog for API versions

**Output Format:**
```
## REST API Specification

### Base URL
`https://api.example.com/v1`

### Authentication
Bearer token (JWT) in Authorization header

### Endpoints

#### Users
- `GET /users` - List users (paginated)
- `POST /users` - Create user
- `GET /users/{id}` - Get user by ID
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user
- `GET /users/{id}/orders` - Get user's orders

#### Products
- `GET /products` - List products (filterable, searchable)
- `POST /products` - Create product (admin only)
- `GET /products/{id}` - Get product details
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product

### Request/Response Examples

**GET /users?page=2&limit=20**
Response 200:
```json
{
  "data": [
    {"id": 1, "name": "John Doe", "email": "john@example.com"}
  ],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "next": "/users?page=3&limit=20"
  }
}
```

**Error Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      {"field": "email", "message": "Must be valid email"}
    ]
  }
}
```

### Rate Limiting
- 1000 requests/hour per user
- 429 Too Many Requests with Retry-After header

### Versioning Strategy
- URL versioning: `/v1/`, `/v2/`
- Deprecation notice 6 months before removal
```

**Quality Checks:**
- [ ] RESTful principles followed (resources, not actions)
- [ ] Consistent naming conventions
- [ ] Comprehensive error handling
- [ ] Authentication/authorization implemented
- [ ] Rate limiting configured
- [ ] Versioning strategy defined
- [ ] OpenAPI documentation complete
- [ ] Pagination for collections
- [ ] HATEOAS links (optional, for mature APIs)

**Example Invocation:**
"use sc-architecture to design REST API for user management"

---

### Task 3: Technology Stack Selection

**Triggers:** "choose stack", "technology selection", "evaluate frameworks", "tech stack"

**When to Use:**
- Starting new project
- Modernizing legacy system
- Evaluating competing technologies
- Architecture decision records

**Protocol:**

1. **Gather Requirements**
   - Performance requirements (latency, throughput)
   - Scale requirements (users, data volume, geography)
   - Team expertise and learning curve
   - Timeline and delivery constraints
   - Budget and operational costs

2. **Identify Options**
   - Backend: Node.js, Go, Python, Java, Rust
   - Frontend: React, Vue, Angular, Svelte
   - Database: PostgreSQL, MySQL, MongoDB, DynamoDB
   - Cache: Redis, Memcached
   - Message Queue: Kafka, RabbitMQ, SQS

3. **Evaluate Against Criteria** (Weighted Scoring)
   - **Performance** (25%): Benchmarks, latency, throughput
   - **Ecosystem** (20%): Libraries, community, documentation
   - **Team Fit** (20%): Existing skills, hiring availability
   - **Scalability** (15%): Horizontal scaling, cloud-native
   - **Maintenance** (10%): Long-term support, updates
   - **Cost** (10%): Licenses, infrastructure, development time

4. **Build Proof of Concept**
   - Top 2 options
   - Core use case implementation
   - Performance testing
   - Developer experience assessment

5. **Make Decision**
   - Document decision rationale (Architecture Decision Record)
   - Identify risks and mitigation strategies
   - Plan migration path (if replacing existing)

**Output Format:**
```
## Technology Stack Decision

### Requirements Summary
- Scale: 10K concurrent users, 1M requests/day
- Performance: <200ms API response, <2s page load
- Team: 5 developers (3 JavaScript, 2 Python)
- Timeline: 6 months to MVP
- Budget: Cloud hosting ~$2K/month

### Options Evaluated

| Criteria | Node.js + React | Go + React | Python + React | Weight |
|----------|----------------|------------|----------------|--------|
| Performance | 8/10 | 10/10 | 7/10 | 25% |
| Ecosystem | 10/10 | 7/10 | 9/10 | 20% |
| Team Fit | 10/10 | 5/10 | 8/10 | 20% |
| Scalability | 8/10 | 10/10 | 7/10 | 15% |
| Maintenance | 9/10 | 8/10 | 9/10 | 10% |
| Cost | 8/10 | 8/10 | 8/10 | 10% |
| **Total Score** | **8.9** | **7.9** | **7.9** | - |

### Recommended Stack
**Backend**: Node.js (Express/Fastify)
**Frontend**: React with TypeScript
**Database**: PostgreSQL
**Cache**: Redis
**Message Queue**: Redis Pub/Sub (start simple)
**Infrastructure**: AWS (ECS Fargate)

### Rationale
- Node.js wins on team expertise (60% JavaScript familiarity)
- React ecosystem mature with excellent tooling
- PostgreSQL for ACID compliance + JSON support
- AWS ECS for managed containers without Kubernetes complexity
- Can scale to Go microservices later if needed

### Risks & Mitigation
- **Risk**: Node.js CPU-intensive tasks slower than Go
  **Mitigation**: Offload heavy compute to worker services (Go/Python)
- **Risk**: Single-threaded Node.js bottlenecks
  **Mitigation**: Horizontal scaling + load balancing
- **Risk**: TypeScript learning curve
  **Mitigation**: Start with JavaScript, gradual TypeScript adoption

### Migration Path
- Phase 1: Core API in Node.js
- Phase 2: Add Redis caching
- Phase 3: Extract heavy services to Go (if needed)
```

**Quality Checks:**
- [ ] All requirements captured
- [ ] Multiple options evaluated objectively
- [ ] Weighted scoring used (not gut feeling)
- [ ] Team skills considered
- [ ] Proof of concept built
- [ ] Risks identified with mitigation
- [ ] Decision documented (ADR)
- [ ] Long-term maintenance considered

**Example Invocation:**
"use sc-architecture to select technology stack for SaaS product"

---

### Task 4: Database Architecture Design

**Triggers:** "database design", "schema design", "data model", "database architecture"

**When to Use:**
- Designing new database schema
- Optimizing existing schema
- Planning data migrations
- Multi-database strategy

**Protocol:**

1. **Requirements Analysis**
   - Data entities and relationships
   - Query patterns (read-heavy vs write-heavy)
   - Consistency requirements (ACID vs eventual)
   - Scale requirements (data volume, growth rate)

2. **Database Selection**
   - Relational (PostgreSQL, MySQL) for structured, transactional
   - Document (MongoDB, DynamoDB) for flexible schema
   - Graph (Neo4j) for relationship-heavy data
   - Time-series (InfluxDB, TimescaleDB) for metrics
   - Search (Elasticsearch) for full-text search

3. **Schema Design**
   - **Relational**: Normalize to 3NF, denormalize for performance
   - **Document**: Embed vs reference based on query patterns
   - Define primary keys, foreign keys, constraints
   - Indexing strategy (B-tree, hash, full-text)

4. **Partitioning & Sharding**
   - Horizontal partitioning (sharding) for scale
   - Vertical partitioning for different access patterns
   - Partition key selection (even distribution)

5. **Data Integrity**
   - Constraints (NOT NULL, UNIQUE, CHECK)
   - Foreign key relationships
   - Transaction boundaries
   - Backup and recovery strategy

**Output Format:**
```
## Database Architecture

### Database Selection
**Primary**: PostgreSQL (ACID, JSON support, mature)
**Cache**: Redis (session, frequently accessed)
**Search**: Elasticsearch (product search)

### Schema Design (PostgreSQL)

**users**
- id: UUID PRIMARY KEY
- email: VARCHAR(255) UNIQUE NOT NULL
- password_hash: VARCHAR(255) NOT NULL
- created_at: TIMESTAMP DEFAULT NOW()
- updated_at: TIMESTAMP DEFAULT NOW()

**products**
- id: UUID PRIMARY KEY
- name: VARCHAR(255) NOT NULL
- description: TEXT
- price: DECIMAL(10,2) NOT NULL
- inventory: INTEGER NOT NULL DEFAULT 0
- category_id: UUID REFERENCES categories(id)
- metadata: JSONB (flexible attributes)
- created_at: TIMESTAMP DEFAULT NOW()

**orders**
- id: UUID PRIMARY KEY
- user_id: UUID REFERENCES users(id)
- status: ENUM('pending', 'paid', 'shipped', 'delivered')
- total: DECIMAL(10,2) NOT NULL
- created_at: TIMESTAMP DEFAULT NOW()

**order_items**
- id: UUID PRIMARY KEY
- order_id: UUID REFERENCES orders(id)
- product_id: UUID REFERENCES products(id)
- quantity: INTEGER NOT NULL
- price: DECIMAL(10,2) NOT NULL

### Indexes
- users: email (UNIQUE)
- products: category_id, name (composite), metadata (GIN for JSONB)
- orders: user_id, status, created_at (composite)
- order_items: order_id, product_id

### Sharding Strategy (Future)
- Shard by user_id (hash-based) when >10M users
- Keep user, orders, order_items co-located

### Query Optimization
- Use connection pooling (pg-pool)
- Prepared statements for frequent queries
- Redis cache for product catalog (5min TTL)
- Read replicas for analytics queries
```

**Quality Checks:**
- [ ] Normalized to appropriate level (3NF or denormalized intentionally)
- [ ] All foreign key relationships defined
- [ ] Indexes created for common queries
- [ ] Data types appropriate (no VARCHAR(MAX) everywhere)
- [ ] Constraints enforce business rules
- [ ] Migration strategy defined
- [ ] Backup and recovery planned
- [ ] Query performance tested

**Example Invocation:**
"use sc-architecture to design database schema for e-commerce"

---

### Task 5: Event-Driven Architecture Design

**Triggers:** "event-driven", "messaging", "event sourcing", "CQRS", "asynchronous"

**When to Use:**
- Decoupling microservices
- Audit trail requirements
- High-throughput systems
- Real-time notifications

**Protocol:**

1. **Identify Events**
   - Business events (OrderPlaced, PaymentProcessed)
   - System events (UserLoggedIn, DataSynced)
   - Event naming: past tense (UserCreated not CreateUser)

2. **Design Event Schema**
   - Event type, timestamp, version
   - Payload (minimal, immutable)
   - Metadata (correlation ID, user context)

3. **Choose Messaging Infrastructure**
   - Kafka: High throughput, event log, replay capability
   - RabbitMQ: Complex routing, low latency
   - SQS/SNS: Managed, AWS-native
   - Redis Pub/Sub: Simple, fast, no persistence

4. **Event Flow Patterns**
   - **Pub/Sub**: One-to-many (order placed → inventory, notification, analytics)
   - **Event Sourcing**: Store events as source of truth
   - **CQRS**: Separate write (commands) and read (queries) models
   - **Saga**: Distributed transactions across services

5. **Error Handling**
   - Dead letter queues for failed events
   - Retry with exponential backoff
   - Idempotency (handle duplicate events)
   - Event versioning for schema evolution

**Output Format:**
```
## Event-Driven Architecture

### Events Catalog

**OrderPlaced**
```json
{
  "eventType": "OrderPlaced",
  "eventId": "uuid",
  "timestamp": "2025-01-01T10:00:00Z",
  "version": "1.0",
  "payload": {
    "orderId": "uuid",
    "userId": "uuid",
    "items": [...],
    "total": 99.99
  },
  "metadata": {
    "correlationId": "uuid",
    "source": "order-service"
  }
}
```

**PaymentProcessed**
**InventoryReserved**
**OrderShipped**

### Messaging Infrastructure
- **Kafka** for event bus
- Topics: orders, payments, inventory, notifications
- Partitioning by orderId for ordering guarantee
- Retention: 7 days

### Event Flow

OrderPlaced →
  → Inventory Service (reserve stock)
  → Payment Service (charge customer)
  → Notification Service (send confirmation)
  → Analytics Service (update metrics)

### Error Handling
- DLQ for failed events (manual review)
- Max 3 retries with exponential backoff
- Idempotency keys in payload
- Circuit breaker after 5 consecutive failures

### Monitoring
- Event lag per consumer
- Processing time per event type
- DLQ depth alerts
- Consumer health checks
```

**Quality Checks:**
- [ ] Events are immutable and past-tense
- [ ] Event schema versioned
- [ ] Idempotency handled
- [ ] Dead letter queue configured
- [ ] Monitoring and alerting
- [ ] Event replay capability (if using Kafka)
- [ ] Schema registry for validation (optional)

**Example Invocation:**
"use sc-architecture to design event-driven architecture for order processing"

---

### Task 6: Frontend Component Architecture

**Triggers:** "component design", "frontend architecture", "React architecture", "UI components"

**When to Use:**
- Building design system
- Frontend application architecture
- Component library
- State management design

**Protocol:**

1. **Component Hierarchy**
   - Atomic design: Atoms → Molecules → Organisms → Templates → Pages
   - Smart (container) vs Dumb (presentational) components
   - Shared components vs feature-specific

2. **State Management**
   - Local state (useState) for UI state
   - Context for cross-cutting concerns (theme, auth)
   - Redux/Zustand for global application state
   - React Query for server state

3. **Component Patterns**
   - Composition over inheritance
   - Render props / children patterns
   - Higher-order components (HOCs)
   - Custom hooks for reusable logic

4. **Styling Strategy**
   - CSS Modules (scoped styles)
   - Styled Components (CSS-in-JS)
   - Tailwind (utility-first)
   - Design tokens for consistency

5. **Accessibility**
   - Semantic HTML
   - ARIA labels and roles
   - Keyboard navigation
   - Screen reader testing

**Output Format:**
```
## Frontend Component Architecture

### Component Structure
```
src/
├── components/
│   ├── atoms/          # Button, Input, Icon
│   ├── molecules/      # FormField, Card, SearchBar
│   ├── organisms/      # Header, ProductList, CheckoutForm
│   └── templates/      # PageLayout, DashboardLayout
├── pages/              # Home, ProductDetail, Checkout
├── hooks/              # useAuth, useCart, useApi
├── context/            # AuthContext, ThemeContext
└── store/              # Redux slices (if needed)
```

### State Management Strategy
- **Local UI state**: useState (modals, dropdowns)
- **Form state**: React Hook Form
- **Server state**: React Query (products, orders)
- **Global state**: Zustand (cart, user preferences)
- **Auth**: Context + custom hook

### Component Example
```tsx
// Atom: Button
export const Button = ({ variant, children, ...props }) => (
  <button className={`btn btn-${variant}`} {...props}>
    {children}
  </button>
);

// Molecule: FormField
export const FormField = ({ label, error, ...props }) => (
  <div className="form-field">
    <label>{label}</label>
    <Input {...props} />
    {error && <span className="error">{error}</span>}
  </div>
);

// Organism: LoginForm
export const LoginForm = () => {
  const { login } = useAuth();
  const { register, handleSubmit, errors } = useForm();

  return (
    <form onSubmit={handleSubmit(login)}>
      <FormField label="Email" {...register('email')} error={errors.email} />
      <FormField label="Password" type="password" {...register('password')} />
      <Button variant="primary">Login</Button>
    </form>
  );
};
```

### Styling Approach
- **Tailwind CSS** for utility-first styling
- **Design tokens** in tailwind.config.js
- **Custom components** for complex UI

### Accessibility
- All interactive elements keyboard accessible
- ARIA labels on icon buttons
- Focus visible indicators
- Semantic HTML (nav, main, article)
```

**Quality Checks:**
- [ ] Component hierarchy clear (atomic design)
- [ ] State management strategy defined
- [ ] Reusable components extracted
- [ ] Accessibility considered (WCAG 2.1)
- [ ] Performance optimized (React.memo, lazy loading)
- [ ] TypeScript types (if using TS)
- [ ] Storybook documentation (optional)

**Example Invocation:**
"use sc-architecture to design React component architecture for dashboard"

---

### Task 7: API Gateway Design

**Triggers:** "API gateway", "gateway design", "API composition", "backend for frontend"

**When to Use:**
- Microservices with external clients
- Mobile + web with different needs
- Cross-cutting concerns (auth, rate limiting)
- API composition and aggregation

**Protocol:**

1. **Gateway Responsibilities**
   - Request routing to backend services
   - Authentication and authorization
   - Rate limiting and throttling
   - Request/response transformation
   - API composition (aggregating multiple services)
   - Caching
   - Logging and monitoring

2. **Choose Gateway Technology**
   - Kong: Feature-rich, plugin ecosystem
   - AWS API Gateway: Managed, AWS-native
   - NGINX: Lightweight, high-performance
   - Envoy: Service mesh integration
   - Custom (Express/Fastify): Full control

3. **Routing Patterns**
   - Path-based: `/users/*` → User Service
   - Host-based: `api.example.com` vs `admin.api.example.com`
   - Header-based: API versioning via Accept header

4. **Cross-Cutting Concerns**
   - JWT validation at gateway
   - Rate limiting per API key
   - CORS configuration
   - Request/response logging
   - Metrics collection

5. **Backend for Frontend (BFF)**
   - Separate gateway per client type (web, mobile, IoT)
   - Client-specific data aggregation
   - Optimized payloads per platform

**Output Format:**
```
## API Gateway Architecture

### Gateway Selection
**Kong** - Rich plugin ecosystem, enterprise features

### Routing Configuration
```yaml
routes:
  - path: /api/v1/users/*
    service: user-service
    strip_path: true

  - path: /api/v1/products/*
    service: product-service

  - path: /api/v1/orders/*
    service: order-service
    plugins:
      - name: jwt
      - name: rate-limiting
        config:
          minute: 100
```

### Cross-Cutting Concerns

**Authentication**
- JWT validation plugin
- Public endpoints: /health, /docs
- Protected: everything else

**Rate Limiting**
- 1000 req/hour per user
- 10000 req/hour per API key (B2B)
- Burst: 100 req/minute

**Caching**
- Cache GET /products for 5min
- Cache product details for 1hour
- Invalidate on PUT/DELETE

**Logging**
- Request/response logging to Elasticsearch
- Correlation ID propagation
- Error tracking to Sentry

### BFF Pattern (Optional)
- web-gateway: Full product details, paginated
- mobile-gateway: Minimal payload, infinite scroll
- admin-gateway: Full access, no rate limits

### Monitoring
- Request count per route
- Response time p95, p99
- Error rate (4xx, 5xx)
- Gateway health check
```

**Quality Checks:**
- [ ] All services behind gateway (no direct access)
- [ ] Authentication at gateway
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Monitoring and logging
- [ ] Gateway is stateless (horizontally scalable)
- [ ] Circuit breaker for failing services

**Example Invocation:**
"use sc-architecture to design API gateway for microservices"

---

### Task 8: Caching Strategy Design

**Triggers:** "caching", "cache design", "performance optimization", "CDN"

**When to Use:**
- Performance optimization
- Reducing database load
- Scaling read-heavy systems
- Global content delivery

**Protocol:**

1. **Identify Cacheable Data**
   - Static content (images, CSS, JS)
   - Infrequently changing (product catalog)
   - User-specific (session, preferences)
   - Computed results (aggregations, reports)

2. **Cache Layers**
   - **Browser cache**: Static assets (long TTL)
   - **CDN**: Global distribution (images, videos)
   - **Application cache**: Redis/Memcached (API responses)
   - **Database cache**: Query result cache

3. **Cache Patterns**
   - **Cache-Aside**: App checks cache, loads from DB on miss
   - **Write-Through**: Write to cache and DB simultaneously
   - **Write-Behind**: Write to cache, async write to DB
   - **Read-Through**: Cache loads from DB on miss

4. **Invalidation Strategy**
   - **TTL (Time-To-Live)**: Expire after duration
   - **Event-based**: Invalidate on data change
   - **Versioned keys**: New version = new key
   - **Cache warming**: Preload cache on deploy

5. **Cache Key Design**
   - Hierarchical: `user:{id}:profile`
   - Include versioning: `product:{id}:v2`
   - Pagination: `products:page:{n}:limit:{m}`

**Output Format:**
```
## Caching Strategy

### Cache Layers

**CDN (CloudFront)**
- Static assets: images, CSS, JS (1 year TTL)
- Product images (1 week TTL, purge on update)

**Application Cache (Redis)**
- Product catalog (5min TTL)
- User sessions (24h TTL, sliding)
- API responses for popular queries (1min TTL)
- Shopping cart (1h TTL)

**Database Query Cache**
- Enabled for read replicas
- Invalidate on write to master

### Caching Patterns

**Product Catalog** (Cache-Aside)
```js
async function getProduct(id) {
  const cacheKey = `product:${id}`;
  let product = await redis.get(cacheKey);

  if (!product) {
    product = await db.query('SELECT * FROM products WHERE id = ?', [id]);
    await redis.set(cacheKey, JSON.stringify(product), 'EX', 300); // 5min
  }

  return JSON.parse(product);
}
```

**Shopping Cart** (Write-Through)
```js
async function updateCart(userId, cart) {
  const cacheKey = `cart:${userId}`;
  await redis.set(cacheKey, JSON.stringify(cart), 'EX', 3600); // 1h
  await db.query('UPDATE carts SET data = ? WHERE user_id = ?', [cart, userId]);
}
```

### Invalidation Strategy
- **TTL-based**: Most caches expire automatically
- **Event-based**: Product update → invalidate `product:{id}`
- **Cache warming**: Popular products preloaded on deploy

### Cache Key Convention
- `product:{id}` - Single product
- `products:category:{cat}:page:{n}` - Product list
- `user:{id}:profile` - User profile
- `cart:{userId}` - Shopping cart

### Monitoring
- Cache hit rate (target >80%)
- Cache eviction rate
- Memory usage
- Latency (cache vs DB)
```

**Quality Checks:**
- [ ] Cache layers identified (CDN, app, DB)
- [ ] Appropriate pattern for each use case
- [ ] TTL configured (not infinite)
- [ ] Invalidation strategy defined
- [ ] Cache keys follow convention
- [ ] Monitoring dashboards
- [ ] Memory limits configured

**Example Invocation:**
"use sc-architecture to design caching strategy for high-traffic API"

---

### Task 9: Infrastructure as Code Design

**Triggers:** "infrastructure", "IaC", "Terraform", "CloudFormation", "deployment"

**When to Use:**
- Provisioning cloud infrastructure
- Multi-environment setup (dev, staging, prod)
- Disaster recovery planning
- Infrastructure versioning

**Protocol:**

1. **Choose IaC Tool**
   - Terraform: Multi-cloud, mature ecosystem
   - CloudFormation: AWS-native, tight integration
   - Pulumi: Code-based (TypeScript, Python, Go)
   - CDK: AWS CloudFormation with code

2. **Infrastructure Components**
   - Compute: EC2, ECS, Lambda, Kubernetes
   - Networking: VPC, subnets, load balancers, API Gateway
   - Storage: S3, EBS, EFS, RDS
   - Security: IAM roles, security groups, secrets
   - Monitoring: CloudWatch, alerts, dashboards

3. **Environment Strategy**
   - Separate workspaces (dev, staging, prod)
   - Shared modules for consistency
   - Environment-specific variables
   - State management (remote backend)

4. **Security Best Practices**
   - Least privilege IAM roles
   - Secrets in Parameter Store / Secrets Manager
   - Network isolation (private subnets)
   - Encryption at rest and in transit

5. **CI/CD Integration**
   - Terraform plan on PR
   - Auto-apply on merge to main
   - State locking for concurrent changes
   - Rollback capability

**Output Format:**
```
## Infrastructure as Code Design

### Tool Selection
**Terraform** - Multi-cloud, declarative, mature

### Directory Structure
```
terraform/
├── modules/
│   ├── vpc/
│   ├── ecs/
│   └── rds/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── staging/
│   └── prod/
└── terraform.tfstate (remote in S3)
```

### Infrastructure Components

**Networking**
- VPC with public + private subnets (3 AZs)
- NAT Gateway for private subnet internet access
- Application Load Balancer

**Compute**
- ECS Fargate for containers
- Auto-scaling (2-10 tasks)
- Task definitions per service

**Database**
- RDS PostgreSQL (Multi-AZ)
- Read replicas for analytics
- Automated backups (7-day retention)

**Caching**
- ElastiCache Redis (cluster mode)

**Storage**
- S3 for static assets (CloudFront CDN)

**Security**
- IAM roles per service (least privilege)
- Secrets Manager for DB credentials
- Security groups (minimal ingress)

### Environment Configuration

**dev**
- t3.small instances
- Single RDS instance
- No auto-scaling

**staging**
- t3.medium instances
- Multi-AZ RDS
- Min 2 tasks

**prod**
- t3.large instances
- Multi-AZ RDS with read replica
- Min 5 tasks, max 20

### Terraform Example
```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  cidr_block  = "10.0.0.0/16"
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name = "app-${var.environment}"
  vpc_id       = module.vpc.id
  subnets      = module.vpc.private_subnets
}

module "rds" {
  source = "../../modules/rds"

  instance_class = var.db_instance_class
  multi_az       = var.environment == "prod"
  vpc_id         = module.vpc.id
}
```

### State Management
- Remote backend: S3 + DynamoDB for locking
- State per environment
- Encrypted at rest

### CI/CD Integration
```yaml
# .github/workflows/terraform.yml
on:
  pull_request:
    - terraform plan
  push:
    branches: [main]
    - terraform apply (auto-approve for dev)
    - terraform apply (manual approve for prod)
```
```

**Quality Checks:**
- [ ] Infrastructure as code (no manual changes)
- [ ] Modules for reusable components
- [ ] Environment separation (dev, staging, prod)
- [ ] Remote state with locking
- [ ] Secrets not in code (use Secrets Manager)
- [ ] IAM least privilege
- [ ] Multi-AZ for production
- [ ] Backup and disaster recovery

**Example Invocation:**
"use sc-architecture to design infrastructure as code for web application"

---

### Task 10: Observability Architecture

**Triggers:** "monitoring", "observability", "logging", "tracing", "metrics"

**When to Use:**
- Production system monitoring
- Debugging distributed systems
- Performance analysis
- SLA/SLO tracking

**Protocol:**

1. **Three Pillars of Observability**
   - **Metrics**: Quantitative measurements (latency, error rate)
   - **Logs**: Event records (structured or unstructured)
   - **Traces**: Request flow across services (distributed tracing)

2. **Metrics Collection**
   - Application metrics (Prometheus, CloudWatch)
   - Infrastructure metrics (CPU, memory, disk)
   - Business metrics (orders/min, revenue)
   - SLIs (Service Level Indicators)

3. **Logging Strategy**
   - Structured logging (JSON format)
   - Log levels (DEBUG, INFO, WARN, ERROR)
   - Centralized aggregation (ELK, CloudWatch Logs)
   - Log retention policy

4. **Distributed Tracing**
   - Trace context propagation (W3C Trace Context)
   - Jaeger, Zipkin, AWS X-Ray
   - Trace sampling for high-volume systems

5. **Alerting**
   - SLO-based alerts (error budget)
   - Actionable alerts (not noise)
   - Escalation policy
   - On-call rotation

**Output Format:**
```
## Observability Architecture

### Metrics (Prometheus + Grafana)

**Application Metrics**
- `http_requests_total` - Request count by endpoint
- `http_request_duration_seconds` - Latency histogram
- `http_requests_errors` - Error count by status code
- `active_users` - Current active sessions

**Infrastructure Metrics**
- CPU utilization per service
- Memory usage
- Network I/O
- Disk usage

**Business Metrics**
- Orders per minute
- Revenue per hour
- Cart abandonment rate

**Dashboards**
- System health (RED: Rate, Errors, Duration)
- Service dependencies
- Database performance
- Business KPIs

### Logging (ELK Stack)

**Log Format** (Structured JSON)
```json
{
  "timestamp": "2025-01-01T10:00:00Z",
  "level": "INFO",
  "service": "order-service",
  "traceId": "abc123",
  "message": "Order created",
  "context": {
    "orderId": "123",
    "userId": "456",
    "total": 99.99
  }
}
```

**Log Aggregation**
- Filebeat → Logstash → Elasticsearch
- Kibana for visualization
- Index per day, 30-day retention

**Log Queries**
- All errors in last hour
- Orders by user
- Slow queries (>1s)

### Distributed Tracing (Jaeger)

**Instrumentation**
- Auto-instrumentation (OpenTelemetry)
- Trace context in headers (traceparent)
- Span per service call

**Trace Example**
```
Order API (100ms total)
  ├─ Auth Service (10ms)
  ├─ Inventory Service (30ms)
  │   └─ Database Query (25ms)
  ├─ Payment Service (50ms)
  │   └─ Payment Gateway (45ms)
  └─ Notification Service (10ms)
```

**Sampling**
- 100% for errors
- 10% for successful requests (high volume)
- 100% for slow requests (>1s)

### Alerting (PagerDuty)

**Critical Alerts** (Page immediately)
- Error rate >5% for 5min
- API latency p95 >1s for 5min
- Database connections >90% for 2min
- Service down

**Warning Alerts** (Slack notification)
- Error rate >2% for 10min
- Disk usage >80%
- Cache hit rate <70%

**SLO Alerts** (Weekly report)
- 99.9% uptime SLO
- 95% of requests <200ms SLO
- Error budget burn rate

### On-Call Rotation
- Primary: 24/7 on-call (1 week rotation)
- Secondary: Escalation after 15min
- Runbooks for common incidents
```

**Quality Checks:**
- [ ] All three pillars implemented (metrics, logs, traces)
- [ ] Structured logging format
- [ ] Distributed tracing across services
- [ ] SLO-based alerting (not threshold-based)
- [ ] Dashboards for system health
- [ ] Retention policies defined
- [ ] On-call runbooks documented
- [ ] Alert fatigue prevented (actionable alerts only)

**Example Invocation:**
"use sc-architecture to design observability for microservices"

---

### Task 11: CI/CD Pipeline Design

**Triggers:** "CI/CD", "deployment pipeline", "continuous integration", "continuous deployment"

**When to Use:**
- Setting up new project deployment
- Modernizing deployment process
- Multi-environment deployment strategy
- Automated testing and quality gates

**Protocol:**

1. **Pipeline Stages**
   - **Build**: Compile, bundle, containerize
   - **Test**: Unit, integration, E2E tests
   - **Security**: SAST, dependency scanning, secrets detection
   - **Deploy**: Dev → Staging → Production
   - **Monitor**: Health checks, smoke tests

2. **Choose CI/CD Platform**
   - GitHub Actions: GitHub-native, easy setup
   - GitLab CI: Built-in, feature-rich
   - Jenkins: Self-hosted, highly customizable
   - AWS CodePipeline: AWS-native
   - CircleCI: Fast, cloud-based

3. **Branching Strategy**
   - **Trunk-based**: Main branch, short-lived feature branches
   - **GitFlow**: Feature → Develop → Release → Main
   - **Environment branches**: dev, staging, main (production)

4. **Deployment Strategies**
   - **Blue-Green**: Switch traffic between two environments
   - **Canary**: Gradual rollout to subset of users
   - **Rolling**: Update instances incrementally
   - **Feature Flags**: Deploy code, enable features gradually

5. **Quality Gates**
   - Test coverage >80%
   - No critical vulnerabilities
   - Performance tests pass
   - Manual approval for production

**Output Format:**
```
## CI/CD Pipeline Design

### Platform
**GitHub Actions** - Native integration, easy setup

### Branching Strategy
- `main` → Production (protected)
- `staging` → Staging environment
- `feature/*` → Feature branches (PR to main)

### Pipeline Stages

**1. Build** (on every push)
```yaml
build:
  - Install dependencies
  - Run linters (ESLint, Prettier)
  - Build application
  - Build Docker image
  - Push to ECR
```

**2. Test** (on every PR)
```yaml
test:
  - Unit tests (Jest)
  - Integration tests (Supertest)
  - E2E tests (Playwright)
  - Test coverage report (>80% required)
```

**3. Security Scan** (on every PR)
```yaml
security:
  - SAST (Snyk Code)
  - Dependency scan (npm audit)
  - Container scan (Trivy)
  - Secrets detection (GitGuardian)
```

**4. Deploy to Staging** (on merge to staging)
```yaml
deploy-staging:
  - Deploy to ECS Staging
  - Run smoke tests
  - Notify team (Slack)
```

**5. Deploy to Production** (on merge to main)
```yaml
deploy-production:
  - Manual approval required
  - Deploy to ECS Production (canary)
  - 10% traffic for 10min
  - Monitor error rate
  - If healthy, ramp to 100%
  - If errors, auto-rollback
```

### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main, staging]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t app:${{ github.sha }} .
      - name: Push to ECR
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin
          docker push app:${{ github.sha }}

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: npm test -- --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  security:
    runs-on: ubuntu-latest
    steps:
      - name: Run Snyk
        run: npx snyk test

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: [build, test, security]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to ECS Staging
        run: aws ecs update-service --service app-staging --force-new-deployment

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [build, test, security]
    environment: production  # Requires approval
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to ECS Production
        run: aws ecs update-service --service app-production --force-new-deployment
```

### Deployment Strategy
- **Staging**: Auto-deploy on merge (rolling deployment)
- **Production**: Manual approval + canary deployment
  - 10% traffic for 10min
  - Monitor error rate, latency
  - Auto-rollback if errors >1%
  - Gradual ramp: 25% → 50% → 100%

### Rollback Strategy
- Keep previous 3 deployments
- One-click rollback in ECS
- Auto-rollback on high error rate
- Manual rollback option

### Monitoring
- Deployment success rate
- Time to deploy (target <10min)
- Rollback frequency
- Quality gate failures
```

**Quality Checks:**
- [ ] Automated testing (unit, integration, E2E)
- [ ] Security scanning (SAST, dependencies, containers)
- [ ] Test coverage >80%
- [ ] Staging environment mirrors production
- [ ] Manual approval for production
- [ ] Automated rollback capability
- [ ] Deployment monitoring
- [ ] Fast feedback (<10min for PR checks)

**Example Invocation:**
"use sc-architecture to design CI/CD pipeline for Node.js application"

---

### Task 12: Data Migration Strategy

**Triggers:** "migration", "database migration", "legacy modernization", "data migration"

**When to Use:**
- Migrating from legacy to new system
- Database platform change (MySQL to PostgreSQL)
- Cloud migration
- Schema refactoring

**Protocol:**

1. **Migration Assessment**
   - Data volume and complexity
   - Acceptable downtime
   - Data transformation requirements
   - Rollback requirements

2. **Migration Strategy**
   - **Big Bang**: All at once (high risk, short downtime)
   - **Phased**: Migrate in stages (low risk, longer timeline)
   - **Parallel Run**: Run both systems (safest, expensive)
   - **Strangler Pattern**: Gradually replace (for applications)

3. **Data Migration Steps**
   - **Extract**: Export data from source
   - **Transform**: Clean, validate, convert schema
   - **Load**: Import to destination
   - **Validate**: Verify data integrity

4. **Minimize Downtime**
   - Read replicas for initial sync
   - Change Data Capture (CDC) for incremental updates
   - Database triggers for dual writes
   - Quick cutover window

5. **Rollback Plan**
   - Keep source system running
   - Reverse replication capability
   - Tested rollback procedure

**Output Format:**
```
## Data Migration Strategy

### Migration Scope
- **Source**: MySQL 5.7 (on-premise)
- **Destination**: AWS RDS PostgreSQL 14
- **Data Volume**: 500GB, 10M records
- **Acceptable Downtime**: <4 hours

### Migration Strategy
**Phased with Minimal Downtime**

### Migration Phases

**Phase 1: Preparation** (Week 1-2)
1. Schema mapping (MySQL → PostgreSQL)
2. Set up AWS RDS PostgreSQL
3. Create migration scripts
4. Set up read replica on MySQL
5. Test migration with subset

**Phase 2: Initial Sync** (Week 3)
1. Full data dump from MySQL replica
2. Transform and load to PostgreSQL
3. Validate data integrity
4. Performance testing on PostgreSQL

**Phase 3: CDC Setup** (Week 4)
1. Set up Change Data Capture (Debezium)
2. Stream changes MySQL → PostgreSQL
3. Monitor replication lag
4. Keep lag <5 minutes

**Phase 4: Cutover** (Scheduled maintenance window)
1. Stop application writes (read-only mode)
2. Wait for CDC to sync final changes (<5min)
3. Validate data consistency
4. Switch application to PostgreSQL
5. Monitor for 1 hour
6. If stable, decommission MySQL

**Total Downtime**: ~30 minutes (read-only + cutover)

### Data Transformation

**Schema Changes**
- `AUTO_INCREMENT` → `SERIAL` (PostgreSQL)
- `DATETIME` → `TIMESTAMP`
- `TINYINT(1)` → `BOOLEAN`

**Data Cleaning**
- Remove orphaned records
- Fix encoding issues (UTF-8)
- Deduplicate users table
- Archive old records (>5 years)

### Validation Checklist
- [ ] Record counts match (±1% for active tables)
- [ ] Sample data comparison (1000 random records)
- [ ] Foreign key integrity
- [ ] Index performance (query benchmarks)
- [ ] Application smoke tests

### Rollback Plan
1. Keep MySQL running for 1 week
2. Reverse CDC (PostgreSQL → MySQL) if needed
3. Switch application back to MySQL
4. Rollback time: <15 minutes

### Migration Script Example
```python
# extract_transform_load.py
import mysql.connector
import psycopg2

# Extract
mysql_conn = mysql.connector.connect(...)
cursor = mysql_conn.cursor()
cursor.execute("SELECT * FROM users")

# Transform
for row in cursor:
    user = {
        'id': row[0],
        'email': row[1].lower(),  # Normalize emails
        'created_at': row[2].isoformat(),  # MySQL DATETIME → ISO
    }

    # Load
    pg_conn = psycopg2.connect(...)
    pg_cursor = pg_conn.cursor()
    pg_cursor.execute(
        "INSERT INTO users (id, email, created_at) VALUES (%s, %s, %s)",
        (user['id'], user['email'], user['created_at'])
    )
```

### Risk Mitigation
- **Risk**: Data loss during migration
  **Mitigation**: CDC + validation, rollback plan
- **Risk**: Extended downtime
  **Mitigation**: Phased migration, CDC for incremental sync
- **Risk**: Application incompatibility
  **Mitigation**: Extensive testing on staging replica
```

**Quality Checks:**
- [ ] Migration plan documented
- [ ] Tested on staging environment
- [ ] Downtime minimized (<4 hours)
- [ ] Rollback plan tested
- [ ] Data validation automated
- [ ] Performance benchmarked
- [ ] Stakeholders informed of timeline
- [ ] Post-migration monitoring plan

**Example Invocation:**
"use sc-architecture to design data migration from MySQL to PostgreSQL"

---

## Multi-Task Workflows

Common combinations of tasks for complex projects:

### Complete System Design
1. **Task 3**: Technology Stack Selection
2. **Task 1**: Microservices Architecture
3. **Task 2**: API Design per service
4. **Task 4**: Database Architecture
5. **Task 10**: Observability Architecture
6. **Task 11**: CI/CD Pipeline

### API-First Project
1. **Task 2**: REST API Architecture
2. **Task 4**: Database Schema
3. **Task 7**: API Gateway Design
4. **Task 8**: Caching Strategy

### Performance Optimization
1. **Task 8**: Caching Strategy Design
2. **Task 4**: Database Optimization
3. **Task 7**: API Gateway (for rate limiting)
4. **Task 10**: Observability (for metrics)

### Cloud Migration
1. **Task 12**: Data Migration Strategy
2. **Task 9**: Infrastructure as Code
3. **Task 11**: CI/CD Pipeline
4. **Task 10**: Observability Setup

---

## Integration Examples

**With confidence-check:**
```
"use confidence-check then sc-architecture to design microservices"
→ First assess feasibility, then design architecture
```

**With sc-agent orchestration:**
```
"use sc-agent to design and implement REST API"
→ sc-agent delegates to sc-architecture (Task 2) + implementation
```

**With deep-research:**
```
"use deep-research to find best practices, then sc-architecture to design caching"
→ Research patterns, then apply to architecture design
```

---

## References

**Books:**
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "Building Microservices" by Sam Newman
- "Domain-Driven Design" by Eric Evans

**Patterns:**
- Microservices Patterns: https://microservices.io/patterns/
- Cloud Design Patterns: https://learn.microsoft.com/azure/architecture/patterns/
- Martin Fowler's Architecture: https://martinfowler.com/architecture/

**Tools:**
- OpenAPI/Swagger: https://swagger.io/
- Terraform: https://www.terraform.io/
- Kubernetes: https://kubernetes.io/

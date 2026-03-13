# Database Standards

> **⚠️ MAINTENANCE:** This file is indexed in `dev-team/skills/shared-patterns/standards-coverage-table.md`.
> When adding/removing `## ` sections, follow FOUR-FILE UPDATE RULE in CLAUDE.md: (1) edit standards file, (2) update TOC, (3) update standards-coverage-table.md, (4) update agent file.

This file defines the specific standards for database engineering across all engines (PostgreSQL as primary reference, with MySQL/MongoDB/Redis patterns where applicable).

> **Reference**: Always consult `docs/PROJECT_RULES.md` for common project standards.

---

## Table of Contents

| # | Section | Description |
|---|---------|-------------|
| 1 | [Schema Design Principles](#schema-design-principles) | Normalization (1NF-BCNF), when to denormalize |
| 2 | [Data Types and Constraints](#data-types-and-constraints) | Type selection, NOT NULL, CHECK, DEFAULT |
| 3 | [Primary Key Strategy](#primary-key-strategy) | UUID vs auto-increment, composite keys |
| 4 | [Foreign Key and Referential Integrity](#foreign-key-and-referential-integrity) | Cascade rules, deferred constraints |
| 5 | [Indexing Strategy](#indexing-strategy) | B-tree, GIN, GiST, partial, covering indexes |
| 6 | [Migration Safety](#migration-safety) | Zero-downtime DDL, backward-compatible changes |
| 7 | [Query Optimization](#query-optimization) | EXPLAIN analysis, scan elimination, joins |
| 8 | [Connection Pooling](#connection-pooling) | PgBouncer/ProxySQL, pool sizing |
| 9 | [Transaction Isolation and Concurrency](#transaction-isolation-and-concurrency) | Isolation levels, advisory locks, deadlocks |
| 10 | [Replication Topology](#replication-topology) | Primary-replica, read replicas, failover |
| 11 | [Sharding and Partitioning](#sharding-and-partitioning) | Range/hash/list partitioning, shard keys |
| 12 | [Performance Tuning](#performance-tuning) | shared_buffers, work_mem, vacuum/analyze |
| 13 | [Database Security](#database-security) | Row-level security, encryption, roles |
| 14 | [Backup and Recovery](#backup-and-recovery) | Logical vs physical, PITR, verification |
| 15 | [Monitoring and Alerting](#monitoring-and-alerting) | pg_stat_statements, slow queries, locks |
| 16 | [MongoDB Patterns](#mongodb-patterns) | Document design, embedding vs referencing |
| 17 | [Redis Patterns](#redis-patterns) | Data structures, key naming, TTL, memory |
| 18 | [Multi-Tenant Data Isolation](#multi-tenant-data-isolation) | Schema-per-tenant, RLS, tenant_id |
| 19 | [Data Migration and ETL](#data-migration-and-etl) | Large table migration, CDC, validation |
| 20 | [Anti-Patterns](#anti-patterns) | SELECT *, missing FK indexes, EAV abuse |

**Meta-sections (not checked by agents):**

- [Checklist](#checklist) - Self-verification before deploying

---

## Schema Design Principles

### Normalization Forms

MUST understand and apply normalization progressively:

| Form | Rule | Example Violation |
|------|------|-------------------|
| **1NF** | Atomic values, no repeating groups | `tags TEXT` storing comma-separated values |
| **2NF** | No partial dependency on composite key | `order_items.product_name` depends only on `product_id`, not full PK |
| **3NF** | No transitive dependency | `orders.customer_city` depends on `customer_id`, not on `order_id` |
| **BCNF** | Every determinant is a candidate key | Rare in practice; resolves edge cases from 3NF |

MUST normalize to **3NF by default**. Denormalization requires explicit justification.

### When to Denormalize

| Condition | Denormalization Approach | Justification Required |
|-----------|--------------------------|------------------------|
| Read-heavy, write-rare data | Materialized views | Refresh strategy documented |
| Reporting/analytics queries | Summary tables | Update trigger or CDC pipeline |
| Single-entity read performance | Computed columns / generated columns | Expression documented |
| Cross-service data | Denormalized cache table | Staleness SLA defined |

```sql
-- GOOD: Materialized view for read-heavy dashboards
CREATE MATERIALIZED VIEW mv_order_summary AS
SELECT
    o.id AS order_id,
    o.created_at,
    c.name AS customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_amount
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.created_at, c.name;

CREATE UNIQUE INDEX idx_mv_order_summary_id ON mv_order_summary (order_id);

-- Refresh on schedule or after bulk writes
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_order_summary;
```

### Naming Conventions (MANDATORY)

- Tables: `snake_case`, plural (`orders`, `order_items`)
- Columns: `snake_case`, singular (`created_at`, `customer_id`)
- Foreign keys: `{referenced_table_singular}_id` (e.g., `customer_id`)
- Indexes: `idx_{table}_{columns}` (e.g., `idx_orders_customer_id`)
- Constraints: `chk_{table}_{description}`, `uq_{table}_{columns}`
- Sequences: `{table}_{column}_seq`

```sql
-- GOOD: Consistent naming
CREATE TABLE order_items (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    BIGINT NOT NULL REFERENCES orders(id),
    product_id  BIGINT NOT NULL REFERENCES products(id),
    quantity    INTEGER NOT NULL,
    unit_price  NUMERIC(12,2) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- BAD: Inconsistent naming
CREATE TABLE OrderItem (
    OrderItemID INT PRIMARY KEY,
    orderid INT,
    Qty INT,
    Price FLOAT
);
```

**Detection:**
```bash
# Find tables not using snake_case (PostgreSQL)
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
AND tablename ~ '[A-Z]';
```

---

## Data Types and Constraints

### Type Selection (MANDATORY)

MUST use the most appropriate type. General-purpose types lead to data corruption and query performance degradation.

| Use Case | MUST Use | MUST NOT Use | Why |
|----------|----------|--------------|-----|
| Timestamps | `TIMESTAMPTZ` | `TIMESTAMP`, `VARCHAR` | Timezone-naive timestamps cause production bugs across regions |
| Money/currency | `NUMERIC(precision, scale)` | `FLOAT`, `DOUBLE PRECISION`, `REAL` | Floating-point arithmetic produces rounding errors |
| Free text | `TEXT` | `VARCHAR(n)` without business reason | `VARCHAR(255)` is an arbitrary limit; `TEXT` has identical performance in PostgreSQL |
| Boolean flags | `BOOLEAN` | `INTEGER`, `CHAR(1)` | Semantic clarity, query optimizer benefits |
| IP addresses | `INET` / `CIDR` | `VARCHAR` | Native operators for range queries and containment checks |
| JSON documents | `JSONB` | `JSON`, `TEXT` | `JSONB` is decomposed binary, supports indexing; `JSON` stores raw text |
| UUIDs | `UUID` | `VARCHAR(36)` | 16 bytes vs 36 bytes, native comparison operators |
| Enumerations | `TEXT` + `CHECK` constraint | `ENUM` type | `ENUM` types cannot be altered in a transaction and cause migration pain |
| Date-only | `DATE` | `TIMESTAMPTZ`, `VARCHAR` | Semantic precision, storage efficiency |
| Intervals | `INTERVAL` | `INTEGER` (storing seconds) | Native arithmetic with timestamps |

### Constraints (MANDATORY)

MUST apply constraints at the database level. Application-level validation is not a substitute.

```sql
-- NOT NULL by default: every column MUST be NOT NULL unless NULL has explicit business meaning
CREATE TABLE products (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku         TEXT NOT NULL,
    name        TEXT NOT NULL,
    description TEXT,                          -- NULL allowed: description is optional
    price       NUMERIC(12,2) NOT NULL,
    status      TEXT NOT NULL DEFAULT 'draft',
    weight_kg   NUMERIC(8,3),                  -- NULL allowed: not all products have weight
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_products_price_positive CHECK (price > 0),
    CONSTRAINT chk_products_status CHECK (status IN ('draft', 'active', 'archived')),
    CONSTRAINT chk_products_weight CHECK (weight_kg IS NULL OR weight_kg > 0),
    CONSTRAINT uq_products_sku UNIQUE (sku)
);
```

**Detection:**
```bash
# Find columns without NOT NULL that probably should have it
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND is_nullable = 'YES'
AND column_name NOT IN ('description', 'deleted_at', 'notes')
ORDER BY table_name, ordinal_position;
```

---

## Primary Key Strategy

### Decision Matrix

| Factor | UUID v7 | Auto-Increment (`BIGINT GENERATED ALWAYS AS IDENTITY`) |
|--------|---------|--------------------------------------------------------|
| Distributed generation | Clients can generate IDs without DB roundtrip | Requires DB sequence |
| Index performance | Time-ordered (v7), B-tree friendly | Naturally sequential, optimal for B-tree |
| Storage size | 16 bytes | 8 bytes |
| URL exposure | Non-guessable | Sequential, predictable (information leak) |
| Replication/sharding | No conflicts across shards | Requires sequence coordination |
| Debugging | Hard to read | Easy to read |
| Recommended for | Public APIs, distributed systems, multi-tenant | Internal tables, high-insert throughput, join-heavy workloads |

### UUID v7 (RECOMMENDED for public-facing entities)

```sql
-- PostgreSQL 17+ has native UUIDv7 support via gen_random_uuid()
-- For older versions, use pgcrypto or application-layer generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ...
);
```

### Auto-Increment (RECOMMENDED for internal/high-throughput tables)

```sql
-- MUST use GENERATED ALWAYS, not GENERATED BY DEFAULT
-- GENERATED BY DEFAULT allows manual inserts that can collide with the sequence
CREATE TABLE audit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    action TEXT NOT NULL,
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Composite Keys

MUST NOT use composite primary keys for application entities. Use a surrogate key with a unique constraint instead.

```sql
-- BAD: Composite primary key
CREATE TABLE enrollments (
    student_id BIGINT REFERENCES students(id),
    course_id BIGINT REFERENCES courses(id),
    PRIMARY KEY (student_id, course_id)
);

-- GOOD: Surrogate key + unique constraint
CREATE TABLE enrollments (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id  BIGINT NOT NULL REFERENCES students(id),
    course_id   BIGINT NOT NULL REFERENCES courses(id),
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_enrollments_student_course UNIQUE (student_id, course_id)
);
```

Exception: join tables with no additional attributes and no need for a surrogate key may use composite PKs.

---

## Foreign Key and Referential Integrity

### Cascade Rules (MANDATORY)

MUST define ON DELETE / ON UPDATE behavior explicitly. The default (`NO ACTION`) causes silent failures.

| Action | Use When | Example |
|--------|----------|---------|
| `RESTRICT` | Parent deletion MUST be prevented | `orders.customer_id` — cannot delete a customer with orders |
| `CASCADE` | Child rows are meaningless without parent | `order_items.order_id` — deleting an order deletes its items |
| `SET NULL` | Child can exist independently | `tasks.assigned_to` — deleting a user unassigns their tasks |
| `SET DEFAULT` | Child should revert to a default | Rare; `articles.category_id` defaults to "uncategorized" |
| `NO ACTION` | Same as RESTRICT but checked at end of transaction | Use only with deferred constraints |

```sql
CREATE TABLE order_items (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(12,2) NOT NULL
);
```

### Deferred Constraints

Use deferred constraints when circular references or bulk inserts require temporary FK violations within a transaction:

```sql
CREATE TABLE departments (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    manager_id  BIGINT CONSTRAINT fk_dept_manager
                REFERENCES employees(id)
                DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE employees (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            TEXT NOT NULL,
    department_id   BIGINT NOT NULL REFERENCES departments(id)
);

-- Both inserts succeed within a single transaction
BEGIN;
INSERT INTO departments (name, manager_id) VALUES ('Engineering', 1);
INSERT INTO employees (name, department_id) VALUES ('Alice', 1);
COMMIT;  -- FK check happens here
```

### FK Index Requirement (MANDATORY)

**HARD GATE: Every foreign key column MUST have a corresponding index.** PostgreSQL does not automatically create indexes on FK columns (unlike MySQL InnoDB). Missing FK indexes cause full table scans on DELETE and JOIN operations.

```sql
-- After creating a foreign key, ALWAYS create an index
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_order_items_product_id ON order_items (product_id);
```

**Detection:**
```sql
-- Find foreign keys without indexes (PostgreSQL)
SELECT
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND NOT EXISTS (
    SELECT 1
    FROM pg_indexes pi
    WHERE pi.tablename = tc.table_name
    AND pi.indexdef LIKE '%' || kcu.column_name || '%'
);
```

---

## Indexing Strategy

### Index Type Selection

| Index Type | Use Case | Example |
|-----------|----------|---------|
| **B-tree** (default) | Equality, range, sorting, LIKE 'prefix%' | `WHERE status = 'active'`, `ORDER BY created_at` |
| **Hash** | Equality only (rarely useful, B-tree is almost always better) | `WHERE id = 123` |
| **GIN** | JSONB containment, full-text search, array operations | `WHERE tags @> '{"urgent"}'` |
| **GiST** | Spatial data (PostGIS), range types, nearest-neighbor | `WHERE location && ST_MakeEnvelope(...)` |
| **BRIN** | Large tables with naturally ordered data (timestamps) | `WHERE created_at BETWEEN ...` on append-only tables |
| **SP-GiST** | Non-balanced data structures (phone numbers, IP ranges) | `WHERE ip_range >>= '192.168.1.0/24'` |

### Partial Indexes (MANDATORY for filtered queries)

MUST use partial indexes when queries consistently filter on a subset of rows:

```sql
-- Only 5% of orders are 'pending', but queries filter on them constantly
CREATE INDEX idx_orders_pending ON orders (created_at)
WHERE status = 'pending';

-- Much smaller than a full index, much faster for the common query
SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at;
```

### Covering Indexes (Index-Only Scans)

Use `INCLUDE` to add non-searchable columns to an index, enabling index-only scans:

```sql
-- Query: SELECT email, name FROM users WHERE email = $1
CREATE INDEX idx_users_email_covering ON users (email) INCLUDE (name);
-- The query is satisfied entirely from the index, no heap access needed
```

### Composite Index Column Ordering

MUST order columns by: **(1) equality conditions first, (2) range/sort conditions last.**

```sql
-- Query: WHERE tenant_id = $1 AND status = $2 AND created_at > $3
-- GOOD: Equality columns first, range column last
CREATE INDEX idx_orders_tenant_status_created
ON orders (tenant_id, status, created_at);

-- BAD: Range column in the middle breaks index usage for status
CREATE INDEX idx_orders_bad
ON orders (tenant_id, created_at, status);
```

### Unused Index Detection

```sql
-- Find indexes with zero scans (candidates for removal)
SELECT
    schemaname || '.' || relname AS table,
    indexrelname AS index,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS size,
    idx_scan AS scans
FROM pg_stat_user_indexes i
JOIN pg_index USING (indexrelid)
WHERE idx_scan = 0
AND NOT indisunique
AND NOT indisprimary
ORDER BY pg_relation_size(i.indexrelid) DESC;
```

### Duplicate Index Detection

```sql
-- Find duplicate or overlapping indexes
SELECT
    a.indexrelid::regclass AS index_a,
    b.indexrelid::regclass AS index_b,
    pg_size_pretty(pg_relation_size(a.indexrelid)) AS size_a
FROM pg_index a
JOIN pg_index b ON a.indrelid = b.indrelid
    AND a.indexrelid <> b.indexrelid
    AND a.indkey::text LIKE b.indkey::text || '%'
WHERE a.indrelid::regclass::text NOT LIKE 'pg_%';
```

---

## Migration Safety

### Zero-Downtime DDL Rules (MANDATORY)

MUST NOT run migrations that acquire `ACCESS EXCLUSIVE` locks on high-traffic tables during peak hours. The following operations acquire this lock:

| Operation | Lock Level | Safe Alternative |
|-----------|-----------|-----------------|
| `ALTER TABLE ADD COLUMN NOT NULL` (no default) | `ACCESS EXCLUSIVE` | Add column nullable, backfill, then set NOT NULL |
| `ALTER TABLE ADD COLUMN DEFAULT` (PG < 11) | `ACCESS EXCLUSIVE` | Use PG 11+ which makes this instant |
| `CREATE INDEX` | `SHARE` (blocks writes) | `CREATE INDEX CONCURRENTLY` |
| `ALTER TABLE ... TYPE` (column type change) | `ACCESS EXCLUSIVE` | Create new column, backfill, rename |
| `DROP COLUMN` | `ACCESS EXCLUSIVE` (brief) | Acceptable, but remove app references first |
| `RENAME TABLE/COLUMN` | `ACCESS EXCLUSIVE` | Use views for transition period |

### Expand-Contract Pattern (MANDATORY for breaking changes)

Phase 1 (Expand): Add new structure alongside old.
Phase 2 (Migrate): Application writes to both, reads from new.
Phase 3 (Contract): Remove old structure after all consumers migrated.

```sql
-- Phase 1: Expand — add new column
ALTER TABLE users ADD COLUMN email_normalized TEXT;

-- Phase 2: Migrate — backfill in batches
UPDATE users SET email_normalized = lower(trim(email))
WHERE email_normalized IS NULL
AND id BETWEEN $start AND $end;  -- batch by PK range

-- Phase 3: Contract — after all app code uses email_normalized
ALTER TABLE users ALTER COLUMN email_normalized SET NOT NULL;
-- Eventually: ALTER TABLE users DROP COLUMN email;
```

### Concurrent Index Creation

```sql
-- MUST use CONCURRENTLY for indexes on production tables
-- This avoids blocking writes during index build
CREATE INDEX CONCURRENTLY idx_orders_customer_id ON orders (customer_id);

-- NOTE: CONCURRENTLY cannot run inside a transaction block
-- NOTE: If interrupted, leaves an INVALID index — check and retry:
SELECT indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE indexrelname LIKE '%customer_id%';

-- Clean up invalid index if needed
DROP INDEX CONCURRENTLY IF EXISTS idx_orders_customer_id;
```

### Rollback Plan (MANDATORY)

Every migration MUST have a documented rollback:

```sql
-- Migration: 20240315_add_order_status.sql
-- UP
ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'pending';
CREATE INDEX CONCURRENTLY idx_orders_status ON orders (status);

-- DOWN (rollback)
DROP INDEX CONCURRENTLY IF EXISTS idx_orders_status;
ALTER TABLE orders DROP COLUMN IF EXISTS status;
```

### Data Backfill Strategy

MUST backfill large tables in batches to avoid long-running transactions and lock escalation:

```sql
-- Backfill in batches of 10,000 rows
DO $$
DECLARE
    batch_size INT := 10000;
    max_id BIGINT;
    current_id BIGINT := 0;
BEGIN
    SELECT MAX(id) INTO max_id FROM orders;
    WHILE current_id < max_id LOOP
        UPDATE orders
        SET status = 'active'
        WHERE status IS NULL
        AND id > current_id
        AND id <= current_id + batch_size;

        current_id := current_id + batch_size;
        COMMIT;
        PERFORM pg_sleep(0.1);  -- brief pause to reduce replication lag
    END LOOP;
END $$;
```

---

## Query Optimization

### EXPLAIN ANALYZE Interpretation (MANDATORY)

MUST run `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)` on every new or modified query before deployment.

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT o.id, c.name, SUM(oi.quantity * oi.unit_price) AS total
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.created_at > '2024-01-01'
GROUP BY o.id, c.name;
```

### Reading EXPLAIN Output

| Node | Indicates | Action |
|------|-----------|--------|
| `Seq Scan` | Full table scan | Add index or fix query predicate |
| `Index Scan` | Single-row or small range lookup | Good — verify selectivity |
| `Index Only Scan` | Answered entirely from index | Optimal — no heap access |
| `Bitmap Index Scan` + `Bitmap Heap Scan` | Multiple index conditions combined | Acceptable for OR conditions |
| `Nested Loop` | Row-by-row join (good for small outer) | Verify inner side uses index |
| `Hash Join` | Hash table on inner, probe from outer | Good for unsorted large joins |
| `Merge Join` | Both sides sorted, merge | Good for pre-sorted data |
| `Sort` | Explicit sort step | Check if an index can eliminate it |
| `actual time=X..Y` | Startup vs total time per node | Focus on nodes with highest `Y` |
| `rows=N (actual=M)` | Estimated vs actual rows | Large discrepancy = stale statistics, run `ANALYZE` |

### Sequential Scan Elimination

```sql
-- BAD: Function on column prevents index usage
SELECT * FROM orders WHERE EXTRACT(YEAR FROM created_at) = 2024;

-- GOOD: Range predicate uses index
SELECT * FROM orders
WHERE created_at >= '2024-01-01'
AND created_at < '2025-01-01';

-- BAD: Implicit cast prevents index usage
SELECT * FROM users WHERE id = '123';  -- id is BIGINT, '123' is TEXT

-- GOOD: Match types explicitly
SELECT * FROM users WHERE id = 123;
```

### CTE Materialization Control (PostgreSQL 12+)

```sql
-- By default, CTEs are optimization fences (materialized)
-- Use NOT MATERIALIZED to allow predicate pushdown
WITH active_users AS NOT MATERIALIZED (
    SELECT id, name FROM users WHERE status = 'active'
)
SELECT * FROM active_users WHERE id = 42;
-- The WHERE id = 42 is pushed into the CTE scan
```

### Pagination Patterns

```sql
-- BAD: Offset-based pagination degrades with page depth
SELECT * FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 10000;
-- Scans and discards 10,000 rows

-- GOOD: Keyset (cursor) pagination
SELECT * FROM orders
WHERE created_at < $last_seen_created_at
ORDER BY created_at DESC
LIMIT 20;
-- Index scan, no rows discarded
```

---

## Connection Pooling

### Pool Sizing Formula (MANDATORY)

```
optimal_connections = (cpu_cores * 2) + effective_spindle_count
```

For SSDs, `effective_spindle_count = 1`. A 4-core server with SSDs should have **~9 connections** to the database, not 100+.

### PgBouncer Configuration (RECOMMENDED for PostgreSQL)

| Parameter | Transaction Mode | Session Mode |
|-----------|-----------------|--------------|
| `pool_mode` | `transaction` | `session` |
| Use case | Stateless queries, most applications | Prepared statements, LISTEN/NOTIFY, temp tables |
| Connection reuse | After each transaction | After session ends |
| Max connections to PG | Low (matches formula) | Higher (1:1 with clients) |
| Prepared statements | MUST NOT use (or use `protocol_native`) | Supported |

```ini
; /etc/pgbouncer/pgbouncer.ini
[databases]
myapp = host=127.0.0.1 port=5432 dbname=myapp

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 9
reserve_pool_size = 3
reserve_pool_timeout = 3
server_idle_timeout = 600
server_lifetime = 3600
log_connections = 1
log_disconnections = 1
```

### ProxySQL Configuration (RECOMMENDED for MySQL)

```ini
mysql_variables=
{
    mysql-max_connections=1000
    mysql-default_query_timeout=30000
    mysql-monitor_username="proxysql_monitor"
    mysql-monitor_password="..."
}
```

### Connection Lifecycle (MANDATORY)

- MUST close connections on application shutdown (graceful shutdown handler)
- MUST configure idle timeout to reclaim leaked connections
- MUST monitor active vs idle connections
- MUST NOT open connections per HTTP request without a pool

**Detection:**
```sql
-- PostgreSQL: Check active connections vs max
SELECT
    count(*) AS active,
    (SELECT setting FROM pg_settings WHERE name = 'max_connections') AS max,
    count(*) FILTER (WHERE state = 'idle') AS idle,
    count(*) FILTER (WHERE state = 'active') AS running
FROM pg_stat_activity
WHERE backend_type = 'client backend';
```

---

## Transaction Isolation and Concurrency

### Isolation Level Selection

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | Use Case |
|-------|-----------|--------------------:|-------------|----------|
| `READ COMMITTED` (default) | No | Possible | Possible | General OLTP, most applications |
| `REPEATABLE READ` | No | No | Possible (PG: No) | Financial calculations, balance checks |
| `SERIALIZABLE` | No | No | No | Critical invariants, audit, compliance |

```sql
-- Set per-transaction (RECOMMENDED over global setting)
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM accounts WHERE id = $1;
UPDATE accounts SET balance = balance - $amount WHERE id = $1;
COMMIT;
```

### Advisory Locks (Application-Level Locking)

Use advisory locks for application-level mutual exclusion without locking table rows:

```sql
-- Session-level advisory lock (released at session end)
SELECT pg_advisory_lock(hashtext('process-payments'));
-- ... exclusive work ...
SELECT pg_advisory_unlock(hashtext('process-payments'));

-- Transaction-level advisory lock (released at COMMIT/ROLLBACK)
SELECT pg_advisory_xact_lock(hashtext('generate-report-' || $tenant_id::text));
-- ... exclusive work within transaction ...
COMMIT;  -- lock released

-- Non-blocking (try lock)
SELECT pg_try_advisory_lock(hashtext('singleton-job'));
-- Returns true if acquired, false if already held
```

### Deadlock Prevention (MANDATORY)

MUST acquire locks in a consistent, deterministic order across all transactions:

```sql
-- BAD: Transaction A locks row 1 then 2; Transaction B locks row 2 then 1
-- Deadlock!

-- GOOD: Always lock in ascending PK order
BEGIN;
SELECT * FROM accounts WHERE id IN (1, 2) ORDER BY id FOR UPDATE;
-- Both transactions lock row 1 first, row 2 second — no deadlock
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

### Optimistic vs Pessimistic Locking

| Approach | When to Use | Implementation |
|----------|-------------|----------------|
| **Optimistic** | Low contention, read-heavy | `version` column + WHERE clause check |
| **Pessimistic** | High contention, critical consistency | `SELECT ... FOR UPDATE` |

```sql
-- Optimistic locking with version column
UPDATE products
SET price = $new_price, version = version + 1
WHERE id = $id AND version = $expected_version;
-- If 0 rows affected → concurrent modification → retry or fail

-- Pessimistic locking
BEGIN;
SELECT * FROM products WHERE id = $id FOR UPDATE;
-- Row is locked until COMMIT — other transactions wait
UPDATE products SET price = $new_price WHERE id = $id;
COMMIT;
```

---

## Replication Topology

### Streaming Replication (PostgreSQL)

| Component | Primary | Replica |
|-----------|---------|---------|
| `wal_level` | `replica` or `logical` | N/A |
| `max_wal_senders` | >= number of replicas + 2 | N/A |
| `hot_standby` | N/A | `on` |
| `primary_conninfo` | N/A | Connection string to primary |

```ini
# postgresql.conf (primary)
wal_level = replica
max_wal_senders = 5
wal_keep_size = 1GB
synchronous_commit = on             # for sync replicas
synchronous_standby_names = 'ANY 1 (replica1, replica2)'
```

### Logical Replication

Use logical replication when you need:
- Selective table replication (not full database)
- Cross-version replication
- Data aggregation from multiple sources

```sql
-- On publisher (primary)
CREATE PUBLICATION my_pub FOR TABLE orders, customers;

-- On subscriber (replica)
CREATE SUBSCRIPTION my_sub
CONNECTION 'host=primary port=5432 dbname=myapp'
PUBLICATION my_pub;
```

### Read Replica Routing (MANDATORY)

MUST route read queries to replicas and write queries to primary. Application code MUST be aware of replication lag.

| Query Type | Route To | Acceptable Lag |
|-----------|----------|----------------|
| Writes (INSERT/UPDATE/DELETE) | Primary | N/A |
| Strong reads (after write) | Primary | 0 |
| Eventual reads (list, search) | Replica | < 5 seconds |
| Analytics/reporting | Dedicated replica | < 60 seconds |

### Replication Lag Monitoring

```sql
-- On replica: check lag
SELECT
    now() - pg_last_xact_replay_timestamp() AS replication_lag,
    pg_is_in_recovery() AS is_replica;

-- On primary: check replication status
SELECT
    client_addr,
    state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

### Failover Procedures

MUST document and test failover procedures:

1. Detect primary failure (monitoring alert)
2. Promote replica: `pg_ctl promote` or `SELECT pg_promote();`
3. Update connection strings (DNS or proxy)
4. Verify no data loss (compare LSN positions)
5. Rebuild old primary as new replica

---

## Sharding and Partitioning

### Table Partitioning (PostgreSQL 10+)

MUST use native declarative partitioning for tables exceeding 10 million rows or 10 GB.

| Strategy | Use Case | Example |
|----------|----------|---------|
| **Range** | Time-series, logs, events | Partition by `created_at` monthly |
| **Hash** | Even distribution, tenant isolation | Partition by `tenant_id` hash |
| **List** | Categorical data, region-based | Partition by `country_code` |

```sql
-- Range partitioning (time-series)
CREATE TABLE events (
    id          BIGINT GENERATED ALWAYS AS IDENTITY,
    event_type  TEXT NOT NULL,
    payload     JSONB NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE events_2024_01 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE events_2024_02 PARTITION OF events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Hash partitioning (tenant isolation)
CREATE TABLE tenant_data (
    id          BIGINT GENERATED ALWAYS AS IDENTITY,
    tenant_id   BIGINT NOT NULL,
    data        JSONB NOT NULL
) PARTITION BY HASH (tenant_id);

CREATE TABLE tenant_data_0 PARTITION OF tenant_data
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE tenant_data_1 PARTITION OF tenant_data
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE tenant_data_2 PARTITION OF tenant_data
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE tenant_data_3 PARTITION OF tenant_data
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

### Partition Pruning

MUST verify partition pruning is active. Queries without the partition key scan all partitions:

```sql
-- GOOD: Partition key in WHERE clause — pruning enabled
EXPLAIN SELECT * FROM events
WHERE created_at >= '2024-03-01' AND created_at < '2024-04-01';
-- Shows scan only on events_2024_03

-- BAD: No partition key — scans all partitions
EXPLAIN SELECT * FROM events WHERE event_type = 'login';
-- Shows scans on ALL partitions
```

### Shard Key Selection (for distributed databases)

| Criterion | Good Shard Key | Bad Shard Key |
|-----------|---------------|---------------|
| Cardinality | High (tenant_id with many tenants) | Low (status with 3 values) |
| Distribution | Even across shards | Skewed (95% in one shard) |
| Query locality | Most queries include shard key | Frequent cross-shard queries |
| Mutability | Immutable after creation | Frequently updated |
| Example | `tenant_id`, `user_id` | `created_at`, `status`, `country` |

### Cross-Shard Query Strategy

When cross-shard queries are unavoidable:

1. **Scatter-gather**: Query all shards, merge results (acceptable for analytics)
2. **Global tables**: Replicate small lookup tables to all shards
3. **Secondary index shard**: Maintain a separate index for non-shard-key lookups

---

## Performance Tuning

### Key PostgreSQL Parameters

| Parameter | Default | Recommended | Description |
|-----------|---------|-------------|-------------|
| `shared_buffers` | 128MB | 25% of RAM | PostgreSQL's buffer cache |
| `effective_cache_size` | 4GB | 75% of RAM | Planner's estimate of OS cache |
| `work_mem` | 4MB | 64-256MB (depends on `max_connections`) | Per-operation memory for sorts/hashes |
| `maintenance_work_mem` | 64MB | 1-2GB | Memory for VACUUM, CREATE INDEX |
| `max_worker_processes` | 8 | CPU cores | Background workers |
| `max_parallel_workers_per_gather` | 2 | CPU cores / 2 | Parallel query workers |
| `random_page_cost` | 4.0 | 1.1 (SSD) / 4.0 (HDD) | Planner cost for random I/O |
| `effective_io_concurrency` | 1 | 200 (SSD) / 2 (HDD) | Concurrent I/O operations |
| `wal_buffers` | -1 (auto) | 64MB | WAL write buffer |
| `checkpoint_completion_target` | 0.9 | 0.9 | Spread checkpoint writes |

```ini
# postgresql.conf — 32GB RAM, 8 cores, SSD
shared_buffers = 8GB
effective_cache_size = 24GB
work_mem = 128MB
maintenance_work_mem = 2GB
max_worker_processes = 8
max_parallel_workers_per_gather = 4
random_page_cost = 1.1
effective_io_concurrency = 200
wal_buffers = 64MB
checkpoint_completion_target = 0.9
```

### Autovacuum Tuning (MANDATORY)

MUST NOT disable autovacuum. Tune thresholds for high-write tables:

```ini
# Global settings (postgresql.conf)
autovacuum_max_workers = 4
autovacuum_naptime = 30s
autovacuum_vacuum_cost_delay = 2ms

# Per-table override for high-write tables
ALTER TABLE events SET (
    autovacuum_vacuum_threshold = 1000,
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_threshold = 500,
    autovacuum_analyze_scale_factor = 0.005
);
```

### MySQL Equivalent Parameters

| PostgreSQL | MySQL (InnoDB) | Notes |
|-----------|---------------|-------|
| `shared_buffers` | `innodb_buffer_pool_size` | 70-80% of RAM for dedicated MySQL |
| `work_mem` | `sort_buffer_size`, `join_buffer_size` | Per-session in MySQL |
| `effective_cache_size` | N/A | MySQL relies on buffer pool |
| `max_connections` | `max_connections` | MySQL default is 151 |
| `autovacuum` | N/A (InnoDB purge thread) | MySQL handles this differently |

**Detection:**
```sql
-- PostgreSQL: Check current settings vs recommendations
SELECT name, setting, unit,
    CASE
        WHEN name = 'shared_buffers' AND setting::bigint < 1000000 THEN 'LOW'
        WHEN name = 'work_mem' AND setting::bigint < 65536 THEN 'LOW'
        ELSE 'OK'
    END AS assessment
FROM pg_settings
WHERE name IN ('shared_buffers', 'effective_cache_size', 'work_mem',
               'maintenance_work_mem', 'random_page_cost');
```

---

## Database Security

### Row-Level Security (RLS) (MANDATORY for multi-tenant)

```sql
-- Enable RLS on table
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Policy: users can only see their own tenant's data
CREATE POLICY tenant_isolation ON orders
    USING (tenant_id = current_setting('app.current_tenant_id')::BIGINT);

-- Force RLS even for table owners (prevents bypass)
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

-- Set tenant context per request (application sets this)
SET app.current_tenant_id = '42';
SELECT * FROM orders;  -- only returns tenant 42's orders
```

### Least-Privilege Role Design (MANDATORY)

MUST NOT use the superuser role for application connections. Design roles hierarchically:

```sql
-- 1. Read-only role
CREATE ROLE app_readonly;
GRANT USAGE ON SCHEMA public TO app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_readonly;

-- 2. Read-write role (inherits read)
CREATE ROLE app_readwrite;
GRANT app_readonly TO app_readwrite;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_readwrite;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT INSERT, UPDATE, DELETE ON TABLES TO app_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO app_readwrite;

-- 3. Migration role (DDL permissions)
CREATE ROLE app_migration;
GRANT app_readwrite TO app_migration;
GRANT CREATE ON SCHEMA public TO app_migration;

-- 4. Application login user
CREATE ROLE myapp_user LOGIN PASSWORD '...' IN ROLE app_readwrite;

-- 5. Migration login user
CREATE ROLE myapp_migrator LOGIN PASSWORD '...' IN ROLE app_migration;
```

### Column-Level Encryption

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt sensitive data
INSERT INTO users (name, ssn_encrypted)
VALUES ('Alice', pgp_sym_encrypt('123-45-6789', $encryption_key));

-- Decrypt when needed
SELECT name, pgp_sym_decrypt(ssn_encrypted, $encryption_key) AS ssn
FROM users WHERE id = $1;
```

### SSL/TLS Enforcement (MANDATORY for production)

```ini
# postgresql.conf
ssl = on
ssl_cert_file = '/etc/ssl/certs/server.crt'
ssl_key_file = '/etc/ssl/private/server.key'
ssl_ca_file = '/etc/ssl/certs/ca.crt'

# pg_hba.conf — require SSL for all remote connections
hostssl all all 0.0.0.0/0 scram-sha-256
```

### Audit Logging

```sql
-- Using pgAudit extension
CREATE EXTENSION pgaudit;
-- postgresql.conf
-- pgaudit.log = 'write, ddl'
-- pgaudit.log_catalog = off

-- Or custom audit trigger
CREATE TABLE audit_log (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name  TEXT NOT NULL,
    operation   TEXT NOT NULL,
    row_id      TEXT NOT NULL,
    old_data    JSONB,
    new_data    JSONB,
    changed_by  TEXT NOT NULL DEFAULT current_user,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, operation, row_id, old_data, new_data)
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(NEW.id::text, OLD.id::text),
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) END
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

---

## Backup and Recovery

### Backup Strategy Decision Matrix

| Method | Type | Point-in-Time | Speed | Size | Use Case |
|--------|------|--------------|-------|------|----------|
| `pg_dump` | Logical | No | Slow (large DBs) | Compressed | Schema + data export, cross-version migration |
| `pg_dumpall` | Logical | No | Slow | Compressed | Full cluster including roles/tablespaces |
| `pg_basebackup` | Physical | Yes (with WAL) | Fast | Full size | Production PITR, replica setup |
| WAL archiving | Continuous | Yes | Continuous | Incremental | Combined with pg_basebackup for PITR |
| `pgBackRest` | Physical | Yes | Fast, parallel | Incremental/diff | Enterprise backup solution (RECOMMENDED) |

### PITR Setup (MANDATORY for production)

```ini
# postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'pgbackrest --stanza=mydb archive-push %p'
# OR: archive_command = 'cp %p /backup/wal_archive/%f'
```

```bash
# Take base backup
pgbackrest --stanza=mydb --type=full backup

# Restore to specific point in time
pgbackrest --stanza=mydb --type=time \
    --target="2024-03-15 14:30:00+00" \
    --target-action=promote \
    restore
```

### Backup Verification (MANDATORY)

MUST test restore regularly. An untested backup is not a backup.

```bash
# Weekly restore test (automated)
#!/bin/bash
set -euo pipefail

RESTORE_DIR="/tmp/restore_test_$(date +%Y%m%d)"

# 1. Restore to temporary directory
pgbackrest --stanza=mydb --type=immediate \
    --target-action=promote \
    --pg1-path="$RESTORE_DIR" restore

# 2. Start temporary instance
pg_ctl -D "$RESTORE_DIR" -o "-p 5433" start

# 3. Run validation queries
psql -p 5433 -c "SELECT count(*) FROM orders;" | grep -q "[0-9]"
psql -p 5433 -c "SELECT count(*) FROM customers;" | grep -q "[0-9]"

# 4. Cleanup
pg_ctl -D "$RESTORE_DIR" stop
rm -rf "$RESTORE_DIR"

echo "Backup verification: PASSED"
```

### Retention Policy

| Environment | Full Backup | Incremental | WAL Retention | PITR Window |
|-------------|-------------|-------------|---------------|-------------|
| Production | Weekly | Daily | 14 days | 14 days |
| Staging | Weekly | None | 3 days | 3 days |
| Development | Manual | None | None | None |

---

## Monitoring and Alerting

### pg_stat_statements Setup (MANDATORY)

```sql
-- Enable in postgresql.conf
-- shared_preload_libraries = 'pg_stat_statements'
-- pg_stat_statements.track = all

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top 10 queries by total time
SELECT
    calls,
    round(total_exec_time::numeric, 2) AS total_ms,
    round(mean_exec_time::numeric, 2) AS mean_ms,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS pct,
    left(query, 100) AS query_preview
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

### Slow Query Identification

```sql
-- Currently running queries (over 5 seconds)
SELECT
    pid,
    now() - pg_stat_activity.query_start AS duration,
    state,
    left(query, 200) AS query
FROM pg_stat_activity
WHERE state != 'idle'
AND now() - pg_stat_activity.query_start > interval '5 seconds'
ORDER BY duration DESC;

-- Kill a long-running query (use with caution)
SELECT pg_cancel_backend($pid);    -- graceful: cancels current query
SELECT pg_terminate_backend($pid); -- forceful: terminates connection
```

### Lock Monitoring

```sql
-- Blocked queries and what's blocking them
SELECT
    blocked.pid AS blocked_pid,
    blocked.query AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking.query AS blocking_query,
    now() - blocked.query_start AS blocked_duration
FROM pg_stat_activity blocked
JOIN pg_locks bl ON bl.pid = blocked.pid
JOIN pg_locks kl ON kl.locktype = bl.locktype
    AND kl.database IS NOT DISTINCT FROM bl.database
    AND kl.relation IS NOT DISTINCT FROM bl.relation
    AND kl.page IS NOT DISTINCT FROM bl.page
    AND kl.tuple IS NOT DISTINCT FROM bl.tuple
    AND kl.transactionid IS NOT DISTINCT FROM bl.transactionid
    AND kl.classid IS NOT DISTINCT FROM bl.classid
    AND kl.objid IS NOT DISTINCT FROM bl.objid
    AND kl.objsubid IS NOT DISTINCT FROM bl.objsubid
    AND kl.pid != bl.pid
JOIN pg_stat_activity blocking ON blocking.pid = kl.pid
WHERE NOT bl.granted;
```

### Table Bloat Detection

```sql
-- Estimate table bloat (simplified)
SELECT
    schemaname || '.' || relname AS table,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    n_dead_tup AS dead_tuples,
    n_live_tup AS live_tuples,
    CASE WHEN n_live_tup > 0
        THEN round(100.0 * n_dead_tup / n_live_tup, 1)
        ELSE 0
    END AS dead_pct,
    last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000
ORDER BY n_dead_tup DESC;
```

### Alert Thresholds (RECOMMENDED)

| Metric | Warning | Critical | Query/Check |
|--------|---------|----------|-------------|
| Replication lag | > 5s | > 30s | `pg_last_xact_replay_timestamp()` |
| Active connections | > 80% of `max_connections` | > 95% | `pg_stat_activity` count |
| Long-running queries | > 30s | > 300s | `pg_stat_activity.query_start` |
| Lock waits | > 10s | > 60s | `pg_locks` + `pg_stat_activity` |
| Dead tuples ratio | > 20% | > 50% | `pg_stat_user_tables.n_dead_tup` |
| Disk usage | > 80% | > 90% | `pg_database_size()` |
| Cache hit ratio | < 99% | < 95% | `pg_stat_database.blks_hit / (blks_hit + blks_read)` |
| Transaction ID wraparound | < 50M remaining | < 10M remaining | `age(datfrozenxid)` |

---

## MongoDB Patterns

### Document Design Principles

| Principle | Guideline |
|-----------|-----------|
| Schema is defined by the application | MUST use schema validation in MongoDB 3.6+ |
| Favor embedding for read-together data | If data is always read together, embed it |
| Favor referencing for independent entities | If data is updated independently, reference it |
| Avoid unbounded arrays | Arrays that grow indefinitely degrade performance |
| Denormalize for read performance | Accept write overhead if reads dominate |

### Embedding vs Referencing Decision Matrix

| Factor | Embed | Reference |
|--------|-------|-----------|
| Read pattern | Data always read together | Data read independently |
| Write pattern | Child updated with parent | Child updated independently |
| Array growth | Bounded (< 100 items) | Unbounded or large |
| Data size | Subdocument < 16KB | Subdocument > 16KB |
| Relationship | 1:1 or 1:few | 1:many or many:many |
| Consistency | Atomic update needed | Eventual consistency acceptable |

```javascript
// GOOD: Embed — address is always read with user, 1:few
{
    _id: ObjectId("..."),
    name: "Alice",
    addresses: [
        { type: "home", street: "123 Main St", city: "Portland" },
        { type: "work", street: "456 Corp Ave", city: "Portland" }
    ]
}

// GOOD: Reference — orders are independent, unbounded
{
    _id: ObjectId("..."),
    name: "Alice"
}
// Separate collection
{
    _id: ObjectId("..."),
    user_id: ObjectId("..."),  // reference
    items: [...],
    total: 99.99
}
```

### Schema Validation (MANDATORY)

```javascript
db.createCollection("products", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name", "price", "status"],
            properties: {
                name: {
                    bsonType: "string",
                    description: "MUST be a string"
                },
                price: {
                    bsonType: "decimal",
                    minimum: 0,
                    description: "MUST be a non-negative decimal"
                },
                status: {
                    enum: ["draft", "active", "archived"],
                    description: "MUST be a valid status"
                }
            }
        }
    },
    validationLevel: "strict",
    validationAction: "error"
});
```

### MongoDB Index Strategies

| Index Type | Use Case | Example |
|-----------|----------|---------|
| Single field | Equality, sort | `db.orders.createIndex({ status: 1 })` |
| Compound | Multi-field queries | `db.orders.createIndex({ tenant_id: 1, created_at: -1 })` |
| TTL | Auto-expiring documents | `db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 3600 })` |
| Text | Full-text search | `db.articles.createIndex({ title: "text", body: "text" })` |
| Partial | Filtered subset | `db.orders.createIndex({ status: 1 }, { partialFilterExpression: { status: "pending" } })` |
| Wildcard | Dynamic/unknown fields | `db.logs.createIndex({ "metadata.$**": 1 })` |

---

## Redis Patterns

### Data Structure Selection

| Structure | Use Case | Example |
|-----------|----------|---------|
| **String** | Simple key-value, counters, cached JSON | Session token, feature flag |
| **Hash** | Object with fields | User profile: `HSET user:42 name "Alice" email "a@b.com"` |
| **List** | Ordered queue, recent items | Activity feed: `LPUSH feed:42 "{event}"` |
| **Set** | Unique collections, membership | Tags: `SADD tags:article:1 "redis" "database"` |
| **Sorted Set** | Leaderboards, priority queues | `ZADD leaderboard 1500 "user:42"` |
| **Stream** | Event sourcing, message queue | `XADD events * type "order_created" order_id "123"` |
| **HyperLogLog** | Cardinality estimation | Unique visitors: `PFADD visitors:2024-03-15 "user:42"` |

### Key Naming Convention (MANDATORY)

Format: `{service}:{entity}:{id}:{attribute}`

```
# GOOD: Structured, scannable, predictable
myapp:user:42:profile
myapp:user:42:sessions
myapp:order:1001:status
myapp:cache:products:page:1
myapp:lock:payment:order:1001
myapp:rate:api:user:42

# BAD: Unstructured, inconsistent
user_42_profile
UserProfile:42
cache-products-1
```

### TTL Management (MANDATORY)

MUST set TTL on all cache keys. Keys without TTL accumulate and cause OOM.

```bash
# Set with TTL
SET myapp:cache:product:42 "{...}" EX 3600  # 1 hour

# Set TTL on existing key
EXPIRE myapp:session:abc123 1800             # 30 minutes

# Check remaining TTL
TTL myapp:cache:product:42                   # Returns seconds remaining
```

### Memory Policy (MANDATORY for production)

```ini
# redis.conf
maxmemory 4gb
maxmemory-policy allkeys-lru    # Evict least recently used keys when memory is full

# Alternative policies:
# volatile-lru    — Evict keys with TTL set (LRU)
# allkeys-lfu     — Evict least frequently used (Redis 4.0+)
# volatile-ttl    — Evict keys with shortest TTL
# noeviction      — Return error on write when full (use for queues)
```

| Policy | Use Case |
|--------|----------|
| `allkeys-lru` | General cache (RECOMMENDED default) |
| `volatile-lru` | Mix of cache (with TTL) and persistent data (without TTL) |
| `allkeys-lfu` | Hotspot-heavy workloads |
| `noeviction` | Message queues, streams (data loss is unacceptable) |

### Persistence Configuration

| Method | Durability | Performance | Use Case |
|--------|-----------|-------------|----------|
| **RDB** (snapshots) | Point-in-time | High (fork + write) | Backup, disaster recovery |
| **AOF** (append-only) | Per-second or per-write | Lower (fsync overhead) | Data durability required |
| **RDB + AOF** | Best of both | Balanced | Production (RECOMMENDED) |
| **None** | No durability | Maximum | Pure cache, ephemeral data |

```ini
# redis.conf — production recommended
save 900 1        # RDB: snapshot if 1+ write in 900s
save 300 10       # RDB: snapshot if 10+ writes in 300s
appendonly yes
appendfsync everysec  # AOF: fsync every second (balance of durability + perf)
```

---

## Multi-Tenant Data Isolation

### Isolation Strategy Selection

| Strategy | Isolation Level | Complexity | Cost | Use Case |
|----------|----------------|-----------|------|----------|
| **Separate databases** | Highest | High (ops overhead) | High | Regulated industries, large tenants |
| **Schema-per-tenant** | High | Medium | Medium | Mid-size tenants, moderate count |
| **Shared schema + RLS** | Medium | Low | Low | Many small tenants, SaaS (RECOMMENDED) |
| **tenant_id column** (no RLS) | Low (app-enforced) | Lowest | Lowest | Internal tools, trusted code only |

### Shared Schema with RLS (RECOMMENDED)

```sql
-- 1. Every multi-tenant table MUST have tenant_id
CREATE TABLE orders (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id   BIGINT NOT NULL REFERENCES tenants(id),
    customer_id BIGINT NOT NULL,
    total       NUMERIC(12,2) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Index on tenant_id MUST be first column in composite indexes
CREATE INDEX idx_orders_tenant_created ON orders (tenant_id, created_at);

-- 3. Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

-- 4. Create isolation policy
CREATE POLICY tenant_policy ON orders
    USING (tenant_id = current_setting('app.current_tenant_id')::BIGINT)
    WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::BIGINT);

-- 5. Application sets tenant context per request
SET LOCAL app.current_tenant_id = '42';
```

### Cross-Tenant Query Prevention (MANDATORY)

MUST have safeguards against cross-tenant data leaks:

```sql
-- 1. Application middleware MUST set tenant context before any query
-- 2. RLS policy MUST be FORCE'd (applies even to table owner)
-- 3. Direct SQL access MUST use a role that does not bypass RLS

-- Verify RLS is enforced
SELECT
    relname AS table_name,
    relrowsecurity AS rls_enabled,
    relforcerowsecurity AS rls_forced
FROM pg_class
WHERE relnamespace = 'public'::regnamespace
AND relkind = 'r'
AND relname IN ('orders', 'customers', 'invoices');

-- MUST show both rls_enabled = true AND rls_forced = true
```

### Tenant Provisioning

```sql
-- For schema-per-tenant approach
CREATE OR REPLACE FUNCTION provision_tenant(p_tenant_name TEXT)
RETURNS void AS $$
DECLARE
    schema_name TEXT := 'tenant_' || p_tenant_name;
BEGIN
    EXECUTE format('CREATE SCHEMA %I', schema_name);
    EXECUTE format('SET search_path TO %I', schema_name);

    -- Create tables in tenant schema
    CREATE TABLE orders (LIKE public.orders_template INCLUDING ALL);
    CREATE TABLE customers (LIKE public.customers_template INCLUDING ALL);

    -- Grant access
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO app_readwrite', schema_name);
    EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO app_readwrite', schema_name);
END;
$$ LANGUAGE plpgsql;
```

---

## Data Migration and ETL

### Large Table Migration Strategies

| Tool | Engine | Approach | Downtime |
|------|--------|----------|----------|
| `pt-online-schema-change` | MySQL | Shadow table + triggers | Zero |
| `gh-ost` | MySQL | Binlog-based shadow table | Zero |
| `pg_repack` | PostgreSQL | Rewrite table without locks | Near-zero |
| Native `ALTER TABLE` | PostgreSQL 11+ | Instant for add column with default | Zero |
| Custom backfill script | Any | Batch UPDATE by PK range | Zero |

### pg_repack (PostgreSQL)

```bash
# Reclaim bloated table space without ACCESS EXCLUSIVE lock
pg_repack --table=orders --jobs=4 --no-superuser-check -d mydb

# Repack specific index
pg_repack --index=idx_orders_created_at -d mydb
```

### Change Data Capture (CDC) with Debezium

```json
{
    "name": "myapp-connector",
    "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "database.hostname": "primary-db",
        "database.port": "5432",
        "database.user": "debezium",
        "database.password": "...",
        "database.dbname": "myapp",
        "topic.prefix": "myapp",
        "table.include.list": "public.orders,public.customers",
        "plugin.name": "pgoutput",
        "slot.name": "debezium_slot",
        "publication.name": "debezium_pub",
        "snapshot.mode": "initial"
    }
}
```

### Batch Processing Pattern

```sql
-- Migrate data in batches with progress tracking
CREATE TABLE migration_progress (
    migration_name TEXT PRIMARY KEY,
    last_processed_id BIGINT NOT NULL DEFAULT 0,
    total_processed BIGINT NOT NULL DEFAULT 0,
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ
);

-- Batch migration function
CREATE OR REPLACE FUNCTION migrate_orders_batch(batch_size INT DEFAULT 10000)
RETURNS TABLE(processed INT, remaining BIGINT) AS $$
DECLARE
    v_last_id BIGINT;
    v_count INT;
BEGIN
    SELECT last_processed_id INTO v_last_id
    FROM migration_progress
    WHERE migration_name = 'orders_v2';

    IF v_last_id IS NULL THEN
        INSERT INTO migration_progress (migration_name)
        VALUES ('orders_v2');
        v_last_id := 0;
    END IF;

    WITH batch AS (
        SELECT id, customer_id, total, created_at
        FROM orders
        WHERE id > v_last_id
        ORDER BY id
        LIMIT batch_size
    ),
    inserted AS (
        INSERT INTO orders_v2 (id, customer_id, total_amount, created_at)
        SELECT id, customer_id, total, created_at
        FROM batch
        ON CONFLICT (id) DO NOTHING
        RETURNING id
    )
    SELECT count(*)::INT INTO v_count FROM inserted;

    UPDATE migration_progress
    SET last_processed_id = v_last_id + batch_size,
        total_processed = total_processed + v_count
    WHERE migration_name = 'orders_v2';

    RETURN QUERY
    SELECT v_count, (SELECT count(*) FROM orders WHERE id > v_last_id + batch_size);
END;
$$ LANGUAGE plpgsql;
```

### Validation Checksums (MANDATORY)

MUST verify data integrity after migration:

```sql
-- Row count comparison
SELECT
    (SELECT count(*) FROM orders) AS source_count,
    (SELECT count(*) FROM orders_v2) AS target_count,
    (SELECT count(*) FROM orders) - (SELECT count(*) FROM orders_v2) AS diff;

-- Checksum comparison (hash of key columns)
SELECT md5(string_agg(
    id::text || customer_id::text || total::text,
    ',' ORDER BY id
)) AS checksum
FROM orders;

-- Compare with target
SELECT md5(string_agg(
    id::text || customer_id::text || total_amount::text,
    ',' ORDER BY id
)) AS checksum
FROM orders_v2;
```

---

## Anti-Patterns

### SELECT * Without Column List

```sql
-- BAD: Fetches all columns, breaks when schema changes, prevents index-only scans
SELECT * FROM orders WHERE customer_id = 42;

-- GOOD: Explicit column list
SELECT id, customer_id, total, status, created_at
FROM orders
WHERE customer_id = 42;
```

**Why it matters:**
- Fetches unused columns, wasting I/O and memory
- Adding a column to the table silently changes query results
- Prevents covering index optimization (index-only scans)
- Increases network transfer between DB and application

### Missing Foreign Key Indexes

```sql
-- BAD: FK without index — causes sequential scan on DELETE of parent
ALTER TABLE order_items ADD CONSTRAINT fk_order
    FOREIGN KEY (order_id) REFERENCES orders(id);
-- No index on order_items.order_id — DELETE FROM orders WHERE id = 1 scans ALL order_items

-- GOOD: Always create index with FK
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
```

### EAV (Entity-Attribute-Value) Abuse

```sql
-- BAD: EAV pattern — untyped, unindexable, unjoinable
CREATE TABLE entity_attributes (
    entity_id   BIGINT,
    attribute   TEXT,     -- 'color', 'size', 'weight'
    value       TEXT      -- everything is a string
);

-- GOOD: Use JSONB for truly dynamic attributes
CREATE TABLE products (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    attributes  JSONB NOT NULL DEFAULT '{}'
);
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);

-- GOOD: Use separate columns for known attributes
CREATE TABLE products (
    id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name    TEXT NOT NULL,
    color   TEXT,
    size    TEXT,
    weight  NUMERIC(8,3)
);
```

### Over-Normalization

```sql
-- BAD: Separate table for country codes that never change
CREATE TABLE countries (id SERIAL PRIMARY KEY, code CHAR(2), name TEXT);
CREATE TABLE addresses (country_id INT REFERENCES countries(id), ...);
-- Extra join for every address query, for a static lookup

-- GOOD: Use ISO code directly or a CHECK constraint
CREATE TABLE addresses (
    country_code CHAR(2) NOT NULL CHECK (country_code ~ '^[A-Z]{2}$'),
    ...
);
```

### Implicit Type Casting

```sql
-- BAD: String compared to integer — index not used, implicit cast
SELECT * FROM users WHERE id = '42';

-- GOOD: Match types explicitly
SELECT * FROM users WHERE id = 42;

-- BAD: Timestamp vs date comparison with implicit cast
SELECT * FROM events WHERE created_at = '2024-03-15';
-- Compares timestamptz to date, may miss timezone edge cases

-- GOOD: Explicit range
SELECT * FROM events
WHERE created_at >= '2024-03-15 00:00:00+00'
AND created_at < '2024-03-16 00:00:00+00';
```

### Storing JSON When Relational is Better

```sql
-- BAD: Relational data stuffed into JSON
CREATE TABLE orders (
    id      BIGINT PRIMARY KEY,
    data    JSONB  -- contains customer_name, items[], total, status...
);
-- Cannot enforce FK, CHECK constraints, or efficient indexes on nested fields

-- GOOD: Relational for structured, known schema
CREATE TABLE orders (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    total       NUMERIC(12,2) NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('pending', 'shipped', 'delivered'))
);
-- Use JSONB only for truly dynamic/schemaless data (e.g., external API payloads, user preferences)
```

### Unbounded Queries

```sql
-- BAD: No LIMIT — returns millions of rows
SELECT * FROM events ORDER BY created_at DESC;

-- GOOD: Always paginate
SELECT id, event_type, created_at
FROM events
ORDER BY created_at DESC
LIMIT 50;

-- BAD: COUNT(*) on large table without filter
SELECT count(*) FROM events;  -- scans entire table

-- GOOD: Use approximate count for UI
SELECT reltuples::BIGINT AS approximate_count
FROM pg_class
WHERE relname = 'events';
```

### N+1 Query Pattern

```sql
-- BAD: Application loops, executing one query per order
-- Python: for order in orders: db.query("SELECT * FROM items WHERE order_id = %s", order.id)

-- GOOD: Single query with JOIN or IN
SELECT oi.*
FROM order_items oi
WHERE oi.order_id = ANY($order_ids);  -- pass array of IDs

-- Or JOIN in the original query
SELECT o.id, o.total, oi.product_id, oi.quantity
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.customer_id = $1;
```

---

## Checklist

Before deploying database changes:

- [ ] All new tables have appropriate primary keys
- [ ] All foreign keys have corresponding indexes
- [ ] Migration tested for zero-downtime compatibility
- [ ] EXPLAIN ANALYZE run on new/modified queries
- [ ] Connection pooling configured appropriately
- [ ] Backup strategy verified for new tables
- [ ] RLS policies applied if multi-tenant
- [ ] Monitoring alerts configured for new components

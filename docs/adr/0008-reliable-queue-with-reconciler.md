# 8. Reliable jobs with a plain Redis list + reconciler

**Decision:** keep a simple Redis list (`RPUSH`/`BLPOP`). Make it reliable with three rules: the database is the source of truth, jobs are idempotent (`UPDATE … WHERE status='pending'`), and a reconciler re-queues orders that stay pending while the queue is empty.
**Why:** covers lost jobs (Redis down at enqueue, worker killed mid-job) without a heavier broker or an outbox table. Every failure mode has a test.
**Trade-off:** a lost job waits up to ~90 s (stale threshold + reconcile interval). For exactly-once at high volume you'd use the outbox pattern or a broker with acks (SQS, RabbitMQ, Redis Streams consumer groups).

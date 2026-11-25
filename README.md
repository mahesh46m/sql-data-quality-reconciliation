# SQL Data Quality & Reconciliation Demo

A small, self-contained portfolio project by **Mahesh M** showing how I approach data-quality monitoring and ledger-to-bank reconciliation in SQL.

> **Demo project.** All data is synthetic and randomly generated. It is not based on any employer's data, systems or results, and the numbers here are not production metrics.

## What it does

Builds a toy loan-servicing database (loans, a payments ledger, and a bank statement), deliberately injects known data problems, then runs a suite of nine SQL checks that find them. Because the problems are injected with a fixed seed, you can verify that every check catches what it should.

| Table | Purpose |
|---|---|
| `loans` | 200 synthetic loans |
| `payments` | Payments as recorded by the servicing ledger (~1,000 rows) |
| `bank_transactions` | Cash as it appears on the bank statement (~1,000 rows) |

## Run it

Requires Python 3.8+ only (uses the built-in `sqlite3` module, no installs).

```bash
python scripts/run_checks.py
```

This rebuilds `dq_demo.db`, runs every file in `sql/checks/`, prints a row count per check and writes `sample_output.md`. The SQL is plain ANSI-style and ports easily to Postgres or SQL Server (`GROUP_CONCAT` becomes `STRING_AGG`).

## The checks

| # | File | What it finds | Injected | Flagged |
|---|---|---|---|---|
| 01 | `01_duplicate_payments.sql` | Same loan, date and amount posted more than once | 6 | 6 |
| 02 | `02_payments_missing_from_bank.sql` | Ledger payment with no bank deposit (reconciliation break) | 8 (+6 from the duplicates, whose originals' references never reached the bank) | 14 |
| 03 | `03_bank_missing_from_payments.sql` | Bank deposit with no ledger record (unapplied cash) | 5 | 5 |
| 04 | `04_amount_mismatches.sql` | Matched reference, different amount | 7 (+2 from check 06's bad amounts) | 9 |
| 05 | `05_orphan_payments.sql` | Payments pointing at a loan that does not exist | 5 | 5 |
| 06 | `06_invalid_values.sql` | NULL / zero / negative amounts, future-dated rows | 3 + 2 | 5 |
| 07 | `07_large_payment_alert.sql` | Payment over 1M or over 5% of loan principal (threshold alert) | 1 | 1 |
| 08 | `08_volume_spike_alert.sql` | Day with more than 3x the average daily payment count | 1 day | 1 |
| 09 | `09_reconciliation_summary.sql` | Daily ledger vs bank control totals that differ by more than 5,000 | n/a | 10 |

Notes on a few design choices:

- **No foreign key on `payments.loan_id`.** Real feeds often arrive without enforced constraints, which is exactly when an orphan check matters.
- **Check 09 is noisy by design.** The generator posts some bank deposits one day after the ledger date, so daily totals drift. That mirrors real settlement timing. A production version would net out timing differences or reconcile on a rolling window.
- **Thresholds are hard-coded** (1,000,000 / 5% / 3x) to keep the SQL readable. In practice they would live in a config table.

Full sample output for every check is in [`sample_output.md`](sample_output.md).

## Example

```text
CHECK 01: possible duplicate payments
| loan_id | payment_date | amount  | copies | payment_ids |
| 183     | 2026-01-03   | 9921.9  | 2      | 29,951      |
```

## Layout

```
sql/schema.sql            table definitions
sql/checks/*.sql          one file per check
scripts/generate_seed.py  deterministic synthetic data + injected issues
scripts/run_checks.py     builds the DB, runs all checks, writes sample_output.md
```

## Possible extensions

Config-driven thresholds, severity levels and an alerts table, a dbt-style test layer, and a dashboard on top of the check results.

---
Author: Mahesh M. Released under the MIT License.

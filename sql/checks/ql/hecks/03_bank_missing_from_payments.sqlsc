-- CHECK 03: reconciliation break - bank deposit with no payment record (unapplied cash)
SELECT b.bank_txn_id, b.reference, b.posted_date, b.amount
FROM bank_transactions b
LEFT JOIN payments p ON p.reference = b.reference
WHERE p.payment_id IS NULL
ORDER BY b.posted_date;

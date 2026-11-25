-- CHECK 02: reconciliation break - payment recorded, no matching bank deposit
SELECT p.payment_id, p.loan_id, p.payment_date, p.amount, p.reference
FROM payments p
LEFT JOIN bank_transactions b ON b.reference = p.reference
WHERE b.bank_txn_id IS NULL
ORDER BY p.payment_date, p.payment_id;

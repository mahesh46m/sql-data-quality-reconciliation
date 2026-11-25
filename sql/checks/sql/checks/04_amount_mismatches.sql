-- CHECK 04: reconciliation break - matched on reference but amounts differ (> 1 cent)
SELECT p.payment_id, p.reference, p.amount AS ledger_amt, b.amount AS bank_amt,
       ROUND(b.amount - p.amount, 2) AS difference
FROM payments p
JOIN bank_transactions b ON b.reference = p.reference
WHERE p.amount IS NOT NULL
  AND ABS(b.amount - p.amount) > 0.01
ORDER BY ABS(b.amount - p.amount) DESC;

-- CHECK 07: threshold alert - single payment above 5% of the loan's principal
-- or above an absolute limit of 1,000,000
SELECT p.payment_id, p.loan_id, p.payment_date, p.amount, l.principal_amt,
       ROUND(100.0 * p.amount / l.principal_amt, 1) AS pct_of_principal
FROM payments p
JOIN loans l ON l.loan_id = p.loan_id
WHERE p.amount > 1000000
   OR p.amount > 0.05 * l.principal_amt
ORDER BY p.amount DESC;

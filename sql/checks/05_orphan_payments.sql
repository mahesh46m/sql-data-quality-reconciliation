-- CHECK 05: orphan records - payments pointing at a loan that does not exist
SELECT p.payment_id, p.loan_id, p.payment_date, p.amount
FROM payments p
LEFT JOIN loans l ON l.loan_id = p.loan_id
WHERE l.loan_id IS NULL
ORDER BY p.payment_id;

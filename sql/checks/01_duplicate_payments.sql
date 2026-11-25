-- CHECK 01: possible duplicate payments
-- Same loan, date and amount posted more than once under different payment_ids.
SELECT loan_id, payment_date, amount,
       COUNT(*)                    AS copies,
       GROUP_CONCAT(payment_id)    AS payment_ids
FROM payments
WHERE amount > 0
GROUP BY loan_id, payment_date, amount
HAVING COUNT(*) > 1
ORDER BY payment_date, loan_id;

-- CHECK 06: invalid values - NULL / non-positive amounts and future-dated payments
-- ('2026-03-31' is the as-of date of the synthetic data set)
SELECT payment_id, loan_id, payment_date, amount,
       CASE WHEN amount IS NULL THEN 'NULL amount'
            WHEN amount <= 0    THEN 'non-positive amount'
            ELSE 'future-dated' END AS issue
FROM payments
WHERE amount IS NULL OR amount <= 0 OR payment_date > '2026-03-31'
ORDER BY payment_id;

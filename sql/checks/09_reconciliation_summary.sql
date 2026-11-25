-- CHECK 09: daily control total - ledger vs bank, top 10 days that do not tie out (>5,000)
WITH l AS (SELECT payment_date AS d, SUM(amount) AS amt FROM payments
           WHERE payment_date <= '2026-03-31' GROUP BY payment_date),
     k AS (SELECT posted_date AS d, SUM(amount) AS amt FROM bank_transactions GROUP BY posted_date)
SELECT l.d AS date, ROUND(l.amt,2) AS ledger_total, ROUND(COALESCE(k.amt,0),2) AS bank_total,
       ROUND(COALESCE(k.amt,0) - l.amt, 2) AS variance
FROM l LEFT JOIN k ON k.d = l.d
WHERE ABS(COALESCE(k.amt,0) - l.amt) > 5000
ORDER BY ABS(COALESCE(k.amt,0) - l.amt) DESC
LIMIT 10;

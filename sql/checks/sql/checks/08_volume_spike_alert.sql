-- CHECK 08: threshold alert - days whose payment count exceeds 3x the average daily count
-- (portable SQL: no window functions needed)
WITH daily AS (
    SELECT payment_date, COUNT(*) AS n
    FROM payments
    WHERE payment_date <= '2026-03-31'
    GROUP BY payment_date
),
baseline AS (SELECT AVG(n) AS avg_n FROM daily)
SELECT d.payment_date, d.n AS payments, ROUND(b.avg_n, 1) AS avg_daily,
       ROUND(d.n / b.avg_n, 1) AS ratio
FROM daily d CROSS JOIN baseline b
WHERE d.n > 3 * b.avg_n
ORDER BY d.n DESC;

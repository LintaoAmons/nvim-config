WITH active_users AS (
    SELECT user_id, user_name, email
    FROM users
    WHERE is_active = 1
      AND created_at >= '2024-01-01'
),
user_orders AS (
    SELECT u.user_id, u.user_name, o.order_id, o.amount, o.order_date
    FROM active_users u
    JOIN orders o ON o.user_id = u.user_id
    WHERE o.status = 'completed'
),
monthly_totals AS (
    SELECT user_id, user_name,
           DATE_TRUNC('month', order_date) AS month,
           COUNT(*) AS order_count,
           SUM(amount) AS total_amount
    FROM user_orders
    GROUP BY user_id, user_name, DATE_TRUNC('month', order_date)
)
SELECT user_name, month, order_count, total_amount,
       RANK() OVER (PARTITION BY month ORDER BY total_amount DESC) AS rank
FROM monthly_totals
WHERE total_amount > 100
ORDER BY month, rank;

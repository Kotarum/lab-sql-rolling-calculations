use sakila;

-- 1. Get number of monthly active customers.
SELECT MONTH(rental_date) AS month, COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY MONTH(rental_date)
ORDER BY MONTH(rental_date);

-- 2. Active users in the previous month.
SELECT (
    SELECT COUNT(DISTINCT customer_id)
    FROM rental
    WHERE MONTH(rental_date) = MONTH(CURRENT_DATE) - 1
) AS active_users_previous_month;
-- I dont know this one

-- 3. Percentage change in the number of active customers
SELECT
    month,
    active_customers,
    (active_customers - (SELECT active_customers FROM (
        SELECT
            MONTH(rental_date) AS month,
            COUNT(DISTINCT customer_id) AS active_customers
        FROM rental
        GROUP BY MONTH(rental_date)
    ) AS prev_month WHERE prev_month.month = curr_month.month - 1)) / 
    (SELECT active_customers FROM (
        SELECT
            MONTH(rental_date) AS month,
            COUNT(DISTINCT customer_id) AS active_customers
        FROM rental
        GROUP BY MONTH(rental_date)
    ) AS prev_month WHERE prev_month.month = curr_month.month - 1) * 100 AS percentage_change
FROM (
    SELECT
        MONTH(rental_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY MONTH(rental_date)
) AS curr_month;

-- 4. Retained customers every month.
SELECT
    curr_month.month AS month,
    COUNT(DISTINCT curr_month.customer_id) AS retained_customers
FROM
    (
        SELECT
            MONTH(r1.rental_date) AS month,
            r1.customer_id
        FROM
            rental r1
        WHERE
            EXISTS (
                SELECT
                     1
                FROM
                     rental r2
                WHERE
                    r2.customer_id = r1.customer_id
                    AND MONTH(r2.rental_date) = MONTH(r1.rental_date) - 1
            )
    ) AS curr_month
GROUP BY
    curr_month.month
ORDER BY
    curr_month.month;
CREATE DATABASE clinic_db;
USE clinic_db;
CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);
CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(15)
);
CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount INT,
    datetime DATETIME,
    sales_channel VARCHAR(50),
    FOREIGN KEY (uid) REFERENCES customer(uid),
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);
CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50),
    description VARCHAR(200),
    amount INT,
    datetime DATETIME,
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

INSERT INTO clinics VALUES
('c1','ABC Clinic','Hyderabad','Telangana','India'),
('c2','XYZ Clinic','Vijayawada','AP','India');


INSERT INTO customer VALUES
('u1','Ravi','9999999999'),
('u2','Sita','8888888888');


INSERT INTO clinic_sales VALUES
('o1','u1','c1',2000,'2021-09-10 10:00:00','online'),
('o2','u2','c1',3000,'2021-09-15 12:00:00','offline'),
('o3','u1','c2',1500,'2021-09-20 09:00:00','online');


INSERT INTO expenses VALUES
('e1','c1','medicine',500,'2021-09-11 08:00:00'),
('e2','c2','rent',700,'2021-09-12 08:00:00');
SELECT * FROM clinics;
-- SALES CHANNEL
SELECT sales_channel,
       SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

-- TOP 10
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- month wise revenue, expense, profit , status
SELECT m,
       SUM(revenue) AS total_revenue,
       SUM(expense) AS total_expense,
       SUM(revenue - expense) AS profit,
       CASE 
           WHEN SUM(revenue - expense) > 0 THEN 'PROFITABLE'
           ELSE 'NOT PROFITABLE'
       END AS status
FROM (
    SELECT DATE_FORMAT(datetime,'%Y-%m') m, amount AS revenue, 0 AS expense
    FROM clinic_sales
    WHERE YEAR(datetime)=2021
    
    UNION ALL
    
    SELECT DATE_FORMAT(datetime,'%Y-%m'), 0, amount
    FROM expenses
    WHERE YEAR(datetime)=2021
) t
GROUP BY m;
-- each city find the most profitable clinic for a given month
SELECT city, cid, profit
FROM (
    SELECT c.city,
           c.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit,
           RANK() OVER (PARTITION BY c.city 
                        ORDER BY SUM(cs.amount) - COALESCE(SUM(e.amount),0) DESC) AS rnk
    FROM clinics c
    LEFT JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e ON c.cid = e.cid
    GROUP BY c.city, c.cid
) x
WHERE rnk = 1;
-- each state find the second least profitable clinic for a given month
SELECT state, cid, profit
FROM (
    SELECT c.state,
           c.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit,
           DENSE_RANK() OVER (
               PARTITION BY c.state 
               ORDER BY SUM(cs.amount) - COALESCE(SUM(e.amount),0)
           ) AS rnk
    FROM clinics c
    LEFT JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e ON c.cid = e.cid
    GROUP BY c.state, c.cid
) x
WHERE rnk = 2;
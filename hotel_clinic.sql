CREATE DATABASE hotel_clinic_db;
USE hotel_clinic_db;
CREATE TABLE users (
    user_id VARCHAR(50),
    name VARCHAR(100),
    phone_number VARCHAR(15),
    mail_id VARCHAR(100),
    billing_address TEXT
);
CREATE TABLE bookings (
    booking_id VARCHAR(50),
    booking_date DATETIME,
    room_no VARCHAR(50),
    user_id VARCHAR(50)
);
CREATE TABLE items (
    item_id VARCHAR(50),
    item_name VARCHAR(100),
    item_rate INT
);
CREATE TABLE booking_commercials (
    id VARCHAR(50),
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity FLOAT
);
INSERT INTO items VALUES
('itm1','Paratha',20),
('itm2','Rice',50);

INSERT INTO users VALUES
('u1','John','9999999999','john@mail.com','Address1');

INSERT INTO bookings VALUES
('b1','2021-11-10 10:00:00','r1','u1');

INSERT INTO booking_commercials VALUES
('c1','b1','bill1','2021-11-10 12:00:00','itm1',2),
('c2','b1','bill1','2021-11-10 12:00:00','itm2',1);
SELECT user_id, room_no
FROM bookings b
WHERE booking_date = (
    SELECT MAX(booking_date)
    FROM bookings
    WHERE user_id = b.user_id
);
SELECT booking_id,
SUM(item_quantity * item_rate) AS total
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bill_date BETWEEN '2021-11-01' AND '2021-11-30'
GROUP BY booking_id;
SELECT bill_id,
SUM(item_quantity * item_rate) AS total
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bill_date BETWEEN '2021-10-01' AND '2021-10-31'
GROUP BY bill_id
HAVING total > 1000;
WITH data AS (
SELECT DATE_FORMAT(bill_date,'%Y-%m') m,
item_id,
SUM(item_quantity) qty,
RANK() OVER(PARTITION BY DATE_FORMAT(bill_date,'%Y-%m') ORDER BY SUM(item_quantity) DESC) r1,
RANK() OVER(PARTITION BY DATE_FORMAT(bill_date,'%Y-%m') ORDER BY SUM(item_quantity)) r2
FROM booking_commercials
WHERE YEAR(bill_date)=2021
GROUP BY m,item_id
)
SELECT * FROM data WHERE r1=1 OR r2=1;
WITH data AS (
SELECT DATE_FORMAT(bill_date,'%Y-%m') m,
b.user_id,
SUM(item_quantity * item_rate) amt,
DENSE_RANK() OVER(PARTITION BY DATE_FORMAT(bill_date,'%Y-%m') ORDER BY SUM(item_quantity * item_rate) DESC) r
FROM booking_commercials bc
JOIN bookings b ON bc.booking_id=b.booking_id
JOIN items i ON bc.item_id=i.item_id
GROUP BY m,b.user_id
)
SELECT * FROM data WHERE r=2;
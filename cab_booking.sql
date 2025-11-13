use ola_cab_booking;
show tables;
describe bengaluru_ola_booking_data;
select *
from bengaluru_ola_booking_data;


-- ==========================================================
-- CUSTOMER & BOOKING ANALYSIS
-- ==========================================================

-- 1. Customers who completed the most bookings
SELECT Customer_ID, COUNT(*) AS total_completed
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
GROUP BY Customer_ID
ORDER BY total_completed DESC
LIMIT 10;

-- 2. Customers with >30% cancellations
SELECT Customer_ID,
       SUM(CASE WHEN Booking_Status LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS canceled,
       COUNT(*) AS total,
       ROUND((SUM(CASE WHEN Booking_Status LIKE 'Cancelled%' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS cancel_rate
FROM bengaluru_ola_booking_data
GROUP BY Customer_ID
HAVING cancel_rate > 30;


-- 3. Busiest day of the week for bookings
SELECT DAYNAME(ride_date) AS day, COUNT(*) AS total_bookings
FROM bengaluru_ola_booking_data
GROUP BY day
ORDER BY total_bookings DESC;

-- ==========================================================
-- DRIVER PERFORMANCE & EFFICIENCY
-- (adapted since no Driver_ID column)
-- ==========================================================

-- 4. Customers experiencing avg driver ratings < 4.0 in past 3 months
SELECT Customer_ID, round(AVG(Driver_Ratings),1) AS avg_rating
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
AND Ride_Date >= DATE_SUB((SELECT MAX(ride_date) FROM bengaluru_ola_booking_data), INTERVAL 3 MONTH)
GROUP BY Customer_ID
HAVING avg_rating < 4.0;




-- 5. Top 5 longest trips by distance
SELECT Customer_ID, MAX(Ride_Distance) AS longest_trip
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
GROUP BY Customer_ID
ORDER BY longest_trip DESC
LIMIT 5;

-- 6. Customers with high % of cancelled trips (>30%)
SELECT Customer_ID,
       SUM(CASE WHEN Booking_Status LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS canceled,
       COUNT(*) AS total,
       ROUND((SUM(CASE WHEN Booking_Status LIKE 'Cancelled%' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS cancel_rate
FROM bengaluru_ola_booking_data
GROUP BY Customer_ID
HAVING cancel_rate > 30;

-- ==========================================================
-- REVENUE & BUSINESS METRICS
-- ==========================================================

-- 7. Total revenue in last 6 months
SELECT round(SUM(Booking_Value),2) AS total_revenue
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
  AND Ride_Date >= DATE_SUB((SELECT MAX(ride_date) FROM bengaluru_ola_booking_data), INTERVAL 6 MONTH);

-- Revenue trend month by month (last 6 months)
SELECT DATE_FORMAT(Ride_Date, '%Y-%m') AS month,
       SUM(Booking_Value) AS revenue
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
  AND Ride_Date >= DATE_SUB((SELECT MAX(ride_date) FROM bengaluru_ola_booking_data), INTERVAL 6 MONTH)
GROUP BY month
ORDER BY month;

-- 8. Top 3 most frequent pickup-drop routes
SELECT Pickup_Location, Drop_Location, COUNT(*) AS trips
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
GROUP BY Pickup_Location, Drop_Location
ORDER BY trips DESC
LIMIT 3;

-- 9. Correlation between ratings & earnings
SELECT Customer_ID,
       AVG(Driver_Ratings) AS avg_rating,
       SUM(Booking_Value) AS total_earnings,
       COUNT(*) AS trips
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
GROUP BY Customer_ID
ORDER BY avg_rating DESC;

-- ==========================================================
-- OPERATIONAL EFFICIENCY & OPTIMIZATION
-- ==========================================================

-- 10. Avg waiting time by pickup location
SELECT Pickup_Location,
       AVG(Avg_VTAT) AS avg_vehicle_wait,
       AVG(Avg_CTAT) AS avg_customer_wait
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
GROUP BY Pickup_Location
ORDER BY avg_vehicle_wait DESC;

-- 11. Most common customer cancellation reasons
SELECT Reason_for_Cancelling_by_Customer, COUNT(*) AS cnt
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Cancelled by Customer'
GROUP BY Reason_for_Cancelling_by_Customer
ORDER BY cnt DESC;

-- 12. Revenue contribution of short (<5km) vs long trips
SELECT CASE WHEN Ride_Distance < 5 THEN 'Short Trip' ELSE 'Long Trip' END AS trip_type,
       SUM(Booking_Value) AS total_revenue
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
GROUP BY trip_type;

-- ==========================================================
-- COMPARATIVE & PREDICTIVE ANALYSIS
-- ==========================================================

-- 13. Revenue by vehicle type (Sedan vs SUV)
SELECT Vehicle_Type, round(SUM(Booking_Value),2) AS total_revenue
FROM bengaluru_ola_booking_data
WHERE Booking_Status = 'Success'
  AND Vehicle_Type IN ('Prime Sedan','Prime SUV')
GROUP BY Vehicle_Type;

-- 14. Customers inactive in last 3 months
SELECT Customer_ID,MAX(Ride_Date) AS last_booking,
DATEDIFF((SELECT MAX(Ride_Date) FROM bengaluru_ola_booking_data),MAX(Ride_Date)) AS days_inactive
FROM bengaluru_ola_booking_data
GROUP BY Customer_ID
ORDER BY days_inactive DESC
limit 100;


-- 15. Weekend vs weekday bookings
SELECT CASE 
           WHEN DAYOFWEEK(Ride_Date) IN (1,7) THEN 'Weekend'
           ELSE 'Weekday'
       END AS day_type,
       COUNT(*) AS total_bookings
FROM bengaluru_ola_booking_data
GROUP BY day_type;

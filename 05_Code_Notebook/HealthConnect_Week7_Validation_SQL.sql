-- HealthConnect Week 7: PostgreSQL validation queries

-- 1. Appointment key coverage
SELECT COUNT(*) AS appointment_rows, COUNT(DISTINCT "AppointmentID") AS distinct_ids
FROM raw.appointments;

-- 2. Billing references without appointment master
SELECT COUNT(*) AS unmatched_billing_rows
FROM raw.billing b LEFT JOIN raw.appointments a
  ON b."AppointmentID" = a."AppointmentID"
WHERE a."AppointmentID" IS NULL;

-- 3. Feedback references without appointment master
SELECT COUNT(*) AS unmatched_feedback_rows
FROM raw.patient_feedback f LEFT JOIN raw.appointments a
  ON f."AppointmentID" = a."AppointmentID"
WHERE a."AppointmentID" IS NULL;

-- 4. Facility-department consistency
SELECT COUNT(*) AS inconsistent_appointments
FROM raw.appointments a
JOIN raw.departments d ON a."DepartmentID" = d."DepartmentID"
WHERE a."FacilityID" <> d."FacilityID";

-- 5. Billing vs payment reconciliation
SELECT b."BillingID", b."Amount", p."AmountPaid",
       b."Amount" - p."AmountPaid" AS difference, b."Status"
FROM raw.billing b
LEFT JOIN raw.payments p ON b."BillingID" = p."BillingID"
WHERE p."PaymentID" IS NULL OR b."Amount" <> p."AmountPaid";

-- 6. Bed status profile
SELECT "Status", COUNT(*) AS bed_count
FROM raw.beds GROUP BY "Status" ORDER BY bed_count DESC;

-- 7. Appointment volume by month
SELECT DATE_TRUNC('month', "Date"::date) AS month, COUNT(*) AS appointment_rows
FROM raw.appointments GROUP BY 1 ORDER BY 1;

-- 8. Numeric feedback rating distribution
SELECT "Rating", COUNT(*) AS feedback_count, AVG("Rating") OVER() AS overall_mean
FROM raw.patient_feedback GROUP BY "Rating" ORDER BY "Rating";

-- TP2 HOSPITAL MANAGEMENT SYSTEM -

-- 1. DB init
DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;

-- 2. TABLE CREATION

-- Table storing different medical specialties and their base consultation fees
CREATE TABLE specialties (
    specialty_id INT PRIMARY KEY AUTO_INCREMENT,
    specialty_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    consultation_fee DECIMAL(10, 2) NOT NULL
);

-- Table storing doctor profiles, linked to their respective specialties
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    specialty_id INT NOT NULL,
    license_number VARCHAR(20) UNIQUE NOT NULL,
    hire_date DATE,
    office VARCHAR(100),
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table storing comprehensive patient demographics and medical history
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    file_number VARCHAR(20) UNIQUE NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    blood_type VARCHAR(5),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(50),
    province VARCHAR(50),
    registration_date DATE DEFAULT (CURRENT_DATE),
    insurance VARCHAR(100),
    insurance_number VARCHAR(50),
    allergies TEXT,
    medical_history TEXT
);

-- Table logging all medical appointments and their clinical outcomes
CREATE TABLE consultations (
    consultation_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    consultation_date DATETIME NOT NULL,
    reason TEXT NOT NULL,
    diagnosis TEXT,
    observations TEXT,
    blood_pressure VARCHAR(20),
    temperature DECIMAL(4, 2),
    weight DECIMAL(5, 2),
    height DECIMAL(5, 2),
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    amount DECIMAL(10, 2),
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table acting as the hospital's pharmacy inventory
CREATE TABLE medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    medication_code VARCHAR(20) UNIQUE NOT NULL,
    commercial_name VARCHAR(150) NOT NULL,
    generic_name VARCHAR(150),
    form VARCHAR(50),
    dosage VARCHAR(50),
    manufacturer VARCHAR(100),
    unit_price DECIMAL(10, 2) NOT NULL,
    available_stock INT DEFAULT 0,
    minimum_stock INT DEFAULT 10,
    expiration_date DATE,
    prescription_required BOOLEAN DEFAULT TRUE,
    reimbursable BOOLEAN DEFAULT FALSE
);

-- Table for general prescription headers linked to a specific consultation
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    consultation_id INT NOT NULL,
    prescription_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    treatment_duration INT,
    general_instructions TEXT,
    FOREIGN KEY (consultation_id) REFERENCES consultations(consultation_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table for the specific medications prescribed within a general prescription
CREATE TABLE prescription_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    dosage_instructions VARCHAR(200) NOT NULL,
    duration INT NOT NULL,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(medication_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Indexes
CREATE INDEX idx_patients_name ON patients(last_name, first_name);
CREATE INDEX idx_consultations_date ON consultations(consultation_date);
CREATE INDEX idx_consultations_patient ON consultations(patient_id);
CREATE INDEX idx_consultations_doctor ON consultations(doctor_id);
CREATE INDEX idx_medications_name ON medications(commercial_name);
CREATE INDEX idx_prescriptions_consultation ON prescriptions(consultation_id);

-- 4. Mock data

-- Insert specialties with updated fees
INSERT INTO specialties (specialty_name, description, consultation_fee) VALUES
('General Medicine', 'Primary care and general health management', 2000.00),
('Cardiology', 'Disorders of the heart and cardiovascular system', 4500.00),
('Pediatrics', 'Medical care of infants, children, and adolescents', 3500.00),
('Dermatology', 'Conditions related to skin, hair, and nails', 4000.00),
('Orthopedics', 'Musculoskeletal system issues and surgeries', 5000.00),
('Gynecology', 'Female reproductive health', 4000.00);

-- Insert a new roster of doctors
INSERT INTO doctors (last_name, first_name, email, phone, specialty_id, license_number, hire_date, office, active) VALUES
('Boudiaf', 'Yassine', 'yassine.boudiaf@hospital.dz', '0555-11-22-33', 1, 'MED-2015-110', '2015-04-12', 'Block A - 101', TRUE),
('Zerouki', 'Rym', 'rym.zerouki@hospital.dz', '0555-22-33-44', 2, 'MED-2012-088', '2012-09-01', 'Block B - 205', TRUE),
('Kateb', 'Amina', 'amina.kateb@hospital.dz', '0555-33-44-55', 3, 'MED-2018-042', '2018-02-15', 'Block C - 302', TRUE),
('Merbah', 'Lyes', 'lyes.merbah@hospital.dz', '0555-44-55-66', 4, 'MED-2020-201', '2020-11-10', 'Block A - 105', TRUE),
('Toumi', 'Sofiane', 'sofiane.toumi@hospital.dz', '0555-55-66-77', 5, 'MED-2010-015', '2010-06-20', 'Block B - 210', TRUE),
('Saidi', 'Imane', 'imane.saidi@hospital.dz', '0555-66-77-88', 6, 'MED-2019-150', '2019-08-05', 'Block C - 305', TRUE);

-- Insert a new list of patients
INSERT INTO patients (file_number, last_name, first_name, date_of_birth, gender, blood_type, email, phone, address, city, province, registration_date, insurance, insurance_number, allergies, medical_history) VALUES
('PT-26-001', 'Mansouri', 'Tarek', '1982-10-05', 'M', 'O+', 'tarek.m@gmail.com', '0661-12-34-56', 'Cité 1000 Logements', 'Algiers', 'Alger', '2026-01-10', 'CNAS', 'CN-998877', 'Pollen', 'Asthma'),
('PT-26-002', 'Keddache', 'Meriem', '1993-04-18', 'F', 'B-', 'meriem.ked@yahoo.fr', '0662-23-45-67', 'Rue de la Paix', 'Oran', 'Oran', '2026-01-12', 'CASNOS', 'CS-554433', NULL, NULL),
('PT-26-003', 'Belkacem', 'Idir', '2018-08-22', 'M', 'A+', NULL, '0663-34-56-78', 'Quartier Bellevue', 'Bejaia', 'Bejaia', '2026-01-15', NULL, NULL, 'Lactose', NULL),
('PT-26-004', 'Djabali', 'Sonia', '1975-12-01', 'F', 'AB+', 'sonia.djabali@hotmail.com', '0664-45-67-89', 'Avenue de l\'Indépendance', 'Setif', 'Setif', '2026-02-01', 'CNAS', 'CN-112233', NULL, 'Type 2 Diabetes'),
('PT-26-005', 'Haddad', 'Nassim', '2001-02-14', 'M', 'O-', 'nassim.haddad99@gmail.com', '0665-56-78-90', 'Cité Universitaire', 'Constantine', 'Constantine', '2026-02-10', NULL, NULL, 'Dust Mites', NULL),
('PT-26-006', 'Lamari', 'Kenza', '1988-06-30', 'F', 'A-', 'kenza.lam@gmail.com', '0666-67-89-01', 'Rue des Frères', 'Annaba', 'Annaba', '2026-02-15', 'CASNOS', 'CS-667788', 'Penicillin', 'Migraines'),
('PT-26-007', 'Bougara', 'Walid', '1965-09-11', 'M', 'O+', NULL, '0667-78-90-12', 'Centre Ville', 'Tlemcen', 'Tlemcen', '2026-03-01', 'CNAS', 'CN-445566', NULL, 'Hypertension'),
('PT-26-008', 'Chabane', 'Amira', '2012-05-25', 'F', 'B+', 'parent.amira@gmail.com', '0668-89-01-23', 'Cité des Roses', 'Blida', 'Blida', '2026-03-05', 'CASNOS', 'CS-990011', 'Peanuts', NULL),
('PT-26-009', 'Latreche', 'Fouad', '1990-11-20', 'M', 'A+', 'fouad.lat@yahoo.com', '0669-90-12-34', 'Rue du Lycée', 'Batna', 'Batna', '2026-03-10', NULL, NULL, NULL, NULL);

-- Insert consultations matching the new patients and doctors (Dates set in early 2026)
INSERT INTO consultations (patient_id, doctor_id, consultation_date, reason, diagnosis, observations, blood_pressure, temperature, weight, height, status, amount, paid) VALUES
(1, 1, '2026-02-10 08:30:00', 'Severe cough', 'Bronchitis', 'Advised rest and inhaler', '125/82', 38.0, 78.5, 180.0, 'Completed', 2000.00, TRUE),
(2, 6, '2026-02-12 11:00:00', 'Routine exam', 'Healthy', 'All normal', '110/70', 36.6, 65.0, 168.0, 'Completed', 4000.00, TRUE),
(3, 3, '2026-02-15 14:15:00', 'Stomach ache', 'Gastroenteritis', 'Hydration crucial', '95/60', 38.5, 22.0, 115.0, 'Completed', 3500.00, TRUE),
(4, 2, '2026-02-20 09:00:00', 'Palpitations', 'Arrhythmia', 'Schedule Holter monitor', '145/95', 36.8, 85.0, 160.0, 'Completed', 4500.00, FALSE),
(5, 4, '2026-02-25 15:30:00', 'Acne flare-up', 'Severe Acne Vulgaris', 'Topical treatment prescribed', '120/75', 36.5, 72.0, 177.0, 'Completed', 4000.00, TRUE),
(6, 1, '2026-03-02 10:45:00', 'Headache', 'Tension headache', 'Stress management needed', '118/78', 36.7, 60.0, 165.0, 'Completed', 2000.00, TRUE),
(7, 2, '2026-03-05 13:00:00', 'BP Check', 'Hypertension controlled', 'Continue current meds', '130/85', 36.4, 90.0, 172.0, 'Completed', 4500.00, TRUE),
(8, 3, '2026-03-10 16:00:00', 'Allergic reaction', 'Food allergy (mild)', 'Prescribed antihistamines', '105/65', 37.1, 40.0, 145.0, 'Completed', 3500.00, FALSE),
(1, 1, '2026-03-18 09:00:00', 'Bronchitis follow-up', NULL, NULL, NULL, NULL, NULL, NULL, 'Scheduled', 2000.00, FALSE);

-- Insert updated medications with adjusted stocks and prices
INSERT INTO medications (medication_code, commercial_name, generic_name, form, dosage, manufacturer, unit_price, available_stock, minimum_stock, expiration_date, prescription_required, reimbursable) VALUES
('RX-001', 'Panadol', 'Paracetamol', 'Tablet', '500mg', 'GSK', 180.00, 600, 150, '2027-10-31', FALSE, TRUE),
('RX-002', 'Clamoxyl', 'Amoxicillin', 'Capsule', '500mg', 'Pfizer', 350.00, 150, 50, '2027-05-30', TRUE, TRUE),
('RX-003', 'Smecta', 'Diosmectite', 'Powder', '3g', 'Ipsen', 400.00, 90, 30, '2028-01-15', FALSE, TRUE),
('RX-004', 'Advil', 'Ibuprofen', 'Tablet', '400mg', 'Pfizer', 250.00, 400, 100, '2027-08-20', FALSE, FALSE),
('RX-005', 'Ventolin', 'Salbutamol', 'Inhaler', '100mcg', 'GSK', 1200.00, 45, 15, '2026-12-31', TRUE, TRUE),
('RX-006', 'Zestril', 'Lisinopril', 'Tablet', '20mg', 'AstraZeneca', 850.00, 200, 50, '2027-11-30', TRUE, TRUE),
('RX-007', 'Glucophage', 'Metformin', 'Tablet', '1000mg', 'Merck', 300.00, 500, 100, '2028-03-15', TRUE, TRUE),
('RX-008', 'Roaccutane', 'Isotretinoin', 'Capsule', '20mg', 'Roche', 4500.00, 30, 10, '2026-09-30', TRUE, FALSE),
('RX-009', 'Zyrtec', 'Cetirizine', 'Tablet', '10mg', 'UCB', 420.00, 300, 80, '2027-04-10', FALSE, TRUE),
('RX-010', 'Maxilase', 'Alpha-amylase', 'Syrup', '200U', 'Sanofi', 380.00, 75, 20, '2026-10-15', FALSE, FALSE);

-- Insert prescriptions linked to specific consultations
INSERT INTO prescriptions (consultation_id, prescription_date, treatment_duration, general_instructions) VALUES
(1, '2026-02-10 08:45:00', 10, 'Ensure plenty of rest and hydration.'),
(3, '2026-02-15 14:30:00', 5, 'Avoid dairy and greasy foods.'),
(4, '2026-02-20 09:20:00', 30, 'Take medication exactly as prescribed.'),
(5, '2026-02-25 15:45:00', 60, 'Avoid excessive sun exposure.'),
(6, '2026-03-02 11:00:00', 7, 'Take painkillers only when necessary.'),
(7, '2026-03-05 13:15:00', 90, 'Maintain low-sodium diet.'),
(8, '2026-03-10 16:15:00', 14, 'Keep antihistamines on hand at all times.');

-- Insert detailed lines for each prescription
INSERT INTO prescription_details (prescription_id, medication_id, quantity, dosage_instructions, duration, total_price) VALUES
(1, 2, 20, '1 capsule morning and evening', 10, 7000.00),
(1, 5, 1, '2 puffs every 4-6 hours as needed', 30, 1200.00),
(2, 3, 15, '1 sachet dissolved in water 3x daily', 5, 6000.00),
(2, 1, 10, '1 tablet every 8 hours if feverish', 5, 1800.00),
(3, 6, 30, '1 tablet daily in the morning', 30, 25500.00),
(4, 8, 60, '1 capsule daily with main meal', 60, 270000.00),
(5, 4, 14, '1 tablet when headache occurs (max 3/day)', 7, 3500.00),
(6, 6, 90, '1 tablet daily', 90, 76500.00),
(7, 9, 14, '1 tablet daily before bed', 14, 5880.00);

-- 5. Queries

-- Query 1: Retrieve basic contact and demographic information for all registered patients
SELECT file_number, CONCAT(last_name, ' ', first_name) AS full_name,
       date_of_birth, phone, city FROM patients;

-- Query 2: List all doctors, their respective specialties, office locations, and status
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       s.specialty_name, d.office, d.active
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id;

-- Query 3: Identify affordable medications (Unit price under 500 DA)
SELECT medication_code, commercial_name, unit_price, available_stock
FROM medications WHERE unit_price < 500;

-- Query 4: Fetch a log of all consultations that occurred in February 2026
SELECT c.consultation_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, c.status
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors d ON c.doctor_id = d.doctor_id
WHERE c.consultation_date >= '2026-02-01' AND c.consultation_date < '2026-03-01';

-- Query 5: Inventory alert - List medications that have fallen below the minimum stock threshold
SELECT commercial_name, available_stock, minimum_stock,
       (minimum_stock - available_stock) AS difference
FROM medications WHERE available_stock < minimum_stock;

-- Query 6: Comprehensive view of consultations including patient, doctor, diagnosis, and billing
SELECT c.consultation_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       c.diagnosis, c.amount
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors d ON c.doctor_id = d.doctor_id;

-- Query 7: Retrieve all prescription items, showing patient name, prescribed drug, and dosage
SELECT pr.prescription_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       m.commercial_name AS medication_name, pd.quantity, pd.dosage_instructions
FROM prescriptions pr
JOIN consultations c ON pr.consultation_id = c.consultation_id
JOIN patients p ON c.patient_id = p.patient_id
JOIN prescription_details pd ON pr.prescription_id = pd.prescription_id
JOIN medications m ON pd.medication_id = m.medication_id;

-- Query 8: Find the most recent consultation date and attending doctor for each patient
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       subq.last_consultation_date,
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name
FROM patients p
JOIN (
    SELECT patient_id, MAX(consultation_date) AS last_consultation_date
    FROM consultations GROUP BY patient_id
) subq ON p.patient_id = subq.patient_id
JOIN consultations c ON subq.patient_id = c.patient_id AND subq.last_consultation_date = c.consultation_date
JOIN doctors d ON c.doctor_id = d.doctor_id;

-- Query 9: Count the total number of consultations handled by each doctor
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       COUNT(c.consultation_id) AS consultation_count
FROM doctors d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id, d.last_name, d.first_name;

-- Query 10: Calculate total revenue generated and volume of visits per medical specialty
SELECT s.specialty_name, SUM(c.amount) AS total_revenue,
       COUNT(c.consultation_id) AS consultation_count
FROM specialties s
LEFT JOIN doctors d ON s.specialty_id = d.specialty_id
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY s.specialty_id, s.specialty_name;

-- Query 11: Calculate the total out-of-pocket prescription cost per patient
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       SUM(pd.total_price) AS total_prescription_cost
FROM patients p
JOIN consultations c ON p.patient_id = c.patient_id
JOIN prescriptions pr ON c.consultation_id = pr.consultation_id
JOIN prescription_details pd ON pr.prescription_id = pd.prescription_id
GROUP BY p.patient_id, p.last_name, p.first_name;

-- Query 12: Workload distribution - Consultations per doctor (Duplicate of Q9, retained for structure)
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       COUNT(c.consultation_id) AS consultation_count
FROM doctors d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id, d.last_name, d.first_name;

-- Query 13: Calculate the total financial value of the current hospital pharmacy stock
SELECT COUNT(medication_id) AS total_medications,
       SUM(available_stock * unit_price) AS total_stock_value
FROM medications;

-- Query 14: Determine the average consultation fee charged per specialty
SELECT s.specialty_name, AVG(c.amount) AS average_price
FROM specialties s
LEFT JOIN doctors d ON s.specialty_id = d.specialty_id
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY s.specialty_id, s.specialty_name;

-- Query 15: Group and count patients based on their blood type
SELECT blood_type, COUNT(patient_id) AS patient_count
FROM patients WHERE blood_type IS NOT NULL
GROUP BY blood_type;

-- Query 16: Identify the top 5 most frequently prescribed medications
SELECT m.commercial_name AS medication_name,
       COUNT(pd.detail_id) AS times_prescribed,
       SUM(pd.quantity) AS total_quantity
FROM medications m
JOIN prescription_details pd ON m.medication_id = pd.medication_id
GROUP BY m.medication_id, m.commercial_name
ORDER BY times_prescribed DESC LIMIT 5;

-- Query 17: Find registered patients who have never had a consultation
SELECT CONCAT(last_name, ' ', first_name) AS patient_name, registration_date
FROM patients
WHERE patient_id NOT IN (SELECT patient_id FROM consultations);

-- Query 18: List doctors who have conducted more than 2 consultations
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       s.specialty_name AS specialty,
       COUNT(c.consultation_id) AS consultation_count
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id
JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id, d.last_name, d.first_name, s.specialty_name
HAVING consultation_count > 2;

-- Query 19: Follow-up list - Fetch all completed or scheduled consultations that remain unpaid
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       c.consultation_date, c.amount,
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors d ON c.doctor_id = d.doctor_id
WHERE c.paid = FALSE AND c.amount IS NOT NULL;

-- Query 20: Expiry alert - Find medications expiring within the next 6 months
SELECT commercial_name AS medication_name, expiration_date,
       DATEDIFF(expiration_date, CURDATE()) AS days_until_expiration
FROM medications
WHERE expiration_date IS NOT NULL
  AND expiration_date <= DATE_ADD(CURDATE(), INTERVAL 6 MONTH);

-- Query 21: Identify 'frequent flyers' - Patients with more consultations than the hospital average
WITH avg_consult AS (
    SELECT AVG(cnt) AS avg_cnt FROM (
        SELECT COUNT(*) AS cnt FROM consultations GROUP BY patient_id
    ) t
)
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       COUNT(c.consultation_id) AS consultation_count,
       (SELECT avg_cnt FROM avg_consult) AS average_count
FROM patients p
JOIN consultations c ON p.patient_id = c.patient_id
GROUP BY p.patient_id, p.last_name, p.first_name
HAVING consultation_count > (SELECT avg_cnt FROM avg_consult);

-- Query 22: Identify premium medications priced above the hospital's average medication cost
SELECT m.commercial_name AS medication_name, m.unit_price,
       (SELECT AVG(unit_price) FROM medications) AS average_price
FROM medications m
WHERE m.unit_price > (SELECT AVG(unit_price) FROM medications);

-- Query 23: Find doctors belonging to the most heavily requested specialty
WITH specialty_count AS (
    SELECT d.specialty_id, COUNT(c.consultation_id) AS cnt
    FROM doctors d JOIN consultations c ON d.doctor_id = c.doctor_id
    GROUP BY d.specialty_id
    ORDER BY cnt DESC LIMIT 1
)
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       s.specialty_name, sc.cnt AS specialty_consultation_count
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id
JOIN specialty_count sc ON d.specialty_id = sc.specialty_id;

-- Query 24: Flag high-value consultations that exceed the average consultation fee
SELECT c.consultation_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       c.amount, (SELECT AVG(amount) FROM consultations WHERE amount IS NOT NULL) AS average_amount
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
WHERE c.amount > (SELECT AVG(amount) FROM consultations WHERE amount IS NOT NULL);

-- Query 25: Correlate allergic patients with their volume of active prescriptions
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
       p.allergies, COUNT(DISTINCT pr.prescription_id) AS prescription_count
FROM patients p
JOIN consultations c ON p.patient_id = c.patient_id
JOIN prescriptions pr ON c.consultation_id = pr.consultation_id
WHERE p.allergies IS NOT NULL AND p.allergies != ''
GROUP BY p.patient_id, p.last_name, p.first_name, p.allergies;

-- Query 26: Financial tracking - Total actual revenue (paid) brought in per doctor
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
       COUNT(c.consultation_id) AS total_consultations,
       SUM(c.amount) AS total_revenue
FROM doctors d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id AND c.paid = TRUE
GROUP BY d.doctor_id, d.last_name, d.first_name;

-- Query 27: Identify the top 3 most profitable medical specialties based on paid consultations
SELECT ROW_NUMBER() OVER (ORDER BY SUM(c.amount) DESC) AS `rank`,
       s.specialty_name, SUM(c.amount) AS total_revenue
FROM specialties s
LEFT JOIN doctors d ON s.specialty_id = d.specialty_id
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id AND c.paid = TRUE
GROUP BY s.specialty_id, s.specialty_name
ORDER BY total_revenue DESC LIMIT 3;

-- Query 28: Procurement list - Calculate exactly how many units are needed to restock depleted medications
SELECT commercial_name AS medication_name, available_stock AS current_stock,
       minimum_stock, (minimum_stock - available_stock) AS quantity_needed
FROM medications WHERE available_stock < minimum_stock;

-- Query 29: Calculate the average number of different medications prescribed per visit
SELECT AVG(med_count) AS average_medications_per_prescription
FROM (SELECT prescription_id, COUNT(*) AS med_count
      FROM prescription_details GROUP BY prescription_id) t;

-- Query 30: Analyze patient demographics by splitting them into defined age groups
WITH age_groups AS (
    SELECT patient_id,
           CASE
               WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) <= 18 THEN '0-18'
               WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) <= 40 THEN '19-40'
               WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) <= 60 THEN '41-60'
               ELSE '60+'
           END AS age_group
    FROM patients
)
SELECT age_group, COUNT(*) AS patient_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM patients), 2) AS percentage
FROM age_groups
GROUP BY age_group
ORDER BY age_group;

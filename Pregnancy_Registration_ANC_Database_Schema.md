# Pregnancy Registration & ANC Database Schema Documentation

## Overview

This document provides comprehensive SQL database schemas for the Pregnancy Registration and Antenatal Care (ANC) modules of the HMS (Hospital Management System). The schemas are designed to match the frontend implementation and support all form fields and data structures.

## Table of Contents

1. [Pregnancy Registration Schema](#pregnancy-registration-schema)
2. [ANC (Antenatal Care) Schema](#anc-antenal-care-schema)
3. [Database Indexes](#database-indexes)
4. [Sample Data](#sample-data)
5. [API Endpoints Reference](#api-endpoints-reference)
6. [Data Relationships](#data-relationships)

---

## Pregnancy Registration Schema

### Main Tables

#### 1. pregnancy_registrations
**Primary table for storing pregnancy registration data**

```sql
CREATE TABLE pregnancy_registrations (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    patient_id BIGINT NOT NULL,
    registration_date DATETIME2 DEFAULT GETDATE(),
    
    -- Basic Pregnancy Information
    lmp_date DATE,                                    -- Last Menstrual Period
    edd_date DATE,                                    -- Expected Due Date
    gravida INT,                                      -- Number of pregnancies
    
    -- Para (Live Births) Information
    term_pregnancies INT DEFAULT 0,                   -- Full-term pregnancies (≥37 weeks)
    preterm_pregnancies INT DEFAULT 0,                -- Pre-term pregnancies (<37 weeks)
    previous_abortions INT DEFAULT 0,                 -- Auto-calculated: Gravida - Para
    
    -- Living Children Information
    living_children INT DEFAULT 0,                    -- Auto-calculated total
    number_of_boys INT DEFAULT 0,
    number_of_girls INT DEFAULT 0,
    
    -- Husband Information
    husband_name NVARCHAR(100),
    husband_cnic NVARCHAR(15),                        -- 13-digit CNIC format
    years_married INT,
    consanguineous_marriage NVARCHAR(10) CHECK (consanguineous_marriage IN ('Yes', 'No')),
    
    -- Risk Assessment Screening
    risk_miscarriage NVARCHAR(20) CHECK (risk_miscarriage IN ('Low Risk', 'High Risk')),
    risk_preeclampsia NVARCHAR(20) CHECK (risk_preeclampsia IN ('Low Risk', 'High Risk')),
    risk_eclampsia NVARCHAR(20) CHECK (risk_eclampsia IN ('Low Risk', 'High Risk')),
    risk_dvt_vta NVARCHAR(20) CHECK (risk_dvt_vta IN ('Low Risk', 'High Risk')),
    risk_kidney_injury NVARCHAR(20) CHECK (risk_kidney_injury IN ('Low Risk', 'High Risk')),
    risk_gestational_diabetes NVARCHAR(20) CHECK (risk_gestational_diabetes IN ('Low Risk', 'High Risk')),
    risk_preterm_labor NVARCHAR(20) CHECK (risk_preterm_labor IN ('Low Risk', 'High Risk')),
    
    -- Clinical Notes
    clinical_notes NVARCHAR(MAX),
    
    -- Metadata
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    created_by BIGINT,
    updated_by BIGINT,
    
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);
```

#### 2. pregnancy_history
**Stores detailed information about previous pregnancies**

```sql
CREATE TABLE pregnancy_history (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    pregnancy_registration_id BIGINT NOT NULL,
    pregnancy_number INT NOT NULL,                    -- Sequential number (1, 2, 3...)
    date_of_delivery DATE,
    weeks_of_gestation INT,
    mode_of_delivery NVARCHAR(20) CHECK (mode_of_delivery IN ('SVD', 'Cesarean')),
    type_of_anesthesia NVARCHAR(20) CHECK (type_of_anesthesia IN ('General', 'Spinal', 'Epidural')),
    abortion_type NVARCHAR(30) CHECK (abortion_type IN ('Missed Abortion', 'Complete', 'Incomplete', 'Medically Induced')),
    dnc_performed NVARCHAR(10) CHECK (dnc_performed IN ('Yes', 'No')),
    still_alive NVARCHAR(10) CHECK (still_alive IN ('Yes', 'No')),
    complications NVARCHAR(20) CHECK (complications IN ('ANC', 'PNC', 'Peripartal')),
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (pregnancy_registration_id) REFERENCES pregnancy_registrations(id) ON DELETE CASCADE
);
```

#### 3. chronic_conditions
**Stores chronic medical conditions**

```sql
CREATE TABLE chronic_conditions (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    pregnancy_registration_id BIGINT NOT NULL,
    condition_type NVARCHAR(50) NOT NULL,             -- 'Diabetes', 'Heart Disease', 'Hypertension', etc.
    is_present BIT DEFAULT 0,
    condition_subtype NVARCHAR(100),                  -- Type 1 Diabetes, Stage 1 Hypertension, etc.
    severity NVARCHAR(20) CHECK (severity IN ('Mild', 'Moderate', 'Severe')),
    diagnosed_date DATE,
    treatment_status NVARCHAR(30),                    -- For cancer: 'Active Treatment', 'Completed Treatment', etc.
    disability_level NVARCHAR(30),                    -- For stroke: 'No Disability', 'Mild Disability', etc.
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (pregnancy_registration_id) REFERENCES pregnancy_registrations(id) ON DELETE CASCADE
);
```

#### 4. previous_surgeries
**Stores information about previous surgeries**

```sql
CREATE TABLE previous_surgeries (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    pregnancy_registration_id BIGINT NOT NULL,
    surgery_type NVARCHAR(100) NOT NULL,
    surgery_date DATE,
    notes NVARCHAR(500),
    is_caesarean BIT DEFAULT 0,
    surgery_description NVARCHAR(500),
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (pregnancy_registration_id) REFERENCES pregnancy_registrations(id) ON DELETE CASCADE
);
```

#### 5. allergies
**Stores patient allergies**

```sql
CREATE TABLE allergies (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    pregnancy_registration_id BIGINT NOT NULL,
    allergen NVARCHAR(100) NOT NULL,
    allergy_type NVARCHAR(20) CHECK (allergy_type IN ('Drug', 'Food', 'Environmental', 'Insect', 'Latex', 'Other')),
    severity NVARCHAR(20) CHECK (severity IN ('Mild', 'Moderate', 'Severe', 'Life-threatening')),
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (pregnancy_registration_id) REFERENCES pregnancy_registrations(id) ON DELETE CASCADE
);
```

#### 6. generic_information
**Stores lifestyle and general information**

```sql
CREATE TABLE generic_information (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    pregnancy_registration_id BIGINT NOT NULL,
    
    -- Lifestyle Information
    smoking BIT DEFAULT 0,
    alcohol_consumption BIT DEFAULT 0,
    other_addiction NVARCHAR(200),
    lifestyle_type NVARCHAR(20) CHECK (lifestyle_type IN ('Sedentary', 'Moderately Active', 'Active', 'Very Active')),
    exercise_habits NVARCHAR(500),
    dietary_plan NVARCHAR(500),
    dietary_habits NVARCHAR(500),
    
    -- Education & Health Information
    literacy_rate NVARCHAR(30) CHECK (literacy_rate IN ('Illiterate', 'Primary (1-5)', 'Middle (6-8)', 'Secondary (9-10)', 'Higher Secondary (11-12)', 'Graduate', 'Post Graduate')),
    medicine_adherence NVARCHAR(20) CHECK (medicine_adherence IN ('Excellent', 'Good', 'Fair', 'Poor', 'Non-compliant')),
    
    -- Family History
    family_history_tb BIT DEFAULT 0,
    family_history_hiv BIT DEFAULT 0,
    family_history_serology BIT DEFAULT 0,
    family_history_notes NVARCHAR(500),
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (pregnancy_registration_id) REFERENCES pregnancy_registrations(id) ON DELETE CASCADE
);
```

---

## ANC (Antenatal Care) Schema

### Main Tables

#### 1. anc_records
**Primary table for storing ANC visit data**

```sql
CREATE TABLE anc_records (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    patient_id BIGINT NOT NULL,
    pregnancy_registration_id BIGINT,
    visit_date DATETIME2 DEFAULT GETDATE(),
    visit_number INT,
    
    -- Medical History
    previous_illness NVARCHAR(500),
    past_obstetric_history NVARCHAR(500),
    
    -- Vitals
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    bmi DECIMAL(5,2),
    weight_gain DECIMAL(5,2),
    systolic_bp INT,
    diastolic_bp INT,
    temperature DECIMAL(4,1),
    blood_group NVARCHAR(5),
    hemoglobin DECIMAL(4,1),
    fundal_height DECIMAL(5,2),
    bsr DECIMAL(5,2),
    albumin NVARCHAR(20),
    muac DECIMAL(4,1),
    danger_signs NVARCHAR(500),
    
    -- ANC Visit Specific
    visit_type NVARCHAR(20) CHECK (visit_type IN ('First Visit', 'Follow-up', 'Emergency')),
    gestational_age_weeks INT,
    gestational_age_days INT,
    pulse INT,
    fetal_heart_rate INT,
    next_visit_date DATE,
    
    -- Symptoms Assessment
    urine_protein NVARCHAR(20) CHECK (urine_protein IN ('Negative', 'Trace', '1+', '2+', '3+')),
    edema_assessment NVARCHAR(20) CHECK (edema_assessment IN ('None', 'Mild', 'Moderate', 'Severe')),
    fetal_movements NVARCHAR(20) CHECK (fetal_movements IN ('Normal', 'Reduced', 'Absent')),
    fetal_presentation NVARCHAR(20) CHECK (fetal_presentation IN ('Cephalic', 'Breech', 'Transverse')),
    fetal_position NVARCHAR(20) CHECK (fetal_position IN ('LOA', 'ROA', 'LOP', 'ROP', 'LOT', 'ROT')),
    nausea_vomiting NVARCHAR(20) CHECK (nausea_vomiting IN ('None', 'Mild', 'Moderate', 'Severe')),
    headaches NVARCHAR(20) CHECK (headaches IN ('None', 'Mild', 'Moderate', 'Severe')),
    urinary_symptoms NVARCHAR(20) CHECK (urinary_symptoms IN ('None', 'Frequency', 'Dysuria', 'Incontinence')),
    pain_location NVARCHAR(50),
    pain_severity NVARCHAR(20) CHECK (pain_severity IN ('Mild', 'Moderate', 'Severe')),
    pain_duration NVARCHAR(50),
    
    -- Boolean Symptoms
    visual_changes BIT DEFAULT 0,
    abdominal_pain BIT DEFAULT 0,
    vaginal_bleeding BIT DEFAULT 0,
    vaginal_discharge BIT DEFAULT 0,
    contractions BIT DEFAULT 0,
    dizziness_fainting BIT DEFAULT 0,
    breathing_difficulty BIT DEFAULT 0,
    lab_test_required BIT DEFAULT 0,
    
    -- Doctor's Notes
    doctor_notes NVARCHAR(MAX),
    
    -- Metadata
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    created_by BIGINT,
    updated_by BIGINT,
    
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (pregnancy_registration_id) REFERENCES pregnancy_registrations(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);
```

#### 2. anc_medical_conditions
**Stores medical conditions for ANC visits**

```sql
CREATE TABLE anc_medical_conditions (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    anc_record_id BIGINT NOT NULL,
    condition_name NVARCHAR(100) NOT NULL,
    is_present BIT DEFAULT 0,
    
    created_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (anc_record_id) REFERENCES anc_records(id) ON DELETE CASCADE
);
```

#### 3. anc_obstetric_history
**Stores obstetric history conditions**

```sql
CREATE TABLE anc_obstetric_history (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    anc_record_id BIGINT NOT NULL,
    condition_name NVARCHAR(100) NOT NULL,
    is_present BIT DEFAULT 0,
    
    created_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (anc_record_id) REFERENCES anc_records(id) ON DELETE CASCADE
);
```

#### 4. ultrasound_records
**Stores ultrasound examination data**

```sql
CREATE TABLE ultrasound_records (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    anc_record_id BIGINT NOT NULL,
    ultrasound_conducted BIT DEFAULT 0,
    type_of_pregnancy NVARCHAR(20) CHECK (type_of_pregnancy IN ('Single', 'Twin', 'Triplets')),
    fetal_movement NVARCHAR(20) CHECK (fetal_movement IN ('Normal', 'Reduced', 'Absent')),
    presentation NVARCHAR(20) CHECK (presentation IN ('Cephalic', 'Breech', 'Transverse')),
    delivery_type NVARCHAR(20) CHECK (delivery_type IN ('Normal', 'Cesarean', 'Assisted')),
    placenta NVARCHAR(50),
    placenta_condition NVARCHAR(50),
    liquor NVARCHAR(50),
    fetal_heart_rate INT,
    ultrasound_notes NVARCHAR(500),
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (anc_record_id) REFERENCES anc_records(id) ON DELETE CASCADE
);
```

#### 5. anc_supplements
**Stores supplements given during ANC visits**

```sql
CREATE TABLE anc_supplements (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    anc_record_id BIGINT NOT NULL,
    supplement_name NVARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    supplements_given BIT DEFAULT 0,
    
    created_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (anc_record_id) REFERENCES anc_records(id) ON DELETE CASCADE
);
```

#### 6. anc_referrals
**Stores referral information**

```sql
CREATE TABLE anc_referrals (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    anc_record_id BIGINT NOT NULL,
    patient_referred BIT DEFAULT 0,
    district NVARCHAR(50),
    referral_type NVARCHAR(20) CHECK (referral_type IN ('DHQ', 'THQ', 'RHC', 'BHU')),
    health_facility NVARCHAR(200),
    referral_reason NVARCHAR(500),
    referral_date DATE,
    
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    
    FOREIGN KEY (anc_record_id) REFERENCES anc_records(id) ON DELETE CASCADE
);
```

---

## Database Indexes

### Performance Optimization Indexes

```sql
-- Pregnancy Registration Indexes
CREATE INDEX IX_pregnancy_registrations_patient_id ON pregnancy_registrations(patient_id);
CREATE INDEX IX_pregnancy_registrations_registration_date ON pregnancy_registrations(registration_date);
CREATE INDEX IX_pregnancy_registrations_edd_date ON pregnancy_registrations(edd_date);

-- Related Tables Indexes
CREATE INDEX IX_pregnancy_history_pregnancy_registration_id ON pregnancy_history(pregnancy_registration_id);
CREATE INDEX IX_chronic_conditions_pregnancy_registration_id ON chronic_conditions(pregnancy_registration_id);
CREATE INDEX IX_previous_surgeries_pregnancy_registration_id ON previous_surgeries(pregnancy_registration_id);
CREATE INDEX IX_allergies_pregnancy_registration_id ON allergies(pregnancy_registration_id);
CREATE INDEX IX_generic_information_pregnancy_registration_id ON generic_information(pregnancy_registration_id);

-- ANC Indexes
CREATE INDEX IX_anc_records_patient_id ON anc_records(patient_id);
CREATE INDEX IX_anc_records_visit_date ON anc_records(visit_date);
CREATE INDEX IX_anc_records_pregnancy_registration_id ON anc_records(pregnancy_registration_id);
CREATE INDEX IX_anc_records_visit_number ON anc_records(visit_number);

-- ANC Related Tables Indexes
CREATE INDEX IX_ultrasound_records_anc_record_id ON ultrasound_records(anc_record_id);
CREATE INDEX IX_anc_supplements_anc_record_id ON anc_supplements(anc_record_id);
CREATE INDEX IX_anc_referrals_anc_record_id ON anc_referrals(anc_record_id);
CREATE INDEX IX_anc_medical_conditions_anc_record_id ON anc_medical_conditions(anc_record_id);
CREATE INDEX IX_anc_obstetric_history_anc_record_id ON anc_obstetric_history(anc_record_id);
```

---

## Sample Data

### Sample Pregnancy Registration

```sql
-- Sample Pregnancy Registration
INSERT INTO pregnancy_registrations (
    patient_id, lmp_date, edd_date, gravida, term_pregnancies, 
    preterm_pregnancies, living_children, number_of_boys, number_of_girls,
    husband_name, husband_cnic, years_married, consanguineous_marriage,
    risk_miscarriage, risk_preeclampsia, clinical_notes
) VALUES (
    1, '2024-01-15', '2024-10-22', 2, 1, 0, 1, 1, 0,
    'John Doe', '12345-1234567-1', 3, 'No',
    'Low Risk', 'Low Risk', 'Patient is healthy, no complications expected'
);

-- Sample Pregnancy History
INSERT INTO pregnancy_history (
    pregnancy_registration_id, pregnancy_number, date_of_delivery, 
    weeks_of_gestation, mode_of_delivery, type_of_anesthesia, still_alive
) VALUES (
    1, 1, '2022-08-15', 39, 'SVD', 'None', 'Yes'
);

-- Sample Chronic Condition
INSERT INTO chronic_conditions (
    pregnancy_registration_id, condition_type, is_present, 
    condition_subtype, severity, diagnosed_date
) VALUES (
    1, 'Diabetes', 1, 'Type 2 Diabetes', 'Mild', '2020-03-15'
);

-- Sample Allergy
INSERT INTO allergies (
    pregnancy_registration_id, allergen, allergy_type, severity
) VALUES (
    1, 'Penicillin', 'Drug', 'Severe'
);
```

### Sample ANC Record

```sql
-- Sample ANC Record
INSERT INTO anc_records (
    patient_id, pregnancy_registration_id, visit_number, height_cm, weight_kg,
    systolic_bp, diastolic_bp, blood_group, hemoglobin, visit_type,
    gestational_age_weeks, gestational_age_days, fetal_heart_rate
) VALUES (
    1, 1, 1, 165.0, 65.0, 120, 80, 'A+', 11.5, 'First Visit',
    12, 3, 150
);

-- Sample Ultrasound Record
INSERT INTO ultrasound_records (
    anc_record_id, ultrasound_conducted, type_of_pregnancy, 
    fetal_movement, presentation, fetal_heart_rate
) VALUES (
    1, 1, 'Single', 'Normal', 'Cephalic', 150
);

-- Sample Supplements
INSERT INTO anc_supplements (
    anc_record_id, supplement_name, quantity, supplements_given
) VALUES 
(1, 'Folic Acid', 1, 1),
(1, 'Iron Tablets', 1, 1),
(1, 'Calcium', 1, 1);
```

---

## API Endpoints Reference

### Pregnancy Registration Endpoints

```
POST   /api/pregnancy-registration                    # Create new registration
GET    /api/pregnancy-registration/{id}               # Get registration by ID
PUT    /api/pregnancy-registration/{id}               # Update registration
DELETE /api/pregnancy-registration/{id}               # Delete registration
GET    /api/pregnancy-registration/patient/{patientId} # Get by patient ID

POST   /api/pregnancy-registration/{id}/history       # Add pregnancy history
PUT    /api/pregnancy-registration/history/{historyId} # Update pregnancy history
DELETE /api/pregnancy-registration/history/{historyId} # Delete pregnancy history

POST   /api/pregnancy-registration/{id}/conditions    # Add chronic condition
PUT    /api/pregnancy-registration/conditions/{conditionId} # Update condition
DELETE /api/pregnancy-registration/conditions/{conditionId} # Delete condition

POST   /api/pregnancy-registration/{id}/surgeries     # Add surgery
PUT    /api/pregnancy-registration/surgeries/{surgeryId} # Update surgery
DELETE /api/pregnancy-registration/surgeries/{surgeryId} # Delete surgery

POST   /api/pregnancy-registration/{id}/allergies     # Add allergy
PUT    /api/pregnancy-registration/allergies/{allergyId} # Update allergy
DELETE /api/pregnancy-registration/allergies/{allergyId} # Delete allergy
```

### ANC Endpoints

```
POST   /api/anc-records                               # Create new ANC record
GET    /api/anc-records/{id}                          # Get ANC record by ID
PUT    /api/anc-records/{id}                          # Update ANC record
DELETE /api/anc-records/{id}                          # Delete ANC record
GET    /api/anc-records/patient/{patientId}           # Get by patient ID

POST   /api/anc-records/{id}/ultrasound               # Add ultrasound record
PUT    /api/anc-records/ultrasound/{ultrasoundId}     # Update ultrasound
DELETE /api/anc-records/ultrasound/{ultrasoundId}     # Delete ultrasound

POST   /api/anc-records/{id}/supplements              # Add supplements
PUT    /api/anc-records/supplements/{supplementId}    # Update supplement
DELETE /api/anc-records/supplements/{supplementId}    # Delete supplement

POST   /api/anc-records/{id}/referrals                # Add referral
PUT    /api/anc-records/referrals/{referralId}        # Update referral
DELETE /api/anc-records/referrals/{referralId}        # Delete referral
```

---

## Data Relationships

### Entity Relationship Diagram

```
patients (1) ←→ (M) pregnancy_registrations
pregnancy_registrations (1) ←→ (M) pregnancy_history
pregnancy_registrations (1) ←→ (M) chronic_conditions
pregnancy_registrations (1) ←→ (M) previous_surgeries
pregnancy_registrations (1) ←→ (M) allergies
pregnancy_registrations (1) ←→ (1) generic_information

patients (1) ←→ (M) anc_records
pregnancy_registrations (1) ←→ (M) anc_records
anc_records (1) ←→ (M) anc_medical_conditions
anc_records (1) ←→ (M) anc_obstetric_history
anc_records (1) ←→ (1) ultrasound_records
anc_records (1) ←→ (M) anc_supplements
anc_records (1) ←→ (1) anc_referrals
```

### Key Relationships

1. **Patient to Pregnancy Registration**: One patient can have multiple pregnancy registrations
2. **Pregnancy Registration to History**: One registration can have multiple previous pregnancy records
3. **Pregnancy Registration to ANC**: One registration can have multiple ANC visits
4. **ANC to Related Data**: Each ANC visit can have ultrasound, supplements, and referrals

---

## Implementation Notes

### Data Validation

- All date fields should be validated for proper format (YYYY-MM-DD)
- CNIC fields should follow the format: XXXXX-XXXXXXX-X
- Numeric fields should have appropriate range validations
- Check constraints ensure data integrity for dropdown values

### Security Considerations

- All tables include created_by and updated_by fields for audit trails
- Foreign key constraints ensure referential integrity
- Sensitive data like CNIC should be encrypted at rest

### Performance Considerations

- Indexes are created on frequently queried columns
- Consider partitioning large tables by date ranges
- Regular maintenance of statistics for optimal query performance

### Backup and Recovery

- Regular full database backups
- Transaction log backups for point-in-time recovery
- Test restore procedures regularly

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-01-XX | Initial schema creation |
| 1.1 | 2024-01-XX | Added indexes and sample data |
| 1.2 | 2024-01-XX | Added API endpoints reference |

---

## Contact Information

For questions or clarifications regarding this schema, please contact the development team.

**Document Created**: January 2024  
**Last Updated**: January 2024  
**Schema Version**: 1.2

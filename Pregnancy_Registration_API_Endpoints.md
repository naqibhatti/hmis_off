# Pregnancy Registration API Endpoints Documentation

## Overview
This document outlines the comprehensive API endpoints required for the Pregnancy Registration system, covering all 6 tabs and their respective data management needs.

## Base URL Structure
```
Base URL: /api/pregnancy-registration
Version: v1
Authentication: Bearer Token Required
```

---

## 1. PREGNANCY DETAILS TAB

### 1.1 Core Pregnancy Information
**Endpoint:** `POST /api/pregnancy-registration/v1/pregnancy-details`
**Purpose:** Save/Update core pregnancy information

**Request Body:**
```json
{
  "patientId": "string (required)",
  "lastMenstrualPeriod": "2024-01-15",
  "expectedDeliveryDate": "2024-10-22",
  "gravida": 2,
  "termDeliveries": 1,
  "pretermDeliveries": 0,
  "previousAbortions": 0,
  "livingChildren": 1,
  "numberOfBoys": 1,
  "numberOfGirls": 0,
  "husbandName": "Ahmed Khan",
  "husbandCnic": "12345-1234567-1",
  "yearsMarried": 3,
  "consanguineousMarriage": "No"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "pregnancyId": "preg_123456",
    "patientId": "patient_789",
    "registrationDate": "2024-01-20T10:30:00Z",
    "calculatedFields": {
      "gestationalAgeWeeks": 8,
      "gestationalAgeDays": 3,
      "para": "1-0-0-1"
    }
  },
  "message": "Pregnancy details saved successfully"
}
```

### 1.2 Pregnancy History Management
**Endpoint:** `POST /api/pregnancy-registration/v1/pregnancy-history`
**Purpose:** Add pregnancy history entries

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "pregnancyHistory": [
    {
      "dateOfDelivery": "2022-05-15",
      "weeksOfGestation": 39,
      "deliveryType": "Normal",
      "birthWeight": 3.2,
      "outcome": "Live Birth",
      "complications": "None"
    }
  ]
}
```

**Endpoint:** `GET /api/pregnancy-registration/v1/pregnancy-history/{pregnancyId}`
**Purpose:** Retrieve pregnancy history

**Endpoint:** `DELETE /api/pregnancy-registration/v1/pregnancy-history/{historyId}`
**Purpose:** Remove pregnancy history entry

---

## 2. CHRONIC CONDITIONS TAB

### 2.1 Diabetes Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/diabetes`
**Purpose:** Save diabetes information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasDiabetes": true,
  "diabetesType": "Type 1",
  "diabetesSeverity": "Moderate",
  "diagnosedDate": "2020-03-15",
  "currentMedication": "Insulin",
  "lastHbA1c": 7.2,
  "pregnancySpecificNotes": "Well controlled with diet"
}
```

### 2.2 Heart Disease Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/heart-disease`
**Purpose:** Save heart disease information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasHeartDisease": true,
  "heartConditionType": "Congenital Heart Disease",
  "heartSeverity": "Mild",
  "diagnosedDate": "2018-07-20",
  "currentMedication": "Beta-blockers",
  "lastEchoDate": "2023-12-15",
  "ejectionFraction": 55
}
```

### 2.3 Hypertension Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/hypertension`
**Purpose:** Save hypertension information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasHypertension": true,
  "hypertensionStage": "Stage 1",
  "diagnosedDate": "2021-09-10",
  "currentMedication": "ACE Inhibitors",
  "lastBloodPressure": "140/90",
  "targetBloodPressure": "130/80"
}
```

### 2.4 Stroke Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/stroke`
**Purpose:** Save stroke information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasStroke": true,
  "strokeType": "Ischemic",
  "strokeDisabilityLevel": "Mild",
  "diagnosedDate": "2019-11-05",
  "affectedAreas": ["Left arm weakness"],
  "rehabilitationStatus": "Ongoing"
}
```

### 2.5 Cancer Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/cancer`
**Purpose:** Save cancer information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasCancer": true,
  "cancerType": "Breast Cancer",
  "cancerTreatmentStatus": "In Remission",
  "diagnosedDate": "2022-01-15",
  "lastTreatmentDate": "2022-08-20",
  "oncologyFollowUp": "Every 3 months"
}
```

### 2.6 Asthma Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/asthma`
**Purpose:** Save asthma information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasAsthma": true,
  "asthmaSeverity": "Moderate",
  "diagnosedDate": "2015-04-12",
  "currentMedication": "Inhaled corticosteroids",
  "lastAttackDate": "2023-10-15",
  "triggers": ["Dust", "Pollen"]
}
```

### 2.7 IBD Management
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/ibd`
**Purpose:** Save IBD information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasIBD": true,
  "ibdType": "Crohn's Disease",
  "ibdSeverity": "Mild",
  "diagnosedDate": "2017-06-08",
  "currentMedication": "Mesalamine",
  "lastFlareDate": "2023-09-20",
  "affectedAreas": ["Small intestine"]
}
```

### 2.8 Bulk Chronic Conditions
**Endpoint:** `POST /api/pregnancy-registration/v1/chronic-conditions/bulk`
**Purpose:** Save all chronic conditions at once

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "conditions": {
    "diabetes": { /* diabetes data */ },
    "heartDisease": { /* heart disease data */ },
    "hypertension": { /* hypertension data */ },
    "stroke": { /* stroke data */ },
    "cancer": { /* cancer data */ },
    "asthma": { /* asthma data */ },
    "ibd": { /* ibd data */ }
  }
}
```

---

## 3. PREVIOUS SURGERY TAB

### 3.1 Surgery Information
**Endpoint:** `POST /api/pregnancy-registration/v1/previous-surgery`
**Purpose:** Save previous surgery information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "hasPreviousSurgery": true,
  "surgeries": [
    {
      "surgeryType": "Appendectomy",
      "surgeryDate": "2020-08-15",
      "hospital": "City General Hospital",
      "surgeon": "Dr. Smith",
      "complications": "None",
      "recoveryTime": "2 weeks",
      "notes": "Laparoscopic procedure"
    },
    {
      "surgeryType": "Cesarean Section",
      "surgeryDate": "2022-05-15",
      "hospital": "Women's Hospital",
      "surgeon": "Dr. Johnson",
      "complications": "Minor bleeding",
      "recoveryTime": "6 weeks",
      "notes": "Emergency C-section"
    }
  ]
}
```

**Endpoint:** `GET /api/pregnancy-registration/v1/previous-surgery/{pregnancyId}`
**Purpose:** Retrieve previous surgery information

**Endpoint:** `PUT /api/pregnancy-registration/v1/previous-surgery/{surgeryId}`
**Purpose:** Update specific surgery entry

**Endpoint:** `DELETE /api/pregnancy-registration/v1/previous-surgery/{surgeryId}`
**Purpose:** Remove surgery entry

---

## 4. ALLERGIES TAB

### 4.1 Allergy Management
**Endpoint:** `POST /api/pregnancy-registration/v1/allergies`
**Purpose:** Save allergy information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "allergies": [
    {
      "allergen": "Penicillin",
      "allergyType": "Drug",
      "severity": "Severe",
      "reaction": "Anaphylaxis",
      "firstOccurrence": "2018-03-10",
      "lastOccurrence": "2018-03-10",
      "notes": "Avoid all penicillin derivatives"
    },
    {
      "allergen": "Shellfish",
      "allergyType": "Food",
      "severity": "Moderate",
      "reaction": "Hives and swelling",
      "firstOccurrence": "2019-07-20",
      "lastOccurrence": "2023-12-15",
      "notes": "Avoid all shellfish products"
    }
  ]
}
```

**Endpoint:** `GET /api/pregnancy-registration/v1/allergies/{pregnancyId}`
**Purpose:** Retrieve allergy information

**Endpoint:** `PUT /api/pregnancy-registration/v1/allergies/{allergyId}`
**Purpose:** Update specific allergy entry

**Endpoint:** `DELETE /api/pregnancy-registration/v1/allergies/{allergyId}`
**Purpose:** Remove allergy entry

---

## 5. GENERIC INFO TAB

### 5.1 Generic Information
**Endpoint:** `POST /api/pregnancy-registration/v1/generic-info`
**Purpose:** Save generic information

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "genericInfo": {
    "occupation": "Teacher",
    "educationLevel": "Bachelor's Degree",
    "maritalStatus": "Married",
    "religion": "Islam",
    "ethnicity": "Punjabi",
    "language": "Urdu",
    "emergencyContact": {
      "name": "Fatima Khan",
      "relationship": "Sister",
      "phone": "+92-300-1234567",
      "address": "123 Main Street, Lahore"
    },
    "insuranceInfo": {
      "provider": "State Insurance",
      "policyNumber": "INS-789456",
      "expiryDate": "2024-12-31"
    }
  }
}
```

**Endpoint:** `GET /api/pregnancy-registration/v1/generic-info/{pregnancyId}`
**Purpose:** Retrieve generic information

---

## 6. CLINICAL NOTES TAB

### 6.1 Risk Assessment Screening
**Endpoint:** `POST /api/pregnancy-registration/v1/risk-assessment`
**Purpose:** Save risk assessment screening results

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "riskAssessment": {
    "misCarriage": "Low Risk",
    "preEclampsia": "High Risk",
    "eclampsia": "Low Risk",
    "dvtVta": "Low Risk",
    "kidneyInjury": "Low Risk",
    "gestationalDiabetes": "High Risk",
    "preTermLabor": "Low Risk"
  },
  "assessmentDate": "2024-01-20T10:30:00Z",
  "assessedBy": "Dr. Sarah Ahmed",
  "notes": "Patient shows high risk for pre-eclampsia due to family history"
}
```

### 6.2 Clinical Notes
**Endpoint:** `POST /api/pregnancy-registration/v1/clinical-notes`
**Purpose:** Save clinical notes

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "clinicalNotes": "Patient presents with normal vital signs. No immediate concerns. Recommended regular ANC visits. Patient educated about warning signs of pre-eclampsia.",
  "notesDate": "2024-01-20T10:30:00Z",
  "notesBy": "Dr. Sarah Ahmed",
  "category": "Initial Assessment"
}
```

**Endpoint:** `GET /api/pregnancy-registration/v1/clinical-notes/{pregnancyId}`
**Purpose:** Retrieve clinical notes history

---

## 7. COMPREHENSIVE DATA MANAGEMENT

### 7.1 Complete Pregnancy Registration
**Endpoint:** `POST /api/pregnancy-registration/v1/complete-registration`
**Purpose:** Save complete pregnancy registration data

**Request Body:**
```json
{
  "patientId": "string (required)",
  "pregnancyDetails": { /* pregnancy details data */ },
  "chronicConditions": { /* chronic conditions data */ },
  "previousSurgery": { /* surgery data */ },
  "allergies": { /* allergies data */ },
  "genericInfo": { /* generic info data */ },
  "riskAssessment": { /* risk assessment data */ },
  "clinicalNotes": "string",
  "registrationDate": "2024-01-20T10:30:00Z",
  "registeredBy": "Dr. Sarah Ahmed"
}
```

### 7.2 Retrieve Complete Registration
**Endpoint:** `GET /api/pregnancy-registration/v1/complete-registration/{pregnancyId}`
**Purpose:** Retrieve complete pregnancy registration data

**Response:**
```json
{
  "success": true,
  "data": {
    "pregnancyId": "preg_123456",
    "patientId": "patient_789",
    "registrationDate": "2024-01-20T10:30:00Z",
    "pregnancyDetails": { /* complete pregnancy details */ },
    "chronicConditions": { /* complete chronic conditions */ },
    "previousSurgery": { /* complete surgery history */ },
    "allergies": { /* complete allergies */ },
    "genericInfo": { /* complete generic info */ },
    "riskAssessment": { /* complete risk assessment */ },
    "clinicalNotes": "string",
    "lastUpdated": "2024-01-20T10:30:00Z",
    "updatedBy": "Dr. Sarah Ahmed"
  }
}
```

### 7.3 Update Registration Status
**Endpoint:** `PUT /api/pregnancy-registration/v1/registration-status/{pregnancyId}`
**Purpose:** Update registration completion status

**Request Body:**
```json
{
  "status": "Completed",
  "completionDate": "2024-01-20T10:30:00Z",
  "completedBy": "Dr. Sarah Ahmed",
  "notes": "All sections completed successfully"
}
```

---

## 8. VALIDATION & CALCULATIONS

### 8.1 Date Calculations
**Endpoint:** `POST /api/pregnancy-registration/v1/calculate-dates`
**Purpose:** Calculate pregnancy dates and gestational age

**Request Body:**
```json
{
  "lastMenstrualPeriod": "2024-01-15",
  "cycleLength": 28
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "expectedDeliveryDate": "2024-10-22",
    "gestationalAgeWeeks": 8,
    "gestationalAgeDays": 3,
    "trimester": 1,
    "daysRemaining": 275
  }
}
```

### 8.2 Risk Assessment Calculation
**Endpoint:** `POST /api/pregnancy-registration/v1/calculate-risk`
**Purpose:** Calculate pregnancy risk factors

**Request Body:**
```json
{
  "pregnancyId": "string (required)",
  "currentData": { /* current pregnancy data */ }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "overallRisk": "High",
    "riskFactors": [
      "Advanced maternal age",
      "Previous C-section",
      "Gestational diabetes"
    ],
    "recommendations": [
      "Increased monitoring",
      "Specialist consultation",
      "Early delivery planning"
    ]
  }
}
```

---

## 9. LOOKUP DATA ENDPOINTS

### 9.1 Medical Conditions Lookup
**Endpoint:** `GET /api/pregnancy-registration/v1/lookup/medical-conditions`
**Purpose:** Get list of medical conditions

**Response:**
```json
{
  "success": true,
  "data": {
    "diabetesTypes": ["Type 1", "Type 2", "Gestational"],
    "heartConditions": ["Congenital", "Acquired", "Arrhythmia"],
    "hypertensionStages": ["Stage 1", "Stage 2", "Stage 3"],
    "strokeTypes": ["Ischemic", "Hemorrhagic", "TIA"],
    "cancerTypes": ["Breast", "Cervical", "Ovarian"],
    "asthmaSeverity": ["Mild", "Moderate", "Severe"],
    "ibdTypes": ["Crohn's Disease", "Ulcerative Colitis"]
  }
}
```

### 9.2 Surgery Types Lookup
**Endpoint:** `GET /api/pregnancy-registration/v1/lookup/surgery-types`
**Purpose:** Get list of surgery types

### 9.3 Allergy Types Lookup
**Endpoint:** `GET /api/pregnancy-registration/v1/lookup/allergy-types`
**Purpose:** Get list of allergy types

### 9.4 Risk Assessment Options
**Endpoint:** `GET /api/pregnancy-registration/v1/lookup/risk-assessment`
**Purpose:** Get risk assessment options

**Response:**
```json
{
  "success": true,
  "data": {
    "riskLevels": ["Low Risk", "High Risk"],
    "conditions": [
      "Mis-carriage",
      "Pre-Eclampsia",
      "Eclampsia",
      "DVT/VTA",
      "Increased Risk of Kidney Injury",
      "Gestational Diabetes",
      "Pre-Term Labor"
    ]
  }
}
```

---

## 10. AUDIT & TRACKING

### 10.1 Registration Audit Trail
**Endpoint:** `GET /api/pregnancy-registration/v1/audit/{pregnancyId}`
**Purpose:** Get registration audit trail

**Response:**
```json
{
  "success": true,
  "data": {
    "pregnancyId": "preg_123456",
    "auditTrail": [
      {
        "action": "Created",
        "timestamp": "2024-01-20T10:30:00Z",
        "user": "Dr. Sarah Ahmed",
        "details": "Initial pregnancy registration created"
      },
      {
        "action": "Updated",
        "timestamp": "2024-01-20T11:15:00Z",
        "user": "Dr. Sarah Ahmed",
        "details": "Risk assessment completed"
      }
    ]
  }
}
```

### 10.2 Data Export
**Endpoint:** `GET /api/pregnancy-registration/v1/export/{pregnancyId}`
**Purpose:** Export complete registration data

**Query Parameters:**
- `format`: `json` | `pdf` | `excel`
- `includeHistory`: `true` | `false`

---

## 11. ERROR HANDLING

### Standard Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid CNIC format",
    "details": {
      "field": "husbandCnic",
      "value": "12345-1234567",
      "expectedFormat": "XXXXX-XXXXXXX-X"
    }
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### Common Error Codes
- `VALIDATION_ERROR`: Input validation failed
- `PATIENT_NOT_FOUND`: Patient ID not found
- `PREGNANCY_NOT_FOUND`: Pregnancy ID not found
- `DUPLICATE_REGISTRATION`: Pregnancy already registered
- `UNAUTHORIZED`: Invalid or expired token
- `FORBIDDEN`: Insufficient permissions
- `SERVER_ERROR`: Internal server error

---

## 12. IMPLEMENTATION PRIORITY

### Phase 1 (High Priority)
1. **Core Pregnancy Details** - Basic pregnancy information
2. **Risk Assessment** - Critical for patient safety
3. **Complete Registration** - Essential for data integrity

### Phase 2 (Medium Priority)
4. **Chronic Conditions** - Important for care planning
5. **Allergies** - Safety-critical information
6. **Clinical Notes** - Documentation requirements

### Phase 3 (Lower Priority)
7. **Previous Surgery** - Historical information
8. **Generic Info** - Administrative data
9. **Audit & Tracking** - Compliance and monitoring

---

## 13. SECURITY CONSIDERATIONS

### Authentication & Authorization
- All endpoints require valid Bearer token
- Role-based access control (Doctor, Nurse, Admin)
- Patient data access restricted to authorized personnel

### Data Privacy
- All personal health information encrypted
- Audit logging for all data access
- GDPR/HIPAA compliance considerations

### Input Validation
- CNIC format validation (13 digits with dashes)
- Date range validation
- Required field validation
- SQL injection prevention

---

## 14. TESTING ENDPOINTS

### Health Check
**Endpoint:** `GET /api/pregnancy-registration/v1/health`
**Purpose:** Service health check

### Test Data Generation
**Endpoint:** `POST /api/pregnancy-registration/v1/test-data`
**Purpose:** Generate test data for development

---

This comprehensive API documentation covers all aspects of the Pregnancy Registration system, providing a complete roadmap for backend implementation and integration with the Flutter frontend.

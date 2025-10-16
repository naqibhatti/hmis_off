# Pregnancy Registration & ANC API Endpoints Documentation

## Overview

This document provides comprehensive REST API endpoints for the Pregnancy Registration and Antenatal Care (ANC) modules of the HMS (Hospital Management System). The endpoints are designed to match the frontend Flutter implementation and support all form operations.

## Table of Contents

1. [Base Configuration](#base-configuration)
2. [Pregnancy Registration Endpoints](#pregnancy-registration-endpoints)
3. [ANC (Antenatal Care) Endpoints](#anc-antenal-care-endpoints)
4. [Request/Response Models](#requestresponse-models)
5. [Error Handling](#error-handling)
6. [Authentication](#authentication)
7. [Rate Limiting](#rate-limiting)

---

## Base Configuration

### Base URL
```
Production: https://api.hms.com/v1
Development: https://dev-api.hms.com/v1
Local: http://localhost:5000/api/v1
```

### Content Type
```
Content-Type: application/json
Accept: application/json
```

### Authentication Header
```
Authorization: Bearer <access_token>
```

---

## Pregnancy Registration Endpoints

### 1. Main Pregnancy Registration

#### Create Pregnancy Registration
```http
POST /pregnancy-registration
```

**Request Body:**
```json
{
  "patientId": 123,
  "lmpDate": "2024-01-15",
  "eddDate": "2024-10-22",
  "gravida": 2,
  "termPregnancies": 1,
  "pretermPregnancies": 0,
  "livingChildren": 1,
  "numberOfBoys": 1,
  "numberOfGirls": 0,
  "husbandName": "John Doe",
  "husbandCnic": "12345-1234567-1",
  "yearsMarried": 3,
  "consanguineousMarriage": "No",
  "riskAssessment": {
    "miscarriage": "Low Risk",
    "preeclampsia": "Low Risk",
    "eclampsia": "Low Risk",
    "dvtVta": "Low Risk",
    "kidneyInjury": "Low Risk",
    "gestationalDiabetes": "Low Risk",
    "pretermLabor": "Low Risk"
  },
  "clinicalNotes": "Patient is healthy, no complications expected"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "patientId": 123,
    "registrationDate": "2024-01-20T10:30:00Z",
    "lmpDate": "2024-01-15",
    "eddDate": "2024-10-22",
    "gravida": 2,
    "termPregnancies": 1,
    "pretermPregnancies": 0,
    "livingChildren": 1,
    "numberOfBoys": 1,
    "numberOfGirls": 0,
    "husbandName": "John Doe",
    "husbandCnic": "12345-1234567-1",
    "yearsMarried": 3,
    "consanguineousMarriage": "No",
    "riskAssessment": {
      "miscarriage": "Low Risk",
      "preeclampsia": "Low Risk",
      "eclampsia": "Low Risk",
      "dvtVta": "Low Risk",
      "kidneyInjury": "Low Risk",
      "gestationalDiabetes": "Low Risk",
      "pretermLabor": "Low Risk"
    },
    "clinicalNotes": "Patient is healthy, no complications expected",
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  },
  "message": "Pregnancy registration created successfully"
}
```

#### Get Pregnancy Registration by ID
```http
GET /pregnancy-registration/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "patientId": 123,
    "registrationDate": "2024-01-20T10:30:00Z",
    "lmpDate": "2024-01-15",
    "eddDate": "2024-10-22",
    "gravida": 2,
    "termPregnancies": 1,
    "pretermPregnancies": 0,
    "livingChildren": 1,
    "numberOfBoys": 1,
    "numberOfGirls": 0,
    "husbandName": "John Doe",
    "husbandCnic": "12345-1234567-1",
    "yearsMarried": 3,
    "consanguineousMarriage": "No",
    "riskAssessment": {
      "miscarriage": "Low Risk",
      "preeclampsia": "Low Risk",
      "eclampsia": "Low Risk",
      "dvtVta": "Low Risk",
      "kidneyInjury": "Low Risk",
      "gestationalDiabetes": "Low Risk",
      "pretermLabor": "Low Risk"
    },
    "clinicalNotes": "Patient is healthy, no complications expected",
    "pregnancyHistory": [...],
    "chronicConditions": [...],
    "previousSurgeries": [...],
    "allergies": [...],
    "genericInformation": {...},
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  }
}
```

#### Update Pregnancy Registration
```http
PUT /pregnancy-registration/{id}
```

**Request Body:** (Same as create, but with updated fields)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "patientId": 123,
    "registrationDate": "2024-01-20T10:30:00Z",
    "lmpDate": "2024-01-15",
    "eddDate": "2024-10-22",
    "gravida": 2,
    "termPregnancies": 1,
    "pretermPregnancies": 0,
    "livingChildren": 1,
    "numberOfBoys": 1,
    "numberOfGirls": 0,
    "husbandName": "John Doe",
    "husbandCnic": "12345-1234567-1",
    "yearsMarried": 3,
    "consanguineousMarriage": "No",
    "riskAssessment": {
      "miscarriage": "Low Risk",
      "preeclampsia": "Low Risk",
      "eclampsia": "Low Risk",
      "dvtVta": "Low Risk",
      "kidneyInjury": "Low Risk",
      "gestationalDiabetes": "Low Risk",
      "pretermLabor": "Low Risk"
    },
    "clinicalNotes": "Updated clinical notes",
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T11:45:00Z"
  },
  "message": "Pregnancy registration updated successfully"
}
```

#### Delete Pregnancy Registration
```http
DELETE /pregnancy-registration/{id}
```

**Response:**
```json
{
  "success": true,
  "message": "Pregnancy registration deleted successfully"
}
```

#### Get Pregnancy Registrations by Patient ID
```http
GET /pregnancy-registration/patient/{patientId}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 456,
      "patientId": 123,
      "registrationDate": "2024-01-20T10:30:00Z",
      "lmpDate": "2024-01-15",
      "eddDate": "2024-10-22",
      "gravida": 2,
      "termPregnancies": 1,
      "pretermPregnancies": 0,
      "livingChildren": 1,
      "numberOfBoys": 1,
      "numberOfGirls": 0,
      "husbandName": "John Doe",
      "husbandCnic": "12345-1234567-1",
      "yearsMarried": 3,
      "consanguineousMarriage": "No",
      "riskAssessment": {
        "miscarriage": "Low Risk",
        "preeclampsia": "Low Risk",
        "eclampsia": "Low Risk",
        "dvtVta": "Low Risk",
        "kidneyInjury": "Low Risk",
        "gestationalDiabetes": "Low Risk",
        "pretermLabor": "Low Risk"
      },
      "clinicalNotes": "Patient is healthy, no complications expected",
      "createdAt": "2024-01-20T10:30:00Z",
      "updatedAt": "2024-01-20T10:30:00Z"
    }
  ],
  "total": 1
}
```

### 2. Pregnancy History Management

#### Add Pregnancy History
```http
POST /pregnancy-registration/{registrationId}/history
```

**Request Body:**
```json
{
  "pregnancyNumber": 1,
  "dateOfDelivery": "2022-08-15",
  "weeksOfGestation": 39,
  "modeOfDelivery": "SVD",
  "typeOfAnesthesia": "None",
  "abortionType": null,
  "dncPerformed": "No",
  "stillAlive": "Yes",
  "complications": "ANC"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 789,
    "pregnancyRegistrationId": 456,
    "pregnancyNumber": 1,
    "dateOfDelivery": "2022-08-15",
    "weeksOfGestation": 39,
    "modeOfDelivery": "SVD",
    "typeOfAnesthesia": "None",
    "abortionType": null,
    "dncPerformed": "No",
    "stillAlive": "Yes",
    "complications": "ANC",
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  },
  "message": "Pregnancy history added successfully"
}
```

#### Update Pregnancy History
```http
PUT /pregnancy-registration/history/{historyId}
```

#### Delete Pregnancy History
```http
DELETE /pregnancy-registration/history/{historyId}
```

### 3. Chronic Conditions Management

#### Add Chronic Condition
```http
POST /pregnancy-registration/{registrationId}/conditions
```

**Request Body:**
```json
{
  "conditionType": "Diabetes",
  "isPresent": true,
  "conditionSubtype": "Type 2 Diabetes",
  "severity": "Mild",
  "diagnosedDate": "2020-03-15",
  "treatmentStatus": null,
  "disabilityLevel": null
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 101,
    "pregnancyRegistrationId": 456,
    "conditionType": "Diabetes",
    "isPresent": true,
    "conditionSubtype": "Type 2 Diabetes",
    "severity": "Mild",
    "diagnosedDate": "2020-03-15",
    "treatmentStatus": null,
    "disabilityLevel": null,
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  },
  "message": "Chronic condition added successfully"
}
```

#### Update Chronic Condition
```http
PUT /pregnancy-registration/conditions/{conditionId}
```

#### Delete Chronic Condition
```http
DELETE /pregnancy-registration/conditions/{conditionId}
```

### 4. Previous Surgeries Management

#### Add Previous Surgery
```http
POST /pregnancy-registration/{registrationId}/surgeries
```

**Request Body:**
```json
{
  "surgeryType": "Appendectomy",
  "surgeryDate": "2018-05-10",
  "notes": "Emergency appendectomy",
  "isCaesarean": false,
  "surgeryDescription": "Laparoscopic appendectomy"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 202,
    "pregnancyRegistrationId": 456,
    "surgeryType": "Appendectomy",
    "surgeryDate": "2018-05-10",
    "notes": "Emergency appendectomy",
    "isCaesarean": false,
    "surgeryDescription": "Laparoscopic appendectomy",
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  },
  "message": "Previous surgery added successfully"
}
```

#### Update Previous Surgery
```http
PUT /pregnancy-registration/surgeries/{surgeryId}
```

#### Delete Previous Surgery
```http
DELETE /pregnancy-registration/surgeries/{surgeryId}
```

### 5. Allergies Management

#### Add Allergy
```http
POST /pregnancy-registration/{registrationId}/allergies
```

**Request Body:**
```json
{
  "allergen": "Penicillin",
  "allergyType": "Drug",
  "severity": "Severe"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 303,
    "pregnancyRegistrationId": 456,
    "allergen": "Penicillin",
    "allergyType": "Drug",
    "severity": "Severe",
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  },
  "message": "Allergy added successfully"
}
```

#### Update Allergy
```http
PUT /pregnancy-registration/allergies/{allergyId}
```

#### Delete Allergy
```http
DELETE /pregnancy-registration/allergies/{allergyId}
```

### 6. Generic Information Management

#### Update Generic Information
```http
PUT /pregnancy-registration/{registrationId}/generic-info
```

**Request Body:**
```json
{
  "smoking": false,
  "alcoholConsumption": false,
  "otherAddiction": "",
  "lifestyleType": "Moderately Active",
  "exerciseHabits": "Walking 30 minutes daily",
  "dietaryPlan": "Balanced diet",
  "dietaryHabits": "Home-cooked meals",
  "literacyRate": "Graduate",
  "medicineAdherence": "Good",
  "familyHistoryTb": false,
  "familyHistoryHiv": false,
  "familyHistorySerology": false,
  "familyHistoryNotes": ""
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 404,
    "pregnancyRegistrationId": 456,
    "smoking": false,
    "alcoholConsumption": false,
    "otherAddiction": "",
    "lifestyleType": "Moderately Active",
    "exerciseHabits": "Walking 30 minutes daily",
    "dietaryPlan": "Balanced diet",
    "dietaryHabits": "Home-cooked meals",
    "literacyRate": "Graduate",
    "medicineAdherence": "Good",
    "familyHistoryTb": false,
    "familyHistoryHiv": false,
    "familyHistorySerology": false,
    "familyHistoryNotes": "",
    "createdAt": "2024-01-20T10:30:00Z",
    "updatedAt": "2024-01-20T10:30:00Z"
  },
  "message": "Generic information updated successfully"
}
```

---

## ANC (Antenatal Care) Endpoints

### 1. Main ANC Records

#### Create ANC Record
```http
POST /anc-records
```

**Request Body:**
```json
{
  "patientId": 123,
  "pregnancyRegistrationId": 456,
  "visitNumber": 1,
  "visitType": "First Visit",
  "visitDate": "2024-01-25T09:00:00Z",
  "gestationalAgeWeeks": 12,
  "gestationalAgeDays": 3,
  "medicalHistory": {
    "previousIllness": "No significant medical history",
    "pastObstetricHistory": "Previous uncomplicated pregnancy",
    "selectedConditions": ["Diabetes", "Hypertension"],
    "selectedObstetricHistory": ["Previous Cesarean"]
  },
  "vitals": {
    "heightCm": 165.0,
    "weightKg": 65.0,
    "bmi": 23.9,
    "weightGain": 2.5,
    "systolicBp": 120,
    "diastolicBp": 80,
    "temperature": 36.5,
    "bloodGroup": "A+",
    "hemoglobin": 11.5,
    "fundalHeight": 12.0,
    "bsr": 5.2,
    "albumin": "Negative",
    "muac": 25.0,
    "dangerSigns": "None"
  },
  "symptoms": {
    "urineProtein": "Negative",
    "edemaAssessment": "None",
    "fetalMovements": "Normal",
    "fetalPresentation": "Cephalic",
    "fetalPosition": "LOA",
    "nauseaVomiting": "Mild",
    "headaches": "None",
    "urinarySymptoms": "None",
    "painLocation": "",
    "painSeverity": null,
    "painDuration": "",
    "visualChanges": false,
    "abdominalPain": false,
    "vaginalBleeding": false,
    "vaginalDischarge": false,
    "contractions": false,
    "dizzinessFainting": false,
    "breathingDifficulty": false,
    "labTestRequired": false
  },
  "pulse": 72,
  "fetalHeartRate": 150,
  "nextVisitDate": "2024-02-25",
  "doctorNotes": "Patient is doing well, continue current care plan"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 505,
    "patientId": 123,
    "pregnancyRegistrationId": 456,
    "visitNumber": 1,
    "visitType": "First Visit",
    "visitDate": "2024-01-25T09:00:00Z",
    "gestationalAgeWeeks": 12,
    "gestationalAgeDays": 3,
    "heightCm": 165.0,
    "weightKg": 65.0,
    "bmi": 23.9,
    "weightGain": 2.5,
    "systolicBp": 120,
    "diastolicBp": 80,
    "temperature": 36.5,
    "bloodGroup": "A+",
    "hemoglobin": 11.5,
    "fundalHeight": 12.0,
    "bsr": 5.2,
    "albumin": "Negative",
    "muac": 25.0,
    "dangerSigns": "None",
    "pulse": 72,
    "fetalHeartRate": 150,
    "nextVisitDate": "2024-02-25",
    "doctorNotes": "Patient is doing well, continue current care plan",
    "createdAt": "2024-01-25T09:00:00Z",
    "updatedAt": "2024-01-25T09:00:00Z"
  },
  "message": "ANC record created successfully"
}
```

#### Get ANC Record by ID
```http
GET /anc-records/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 505,
    "patientId": 123,
    "pregnancyRegistrationId": 456,
    "visitNumber": 1,
    "visitType": "First Visit",
    "visitDate": "2024-01-25T09:00:00Z",
    "gestationalAgeWeeks": 12,
    "gestationalAgeDays": 3,
    "heightCm": 165.0,
    "weightKg": 65.0,
    "bmi": 23.9,
    "weightGain": 2.5,
    "systolicBp": 120,
    "diastolicBp": 80,
    "temperature": 36.5,
    "bloodGroup": "A+",
    "hemoglobin": 11.5,
    "fundalHeight": 12.0,
    "bsr": 5.2,
    "albumin": "Negative",
    "muac": 25.0,
    "dangerSigns": "None",
    "pulse": 72,
    "fetalHeartRate": 150,
    "nextVisitDate": "2024-02-25",
    "doctorNotes": "Patient is doing well, continue current care plan",
    "medicalConditions": [...],
    "obstetricHistory": [...],
    "ultrasoundRecord": {...},
    "supplements": [...],
    "referral": {...},
    "createdAt": "2024-01-25T09:00:00Z",
    "updatedAt": "2024-01-25T09:00:00Z"
  }
}
```

#### Update ANC Record
```http
PUT /anc-records/{id}
```

#### Delete ANC Record
```http
DELETE /anc-records/{id}
```

#### Get ANC Records by Patient ID
```http
GET /anc-records/patient/{patientId}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 505,
      "patientId": 123,
      "pregnancyRegistrationId": 456,
      "visitNumber": 1,
      "visitType": "First Visit",
      "visitDate": "2024-01-25T09:00:00Z",
      "gestationalAgeWeeks": 12,
      "gestationalAgeDays": 3,
      "heightCm": 165.0,
      "weightKg": 65.0,
      "bmi": 23.9,
      "weightGain": 2.5,
      "systolicBp": 120,
      "diastolicBp": 80,
      "temperature": 36.5,
      "bloodGroup": "A+",
      "hemoglobin": 11.5,
      "fundalHeight": 12.0,
      "bsr": 5.2,
      "albumin": "Negative",
      "muac": 25.0,
      "dangerSigns": "None",
      "pulse": 72,
      "fetalHeartRate": 150,
      "nextVisitDate": "2024-02-25",
      "doctorNotes": "Patient is doing well, continue current care plan",
      "createdAt": "2024-01-25T09:00:00Z",
      "updatedAt": "2024-01-25T09:00:00Z"
    }
  ],
  "total": 1
}
```

### 2. Medical Conditions Management

#### Add Medical Condition
```http
POST /anc-records/{ancRecordId}/medical-conditions
```

**Request Body:**
```json
{
  "conditionName": "Diabetes",
  "isPresent": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 606,
    "ancRecordId": 505,
    "conditionName": "Diabetes",
    "isPresent": true,
    "createdAt": "2024-01-25T09:00:00Z"
  },
  "message": "Medical condition added successfully"
}
```

#### Update Medical Condition
```http
PUT /anc-records/medical-conditions/{conditionId}
```

#### Delete Medical Condition
```http
DELETE /anc-records/medical-conditions/{conditionId}
```

### 3. Obstetric History Management

#### Add Obstetric History
```http
POST /anc-records/{ancRecordId}/obstetric-history
```

**Request Body:**
```json
{
  "conditionName": "Previous Cesarean",
  "isPresent": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 707,
    "ancRecordId": 505,
    "conditionName": "Previous Cesarean",
    "isPresent": true,
    "createdAt": "2024-01-25T09:00:00Z"
  },
  "message": "Obstetric history added successfully"
}
```

#### Update Obstetric History
```http
PUT /anc-records/obstetric-history/{historyId}
```

#### Delete Obstetric History
```http
DELETE /anc-records/obstetric-history/{historyId}
```

### 4. Ultrasound Records Management

#### Add Ultrasound Record
```http
POST /anc-records/{ancRecordId}/ultrasound
```

**Request Body:**
```json
{
  "ultrasoundConducted": true,
  "typeOfPregnancy": "Single",
  "fetalMovement": "Normal",
  "presentation": "Cephalic",
  "deliveryType": "Normal",
  "placenta": "Anterior",
  "placentaCondition": "Normal",
  "liquor": "Adequate",
  "fetalHeartRate": 150,
  "ultrasoundNotes": "Normal fetal development"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 808,
    "ancRecordId": 505,
    "ultrasoundConducted": true,
    "typeOfPregnancy": "Single",
    "fetalMovement": "Normal",
    "presentation": "Cephalic",
    "deliveryType": "Normal",
    "placenta": "Anterior",
    "placentaCondition": "Normal",
    "liquor": "Adequate",
    "fetalHeartRate": 150,
    "ultrasoundNotes": "Normal fetal development",
    "createdAt": "2024-01-25T09:00:00Z",
    "updatedAt": "2024-01-25T09:00:00Z"
  },
  "message": "Ultrasound record added successfully"
}
```

#### Update Ultrasound Record
```http
PUT /anc-records/ultrasound/{ultrasoundId}
```

#### Delete Ultrasound Record
```http
DELETE /anc-records/ultrasound/{ultrasoundId}
```

### 5. Supplements Management

#### Add Supplements
```http
POST /anc-records/{ancRecordId}/supplements
```

**Request Body:**
```json
{
  "supplements": [
    {
      "supplementName": "Folic Acid",
      "quantity": 1,
      "supplementsGiven": true
    },
    {
      "supplementName": "Iron Tablets",
      "quantity": 1,
      "supplementsGiven": true
    },
    {
      "supplementName": "Calcium",
      "quantity": 1,
      "supplementsGiven": true
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 909,
      "ancRecordId": 505,
      "supplementName": "Folic Acid",
      "quantity": 1,
      "supplementsGiven": true,
      "createdAt": "2024-01-25T09:00:00Z"
    },
    {
      "id": 910,
      "ancRecordId": 505,
      "supplementName": "Iron Tablets",
      "quantity": 1,
      "supplementsGiven": true,
      "createdAt": "2024-01-25T09:00:00Z"
    },
    {
      "id": 911,
      "ancRecordId": 505,
      "supplementName": "Calcium",
      "quantity": 1,
      "supplementsGiven": true,
      "createdAt": "2024-01-25T09:00:00Z"
    }
  ],
  "message": "Supplements added successfully"
}
```

#### Update Supplement
```http
PUT /anc-records/supplements/{supplementId}
```

#### Delete Supplement
```http
DELETE /anc-records/supplements/{supplementId}
```

### 6. Referrals Management

#### Add Referral
```http
POST /anc-records/{ancRecordId}/referrals
```

**Request Body:**
```json
{
  "patientReferred": true,
  "district": "Lahore",
  "referralType": "DHQ",
  "healthFacility": "Lahore General Hospital",
  "referralReason": "High-risk pregnancy requiring specialized care",
  "referralDate": "2024-01-25"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1010,
    "ancRecordId": 505,
    "patientReferred": true,
    "district": "Lahore",
    "referralType": "DHQ",
    "healthFacility": "Lahore General Hospital",
    "referralReason": "High-risk pregnancy requiring specialized care",
    "referralDate": "2024-01-25",
    "createdAt": "2024-01-25T09:00:00Z",
    "updatedAt": "2024-01-25T09:00:00Z"
  },
  "message": "Referral added successfully"
}
```

#### Update Referral
```http
PUT /anc-records/referrals/{referralId}
```

#### Delete Referral
```http
DELETE /anc-records/referrals/{referralId}
```

---

## Request/Response Models

### Common Response Structure
```json
{
  "success": boolean,
  "data": object | array,
  "message": string,
  "errors": array,
  "pagination": {
    "page": number,
    "limit": number,
    "total": number,
    "totalPages": number
  }
}
```

### Error Response Structure
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "lmpDate",
      "message": "LMP date is required",
      "code": "REQUIRED_FIELD"
    }
  ],
  "timestamp": "2024-01-25T09:00:00Z",
  "path": "/api/v1/pregnancy-registration"
}
```

### Validation Rules

#### Pregnancy Registration
- `patientId`: Required, must exist in patients table
- `lmpDate`: Required, valid date format (YYYY-MM-DD)
- `eddDate`: Required, valid date format (YYYY-MM-DD)
- `gravida`: Required, integer >= 0
- `husbandCnic`: Optional, valid CNIC format (XXXXX-XXXXXXX-X)
- `yearsMarried`: Optional, integer >= 0

#### ANC Records
- `patientId`: Required, must exist in patients table
- `visitNumber`: Required, integer >= 1
- `visitType`: Required, must be one of: "First Visit", "Follow-up", "Emergency"
- `gestationalAgeWeeks`: Required, integer between 0-42
- `gestationalAgeDays`: Required, integer between 0-6
- `bloodGroup`: Optional, must be one of: "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"

---

## Error Handling

### HTTP Status Codes

| Status Code | Description | Usage |
|-------------|-------------|-------|
| 200 | OK | Successful GET, PUT requests |
| 201 | Created | Successful POST requests |
| 400 | Bad Request | Invalid request data, validation errors |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate resource creation |
| 422 | Unprocessable Entity | Business logic validation errors |
| 500 | Internal Server Error | Server-side errors |

### Common Error Codes

| Error Code | Description |
|------------|-------------|
| `REQUIRED_FIELD` | Required field is missing |
| `INVALID_FORMAT` | Field format is invalid |
| `DUPLICATE_RESOURCE` | Resource already exists |
| `NOT_FOUND` | Resource not found |
| `UNAUTHORIZED` | Authentication required |
| `FORBIDDEN` | Insufficient permissions |
| `VALIDATION_ERROR` | Business logic validation failed |

---

## Authentication

### JWT Token Structure
```json
{
  "sub": "user_id",
  "iat": 1643123456,
  "exp": 1643209856,
  "role": "doctor",
  "permissions": ["pregnancy:read", "pregnancy:write", "anc:read", "anc:write"]
}
```

### Required Permissions

| Endpoint | Required Permission |
|----------|-------------------|
| Pregnancy Registration | `pregnancy:write` |
| ANC Records | `anc:write` |
| Read Operations | `pregnancy:read`, `anc:read` |
| Delete Operations | `pregnancy:delete`, `anc:delete` |

---

## Rate Limiting

### Rate Limits
- **General API**: 1000 requests per hour per user
- **Pregnancy Registration**: 100 requests per hour per user
- **ANC Records**: 200 requests per hour per user

### Rate Limit Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1643209856
```

---

## Testing Examples

### cURL Examples

#### Create Pregnancy Registration
```bash
curl -X POST "https://api.hms.com/v1/pregnancy-registration" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "patientId": 123,
    "lmpDate": "2024-01-15",
    "eddDate": "2024-10-22",
    "gravida": 2,
    "termPregnancies": 1,
    "pretermPregnancies": 0,
    "livingChildren": 1,
    "numberOfBoys": 1,
    "numberOfGirls": 0,
    "husbandName": "John Doe",
    "husbandCnic": "12345-1234567-1",
    "yearsMarried": 3,
    "consanguineousMarriage": "No"
  }'
```

#### Create ANC Record
```bash
curl -X POST "https://api.hms.com/v1/anc-records" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "patientId": 123,
    "pregnancyRegistrationId": 456,
    "visitNumber": 1,
    "visitType": "First Visit",
    "visitDate": "2024-01-25T09:00:00Z",
    "gestationalAgeWeeks": 12,
    "gestationalAgeDays": 3,
    "heightCm": 165.0,
    "weightKg": 65.0,
    "systolicBp": 120,
    "diastolicBp": 80,
    "bloodGroup": "A+",
    "hemoglobin": 11.5
  }'
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-01-XX | Initial API endpoints |
| 1.1 | 2024-01-XX | Added validation rules and error handling |
| 1.2 | 2024-01-XX | Added authentication and rate limiting |

---

## Support

For API support and questions:
- **Email**: api-support@hms.com
- **Documentation**: https://docs.hms.com/api
- **Status Page**: https://status.hms.com

**Document Created**: January 2024  
**Last Updated**: January 2024  
**API Version**: 1.2

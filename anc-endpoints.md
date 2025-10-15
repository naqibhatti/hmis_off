# ANC Page API Endpoints Documentation

## Overview
This document provides a comprehensive list of API endpoints required to replace hardcoded data with live backend data for the ANC (Antenatal Care) page in the HMS application.

---

## 🏥 1. ANC Visit Tab

### Visit Information
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/anc/visit-types` | Get visit type options | - | `["Routine", "Emergency", "Follow-up", "Initial"]` |
| POST | `/api/anc/visits` | Save visit information | `{patientId, visitDate, gestationalAgeWeeks, gestationalAgeDays, visitType}` | `{success: true, visitId: string}` |
| GET | `/api/anc/visits/{patientId}` | Get patient's visit history | - | `{visits: [{visitId, visitDate, visitType, ...}]}` |

### Maternal Assessment
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/anc/urine-protein-levels` | Get urine protein options | - | `["Negative", "Trace", "+1", "+2", "+3", "+4"]` |
| GET | `/api/anc/edema-severity` | Get edema assessment options | - | `["None", "Mild", "Moderate", "Severe"]` |
| POST | `/api/anc/maternal-assessment` | Save maternal assessment data | `{patientId, visitId, weight, bpSystolic, bpDiastolic, pulse, temperature, hemoglobin, urineProtein, edemaAssessment}` | `{success: true, assessmentId: string}` |

### Fetal Assessment
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/anc/fetal-movements` | Get fetal movement options | - | `["None", "Present", "Active", "Reduced"]` |
| GET | `/api/anc/fetal-presentations` | Get presentation options | - | `["Cephalic", "Breech", "Transverse", "Oblique"]` |
| GET | `/api/anc/fetal-positions` | Get position options | - | `["LOA", "ROA", "LOP", "ROP", "LOT", "ROT", "LSA", "RSA"]` |
| POST | `/api/anc/fetal-assessment` | Save fetal assessment data | `{patientId, visitId, fundalHeight, fetalHeartRate, fetalMovements, fetalPresentation, fetalPosition}` | `{success: true, assessmentId: string}` |

### Symptom Assessment
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/anc/symptom-severity` | Get severity options | - | `["None", "Mild", "Moderate", "Severe"]` |
| GET | `/api/anc/urinary-symptoms` | Get urinary symptom options | - | `["None", "Frequency", "Dysuria", "Incontinence"]` |
| GET | `/api/anc/symptom-checklist` | Get symptom checklist items | - | `["Visual Changes", "Abdominal Pain", "Vaginal Bleeding", "Vaginal Discharge", "Contractions", "Dizziness/Fainting", "Breathing Difficulty"]` |
| POST | `/api/anc/symptom-assessment` | Save symptom assessment data | `{patientId, visitId, nauseaVomiting, headaches, urinarySymptoms, symptomChecklist: {visualChanges, abdominalPain, vaginalBleeding, vaginalDischarge, contractions, dizzinessFainting, breathingDifficulty}}` | `{success: true, assessmentId: string}` |

### Pain Assessment
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/anc/pain-locations` | Get pain location options | - | `["None", "Head", "Abdomen", "Back", "Pelvic", "Chest", "Other"]` |
| GET | `/api/anc/pain-severity` | Get pain severity options | - | `["None", "Mild", "Moderate", "Severe"]` |
| POST | `/api/anc/pain-assessment` | Save pain assessment data | `{patientId, visitId, painLocation, painSeverity, painDuration, labTestRequired}` | `{success: true, assessmentId: string}` |

### Follow-up Planning
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/anc/follow-up` | Save follow-up planning data | `{patientId, visitId, nextVisitDate, notes}` | `{success: true, followUpId: string}` |

---

## 🤱 2. Pregnancy Info Tab

### Pregnancy Details
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/pregnancy/basic-info/{patientId}` | Get existing pregnancy information | - | `{lmp, gravida, para, abortion, gestationAge, edd, trimester, birthAddress}` |
| POST | `/api/pregnancy/basic-info` | Save pregnancy basic information | `{patientId, lmp, gravida, para, abortion, gestationAge, edd, trimester, birthAddress}` | `{success: true, pregnancyId: string}` |
| GET | `/api/pregnancy/gravida-para/{patientId}` | Get gravida/para history | - | `{gravida, para, abortion, livingChildren}` |
| POST | `/api/pregnancy/gravida-para` | Save gravida/para data | `{patientId, gravida, para, abortion, livingChildren}` | `{success: true, recordId: string}` |

### Husband Information
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/pregnancy/husband-info/{patientId}` | Get husband information | - | `{husbandName, husbandCnic, yearsMarried, consanguineousMarriage}` |
| POST | `/api/pregnancy/husband-info` | Save husband information | `{patientId, husbandName, husbandCnic, yearsMarried, consanguineousMarriage}` | `{success: true, husbandInfoId: string}` |

---

## 🏥 3. Medical History Tab

### Medical Conditions
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/medical-conditions` | Get available medical conditions list | - | `[{id, name, category, description}]` |
| GET | `/api/medical-conditions/{patientId}` | Get patient's medical conditions | - | `{conditions: [{conditionId, name, diagnosedDate, severity, notes}]}` |
| POST | `/api/medical-conditions` | Save patient's medical conditions | `{patientId, conditions: [{conditionId, diagnosedDate, severity, notes}]}` | `{success: true, recordId: string}` |

### Obstetric History
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/obstetric-history/{patientId}` | Get patient's obstetric history | - | `{history: [{pregnancyNumber, deliveryDate, outcome, complications, notes}]}` |
| POST | `/api/obstetric-history` | Save obstetric history | `{patientId, history: [{pregnancyNumber, deliveryDate, outcome, complications, notes}]}` | `{success: true, recordId: string}` |
| GET | `/api/obstetric-conditions` | Get available obstetric conditions | - | `[{id, name, category, description}]` |

---

## 📊 4. Vitals Tab

### Physical Measurements
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/vitals/{patientId}` | Get patient's vitals history | - | `{vitals: [{date, height, weight, bmi, weightGain, systolic, diastolic, temperature, bloodGroup, hemoglobin, fundalHeight, bsr, albumin, muac, dangerSigns}]}` |
| POST | `/api/vitals` | Save vitals data | `{patientId, height, weight, systolic, diastolic, temperature, bloodGroup, hemoglobin, fundalHeight, bsr, albumin, muac, dangerSigns}` | `{success: true, vitalsId: string}` |
| GET | `/api/blood-groups` | Get blood group options | - | `["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]` |

### Calculated Fields
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/vitals/calculate-bmi` | Calculate BMI from height/weight | `{height, weight}` | `{bmi: number, category: string}` |
| POST | `/api/vitals/calculate-weight-gain` | Calculate weight gain | `{currentWeight, prePregnancyWeight}` | `{weightGain: number, category: string}` |

---

## 🩺 5. Ultrasound Tab

### Ultrasound Data
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/ultrasound/{patientId}` | Get ultrasound history | - | `{ultrasounds: [{date, typeOfPregnancy, fetalMovement, presentation, deliveryType, placenta, placentaCondition, liquor, fetalHeartRate}]}` |
| POST | `/api/ultrasound` | Save ultrasound data | `{patientId, typeOfPregnancy, fetalMovement, presentation, deliveryType, placenta, placentaCondition, liquor, fetalHeartRate}` | `{success: true, ultrasoundId: string}` |
| GET | `/api/ultrasound/pregnancy-types` | Get pregnancy type options | - | `["Singleton", "Twins", "Triplets", "Multiple"]` |
| GET | `/api/ultrasound/fetal-movements` | Get fetal movement options | - | `["Active", "Normal", "Reduced", "Absent"]` |
| GET | `/api/ultrasound/presentations` | Get presentation options | - | `["Cephalic", "Breech", "Transverse", "Oblique"]` |
| GET | `/api/ultrasound/delivery-types` | Get delivery type options | - | `["Normal", "Cesarean", "Assisted"]` |
| GET | `/api/ultrasound/placenta-conditions` | Get placenta condition options | - | `["Normal", "Low-lying", "Previa", "Abruption"]` |
| GET | `/api/ultrasound/liquor-conditions` | Get liquor condition options | - | `["Normal", "Oligohydramnios", "Polyhydramnios"]` |

---

## 💊 6. Supplements Tab

### Supplements Management
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/supplements` | Get available supplements list | - | `[{id, name, category, description, dosageOptions}]` |
| GET | `/api/supplements/{patientId}` | Get patient's supplement history | - | `{supplements: [{supplementId, name, dosage, frequency, startDate, endDate, notes}]}` |
| POST | `/api/supplements` | Save supplement prescriptions | `{patientId, supplements: [{supplementId, dosage, frequency, startDate, endDate, notes}]}` | `{success: true, prescriptionId: string}` |
| GET | `/api/supplements/dosages` | Get dosage options for supplements | - | `[{supplementId, dosages: [string]}]` |

---

## 🏥 7. Referrals Tab

### Referral System
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/referrals/districts` | Get available districts | - | `["Bahawalnagar", "Bahawalpur", "Rahim Yar Khan", "Lahore", "Karachi", "Islamabad", "Rawalpindi", "Faisalabad", "Multan", "Peshawar"]` |
| GET | `/api/referrals/facility-types` | Get facility type options | - | `["DHQ", "THQ", "RHC", "BHU", "Private Hospital", "Specialist Clinic", "Teaching Hospital", "General Hospital"]` |
| GET | `/api/referrals/health-facilities` | Get health facilities by district/type | `?district={district}&type={type}` | `[{id, name, address, contact, type, district}]` |
| GET | `/api/referrals/{patientId}` | Get patient's referral history | - | `{referrals: [{referralId, date, district, facilityType, healthFacility, reason, status}]}` |
| POST | `/api/referrals` | Save referral data | `{patientId, district, facilityType, healthFacility, reason, urgency}` | `{success: true, referralId: string}` |

---

## 🔄 8. General Data Management

### Patient Data
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/patients/{patientId}/anc-summary` | Get complete ANC summary | - | `{patientInfo, pregnancyInfo, visitHistory, medicalHistory, vitals, ultrasound, supplements, referrals}` |
| POST | `/api/patients/{patientId}/anc-summary` | Save complete ANC data | `{pregnancyInfo, visitData, medicalHistory, vitals, ultrasound, supplements, referrals}` | `{success: true, summaryId: string}` |
| GET | `/api/patients/{patientId}/anc-visits` | Get all ANC visits | - | `{visits: [{visitId, date, type, status, summary}]}` |
| DELETE | `/api/anc/visits/{visitId}` | Delete specific visit | - | `{success: true, message: string}` |

### Lookup Data
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/lookup/medical-conditions` | Get all medical conditions | - | `[{id, name, category, icd10Code, description}]` |
| GET | `/api/lookup/symptoms` | Get all symptom options | - | `[{id, name, category, severityLevels}]` |
| GET | `/api/lookup/severity-levels` | Get severity level options | - | `["None", "Mild", "Moderate", "Severe", "Critical"]` |
| GET | `/api/lookup/measurement-units` | Get measurement unit options | - | `[{type, units: [string]}]` |

### Validation & Calculations
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/anc/validate-data` | Validate ANC form data | `{formData, validationRules}` | `{isValid: boolean, errors: [string], warnings: [string]}` |
| POST | `/api/anc/calculate-gestational-age` | Calculate gestational age from LMP | `{lmpDate, currentDate}` | `{gestationalAgeWeeks: number, gestationalAgeDays: number}` |
| POST | `/api/anc/calculate-edd` | Calculate expected due date | `{lmpDate}` | `{edd: date, gestationalAgeAtDelivery: number}` |
| POST | `/api/anc/risk-assessment` | Perform risk assessment | `{patientData, visitData}` | `{riskLevel: string, riskFactors: [string], recommendations: [string]}` |

---

## 📱 9. Real-time Features

### Notifications & Alerts
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/anc/alerts/{patientId}` | Get patient-specific alerts | - | `{alerts: [{alertId, type, message, severity, date, isRead}]}` |
| POST | `/api/anc/set-reminders` | Set follow-up reminders | `{patientId, reminderType, date, message}` | `{success: true, reminderId: string}` |
| GET | `/api/anc/upcoming-visits` | Get upcoming visit reminders | - | `{reminders: [{patientId, patientName, visitDate, visitType, urgency}]}` |

### Data Synchronization
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/anc/sync-offline-data` | Sync offline collected data | `{offlineData: [object]}` | `{synced: number, failed: number, errors: [string]}` |
| GET | `/api/anc/last-sync/{patientId}` | Get last sync timestamp | - | `{lastSync: timestamp, syncStatus: string}` |
| POST | `/api/anc/backup-data` | Backup ANC data | `{patientId, dataType}` | `{success: true, backupId: string}` |

---

## 🔐 10. Security & Access Control

### User Permissions
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/api/users/permissions` | Get user permissions for ANC features | - | `{permissions: {canView: boolean, canEdit: boolean, canDelete: boolean, canRefer: boolean}}` |
| POST | `/api/anc/audit-log` | Log ANC data access/modifications | `{action, patientId, userId, details}` | `{success: true, logId: string}` |
| GET | `/api/anc/access-history/{patientId}` | Get data access history | - | `{accessLog: [{userId, userName, action, timestamp, details}]}` |

---

## 🎯 Implementation Priority

### High Priority (Core Functionality)
1. **ANC Visit data endpoints** - Essential for daily operations
2. **Pregnancy Info endpoints** - Core patient data
3. **Vitals endpoints** - Critical health monitoring
4. **Basic lookup data endpoints** - Required for dropdowns

### Medium Priority (Enhanced Features)
1. **Medical History endpoints** - Important for comprehensive care
2. **Ultrasound endpoints** - Specialized diagnostic data
3. **Supplements endpoints** - Treatment management
4. **Referrals endpoints** - Care coordination

### Low Priority (Advanced Features)
1. **Real-time notifications** - Enhanced user experience
2. **Offline sync capabilities** - Field work support
3. **Advanced analytics** - Reporting and insights
4. **Audit logging** - Compliance and security

---

## 📋 Request/Response Examples

### Example: Save ANC Visit Data
```json
POST /api/anc/visits
{
  "patientId": "12345",
  "visitDate": "2024-01-15",
  "gestationalAgeWeeks": 28,
  "gestationalAgeDays": 3,
  "visitType": "Routine",
  "maternalAssessment": {
    "weight": 65.5,
    "bpSystolic": 120,
    "bpDiastolic": 80,
    "pulse": 72,
    "temperature": 36.8,
    "hemoglobin": 12.5,
    "urineProtein": "Negative",
    "edemaAssessment": "None"
  },
  "fetalAssessment": {
    "fundalHeight": 28,
    "fetalHeartRate": 140,
    "fetalMovements": "Active",
    "fetalPresentation": "Cephalic",
    "fetalPosition": "LOA"
  }
}
```

### Example: Get Patient ANC Summary
```json
GET /api/patients/12345/anc-summary
{
  "patientInfo": {
    "patientId": "12345",
    "name": "Sarah Ahmed",
    "age": 28,
    "cnic": "12345-1234567-1"
  },
  "pregnancyInfo": {
    "lmp": "2023-06-15",
    "edd": "2024-03-22",
    "gravida": 2,
    "para": 1,
    "abortion": 0
  },
  "visitHistory": [
    {
      "visitId": "v001",
      "date": "2024-01-15",
      "type": "Routine",
      "gestationalAge": "28w 3d"
    }
  ],
  "medicalHistory": {
    "conditions": ["Hypertension"],
    "obstetricHistory": ["Previous C-section"]
  }
}
```

---

## 🔧 Error Handling

All endpoints should return consistent error responses:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid gestational age",
    "details": {
      "field": "gestationalAgeWeeks",
      "value": 45,
      "constraint": "Must be between 0 and 42"
    }
  }
}
```

---

## 📊 Performance Considerations

1. **Pagination**: Use pagination for large datasets (visits, history)
2. **Caching**: Cache lookup data (conditions, symptoms, etc.)
3. **Batch Operations**: Support batch saves for multiple records
4. **Compression**: Use gzip compression for large responses
5. **Rate Limiting**: Implement rate limiting for API protection

---

*This document serves as a comprehensive guide for implementing the ANC page API integration. All endpoints should follow RESTful conventions and include proper authentication, validation, and error handling.*

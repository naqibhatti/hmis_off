# API Integration Setup Guide

This guide will help you set up the API integration between your Flutter app and the backend server.

## Prerequisites

1. Backend server running (HMIS-Prod)
2. Flutter app with HTTP dependencies (already included)

## Configuration Steps

### 1. Update Backend URL

Edit `lib/config/app_config.dart` and update the `backendBaseUrl`:

```dart
// For local development (if running backend locally)
static const String backendBaseUrl = 'http://localhost:7287/api';

// For Android emulator (if backend is on host machine)
static const String backendBaseUrl = 'http://10.0.2.2:7287/api';

// For production server
static const String backendBaseUrl = 'https://your-production-server.com/api';
```

### 2. Backend Server Requirements

Ensure your backend server is running and accessible. The following endpoints should be available:

- `POST /api/Patient` - Create new patient
- `GET /api/Patient/{id}` - Get patient by ID
- `GET /api/Patient/cnic/{cnic}` - Get patient by CNIC
- `GET /api/Patient/exists/{cnic}` - Check if patient exists
- `GET /api/Patient` - Search patients
- `PUT /api/Patient/{id}` - Update patient

### 3. CORS Configuration (if needed)

If you're testing with a web browser, ensure your backend has CORS configured to allow requests from your Flutter app.

### 4. Testing the Integration

1. Start your backend server
2. Update the backend URL in `app_config.dart`
3. Run the Flutter app
4. Navigate to "Add Patient" page
5. Fill in patient details and submit
6. Check your backend database to verify the patient was created

## Features Implemented

### ✅ Completed Features

1. **Patient Registration API Integration**
   - Create new patients via API
   - Proper error handling and loading states
   - Field mapping between frontend and backend

2. **Data Model Updates**
   - Updated `PatientData` model to match backend fields
   - Added backward compatibility getters
   - CNIC format conversion (display vs API)

3. **API Service Layer**
   - Complete CRUD operations for patients
   - Proper error handling
   - Timeout configuration
   - Response parsing

4. **UI Improvements**
   - Loading states during API calls
   - Error messages for failed requests
   - Success confirmations

### 🔄 Field Mapping

| Frontend Field | Backend Field | Notes |
|----------------|---------------|-------|
| `phone` | `contactNumber` | Legacy getter for backward compatibility |
| `emergencyContactName` | `emergencyContact` | Legacy getter for backward compatibility |
| `emergencyRelation` | `emergencyContactRelation` | Legacy getter for backward compatibility |
| `cnic` | `cnic` | Format conversion (12345-1234567-1 ↔ 1234512345671) |

### ⚠️ Known Limitations

1. **Family Management**: Not yet implemented (will be added later)
2. **Registration Type**: "Self" vs "Others" logic not sent to backend
3. **MRN Generation**: Backend handles MRN generation
4. **Offline Support**: Currently requires internet connection

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Check if backend server is running on port 7287
   - Verify the backend URL in `app_config.dart` (should be `http://localhost:7287/api`)
   - For Android emulator, use `10.0.2.2:7287` instead of `localhost:7287`

2. **CORS Errors (Web)**
   - Configure CORS in your backend to allow Flutter web requests
   - Add your Flutter app's domain to allowed origins

3. **Timeout Errors**
   - Increase timeout in `api_config.dart`
   - Check network connectivity
   - Verify backend server performance

4. **Validation Errors**
   - Check CNIC format (should be 13 digits without dashes for API)
   - Verify required fields are provided
   - Check email and phone number formats

### Debug Mode

Enable debug logging by setting `enableDebugLogging = true` in `app_config.dart`. This will help identify API issues.

## Next Steps

1. **Family Management APIs**: Implement family relationship management
2. **Offline Support**: Add local storage for offline functionality
3. **Authentication**: Integrate patient authentication system
4. **Advanced Search**: Implement comprehensive patient search
5. **Data Sync**: Add data synchronization between local and remote storage

## Support

If you encounter issues:

1. Check the console logs for detailed error messages
2. Verify backend server logs
3. Test API endpoints directly using tools like Postman
4. Ensure all required fields are provided in the correct format

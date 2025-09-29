import 'package:flutter/material.dart';

class Disease {
  final String name;
  final String category;
  final String description;
  final String icdCode;

  Disease({
    required this.name,
    required this.category,
    required this.description,
    required this.icdCode,
  });
}

class DiseasesService {
  static final List<Disease> _diseases = [
    // Cardiovascular Diseases
    Disease(
      name: 'Hypertension',
      category: 'Cardiovascular',
      description: 'High blood pressure',
      icdCode: 'I10',
    ),
    Disease(
      name: 'Coronary Artery Disease',
      category: 'Cardiovascular',
      description: 'Narrowing of coronary arteries',
      icdCode: 'I25.9',
    ),
    Disease(
      name: 'Myocardial Infarction',
      category: 'Cardiovascular',
      description: 'Heart attack',
      icdCode: 'I21.9',
    ),
    Disease(
      name: 'Atrial Fibrillation',
      category: 'Cardiovascular',
      description: 'Irregular heart rhythm',
      icdCode: 'I48.91',
    ),
    Disease(
      name: 'Heart Failure',
      category: 'Cardiovascular',
      description: 'Heart cannot pump blood effectively',
      icdCode: 'I50.9',
    ),

    // Respiratory Diseases
    Disease(
      name: 'Asthma',
      category: 'Respiratory',
      description: 'Chronic inflammatory airway disease',
      icdCode: 'J45.9',
    ),
    Disease(
      name: 'Chronic Obstructive Pulmonary Disease',
      category: 'Respiratory',
      description: 'COPD - progressive lung disease',
      icdCode: 'J44.9',
    ),
    Disease(
      name: 'Pneumonia',
      category: 'Respiratory',
      description: 'Infection of the lungs',
      icdCode: 'J18.9',
    ),
    Disease(
      name: 'Bronchitis',
      category: 'Respiratory',
      description: 'Inflammation of bronchial tubes',
      icdCode: 'J40',
    ),
    Disease(
      name: 'Tuberculosis',
      category: 'Respiratory',
      description: 'Bacterial infection of the lungs',
      icdCode: 'A15.9',
    ),

    // Endocrine Diseases
    Disease(
      name: 'Type 2 Diabetes Mellitus',
      category: 'Endocrine',
      description: 'High blood sugar levels',
      icdCode: 'E11.9',
    ),
    Disease(
      name: 'Type 1 Diabetes Mellitus',
      category: 'Endocrine',
      description: 'Insulin-dependent diabetes',
      icdCode: 'E10.9',
    ),
    Disease(
      name: 'Hypothyroidism',
      category: 'Endocrine',
      description: 'Underactive thyroid gland',
      icdCode: 'E03.9',
    ),
    Disease(
      name: 'Hyperthyroidism',
      category: 'Endocrine',
      description: 'Overactive thyroid gland',
      icdCode: 'E05.9',
    ),
    Disease(
      name: 'Obesity',
      category: 'Endocrine',
      description: 'Excessive body weight',
      icdCode: 'E66.9',
    ),

    // Gastrointestinal Diseases
    Disease(
      name: 'Gastroesophageal Reflux Disease',
      category: 'Gastrointestinal',
      description: 'GERD - acid reflux',
      icdCode: 'K21.9',
    ),
    Disease(
      name: 'Peptic Ulcer Disease',
      category: 'Gastrointestinal',
      description: 'Ulcers in stomach or duodenum',
      icdCode: 'K27.9',
    ),
    Disease(
      name: 'Irritable Bowel Syndrome',
      category: 'Gastrointestinal',
      description: 'IBS - digestive disorder',
      icdCode: 'K58.9',
    ),
    Disease(
      name: 'Hepatitis B',
      category: 'Gastrointestinal',
      description: 'Viral infection of the liver',
      icdCode: 'B16.9',
    ),
    Disease(
      name: 'Hepatitis C',
      category: 'Gastrointestinal',
      description: 'Viral infection of the liver',
      icdCode: 'B17.1',
    ),

    // Neurological Diseases
    Disease(
      name: 'Migraine',
      category: 'Neurological',
      description: 'Severe headache disorder',
      icdCode: 'G43.909',
    ),
    Disease(
      name: 'Epilepsy',
      category: 'Neurological',
      description: 'Seizure disorder',
      icdCode: 'G40.909',
    ),
    Disease(
      name: 'Parkinson\'s Disease',
      category: 'Neurological',
      description: 'Progressive nervous system disorder',
      icdCode: 'G20',
    ),
    Disease(
      name: 'Alzheimer\'s Disease',
      category: 'Neurological',
      description: 'Progressive dementia',
      icdCode: 'G30.9',
    ),
    Disease(
      name: 'Multiple Sclerosis',
      category: 'Neurological',
      description: 'Autoimmune disease affecting nerves',
      icdCode: 'G35',
    ),

    // Musculoskeletal Diseases
    Disease(
      name: 'Osteoarthritis',
      category: 'Musculoskeletal',
      description: 'Degenerative joint disease',
      icdCode: 'M19.9',
    ),
    Disease(
      name: 'Rheumatoid Arthritis',
      category: 'Musculoskeletal',
      description: 'Autoimmune joint disease',
      icdCode: 'M06.9',
    ),
    Disease(
      name: 'Osteoporosis',
      category: 'Musculoskeletal',
      description: 'Bone density loss',
      icdCode: 'M81.0',
    ),
    Disease(
      name: 'Fibromyalgia',
      category: 'Musculoskeletal',
      description: 'Chronic pain syndrome',
      icdCode: 'M79.3',
    ),
    Disease(
      name: 'Gout',
      category: 'Musculoskeletal',
      description: 'Uric acid crystal arthritis',
      icdCode: 'M10.9',
    ),

    // Infectious Diseases
    Disease(
      name: 'Malaria',
      category: 'Infectious',
      description: 'Mosquito-borne parasitic disease',
      icdCode: 'B54',
    ),
    Disease(
      name: 'Dengue Fever',
      category: 'Infectious',
      description: 'Mosquito-borne viral disease',
      icdCode: 'A90',
    ),
    Disease(
      name: 'COVID-19',
      category: 'Infectious',
      description: 'Coronavirus disease',
      icdCode: 'U07.1',
    ),
    Disease(
      name: 'Influenza',
      category: 'Infectious',
      description: 'Flu - viral respiratory infection',
      icdCode: 'J11.1',
    ),
    Disease(
      name: 'Hepatitis A',
      category: 'Infectious',
      description: 'Viral liver infection',
      icdCode: 'B15.9',
    ),

    // Mental Health
    Disease(
      name: 'Major Depressive Disorder',
      category: 'Mental Health',
      description: 'Clinical depression',
      icdCode: 'F32.9',
    ),
    Disease(
      name: 'Generalized Anxiety Disorder',
      category: 'Mental Health',
      description: 'Excessive anxiety and worry',
      icdCode: 'F41.1',
    ),
    Disease(
      name: 'Bipolar Disorder',
      category: 'Mental Health',
      description: 'Mood disorder with manic episodes',
      icdCode: 'F31.9',
    ),
    Disease(
      name: 'Post-Traumatic Stress Disorder',
      category: 'Mental Health',
      description: 'PTSD - trauma-related disorder',
      icdCode: 'F43.10',
    ),
    Disease(
      name: 'Obsessive-Compulsive Disorder',
      category: 'Mental Health',
      description: 'OCD - repetitive thoughts and behaviors',
      icdCode: 'F42',
    ),

    // Dermatological Diseases
    Disease(
      name: 'Eczema',
      category: 'Dermatological',
      description: 'Atopic dermatitis',
      icdCode: 'L30.9',
    ),
    Disease(
      name: 'Psoriasis',
      category: 'Dermatological',
      description: 'Autoimmune skin condition',
      icdCode: 'L40.9',
    ),
    Disease(
      name: 'Acne',
      category: 'Dermatological',
      description: 'Skin condition with pimples',
      icdCode: 'L70.9',
    ),
    Disease(
      name: 'Vitiligo',
      category: 'Dermatological',
      description: 'Loss of skin pigmentation',
      icdCode: 'L81.0',
    ),
    Disease(
      name: 'Dermatitis',
      category: 'Dermatological',
      description: 'Skin inflammation',
      icdCode: 'L30.9',
    ),

    // Urological Diseases
    Disease(
      name: 'Urinary Tract Infection',
      category: 'Urological',
      description: 'UTI - bacterial infection',
      icdCode: 'N39.0',
    ),
    Disease(
      name: 'Kidney Stones',
      category: 'Urological',
      description: 'Nephrolithiasis',
      icdCode: 'N20.0',
    ),
    Disease(
      name: 'Chronic Kidney Disease',
      category: 'Urological',
      description: 'Progressive kidney damage',
      icdCode: 'N18.6',
    ),
    Disease(
      name: 'Benign Prostatic Hyperplasia',
      category: 'Urological',
      description: 'BPH - enlarged prostate',
      icdCode: 'N40',
    ),
    Disease(
      name: 'Bladder Cancer',
      category: 'Urological',
      description: 'Malignant tumor of bladder',
      icdCode: 'C67.9',
    ),

    // Gynecological Diseases
    Disease(
      name: 'Polycystic Ovary Syndrome',
      category: 'Gynecological',
      description: 'PCOS - hormonal disorder',
      icdCode: 'E28.2',
    ),
    Disease(
      name: 'Endometriosis',
      category: 'Gynecological',
      description: 'Uterine tissue outside uterus',
      icdCode: 'N80.9',
    ),
    Disease(
      name: 'Uterine Fibroids',
      category: 'Gynecological',
      description: 'Non-cancerous uterine tumors',
      icdCode: 'D25.9',
    ),
    Disease(
      name: 'Cervical Cancer',
      category: 'Gynecological',
      description: 'Malignant tumor of cervix',
      icdCode: 'C53.9',
    ),
    Disease(
      name: 'Ovarian Cancer',
      category: 'Gynecological',
      description: 'Malignant tumor of ovary',
      icdCode: 'C56.9',
    ),

    // Pediatric Diseases
    Disease(
      name: 'Attention Deficit Hyperactivity Disorder',
      category: 'Pediatric',
      description: 'ADHD - neurodevelopmental disorder',
      icdCode: 'F90.9',
    ),
    Disease(
      name: 'Autism Spectrum Disorder',
      category: 'Pediatric',
      description: 'ASD - developmental disorder',
      icdCode: 'F84.0',
    ),
    Disease(
      name: 'Cerebral Palsy',
      category: 'Pediatric',
      description: 'Motor disability from brain damage',
      icdCode: 'G80.9',
    ),
    Disease(
      name: 'Down Syndrome',
      category: 'Pediatric',
      description: 'Genetic chromosomal disorder',
      icdCode: 'Q90.9',
    ),
    Disease(
      name: 'Cystic Fibrosis',
      category: 'Pediatric',
      description: 'Genetic disorder affecting lungs',
      icdCode: 'E84.9',
    ),
  ];

  static List<Disease> getAllDiseases() {
    return List.from(_diseases);
  }

  static List<Disease> searchDiseases(String query) {
    if (query.isEmpty) return _diseases;
    
    return _diseases.where((disease) {
      return disease.name.toLowerCase().contains(query.toLowerCase()) ||
             disease.category.toLowerCase().contains(query.toLowerCase()) ||
             disease.description.toLowerCase().contains(query.toLowerCase()) ||
             disease.icdCode.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  static List<String> getCategories() {
    return _diseases.map((disease) => disease.category).toSet().toList()..sort();
  }

  static List<Disease> getDiseasesByCategory(String category) {
    return _diseases.where((disease) => disease.category == category).toList();
  }
}

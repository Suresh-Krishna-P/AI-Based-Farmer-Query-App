/// Crop Diseases Dataset
class CropDiseasesDataset {
  /// Comprehensive crop diseases information
  static const String cropDiseasesData = """
# Comprehensive Crop Diseases Dataset

## Powdery Mildew
- **Affected Crops**: Grapes, Cucumbers
- **Symptoms**: White powdery fungus on leaves
- **Treatments**: Fungicides (Sulfur-based)
- **Prevention**: Proper spacing, avoid overhead watering

## Blight
- **Affected Crops**: Tomatoes, Potatoes
- **Symptoms**: Dark spots on leaves
- **Treatments**: Copper fungicides, removal of infected plants
- **Prevention**: Crop rotation, resistant varieties

## Downy Mildew
- **Affected Crops**: Lettuce, Onions
- **Symptoms**: Yellowing, wilting leaves
- **Treatments**: Fungicides (mancozeb)
- **Prevention**: Good air circulation, resistant varieties

## Rust
- **Affected Crops**: Wheat, Barley
- **Symptoms**: Orange or brown pustules
- **Treatments**: Fungicides, resistant varieties
- **Prevention**: Crop rotation, good drainage

## Fusarium Wilt
- **Affected Crops**: Tomatoes, Peppers
- **Symptoms**: Yellowing, wilting of leaves
- **Treatments**: Soil fumigation, resistant varieties
- **Prevention**: Good sanitation, use healthy seeds

## Root Rot
- **Affected Crops**: Various vegetables
- **Symptoms**: Wilting, blackened roots
- **Treatments**: Fungicide treatments
- **Prevention**: Proper drainage, avoid overwatering

## Anthracnose
- **Affected Crops**: Beans, Peppers
- **Symptoms**: Dark, sunken lesions on fruit
- **Treatments**: Fungicides, removal of infected plants
- **Prevention**: Crop rotation, use of resistant varieties

## Leaf Spot
- **Affected Crops**: Cucumbers, Lettuce
- **Symptoms**: Water-soaked spots
- **Treatments**: Copper fungicides
- **Prevention**: Avoid overhead watering, proper spacing

## Sclerotinia
- **Affected Crops**: Spinach, Lettuce
- **Symptoms**: Wilting, gray mold
- **Treatments**: Removal of affected plants, fungicides
- **Prevention**: Good air circulation, avoid overcrowding

## Viruses
- **Affected Crops**: Various crops
- **Symptoms**: Stunted growth, mottled leaves
- **Treatments**: No cure, remove infected plants
- **Prevention**: Use virus-free seeds, insect control

## Notes:
- Ensure all treatments are used according to manufacturer's instructions.
- Resistance can vary with different varieties; consult local agricultural extension services for best practices.
""";

  /// Get crop diseases data as a map
  static Map<String, dynamic> getCropDiseasesData() {
    return {
      'powdery_mildew': {
        'affected_crops': ['Grapes', 'Cucumbers'],
        'symptoms': 'White powdery fungus on leaves',
        'treatments': [
          'Fungicides (Sulfur-based)',
        ],
        'prevention': [
          'Proper spacing',
          'Avoid overhead watering',
        ],
      },
      'blight': {
        'affected_crops': ['Tomatoes', 'Potatoes'],
        'symptoms': 'Dark spots on leaves',
        'treatments': [
          'Copper fungicides',
          'Removal of infected plants',
        ],
        'prevention': [
          'Crop rotation',
          'Resistant varieties',
        ],
      },
      'downy_mildew': {
        'affected_crops': ['Lettuce', 'Onions'],
        'symptoms': 'Yellowing, wilting leaves',
        'treatments': [
          'Fungicides (mancozeb)',
        ],
        'prevention': [
          'Good air circulation',
          'Resistant varieties',
        ],
      },
      'rust': {
        'affected_crops': ['Wheat', 'Barley'],
        'symptoms': 'Orange or brown pustules',
        'treatments': [
          'Fungicides',
          'Resistant varieties',
        ],
        'prevention': [
          'Crop rotation',
          'Good drainage',
        ],
      },
      'fusarium_wilt': {
        'affected_crops': ['Tomatoes', 'Peppers'],
        'symptoms': 'Yellowing, wilting of leaves',
        'treatments': [
          'Soil fumigation',
          'Resistant varieties',
        ],
        'prevention': [
          'Good sanitation',
          'Use healthy seeds',
        ],
      },
      'root_rot': {
        'affected_crops': ['Various vegetables'],
        'symptoms': 'Wilting, blackened roots',
        'treatments': [
          'Fungicide treatments',
        ],
        'prevention': [
          'Proper drainage',
          'Avoid overwatering',
        ],
      },
      'anthracnose': {
        'affected_crops': ['Beans', 'Peppers'],
        'symptoms': 'Dark, sunken lesions on fruit',
        'treatments': [
          'Fungicides',
          'Removal of infected plants',
        ],
        'prevention': [
          'Crop rotation',
          'Use of resistant varieties',
        ],
      },
      'leaf_spot': {
        'affected_crops': ['Cucumbers', 'Lettuce'],
        'symptoms': 'Water-soaked spots',
        'treatments': [
          'Copper fungicides',
        ],
        'prevention': [
          'Avoid overhead watering',
          'Proper spacing',
        ],
      },
      'sclerotinia': {
        'affected_crops': ['Spinach', 'Lettuce'],
        'symptoms': 'Wilting, gray mold',
        'treatments': [
          'Removal of affected plants',
          'Fungicides',
        ],
        'prevention': [
          'Good air circulation',
          'Avoid overcrowding',
        ],
      },
      'viruses': {
        'affected_crops': ['Various crops'],
        'symptoms': 'Stunted growth, mottled leaves',
        'treatments': [
          'No cure',
          'Remove infected plants',
        ],
        'prevention': [
          'Use virus-free seeds',
          'Insect control',
        ],
      },
    };
  }

  /// Get specific disease information
  static Map<String, dynamic> getDiseaseInfo(String diseaseName) {
    final data = getCropDiseasesData();
    return data[diseaseName.toLowerCase()] ?? {};
  }

  /// Get all disease names
  static List<String> getDiseaseNames() {
    return [
      'Powdery Mildew',
      'Blight',
      'Downy Mildew',
      'Rust',
      'Fusarium Wilt',
      'Root Rot',
      'Anthracnose',
      'Leaf Spot',
      'Sclerotinia',
      'Viruses',
    ];
  }
}

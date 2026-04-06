/// Pest Management Dataset
class PestManagementDataset {
  /// Comprehensive pest management information
  static const String pestManagementData = """
# Pest Management Dataset

## 1. Armyworm
- **Identification**: Armyworms are caterpillars that are usually green or brown, with stripes running along their bodies.
- **Damage**: They feed on a variety of crops, including corn and grass, and can cause significant damage to young plants.
- **Control Methods**: Use insecticides, biological control agents like parasitic wasps, and maintain good crop management practices.

## 2. Stemborers
- **Identification**: Larvae bore into the stems of plants causing wilting. They are typically yellowish and have a cylindrical shape.
- **Damage**: Damage includes stunted growth, wilting, and potential plant death.
- **Control Methods**: Use resistant plant varieties and practice crop rotation.

## 3. Whiteflies
- **Identification**: Small flying insects usually found on the underside of leaves, are white and resemble tiny moths.
- **Damage**: They can cause yellowing of leaves and promote the growth of sooty mold.
- **Control Methods**: Use insecticidal soaps, yellow sticky traps, and introduce natural predators like ladybugs.

## 4. Mites
- **Identification**: Tiny pests, often found on leaf undersides, are usually red or green in color.
- **Damage**: They suck plant juices, leading to leaf discoloration and damage.
- **Control Methods**: Apply miticides and encourage beneficial insects.

## 5. Bollworms
- **Identification**: Larvae of moths, usually green or brown. They can be found inside the bolls of cotton plants.
- **Damage**: They feed on the cotton bolls, significantly reducing yields.
- **Control Methods**: Use Bacillus thuringiensis (Bt) cotton and apply insecticides when necessary.

## 6. Leafhoppers
- **Identification**: Small, wedge-shaped insects that jump when disturbed, often green or yellow.
- **Damage**: They can cause leaf yellowing and stunt growth of plants due to sap feeding.
- **Control Methods**: Use insecticidal soaps and maintain healthy crops to resist infestations.

## 7. Fruit Flies
- **Identification**: Small flies that often hover around fruits, with red eyes and yellow-brown bodies.
- **Damage**: Larvae feed on fruits, leading to decay and loss of marketability.
- **Control Methods**: Use protein bait and traps, along with proper sanitation.

## 8. Grasshoppers
- **Identification**: Large insects with long jumping legs, usually green or brown.
- **Damage**: They feed on various crops and can strip entire fields bare.
- **Control Methods**: Use insecticides and encourage natural predators such as birds.
""";

  /// Get pest management data as a map
  static Map<String, dynamic> getPestManagementData() {
    return {
      'armyworm': {
        'identification': 'Caterpillars that are usually green or brown, with stripes running along their bodies',
        'damage': 'Feed on a variety of crops, including corn and grass, causing significant damage to young plants',
        'control_methods': [
          'Use insecticides',
          'Biological control agents like parasitic wasps',
          'Maintain good crop management practices',
        ],
      },
      'stemborers': {
        'identification': 'Larvae bore into the stems of plants causing wilting, typically yellowish and cylindrical',
        'damage': 'Stunted growth, wilting, and potential plant death',
        'control_methods': [
          'Use resistant plant varieties',
          'Practice crop rotation',
        ],
      },
      'whiteflies': {
        'identification': 'Small flying insects found on leaf undersides, white and moth-like',
        'damage': 'Yellowing of leaves and promotion of sooty mold growth',
        'control_methods': [
          'Use insecticidal soaps',
          'Yellow sticky traps',
          'Introduce natural predators like ladybugs',
        ],
      },
      'mites': {
        'identification': 'Tiny pests found on leaf undersides, usually red or green',
        'damage': 'Suck plant juices, leading to leaf discoloration and damage',
        'control_methods': [
          'Apply miticides',
          'Encourage beneficial insects',
        ],
      },
      'bollworms': {
        'identification': 'Larvae of moths, usually green or brown, found inside cotton bolls',
        'damage': 'Feed on cotton bolls, significantly reducing yields',
        'control_methods': [
          'Use Bacillus thuringiensis (Bt) cotton',
          'Apply insecticides when necessary',
        ],
      },
      'leafhoppers': {
        'identification': 'Small, wedge-shaped insects that jump when disturbed, often green or yellow',
        'damage': 'Leaf yellowing and stunted growth due to sap feeding',
        'control_methods': [
          'Use insecticidal soaps',
          'Maintain healthy crops to resist infestations',
        ],
      },
      'fruit_flies': {
        'identification': 'Small flies that hover around fruits, with red eyes and yellow-brown bodies',
        'damage': 'Larvae feed on fruits, leading to decay and loss of marketability',
        'control_methods': [
          'Use protein bait and traps',
          'Proper sanitation',
        ],
      },
      'grasshoppers': {
        'identification': 'Large insects with long jumping legs, usually green or brown',
        'damage': 'Feed on various crops and can strip entire fields bare',
        'control_methods': [
          'Use insecticides',
          'Encourage natural predators such as birds',
        ],
      },
    };
  }

  /// Get specific pest information
  static Map<String, dynamic> getPestInfo(String pestName) {
    final data = getPestManagementData();
    return data[pestName.toLowerCase()] ?? {};
  }

  /// Get all pest names
  static List<String> getPestNames() {
    return [
      'Armyworm',
      'Stemborers', 
      'Whiteflies',
      'Mites',
      'Bollworms',
      'Leafhoppers',
      'Fruit Flies',
      'Grasshoppers',
    ];
  }
}

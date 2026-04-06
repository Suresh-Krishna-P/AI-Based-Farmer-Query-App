class CropYieldData {
  final String crop;
  final double yieldPerHectare;
  final String season;
  final String region;
  final String source;
  final DateTime? lastUpdated;

  CropYieldData({
    required this.crop,
    required this.yieldPerHectare,
    required this.season,
    required this.region,
    required this.source,
    this.lastUpdated,
  });

  factory CropYieldData.fromJson(Map<String, dynamic> json) {
    return CropYieldData(
      crop: json['crop'] ?? '',
      yieldPerHectare: (json['yield_per_hectare'] ?? 0).toDouble(),
      season: json['season'] ?? '',
      region: json['region'] ?? '',
      source: json['source'] ?? '',
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'yield_per_hectare': yieldPerHectare,
      'season': season,
      'region': region,
      'source': source,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

class PestDiseaseData {
  final String pestName;
  final String description;
  final List<String> controlMethods;
  final String source;
  final DateTime? lastUpdated;

  PestDiseaseData({
    required this.pestName,
    required this.description,
    required this.controlMethods,
    required this.source,
    this.lastUpdated,
  });

  factory PestDiseaseData.fromJson(Map<String, dynamic> json) {
    var rawMethods = json['control_methods'];
    List<String> parsedMethods = [];
    if (rawMethods is List) {
      parsedMethods = rawMethods.map((e) => e.toString()).toList();
    } else if (rawMethods is String) {
      // Sometimes stored as comma separated string in DB
      parsedMethods = rawMethods.split(',').map((e) => e.trim()).toList();
    }

    return PestDiseaseData(
      pestName: json['pest_name'] ?? '',
      description: json['description'] ?? '',
      controlMethods: parsedMethods,
      source: json['source'] ?? '',
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pest_name': pestName,
      'description': description,
      'control_methods': controlMethods.join(','), // Storing as CSV in local DB for simplicity
      'source': source,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

class MarketPriceData {
  final String market;
  final double price;
  final String date;
  final String variety;
  final String source;
  final DateTime? lastUpdated;

  MarketPriceData({
    required this.market,
    required this.price,
    required this.date,
    required this.variety,
    required this.source,
    this.lastUpdated,
  });

  factory MarketPriceData.fromJson(Map<String, dynamic> json) {
    return MarketPriceData(
      market: json['market'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      variety: json['variety'] ?? '',
      source: json['source'] ?? '',
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'market': market,
      'price': price,
      'date': date,
      'variety': variety,
      'source': source,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

class SoilData {
  final String soilType;
  final double phLevel;
  final double organicMatter;
  final String source;
  final DateTime? lastUpdated;

  SoilData({
    required this.soilType,
    required this.phLevel,
    required this.organicMatter,
    required this.source,
    this.lastUpdated,
  });

  factory SoilData.fromJson(Map<String, dynamic> json) {
    return SoilData(
      soilType: json['soil_type'] ?? '',
      phLevel: (json['ph_level'] ?? 0).toDouble(),
      organicMatter: (json['organic_matter'] ?? 0).toDouble(),
      source: json['source'] ?? '',
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soil_type': soilType,
      'ph_level': phLevel,
      'organic_matter': organicMatter,
      'source': source,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

class AgroQAData {
  final int? id;
  final String crop;
  final String question;
  final String answer;

  AgroQAData({
    this.id,
    required this.crop,
    required this.question,
    required this.answer,
  });

  factory AgroQAData.fromJson(Map<String, dynamic> json) {
    return AgroQAData(
      id: json['id'],
      crop: json['crop'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop': crop,
      'question': question,
      'answer': answer,
    };
  }
}

class CropRecommendation {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;
  final String label;

  CropRecommendation({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
    required this.label,
  });

  factory CropRecommendation.fromCsv(List<dynamic> row) {
    return CropRecommendation(
      nitrogen: double.tryParse(row[0].toString()) ?? 0.0,
      phosphorus: double.tryParse(row[1].toString()) ?? 0.0,
      potassium: double.tryParse(row[2].toString()) ?? 0.0,
      temperature: double.tryParse(row[3].toString()) ?? 0.0,
      humidity: double.tryParse(row[4].toString()) ?? 0.0,
      ph: double.tryParse(row[5].toString()) ?? 0.0,
      rainfall: double.tryParse(row[6].toString()) ?? 0.0,
      label: row[7].toString(),
    );
  }
}

class FertilizerRecommendation {
  final String soilType;
  final String cropType;
  final double nitrogen;
  final double potassium;
  final double phosphorus;
  final String fertilizerName;

  FertilizerRecommendation({
    required this.soilType,
    required this.cropType,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorus,
    required this.fertilizerName,
  });

  factory FertilizerRecommendation.fromCsv(List<dynamic> row) {
    return FertilizerRecommendation(
      cropType: row[0].toString(),
      soilType: row[1].toString(),
      nitrogen: double.tryParse(row[2].toString()) ?? 0.0,
      phosphorus: double.tryParse(row[3].toString()) ?? 0.0,
      potassium: double.tryParse(row[4].toString()) ?? 0.0,
      fertilizerName: row[5].toString(),
    );
  }
}

class PestTreatment {
  final String crop;
  final String pestOrDisease;
  final String symptoms;
  final String treatment;
  final String organicControl;

  PestTreatment({
    required this.crop,
    required this.pestOrDisease,
    required this.symptoms,
    required this.treatment,
    required this.organicControl,
  });

  factory PestTreatment.fromCsv(List<dynamic> row) {
    return PestTreatment(
      crop: row[0].toString(),
      pestOrDisease: row[1].toString(),
      symptoms: row[2].toString(),
      treatment: row[3].toString(),
      organicControl: row[4].toString(),
    );
  }
}

class SeedVariety {
  final String crop;
  final String variety;
  final String duration;
  final String estimatedYield;
  final String specialFeatures;

  SeedVariety({
    required this.crop,
    required this.variety,
    required this.duration,
    required this.estimatedYield,
    required this.specialFeatures,
  });

  factory SeedVariety.fromCsv(List<dynamic> row) {
    return SeedVariety(
      crop: row[0].toString(),
      variety: row[1].toString(),
      duration: row[2].toString(),
      estimatedYield: row[3].toString() ?? 'N/A',
      specialFeatures: row[4].toString(),
    );
  }
}

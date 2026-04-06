/// Comprehensive Tamil Nadu Agriculture Dataset
class TamilNaduAgricultureDataset {
  /// Major crops grown in Tamil Nadu with regional data
  static final Map<String, dynamic> majorCrops = {
    'rice': {
      'scientific_name': 'Oryza sativa',
      'regions': ['Thanjavur', 'Tiruvarur', 'Nagapattinam', 'Cuddalore', 'Kancheepuram'],
      'seasons': ['Kuruvai (June-July)', 'Samba (August-September)', 'Thaladi (October-November)'],
      'average_yield': {'kuruvai': 4.5, 'samba': 5.2, 'thaladi': 4.8}, // tons per hectare
      'water_requirement': 'High (1500-2500 mm)',
      'common_pests': ['Stem borer', 'Leaf folder', 'Gundhi bug', 'Brown plant hopper'],
      'common_diseases': ['Blast', 'Bacterial leaf blight', 'Sheath blight', 'Tungro'],
      'fertilizer_recommendations': {
        'nitrogen': '120-150 kg/ha',
        'phosphorus': '60-80 kg/ha', 
        'potassium': '60-80 kg/ha',
      },
      'harvest_period': '3-6 months depending on variety',
      'market_price_range': '₹1800-₹2200 per quintal',
    },
    'coconut': {
      'scientific_name': 'Cocos nucifera',
      'regions': ['Thanjavur', 'Tiruvarur', 'Nagapattinam', 'Cuddalore', 'Kanyakumari'],
      'varieties': ['Tall varieties', 'Dwarf varieties', 'Hybrid varieties'],
      'average_yield': {'tall': 60-80, 'dwarf': 80-100, 'hybrid': 100-120}, // nuts per tree per year
      'water_requirement': 'Moderate (1000-1500 mm)',
      'common_pests': ['Red palm weevil', 'Rhino beetle', 'Coconut mite'],
      'common_diseases': ['Root wilt', 'Leaf rot', 'Bud rot'],
      'fertilizer_recommendations': {
        'organic': '50 kg FYM + 1.2 kg N + 0.75 kg P + 2.0 kg K per tree',
      },
      'harvest_period': '12-14 months after flowering',
      'market_price_range': '₹15-₹25 per nut',
    },
    'banana': {
      'scientific_name': 'Musa paradisiaca',
      'regions': ['Theni', 'Madurai', 'Virudhunagar', 'Tirunelveli', 'Kanyakumari'],
      'varieties': ['Robusta', 'Grand Naine', 'Nendran', 'Poovan'],
      'average_yield': {'robusta': 30-40, 'grand_naine': 40-50, 'nendran': 25-35}, // kg per plant
      'water_requirement': 'High (1200-1500 mm)',
      'common_pests': ['Banana weevil', 'Aphids', 'Nematodes'],
      'common_diseases': ['Panama wilt', 'Sigatoka leaf spot', 'Bunchy top'],
      'fertilizer_recommendations': {
        'nitrogen': '200-250 g per plant',
        'phosphorus': '100-150 g per plant',
        'potassium': '300-400 g per plant',
      },
      'harvest_period': '12-15 months',
      'market_price_range': '₹20-₹40 per dozen',
    },
    'sugarcane': {
      'scientific_name': 'Saccharum officinarum',
      'regions': ['Coimbatore', 'Erode', 'Tiruppur', 'Karur', 'Namakkal'],
      'varieties': ['Co 86032', 'Co 005', 'Co 8011', 'Co 8013'],
      'average_yield': {'co_86032': 120, 'co_005': 100, 'co_8011': 110}, // tons per hectare
      'water_requirement': 'Very high (1500-2500 mm)',
      'common_pests': ['Sugarcane borers', 'Termites', 'Mealybugs'],
      'common_diseases': ['Red rot', 'Smut', 'Grassy shoot'],
      'fertilizer_recommendations': {
        'nitrogen': '200-250 kg/ha',
        'phosphorus': '60-80 kg/ha',
        'potassium': '100-120 kg/ha',
      },
      'harvest_period': '12-18 months',
      'market_price_range': '₹280-₹320 per quintal',
    },
    'cotton': {
      'scientific_name': 'Gossypium hirsutum',
      'regions': ['Coimbatore', 'Erode', 'Tiruppur', 'Karur', 'Namakkal'],
      'varieties': ['Hybrid varieties', 'Desi varieties', 'American varieties'],
      'average_yield': {'hybrid': 15-20, 'desi': 8-12, 'american': 12-16}, // quintals per hectare
      'water_requirement': 'Moderate (600-800 mm)',
      'common_pests': ['Bollworm', 'Aphids', 'Whitefly', 'Jassids'],
      'common_diseases': ['Fusarium wilt', 'Bacterial blight', 'Leaf curl'],
      'fertilizer_recommendations': {
        'nitrogen': '100-120 kg/ha',
        'phosphorus': '60-80 kg/ha',
        'potassium': '60-80 kg/ha',
      },
      'harvest_period': '180-210 days',
      'market_price_range': '₹5500-₹6500 per quintal',
    },
    'turmeric': {
      'scientific_name': 'Curcuma longa',
      'regions': ['Erode', 'Salem', 'Namakkal', 'Dharmapuri', 'Krishnagiri'],
      'varieties': ['Erode local', 'Salem local', 'Alleppey finger'],
      'average_yield': {'erode': 25-30, 'salem': 20-25, 'alleppey': 30-35}, // quintals per hectare
      'water_requirement': 'Moderate (750-1000 mm)',
      'common_pests': ['Shoot borer', 'Rhizome scale', 'Leaf roller'],
      'common_diseases': ['Leaf spot', 'Rhizome rot', 'Bacterial wilt'],
      'fertilizer_recommendations': {
        'organic': '25 tons FYM + 100 kg N + 50 kg P + 100 kg K per hectare',
      },
      'harvest_period': '7-9 months',
      'market_price_range': '₹8000-₹12000 per quintal',
    },
    'mango': {
      'scientific_name': 'Mangifera indica',
      'regions': ['Salem', 'Krishnagiri', 'Dharmapuri', 'Coimbatore', 'Theni'],
      'varieties': ['Alphonso', 'Bangalora', 'Neelum', 'Mallika'],
      'average_yield': {'alphonso': 15-20, 'bangalora': 20-25, 'neelum': 25-30}, // kg per tree
      'water_requirement': 'Moderate (800-1200 mm)',
      'common_pests': ['Mango hopper', 'Fruit fly', 'Mealybug'],
      'common_diseases': ['Anthracnose', 'Powdery mildew', 'Mango malformation'],
      'fertilizer_recommendations': {
        'young_tree': '10 kg FYM + 200 g N + 100 g P + 150 g K per year',
        'bearing_tree': '25 kg FYM + 1 kg N + 0.5 kg P + 1.5 kg K per year',
      },
      'harvest_period': '4-6 years for bearing, 3-4 months after flowering',
      'market_price_range': '₹40-₹120 per kg depending on variety',
    },
  };

  /// Tamil Nadu soil types and characteristics
  static final Map<String, dynamic> soilTypes = {
    'red_soil': {
      'regions': ['Coimbatore', 'Erode', 'Salem', 'Namakkal', 'Dharmapuri'],
      'characteristics': {
        'texture': 'Sandy loam to clay loam',
        'ph_range': '5.5-7.5',
        'organic_matter': 'Low (0.5-1.0%)',
        'drainage': 'Good',
        'fertility': 'Moderate',
      },
      'suitable_crops': ['Millets', 'Pulses', 'Oilseeds', 'Cotton', 'Sugarcane'],
      'improvement_methods': [
        'Add organic matter (FYM, compost)',
        'Use green manuring crops',
        'Apply lime if pH is too low',
        'Practice crop rotation',
      ],
    },
    'black_soil': {
      'regions': ['Thanjavur', 'Tiruvarur', 'Nagapattinam', 'Cuddalore'],
      'characteristics': {
        'texture': 'Clayey',
        'ph_range': '7.0-8.5',
        'organic_matter': 'Moderate (1.0-1.5%)',
        'drainage': 'Poor to moderate',
        'fertility': 'High',
      },
      'suitable_crops': ['Rice', 'Sugarcane', 'Cotton', 'Pulses', 'Oilseeds'],
      'improvement_methods': [
        'Improve drainage',
        'Add organic matter',
        'Use gypsum for sodic soils',
        'Practice proper tillage',
      ],
    },
    'laterite_soil': {
      'regions': ['Kanyakumari', 'Tirunelveli', 'Theni', 'Madurai'],
      'characteristics': {
        'texture': 'Sandy loam',
        'ph_range': '4.5-6.5',
        'organic_matter': 'Low (0.5-0.8%)',
        'drainage': 'Excellent',
        'fertility': 'Low',
      },
      'suitable_crops': ['Cashew', 'Rubber', 'Tea', 'Coffee', 'Spices'],
      'improvement_methods': [
        'Add organic matter',
        'Apply lime to reduce acidity',
        'Use rock phosphate',
        'Practice agroforestry',
      ],
    },
    'alluvial_soil': {
      'regions': ['Cauvery Delta', 'Penna River basin', 'Vaigai River basin'],
      'characteristics': {
        'texture': 'Loamy',
        'ph_range': '6.5-7.5',
        'organic_matter': 'Moderate (1.0-2.0%)',
        'drainage': 'Good',
        'fertility': 'High',
      },
      'suitable_crops': ['Rice', 'Vegetables', 'Flowers', 'Fruits'],
      'improvement_methods': [
        'Maintain organic matter levels',
        'Practice crop rotation',
        'Use balanced fertilization',
        'Implement soil conservation',
      ],
    },
  };

  /// Tamil Nadu climate zones and weather patterns
  static final Map<String, dynamic> climateZones = {
    'coastal': {
      'regions': ['Chennai', 'Cuddalore', 'Nagapattinam', 'Tiruvarur', 'Kanyakumari'],
      'temperature_range': '25-35°C',
      'rainfall': '1000-1500 mm annually',
      'monsoon_pattern': 'Northeast monsoon (Oct-Dec) major, Southwest monsoon (Jun-Sep) minor',
      'suitable_crops': ['Rice', 'Coconut', 'Banana', 'Mango', 'Vegetables'],
      'challenges': ['Salinity', 'Waterlogging', 'Cyclones'],
      'adaptation_strategies': [
        'Use salt-tolerant varieties',
        'Improve drainage systems',
        'Plant windbreaks',
        'Practice mixed cropping',
      ],
    },
    'interior': {
      'regions': ['Coimbatore', 'Erode', 'Salem', 'Tiruppur', 'Karur'],
      'temperature_range': '20-40°C',
      'rainfall': '600-1000 mm annually',
      'monsoon_pattern': 'Both monsoons contribute equally',
      'suitable_crops': ['Cotton', 'Sugarcane', 'Turmeric', 'Millets', 'Pulses'],
      'challenges': ['Drought', 'High temperatures', 'Soil erosion'],
      'adaptation_strategies': [
        'Implement water conservation',
        'Use drought-resistant varieties',
        'Practice rainwater harvesting',
        'Adopt drip irrigation',
      ],
    },
    'hill_zones': {
      'regions': ['Nilgiris', 'Kodaikanal', 'Yercaud', 'Courtallam'],
      'temperature_range': '15-25°C',
      'rainfall': '1500-2500 mm annually',
      'monsoon_pattern': 'Both monsoons, higher rainfall',
      'suitable_crops': ['Tea', 'Coffee', 'Spices', 'Fruits', 'Flowers'],
      'challenges': ['Landslides', 'Frost', 'High humidity diseases'],
      'adaptation_strategies': [
        'Terrace farming',
        'Use disease-resistant varieties',
        'Implement proper drainage',
        'Practice agroforestry',
      ],
    },
    'arid': {
      'regions': ['Madurai', 'Theni', 'Ramanathapuram', 'Virudhunagar'],
      'temperature_range': '25-45°C',
      'rainfall': '400-800 mm annually',
      'monsoon_pattern': 'Northeast monsoon primary',
      'suitable_crops': ['Millets', 'Pulses', 'Oilseeds', 'Date palm', 'Arid vegetables'],
      'challenges': ['Water scarcity', 'High evaporation', 'Soil salinity'],
      'adaptation_strategies': [
        'Rainwater harvesting',
        'Drought-resistant crops',
        'Mulching',
        'Micro-irrigation',
      ],
    },
  };

  /// Common pests and diseases in Tamil Nadu
  static final Map<String, dynamic> commonPests = {
    'rice_stem_borer': {
      'scientific_name': 'Chilo suppressalis',
      'affected_crops': ['Rice'],
      'symptoms': ['Dead hearts', 'White ears', 'Hollow stems'],
      'life_cycle': 'Egg → Larva → Pupa → Adult (30-45 days)',
      'natural_predators': ['Trichogramma wasps', 'Spiders', 'Dragonflies'],
      'chemical_control': ['Cartap hydrochloride', 'Fenitrothion', 'Monocrotophos'],
      'organic_control': ['Neem oil', 'Bt spray', 'Light traps'],
      'preventive_measures': [
        'Use resistant varieties',
        'Proper water management',
        'Field sanitation',
        'Timely planting',
      ],
    },
    'coconut_red_palm_weevil': {
      'scientific_name': 'Rhynchophorus ferrugineus',
      'affected_crops': ['Coconut', 'Palmyra', 'Date palm'],
      'symptoms': ['Holes in trunk', 'Oozing of brown fluid', 'Crown drying'],
      'life_cycle': 'Egg → Larva → Pupa → Adult (60-90 days)',
      'natural_predators': ['Beetle predators', 'Ants', 'Birds'],
      'chemical_control': ['Monocrotophos', 'Chlorpyrifos', 'Fenthion'],
      'organic_control': ['Pheromone traps', 'Neem cake', 'Biological control agents'],
      'preventive_measures': [
        'Remove affected palms',
        'Avoid mechanical injuries',
        'Use healthy planting material',
        'Regular monitoring',
      ],
    },
    'banana_bunchy_top': {
      'scientific_name': 'Banana bunchy top virus',
      'affected_crops': ['Banana'],
      'symptoms': ['Stunted growth', 'Narrow leaves', 'Bunched appearance'],
      'transmission': 'Aphids (Pentalonia nigronervosa)',
      'natural_predators': ['Lady beetles', 'Lacewings', 'Parasitic wasps'],
      'chemical_control': ['Imidacloprid', 'Thiamethoxam', 'Acetamiprid'],
      'organic_control': ['Neem oil', 'Yellow sticky traps', 'Biological control'],
      'preventive_measures': [
        'Use disease-free planting material',
        'Rogue out infected plants',
        'Control aphid vectors',
        'Maintain field hygiene',
      ],
    },
    'cotton_bollworm': {
      'scientific_name': 'Helicoverpa armigera',
      'affected_crops': ['Cotton', 'Chilli', 'Tomato', 'Okra'],
      'symptoms': ['Bored fruits', 'Holes in bolls', 'Frass near entry holes'],
      'life_cycle': 'Egg → Larva → Pupa → Adult (25-35 days)',
      'natural_predators': ['Trichogramma wasps', 'Chrysoperla', 'Birds'],
      'chemical_control': ['Quinalphos', 'Monocrotophos', 'Endosulfan'],
      'organic_control': ['Bt spray', 'Neem oil', 'Pheromone traps'],
      'preventive_measures': [
        'Crop rotation',
        'Field sanitation',
        'Resistant varieties',
        'Monitoring with traps',
      ],
    },
  };

  static final Map<String, dynamic> commonDiseases = {
    'rice_blast': {
      'pathogen': 'Pyricularia oryzae',
      'affected_crops': ['Rice'],
      'symptoms': ['Diamond-shaped lesions', 'Lesions with gray centers', 'Collar rot'],
      'favorable_conditions': ['High humidity', 'Temperature 25-28°C', 'Excessive nitrogen'],
      'chemical_control': ['Tricyclazole', 'Carbendazim', 'Mancozeb'],
      'organic_control': ['Copper fungicides', 'Neem oil', 'Bacillus subtilis'],
      'preventive_measures': [
        'Resistant varieties',
        'Balanced fertilization',
        'Field sanitation',
        'Proper water management',
      ],
    },
    'coconut_root_wilt': {
      'pathogen': 'Phytoplasma',
      'affected_crops': ['Coconut'],
      'symptoms': ['Yellowing of leaflets', 'Reduced leaf size', 'Root rot'],
      'transmission': 'Insect vectors (planthoppers)',
      'chemical_control': ['Oxytetracycline', 'Streptomycin', 'Ampicillin'],
      'organic_control': ['Neem cake', 'Trichoderma', 'Pseudomonas'],
      'preventive_measures': [
        'Remove infected palms',
        'Use healthy planting material',
        'Vector control',
        'Balanced nutrition',
      ],
    },
    'banana_panama_wilt': {
      'pathogen': 'Fusarium oxysporum f.sp. cubense',
      'affected_crops': ['Banana'],
      'symptoms': ['Yellowing of older leaves', 'Pseudo stem splitting', 'Vascular discoloration'],
      'favorable_conditions': ['High soil moisture', 'Temperature 25-30°C', 'Poor drainage'],
      'chemical_control': ['Carbendazim', 'Mancozeb', 'Copper oxychloride'],
      'organic_control': ['Trichoderma', 'Pseudomonas', 'Neem cake'],
      'preventive_measures': [
        'Use disease-free suckers',
        'Crop rotation',
        'Soil solarization',
        'Proper drainage',
      ],
    },
    'cotton_fusarium_wilt': {
      'pathogen': 'Fusarium oxysporum f.sp. vasinfectum',
      'affected_crops': ['Cotton'],
      'symptoms': ['Yellowing of leaves', 'Wilting', 'Vascular discoloration'],
      'favorable_conditions': ['High soil moisture', 'Temperature 25-30°C', 'Acidic soils'],
      'chemical_control': ['Carbendazim', 'Thiram', 'Captan'],
      'organic_control': ['Trichoderma', 'Pseudomonas', 'Neem cake'],
      'preventive_measures': [
        'Resistant varieties',
        'Crop rotation',
        'Soil solarization',
        'Balanced fertilization',
      ],
    },
  };

  /// Tamil Nadu agricultural schemes and subsidies
  static final Map<String, dynamic> governmentSchemes = {
    'pm_kisan': {
      'full_name': 'Pradhan Mantri Kisan Samman Nidhi',
      'benefit': '₹6,000 per year in three installments',
      'eligibility': 'Small and marginal farmers with cultivable land up to 2 hectares',
      'application_process': 'Through Common Service Centers or online portal',
      'contact': 'Toll-free: 1800-11-5526',
    },
    'pm_fasal_bima_yojana': {
      'full_name': 'Pradhan Mantri Fasal Bima Yojana',
      'benefit': 'Crop insurance with low premium rates',
      'coverage': 'Pre-sowing to post-harvest losses, prevented sowing, localized calamities',
      'premium_rates': {
        'kharif_cereals': '2%',
        'rabi_cereals': '1.5%',
        'commercial_crops': '5%',
      },
      'application_process': 'Through banks, insurance companies, or online',
      'contact': 'Toll-free: 1800-180-1551',
    },
    'subsidy_for_drip_irrigation': {
      'full_name': 'Micro Irrigation Subsidy Scheme',
      'benefit': '50-90% subsidy on drip/sprinkler systems',
      'eligibility': 'All farmers, higher subsidy for SC/ST/women farmers',
      'subsidy_amount': {
        'general_farmers': '50%',
        'sc_st_farmers': '75%',
        'women_farmers': '80%',
        'northeast_hills': '90%',
      },
      'application_process': 'Through Agriculture Department or online portal',
      'contact': 'Agriculture Department offices',
    },
    'organic_farming_promotion': {
      'full_name': 'Paramparagat Krishi Vikas Yojana',
      'benefit': '₹50,000 per cluster for 3 years',
      'eligibility': 'Groups of 50 farmers forming clusters of 50 acres',
      'coverage': 'Certification, training, marketing support',
      'application_process': 'Through Agriculture Department',
      'contact': 'District Agriculture Office',
    },
    'tamil_nadu_specific_schemes': {
      'krishi_satham': {
        'full_name': 'Krishi Satham Scheme',
        'benefit': 'Subsidy on agricultural implements',
        'coverage': 'Tractors, harvesters, planters, etc.',
        'subsidy_rate': '25-50% depending on implement',
      },
      'water_conservation': {
        'full_name': 'Water Conservation Scheme',
        'benefit': 'Subsidy for water harvesting structures',
        'coverage': 'Check dams, percolation tanks, farm ponds',
        'subsidy_rate': '75% for SC/ST, 50% for others',
      },
      'youth_agriculture': {
        'full_name': 'Youth Agriculture Promotion Scheme',
        'benefit': 'Financial assistance for young farmers',
        'eligibility': 'Youth aged 18-45 years',
        'assistance_amount': 'Up to ₹5 lakhs',
      },
    },
  };

  /// Tamil Nadu market information and prices
  static final Map<String, dynamic> marketInformation = {
    'major_markets': {
      'chennai': {
        'market_name': 'Koyambedu Market',
        'specialty': 'All vegetables and fruits',
        'trading_hours': '4:00 AM - 2:00 PM',
        'contact': '+91-44-26740000',
      },
      'coimbatore': {
        'market_name': 'Coimbatore Market Yard',
        'specialty': 'Cotton, turmeric, spices',
        'trading_hours': '6:00 AM - 12:00 PM',
        'contact': '+91-422-2300000',
      },
      'madurai': {
        'market_name': 'Madurai Market Yard',
        'specialty': 'Banana, mango, vegetables',
        'trading_hours': '5:00 AM - 1:00 PM',
        'contact': '+91-452-2530000',
      },
      'tirunelveli': {
        'market_name': 'Tirunelveli Market Yard',
        'specialty': 'Coconut, banana, spices',
        'trading_hours': '5:00 AM - 1:00 PM',
        'contact': '+91-462-2520000',
      },
    },
    'price_trends': {
      'rice': {
        'current_range': '₹1800-₹2200 per quintal',
        'seasonal_high': '₹2500 (post-harvest)',
        'seasonal_low': '₹1600 (pre-harvest)',
        'trend': 'Gradual increase due to demand',
      },
      'coconut': {
        'current_range': '₹15-₹25 per nut',
        'seasonal_high': '₹30 (summer)',
        'seasonal_low': '₹12 (rainy season)',
        'trend': 'Increasing due to health awareness',
      },
      'banana': {
        'current_range': '₹20-₹40 per dozen',
        'seasonal_high': '₹60 (off-season)',
        'seasonal_low': '₹15 (peak season)',
        'trend': 'Stable with seasonal variations',
      },
      'turmeric': {
        'current_range': '₹8000-₹12000 per quintal',
        'seasonal_high': '₹15000 (demand peak)',
        'seasonal_low': '₹6000 (harvest season)',
        'trend': 'Increasing due to export demand',
      },
    },
    'export_opportunities': {
      'spices': {
        'main_exports': ['Turmeric', 'Chilli', 'Pepper', 'Cardamom'],
        'target_countries': ['USA', 'Germany', 'UK', 'Middle East'],
        'requirements': ['Organic certification', 'Quality standards', 'Packaging'],
      },
      'processed_foods': {
        'main_exports': ['Coconut products', 'Cashew', 'Spice powders'],
        'target_countries': ['USA', 'Europe', 'Japan', 'Australia'],
        'requirements': ['FSSAI certification', 'HACCP', 'Export licenses'],
      },
    },
  };

  /// Tamil Nadu agricultural research and extension
  static final Map<String, dynamic> researchInstitutions = {
    'tamil_nadu_agricultural_university': {
      'location': 'Coimbatore',
      'established': 1971,
      'faculties': ['Agriculture', 'Horticulture', 'Forestry', 'Veterinary', 'Fisheries'],
      'research_areas': [
        'Crop improvement',
        'Soil science',
        'Plant protection',
        'Agricultural engineering',
      ],
      'contact': '+91-422-2380241',
      'website': 'www.tnau.ac.in',
    },
    'spices_board': {
      'location': 'Kochi (regional office in Coimbatore)',
      'functions': [
        'Research on spice crops',
        'Quality control',
        'Export promotion',
        'Farmer training',
      ],
      'contact': '+91-484-2385000',
      'website': 'www.indianspices.com',
    },
    'coconut_research_institute': {
      'location': 'Kerala (serves Tamil Nadu)',
      'functions': [
        'Coconut variety development',
        'Pest and disease management',
        'Value addition technologies',
      ],
      'contact': '+91-477-2742200',
      'website': 'www.cpcrid.ac.in',
    },
  };

  /// Get crop information for a specific region
  static Map<String, dynamic> getCropInfoForRegion(String crop, String region) {
    final cropData = majorCrops[crop];
    if (cropData == null) return {};

    final regionData = <String, dynamic>{};
    regionData['crop_name'] = crop;
    regionData['suitability'] = cropData['regions'].contains(region) ? 'High' : 'Low';
    regionData['recommended_varieties'] = _getRecommendedVarieties(crop, region);
    regionData['planting_schedule'] = _getPlantingSchedule(crop, region);
    regionData['yield_potential'] = _getYieldPotential(crop, region);
    regionData['market_info'] = marketInformation['price_trends'][crop];

    return regionData;
  }

  /// Get recommended varieties for a crop and region
  static List<String> _getRecommendedVarieties(String crop, String region) {
    switch (crop) {
      case 'rice':
        if (region == 'Thanjavur') return ['ADT 43', 'CO 51', 'CO 52'];
        if (region == 'Coimbatore') return ['CO 50', 'CO 51', 'CO 52'];
        return ['ADT 43', 'CO 51'];
      case 'coconut':
        if (region == 'Thanjavur') return ['Tall varieties', 'Hybrid COCH 1'];
        if (region == 'Kanyakumari') return ['Dwarf varieties', 'Hybrid COCH 2'];
        return ['Tall varieties'];
      case 'banana':
        if (region == 'Theni') return ['Robusta', 'Grand Naine'];
        if (region == 'Madurai') return ['Nendran', 'Poovan'];
        return ['Robusta'];
      default:
        return ['Recommended varieties available'];
    }
  }

  /// Get planting schedule for a crop and region
  static Map<String, String> _getPlantingSchedule(String crop, String region) {
    switch (crop) {
      case 'rice':
        return {
          'kuruvai': 'June-July',
          'samba': 'August-September', 
          'thaladi': 'October-November',
        };
      case 'coconut':
        return {
          'main_season': 'June-September',
          'secondary': 'November-February',
        };
      case 'banana':
        return {
          'main_planting': 'June-July',
          'off_season': 'October-November',
        };
      default:
        return {'planting_season': 'Varies by crop'};
    }
  }

  /// Get yield potential for a crop and region
  static Map<String, dynamic> _getYieldPotential(String crop, String region) {
    final cropData = majorCrops[crop];
    if (cropData == null) return {};

    return {
      'average_yield': cropData['average_yield'],
      'potential_yield': _calculatePotentialYield(crop, region),
      'factors_affecting_yield': _getYieldFactors(crop, region),
    };
  }

  /// Calculate potential yield based on region
  static double _calculatePotentialYield(String crop, String region) {
    final baseYield = majorCrops[crop]?['average_yield']?.values?.first ?? 0;
    // Apply regional factors
    if (region == 'Thanjavur' && crop == 'rice') return baseYield * 1.2;
    if (region == 'Coimbatore' && crop == 'turmeric') return baseYield * 1.1;
    return baseYield;
  }

  /// Get factors affecting yield for a crop and region
  static List<String> _getYieldFactors(String crop, String region) {
    final factors = <String>[];
    
    if (crop == 'rice' && region == 'Thanjavur') {
      factors.addAll([
        'Water availability',
        'Soil fertility',
        'Variety selection',
        'Pest management',
      ]);
    } else if (crop == 'coconut' && region == 'Tiruvarur') {
      factors.addAll([
        'Soil drainage',
        'Wind protection',
        'Nutrient management',
        'Pest control',
      ]);
    }

    return factors.isNotEmpty ? factors : ['Climate conditions', 'Soil type', 'Management practices'];
  }

  /// Get pest and disease management for a crop
  static Map<String, dynamic> getPestDiseaseManagement(String crop) {
    final management = <String, dynamic>{};
    management['common_pests'] = majorCrops[crop]?['common_pests'] ?? [];
    management['common_diseases'] = majorCrops[crop]?['common_diseases'] ?? [];
    management['integrated_management'] = [
      'Use resistant varieties',
      'Crop rotation',
      'Field sanitation',
      'Biological control',
      'Judicious chemical use',
    ];
    management['organic_options'] = [
      'Neem-based products',
      'Biocontrol agents',
      'Botanical extracts',
      'Cultural practices',
    ];

    return management;
  }

  /// Get fertilizer recommendations for a crop
  static Map<String, dynamic> getFertilizerRecommendations(String crop) {
    return majorCrops[crop]?['fertilizer_recommendations'] ?? {};
  }

  /// Get market information for a crop
  static Map<String, dynamic> getMarketInformation(String crop) {
    return marketInformation['price_trends'][crop] ?? {};
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/agricultural_data_models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Database is not supported on web');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmer_query.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE agro_qa(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          crop TEXT,
          question TEXT,
          answer TEXT
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crop Yield Table
    await db.execute('''
      CREATE TABLE crop_yield(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        crop TEXT,
        yield_per_hectare REAL,
        season TEXT,
        region TEXT,
        source TEXT,
        last_updated TEXT
      )
    ''');

    // Pest Disease Table
    await db.execute('''
      CREATE TABLE pest_disease(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pest_name TEXT,
        description TEXT,
        control_methods TEXT,
        source TEXT,
        last_updated TEXT
      )
    ''');

    // Market Prices Table
    await db.execute('''
      CREATE TABLE market_prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        market TEXT,
        price REAL,
        date TEXT,
        variety TEXT,
        source TEXT,
        last_updated TEXT
      )
    ''');

    // Soil Data Table
    await db.execute('''
      CREATE TABLE soil_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        soil_type TEXT,
        ph_level REAL,
        organic_matter REAL,
        source TEXT,
        last_updated TEXT
      )
    ''');

    // AgroQA Table
    await db.execute('''
      CREATE TABLE agro_qa(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        crop TEXT,
        question TEXT,
        answer TEXT
      )
    ''');
  }

  // --- Insertion Methods ---

  Future<void> insertCropYield(List<CropYieldData> dataList) async {
    if (kIsWeb) return;
    final db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert('crop_yield', data.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertPestDisease(List<PestDiseaseData> dataList) async {
    if (kIsWeb) return;
    final db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert('pest_disease', data.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertMarketPrices(List<MarketPriceData> dataList) async {
    if (kIsWeb) return;
    final db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert('market_prices', data.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertSoilData(List<SoilData> dataList) async {
    if (kIsWeb) return;
    final db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert('soil_data', data.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertAgroQA(List<AgroQAData> dataList) async {
    if (kIsWeb) return;
    final db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert('agro_qa', data.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // --- Query Methods ---

  Future<List<CropYieldData>> getCropYields(String cropType) async {
    if (kIsWeb) return [];
    final db = await database;
    // Simple LIKE query
    final List<Map<String, dynamic>> maps = await db.query(
      'crop_yield',
      where: 'crop LIKE ?',
      whereArgs: ['%$cropType%'],
    );
    return List.generate(maps.length, (i) => CropYieldData.fromJson(maps[i]));
  }

  Future<List<PestDiseaseData>> getPestDiseases(String keyword) async {
    if (kIsWeb) return [];
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pest_disease',
      where: 'pest_name LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return List.generate(maps.length, (i) => PestDiseaseData.fromJson(maps[i]));
  }

  Future<List<MarketPriceData>> getMarketPrices(String variety) async {
    if (kIsWeb) return [];
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'market_prices',
      where: 'variety LIKE ?',
      whereArgs: ['%$variety%'],
    );
    return List.generate(maps.length, (i) => MarketPriceData.fromJson(maps[i]));
  }

  Future<List<SoilData>> getAllSoilData() async {
    if (kIsWeb) return [];
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('soil_data');
    return List.generate(maps.length, (i) => SoilData.fromJson(maps[i]));
  }

  Future<List<AgroQAData>> searchAgroQA(String query) async {
    if (kIsWeb) return [];
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'agro_qa',
      where: 'question LIKE ? OR answer LIKE ? OR crop LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => AgroQAData.fromJson(maps[i]));
  }

  Future<int> getAgroQACount() async {
    if (kIsWeb) return 0;
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM agro_qa')) ?? 0;
  }

  // --- Cache invalidation basic check ---
  Future<bool> isCacheValid(String tableName, {Duration maxAge = const Duration(hours: 24)}) async {
    if (kIsWeb) return false;
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: ['last_updated'],
      limit: 1,
      orderBy: 'last_updated DESC'
    );

    if (maps.isEmpty || maps.first['last_updated'] == null) return false;
    
    DateTime lastUpdated = DateTime.parse(maps.first['last_updated']);
    return DateTime.now().difference(lastUpdated) < maxAge;
  }
}

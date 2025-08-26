import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/projet_model.dart';
import '../../data/models/troncon_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProjetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TronconModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TronconImageModelAdapter());
    }
  }

  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }
} 
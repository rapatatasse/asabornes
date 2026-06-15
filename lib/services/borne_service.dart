import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/borne.dart';

/// Service responsable du chargement et du parsing des bornes depuis le JSON local.
/// En V2, remplacer [loadBornes] par un appel HTTP vers l'API.
class BorneService {
  static const String _assetPath = 'assets/bornes_backup.json';

  /// Charge les bornes depuis l'asset JSON embarqué dans l'application.
  Future<List<Borne>> loadBornes() async {
    final String jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> raw = jsonDecode(jsonString) as Map<String, dynamic>;

    final List<Borne> bornes = [];
    for (final entry in raw.entries) {
      final data = entry.value as Map<String, dynamic>?;
      if (data == null) continue;

      // Ignorer les entrées sans coordonnées valides
      final localite = data['localite'] as Map<String, dynamic>?;
      final value = localite?['value'] as Map<String, dynamic>?;
      if (value == null) continue;
      final lat = (value['_latitude'] as num?)?.toDouble();
      final lng = (value['_longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      bornes.add(Borne.fromJson(entry.key, data));
    }
    return bornes;
  }
}

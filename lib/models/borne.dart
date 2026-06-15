import 'package:latlong2/latlong.dart';

/// Types de bornes connus dans les données
enum BorneType {
  borne,
  colonneSeche,
  vanne,
  ventouse,
  autre,
}

/// Modèle de données pour une borne d'irrigation
class Borne {
  final String id;
  final String name;
  final BorneType type;
  final String typeRaw;
  final LatLng position;
  final String comment;
  final String commentTechnician;
  final bool colonneSeche;
  final String asaId;
  final String secteurId;

  const Borne({
    required this.id,
    required this.name,
    required this.type,
    required this.typeRaw,
    required this.position,
    required this.comment,
    required this.commentTechnician,
    required this.colonneSeche,
    required this.asaId,
    required this.secteurId,
  });

  /// Parse un objet JSON représentant une borne
  factory Borne.fromJson(String key, Map<String, dynamic> json) {
    // Extraction de la position depuis le champ 'localite'
    final localite = json['localite'] as Map<String, dynamic>?;
    final value = localite?['value'] as Map<String, dynamic>?;
    final lat = (value?['_latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (value?['_longitude'] as num?)?.toDouble() ?? 0.0;

    final typeRaw = (json['type'] as String?) ?? 'Borne';
    final type = _parseType(typeRaw);

    return Borne(
      id: (json['id'] as String?) ?? key.split('/').last,
      name: (json['name'] as String?) ?? '',
      type: type,
      typeRaw: typeRaw,
      position: LatLng(lat, lng),
      comment: (json['comment'] as String?) ?? '',
      commentTechnician: (json['commenttechnician'] as String?) ?? '',
      colonneSeche: (json['colonneseche'] as bool?) ?? false,
      asaId: (json['asa_id'] as String?) ?? '',
      secteurId: (json['secteur_id'] as String?) ?? '',
    );
  }

  static BorneType _parseType(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('colonne')) return BorneType.colonneSeche;
    if (lower.contains('vanne')) return BorneType.vanne;
    if (lower.contains('ventouse')) return BorneType.ventouse;
    if (lower.contains('borne')) return BorneType.borne;
    return BorneType.autre;
  }
}

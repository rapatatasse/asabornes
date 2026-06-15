import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/borne.dart';
import '../providers/borne_provider.dart';

/// Écran principal : carte interactive avec les bornes d'irrigation.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Centre par défaut sur la zone des bornes (région Saint-Étienne)
  static const LatLng _defaultCenter = LatLng(45.32, 4.82);
  static const double _defaultZoom = 13.0;

  @override
  void initState() {
    super.initState();
    // Déclenche le chargement des bornes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorneProvider>().loadBornes();
    });
  }

  // ─── Géolocalisation ────────────────────────────────────────────────────────

  Future<void> _goToUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Le service de localisation est désactivé.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('Permission de localisation refusée.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnack('Permission de localisation refusée définitivement.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
  }

  // ─── FitBounds sur toutes les bornes ────────────────────────────────────────

  void _fitAllBornes(List<Borne> bornes) {
    if (bornes.isEmpty) return;

    double minLat = bornes.first.position.latitude;
    double maxLat = bornes.first.position.latitude;
    double minLng = bornes.first.position.longitude;
    double maxLng = bornes.first.position.longitude;

    for (final b in bornes) {
      if (b.position.latitude < minLat) minLat = b.position.latitude;
      if (b.position.latitude > maxLat) maxLat = b.position.latitude;
      if (b.position.longitude < minLng) minLng = b.position.longitude;
      if (b.position.longitude > maxLng) maxLng = b.position.longitude;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  // ─── BottomSheet détail borne ────────────────────────────────────────────────

  void _showBorneDetail(Borne borne) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _BorneDetailSheet(borne: borne),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ─── Couleur & icône selon le type ──────────────────────────────────────────

  Color _colorForType(BorneType type) {
    switch (type) {
      case BorneType.borne:
        return Colors.blue.shade700;
      case BorneType.colonneSeche:
        return Colors.orange.shade700;
      case BorneType.vanne:
        return Colors.red.shade600;
      case BorneType.ventouse:
        return Colors.purple.shade600;
      case BorneType.autre:
        return Colors.grey.shade600;
    }
  }

  IconData _iconForType(BorneType type) {
    switch (type) {
      case BorneType.borne:
        return Icons.water_drop;
      case BorneType.colonneSeche:
        return Icons.fire_hydrant_alt;
      case BorneType.vanne:
        return Icons.settings;
      case BorneType.ventouse:
        return Icons.air;
      case BorneType.autre:
        return Icons.location_on;
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BorneProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ASA Bornes'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (provider.state == LoadingState.loaded)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${provider.bornes.length} bornes',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(provider),
          _buildLegend(),
          if (provider.state == LoadingState.loading)
            const Center(child: CircularProgressIndicator()),
          if (provider.state == LoadingState.error)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur : ${provider.errorMessage}'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton : recentrer sur toutes les bornes
          FloatingActionButton(
            heroTag: 'fitBounds',
            mini: true,
            tooltip: 'Vue globale des bornes',
            onPressed: () => _fitAllBornes(provider.bornes),
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            child: const Icon(Icons.zoom_out_map),
          ),
          const SizedBox(height: 8),
          // Bouton : ma position
          FloatingActionButton(
            heroTag: 'myLocation',
            tooltip: 'Ma position',
            onPressed: _goToUserLocation,
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BorneProvider provider) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        minZoom: 5,
        maxZoom: 20,
      ),
      children: [
        // ── Couche 1 : OpenStreetMap (fond) ──────────────────────────────────
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'fr.asabornes.app',
        ),

        // ── Couche 2 : Cadastre IGN Géoportail (WMTS) ────────────────────────
        TileLayer(
          urlTemplate:
              'https://wxs.ign.fr/essentiels/geoportail/wmts?'
              'SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0'
              '&LAYER=CADASTRALPARCELS.PARCELS'
              '&STYLE=normal'
              '&TILEMATRIXSET=PM'
              '&TILEMATRIX={z}'
              '&TILEROW={y}'
              '&TILECOL={x}'
              '&FORMAT=image%2Fpng',
          userAgentPackageName: 'fr.asabornes.app',
          opacity: 0.6,
        ),

        // ── Couche 3 : Markers des bornes ────────────────────────────────────
        if (provider.state == LoadingState.loaded)
          MarkerLayer(
            markers: provider.bornes.map((borne) {
              final color = _colorForType(borne.type);
              final icon = _iconForType(borne.type);
              return Marker(
                point: borne.position,
                width: 36,
                height: 36,
                child: GestureDetector(
                  onTap: () => _showBorneDetail(borne),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Légende des types de bornes
  Widget _buildLegend() {
    const items = [
      (BorneType.borne, 'Borne', Colors.blue),
      (BorneType.colonneSeche, 'Colonne sèche', Colors.orange),
      (BorneType.vanne, 'Vanne', Colors.red),
      (BorneType.ventouse, 'Ventouse', Colors.purple),
    ];

    return Positioned(
      bottom: 100,
      left: 12,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 7,
                      backgroundColor: item.$3.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(item.$2, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Widget BottomSheet détail d'une borne ─────────────────────────────────────

class _BorneDetailSheet extends StatelessWidget {
  final Borne borne;
  const _BorneDetailSheet({required this.borne});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Borne "${borne.name}"',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),

          _row('Type', borne.typeRaw),
          _row('ID', borne.id),
          _row('Lat / Lon',
              '${borne.position.latitude.toStringAsFixed(6)}, ${borne.position.longitude.toStringAsFixed(6)}'),
          if (borne.comment.isNotEmpty) _row('Commentaire', borne.comment),
          if (borne.commentTechnician.isNotEmpty)
            _row('Commentaire technicien', borne.commentTechnician),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

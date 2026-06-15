import 'package:flutter/foundation.dart';
import '../models/borne.dart';
import '../services/borne_service.dart';

enum LoadingState { idle, loading, loaded, error }

/// Provider gérant l'état des bornes (chargement + liste).
class BorneProvider extends ChangeNotifier {
  final BorneService _service = BorneService();

  LoadingState _state = LoadingState.idle;
  List<Borne> _bornes = [];
  String _errorMessage = '';

  LoadingState get state => _state;
  List<Borne> get bornes => _bornes;
  String get errorMessage => _errorMessage;

  /// Charge les bornes et notifie les listeners.
  Future<void> loadBornes() async {
    _state = LoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _bornes = await _service.loadBornes();
      _state = LoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }
}

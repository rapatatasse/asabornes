# ASA Bornes

Application Flutter Android pour cartographier les **bornes d'irrigation agricoles** sur une carte interactive avec cadastre IGN.

---

## Prérequis

| Outil | Version minimale |
|-------|-----------------|
| Flutter SDK | 3.x (stable) |
| Dart SDK | 3.0.0+ |
| Android SDK | API 21+ (Android 5.0) |
| Java (JDK) | 11 ou 17 |

> Vérifier l'installation : `flutter doctor`

---

## Installation

### 1. Cloner / ouvrir le projet

```bash
cd "c:\flutter app\asabornes"
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Vérifier les appareils disponibles

```bash
flutter devices
```

---

## Lancer l'application

### Sur un appareil Android physique (USB)

```bash
flutter run
```

### Sur un émulateur Android

```bash
# Démarrer l'émulateur depuis Android Studio, puis :
flutter run
```

### Générer un APK de debug

```bash
flutter build apk --debug
# APK produit : build\app\outputs\flutter-apk\app-debug.apk
```

### Générer un APK de release

```bash
flutter build apk --release
# APK produit : build\app\outputs\flutter-apk\app-release.apk
```

> **Note release** : un keystore de signature est requis pour un APK release signé.  
> Pour tester, utilisez `--debug` ou `--release` avec le signingConfig debug (déjà configuré).

---

## Structure du projet

```
asabornes/
├── assets/
│   └── bornes_backup.json       # Données des bornes (embarquées)
├── lib/
│   ├── main.dart                # Point d'entrée de l'application
│   ├── models/
│   │   └── borne.dart           # Modèle de données Borne
│   ├── services/
│   │   └── borne_service.dart   # Lecture et parsing du JSON
│   ├── providers/
│   │   └── borne_provider.dart  # Gestion d'état (ChangeNotifier)
│   └── screens/
│       └── map_screen.dart      # Écran carte principal
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml  # Permissions Internet + GPS
└── pubspec.yaml                 # Dépendances Flutter
```

---

## Fonctionnalités

- **Carte OpenStreetMap** comme fond de carte
- **Cadastre IGN Géoportail** (WMTS `CADASTRALPARCELS.PARCELS`) superposé en transparence
- **Markers** colorés selon le type de borne :
  - 🔵 Borne
  - 🟠 Colonne sèche
  - 🔴 Vanne
  - 🟣 Ventouse
- **Clic sur un marker** → BottomSheet avec les détails (nom, type, coordonnées, commentaires)
- **Bouton "Ma position"** → recentre la carte sur la géolocalisation de l'utilisateur
- **Bouton "Vue globale"** → ajuste le zoom pour afficher toutes les bornes (FitBounds)

---

## Dépendances principales

```yaml
flutter_map: ^7.0.2       # Cartographie
latlong2: ^0.9.1          # Coordonnées géographiques
geolocator: ^12.0.0       # Géolocalisation GPS
provider: ^6.1.2          # Gestion d'état
```

---

## Permissions Android requises

Déclarées dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## Migration V2 (API)

Actuellement les bornes sont chargées depuis `assets/bornes_backup.json`.  
Pour brancher une API, modifier uniquement `lib/services/borne_service.dart` :

```dart
// Remplacer rootBundle.loadString(...) par :
final response = await http.get(Uri.parse('https://votre-api.com/bornes'));
final Map<String, dynamic> raw = jsonDecode(response.body);
```

Ajouter le package `http` dans `pubspec.yaml` et la permission réseau est déjà présente.

---

## Commandes utiles

```bash
# Nettoyer le build
flutter clean

# Mettre à jour les dépendances
flutter pub upgrade

# Analyser le code
flutter analyze

# Voir les logs en temps réel
flutter logs
```

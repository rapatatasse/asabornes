Agis en tant qu'expert Flutter et Dart. Je souhaite créer une application mobile Android (générant un fichier .apk) dont le but est de cartographier des bornes d'irrigation agricoles sur une carte interactive.

Voici les spécifications techniques et fonctionnelles de l'application :

1. Architecture et Packages :
- Framework : Flutter (dernière version stable).
- Cartographie : Utiliser impérativement le package 'flutter_map' (et 'latlong2' pour les coordonnées).
- Gestion de l'état : Un State Management simple (ex: Cubit/Bloc ou ChangeNotifier) pour gérer le chargement des données.
- Requêtes HTTP : Le package 'http' pour récupérer le fichier JSON.

2. Données (Bornes d'irrigation) :
- Les données des bornes sont stockées dans un fichier JSON actuellement  cici : bornes_backup.json. dans la V2 il y aura une API qui fournira ces données.
- Chaque a ses donnés 
"bornes/0gFM4xxl2LP64Ze4QCAB": {"localitecolonneseche":{"__datatype__":"geopoint","value":{"_latitude":45.33579339639354,"_longitude":4.857876866209507}},"asa_id":"sBx57HJbJ9cgPKaJ2VKv","localite":{"__datatype__":"geopoint","value":{"_latitude":45.33574339639354,"_longitude":4.857826866209507}},"pompage_id":"ZBaQEJUjDlNhYNtkXvyC","name":"116","colonneseche":false,"created_at":{"__datatype__":"timestamp","value":{"_seconds":1739602827,"_nanoseconds":156000000}},"comment":"","id":"0gFM4xxl2LP64Ze4QCAB","secteur_id":"QHhCzJyBzfEz6RWaV9YO","type":"Borne","commenttechnician":"","user_id":"oN8wVdhU64EVZWSzvTii","operation":{"__datatype__":"timestamp","value":{"_seconds":1781301600,"_nanoseconds":0}}},
- L'application doit lire ce JSON au démarrage, parser les données et afficher chaque borne sous forme de Marker (un icône de borne ou de goutte d'eau) sur la carte. Et prendre en info son type. Pa sbesoin du reste
- Un clic sur un Marker doit ouvrir une Popup ou une BottomSheet affichant les détails de la borne sélectionnée.

3. Configuration de la Carte (Couches / Layers) :
La carte doit être composée de deux couches superposées :
- Couche de fond (Optionnelle/Standard) : OpenStreetMap classique (TileLayer).
- Couche Haute (Le Cadastre Français) : Tu dois intégrer le flux WMTS de l'IGN pour afficher les parcelles cadastrales par-dessus en transparence. Utilise un 'TileLayer' configuré avec l'URL WMTS de la plateforme GéOPORTAIL de l'IGN (flux 'CADASTRALPARCELS.PARCELS'). Gère correctement les sous-domaines si nécessaire et l'opacité (ex: opacity: 0.6) pour que le fond reste visible.

4. Fonctionnalités de la carte :
- Recentrer la carte sur la position actuelle de l'utilisateur (géolocalisation via le package 'geolocator').
- Un bouton pour recentrer la vue sur l'ensemble des bornes chargées (FitBounds).

Génère-moi le code complet, propre et commenté :
- Le fichier 'pubspec.yaml' avec toutes les dépendances nécessaires.
- Les configurations requises pour Android (Permissions Internet et GPS dans le AndroidManifest.xml).
- Le code source Dart structuré (Modèle de données pour le JSON, le Service de récupération HTTP, et la Vue principale de la carte).
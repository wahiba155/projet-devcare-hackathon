# DevCare 🧠💙
> AI Agent for Student Productivity & Well-being

## 🎯 Concept
DevCare est une application mobile/web qui détecte automatiquement
l'état mental de l'utilisateur (stress, burnout, blocage) et propose
des actions personnalisées en temps réel pour améliorer son bien-être.

## ⚙️ Tech Stack
- **Frontend** : Flutter (Android + Web + Windows)
- **Backend IA** : OpenAI GPT-4o-mini
- **Base de données** : Firebase Realtime Database
- **Auth** : Firebase Authentication

## 🚀 Installation

### Prérequis
- Flutter SDK : https://flutter.dev/docs/get-started/install
- Dart SDK (inclus avec Flutter)
- Node.js : https://nodejs.org
- Firebase CLI : `npm install -g firebase-tools`

### Étapes

**1. Cloner le projet**
```bash
git clone https://github.com/wahiba155/devcare-hackathon.git
cd devcare-hackathon
```


# Flutter SDK (si pas encore installé)
# Télécharger sur https://flutter.dev/docs/get-started/install

# Vérifier l'installation
flutter doctor

**2. Installer les dépendances**
```bash
flutter pub get
```

**3. Configurer Firebase**
```bash
firebase login
flutterfire configure
```

Sélectionner le projet : `devcare-hackathon`

**4. Configurer OpenAI**
- Ouvre `lib/services/ai_service.dart`
- Remplace `sk-VOTRE_CLE_OPENAI` par ta clé API

**5. Lancer l'app**
```bash
# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Android
flutter run -d android
```

## 📁 Structure du projet
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_state.dart
│   └── stress_entry.dart
├── services/
│   ├── ai_service.dart
│   ├── stress_service.dart
│   └── firebase_service.dart
├── providers/
│   └── app_provider.dart
└── screens/
├── home_screen.dart
├── analyze_screen.dart
├── dashboard_screen.dart
├── coach_screen.dart
└── breathing_screen.dart
## 🧩 Fonctionnalités
- 🔍 **Détection de stress** via analyse de texte + comportement
- 🤖 **Agent IA** qui décide et agit automatiquement
- 📅 **Smart Calendar** qui reprogramme selon l'énergie
- 🧘 **Micro-actions** : respiration, pause, sons relaxants
- 📊 **Dashboard** : graphe stress sur 7 jours

- 1. Détection d'état mental — via analyse de texte (sentiment + mots-clés) ET comportement (temps de session, inactivité). Score de stress 0→100 avec 3 états : calme / moyen / burnout.
2. Agent IA adaptatif — le vrai "wow" : l'app ne détecte pas seulement, elle décide et agit. Elle utilise GPT-4 pour raisonner sur l'état de l'utilisateur et proposer une action concrète (pause, respiration, replanification).
3. Stuck Breaker — détecte l'inactivité prolongée sur une tâche, propose des hints, découpe les tâches, suggère de changer d'activité.
4. Smart Calendar Adapter — reprogramme automatiquement les sessions selon l'énergie détectée. Si burnout → retire les sessions de travail, ajoute des pauses.
5. Dashboard d'énergie — graphe stress/énergie sur 7 jours, historique des sessions, score moyen. C'est l'élément visuel fort pour le jury.
6. Micro-actions intégrées — respiration guidée (animation), timer de pause, sons relaxants.

## 👥 Équipe
- Wahiba — [@wahiba155](https://github.com/wahiba155)
- (ajoute tes coéquipiers ici)

## 🔑 Variables importantes
| Variable | Fichier | Description |
|----------|---------|-------------|
| `_apiKey` | `lib/services/ai_service.dart` | Clé API OpenAI |
| Firebase config | `lib/firebase_options.dart` | Auto-généré par FlutterFire |

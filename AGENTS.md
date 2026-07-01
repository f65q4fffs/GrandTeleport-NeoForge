# Système de Gouvernance et Suivi - Grand Teleport (NeoForge Port)

Ce document régit les règles de développement, l'architecture du projet et le suivi de la roadmap pour le portage de Grand Teleport vers NeoForge 1.21.1.

---

## Environnement technique & Stack
- **Jeu** : Minecraft 1.21.1
- **Framework** : NeoForge (version 21.1.234)
- **Langage** : Java 21
- **Outil de Build** : Gradle (version 9.2.1)
- **Mod ID** : `gtalike_teleport`
- **Licence** : MIT (code source) + restriction ZapSplat sur les fichiers audio (voir LICENSE)

---

## Architecture du projet
```text
c:/Users/user/Desktop/dev/mod Grand Teleport Neoforge portage/
├── build.gradle                               # Configuration Gradle
├── settings.gradle                             # Paramètres Gradle
├── gradle.properties                           # Propriétés du projet et versions
├── README.md                                   # README principal avec crédits
├── AGENTS.md                                   # Fichier de gouvernance (ce fichier)
└── src/
    └── main/
        ├── java/
        │   └── dev/
        │       └── codex/
        │           └── gtaliketeleport/
        │               ├── GtaLikeTeleport.java        # Classe principale du mod
        │               ├── GtaLikeTeleportConfig.java  # Système de configuration portabilité
        │               ├── client/                     # Logique client & rendu caméra (Étape 3)
        │               ├── network/                    # Gestion des paquets réseau (Étape 2)
        │               └── mixin/                      # Mixins de caméra (Étape 4)
        └── templates/
            └── META-INF/
                └── neoforge.mods.toml          # Template de configuration NeoForge
```

---

## Règles de développement universelles
- **Chirurgical** : Ne jamais réécrire un fichier entier si une modification ciblée et chirurgicale est possible.
- **Dépendances** : Ne jamais inventer, ajouter ou installer de dépendance sans validation explicite.
- **Qualité** : Typage strict, modularité, lisibilité, pas de fonctions ou variables mortes.
- **Validation** : Toujours poser des questions et obtenir la validation explicite de l'utilisateur avant de modifier le code.
- **Git** : Ne jamais pousser (`git push`) ou committer de modifications sur un dépôt distant sans l'accord explicite préalable de l'utilisateur.
- **Fin de Session** : Ne pas décider de terminer de manière autonome. Suivre le protocole strict de fin de session (mise à jour d'AGENTS.md, compilation, résumé dans un bloc texte unique) si l'utilisateur en signale la fin.

---

## Roadmap

### ✅ En place
- **Étape 1 : Initialisation & Structure**
  - Fichiers Gradle du MDK NeoForge 1.21.1 configurés.
  - Fichier `neoforge.mods.toml` configuré avec le Mod ID `gtalike_teleport` et les crédits.
  - Classe principale `GtaLikeTeleport.java` implémentée.
  - Classe `GtaLikeTeleportConfig.java` portée et compatible avec l'API NeoForge `FMLPaths`.
  - Fichier `README.md` créé pour créditer hookuru_.
  - Compilation Java validée avec succès.
- **Étape 2 : Le Payload Réseau (Network)**
  - Implémentation de `StartServerTeleportPayload`, `ServerTeleportAckPayload` et `BypassNextServerTeleportPayload` sous forme de records et StreamCodecs.
  - Gestion de l'enregistrement réseau via `RegisterPayloadHandlersEvent` sur le Mod Event Bus.
  - Création des classes `GtaLikeTeleportClientNetworking` et `GtaLikeTeleportServerNetworking`.
  - Intégration dans la classe principale `GtaLikeTeleport.java`.
  - Résolution d'accès sur `DimensionIds.java` (rendue publique) et compilation validée avec succès.
- **Étape 3 : La Logique Client & Calculs Caméra**
  - Interpolation (Lerp) de la caméra sur le client et transition.
  - Remplacement de mixins Fabric par des événements NeoForge client natifs (`MovementInputUpdateEvent`, `RenderGuiEvent.Post`, `ClientTickEvent.Post`).
  - Utilisation de mixins ciblés sur `Camera` et `MouseHandler` pour surcharger la position de la caméra et bloquer la souris.
  - Portage de toutes les classes de logique (`TeleportTransitionController`, `TeleportStepEffectRenderer`, `TeleportCommandMatcher`, `TeleportDestinationParser`, `TeleportSounds`) et des classes de compatibilité.
  - Compilation Java validée avec succès.

- **Étape 4 : Gestion des Nuages & Rendu Visuel**
  - Masquage automatique des nuages (`LevelRendererMixin`) durant les transitions de téléportation pour éviter les coupures visuelles.
  - Masquage dynamique du modèle du joueur (`EntityRendererMixin`) pour une vue à la première personne fluide.
  - Neutralisation du menu pause durant la transition cinématique (`MinecraftMixin`).
  - Portage complet de la compatibilité avec Waystones (`WaystonesWarpPlateHandler`, `WaystonesWarpPlateBlockEntityMixin`) et JourneyMap (`JourneyMapClientNetworkDispatcherMixin`).
  - Compilation Java validée avec succès.

- **Correctifs post-tests (session finale)**
  - **Bug fix** : `GtaLikeTeleportMixinPlugin` utilisait `ModList` (runtime) dans `shouldApplyMixin()`, appelé bien avant l'initialisation de FML. Remplacé par `LoadingModList` (early-loading) → NPE corrigé.
  - **Bug fix** : `NeoForge.EVENT_BUS.register(this)` dans `GtaLikeTeleport` levait une `IllegalArgumentException` car la classe n'a aucune méthode `@SubscribeEvent` (elle utilise `addListener()`). Ligne supprimée.
  - **Validation en jeu** : mod testé et fonctionnel en jeu avec des mods tiers (Waystones, JourneyMap, Sodium, etc.).

### 🔄 À faire
- Aucun élément restant. Le portage Fabric → NeoForge 1.21.1 est **entièrement terminé, corrigé et validé en jeu** !

---

## Instructions pour l'assistant
1. **Lecture prioritaire** : Lire impérativement le contenu d`AGENTS.md` au début de chaque session ou tâche.
2. **Notification** : À chaque modification d'`AGENTS.md`, prévenir l'utilisateur et expliquer le changement.
3. **Fin de session** : Appliquer le protocole de fin de session lorsque l'utilisateur le demande.
4. **Format du résumé de fin de session** : Le résumé final doit être rédigé en **texte brut uniquement** (pas de markdown, pas de titres `#`, pas de gras `**`, pas de listes `-`), dans un seul bloc de texte continu que l'utilisateur peut copier directement.

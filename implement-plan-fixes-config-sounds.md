# Plan d'implémentation — Correctifs interface Config + Sons GTA V

**Date** : 3 juillet 2026  
**Contexte** : retours utilisateur après tests en jeu (screenshot dans `.conv/Screenshot_1.png`).

**Aucune modification de code tant que ce plan n'est pas validé explicitement.**

---

## Synthèse des problèmes

| Problème | Cause racine identifiée | Priorité |
|----------|-------------------------|----------|
| Interface config « buggée » | Régression : labels des `IconButton` effacés après `repositionWidgets()` | 🔴 Haute |
| Interface config (secondaire) | Layout custom activé par défaut (`configLayoutCustom=true`) calé sur 640×353 | 🟠 Moyenne |
| Interface config (secondaire) | i18n partielle : titres/onglets en anglais, clés FR déjà présentes mais non branchées | 🟠 Moyenne |
| Sons GTA V silencieux | **4 fichiers `.ogg` absents** du projet et du JAR compilé | 🔴 Haute |

---

## 1. Sons GTA V — diagnostic

### État actuel du code (correct côté logique)

- `TeleportTransitionController` joue bien `GTA5_DEZOOM`, `GTA5_ZOOM`, `GTA5_LANDING`, `GTA5_WIND` quand :
  - `customSoundsEnabled == true`
  - `soundPack == "gta"`
- `sounds.json` déclare les 4 entrées GTA.
- `TeleportSounds.java` référence les bons IDs.

### Cause racine : assets audio au mauvais emplacement (problème de branche)

Sur la branche `unstable/agent-progress`, les fichiers GTA **existent** dans `audio/` (commités sur la branche) mais n'ont **jamais été copiés** vers le chemin Minecraft :

```
src/main/resources/assets/gtalike_teleport/sounds/teleport/
```

| Fichier source (`audio/`) | Fichier cible (`sounds/teleport/`) | Phase jeu |
|---------------------------|-------------------------------------|-----------|
| `GTA5_1_dezoom.ogg` | `gta5_dezoom.ogg` | zoom-out |
| `GTA5_2_Wind.ogg` | `gta5_wind.ogg` | voyage (vent) |
| `GTA5_3_zoom.ogg` | `gta5_zoom.ogg` | zoom-in |
| `GTA5_4_zoom_wind_impact.ogg` | `gta5_landing.ogg` | impact final |

Les `.wav` dans `audio/` sont des sources ; seuls les `.ogg` vont dans le mod.

Fichiers présents dans `sounds/teleport/` aujourd'hui (7 classiques) :

```
camera_in/out.ogg, teleport.ogg, zoom_in/out long/short.ogg
```

→ `sounds.json` référence `gta5_*` mais Minecraft ne trouve pas les fichiers → **silence**.

La branche `main` n'a ni le code GTA ni le dossier `audio/`. Le travail est sur `unstable/agent-progress` ; l'oubli de copie explique la régression.

### Étapes de correction (sons)

| # | Action | Fichiers |
|---|--------|----------|
| S1 | Copier/renommer depuis `audio/` vers `src/main/resources/assets/gtalike_teleport/sounds/teleport/` (table de mapping ci-dessus) | 4 × `.ogg` |
| S2 | Ne pas modifier `sounds.json` (chemins `gta5_*` déjà corrects) | — |
| S3 | Vérifier que `sounds.json` pointe vers les bons chemins (déjà OK) | `sounds.json` |
| S4 | Vérifier config joueur : `soundPack=gta` + `customSoundsEnabled=true` (toggle « GTA V (Real) ») | `grand_teleport.properties` |
| S5 | `./gradlew build` + test téléportation avec pack GTA | — |
| S6 | *(Optionnel)* Log debug si son introuvable au runtime (facilite futurs diagnostics) | `TeleportTransitionController.java` |

### Test de validation (sons)

1. Ouvrir config → onglet Sons → basculer sur **GTA V (Real)**.
2. Téléporter (`/tp` ou autre source activée).
3. Entendre : dézoom → vent en vol → zoom → impact landing.
4. Vérifier dans le JAR final que les 11 `.ogg` sont présents (7 classiques + 4 GTA).

---

## 2. Interface config — diagnostic

### Cause racine A — labels effacés (régression port NeoForge)

**Flux actuel défectueux :**

```
initGeneralWidgets()
  → updateGeneralButtons()     // pose Component.translatable("gtalike_teleport.option.*")
init()
  → repositionWidgets()
      → applyItemText()        // remet Component.empty() sur les toggles
      → setMessage(empty)      // efface à nouveau les labels
```

**Résultat** : les `IconButton` n'affichent que l'icône + indicateur ON/OFF (carré vert/rouge), **sans texte**. L'interface paraît cassée/incomplète.

**Référence** : sur Fabric, `updateGeneralButtons()` mettait déjà `Component.empty()` — les labels étaient dessinés autrement. Le port NeoForge a ajouté des labels traduits sur les boutons **sans retirer** l'effacement dans `repositionWidgets()`.

### Cause racine B — layout custom par défaut

Dans `GtaLikeTeleportConfig.DEFAULT_CONFIG_PROPERTIES` :

```
configLayoutCustom=true
configLayoutBaseWidth=640
configLayoutBaseHeight=353
configLayoutX/Y/Width/Height=… (positions sauvegardées)
configText.*=… (overrides de texte)
configWidget.*=… (positions widgets)
```

→ Une installation fraîche hérite d'un layout édité pour une résolution spécifique. Sur un autre écran/GUI scale, widgets et textes peuvent être **décalés, tronqués ou superposés**.

### Cause racine C — i18n partielle

- Clés FR/EN existent (`gtalike_teleport.config.page.*`, `option.*`, etc.).
- `getDefaultItemText()` utilise encore ~150 chaînes anglaises en dur pour titres, onglets, labels.
- Plan détaillé déjà rédigé : `.kilo/plans/20260703053000-i18n-config-screen.md`.

---

## 3. Étapes de correction (interface config)

### Phase 1 — correctif urgent (labels boutons)

| # | Action | Fichier |
|---|--------|---------|
| C1 | À la fin de `repositionWidgets()`, rappeler les updaters selon la page active : `updateGeneralButtons()`, `updateSoundButtons()`, `updateOthersButtons()` | `GtaLikeTeleportConfigScreen.java` |
| C2 | Dans `applyItemText()`, **ne plus** appeler `setMessage(Component.empty())` sur les toggles qui portent leur propre label traduit | idem |
| C3 | Dans `repositionWidgets()`, retirer les `setMessage(Component.empty())` redondants sur : `effectToggle`, `movementToggle`, `crossDimension`, `soundMode`, `warpPlate`, `externalTeleport`, `preset`, `fadeColor`, `shutter`, `vignette`, `interference`, `vanillaTp`, `journeyMap`, `portals`, `fallbackChunkFade` | idem |
| C4 | Conserver `Component.empty()` uniquement sur : tabs, prev/next, reset/done (texte dessiné manuellement via `drawButtonText`) | idem |

**Changement chirurgical estimé** : ~30 lignes dans `repositionWidgets()`, `applyItemText()`, fin de `repositionWidgets()`.

### Phase 2 — layout par défaut sain

| # | Action | Fichier |
|---|--------|---------|
| C5 | Passer `configLayoutCustom=false` dans `DEFAULT_CONFIG_PROPERTIES` | `GtaLikeTeleportConfig.java` |
| C6 | Retirer les `configWidget.*` et `configText.*` de développement des defaults embarqués (garder uniquement dans les saves utilisateur existantes) | idem |
| C7 | *(Optionnel)* Bouton « Réinitialiser disposition » déjà présent si layout editor activé ; documenter pour l'utilisateur | — |

> **Note** : les joueurs ayant déjà un `grand_teleport.properties` custom ne seront pas affectés. Seules les nouvelles installs / reset config bénéficient du layout propre.

### Phase 3 — i18n complète (plan existant)

Reporter sur `.kilo/plans/20260703053000-i18n-config-screen.md` :

- Map `itemToTranslationKey`
- Refonte `getItemComponent()` / `getItemText()`
- Brancher onglets sur `gtalike_teleport.config.page.*`
- Logique Apply de l'éditeur de layout

**Hors scope** (décision utilisateur confirmée) : ON/OFF, dimensions, ticks, presets, commandes.

---

## 4. Fichiers impactés (récapitulatif)

| Fichier | Phase 1 | Phase 2 | Sons |
|---------|---------|---------|------|
| `GtaLikeTeleportConfigScreen.java` | ✅ | — | — |
| `GtaLikeTeleportConfig.java` | — | ✅ | — |
| `sounds/teleport/gta5_*.ogg` | — | — | ✅ (ajout assets) |
| `sounds.json` | — | — | vérif seule |
| `en_us.json` / `fr_fr.json` | Phase 3 | — | — |
| `TeleportTransitionController.java` | — | — | optionnel S6 |

**Pas de nouvelle dépendance.**

---

## 5. Ordre d'exécution recommandé

```
1. Copier les 4 .ogg depuis audio/ → sounds/teleport/ (renommage)
2. Phase 1 — fix labels IconButton (C1–C4)
3. Phase 2 — defaults layout (C5–C6)
4. ./gradlew build
5. Tests en jeu (checklist ci-dessous)
6. Phase 3 — i18n complète (validation séparée)
```

---

## 6. Checklist de validation en jeu

### Interface config
- [ ] Menu Mods → Config s'ouvre correctement
- [ ] Onglet **General** : chaque toggle affiche icône + **label traduit** + indicateur état
- [ ] Onglet **Sounds** : bouton pack son affiche « Pack de Sons: GTA V (Real) » (ou équivalent EN)
- [ ] Onglets **Zoom / Durées / Intégrations** : pas de chevauchement visible
- [ ] Boutons Reset / Close fonctionnels
- [ ] Retour au menu Mods OK

### Sons GTA V
- [ ] Pack GTA V sélectionné dans config
- [ ] Téléportation joue les 4 phases sonores GTA
- [ ] Pack « Default (Mod) » joue toujours les sons classiques du mod
- [ ] Pack « Minecraft (OFF) » utilise les sons vanilla

---

## 7. Contexte branche Git

| Branche | Code GTA | `audio/` | `sounds/teleport/gta5_*` |
|---------|----------|----------|--------------------------|
| `main` | ❌ | ❌ | ❌ |
| `unstable/agent-progress` | ✅ | ✅ (4 ogg) | ❌ **oubli de copie** |

Modifications locales non commitées sur la branche actuelle :
- `GtaLikeTeleport.java` (fix `IConfigScreenFactory`)
- `GtaLikeTeleportConfig.java`, `GtaLikeTeleportConfigScreen.java`, `GtaLikeTeleportClient.java`

---

## 8. Questions ouvertes pour l'utilisateur

1. **Screenshot** : texte manquant sur les boutons, éléments décalés, autre ?
2. **Scope** : Phase 1 + 2 + copie audio, ou aussi Phase 3 (i18n) ?

---

## Validation requise

Réponds avec **YES** pour lancer l'implémentation dans l'ordre décrit.
Plan d'implémentation — Correctifs Config + Sons GTA V
Dernière mise à jour : 3 juillet 2026 — session interrompue (freeze agent/terminal)
Branche : unstable/agent-progress
Modifications locales : NON COMMITÉES

---

STATUT GLOBAL
Tâche	Statut	Notes
Copie sons GTA (audio/ → sounds/teleport/)	✅ FAIT	4 fichiers .ogg renommés
Fix labels interface config (Phase 1)	✅ FAIT	GtaLikeTeleportConfigScreen.java
Layout par défaut propre (Phase 2)	✅ FAIT	GtaLikeTeleportConfig.java
Bouton Config menu Mods	✅ FAIT	GtaLikeTeleport.java + IConfigScreenFactory
Commande /gtp config (bonus)	✅ FAIT	GtaLikeTeleportClient.java
Compilation gradlew build	⏳ À FAIRE	Par l'utilisateur (agent freeze)
Test en jeu — interface config	⏳ À FAIRE	
Test en jeu — sons GTA V	⏳ À FAIRE	
i18n complète écran config (Phase 3)	📋 REPORTÉ	Plan .kilo/plans/20260703053000-i18n-config-screen.md
Commit / push	⏳ EN ATTENTE	Accord utilisateur requis (AGENTS.md)
Mise à jour AGENTS.md	⏳ FIN DE SESSION	Sur demande utilisateur
---

CONTEXTE BRANCHE
main : pas de code GTA, pas de dossier audio/
unstable/agent-progress : tout le travail VFX/SFX/config est ici
Problème branche : les .ogg GTA étaient dans audio/ (commités) mais jamais copiés vers src/main/resources/assets/gtalike_teleport/sounds/teleport/ → sons silencieux en jeu
Problème interface : updateGeneralButtons() posait des labels traduits, puis repositionWidgets() les effaçait avec setMessage(Component.empty()) → boutons sans texte
---
SONS GTA V
Mapping fichiers (FAIT)
audio/GTA5_1_dezoom.ogg → sounds/teleport/gta5_dezoom.ogg
audio/GTA5_2_Wind.ogg → sounds/teleport/gta5_wind.ogg
audio/GTA5_3_zoom.ogg → sounds/teleport/gta5_zoom.ogg
audio/GTA5_4_zoom_wind_impact.ogg → sounds/teleport/gta5_landing.ogg
Code (déjà en place, inchangé cette session)
sounds.json — entrées gta5_* OK
TeleportSounds.java — 4 SoundEvents GTA
TeleportTransitionController.java — joue GTA si customSoundsEnabled=true + soundPack=gta
Validation à faire
gradlew build
Vérifier JAR : 11 .ogg dans assets/gtalike_teleport/sounds/teleport/ (7 classiques + 4 GTA)
En jeu : Config → Sons → GTA V (Real) → téléportation → dézoom / vent / zoom / impact
---
INTERFACE CONFIG — Phase 1 (FAIT)
Fichier : src/main/java/dev/codex/gtaliketeleport/GtaLikeTeleportConfigScreen.java

Changements appliqués :
rebuildWidgets() ajouté (appelé 8× dans le code mais méthode absente du source) :
private void rebuildWidgets() {
this.clearWidgets();
resetWidgetReferences();
this.init();
}
applyItemText() — supprimé les branches setMessage(Component.empty()) sur :
effectToggle, movementToggle, crossDimensionToggle, soundModeToggle, warpPlateToggle, externalTeleportToggle
repositionWidgets() — supprimé les setMessage(Component.empty()) sur les mêmes toggles
repositionWidgets() — ajouté repositionnement pour toggles manquants :
preset, fadeColor, shutterFlash, vignette, interference, vanillaTp, journeyMap, portals, fallbackChunkFade
Fin de repositionWidgets() — rappel des updaters selon la page :
if (currentPage == GENERAL) updateGeneralButtons();
else if (currentPage == SOUNDS) updateSoundButtons();
else if (currentPage == OTHERS) updateOthersButtons();

Validation à faire :
Menu Mods → Config : chaque toggle affiche icône + label traduit + indicateur ON/OFF
Onglets General / Sounds / Others : pas de chevauchement bizarre
Boutons Reset / Close OK
---
LAYOUT PAR DÉFAUT — Phase 2 (FAIT)
Fichier : src/main/java/dev/codex/gtaliketeleport/GtaLikeTeleportConfig.java

Changements appliqués :
configLayoutCustom=true → configLayoutCustom=false
Supprimé des DEFAULT_CONFIG_PROPERTIES :
configLayoutX/Y/Width/Height (positions calées dev 640×353)
Tous les configText.* (~13 lignes)
Tous les configWidget.* (~370 lignes)
Résultat : defaults passés de 438 lignes → 61 lignes
Note : les joueurs avec un grand_teleport.properties existant gardent leur layout custom. Seules les nouvelles installs ou un reset config bénéficient du layout propre.

Si l'interface reste décalée chez toi : supprimer ou renommer grand_teleport.properties dans le dossier config Minecraft, ou utiliser Réinitialiser disposition si layout editor activé.

---
BOUTON CONFIG MENU MODS (FAIT — session précédente)
Fichier : src/main/java/dev/codex/gtaliketeleport/GtaLikeTeleport.java
RegisterConfigScreensEvent n'existe PAS en NeoForge 21.1.234
API correcte : ModContainer.registerExtensionPoint(IConfigScreenFactory.class, (container, parent) -> new GtaLikeTeleportConfigScreen(parent))
Constructeur : GtaLikeTeleport(IEventBus modEventBus, ModContainer modContainer)
Compilé avec succès (~3 s) avant les freezes agent
---
FICHIERS MODIFIÉS (récap non commité)
GtaLikeTeleport.java — IConfigScreenFactory + ModContainer
GtaLikeTeleportClient.java — /gtp config + alias settings
GtaLikeTeleportConfig.java — defaults layout + public sur sanitizeStageHeights/getMin/MaxStageHeight/getMinStageGap
GtaLikeTeleportConfigScreen.java — labels, rebuildWidgets, titre i18n
sounds/teleport/gta5_dezoom.ogg, gta5_wind.ogg, gta5_zoom.ogg, gta5_landing.ogg — 4 nouveaux fichiers
implement-plan-config-mods-menu.md — plan bouton Config mis à jour
implement-plan-fixes-config-sounds.md — ce document
---
À FAIRE APRÈS REDÉMARRAGE VSCode
Immédiat (utilisateur) :
cd "c:\Users\user\Desktop\dev\mod Grand Teleport Neoforge portage"
gradlew.bat build

Si JAVA_HOME manquant :
set JAVA_HOME=%USERPROFILE%\.gradle\jdks\eclipse_adoptium-21-amd64-windows.2
set PATH=%JAVA_HOME%\bin;%PATH%
gradlew.bat build

Tests en jeu :
[ ] Menu Mods → Grand Teleport → Config s'ouvre
[ ] Labels visibles sur tous les toggles
[ ] Sons → GTA V (Real) → téléportation avec 4 sons GTA
[ ] Sons Default (Mod) et Minecraft (OFF) toujours OK
[ ] /gtp config ouvre aussi l'écran

Si build échoue :
Erreur rebuildWidgets duplicate → vérifier qu'il n'y a qu'UNE définition dans GtaLikeTeleportConfigScreen.java
Erreur sons → vérifier présence des 4 gta5_*.ogg dans src/main/resources/assets/gtalike_teleport/sounds/teleport/
Plus tard (validation séparée) :
Phase 3 i18n : plan .kilo/plans/20260703053000-i18n-config-screen.md
Map itemToTranslationKey, brancher onglets/titres sur fr_fr.json / en_us.json
~5 % fait (titre seulement)

Fin de session (sur demande) :
Mise à jour AGENTS.md
Résumé texte brut (protocole AGENTS.md)
Commit uniquement avec accord explicite
---
PROBLÈME AGENT (session actuelle)
L'agent Cursor a freeze sur toutes les commandes (même echo test) et lectures de fichiers en fin de session. La compilation n'a PAS été relancée après les derniers changements (sons + config). L'utilisateur doit compiler manuellement.

Prochain message utile à l'agent après redémarrage :
« Lis implement-plan-fixes-config-sounds.md, compile, et dis-moi si le build passe. »

---

RÉSUMÉ : le code et les sons sont en place localement ; il reste gradlew build + test en jeu ; i18n complète et commit viendront après.
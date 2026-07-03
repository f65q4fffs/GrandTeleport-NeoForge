# Plan d'implémentation — Restauration du bouton Config dans le menu Mods de Minecraft (NeoForge 1.21.1)

**Dernière mise à jour** : 3 juillet 2026

Ce plan répond au bug : le bouton "Config" du menu Mods de Minecraft n'ouvre plus l'écran de configuration du mod.

## Statut global

| Étape | Statut |
|-------|--------|
| Enregistrement `IConfigScreenFactory` via `ModContainer` | ✅ Fait (non commité) |
| Titre i18n de l'écran | ✅ Fait (non commité) |
| Clés `gtalike_teleport.config.title` (en/fr) | ✅ Déjà présentes |
| Commande `/gtp config` (bonus) | ✅ Fait (non commité) |
| Compilation `./gradlew build` | ⏳ À valider |
| Test en jeu (menu Mods → Config) | ⏳ À valider |
| Mise à jour `AGENTS.md` | ⏳ En attente (fin de session) |
| i18n complète de l'écran config | 📋 Plan séparé (voir ci-dessous) |

---

## Contexte
- Le mod utilise déjà `GtaLikeTeleportConfigScreen` qui étend `Screen`.
- NeoForge nécessite l'enregistrement d'un `IConfigScreenFactory` via `ModContainer.registerExtensionPoint()` pour que le bouton "Config" apparaisse et fonctionne dans le menu Mods.
- Avant ce correctif, l'écran n'était accessible que via la commande `/gtp config` (ajoutée en parallèle).
- L'objectif est d'enregistrer le factory sans casser le layout editor ni le système de configuration existant.

## Décisions prises
- **Scope principal** : restauration du bouton Config dans le menu Mods.
- Utiliser l'API NeoForge `IConfigScreenFactory` + `ModContainer.registerExtensionPoint()` (pas d'événement dédié en 21.1.234).
- Garder le constructeur existant `GtaLikeTeleportConfigScreen(Screen parent)`.
- Utiliser `Component.translatable` pour le titre de l'écran (conforme à la règle i18n d'AGENTS.md).
- Pas de nouvelle dépendance, pas de réécriture de classe.

## Écart par rapport au plan initial

Les premières tentatives utilisaient `RegisterConfigScreensEvent`, qui **n'existe pas** dans NeoForge 21.1.234 (échec de compilation). L'implémentation corrigée :

```java
public GtaLikeTeleport(IEventBus modEventBus, ModContainer modContainer) {
    // ...
    if (FMLEnvironment.dist == Dist.CLIENT) {
        modContainer.registerExtensionPoint(
            IConfigScreenFactory.class,
            (container, parent) -> new GtaLikeTeleportConfigScreen(parent)
        );
    }
}
```

C'est l'API documentée dans `IConfigScreenFactory` (sources NeoForge 21.1.234).

---

## Fichiers modifiés

### Plan principal (bouton Config menu Mods)

| Fichier | Modification | Statut |
|---------|--------------|--------|
| `GtaLikeTeleport.java` | `ModContainer` + `registerExtensionPoint(IConfigScreenFactory)` | ✅ |
| `GtaLikeTeleportConfigScreen.java` | Titre → `Component.translatable("gtalike_teleport.config.title")` | ✅ |
| `en_us.json` / `fr_fr.json` | Clé `gtalike_teleport.config.title` | ✅ (déjà en place) |

### Travail bonus (hors scope initial, déjà fait)

| Fichier | Modification | Statut |
|---------|--------------|--------|
| `GtaLikeTeleportClient.java` | Sous-commande `/gtp config` + alias `settings` | ✅ |
| `GtaLikeTeleportConfig.java` | Visibilité `public` sur `sanitizeStageHeights`, `getMin/MaxStageHeight`, `getMinStageGap` | ✅ |

---

## Étapes restantes

### 1. Compilation
```bash
./gradlew build
```
Confirmer l'absence d'erreurs de compilation.

### 2. Test en jeu — menu Mods
1. Lancer Minecraft avec le mod.
2. Ouvrir le menu **Mods**.
3. Sélectionner **Grand Teleport**.
4. Cliquer sur **Config**.
5. Vérifier que `GtaLikeTeleportConfigScreen` s'ouvre correctement.
6. Vérifier que le bouton retour ferme l'écran et revient au menu Mods.

### 3. Test en jeu — commande (bonus)
1. Exécuter `/gtp config` ou `/gtp settings`.
2. Vérifier que l'écran s'ouvre.

### 4. Fin de session (sur demande utilisateur)
- Mettre à jour `AGENTS.md` (section roadmap / correctifs).
- Résumé en texte brut (protocole AGENTS.md).
- Commit / push uniquement avec accord explicite de l'utilisateur.

---

## Plan connexe — i18n complète de l'écran config

Le bouton Config et le titre traduit ne couvrent qu'une **fraction** de l'i18n requise par AGENTS.md.

Un plan détaillé existe dans `.kilo/plans/20260703053000-i18n-config-screen.md`.

**État actuel de l'i18n :**
- ✅ Titre de l'écran (`gtalike_teleport.config.title`)
- ✅ ~41 clés déjà présentes dans `en_us.json` / `fr_fr.json` (`option.*`, `tooltip.*`, `page.*`, layout debug, etc.)
- ✅ Boutons/widgets du layout editor déjà branchés sur `Component.translatable`
- ❌ `getDefaultItemText()` : ~150 chaînes encore en anglais dur
- ❌ `getItemComponent()` / `getItemText()` : pas encore de map `itemToTranslationKey`
- ❌ Logique Apply de l'éditeur de layout : pas encore de comparaison avec la traduction par défaut

**Hors scope i18n (décision utilisateur confirmée) :**
- Noms de dimensions (Overworld / Nether / End)
- ON / OFF / SERVER OFF
- "ticks", placeholders dynamiques
- Presets, couleurs, packs de sons (Classic, Black, GTA V, etc.)
- Chaînes de commandes dans `GtaLikeTeleportClient.java`

---

## Notes importantes
- Respect des règles AGENTS.md : modifications chirurgicales, i18n obligatoire, pas de réécriture complète.
- Les modifications actuelles sont **locales et non commitées** (branche `unstable/agent-progress`).
- L'i18n complète est un chantier distinct ; ne pas le confondre avec la restauration du bouton Config.

## Prochaine action suggérée

1. Lancer `./gradlew build` et tester le bouton Config en jeu.
2. Si validé → demander commit ou fin de session.
3. Si l'i18n complète est souhaitée → valider explicitement le plan `.kilo/plans/20260703053000-i18n-config-screen.md` avant toute modification supplémentaire.
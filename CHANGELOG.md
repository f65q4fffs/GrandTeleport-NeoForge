# Changelog

Toutes les versions de ce port NeoForge sont préfixées `neoforge-` pour les distinguer du mod Fabric d'origine.

## neoforge-1.0.1

### Ajouts
- Modes sons en 3 états : GTA V, Default (Mod) et OFF (`/gtp sound gta|default|off`).
- Pipeline CI/CD GitHub Actions pour publication automatique Modrinth et CurseForge (déclenchement par tag `v*`).

### Corrections
- Écran de configuration : labels IconButton lisibles, layout restauré, colonnes toggle recalculées.
- Sons : séparation explicite des packs GTA V et sons par défaut du mod ; chargement config client corrigé.
- Bouton Config accessible depuis le menu Mods NeoForge et via `/gtp config`.

### Modifications
- Nomenclature des versions : préfixe obligatoire `neoforge-` pour toutes les releases du port.

## neoforge-1.0.0

### Ajouts
- Port initial de Grand Teleport (Fabric) vers NeoForge 1.21.1.
- Transition caméra cinématique GTA V (zoom, survol, atterrissage).
- Compatibilité Waystones, JourneyMap, masquage nuages/joueur durant la transition.
- Écran de configuration in-game et commandes `/gtp`.
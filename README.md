# Grand Teleport (NeoForge Port)

Ce projet est un portage du mod original **Grand Teleport (GTP)** de **Codex** et **hookuru_** pour l'écosystème **NeoForge** (Minecraft 1.21.1).

Le mod d'origine (pour Fabric) peut être trouvé ici :
* Modrinth: [https://modrinth.com/mod/gtp](https://modrinth.com/mod/gtp)
* GitHub: [https://github.com/hookuru/GrandTeleport](https://github.com/hookuru/GrandTeleport)

## Description

Grand Teleport ajoute un effet de transition de caméra cinématique de style GTA V lors des téléportations dans Minecraft. 

Lorsque le joueur se téléporte (via `/tp`, `/teleport` ou d'autres moyens supportés), la caméra se détache du joueur, monte verticalement dans les nuages à travers plusieurs étapes de zoom, se déplace vers la destination, puis redescend sur la position finale du joueur de manière fluide.

## Fonctionnalités principales

* Effet cinématique de zoom/dézoom vertical et déplacement de caméra en vol d'oiseau.
* Hauteurs et transitions configurables.
* Configurations distinctes pour l'Overworld, le Nether et l'End.
* Option pour figer le joueur (mouvements et caméra) pendant la transition.
* Support des téléportations inter-dimensionnelles.
* Effets sonores intégrés.

## Commandes

* `/gtp on` ou `/grandtp on` - Activer la transition.
* `/gtp off` ou `/grandtp off` - Désactiver la transition.
* `/gtp status` ou `/grandtp status` - Afficher l'état actuel du mod.
* `/gtp player_freeze on|off|status` - Activer/désactiver/vérifier le blocage du joueur pendant la transition.

## Crédits et Licence

* **Auteurs originaux** : Codex (code) et hookuru_ (supervision, playtests, dépôt original).
* **Portage NeoForge** : Antigravity (développement).
* **Licence du code** : Ce portage est distribué sous la licence **MIT**, conformément au projet original.
* **Licence audio** : Les effets sonores personnalisés inclus sont des assets édités à partir de sons licenciés depuis ZapSplat sous un plan Premium. Ils ne peuvent pas être extraits, redistribués, vendus ou réutilisés séparément. Voir [LICENSE](./LICENSE) pour les détails.

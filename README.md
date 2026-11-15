```
   _._
 o|- -|o This file is licensed under CC BY-NC-SA 4.0 international license.
  ( l )  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
    =    Author: jean-marc "jihem" quere 2026
```

[![kaleido](kaleido.png)](https://lipunila.sonaliwan.fr)
# ◆ Kaléido

Atelier de conception de contenus visuels et documentaires, écrit en **Lexis+** : documents, illustrations SVG, présentations et storyboards assemblés à partir de **composants réutilisables**, avec traçabilité complète des dépendances.

```sh
wdlexisrt exemples/kaleido/principal.prg [dossier_du_projet]
```

Au premier lancement, un projet de démonstration est créé dans `~/Kaleido/Demonstration`.

## En une minute

| Raccourci | Action |
|:--|:--|
| Cmd+K | palette : toutes les commandes, composants, documents, titres |
| Cmd+1 … Cmd+6 | espaces Document, Dessin, Présentation, Storyboard, Graphe, Publier |
| Cmd+S · Cmd+P | enregistrer · PDF du document |
| F5 · F8 | conférence · téléprompteur |
| V R E L A P T I N H | outils de dessin |

- `{{> id}}` insère un composant, `{{> id@client}}` sa variante, `{{> id#v2}}` une version figée.
- Avant d'enregistrer un composant partagé, Kaléido annonce l'impact : propager, ignorer, variante ou branche.
- **Publier** produit des PDF (texte réel, signets, index, accessibles) et un site web autonome avec lecteur.

## Fichiers

- `CAHIER_TECHNIQUE.md` / `.pdf` : architecture, modèle objet, formats, graphe, interface, maquettes, workflows, API, extensions, publication (le PDF est produit par Kaléido lui-même).
- `maquettes/` : captures des écrans principaux.
- `plugins/statistiques.prg` : extension d'exemple (commande, macros, exportateur, vérification).
- `ressources/` : lecteur web (HTML, CSS, JS) et lecteur intégré (WebView).
- `Kaleido-Guide-utilisateur.pdf` : Guide de l'utilisateur (avec des exemples de projet décrits pas à pas).

## IMPORTANT
Le langage de programmation utilisé pour réaliser cette application est **Lexis+** (disponible pour Linux, macOS et Windows). Vous devez installer l'environnement de développement intégré (EDI / IDE) **[wdlexis+](https://github.com/lipunila-sonaliwan-fr/nim.wdlexis)** disponible sur GitHub pour pouvoir (re)compiler. Le dépôt de **wdlexis** comporte des versions prête à installer dans la section **[Releases](https://github.com/lipunila-sonaliwan-fr/nim.wdlexis/releases)**. La version minimale requise est **v1.9.4 wdlexis+ (complet)**.

## Licence

CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026

### Encore une chose !
Un p'tit geste qui peut - grandement - nous aider... \[La caféïne c'est important pour une équipe de neuro-atypiques : TSA, TDAH, TAG, HPI et/ou THPI (membres de **mensa.fr** et de **triplenine.org**).\]

[![Buy Me a Coffee](buymeacoffe-fre.png)](https://buymeacoffee.com/sonaliwan.fr)

# Conversion de planches SVG en planches de symboles Kaléido

```
wdlexisrt exemples/planches_svg/convertir_planches.prg <dossier source> <dossier destination>
```

Chaque pictogramme dessiné dans un groupe `<g transform="translate(x y) scale(k)">` muni
d'un `<title>` devient un `<symbol>` (viewBox local, titre, attributs de style) ; la planche
l'affiche par un `<use>` au même endroit et reste visuellement identique. Les découpes
rectangulaires (`clip-path`) sont recalculées en formes, car Kaléido ne les gère pas.

Les planches produites s'importent par *Fichier ▸ Importer une planche de symboles SVG…*.
La boîte de chaque pictogramme est calculée par le moteur SVG de Kaléido
(`publication.boitesvg`).

&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : lecteur web intégré (WebView Lexis+), lancé par Publier ▸ Lecteur.
&&   wdlexisrt ressources/lecteur.prg chemin/vers/publication/web/index.html
&& (procédures seulement : le fichier est aussi chargé avec l'application)

procedure PRINCIPAL
  locale chemin_ = systeme.args[1]
  si chemin_ = nul ou chemin_ = ""
    ? "usage : lecteur.prg index.html"
    retourner
  finsi
  si non webview.disponible()
    systeme.executer(sisinon(systeme.plateforme() = "macosx", "open ", "xdg-open ") + '"' + chemin_ + '"')
    retourner
  finsi
  locale f = webview.fenetre{titre = "Kaléido — Lecteur", largeur = 1280, hauteur = 860, url = "file://" + chemin_}
  f:executer()
retourner

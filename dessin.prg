&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : éditeur SVG intégré.
&&
&& La toile (paquet interface) édite une scène SVG en manipulation directe : outils, poignées,
&& magnétisme (grille, guides intelligents), calques, groupes, Bézier (plume, nœuds),
&& alignements et répartition, opérations booléennes, symboles (composants liés), styles
&& graphiques et thèmes de couleurs. Le SVG produit est standard et compact.
&& Raccourcis (toile active) : V sélection, R rectangle, E ellipse, L ligne, A flèche, P plume,
&& T texte, I image, H main, N nœuds ; Cmd+G grouper, Cmd+D dupliquer, Suppr, flèches.

procedure DESSIN_ETAT(esp)
  && chaque toile (dessin, diapositive) a son propre état d'édition
  globale DSN, DESSIN_ETATS
  si DESSIN_ETATS = nul
    DESSIN_ETATS = {}
  finsi
  locale k = sisinon(esp = "presentation", "presentation", "dessin")
  si DESSIN_ETATS[k] = nul
    DESSIN_ETATS[k] = {cible = nul, modifie = faux, dernier = 0, theme = "aurore"}
  finsi
  DSN = DESSIN_ETATS[k]
retourner

procedure CONSTRUIRE_DESSIN(o)
  globale toile, toile_dessin, lcalques, lobjets, lstyles, DSN, onglets_dessin
  DESSIN_ETAT("dessin")
  locale info = o:ajouter(ui.rangee())
  info.ancrage = "haut"
  info.marge = 4
  globale lbldessin
  lbldessin = info:ajouter(ui.etiquette("Aucune illustration ouverte : créez-en une (Fichier ▸ Nouvelle illustration) ou double-cliquez un composant SVG."))
  lbldessin.poids = 1
  lbldessin.couleur = "#CBD5E1"
  locale sep = o:ajouter(ui.separateur{vertical = vrai, position = 0.8})
  sep.ancrage = "centre"
  toile = sep:ajouter(ui.toile{mode = "edition", grille = faux})
  toile_dessin = toile
  toile.surselection = @DESSIN_SELECTION
  toile.surchangement = @DESSIN_CHANGE
  toile.surdoubleclic = @DESSIN_DOUBLE
  toile.surtouchebas = @DESSIN_TOUCHE
  onglets_dessin = sep:ajouter(ui.onglets())
  locale pc = onglets_dessin:ajouterpage("Calques", "bordure")
  locale bc = pc:ajouter(ui.rangee())
  bc.ancrage = "haut"
  bc.marge = 2
  ICONE(bc, "plus", "Nouveau calque", "Ajouter un calque (les nouvelles formes y vont)", @CALQUE_NOUVEAU)
  ICONE(bc, "k-eye", "Afficher / masquer", "Afficher ou masquer le calque choisi", @CALQUE_VISIBLE)
  ICONE(bc, "k-lock", "Verrouiller", "Verrouiller ou déverrouiller le calque choisi", @CALQUE_VERROU)
  ICONE(bc, "k-up", "Monter", "Monter le calque", @CALQUE_MONTER)
  ICONE(bc, "k-down", "Descendre", "Descendre le calque", @CALQUE_DESCENDRE)
  ICONE(bc, "supprimer", "Supprimer", "Supprimer le calque et ses formes", @CALQUE_SUPPRIMER)
  lcalques = pc:ajouter(ui.liste())
  lcalques.ancrage = "centre"
  lcalques.surselection = @CALQUE_CHOIX
  lcalques.surdoubleclic = @CALQUE_RENOMMER
  locale po = onglets_dessin:ajouterpage("Objets", "bordure")
  lobjets = po:ajouter(ui.liste())
  lobjets.ancrage = "centre"
  lobjets.surdoubleclic = @OBJET_INSERER
  locale ps = onglets_dessin:ajouterpage("Styles", "bordure")
  lstyles = ps:ajouter(ui.liste())
  lstyles.ancrage = "centre"
  lstyles.surdoubleclic = @STYLE_APPLIQUER
  pour chaque o2 dans OBJETS()
    lobjets:ajouter(o2.nom)
  suivant
  pour chaque s dans STYLES_GRAPHIQUES()
    lstyles:ajouter(s.nom)
  suivant
retourner

procedure RUBAN_DESSIN(r)
  globale BOUTONS_OUTILS, NUANCIER
  BOUTONS_OUTILS = {}
  ICONE(r, "nouveau", "Nouvelle illustration", "Nouvelle illustration SVG (composant)", @DESSIN_NOUVEAU)
  ICONE(r, "enregistrer", "Enregistrer", "Enregistrer l'illustration (Cmd+S)", @DESSIN_ENREGISTRER)
  FILET(r)
  pour chaque t dans OUTILS_DESSIN()
    BOUTONS_OUTILS[t.id] = ICONE(r, t.icone, t.libelle, t.aide, t.proc)
  suivant
  FILET(r)
  ICONE(r, "k-alignl", "Aligner à gauche", "Aligner à gauche (une forme : sur la planche)", @AL_GAUCHE)
  ICONE(r, "k-alignc", "Centrer", "Centrer horizontalement", @AL_CENTRE)
  ICONE(r, "k-alignr", "Aligner à droite", "Aligner à droite", @AL_DROITE)
  ICONE(r, "k-alignt", "Aligner en haut", "Aligner en haut", @AL_HAUT)
  ICONE(r, "k-alignm", "Centrer verticalement", "Centrer verticalement", @AL_MILIEU)
  ICONE(r, "k-alignb", "Aligner en bas", "Aligner en bas", @AL_BAS)
  ICONE(r, "k-disth", "Répartir horizontalement", "Répartir horizontalement (3 formes ou plus)", @AL_REPH)
  ICONE(r, "k-distv", "Répartir verticalement", "Répartir verticalement", @AL_REPV)
  FILET(r)
  ICONE(r, "k-group", "Grouper", "Grouper (Cmd+G)", @D_GROUPER)
  ICONE(r, "k-ungroup", "Dégrouper", "Dégrouper (Cmd+Maj+G)", @D_DEGROUPER)
  ICONE(r, "k-front", "Premier plan", "Mettre au premier plan (Cmd+Maj+↑)", @D_AVANT)
  ICONE(r, "k-back", "Arrière-plan", "Mettre à l'arrière-plan (Cmd+Maj+↓)", @D_ARRIERE)
  ICONE(r, "k-union", "Union", "Union des formes choisies", @B_UNION)
  ICONE(r, "k-subtract", "Différence", "La première forme moins les suivantes", @B_DIFF)
  ICONE(r, "k-intersect", "Intersection", "Intersection des formes", @B_INTER)
  FILET(r)
  NUANCIER = {}
  pour chaque c dans THEME_COULEURS(DSN.theme)
    locale b = r:ajouter(ui.bouton("●", {plat = vrai}))
    b.couleur = c
    b.infobulle = "Remplissage " + c + " (Alt : contour)"
    b.surclic = @NUANCE_CLIC
    b.largeurfixe = 28
    inserer(NUANCIER, {bouton = b, couleur = c})
  suivant
  ICONE(r, "palette", "Couleur…", "Choisir une couleur de remplissage", @COULEUR_CHOISIR)
  FILET(r)
  ICONE(r, "k-grid", "Grille", "Afficher la grille et y aimanter les formes", @D_GRILLE)
  ICONE(r, "k-magnet", "Magnétisme", "Guides intelligents (bords et centres des formes)", @D_MAGNET)
  ICONE(r, "k-vectorize", "Vectoriser", "Importer et vectoriser une image", @VECTORISER_DIALOGUE)
  ICONE(r, "k-component", "Symbole", "Enregistrer la sélection comme symbole réutilisable", @DESSIN_SYMBOLE)
  ICONE(r, "k-undo", "Annuler", "Annuler (Cmd+Z)", @D_ANNULER)
  ICONE(r, "k-redo", "Rétablir", "Rétablir (Cmd+Maj+Z)", @D_RETABLIR)
  locale e = r:ajouter(ui.etiquette(""))
  e.poids = 1
  ICONE(r, "ajuster", "Ajuster", "Toute la planche dans la vue (Cmd+0)", @D_AJUSTER)
retourner

procedure RUBAN_DESSIN_TEXTE(r)
  ICONE(r, "k-select", "Sélection", "Outil sélection (V)", @OUTIL_SELECTION)
  FILET(r)
  LIBELLE(r, "Texte", 40)
  OUTIL(r, "Poppins", @TX_POPPINS, "Police sans empattement (titres, interfaces)")
  OUTIL(r, "Lora", @TX_LORA, "Police à empattements (texte courant)")
  OUTIL(r, "Mono", @TX_MONO, "Police à chasse fixe (code)")
  FILET(r)
  ICONE(r, "moins", "Plus petit", "Réduire la taille", @TX_MOINS)
  ICONE(r, "plus", "Plus grand", "Augmenter la taille", @TX_PLUS)
  ICONE(r, "k-bold", "Gras", "Gras", @TX_GRAS)
  ICONE(r, "k-italic", "Italique", "Italique", @TX_ITALIQUE)
  ICONE(r, "k-alignl", "À gauche", "Aligner le texte à gauche", @TX_GAUCHE)
  ICONE(r, "k-alignc", "Centré", "Centrer le texte", @TX_CENTRE)
  ICONE(r, "k-alignr", "À droite", "Aligner le texte à droite", @TX_DROITE)
  FILET(r)
  pour chaque c dans THEME_COULEURS(DSN.theme)
    locale b = r:ajouter(ui.bouton("●", {plat = vrai}))
    b.couleur = c
    b.infobulle = "Couleur du texte " + c
    b.surclic = @NUANCE_CLIC
    b.largeurfixe = 28
    inserer(NUANCIER, {bouton = b, couleur = c})
  suivant
  ICONE(r, "palette", "Couleur…", "Choisir la couleur du texte", @COULEUR_CHOISIR)
  locale e = r:ajouter(ui.etiquette("  Double-clic : modifier le texte · Échap : terminer"))
  e.couleur = "#64748B"
retourner

fonction OUTILS_DESSIN()
retourner { ;
  {id = "selection", icone = "k-select", libelle = "Sélection", aide = "Sélection et déplacement (V)", proc = @OUTIL_SELECTION, touche = 118}, ;
  {id = "rectangle", icone = "k-rect", libelle = "Rectangle", aide = "Rectangle (R) ; Maj : carré", proc = @OUTIL_RECT, touche = 114}, ;
  {id = "ellipse", icone = "k-ellipse", libelle = "Ellipse", aide = "Ellipse (E) ; Maj : cercle", proc = @OUTIL_ELLIPSE, touche = 101}, ;
  {id = "ligne", icone = "k-line", libelle = "Ligne", aide = "Ligne (L) ; Maj : 45°", proc = @OUTIL_LIGNE, touche = 108}, ;
  {id = "fleche", icone = "k-arrow", libelle = "Flèche", aide = "Flèche (A)", proc = @OUTIL_FLECHE, touche = 97}, ;
  {id = "plume", icone = "k-pen", libelle = "Plume", aide = "Plume Bézier (P) : clic = point, glisser = courbe, clic sur le premier point = fermer, Entrée = finir", proc = @OUTIL_PLUME, touche = 112}, ;
  {id = "texte", icone = "k-text", libelle = "Texte", aide = "Texte (T) : cliquer ou tracer une boîte, puis taper", proc = @OUTIL_TEXTE, touche = 116}, ;
  {id = "image", icone = "k-image", libelle = "Image", aide = "Image (I) : choisir un fichier puis tracer sa place", proc = @OUTIL_IMAGE, touche = 105}, ;
  {id = "noeuds", icone = "k-nodes", libelle = "Nœuds", aide = "Édition des nœuds (N) : glisser nœuds et poignées, double-clic : ajouter / lisser", proc = @OUTIL_NOEUDS, touche = 110}, ;
  {id = "main", icone = "k-hand", libelle = "Main", aide = "Déplacer la vue (H, ou Espace + glisser)", proc = @OUTIL_MAIN, touche = 104}}

procedure OUTIL_ACTIVER(nom)
  toile:outil(nom)
  pour chaque k, b dans BOUTONS_OUTILS
    b.fond = sisinon(minuscule(k) = nom, "#4338CA", "")
  suivant
  STATUT("Outil : " + nom)
retourner

procedure OUTIL_SELECTION(ev)
  OUTIL_ACTIVER("selection")
retourner
procedure OUTIL_RECT(ev)
  OUTIL_ACTIVER("rectangle")
retourner
procedure OUTIL_ELLIPSE(ev)
  OUTIL_ACTIVER("ellipse")
retourner
procedure OUTIL_LIGNE(ev)
  OUTIL_ACTIVER("ligne")
retourner
procedure OUTIL_FLECHE(ev)
  OUTIL_ACTIVER("fleche")
retourner
procedure OUTIL_PLUME(ev)
  OUTIL_ACTIVER("plume")
retourner
procedure OUTIL_TEXTE(ev)
  OUTIL_ACTIVER("texte")
retourner
procedure OUTIL_NOEUDS(ev)
  OUTIL_ACTIVER("noeuds")
retourner
procedure OUTIL_MAIN(ev)
  OUTIL_ACTIVER("main")
retourner
procedure OUTIL_IMAGE(ev)
  locale f = ui.ouvrirfichier{titre = "Image à placer", filtre = "Images et PDF|*.png;*.jpg;*.jpeg;*.gif;*.bmp;*.svg;*.webp;*.pdf"}
  si f = nul
    retourner
  finsi
  locale dest = IMPORTER_MEDIA(f)
  si dest = nul
    retourner
  finsi
  locale t = pub.tailleimage(dest)
  toile:outil("image", {href = dest, ratio = sisinon(t = nul, 0, t.largeur / max(1, t.hauteur))})
  OUTIL_ACTIVER("image")
  STATUT("Tracez la place de l'image (un clic : taille par défaut).")
retourner

&& raccourcis d'outils (lettres seules, toile active)
procedure DESSIN_TOUCHE(ev)
  locale m = MODS(ev)
  si non (m.cmd ou m.alt) et ev.id:ensaisie()
    retourner
  finsi
  si non (m.cmd ou m.alt)
    pour chaque t dans OUTILS_DESSIN()
      si ev.touche = t.touche
        si t.id = "image"
          OUTIL_IMAGE(nul)
        sinon
          OUTIL_ACTIVER(t.id)
        finsi
        retourner
      finsi
    suivant
  finsi
  && raccourcis globaux (palette, espaces, F5…) : traités ici, une seule fois
  TOUCHE(ev)
  ev:arreter()
retourner

&&
&& Ouverture et enregistrement
&&

fonction SVG_VIDE(l, h)
retourner '<svg xmlns="http://www.w3.org/2000/svg" width="' + l + '" height="' + h + '" viewBox="0 0 ' + l + " " + h + '">' + ;
          '<rect id="fond" width="' + l + '" height="' + h + '" fill="#ffffff"/></svg>'

procedure DESSIN_NOUVEAU(ev)
  locale t = ui.demander("Titre de la nouvelle illustration :", "Illustration")
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale id = ENREGISTRER_COMPOSANT({titre = rogner(t), genre = "illustration", ext = "svg", dossier = "Illustrations", tags = {}}, SVG_VIDE(1200, 800), nul)
  RAFRAICHIR_BIBLIOTHEQUE()
  OUVRIR_ESPACE("dessin")
  DESSIN_OUVRIR_COMPOSANT(COMPOSANT(id), nul)
retourner

procedure DESSIN_CHARGER(cible, svg, dossier_)
  DESSIN_ENREGISTRER_SI_MODIFIE()
  DSN.cible = cible
  DSN.modifie = faux
  toile:chargersvg(svg, dossier_)
  toile:ajuster()
  CALQUES_RAFRAICHIR()
  OUTIL_ACTIVER("selection")
  DESSIN_TITRE()
retourner

procedure DESSIN_TITRE
  locale c = DSN.cible
  si c = nul
    retourner
  finsi
  locale d = toile:dimensions()
  lbldessin.libelle = c.libelle + "   ·   " + d.largeur + " × " + d.hauteur + "   ·   " + PLURIEL(#toile:formes(), "forme") + ;
                      sisinon(DSN.modifie, "   ·   ● modifié", "")
retourner

procedure DESSIN_OUVRIR_COMPOSANT(c, variante)
  locale f = FICHIER_COMPOSANT(c, variante)
  si non fichier.existe(f)
    f = FICHIER_COMPOSANT(c, nul)
  finsi
  DESSIN_CHARGER({genre = "composant", id = c.id, variante = variante, chemin = f, ;
                  libelle = "◆ " + c.titre + sisinon(variante <> nul, " @" + variante, "")}, LIRE_TEXTE(f), fichier.dossier(f))
retourner

procedure DESSIN_OUVRIR_IMAGE(c)
  && image bitmap : placée dans une illustration (le composant reste l'image)
  locale f = FICHIER_COMPOSANT(c, nul)
  locale t = pub.tailleimage(f)
  locale l = sisinon(t = nul, 800, t.largeur)
  locale h = sisinon(t = nul, 600, t.hauteur)
  locale svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + l + '" height="' + h + '"><image href="' + f + '" x="0" y="0" width="' + l + '" height="' + h + '"/></svg>'
  DESSIN_CHARGER({genre = "apercu", id = c.id, chemin = nul, libelle = "▣ " + c.titre + " (image : vectorisez-la pour l'éditer)"}, svg, CHEMIN("composants"))
retourner

&& diapositive ou scène : enregistrées automatiquement
procedure DESSIN_OUVRIR_FICHIER(genre, chemin_, libelle, rappel)
  DESSIN_CHARGER({genre = genre, chemin = chemin_, libelle = libelle, rappel = rappel}, LIRE_TEXTE(chemin_), fichier.dossier(chemin_))
retourner

procedure DESSIN_CHANGE(ev)
  DSN.modifie = vrai
  DSN.dernier = horodatage()
  locale a = toile:action()
  si a.action = "outil"
    OUTIL_ACTIVER(toile:outil())
  finsi
  si a.action = "creation"
    OUTIL_ACTIVER(toile:outil())
  finsi
  DESSIN_TITRE()
  DESSIN_PROPS()
retourner

procedure DESSIN_SELECTION(ev)
  DESSIN_PROPS()
  RUBAN_CONTEXTUEL()
retourner

procedure DESSIN_DOUBLE(ev)
  && double-clic sur un symbole lié : ouvrir son composant
  si ev.texte = ""
    retourner
  finsi
  locale f = toile:forme(ev.texte)
  si f <> nul et f.genre = "image" et f.donnees <> nul et COMPOSANT(PARTIE_ID(f.donnees)) <> nul
    OUVRIR_COMPOSANT(PARTIE_ID(f.donnees))
  finsi
retourner

fonction DESSIN_SEL_TEXTE()
  essayer
    locale s = toile:selection()
    si #s = 1
      locale f = toile:forme(s[1])
      retourner f <> nul et f.genre = "texte"
    finsi
  capturer e
  finessayer
retourner faux

procedure DESSIN_AUTOSAUVEGARDE
  si DSN = nul ou non DSN.modifie ou DSN.cible = nul
    retourner
  finsi
  si DSN.cible.genre <> "composant" et horodatage() - DSN.dernier > 1.2
    DESSIN_ENREGISTRER(nul)
  finsi
retourner

procedure DESSIN_ENREGISTRER_SI_MODIFIE
  si DSN <> nul et DSN.modifie et DSN.cible <> nul et DSN.cible.genre <> "composant" et DSN.cible.chemin <> nul
    DESSIN_ENREGISTRER(nul)
  finsi
retourner

procedure DESSIN_ENREGISTRER(ev)
  locale c = DSN.cible
  si c = nul ou c.chemin = nul
    retourner
  finsi
  locale svg = toile:svg{compact = vrai}
  si c.genre = "composant"
    locale comp = COMPOSANT(c.id)
    si svg = CONTENU_COMPOSANT(comp, c.variante)
      DSN.modifie = faux
      retourner
    finsi
    DEMANDER_IMPACT(comp, svg, c.variante, @DESSIN_APRES_IMPACT)
    retourner
  finsi
  ECRIRE_TEXTE(c.chemin, svg)
  DSN.modifie = faux
  DESSIN_TITRE()
  si c.rappel <> nul
    appeler(c.rappel, c)
  finsi
retourner

procedure DESSIN_APRES_IMPACT(res)
  si res <> nul
    DSN.modifie = faux
    DESSIN_TITRE()
  finsi
retourner

&&
&& Propriétés de la sélection (inspecteur)
&&

procedure DESSIN_PROPS
  globale PROPS_CIBLE
  locale s = toile:selection()
  si #s <> 1
    si #s > 1
      gprops:vider()
      PROP(gprops, "Sélection", PLURIEL(#s, "forme"))
      PROPS_CIBLE = nul
    finsi
    retourner
  finsi
  locale f = toile:forme(s[1])
  si f = nul
    retourner
  finsi
  gprops:vider()
  PROPS_CIBLE = {genre = "forme", id = s[1]}
  pour chaque k dans {"nom", "x", "y", "largeur", "hauteur", "rotation", "remplissage", "contour", "epaisseur", "pointilles", "opacite", ;
                      "rayon", "ombre", "texte", "police", "taille", "gras", "italique", "alignement", "interligne", "calque", "flechedebut", "flechefin", "donnees"}
    si f[k] <> nul
      locale v = f[k]
      si type(v) = "nombre"
        v = arrondi(v, 2)
      finsi
      PROP(gprops, k, v)
    finsi
  suivant
  droite.valeur = 1
retourner

&& modification depuis l'inspecteur (appelée par PROPS_CHANGEES)
procedure FORME_PROPS_CHANGEES(id)
  locale n = gprops:nombre()
  locale t = {}
  pour i = 1 a n
    t[gprops:cellule(i, 1)] = gprops:cellule(i, 2)
  suivant
  toile:modifier(id, t)
  DSN.modifie = vrai
  DSN.dernier = horodatage()
  DESSIN_TITRE()
retourner

&&
&& Commandes
&&

procedure AL_GAUCHE(ev)
  toile:aligner("gauche")
retourner
procedure AL_CENTRE(ev)
  toile:aligner("centre")
retourner
procedure AL_DROITE(ev)
  toile:aligner("droite")
retourner
procedure AL_HAUT(ev)
  toile:aligner("haut")
retourner
procedure AL_MILIEU(ev)
  toile:aligner("milieu")
retourner
procedure AL_BAS(ev)
  toile:aligner("bas")
retourner
procedure AL_REPH(ev)
  toile:aligner("repartirh")
retourner
procedure AL_REPV(ev)
  toile:aligner("repartirv")
retourner
procedure D_GROUPER(ev)
  toile:grouper()
retourner
procedure D_DEGROUPER(ev)
  toile:degrouper()
retourner
procedure D_AVANT(ev)
  toile:ordre("premierplan")
retourner
procedure D_ARRIERE(ev)
  toile:ordre("arriereplan")
retourner
procedure D_ANNULER(ev)
  toile:annuler()
retourner
procedure D_RETABLIR(ev)
  toile:retablir()
retourner
procedure D_AJUSTER(ev)
  toile:ajuster()
retourner
procedure B_UNION(ev)
  BOOLEEN("union")
retourner
procedure B_DIFF(ev)
  BOOLEEN("difference")
retourner
procedure B_INTER(ev)
  BOOLEEN("intersection")
retourner

procedure BOOLEEN(op)
  si #toile:selection() < 2
    STATUT("Choisissez au moins deux formes (Maj+clic).")
    retourner
  finsi
  si toile:booleen(op) = nul
    STATUT("Le résultat est vide.")
  sinon
    STATUT("Opération « " + op + " » appliquée : un seul chemin éditable (outil Nœuds).")
  finsi
retourner

procedure D_GRILLE(ev)
  locale g = toile:grille()
  toile:grille{visible = non g.visible, magnetisme = non g.visible, taille = 10}
  STATUT(sisinon(non g.visible, "Grille affichée et aimantée (10).", "Grille masquée."))
retourner

procedure D_MAGNET(ev)
  locale g = toile:grille()
  toile:grille{objets = non g.objets}
  STATUT(sisinon(non g.objets, "Guides intelligents activés.", "Guides intelligents désactivés."))
retourner

&& thèmes de couleurs (nuancier)
fonction THEME_COULEURS(nom)
  faire cas
  cas nom = "ocean"
    retourner {"#0F172A", "#0369A1", "#0EA5E9", "#38BDF8", "#14B8A6", "#F59E0B", "#F8FAFC"}
  cas nom = "foret"
    retourner {"#1A2E05", "#166534", "#22C55E", "#84CC16", "#CA8A04", "#B45309", "#FEFCE8"}
  fincas
retourner {"#0F172A", "#4F46E5", "#7C3AED", "#EC4899", "#0EA5E9", "#10B981", "#F59E0B", "#EF4444", "#FFFFFF"}

procedure NUANCE_CLIC(ev)
  locale coul = nul
  pour chaque n dans NUANCIER
    si n.bouton = ev.id
      coul = n.couleur
    finsi
  suivant
  si coul = nul
    retourner
  finsi
  APPLIQUER_COULEUR(coul, MODS(ev).alt)
retourner

procedure APPLIQUER_COULEUR(coul, contour)
  locale ids = toile:selection()
  si #ids = 0
    toile:style{remplissage = coul}
    STATUT("Couleur des prochaines formes : " + coul)
    retourner
  finsi
  si contour
    toile:modifier(ids, {contour = coul, epaisseur = 2})
  sinon
    toile:modifier(ids, {remplissage = coul})
  finsi
  DSN.modifie = vrai
  DSN.dernier = horodatage()
  DESSIN_PROPS()
retourner

procedure COULEUR_CHOISIR(ev)
  locale c = ui.couleur("#4F46E5")
  si c <> nul
    APPLIQUER_COULEUR(c, faux)
  finsi
retourner

&& texte
procedure TX(props)
  locale ids = toile:selection()
  si #ids > 0
    toile:modifier(ids, props)
    DSN.modifie = vrai
    DSN.dernier = horodatage()
    DESSIN_PROPS()
  finsi
retourner
procedure TX_POPPINS(ev)
  TX({police = "Poppins"})
retourner
procedure TX_LORA(ev)
  TX({police = "Lora"})
retourner
procedure TX_MONO(ev)
  TX({police = "Mono"})
retourner
procedure TX_PLUS(ev)
  locale f = toile:forme(toile:selection()[1])
  TX({taille = arrondi(f.taille * 1.15)})
retourner
procedure TX_MOINS(ev)
  locale f = toile:forme(toile:selection()[1])
  TX({taille = max(6, arrondi(f.taille / 1.15))})
retourner
procedure TX_GRAS(ev)
  locale f = toile:forme(toile:selection()[1])
  TX({gras = non f.gras})
retourner
procedure TX_ITALIQUE(ev)
  locale f = toile:forme(toile:selection()[1])
  TX({italique = non f.italique})
retourner
procedure TX_GAUCHE(ev)
  TX({alignement = "gauche"})
retourner
procedure TX_CENTRE(ev)
  TX({alignement = "centre"})
retourner
procedure TX_DROITE(ev)
  TX({alignement = "droite"})
retourner

&&
&& Calques
&&

procedure CALQUES_RAFRAICHIR
  lcalques:vider()
  locale cs = toile:calques()
  pour i = #cs a 1 pas -1
    locale c = cs[i]
    lcalques:ajouter(sisinon(c.visible, "◉ ", "   ") + sisinon(c.verrouille, "⊘ ", "") + c.nom + "  (" + c.formes + ")")
  suivant
retourner

fonction CALQUE_CHOISI()
  locale i = nombre(lcalques:selection())
  locale cs = toile:calques()
  si i = nul ou i < 1 ou i > #cs
    retourner nul
  finsi
retourner cs[#cs - i + 1]

procedure CALQUE_CHOIX(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul
    STATUT("Calque « " + c.nom + " »")
  finsi
retourner

procedure CALQUE_NOUVEAU(ev)
  locale n = ui.demander("Nom du calque :", "Calque " + (#toile:calques() + 1))
  si n <> nul et rogner(n) <> ""
    toile:calque(rogner(n))
    CALQUES_RAFRAICHIR()
    DSN.modifie = vrai
  finsi
retourner

procedure CALQUE_VISIBLE(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul
    toile:calque(c.nom, {visible = non c.visible})
    CALQUES_RAFRAICHIR()
  finsi
retourner

procedure CALQUE_VERROU(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul
    toile:calque(c.nom, {verrouille = non c.verrouille})
    CALQUES_RAFRAICHIR()
  finsi
retourner

procedure CALQUE_MONTER(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul
    toile:calque(c.nom, {monter = vrai})
    CALQUES_RAFRAICHIR()
    DSN.modifie = vrai
  finsi
retourner

procedure CALQUE_DESCENDRE(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul
    toile:calque(c.nom, {descendre = vrai})
    CALQUES_RAFRAICHIR()
    DSN.modifie = vrai
  finsi
retourner

procedure CALQUE_RENOMMER(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul
    locale n = ui.demander("Nouveau nom du calque :", c.nom)
    si n <> nul et rogner(n) <> ""
      toile:calque(c.nom, {renommer = rogner(n)})
      CALQUES_RAFRAICHIR()
      DSN.modifie = vrai
    finsi
  finsi
retourner

procedure CALQUE_SUPPRIMER(ev)
  locale c = CALQUE_CHOISI()
  si c <> nul et ui.confirmer("Supprimer le calque « " + c.nom + " » et ses " + c.formes + " forme(s) ?", "attention")
    toile:calque(c.nom, {supprimer = vrai})
    CALQUES_RAFRAICHIR()
    DSN.modifie = vrai
  finsi
retourner

&&
&& Bibliothèque d'objets et styles graphiques
&&

fonction OBJETS()
retourner { ;
  {nom = "★ Étoile", genre = "chemin", chemin = "M 50 0 L 61 35 L 98 35 L 68 57 L 79 91 L 50 70 L 21 91 L 32 57 L 2 35 L 39 35 Z", remplissage = "#F59E0B"}, ;
  {nom = "→ Flèche épaisse", genre = "chemin", chemin = "M 0 30 L 60 30 L 60 10 L 100 50 L 60 90 L 60 70 L 0 70 Z", remplissage = "#4F46E5"}, ;
  {nom = "◇ Bulle", genre = "chemin", chemin = "M 10 0 L 90 0 C 96 0 100 4 100 10 L 100 60 C 100 66 96 70 90 70 L 40 70 L 20 90 L 24 70 L 10 70 C 4 70 0 66 0 60 L 0 10 C 0 4 4 0 10 0 Z", remplissage = "#E0E7FF"}, ;
  {nom = "☁ Nuage", genre = "chemin", chemin = "M 25 70 C 5 70 0 50 15 42 C 10 22 35 12 45 25 C 52 5 85 8 85 32 C 100 34 100 70 80 70 Z", remplissage = "#BAE6FD"}, ;
  {nom = "◆ Losange", genre = "chemin", chemin = "M 50 0 L 100 50 L 50 100 L 0 50 Z", remplissage = "#EC4899"}, ;
  {nom = "⬢ Hexagone", genre = "chemin", chemin = "M 25 0 L 75 0 L 100 43 L 75 86 L 25 86 L 0 43 Z", remplissage = "#10B981"}, ;
  {nom = "▭ Carte arrondie", genre = "rectangle", rayon = 18, remplissage = "#FFFFFF", contour = "#E2E8F0", ombre = vrai}, ;
  {nom = "● Pastille", genre = "ellipse", remplissage = "#4F46E5"}, ;
  {nom = "⌸ Base de données", genre = "chemin", chemin = "M 0 15 C 0 -5 100 -5 100 15 L 100 85 C 100 105 0 105 0 85 Z M 0 15 C 0 35 100 35 100 15", remplissage = "#0EA5E9"}, ;
  {nom = "▭ Écran", genre = "chemin", chemin = "M 0 0 L 100 0 L 100 62 L 0 62 Z M 40 62 L 60 62 L 64 80 L 36 80 Z", remplissage = "#334155"}, ;
  {nom = "◉ Personnage", genre = "chemin", chemin = "M 50 0 C 64 0 72 10 72 22 C 72 34 64 44 50 44 C 36 44 28 34 28 22 C 28 10 36 0 50 0 Z M 10 100 C 10 70 30 54 50 54 C 70 54 90 70 90 100 Z", remplissage = "#64748B"}, ;
  {nom = "▤ Document", genre = "chemin", chemin = "M 0 0 L 70 0 L 100 30 L 100 120 L 0 120 Z M 70 0 L 70 30 L 100 30", remplissage = "#F8FAFC", contour = "#94A3B8"}, ;
  {nom = "T Titre", genre = "texte", texte = "Titre", police = "Poppins", taille = 48, gras = vrai, remplissage = "#0F172A"}, ;
  {nom = "T Paragraphe", genre = "texte", texte = "Un paragraphe de texte qui revient à la ligne dans sa boîte.", police = "Lora", taille = 20, remplissage = "#334155", largeur = 360}}

procedure OBJET_INSERER(ev)
  locale i = nombre(lobjets:selection())
  locale o = OBJETS()[i]
  si o = nul
    retourner
  finsi
  locale d = toile:dimensions()
  locale props = copier(o)
  props.nom = nul
  props.x = d.largeur / 2 - 80
  props.y = d.hauteur / 2 - 80
  si props.largeur = nul
    props.largeur = 160
  finsi
  si props.hauteur = nul et o.genre <> "texte"
    props.hauteur = 160
  finsi
  toile:ajouter(props)
  DSN.modifie = vrai
  DESSIN_TITRE()
retourner

fonction STYLES_GRAPHIQUES()
retourner { ;
  {nom = "Carte (blanc, ombre, coins arrondis)", props = {remplissage = "#FFFFFF", contour = "#E2E8F0", epaisseur = 1, ombre = vrai, rayon = 16}}, ;
  {nom = "Accent (indigo plein)", props = {remplissage = "#4F46E5", contour = "none", ombre = faux}}, ;
  {nom = "Dégradé Aurore", props = {remplissage = "linear(135,#6366F1,#EC4899)", contour = "none"}}, ;
  {nom = "Dégradé Océan", props = {remplissage = "linear(90,#0EA5E9,#14B8A6)", contour = "none"}}, ;
  {nom = "Contour seul", props = {remplissage = "none", contour = "#0F172A", epaisseur = 2}}, ;
  {nom = "Pointillés", props = {remplissage = "none", contour = "#64748B", epaisseur = 2, pointilles = "6 4"}}, ;
  {nom = "Verre (semi-transparent)", props = {remplissage = "#FFFFFF", opacite = 0.55, contour = "#FFFFFF", epaisseur = 1}}, ;
  {nom = "Sombre", props = {remplissage = "#0F172A", contour = "none"}}}

procedure STYLE_APPLIQUER(ev)
  locale i = nombre(lstyles:selection())
  locale s = STYLES_GRAPHIQUES()[i]
  locale ids = toile:selection()
  si s = nul ou #ids = 0
    STATUT("Choisissez des formes, puis double-cliquez un style.")
    retourner
  finsi
  toile:modifier(ids, s.props)
  DSN.modifie = vrai
  DSN.dernier = horodatage()
  DESSIN_PROPS()
retourner

&&
&& Symboles : composants liés (modifier le composant met à jour toutes ses occurrences)
&&

procedure DESSIN_INSERER_COMPOSANT(c)
  si DSN.cible = nul
    ui.alerte("Ouvrez d'abord une illustration, une diapositive ou une scène.", "information")
    retourner
  finsi
  locale f = FICHIER_COMPOSANT(c, nul)
  locale d = toile:dimensions()
  locale l = 240
  locale h = 160
  si c.ext = "svg" ou GENRE_IMAGE(c.genre)
    locale t = pub.tailleimage(f)
    si t <> nul
      h = l * t.hauteur / max(1, t.largeur)
    finsi
    toile:ajouter{genre = "image", image = f, x = (d.largeur - l) / 2, y = (d.hauteur - h) / 2, largeur = l, hauteur = h, donnees = c.id, nom = c.titre}
  sinon
    toile:ajouter{genre = "texte", texte = pub.textebrut(CONTENU_COMPOSANT(c, nul)), police = "Lora", taille = 22, ;
                  x = d.largeur * 0.1, y = d.hauteur * 0.3, largeur = d.largeur * 0.8, donnees = c.id, nom = c.titre, remplissage = "#1F2937"}
  finsi
  DSN.modifie = vrai
  DSN.dernier = horodatage()
  DESSIN_TITRE()
retourner

procedure DESSIN_SYMBOLE(ev)
  si #toile:selection() = 0
    ui.alerte("Sélectionnez les formes qui composeront le symbole.", "information")
    retourner
  finsi
  locale t = ui.demander("Nom du symbole :", "Symbole")
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale svg = toile:svg{selection = vrai, compact = vrai}
  locale id = ENREGISTRER_COMPOSANT({titre = rogner(t), genre = "illustration", ext = "svg", dossier = "Symboles", tags = {"symbole"}}, svg, nul)
  RAFRAICHIR_BIBLIOTHEQUE()
  && la sélection est remplacée par une occurrence liée du symbole
  locale b = toile:boite()
  toile:supprimer()
  toile:ajouter{genre = "image", image = FICHIER_COMPOSANT(COMPOSANT(id), nul), x = b.x - 2, y = b.y - 2, largeur = b.largeur + 4, hauteur = b.hauteur + 4, donnees = id, nom = rogner(t)}
  DSN.modifie = vrai
  STATUT("Symbole « " + t + " » créé : ses occurrences suivent ses modifications.")
retourner

procedure DESSIN_OPTIMISER(ev)
  locale r = pub.optimisersvg(toile:svg{compact = vrai}, {simplifier = 0.4, nettoyer = 2, fusionner = vrai})
  toile:memoriser()
  toile:chargersvg(r.svg, sisinon(DSN.cible = nul ou DSN.cible.chemin = nul, ".", fichier.dossier(DSN.cible.chemin)))
  DSN.modifie = vrai
  CALQUES_RAFRAICHIR()
  DESSIN_TITRE()
  STATUT("SVG optimisé : " + OCTETS(r.avant) + " → " + OCTETS(r.apres) + ".")
retourner

procedure DESSIN_IMPORTER(ev)
  VECTORISER_DIALOGUE(nul)
retourner

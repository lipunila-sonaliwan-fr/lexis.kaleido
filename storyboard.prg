&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : storyboards.
&&
&& storyboards/<nom>.json : {titre, format, personnages = {{nom, couleur, description}},
&&   scenes = {{id, titre, sequence, duree, personnages, medias, commentaire, annotations, svg}}}
&& Plateau : vignettes en temps réel, glisser-déposer pour réordonner (mode plateau de la
&& toile) ; timeline (Gantt) colorée par séquence ; fiche de la scène ; double-clic : la scène
&& s'ouvre dans l'éditeur SVG (médias de la bibliothèque, personnages, annotations).

procedure CONSTRUIRE_STORYBOARD(o)
  globale plateau, timeline, SB_COURANT, SB_INDEX, lblsb, gscene
  SB_COURANT = nul
  SB_INDEX = 1
  lblsb = o:ajouter(ui.etiquette("Aucun storyboard : Fichier ▸ Nouveau storyboard."))
  lblsb.ancrage = "haut"
  lblsb.couleur = "#CBD5E1"
  locale sep = o:ajouter(ui.separateur{vertical = faux, position = 0.68})
  sep.ancrage = "centre"
  locale sep2 = sep:ajouter(ui.separateur{vertical = vrai, position = 0.74})
  plateau = sep2:ajouter(ui.toile{mode = "plateau"})
  plateau.surselection = @SB_CHOIX
  plateau.surdoubleclic = @SB_DOUBLE
  plateau.surchangement = @SB_DEPLACE
  gscene = sep2:ajouter(ui.grille())
  gscene:ajoutercolonne{nom = "prop", titre = "Scène", largeur = 110}
  gscene:ajoutercolonne{nom = "valeur", titre = "", largeur = 260}
  gscene:fixermodifiable(vrai)
  gscene.surchangement = @SB_FICHE_CHANGEE
  timeline = sep:ajouter(ui.gantt())
  timeline.surselection = @SB_TIMELINE_CHOIX
retourner

procedure RUBAN_STORYBOARD(r)
  ICONE(r, "nouveau", "Nouveau storyboard", "Nouveau storyboard", @SB_NOUVEAU)
  ICONE(r, "k-scene", "Nouvelle scène", "Ajouter une scène après la courante", @SB_AJOUTER)
  ICONE(r, "dupliquer", "Dupliquer", "Dupliquer la scène", @SB_DUPLIQUER)
  ICONE(r, "supprimer", "Supprimer", "Supprimer la scène", @SB_SUPPRIMER)
  ICONE(r, "k-up", "Avant", "Déplacer la scène vers le début", @SB_MONTER)
  ICONE(r, "k-down", "Après", "Déplacer la scène vers la fin", @SB_DESCENDRE)
  FILET(r)
  ICONE(r, "k-pen", "Dessiner", "Ouvrir la scène dans l'éditeur SVG", @SB_DESSINER)
  ICONE(r, "k-character", "Personnages", "Personnages du storyboard", @SB_PERSONNAGES)
  ICONE(r, "k-comment", "Annoter", "Ajouter une annotation à la scène", @SB_ANNOTER)
  FILET(r)
  OUTIL(r, "Vignettes : 3", @SB_COL3, "Trois scènes par ligne")
  OUTIL(r, "4", @SB_COL4, "Quatre scènes par ligne")
  OUTIL(r, "6", @SB_COL6, "Six scènes par ligne")
  FILET(r)
  ICONE(r, "k-play", "Animatique", "Lire le storyboard (chaque scène pendant sa durée)", @SB_LIRE)
  ICONE(r, "pdf", "PDF", "Planches PDF (6 scènes par page, avec légendes)", @SB_PDF)
retourner

&& vignette d'une scène : cadre 16:9 avec médias et personnages (générée tant que la scène
&& n'a pas été dessinée à la main)
fonction SCENE_SVG(d, s)
  locale W = 1280
  locale H = 720
  locale svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + W + '" height="' + H + '"><rect id="fond" width="' + W + '" height="' + H + '" fill="#F8FAFC"/>'
  svg = svg + '<g data-calque="Décor"><rect x="0" y="560" width="' + W + '" height="160" fill="#E2E8F0"/>' + ;
        '<line x1="0" y1="560" x2="' + W + '" y2="560" stroke="#CBD5E1" stroke-width="2"/></g><g data-calque="Médias">'
  locale medias = sisinon(s.medias = nul, {}, s.medias)
  locale n = #medias
  locale i = 0
  pour chaque m dans medias
    locale l = sisinon(n = 1, 640, 420)
    locale x = sisinon(n = 1, 320, 80 + i * (1120 / max(1, n)))
    svg = svg + MEDIA_SVG(m, x, 140, l, 400)
    i += 1
  suivant
  svg = svg + '</g><g data-calque="Personnages">'
  i = 0
  pour chaque p dans sisinon(s.personnages = nul, {}, s.personnages)
    locale coul = "#64748B"
    pour chaque q dans sisinon(d.personnages = nul, {}, d.personnages)
      si q.nom = p
        coul = sisinon(q.couleur = nul, coul, q.couleur)
      finsi
    suivant
    locale x = 140 + i * 260
    svg = svg + '<circle cx="' + (x + 50) + '" cy="430" r="38" fill="' + coul + '"/>' + ;
          '<path d="M ' + (x) + ' 560 C ' + x + ' 490 ' + (x + 20) + ' 470 ' + (x + 50) + ' 470 C ' + (x + 80) + ' 470 ' + (x + 100) + ' 490 ' + (x + 100) + ' 560 Z" fill="' + coul + '"/>' + ;
          SVG_TEXTE(x - 30, 575, 160, p, "Poppins", 22, "#334155", vrai, nul, 1.1)
    i += 1
  suivant
  svg = svg + '</g><g data-calque="Annotations">'
  si s.commentaire <> nul et s.commentaire <> ""
    svg = svg + '<rect x="40" y="36" width="560" height="74" rx="14" fill="#FEF3C7" stroke="#F59E0B" stroke-width="2"/>' + ;
          SVG_TEXTE(60, 46, 520, COURT(s.commentaire, 90), "Poppins", 22, "#92400E", faux, nul, 1.2)
  finsi
retourner svg + "</g></svg>"

procedure SCENE_ECRIRE(d, s)
  si s.svg = nul
    s.svg = "storyboards/" + d.nom + "/" + s.id + ".svg"
  finsi
  si non s.dessinee ou non fichier.existe(CHEMIN(s.svg))
    ECRIRE_TEXTE(CHEMIN(s.svg), SCENE_SVG(d, s))
  finsi
retourner

procedure SB_ACTIVER
  si SB_COURANT = nul et #SB > 0
    SB_OUVRIR(SB[1].nom)
  finsi
retourner

procedure SB_OUVRIR(nom)
  globale SB_COURANT, SB_INDEX
  SB_COURANT = STORYBOARD(nom)
  si SB_COURANT = nul
    retourner
  finsi
  si SB_COURANT.colonnes = nul
    SB_COURANT.colonnes = 4
  finsi
  pour chaque s dans SB_COURANT.scenes
    si s.svg = nul ou non fichier.existe(CHEMIN(s.svg))
      SCENE_ECRIRE(SB_COURANT, s)
    finsi
  suivant
  SB_INDEX = 1
  SB_RAFRAICHIR()
  SELECTIONNER("storyboard", nom)
retourner

procedure SB_RAFRAICHIR
  si SB_COURANT = nul
    retourner
  finsi
  locale d = SB_COURANT
  locale pages = {}
  locale leg = {}
  locale i = 1
  locale total = 0
  pour chaque s dans d.scenes
    inserer(pages, CHEMIN(s.svg))
    inserer(leg, i + " · " + COURT(s.titre, 30) + " · " + sisinon(s.duree = nul, 0, s.duree) + " s" + sisinon(s.sequence <> nul et s.sequence <> "", " · " + s.sequence, ""))
    total += sisinon(s.duree = nul, 0, s.duree)
    i += 1
  suivant
  plateau:chargerpages(pages, {colonnes = d.colonnes, ecart = 36, legendes = leg, choisie = SB_INDEX, garderposition = vrai})
  && timeline : une barre par scène, couleur par séquence
  timeline:vider()
  timeline:horaire(faux)
  locale t = 0
  locale seqs = {}
  locale palette = {"#6366F1", "#EC4899", "#10B981", "#F59E0B", "#0EA5E9", "#8B5CF6", "#EF4444"}
  pour chaque s dans d.scenes
    locale sq = sisinon(s.sequence = nul ou s.sequence = "", "—", s.sequence)
    si seqs[sq] = nul
      seqs[sq] = palette[(nbelements(seqs) % #palette) + 1]
    finsi
    locale du = max(1, sisinon(s.duree = nul, 5, s.duree))
    timeline:ajoutertache(COURT(s.titre, 28), t, du, 0, seqs[sq], sq + " · " + du + " s")
    t += du
  suivant
  lblsb.libelle = "◫ " + d.titre + "   ·   " + PLURIEL(#d.scenes, "scène") + "   ·   " + PLURIEL(nbelements(seqs), "séquence") + "   ·   durée " + ;
                  entier(total / 60) + " min " + (total % 60) + " s   ·   glissez une vignette pour réordonner"
  SB_FICHE()
retourner

procedure SB_FICHE
  gscene:vider()
  si SB_COURANT = nul ou #SB_COURANT.scenes = 0
    retourner
  finsi
  locale s = SB_COURANT.scenes[SB_INDEX]
  PROP(gscene, "Numéro", SB_INDEX)
  PROP(gscene, "Titre", s.titre)
  PROP(gscene, "Séquence", sisinon(s.sequence = nul, "", s.sequence))
  PROP(gscene, "Durée (s)", sisinon(s.duree = nul, 5, s.duree))
  PROP(gscene, "Personnages", joindre(sisinon(s.personnages = nul, {}, s.personnages), ", "))
  PROP(gscene, "Médias", joindre(sisinon(s.medias = nul, {}, s.medias), ", "))
  PROP(gscene, "Commentaire", sisinon(s.commentaire = nul, "", s.commentaire))
  PROP(gscene, "Annotations", joindre(sisinon(s.annotations = nul, {}, s.annotations), " | "))
  PROP(gscene, "Dessinée", sisinon(s.dessinee, "oui (retouchée)", "non (générée)"))
retourner

procedure SB_FICHE_CHANGEE(ev)
  si SB_COURANT = nul
    retourner
  finsi
  locale s = SB_COURANT.scenes[SB_INDEX]
  locale v = {}
  pour i = 1 a gscene:nombre()
    v[gscene:cellule(i, 1)] = gscene:cellule(i, 2)
  suivant
  s.titre = v["Titre"]
  s.sequence = v["Séquence"]
  s.duree = max(1, valeur(v["Durée (s)"]))
  s.personnages = LISTE_DE(v["Personnages"])
  s.medias = LISTE_DE(v["Médias"])
  s.commentaire = v["Commentaire"]
  s.annotations = {}
  pour chaque a dans decouper(v["Annotations"], "|")
    si rogner(a) <> ""
      inserer(s.annotations, rogner(a))
    finsi
  suivant
  SCENE_ECRIRE(SB_COURANT, s)
  ENREGISTRER_STORYBOARD(SB_COURANT)
  SB_RAFRAICHIR()
retourner

procedure SB_CHOIX(ev)
  si commencepar(ev.texte, "page-")
    globale SB_INDEX
    SB_INDEX = nombre(souschaine(ev.texte, 6))
    SB_FICHE()
  finsi
retourner

procedure SB_TIMELINE_CHOIX(ev)
  si ev.index <> nul et ev.index >= 1
    globale SB_INDEX
    SB_INDEX = ev.index
    plateau:selectionner("groupe:page-" + SB_INDEX)
    plateau:montrer("page-" + SB_INDEX)
    SB_FICHE()
  finsi
retourner

&& glisser-déposer : la position finale de la vignette donne son nouveau rang
procedure SB_DEPLACE(ev)
  locale a = plateau:action()
  si non commencepar(a.action, "deplace:page-")
    retourner
  finsi
  locale i = nombre(souschaine(a.action, 14))
  locale b = plateau:boite()
  locale cx = b.x + b.largeur / 2
  locale cy = b.y + b.hauteur / 2
  && rang visé d'après les cases de la grille (cellules de taille constante)
  locale cols = SB_COURANT.colonnes
  locale cellw = 1280 + 36
  locale cellh = 720 + 36 + max(18, 1280 * 0.045) * 1.9
  locale col = max(0, min(cols - 1, entier((cx - 36) / cellw)))
  locale ligne = max(0, entier((cy - 36) / cellh))
  locale cible = min(#SB_COURANT.scenes, ligne * cols + col + 1)
  si cible <> i
    locale s = retirer(SB_COURANT.scenes, i)
    inserer(SB_COURANT.scenes, s, cible)
    ENREGISTRER_STORYBOARD(SB_COURANT)
    STATUT("Scène déplacée de la position " + i + " à " + cible + ".")
  finsi
  globale SB_INDEX
  SB_INDEX = cible
  SB_RAFRAICHIR()
retourner

procedure SB_DOUBLE(ev)
  SB_DESSINER(nul)
retourner

procedure SB_DESSINER(ev)
  si SB_COURANT = nul
    retourner
  finsi
  locale s = SB_COURANT.scenes[SB_INDEX]
  OUVRIR_ESPACE("dessin")
  DESSIN_OUVRIR_FICHIER("scene", CHEMIN(s.svg), "◫ " + SB_COURANT.titre + " · scène " + SB_INDEX + " · " + s.titre, @SB_APRES_DESSIN)
retourner

procedure SB_APRES_DESSIN(cible)
  pour chaque d dans SB
    pour chaque s dans d.scenes
      si CHEMIN(s.svg) = cible.chemin
        s.dessinee = vrai
        ENREGISTRER_STORYBOARD(d)
      finsi
    suivant
  suivant
  si SB_COURANT <> nul
    SB_RAFRAICHIR()
  finsi
retourner

procedure SB_NOUVEAU(ev)
  locale t = ui.demander("Titre du storyboard :", "Nouveau storyboard")
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale existants = {}
  pour chaque d dans SB
    existants[d.nom] = vrai
  suivant
  locale nom = IDENT(t, existants)
  locale d = {nom = nom, titre = rogner(t), colonnes = 4, personnages = {{nom = "Héros", couleur = "#6366F1"}}, scenes = {}}
  pour i = 1 a 4
    inserer(d.scenes, {id = "s" + i, titre = "Scène " + i, sequence = "Acte 1", duree = 5, personnages = {"Héros"}, medias = {}, commentaire = "", annotations = {}})
  suivant
  pour chaque s dans d.scenes
    SCENE_ECRIRE(d, s)
  suivant
  inserer(SB, d)
  ENREGISTRER_STORYBOARD(d)
  PROJET_ARBRE()
  OUVRIR_ESPACE("storyboard")
  SB_OUVRIR(nom)
retourner

fonction NOUVEL_ID_SCENE(d)
  locale n = #d.scenes + 1
  tantque vrai
    locale id = "s" + n
    locale ok = vrai
    pour chaque s dans d.scenes
      si s.id = id
        ok = faux
      finsi
    suivant
    si ok
      retourner id
    finsi
    n += 1
  fintantque
retourner "s0"

procedure SB_AJOUTER(ev)
  si SB_COURANT = nul
    SB_NOUVEAU(nul)
    retourner
  finsi
  locale prec = SB_COURANT.scenes[SB_INDEX]
  locale s = {id = NOUVEL_ID_SCENE(SB_COURANT), titre = "Nouvelle scène", sequence = sisinon(prec = nul, "", prec.sequence), duree = 5, ;
              personnages = {}, medias = {}, commentaire = "", annotations = {}}
  SCENE_ECRIRE(SB_COURANT, s)
  inserer(SB_COURANT.scenes, s, SB_INDEX + 1)
  globale SB_INDEX
  SB_INDEX += 1
  ENREGISTRER_STORYBOARD(SB_COURANT)
  SB_RAFRAICHIR()
retourner

procedure SB_DUPLIQUER(ev)
  si SB_COURANT = nul
    retourner
  finsi
  locale s = copier(SB_COURANT.scenes[SB_INDEX])
  locale src = CHEMIN(s.svg)
  s.id = NOUVEL_ID_SCENE(SB_COURANT)
  s.svg = "storyboards/" + SB_COURANT.nom + "/" + s.id + ".svg"
  ECRIRE_TEXTE(CHEMIN(s.svg), LIRE_TEXTE(src))
  inserer(SB_COURANT.scenes, s, SB_INDEX + 1)
  globale SB_INDEX
  SB_INDEX += 1
  ENREGISTRER_STORYBOARD(SB_COURANT)
  SB_RAFRAICHIR()
retourner

procedure SB_SUPPRIMER(ev)
  si SB_COURANT = nul ou #SB_COURANT.scenes <= 1
    retourner
  finsi
  si ui.confirmer("Supprimer la scène " + SB_INDEX + " ?", "attention")
    retirer(SB_COURANT.scenes, SB_INDEX)
    globale SB_INDEX
    SB_INDEX = max(1, min(SB_INDEX, #SB_COURANT.scenes))
    ENREGISTRER_STORYBOARD(SB_COURANT)
    SB_RAFRAICHIR()
  finsi
retourner

procedure SB_MONTER(ev)
  si SB_COURANT <> nul et SB_INDEX > 1
    locale s = retirer(SB_COURANT.scenes, SB_INDEX)
    inserer(SB_COURANT.scenes, s, SB_INDEX - 1)
    globale SB_INDEX
    SB_INDEX -= 1
    ENREGISTRER_STORYBOARD(SB_COURANT)
    SB_RAFRAICHIR()
  finsi
retourner

procedure SB_DESCENDRE(ev)
  si SB_COURANT <> nul et SB_INDEX < #SB_COURANT.scenes
    locale s = retirer(SB_COURANT.scenes, SB_INDEX)
    inserer(SB_COURANT.scenes, s, SB_INDEX + 1)
    globale SB_INDEX
    SB_INDEX += 1
    ENREGISTRER_STORYBOARD(SB_COURANT)
    SB_RAFRAICHIR()
  finsi
retourner

procedure SB_COL3(ev)
  SB_COLONNES(3)
retourner
procedure SB_COL4(ev)
  SB_COLONNES(4)
retourner
procedure SB_COL6(ev)
  SB_COLONNES(6)
retourner
procedure SB_COLONNES(n)
  si SB_COURANT <> nul
    SB_COURANT.colonnes = n
    ENREGISTRER_STORYBOARD(SB_COURANT)
    SB_RAFRAICHIR()
    plateau:ajuster(vrai)
  finsi
retourner

procedure SB_PERSONNAGES(ev)
  si SB_COURANT = nul
    retourner
  finsi
  locale t = ""
  pour chaque p dans sisinon(SB_COURANT.personnages = nul, {}, SB_COURANT.personnages)
    t = t + p.nom + " | " + sisinon(p.couleur = nul, "#64748B", p.couleur) + " | " + sisinon(p.description = nul, "", p.description) + car(10)
  suivant
  EDITER_TEXTE("Personnages de « " + SB_COURANT.titre + " »", "Un personnage par ligne : nom | couleur | description", t, @SB_PERSOS_VALIDES)
retourner

procedure SB_PERSOS_VALIDES(r)
  SB_COURANT.personnages = {}
  pour chaque l dans LIGNES(r)
    si rogner(l) <> ""
      locale p = decouper(l, "|")
      inserer(SB_COURANT.personnages, {nom = rogner(p[1]), couleur = sisinon(#p > 1, rogner(sisinon(p[2] = nul, "", p[2])), "#64748B"), description = sisinon(#p > 2, rogner(sisinon(p[3] = nul, "", p[3])), "")})
    finsi
  suivant
  pour chaque s dans SB_COURANT.scenes
    SCENE_ECRIRE(SB_COURANT, s)
  suivant
  ENREGISTRER_STORYBOARD(SB_COURANT)
  SB_RAFRAICHIR()
retourner

procedure SB_ANNOTER(ev)
  si SB_COURANT = nul
    retourner
  finsi
  locale s = SB_COURANT.scenes[SB_INDEX]
  locale a = ui.demander("Annotation pour la scène " + SB_INDEX + " (cadrage, son, intention…) :", "")
  si a <> nul et rogner(a) <> ""
    si s.annotations = nul
      s.annotations = {}
    finsi
    inserer(s.annotations, heure() + " — " + rogner(a))
    si s.commentaire = nul ou s.commentaire = ""
      s.commentaire = rogner(a)
      SCENE_ECRIRE(SB_COURANT, s)
    finsi
    ENREGISTRER_STORYBOARD(SB_COURANT)
    SB_RAFRAICHIR()
  finsi
retourner

procedure SB_INSERER_COMPOSANT(c)
  si SB_COURANT = nul
    retourner
  finsi
  locale s = SB_COURANT.scenes[SB_INDEX]
  si s.medias = nul
    s.medias = {}
  finsi
  si non LISTE_CONTIENT(s.medias, c.id)
    inserer(s.medias, c.id)
  finsi
  SCENE_ECRIRE(SB_COURANT, s)
  ENREGISTRER_STORYBOARD(SB_COURANT)
  SB_RAFRAICHIR()
  STATUT("« " + c.titre + " » ajouté aux médias de la scène " + SB_INDEX + ".")
retourner

procedure SB_COMPOSANT_MODIFIE(id)
  pour chaque d dans SB
    locale touche = faux
    pour chaque s dans d.scenes
      si non s.dessinee et LISTE_CONTIENT(sisinon(s.medias = nul, {}, s.medias), id)
        SCENE_ECRIRE(d, s)
        touche = vrai
      finsi
    suivant
    si touche et SB_COURANT <> nul et d.nom = SB_COURANT.nom
      SB_RAFRAICHIR()
    finsi
  suivant
retourner

&& animatique : chaque scène pendant sa durée, dans la fenêtre de conférence
procedure SB_LIRE(ev)
  si SB_COURANT = nul
    retourner
  finsi
  globale fenconf, conf_toile, ANIM
  ANIM = {index = 1, debut = horodatage()}
  fenconf = ui.fenetre{titre = SB_COURANT.titre, largeur = 1280, hauteur = 760, disposition = "bordure", sombre = vrai}
  fenconf.surtouchebas = @ANIM_TOUCHE
  fenconf.surfermeture = @ANIM_FERMEE
  conf_toile = fenconf:ajouter(ui.toile{mode = "lecture"})
  conf_toile.ancrage = "centre"
  globale anim_leg
  anim_leg = fenconf:ajouter(ui.etiquette(""))
  anim_leg.ancrage = "bas"
  ANIM_AFFICHER()
  ui.minuterie(200, @ANIM_TIC, vrai)
retourner

procedure ANIM_AFFICHER
  locale s = SB_COURANT.scenes[ANIM.index]
  conf_toile:chargerfichier(CHEMIN(s.svg))
  conf_toile:ajuster()
  anim_leg.libelle = "  " + ANIM.index + " / " + #SB_COURANT.scenes + " · " + s.titre + " · " + sisinon(s.commentaire = nul, "", s.commentaire)
  ANIM.debut = horodatage()
retourner

procedure ANIM_TIC(ev)
  si ANIM = nul ou fenconf = nul
    retourner
  finsi
  locale s = SB_COURANT.scenes[ANIM.index]
  si horodatage() - ANIM.debut >= sisinon(s.duree = nul, 5, s.duree)
    si ANIM.index < #SB_COURANT.scenes
      ANIM.index += 1
      ANIM_AFFICHER()
    finsi
  finsi
retourner

procedure ANIM_TOUCHE(ev)
  si ev.touche = 27
    globale ANIM, fenconf
    ANIM = nul
    locale f = fenconf
    fenconf = nul
    f:fermer()
  sinonsi ev.touche = 1073741903 et ANIM.index < #SB_COURANT.scenes
    ANIM.index += 1
    ANIM_AFFICHER()
  sinonsi ev.touche = 1073741904 et ANIM.index > 1
    ANIM.index -= 1
    ANIM_AFFICHER()
  finsi
retourner

procedure ANIM_FERMEE(ev)
  globale ANIM, fenconf
  ANIM = nul
  fenconf = nul
retourner

&& planches PDF : 6 scènes par page A4 paysage, légendes et commentaires
procedure SB_PDF(ev)
  si SB_COURANT = nul
    retourner
  finsi
  locale d = SB_COURANT
  locale pages = {}
  locale W = 1123
  locale H = 794
  locale k = 1
  tantque k <= #d.scenes
    locale svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + W + '" height="' + H + '"><rect id="fond" width="' + W + '" height="' + H + '" fill="#FFFFFF"/>' + ;
                 SVG_TEXTE(48, 28, 800, d.titre, "Poppins", 22, "#0F172A", vrai, nul, 1.1) + ;
                 SVG_TEXTE(W - 248, 34, 200, "Planche " + (entier((k - 1) / 6) + 1), "Poppins", 13, "#64748B", faux, "end", 1)
    pour j = 0 a 5
      locale i = k + j
      si i <= #d.scenes
        locale s = d.scenes[i]
        locale col = j % 3
        locale lig = entier(j / 3)
        locale x = 48 + col * 350
        locale y = 90 + lig * 345
        svg = svg + '<rect x="' + x + '" y="' + y + '" width="330" height="186" fill="#F1F5F9" stroke="#CBD5E1"/>' + ;
              '<image href="' + CHEMIN(s.svg) + '" x="' + x + '" y="' + y + '" width="330" height="186"/>' + ;
              SVG_TEXTE(x, y + 196, 330, i + ". " + s.titre + "  ·  " + sisinon(s.duree = nul, 0, s.duree) + " s", "Poppins", 13, "#0F172A", vrai, nul, 1.2) + ;
              SVG_TEXTE(x, y + 220, 330, COURT(sisinon(s.commentaire = nul, "", s.commentaire), 140), "Lora", 11, "#475569", faux, nul, 1.3)
      finsi
    suivant
    inserer(pages, svg + "</svg>")
    k += 6
  fintantque
  locale dest = CHEMIN("publication", d.nom + "-storyboard.pdf")
  pub.pdfsvg(dest, pages, {titre = d.titre, auteur = PROJ.auteur, qualite = "standard"})
  STATUT("Planches PDF : " + dest)
  PUBLICATION_AJOUTER(dest)
retourner

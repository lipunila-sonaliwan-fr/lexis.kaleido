&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : présentations.
&&
&& presentations/<nom>.json : {titre, theme, sections, diapositives = {{id, section, disposition, titre,
&&   soustitre, texte, medias, notes, transition, duree, libre, svg}}}
&& Chaque diapositive est un SVG 1280 × 720 (presentations/<nom>/<id>.svg) produit par une
&& disposition (titre, contenu, deux colonnes, média, citation, section, chiffres, fin) et un
&& thème ; elle reste éditable à la main (elle devient alors « libre »). Les composants y sont
&& des occurrences liées (data-composant) : leur modification se propage.
&& Modes : conférence (plein écran + fenêtre du présentateur : notes, suivante, chrono),
&& répétition (chronomètre par diapositive, durées mémorisées), téléprompteur (notes défilantes).

procedure CONSTRUIRE_PRESENTATION(o)
  globale trieuse, toile_pres, notes_pres, PRES_COURANTE, PRES_INDEX, lblpres, combo_dispo, combo_trans, combo_theme
  PRES_COURANTE = nul
  PRES_INDEX = 1
  lblpres = o:ajouter(ui.etiquette("Aucune présentation : Fichier ▸ Nouvelle présentation."))
  lblpres.ancrage = "haut"
  lblpres.couleur = "#CBD5E1"
  locale sep = o:ajouter(ui.separateur{vertical = vrai, position = 0.2})
  sep.ancrage = "centre"
  trieuse = sep:ajouter(ui.toile{mode = "galerie"})
  trieuse.surselection = @PRES_TRIEUSE_CHOIX
  trieuse.surdoubleclic = @PRES_TRIEUSE_DOUBLE
  trieuse.surclicdroit = @PRES_TRIEUSE_MENU
  trieuse.surchangement = @PRES_TRIEUSE_MENU_CHOIX
  locale sep2 = sep:ajouter(ui.separateur{vertical = faux, position = 0.78})
  toile_pres = sep2:ajouter(ui.toile{mode = "edition"})
  toile_pres.surselection = @DESSIN_SELECTION
  toile_pres.surchangement = @DESSIN_CHANGE
  toile_pres.surdoubleclic = @DESSIN_DOUBLE
  toile_pres.surtouchebas = @DESSIN_TOUCHE
  locale bas = sep2:ajouter(ui.conteneur("bordure"))
  locale lb = bas:ajouter(ui.etiquette("Notes de l'orateur (téléprompteur, fenêtre du présentateur)"))
  lb.ancrage = "haut"
  lb.couleur = "#94A3B8"
  notes_pres = bas:ajouter(ui.saisie{multiligne = vrai, indication = "Ce que vous direz pendant cette diapositive…"})
  notes_pres.ancrage = "centre"
  notes_pres.surchangement = @PRES_NOTES
retourner

procedure RUBAN_PRESENTATION(r)
  ICONE(r, "nouveau", "Nouvelle présentation", "Nouvelle présentation", @PRES_NOUVELLE)
  ICONE(r, "k-slide", "Nouvelle diapositive", "Ajouter une diapositive après la courante", @PRES_AJOUTER)
  ICONE(r, "dupliquer", "Dupliquer", "Dupliquer la diapositive", @PRES_DUPLIQUER)
  ICONE(r, "supprimer", "Supprimer", "Supprimer la diapositive", @PRES_SUPPRIMER)
  ICONE(r, "k-up", "Avancer", "Déplacer la diapositive vers le début", @PRES_MONTER)
  ICONE(r, "k-down", "Reculer", "Déplacer la diapositive vers la fin", @PRES_DESCENDRE)
  FILET(r)
  LIBELLE(r, "Disposition", 84)
  combo_dispo = r:ajouter(ui.combo("titre", "contenu", "deux-colonnes", "media", "citation", "section", "chiffres", "fin"))
  combo_dispo:selectionner(2)
  combo_dispo.largeurfixe = 120
  combo_dispo.surselection = @PRES_DISPO
  LIBELLE(r, "Transition", 78)
  combo_trans = r:ajouter(ui.combo("fondu", "glissement", "zoom", "aucune"))
  combo_trans:selectionner(1)
  combo_trans.largeurfixe = 100
  combo_trans.surselection = @PRES_TRANSITION
  LIBELLE(r, "Thème", 52)
  combo_theme = r:ajouter(ui.combo("aurore", "clair", "ocean", "papier"))
  combo_theme:selectionner(1)
  combo_theme.largeurfixe = 110
  combo_theme.surselection = @PRES_THEME
  ICONE(r, "texte", "Contenu", "Modifier le titre et le texte de la diapositive (mise en page automatique)", @PRES_EDITER_TEXTE)
  ICONE(r, "actualiser", "Réinitialiser", "Refaire la mise en page de la diapositive (annule les retouches manuelles)", @PRES_REINITIALISER)
  FILET(r)
  ICONE(r, "k-play", "Conférence", "Lancer la présentation (F5) : plein écran + fenêtre du présentateur", @PRES_LANCER)
  ICONE(r, "k-history", "Répétition", "Mode répétition : chronomètre par diapositive", @PRES_REPETITION)
  ICONE(r, "k-prompter", "Téléprompteur", "Téléprompteur : notes en grand, défilement automatique (F8)", @PRES_TELEPROMPTEUR)
  ICONE(r, "pdf", "PDF", "Exporter la présentation en PDF (diapositives vectorielles)", @PRES_PDF)
retourner

&&
&& Thèmes et dispositions : génération du SVG
&&

fonction THEME(nom)
  faire cas
  cas nom = "clair"
    retourner {fond = "#FFFFFF", titre = "#0F172A", texte = "#334155", accent = "#4F46E5", doux = "#E0E7FF", police = "Poppins", corps = "Poppins", deco = "#EEF2FF"}
  cas nom = "ocean"
    retourner {fond = "linear(135,#0C4A6E,#0F766E)", titre = "#FFFFFF", texte = "#E0F2FE", accent = "#5EEAD4", doux = "#134E4A", police = "Poppins", corps = "Poppins", deco = "#FFFFFF"}
  cas nom = "papier"
    retourner {fond = "#FBF7F0", titre = "#3F2E1E", texte = "#57534E", accent = "#B45309", doux = "#F5E9D7", police = "Lora", corps = "Lora", deco = "#F1E4CF"}
  fincas
retourner {fond = "linear(135,#1E1B4B,#4C1D95)", titre = "#FFFFFF", texte = "#E0E7FF", accent = "#A78BFA", doux = "#312E81", police = "Poppins", corps = "Poppins", deco = "#FFFFFF"}

fonction SVG_TEXTE(x, y, l, texte_, police, taille, couleur, gras, ancre, interligne, extra)
  locale a = sisinon(ancre = nul, "", ' text-anchor="' + ancre + '"')
  locale t = '<text font-family="' + police + '" font-size="' + taille + '" fill="' + couleur + '"' + sisinon(gras, ' font-weight="bold"', "") + a + ;
             ' data-boite="' + x + " " + y + " " + l + '"' + sisinon(interligne = nul, "", ' data-interligne="' + interligne + '"') + sisinon(extra = nul, "", " " + extra) + ">"
  && position d'ancrage pour les lecteurs SVG standard (Kaléido relit data-boite)
  locale ax = sisinon(ancre = "middle", x + l / 2, sisinon(ancre = "end", x + l, x))
  locale k = 0
  pour chaque ligne dans LIGNES(texte_)
    t = t + '<tspan x="' + ax + '" y="' + arrondi(y + taille + k * taille * sisinon(interligne = nul, 1.25, interligne), 1) + '">' + XML(sisinon(ligne = "", " ", ligne)) + "</tspan>"
    k += 1
  suivant
retourner t + "</text>"

fonction SVG_FOND(th, w, h)
  locale f = th.fond
  locale s = ""
  si commencepar(f, "linear(")
    locale p = decouper(souschaine(f, 8, #f - 8), ",")
    s = '<defs><linearGradient id="fondg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="' + p[2] + '"/><stop offset="1" stop-color="' + p[3] + '"/></linearGradient></defs>' + ;
        '<rect id="fond" width="' + w + '" height="' + h + '" fill="url(#fondg)"/>'
  sinon
    s = '<rect id="fond" width="' + w + '" height="' + h + '" fill="' + f + '"/>'
  finsi
retourner s

&& lignes à puces d'un texte : « - élément » ou lignes simples
fonction PUCES(texte_)
  locale r = {}
  pour chaque l dans LIGNES(sisinon(texte_ = nul, "", texte_))
    l = rogner(l)
    si commencepar(l, "- ") ou commencepar(l, "* ")
      l = souschaine(l, 3)
    finsi
    si l <> ""
      inserer(r, l)
    finsi
  suivant
retourner r

fonction MEDIA_SVG(id, x, y, l, h)
  locale c = COMPOSANT(PARTIE_ID(id))
  si c = nul
    retourner ""
  finsi
  si GENRE_TEXTE(c.genre)
    retourner SVG_TEXTE(x, y, l, pub.textebrut(CONTENU_COMPOSANT(c, nul)), "Lora", 24, "#1F2937", faux, nul, 1.4, 'data-composant="' + c.id + '"')
  finsi
  locale f = FICHIER_COMPOSANT(c, nul)
  locale t = pub.tailleimage(f)
  locale lw = l
  locale lh = h
  si t <> nul et t.largeur > 0 et t.hauteur > 0
    locale k = min(l / t.largeur, h / t.hauteur)
    lw = t.largeur * k
    lh = t.hauteur * k
  finsi
retourner '<image href="' + f + '" x="' + arrondi(x + (l - lw) / 2, 1) + '" y="' + arrondi(y + (h - lh) / 2, 1) + '" width="' + arrondi(lw, 1) + '" height="' + arrondi(lh, 1) + ;
          '" data-composant="' + c.id + '" data-nom="' + XML(c.titre) + '"/>'

fonction DIAPO_SVG(d, s, numero)
  locale th = THEME(d.theme)
  locale W = 1280
  locale H = 720
  locale svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + W + '" height="' + H + '" viewBox="0 0 ' + W + " " + H + '">' + SVG_FOND(th, W, H)
  locale deco = '<g data-calque="Décor" id="calque-decor">'
  locale corps = '<g data-calque="Contenu" id="calque-contenu">'
  locale dispo = sisinon(s.disposition = nul, "contenu", s.disposition)
  locale medias = sisinon(s.medias = nul, {}, s.medias)
  && décor discret commun
  deco = deco + '<circle cx="' + (W - 60) + '" cy="60" r="220" fill="none" stroke="' + th.deco + '" stroke-width="1.5" opacity="0.12"/>' + ;
         '<circle cx="' + (W - 60) + '" cy="60" r="150" fill="none" stroke="' + th.deco + '" stroke-width="1.5" opacity="0.10"/>'
  faire cas
  cas dispo = "titre"
    deco = deco + '<rect x="96" y="420" width="120" height="6" rx="3" fill="' + th.accent + '"/>'
    corps = corps + SVG_TEXTE(96, 230, 1088, s.titre, th.police, 72, th.titre, vrai, nul, 1.1)
    corps = corps + SVG_TEXTE(96, 450, 1000, sisinon(s.soustitre = nul, "", s.soustitre), th.corps, 30, th.texte, faux, nul, 1.3)
  cas dispo = "section"
    deco = deco + '<rect x="0" y="0" width="14" height="' + H + '" fill="' + th.accent + '"/>'
    corps = corps + SVG_TEXTE(96, 250, 1000, sisinon(s.section = nul, "", majuscule(s.section)), th.police, 22, th.accent, vrai, nul, 1.2)
    corps = corps + SVG_TEXTE(96, 300, 1088, s.titre, th.police, 64, th.titre, vrai, nul, 1.1)
  cas dispo = "citation"
    corps = corps + SVG_TEXTE(96, 120, 200, "“", "Lora", 200, th.accent, vrai, nul, 1)
    corps = corps + SVG_TEXTE(180, 230, 920, sisinon(s.texte = nul, s.titre, s.texte), "Lora", 44, th.titre, faux, nul, 1.35, 'font-style="italic"')
    corps = corps + SVG_TEXTE(180, 560, 920, "— " + sisinon(s.soustitre = nul, "", s.soustitre), th.corps, 26, th.accent, vrai, nul, 1.2)
  cas dispo = "chiffres"
    corps = corps + SVG_TEXTE(96, 70, 1088, s.titre, th.police, 48, th.titre, vrai, nul, 1.15)
    locale items = PUCES(s.texte)
    locale n = max(1, min(4, #items))
    locale lc = (W - 192 - (n - 1) * 32) / n
    pour i = 1 a n
      locale p = decouper(items[i], "|")
      locale x = 96 + (i - 1) * (lc + 32)
      deco = deco + '<rect x="' + x + '" y="230" width="' + lc + '" height="300" rx="24" fill="' + th.doux + '" opacity="0.55"/>'
      corps = corps + SVG_TEXTE(x + 28, 270, lc - 56, rogner(p[1]), th.police, 76, th.accent, vrai, nul, 1)
      corps = corps + SVG_TEXTE(x + 28, 390, lc - 56, sisinon(#p > 1, rogner(sisinon(p[2] = nul, "", p[2])), ""), th.corps, 24, th.texte, faux, nul, 1.3)
    suivant
  cas dispo = "fin"
    corps = corps + SVG_TEXTE(96, 260, 1088, sisinon(s.titre = nul, "Merci", s.titre), th.police, 96, th.titre, vrai, "middle", 1)
    corps = corps + SVG_TEXTE(96, 420, 1088, sisinon(s.soustitre = nul, "", s.soustitre), th.corps, 28, th.accent, faux, "middle", 1.3)
  cas dispo = "media"
    corps = corps + SVG_TEXTE(96, 60, 1088, s.titre, th.police, 44, th.titre, vrai, nul, 1.15)
    si #medias > 0
      corps = corps + MEDIA_SVG(medias[1], 96, 160, 1088, 500)
    finsi
  autrement
    && contenu et deux colonnes
    deco = deco + '<rect x="96" y="152" width="64" height="5" rx="2.5" fill="' + th.accent + '"/>'
    corps = corps + SVG_TEXTE(96, 64, 1088, s.titre, th.police, 48, th.titre, vrai, nul, 1.15)
    locale large = sisinon(#medias > 0 ou dispo = "deux-colonnes", 560, 1060)
    locale y = 196
    pour chaque p dans PUCES(s.texte)
      locale lignes_ = max(1, plafond(pub.mesurer(p, th.corps, 28) / (large - 40)))
      deco = deco + '<circle cx="' + 106 + '" cy="' + (y + 22) + '" r="6" fill="' + th.accent + '"/>'
      corps = corps + SVG_TEXTE(130, y, large - 40, p, th.corps, 28, th.texte, faux, nul, 1.3)
      y = y + lignes_ * 36 + 22
    suivant
    si #medias > 0
      corps = corps + MEDIA_SVG(medias[1], 700, 190, 484, 440)
    finsi
  fincas
  && pied : titre de la présentation et numéro
  si dispo <> "titre" et dispo <> "fin"
    deco = deco + SVG_TEXTE(96, 664, 800, d.titre, th.corps, 14, th.texte, faux, nul, 1, 'opacity="0.6"')
    deco = deco + SVG_TEXTE(1084, 664, 100, chaine(numero), th.corps, 14, th.accent, vrai, "end", 1)
  finsi
retourner svg + deco + "</g>" + corps + "</g></svg>"

procedure DIAPO_ECRIRE(d, s, numero)
  si s.svg = nul
    s.svg = "presentations/" + d.nom + "/" + s.id + ".svg"
  finsi
  si non s.libre ou non fichier.existe(CHEMIN(s.svg))
    ECRIRE_TEXTE(CHEMIN(s.svg), DIAPO_SVG(d, s, numero))
  finsi
retourner

procedure PRES_REGENERER_TOUT
  si PRES_COURANTE = nul
    retourner
  finsi
  locale i = 1
  pour chaque s dans PRES_COURANTE.diapositives
    DIAPO_ECRIRE(PRES_COURANTE, s, i)
    i += 1
  suivant
  ENREGISTRER_PRESENTATION(PRES_COURANTE)
  PRES_TRIEUSE()
  PRES_AFFICHER(PRES_INDEX)
retourner

&&
&& Ouverture, trieuse, édition
&&

procedure PRES_ACTIVER
  si PRES_COURANTE = nul et #PRES > 0
    PRES_OUVRIR(PRES[1].nom)
  finsi
retourner

procedure PRES_OUVRIR(nom)
  globale PRES_COURANTE, PRES_INDEX
  DESSIN_ENREGISTRER_SI_MODIFIE()
  PRES_COURANTE = PRESENTATION(nom)
  si PRES_COURANTE = nul
    retourner
  finsi
  PRES_INDEX = 1
  COMBO_FIXER(combo_theme, LISTE_THEMES(), sisinon(PRES_COURANTE.theme = nul, "aurore", PRES_COURANTE.theme))
  locale i = 1
  pour chaque s dans PRES_COURANTE.diapositives
    si s.svg = nul ou non fichier.existe(CHEMIN(s.svg))
      DIAPO_ECRIRE(PRES_COURANTE, s, i)
    finsi
    i += 1
  suivant
  PRES_TRIEUSE()
  PRES_AFFICHER(1)
  SELECTIONNER("presentation", nom)
retourner

procedure PRES_TRIEUSE
  locale pages = {}
  locale leg = {}
  locale i = 1
  pour chaque s dans PRES_COURANTE.diapositives
    inserer(pages, CHEMIN(s.svg))
    inserer(leg, i + " · " + COURT(s.titre, 26))
    i += 1
  suivant
  trieuse:chargerpages(pages, {colonnes = 1, ecart = 40, legendes = leg, choisie = PRES_INDEX, garderposition = vrai})
  locale duree = 0
  pour chaque s dans PRES_COURANTE.diapositives
    duree += sisinon(s.duree = nul, 60, s.duree)
  suivant
  lblpres.libelle = "▭ " + PRES_COURANTE.titre + "   ·   " + PLURIEL(#PRES_COURANTE.diapositives, "diapositive") + "   ·   durée prévue " + ;
                    entier(duree / 60) + " min " + (duree % 60) + " s   ·   thème " + sisinon(PRES_COURANTE.theme = nul, "aurore", PRES_COURANTE.theme)
retourner

procedure PRES_AFFICHER(i)
  globale PRES_INDEX, toile
  si PRES_COURANTE = nul ou #PRES_COURANTE.diapositives = 0
    retourner
  finsi
  PRES_INDEX = max(1, min(i, #PRES_COURANTE.diapositives))
  locale s = PRES_COURANTE.diapositives[PRES_INDEX]
  locale ancien = toile
  toile = toile_pres
  DESSIN_ETAT("presentation")
  DESSIN_CHARGER({genre = "diapositive", chemin = CHEMIN(s.svg), libelle = "Diapositive " + PRES_INDEX, rappel = @PRES_APRES_DESSIN}, ;
                 LIRE_TEXTE(CHEMIN(s.svg)), CHEMIN("presentations", PRES_COURANTE.nom))
  si ESPACE <> "presentation"
    toile = ancien
    DESSIN_ETAT(ESPACE)
  finsi
  notes_pres.valeur = sisinon(s.notes = nul, "", s.notes)
  COMBO_FIXER(combo_dispo, LISTE_DISPOS(), sisinon(s.disposition = nul, "contenu", s.disposition))
  COMBO_FIXER(combo_trans, LISTE_TRANSITIONS(), sisinon(s.transition = nul, "fondu", s.transition))
  trieuse:selectionner("groupe:page-" + PRES_INDEX)
retourner

&& retouche manuelle enregistrée : la diapositive devient libre
procedure PRES_APRES_DESSIN(cible)
  si PRES_COURANTE = nul
    retourner
  finsi
  locale s = PRES_COURANTE.diapositives[PRES_INDEX]
  si s <> nul et CHEMIN(s.svg) = cible.chemin
    s.libre = vrai
    ENREGISTRER_PRESENTATION(PRES_COURANTE)
    PRES_TRIEUSE()
  finsi
retourner

procedure PRES_TRIEUSE_CHOIX(ev)
  si commencepar(ev.texte, "page-")
    DESSIN_ENREGISTRER_SI_MODIFIE()
    PRES_AFFICHER(nombre(souschaine(ev.texte, 6)))
  finsi
retourner

procedure PRES_TRIEUSE_DOUBLE(ev)
  PRES_EDITER_TEXTE(nul)
retourner

procedure PRES_TRIEUSE_MENU(ev)
  trieuse:menucontextuel("Nouvelle diapositive", "Dupliquer", "Supprimer", "-", "Avancer", "Reculer", "-", "Modifier le contenu…", "Réinitialiser la mise en page")
retourner

procedure PRES_TRIEUSE_MENU_CHOIX(ev)
  faire cas
  cas ev.texte = "Nouvelle diapositive"
    PRES_AJOUTER(nul)
  cas ev.texte = "Dupliquer"
    PRES_DUPLIQUER(nul)
  cas ev.texte = "Supprimer"
    PRES_SUPPRIMER(nul)
  cas ev.texte = "Avancer"
    PRES_MONTER(nul)
  cas ev.texte = "Reculer"
    PRES_DESCENDRE(nul)
  cas ev.texte = "Modifier le contenu…"
    PRES_EDITER_TEXTE(nul)
  cas ev.texte = "Réinitialiser la mise en page"
    PRES_REINITIALISER(nul)
  fincas
retourner

procedure PRES_NOTES(ev)
  si PRES_COURANTE <> nul et #PRES_COURANTE.diapositives >= PRES_INDEX
    PRES_COURANTE.diapositives[PRES_INDEX].notes = notes_pres.valeur
    PRES_COURANTE.modifie = horodatage()
  finsi
retourner

procedure PRES_NOUVELLE(ev)
  locale t = ui.demander("Titre de la présentation :", "Nouvelle présentation")
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale existants = {}
  pour chaque d dans PRES
    existants[d.nom] = vrai
  suivant
  locale nom = IDENT(t, existants)
  locale d = {nom = nom, titre = rogner(t), theme = "aurore", diapositives = { ;
    {id = "d1", disposition = "titre", titre = rogner(t), soustitre = sisinon(PROJ.auteur = nul, "", PROJ.auteur), notes = "", transition = "fondu", duree = 30}, ;
    {id = "d2", disposition = "contenu", titre = "Les points clés", texte = "- Premier point" + car(10) + "- Deuxième point" + car(10) + "- Troisième point", notes = "", transition = "fondu", duree = 60}, ;
    {id = "d3", disposition = "fin", titre = "Merci", soustitre = "Questions ?", notes = "", transition = "fondu", duree = 20}}}
  inserer(PRES, d)
  locale i = 1
  pour chaque s dans d.diapositives
    DIAPO_ECRIRE(d, s, i)
    i += 1
  suivant
  ENREGISTRER_PRESENTATION(d)
  PROJET_ARBRE()
  OUVRIR_ESPACE("presentation")
  PRES_OUVRIR(nom)
retourner

fonction NOUVEL_ID_DIAPO(d)
  locale n = #d.diapositives + 1
  tantque vrai
    locale id = "d" + n
    locale libre_ = vrai
    pour chaque s dans d.diapositives
      si s.id = id
        libre_ = faux
      finsi
    suivant
    si libre_
      retourner id
    finsi
    n += 1
  fintantque
retourner "d0"

procedure PRES_AJOUTER(ev)
  si PRES_COURANTE = nul
    PRES_NOUVELLE(nul)
    retourner
  finsi
  locale s = {id = NOUVEL_ID_DIAPO(PRES_COURANTE), disposition = "contenu", titre = "Nouvelle diapositive", texte = "- Point", notes = "", transition = "fondu", duree = 60}
  inserer(PRES_COURANTE.diapositives, s, PRES_INDEX + 1)
  PRES_REGENERER_TOUT()
  PRES_AFFICHER(PRES_INDEX + 1)
  PRES_EDITER_TEXTE(nul)
retourner

procedure PRES_DUPLIQUER(ev)
  si PRES_COURANTE = nul
    retourner
  finsi
  locale s = copier(PRES_COURANTE.diapositives[PRES_INDEX])
  locale src = CHEMIN(s.svg)
  s.id = NOUVEL_ID_DIAPO(PRES_COURANTE)
  s.svg = "presentations/" + PRES_COURANTE.nom + "/" + s.id + ".svg"
  ECRIRE_TEXTE(CHEMIN(s.svg), LIRE_TEXTE(src))
  inserer(PRES_COURANTE.diapositives, s, PRES_INDEX + 1)
  ENREGISTRER_PRESENTATION(PRES_COURANTE)
  PRES_TRIEUSE()
  PRES_AFFICHER(PRES_INDEX + 1)
retourner

procedure PRES_SUPPRIMER(ev)
  si PRES_COURANTE = nul ou #PRES_COURANTE.diapositives <= 1
    retourner
  finsi
  si ui.confirmer("Supprimer la diapositive " + PRES_INDEX + " ?", "attention")
    retirer(PRES_COURANTE.diapositives, PRES_INDEX)
    PRES_REGENERER_TOUT()
    PRES_AFFICHER(min(PRES_INDEX, #PRES_COURANTE.diapositives))
  finsi
retourner

procedure PRES_MONTER(ev)
  si PRES_COURANTE = nul ou PRES_INDEX <= 1
    retourner
  finsi
  locale s = retirer(PRES_COURANTE.diapositives, PRES_INDEX)
  inserer(PRES_COURANTE.diapositives, s, PRES_INDEX - 1)
  PRES_INDEX -= 1
  PRES_REGENERER_TOUT()
retourner

procedure PRES_DESCENDRE(ev)
  si PRES_COURANTE = nul ou PRES_INDEX >= #PRES_COURANTE.diapositives
    retourner
  finsi
  locale s = retirer(PRES_COURANTE.diapositives, PRES_INDEX)
  inserer(PRES_COURANTE.diapositives, s, PRES_INDEX + 1)
  PRES_INDEX += 1
  PRES_REGENERER_TOUT()
retourner

procedure PRES_DISPO(ev)
  si PRES_COURANTE = nul
    retourner
  finsi
  locale s = PRES_COURANTE.diapositives[PRES_INDEX]
  locale v = COMBO_VAL(combo_dispo, LISTE_DISPOS())
  si s.disposition <> v
    s.disposition = v
    s.libre = faux
    PRES_REGENERER_TOUT()
  finsi
retourner

procedure PRES_TRANSITION(ev)
  si PRES_COURANTE <> nul
    PRES_COURANTE.diapositives[PRES_INDEX].transition = COMBO_VAL(combo_trans, LISTE_TRANSITIONS())
    ENREGISTRER_PRESENTATION(PRES_COURANTE)
  finsi
retourner

procedure PRES_THEME(ev)
  si PRES_COURANTE <> nul et PRES_COURANTE.theme <> COMBO_VAL(combo_theme, LISTE_THEMES())
    PRES_COURANTE.theme = COMBO_VAL(combo_theme, LISTE_THEMES())
    PRES_REGENERER_TOUT()
  finsi
retourner

procedure PRES_REINITIALISER(ev)
  si PRES_COURANTE <> nul
    PRES_COURANTE.diapositives[PRES_INDEX].libre = faux
    PRES_REGENERER_TOUT()
  finsi
retourner

&& contenu d'une diapositive : titre (1re ligne), sous-titre (« > … »), points (lignes suivantes)
procedure PRES_EDITER_TEXTE(ev)
  si PRES_COURANTE = nul
    retourner
  finsi
  locale s = PRES_COURANTE.diapositives[PRES_INDEX]
  locale t = s.titre + car(10)
  si s.soustitre <> nul et s.soustitre <> ""
    t = t + "> " + s.soustitre + car(10)
  finsi
  t = t + sisinon(s.texte = nul, "", s.texte)
  EDITER_TEXTE("Contenu de la diapositive " + PRES_INDEX, "1re ligne : titre · « > texte » : sous-titre · puis un point par ligne (« 42 % | libellé » pour la disposition chiffres)", t, @PRES_TEXTE_VALIDE)
retourner

procedure PRES_TEXTE_VALIDE(r)
  locale s = PRES_COURANTE.diapositives[PRES_INDEX]
  locale l = LIGNES(r)
  s.titre = sisinon(#l > 0, l[1], "")
  s.soustitre = ""
  locale corps = {}
  pour i = 2 a #l
    si commencepar(l[i], "> ")
      s.soustitre = souschaine(l[i], 3)
    sinon
      inserer(corps, l[i])
    finsi
  suivant
  s.texte = joindre(corps, car(10))
  s.libre = faux
  PRES_REGENERER_TOUT()
retourner

procedure PRES_INSERER_COMPOSANT(c)
  si PRES_COURANTE = nul
    retourner
  finsi
  locale s = PRES_COURANTE.diapositives[PRES_INDEX]
  si s.libre
    DESSIN_INSERER_COMPOSANT(c)
    retourner
  finsi
  si s.medias = nul
    s.medias = {}
  finsi
  s.medias = {c.id}
  si s.disposition = "titre" ou s.disposition = "fin"
    s.disposition = "deux-colonnes"
  finsi
  PRES_REGENERER_TOUT()
  STATUT("« " + c.titre + " » placé dans la diapositive " + PRES_INDEX + " (occurrence liée).")
retourner

&& un composant a changé : les diapositives générées qui l'utilisent sont refaites
procedure PRES_COMPOSANT_MODIFIE(id)
  pour chaque d dans PRES
    locale touche = faux
    locale i = 1
    pour chaque s dans d.diapositives
      si non s.libre et LISTE_CONTIENT(sisinon(s.medias = nul, {}, s.medias), id)
        DIAPO_ECRIRE(d, s, i)
        touche = vrai
      finsi
      i += 1
    suivant
    si touche et PRES_COURANTE <> nul et d.nom = PRES_COURANTE.nom
      PRES_TRIEUSE()
    finsi
  suivant
retourner

procedure PRES_PDF(ev)
  si PRES_COURANTE = nul
    retourner
  finsi
  locale pages = {}
  locale sig = {}
  locale i = 1
  pour chaque s dans PRES_COURANTE.diapositives
    inserer(pages, CHEMIN(s.svg))
    inserer(sig, {titre = i + ". " + s.titre, page = i, niveau = 1})
    i += 1
  suivant
  locale dest = CHEMIN("publication", PRES_COURANTE.nom + ".pdf")
  pub.pdfsvg(dest, pages, {titre = PRES_COURANTE.titre, auteur = PROJ.auteur, signets = sig, qualite = "hd"})
  STATUT("PDF de la présentation : " + dest)
  PUBLICATION_AJOUTER(dest)
retourner

&&
&& Conférence, répétition, téléprompteur
&&

procedure PRES_LANCER(ev)
  si PRES_COURANTE = nul
    PRES_ACTIVER()
    si PRES_COURANTE = nul
      retourner
    finsi
  finsi
  DESSIN_ENREGISTRER_SI_MODIFIE()
  PRES_PDF_SILENCIEUX()
  globale fenconf, conf_toile, CONF, fenpresentateur
  CONF = {index = 1, debut = horodatage(), debut_diapo = horodatage(), repetition = faux, durees = {}}
  fenconf = ui.fenetre{titre = PRES_COURANTE.titre, largeur = 1280, hauteur = 720, disposition = "bordure", sombre = vrai, etat = "pleinecran"}
  fenconf.marge = 0
  fenconf.surtouchebas = @CONF_TOUCHE
  fenconf.surfermeture = @CONF_FERMEE
  conf_toile = fenconf:ajouter(ui.toile{mode = "lecture"})
  conf_toile.ancrage = "centre"
  conf_toile.surselection = @CONF_CLIC
  PRES_PRESENTATEUR()
  CONF_AFFICHER()
retourner

procedure PRES_PDF_SILENCIEUX
  && rien : les SVG sont déjà à jour (enregistrement automatique)
retourner

procedure PRES_REPETITION(ev)
  PRES_LANCER(nul)
  si CONF <> nul
    CONF.repetition = vrai
    STATUT("Répétition : les durées réelles seront enregistrées à la fin.")
  finsi
retourner

procedure PRES_PRESENTATEUR
  globale fenpresentateur, pres_notes_md, pres_suiv, pres_chrono
  fenpresentateur = ui.fenetre{titre = "Présentateur — " + PRES_COURANTE.titre, largeur = 980, hauteur = 640, disposition = "bordure", sombre = vrai, densite = "compacte"}
  fenpresentateur.surtouchebas = @CONF_TOUCHE
  pres_chrono = fenpresentateur:ajouter(ui.etiquette(""))
  pres_chrono.ancrage = "haut"
  pres_chrono.couleur = "#FBBF24"
  locale sep = fenpresentateur:ajouter(ui.separateur{vertical = vrai, position = 0.55})
  sep.ancrage = "centre"
  pres_notes_md = sep:ajouter(ui.markdown(""))
  pres_suiv = sep:ajouter(ui.toile{mode = "galerie"})
retourner

procedure CONF_AFFICHER
  locale d = PRES_COURANTE
  locale i = CONF.index
  locale s = d.diapositives[i]
  conf_toile:chargerfichier(CHEMIN(s.svg))
  conf_toile:ajuster()
  CONF.debut_diapo = horodatage()
  si pres_notes_md <> nul
    pres_notes_md.valeur = "## " + i + " / " + #d.diapositives + " — " + s.titre + car(10) + car(10) + sisinon(s.notes = nul ou s.notes = "", "*Pas de notes.*", s.notes)
    locale suivantes = {}
    locale leg = {}
    pour k = i + 1 a min(i + 2, #d.diapositives)
      inserer(suivantes, CHEMIN(d.diapositives[k].svg))
      inserer(leg, "Ensuite : " + k + ". " + d.diapositives[k].titre)
    suivant
    si #suivantes > 0
      pres_suiv:chargerpages(suivantes, {colonnes = 1, ecart = 30, legendes = leg})
    finsi
  finsi
retourner

procedure PRES_HORLOGE
  globale fenpresentateur, pres_chrono, pres_notes_md
  si CONF = nul et fenpresentateur <> nul
    pres_chrono = nul
    pres_notes_md = nul
    locale f = fenpresentateur
    fenpresentateur = nul
    essayer
      f:fermer()
    capturer e
    finessayer
  finsi
  si CONF <> nul et fenconf <> nul et pres_chrono <> nul
    locale t = entier(horodatage() - CONF.debut)
    locale td = entier(horodatage() - CONF.debut_diapo)
    locale s = PRES_COURANTE.diapositives[CONF.index]
    locale prevue = sisinon(s.duree = nul, 60, s.duree)
    pres_chrono.libelle = "⏱ " + entier(t / 60) + ":" + droite("0" + (t % 60), 2) + "   ·   diapositive " + td + " s / " + prevue + " s prévues" + ;
                          sisinon(td > prevue, "   ·   ⚠ dépassement", "") + sisinon(CONF.repetition, "   ·   RÉPÉTITION", "")
  finsi
  PROMPT_DEFILER()
retourner

procedure CONF_ALLER(delta)
  locale n = #PRES_COURANTE.diapositives
  locale i = CONF.index + delta
  si CONF.repetition
    CONF.durees[CONF.index] = entier(horodatage() - CONF.debut_diapo)
  finsi
  si i < 1
    retourner
  finsi
  si i > n
    CONF_TERMINER()
    retourner
  finsi
  CONF.index = i
  CONF_AFFICHER()
retourner

procedure CONF_TOUCHE(ev)
  locale t = ev.touche
  faire cas
  cas t = 1073741903 ou t = 32 ou t = 1073741902 ou t = 13      && droite, espace, page suivante, entrée
    CONF_ALLER(1)
  cas t = 1073741904 ou t = 1073741899 ou t = 8                 && gauche, page précédente, retour
    CONF_ALLER(-1)
  cas t = 27
    CONF_TERMINER()
  cas t = 1073741898                                            && début
    CONF.index = 1
    CONF_AFFICHER()
  fincas
retourner

procedure CONF_CLIC(ev)
  CONF_ALLER(1)
retourner

procedure CONF_FERMEE(ev)
  && fenêtre fermée par l'utilisateur
  si CONF <> nul
    CONF_TERMINER()
  finsi
retourner

procedure CONF_TERMINER
  globale fenconf, CONF
  si CONF = nul
    retourner
  finsi
  si CONF.repetition
    pour chaque k, v dans CONF.durees
      locale s = PRES_COURANTE.diapositives[k]
      si s <> nul
        s.duree = v
      finsi
    suivant
    ENREGISTRER_PRESENTATION(PRES_COURANTE)
    PRES_TRIEUSE()
    STATUT("Répétition terminée : durées réelles enregistrées.")
  finsi
  CONF = nul
  locale f = fenconf
  fenconf = nul
  essayer
    f:fermer()
  capturer e
  finessayer
  && la fenêtre du présentateur est fermée au prochain tic (hors de ce gestionnaire)
retourner

procedure PRES_TELEPROMPTEUR(ev)
  globale fenprompt, prompt_md, PROMPT
  si PRES_COURANTE = nul
    retourner
  finsi
  locale n = car(10)
  locale md = ""
  locale i = 1
  pour chaque s dans PRES_COURANTE.diapositives
    md = md + "# " + i + ". " + s.titre + n + n + sisinon(s.notes = nul ou s.notes = "", "*(pas de notes)*", s.notes) + n + n + "---" + n + n
    i += 1
  suivant
  fenprompt = ui.fenetre{titre = "Téléprompteur — " + PRES_COURANTE.titre + "  (Espace : pause · ↑↓ vitesse · Échap)", largeur = 1100, hauteur = 760, ;
                         disposition = "bordure", sombre = vrai, etat = "agrandie"}
  fenprompt.surtouchebas = @PROMPT_TOUCHE
  fenprompt.surfermeture = @PROMPT_FERMEE
  prompt_md = fenprompt:ajouter(ui.markdown(md))
  prompt_md.ancrage = "centre"
  PROMPT = {pos = 0, vitesse = 2, pause = faux}
retourner

procedure PROMPT_DEFILER
  si PROMPT <> nul et fenprompt <> nul et non PROMPT.pause
    PROMPT.pos += PROMPT.vitesse * 4
    prompt_md:defilera(PROMPT.pos)
  finsi
retourner

procedure PROMPT_TOUCHE(ev)
  faire cas
  cas ev.touche = 32
    PROMPT.pause = non PROMPT.pause
  cas ev.touche = 1073741906
    PROMPT.vitesse = min(12, PROMPT.vitesse + 1)
  cas ev.touche = 1073741905
    PROMPT.vitesse = max(0, PROMPT.vitesse - 1)
  cas ev.touche = 27
    globale fenprompt, PROMPT
    PROMPT = nul
    locale f = fenprompt
    fenprompt = nul
    f:fermer()
  fincas
retourner

procedure PROMPT_FERMEE(ev)
  globale fenprompt, PROMPT
  fenprompt = nul
  PROMPT = nul
retourner

fonction LISTE_THEMES()
retourner {"aurore", "clair", "ocean", "papier"}
fonction LISTE_DISPOS()
retourner {"titre", "contenu", "deux-colonnes", "media", "citation", "section", "chiffres", "fin"}
fonction LISTE_TRANSITIONS()
retourner {"fondu", "glissement", "zoom", "aucune"}

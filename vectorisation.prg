&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : importation (PNG, JPEG, WEBP, GIF, BMP, PDF) et vectorisation (bitmap -> SVG).
&&
&& Préréglages : monochrome, niveaux de gris, couleurs, logo, dessin technique, illustration ;
&& réglages fins : nombre de couleurs, lissage, détail. L'aperçu compare l'original et le SVG ;
&& « Créer le composant » range le résultat dans la bibliothèque, éditable dans l'éditeur SVG
&& (nettoyage, fusion, simplification et optimisation : commande « Optimiser le SVG »).

procedure VECTORISER_DIALOGUE(ev)
  globale fenvect, VECT, vect_mode, vect_coul, vect_lissage, vect_detail, vect_toile, vect_info, vect_page
  locale f = ui.ouvrirfichier{titre = "Image à importer et vectoriser", filtre = "Images, PDF et SVG|*.png;*.jpg;*.jpeg;*.gif;*.bmp;*.webp;*.pdf;*.svg"}
  si f = nul
    retourner
  finsi
  si minuscule(fichier.extension(f)) = ".svg"
    && déjà vectoriel : import direct (planche de symboles ou illustration)
    IMPORTER_SVG(f)
    retourner
  finsi
  VECT = {source = f, svg = "", page = 1}
  si fenvect <> nul
    essayer
      fenvect:fermer()
    capturer e
    finessayer
  finsi
  fenvect = ui.fenetre{titre = "Importer et vectoriser — " + fichier.nom(f), largeur = 1180, hauteur = 760, disposition = "bordure", ;
                       sombre = reglages.sombre, densite = "compacte"}
  fenvect.surfermeture = @VECT_FERMEE
  locale r = fenvect:ajouter(ui.rangee())
  r.ancrage = "haut"
  r.marge = 6
  r.espacement = 6
  LIBELLE(r, "Mode", 40)
  vect_mode = r:ajouter(ui.combo("couleurs", "logo", "mono", "gris", "technique", "illustration"))
  vect_mode:selectionner(1)
  vect_mode.largeurfixe = 120
  vect_mode.surselection = @VECT_PRESET
  LIBELLE(r, "Couleurs", 60)
  vect_coul = r:ajouter(ui.compteur())
  vect_coul.min = 2
  vect_coul.max = 32
  vect_coul.valeur = 8
  vect_coul.largeurfixe = 70
  LIBELLE(r, "Lissage", 54)
  vect_lissage = r:ajouter(ui.curseur())
  vect_lissage.min = 0
  vect_lissage.max = 100
  vect_lissage.valeur = 60
  vect_lissage.largeurfixe = 120
  LIBELLE(r, "Détail", 46)
  vect_detail = r:ajouter(ui.curseur())
  vect_detail.min = 0
  vect_detail.max = 100
  vect_detail.valeur = 60
  vect_detail.largeurfixe = 120
  si finitpar(minuscule(f), ".pdf")
    LIBELLE(r, "Page", 40)
    vect_page = r:ajouter(ui.compteur())
    vect_page.min = 1
    vect_page.max = max(1, pub.pagespdf(f))
    vect_page.valeur = 1
    vect_page.largeurfixe = 70
  sinon
    vect_page = nul
  finsi
  OUTIL(r, "▶ Vectoriser", @VECT_LANCER, "Calculer le SVG avec ces réglages")
  locale e = r:ajouter(ui.etiquette(""))
  e.poids = 1
  OUTIL(r, "Importer l'image seule", @VECT_IMAGE_SEULE, "Ranger l'image (PNG) dans la bibliothèque sans la vectoriser")
  OUTIL(r, "✓ Créer le composant", @VECT_CREER, "Ranger le SVG dans la bibliothèque et l'ouvrir dans l'éditeur")
  vect_info = fenvect:ajouter(ui.etiquette(""))
  vect_info.ancrage = "bas"
  vect_info.couleur = "#94A3B8"
  vect_toile = fenvect:ajouter(ui.toile{mode = "galerie"})
  vect_toile.ancrage = "centre"
  VECT_LANCER(nul)
retourner

procedure VECT_FERMEE(ev)
  globale fenvect
  fenvect = nul
retourner

procedure VECT_PRESET(ev)
  locale m = MODE_VECT()
  faire cas
  cas m = "mono" ou m = "technique"
    vect_coul.valeur = 2
  cas m = "gris"
    vect_coul.valeur = 5
  cas m = "logo"
    vect_coul.valeur = 5
    vect_lissage.valeur = 75
    vect_detail.valeur = 50
  cas m = "illustration"
    vect_coul.valeur = 16
  autrement
    vect_coul.valeur = 8
  fincas
  si m = "technique"
    vect_lissage.valeur = 10
    vect_detail.valeur = 90
  finsi
  VECT_LANCER(nul)
retourner

procedure VECT_LANCER(ev)
  locale t0 = horodatage()
  locale page = sisinon(vect_page = nul, 1, nombre(vect_page.valeur))
  vect_info.libelle = "Vectorisation…"
  locale svg = ""
  essayer
    svg = pub.vectoriser(VECT.source, {mode = MODE_VECT(), couleurs = nombre(vect_coul.valeur), lissage = nombre(vect_lissage.valeur) / 100, ;
                                       detail = nombre(vect_detail.valeur) / 100, page = page})
  capturer e
    vect_info.libelle = "Échec : " + e
    retourner
  finessayer
  VECT.svg = svg
  VECT.page = page
  && original (PNG temporaire) et résultat côte à côte
  locale tmp = fichier.joindre(fichier.dossiertemp(), "kaleido_vect_" + page + ".png")
  locale im = pub.importer(VECT.source, tmp, {page = page})
  locale l = sisinon(im = nul, 800, im.largeur)
  locale h = sisinon(im = nul, 600, im.hauteur)
  vect_toile:chargerpages({'<svg xmlns="http://www.w3.org/2000/svg" width="' + l + '" height="' + h + '"><image href="' + tmp + '" x="0" y="0" width="' + l + '" height="' + h + '"/></svg>', svg}, ;
                          {colonnes = 2, ecart = 24, legendes = {"Original", "SVG vectoriel"}})
  vect_info.libelle = "SVG : " + OCTETS(#svg) + " · " + PLURIEL(NB_OCCURRENCES(svg, "<path"), "chemin") + " · " + arrondi((horodatage() - t0) * 1000) + " ms"
retourner

fonction NB_OCCURRENCES(s, motif)
  locale n = 0
  locale k = position(motif, s)
  tantque k > 0
    n += 1
    s = souschaine(s, k + #motif)
    k = position(motif, s)
  fintantque
retourner n

procedure VECT_CREER(ev)
  si VECT.svg = ""
    retourner
  finsi
  locale base_ = fichier.nom(VECT.source)
  locale t = ui.demander("Titre du composant :", gauche(base_, #base_ - #fichier.extension(base_)))
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale genre = sisinon(MODE_VECT() = "logo", "logo", sisinon(MODE_VECT() = "technique", "schema", "illustration"))
  locale id = ENREGISTRER_COMPOSANT({titre = rogner(t), genre = genre, ext = "svg", dossier = "Vectorisations", tags = {"vectorisé", MODE_VECT()}, ;
                                    description = "Vectorisé depuis " + base_ + " (" + MODE_VECT() + ")"}, VECT.svg, nul)
  fenvect:fermer()
  RAFRAICHIR_BIBLIOTHEQUE()
  OUVRIR_ESPACE("dessin")
  DESSIN_OUVRIR_COMPOSANT(COMPOSANT(id), nul)
  STATUT("Composant « " + t + " » créé : chaque couleur est un chemin éditable (outil Nœuds).")
retourner

procedure VECT_IMAGE_SEULE(ev)
  locale base_ = fichier.nom(VECT.source)
  locale t = ui.demander("Titre de l'image :", gauche(base_, #base_ - #fichier.extension(base_)))
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale m = {titre = rogner(t), genre = "image", ext = "png", dossier = "Images", tags = {}}
  locale id = ENREGISTRER_COMPOSANT(m, nul, nul)
  pub.importer(VECT.source, FICHIER_COMPOSANT(COMPOSANT(id), nul), {page = VECT.page})
  INDEXER_COMPOSANT(COMPOSANT(id))
  fenvect:fermer()
  RAFRAICHIR_BIBLIOTHEQUE()
  STATUT("Image « " + t + " » ajoutée à la bibliothèque.")
retourner

fonction MODE_VECT()
retourner COMBO_VAL(vect_mode, {"couleurs", "logo", "mono", "gris", "technique", "illustration"})

&&  import SVG et planches de symboles

procedure IMPORTER_PLANCHE(ev)
  locale f = ui.ouvrirfichier{titre = "Fichier SVG (planche de symboles ou illustration)", filtre = "SVG|*.svg"}
  si f <> nul
    IMPORTER_SVG(f)
  finsi
retourner

procedure IMPORTER_SVG(f)
  locale code = LIRE_TEXTE(f)
  locale syms = pub.symbolessvg(code, {couleur = "#1E293B", taille = 256})
  si #syms > 0
    IMPORTER_SYMBOLES(f, syms)
    retourner
  finsi
  && SVG ordinaire : un seul composant illustration, ouvert dans l'éditeur vectoriel
  locale base_ = fichier.nom(f)
  locale t = ui.demander("Titre du composant :", gauche(base_, #base_ - #fichier.extension(base_)))
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale id = ENREGISTRER_COMPOSANT({titre = rogner(t), genre = "illustration", ext = "svg", dossier = "Imports", tags = {"importé"}, ;
                                    description = "Importé depuis " + base_}, code, nul)
  RAFRAICHIR_BIBLIOTHEQUE()
  OUVRIR_ESPACE("dessin")
  DESSIN_OUVRIR_COMPOSANT(COMPOSANT(id), nul)
  STATUT("Illustration « " + t + " » importée.")
retourner

fonction SYMBOLE_EXISTANT(source, sid)
  && composant déjà importé depuis la même planche (réimportation = mise à jour)
  pour chaque id, c dans COMPOSANTS
    si c.planche = source et c.symbole = sid
      retourner c
    finsi
  suivant
retourner nul

procedure IMPORTER_SYMBOLES(f, syms)
  locale base_ = fichier.nom(f)
  locale nom_ = gauche(base_, #base_ - #fichier.extension(base_))
  locale dossier_ = "Symboles/" + nom_
  locale noms = ""
  locale nouveaux = 0
  locale maj = 0
  locale utilises = 0
  pour i = 1 a #syms
    locale c = SYMBOLE_EXISTANT(base_, syms[i].id)
    si c = nul
      nouveaux += 1
    sinonsi CONTENU_COMPOSANT(c, nul) <> syms[i].svg
      maj += 1
      si #UTILISATIONS(c.id) > 0
        utilises += 1
      finsi
    finsi
    si i <= 8
      noms = noms + sisinon(noms = "", "", ", ") + syms[i].titre
    finsi
  suivant
  si #syms > 8
    noms = noms + "… (+" + (#syms - 8) + ")"
  finsi
  locale msg = chaine(#syms) + " symbole(s) trouvé(s) dans « " + base_ + " » :" + car(10) + noms + car(10) + car(10) + ;
               chaine(nouveaux) + " nouveau(x) composant(s) dans le dossier « " + dossier_ + " »"
  si maj > 0
    msg = msg + car(10) + chaine(maj) + " symbole(s) déjà importé(s) seront mis à jour (nouvelle version)"
    si utilises > 0
      msg = msg + car(10) + "dont " + utilises + " déjà utilisé(s) dans vos livrables"
    finsi
  finsi
  si nouveaux = 0 et maj = 0
    ui.alerte("Les " + #syms + " symboles de « " + base_ + " » sont déjà dans la bibliothèque, à jour.", "information")
    retourner
  finsi
  si non ui.confirmer(msg + "." + car(10) + car(10) + "Importer ?", "question")
    retourner
  finsi
  locale premier = nul
  pour chaque sy dans syms
    locale c = SYMBOLE_EXISTANT(base_, sy.id)
    locale m = c
    si m = nul
      m = {titre = sy.titre, genre = "illustration", ext = "svg", dossier = dossier_, tags = {"symbole", nom_}, ;
           description = "Symbole « " + sy.id + " » de la planche " + base_, planche = base_, symbole = sy.id}
    finsi
    si c = nul ou CONTENU_COMPOSANT(c, nul) <> sy.svg
      locale id = ENREGISTRER_COMPOSANT(m, sy.svg, nul)
      si premier = nul
        premier = id
      finsi
    finsi
  suivant
  RAFRAICHIR_BIBLIOTHEQUE()
  si premier <> nul
    SELECTIONNER("composant", premier)
  finsi
  STATUT(chaine(nouveaux) + " symbole(s) importé(s), " + maj + " mis à jour, depuis « " + base_ + " » (dossier " + dossier_ + ").")
retourner

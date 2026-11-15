&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : publication PDF et site web autonome.
&&
&& PDF : documents (mise en page du moteur, polices incorporées, signets, liens, sommaire,
&& index, renvois, balisage d'accessibilité), présentations (diapositives vectorielles),
&& storyboards (planches). Qualités : standard, hd, ecran (léger), impression (repères de coupe).
&& Web : publication/web/ — index.html + lecteur.js + lecteur.css + contenu.js (données) +
&& medias/ ; aucune dépendance externe, fonctionne en file:// (navigateur, tablette, téléphone,
&& WebView Lexis+).

procedure CONSTRUIRE_PUBLICATION(o)
  globale lpub, mdpub, combo_qualite, PUBLIES
  PUBLIES = {}
  locale sep = o:ajouter(ui.separateur{vertical = vrai, position = 0.45})
  sep.ancrage = "centre"
  locale g = sep:ajouter(ui.conteneur("bordure"))
  locale t = g:ajouter(ui.etiquette("Fichiers publiés (double-clic : ouvrir)"))
  t.ancrage = "haut"
  t.couleur = "#A5B4FC"
  lpub = g:ajouter(ui.liste())
  lpub.ancrage = "centre"
  lpub.surdoubleclic = @PUB_OUVRIR
  mdpub = sep:ajouter(ui.markdown(""))
retourner

procedure RUBAN_PUBLICATION(r)
  LIBELLE(r, "Qualité PDF", 90)
  combo_qualite = r:ajouter(ui.combo("standard", "hd", "ecran", "impression"))
  combo_qualite:selectionner(1)
  combo_qualite.largeurfixe = 110
  combo_qualite.infobulle = "standard : images ≤ 2400 px ; hd : images d'origine ; ecran : léger ; impression : repères de coupe"
  ICONE(r, "pdf", "PDF du document", "Publier le document courant en PDF (Cmd+P)", @PUBLIER_PDF_COURANT)
  OUTIL(r, "Tous les PDF", @PUBLIER_TOUS_PDF, "Documents, présentations et storyboards")
  FILET(r)
  ICONE(r, "k-web", "Site web", "Générer le site web autonome (HTML, CSS, JS, SVG)", @PUBLIER_WEB)
  ICONE(r, "k-preview", "Lecteur", "Ouvrir le lecteur web intégré", @OUVRIR_LECTEUR)
  FILET(r)
  OUTIL(r, "Exporter le Markdown composé", @EXPORTER_MD, "Le document courant, composants résolus")
  OUTIL(r, "Exporter les SVG", @EXPORTER_SVG, "Copie des illustrations du projet")
retourner

procedure PUBLICATION_RAFRAICHIR
  lpub:vider()
  globale PUBLIES
  PUBLIES = {}
  pour chaque nom dans fichier.liste(CHEMIN("publication"), vrai)
    si non finitpar(nom, "/") et (finitpar(nom, ".pdf") ou finitpar(nom, "index.html") ou finitpar(nom, ".md"))
      locale f = CHEMIN("publication", nom)
      locale inf = fichier.infos(f)
      lpub:ajouter(nom + "   ·   " + OCTETS(sisinon(inf = nul, 0, inf.taille)))
      inserer(PUBLIES, f)
    finsi
  suivant
  locale n = car(10)
  mdpub.valeur = "## Publier" + n + n + ;
    "- **PDF du document** : mise en page identique à l'aperçu ; texte réel, polices Poppins et Lora incorporées, signets, liens actifs, sommaire, index, renvois, balisage d'accessibilité." + n + ;
    "- **Présentations** : une page vectorielle par diapositive, signets." + n + ;
    "- **Storyboards** : planches de six scènes avec légendes." + n + ;
    "- **Site web** : un dossier autonome (`publication/web`) à copier sur n'importe quel serveur ou à ouvrir directement ; lecteur avec navigation, recherche plein texte, zoom, modes documentation / présentation / storyboard, sommaire dynamique, annotations, favoris et historique." + n + n + ;
    "Dossier : `" + CHEMIN("publication") + "`"
retourner

procedure PUBLICATION_AJOUTER(f)
  si ESPACE = "publication"
    PUBLICATION_RAFRAICHIR()
  finsi
retourner

procedure PUB_OUVRIR(ev)
  locale i = nombre(lpub:selection())
  si i = nul ou i < 1 ou i > #PUBLIES
    retourner
  finsi
  OUVRIR_EXTERNE(PUBLIES[i])
retourner

procedure OUVRIR_EXTERNE(f)
  locale pl = systeme.plateforme()
  essayer
    faire cas
    cas pl = "macosx"
      systeme.executer('open "' + f + '"')
    cas pl = "windows"
      systeme.executer('start "" "' + f + '"')
    autrement
      systeme.executer('xdg-open "' + f + '" >/dev/null 2>&1 &')
    fincas
  capturer e
    STATUT("Ouverture impossible : " + e)
  finessayer
retourner

fonction QUALITE()
  si combo_qualite = nul
    retourner "standard"
  finsi
retourner COMBO_VAL(combo_qualite, {"standard", "hd", "ecran", "impression"})

fonction PUBLIER_DOCUMENT(d)
  locale r = COMPOSER_DOCUMENT(d, nul, d.meta.variante)
  locale g = r.gabarit
  g.qualite = QUALITE()
  g.sujet = sisinon(r.variables.SUJET = nul, "", r.variables.SUJET)
  g.motscles = sisinon(r.variables.MOTSCLES = nul, "", r.variables.MOTSCLES)
  locale dest = CHEMIN("publication", d.nom + sisinon(d.meta.variante <> nul, "-" + d.meta.variante, "") + ".pdf")
  locale res = pub.pdf(dest, r.texte, g)
  JOURNAL("info", "PDF " + dest + " (" + res.pages + " pages)")
retourner {chemin = dest, pages = res.pages, octets = res.octets, problemes = r.problemes}

procedure PUBLIER_PDF_COURANT(ev)
  locale x = DOC_ACTIF()
  si x = nul ou x.genre <> "document"
    si #DOCS = 0
      retourner
    finsi
    x = {genre = "document", id = DOCS[1].nom}
  finsi
  DOC_ENREGISTRER(nul)
  locale t0 = horodatage()
  locale r = PUBLIER_DOCUMENT(DOC(x.id))
  STATUT("PDF publié : " + fichier.nom(r.chemin) + " · " + PLURIEL(r.pages, "page") + " · " + OCTETS(r.octets) + " · " + arrondi((horodatage() - t0) * 1000) + " ms" + ;
         sisinon(#r.problemes > 0, " · ⚠ " + PLURIEL(#r.problemes, "problème"), ""))
  PUBLICATION_AJOUTER(r.chemin)
  si ev <> nul
    OUVRIR_EXTERNE(r.chemin)
  finsi
retourner

procedure PUBLIER_TOUS_PDF(ev)
  locale n = 0
  pour chaque d dans DOCS
    PUBLIER_DOCUMENT(d)
    n += 1
  suivant
  locale pc = PRES_COURANTE
  pour chaque d dans PRES
    globale PRES_COURANTE
    PRES_COURANTE = d
    PRES_PDF(nul)
    n += 1
  suivant
  PRES_COURANTE = pc
  locale sc = SB_COURANT
  pour chaque d dans SB
    globale SB_COURANT
    SB_COURANT = d
    SB_PDF(nul)
    n += 1
  suivant
  SB_COURANT = sc
  PUBLICATION_RAFRAICHIR()
  STATUT(PLURIEL(n, "PDF") + " publiés dans " + CHEMIN("publication"))
retourner

procedure EXPORTER_MD(ev)
  locale x = DOC_ACTIF()
  si x = nul ou x.genre <> "document"
    retourner
  finsi
  locale d = DOC(x.id)
  locale r = COMPOSER_DOCUMENT(d, ed:texte(), d.meta.variante)
  locale dest = CHEMIN("publication", d.nom + "-compose.md")
  ECRIRE_TEXTE(dest, r.texte)
  PUBLICATION_RAFRAICHIR()
  STATUT("Markdown composé : " + dest)
retourner

procedure EXPORTER_SVG(ev)
  locale dest = CHEMIN("publication", "svg")
  fichier.creerdossier(dest)
  locale n = 0
  pour chaque id, c dans COMPOSANTS
    si c.ext = "svg"
      fichier.copier(FICHIER_COMPOSANT(c, nul), fichier.joindre(dest, c.id + ".svg"))
      n += 1
    finsi
  suivant
  STATUT(PLURIEL(n, "SVG") + " exportés dans " + dest)
retourner

&&
&& Site web autonome et lecteur
&&

fonction WEB_CHEMIN_MEDIA(f, medias, dossier_web)
  && copie un fichier référencé dans web/medias et renvoie son chemin relatif
  si f = nul ou f = ""
    retourner ""
  finsi
  si medias[f] <> nul
    retourner medias[f]
  finsi
  locale nom = pub.ancre(fichier.nom(fichier.dossier(f))) + "-" + fichier.nom(f)
  fichier.copier(f, fichier.joindre(dossier_web, "medias", nom))
  medias[f] = "medias/" + nom
retourner medias[f]

&& SVG autonome (images incorporées) : affichable par <img> dans tout navigateur
fonction WEB_SVG_AUTONOME(f, medias, dossier_web)
  si medias[f] <> nul
    retourner medias[f]
  finsi
  locale nom = pub.ancre(fichier.nom(fichier.dossier(f))) + "-" + fichier.nom(f)
  locale r = pub.optimisersvg(LIRE_TEXTE(f), {images = vrai})
  ECRIRE_TEXTE(fichier.joindre(dossier_web, "medias", nom), r.svg)
  medias[f] = "medias/" + nom
retourner medias[f]

&& remplace les chemins absolus d'images par des chemins du site
fonction WEB_IMAGES(html_, medias, dossier_web)
  locale sortie = ""
  locale reste = html_
  locale k = position('<img src="', reste)
  tantque k > 0
    sortie = sortie + gauche(reste, k + 9)
    reste = souschaine(reste, k + 10)
    locale f = position('"', reste)
    locale src = gauche(reste, f - 1)
    si commencepar(src, "../")
      src = CHEMIN(souschaine(src, 4))
    finsi
    si fichier.existe(src) et finitpar(minuscule(src), ".svg")
      sortie = sortie + WEB_SVG_AUTONOME(src, medias, dossier_web)
    sinonsi fichier.existe(src)
      sortie = sortie + WEB_CHEMIN_MEDIA(src, medias, dossier_web)
    sinon
      sortie = sortie + src
    finsi
    reste = souschaine(reste, f)
    k = position('<img src="', reste)
  fintantque
retourner sortie + reste

procedure PUBLIER_WEB(ev)
  locale t0 = horodatage()
  locale web = CHEMIN("publication", "web")
  fichier.creerdossier(fichier.joindre(web, "medias"))
  locale medias = {}
  locale site = {titre = PROJ.titre, auteur = sisinon(PROJ.auteur = nul, "", PROJ.auteur), genere = MAINTENANT_ISO(), documents = {}, presentations = {}, storyboards = {}}
  pour chaque d dans DOCS
    locale r = COMPOSER_DOCUMENT(d, nul, d.meta.variante)
    locale h = WEB_IMAGES(pub.html(r.texte), medias, web)
    inserer(site.documents, {id = d.nom, titre = r.gabarit.titre, html = h, texte = pub.textebrut(r.texte), titres = pub.titres(r.texte)})
  suivant
  pour chaque d dans PRES
    locale diapos = {}
    pour chaque s dans d.diapositives
      inserer(diapos, {titre = s.titre, svg = WEB_SVG_AUTONOME(CHEMIN(s.svg), medias, web), notes = sisinon(s.notes = nul, "", s.notes), ;
                       transition = sisinon(s.transition = nul, "fondu", s.transition), texte = sisinon(s.texte = nul, "", s.texte)})
    suivant
    inserer(site.presentations, {id = d.nom, titre = d.titre, diapositives = diapos})
  suivant
  pour chaque d dans SB
    locale scenes = {}
    pour chaque s dans d.scenes
      inserer(scenes, {titre = s.titre, svg = WEB_SVG_AUTONOME(CHEMIN(s.svg), medias, web), duree = sisinon(s.duree = nul, 5, s.duree), ;
                       sequence = sisinon(s.sequence = nul, "", s.sequence), commentaire = sisinon(s.commentaire = nul, "", s.commentaire)})
    suivant
    inserer(site.storyboards, {id = d.nom, titre = d.titre, scenes = scenes})
  suivant
  ECRIRE_TEXTE(fichier.joindre(web, "contenu.js"), "window.KALEIDO = " + JSONK(site, "") + ";" + car(10))
  locale res = fichier.joindre(systeme.dossierprogramme(), "ressources")
  fichier.copier(fichier.joindre(res, "lecteur.js"), fichier.joindre(web, "lecteur.js"))
  fichier.copier(fichier.joindre(res, "lecteur.css"), fichier.joindre(web, "lecteur.css"))
  && polices du site : les mêmes que celles du PDF
  locale dpol = fichier.joindre(systeme.dossierprogramme(), "..", "..", "ttf")
  fichier.creerdossier(fichier.joindre(web, "polices"))
  pour chaque p dans {"Poppins-Regular", "Poppins-Medium", "Poppins-Bold", "Lora-Regular", "Lora-Bold", "Lora-Italic"}
    si fichier.existe(fichier.joindre(dpol, p + ".ttf"))
      fichier.copier(fichier.joindre(dpol, p + ".ttf"), fichier.joindre(web, "polices", p + ".ttf"))
    finsi
  suivant
  ECRIRE_TEXTE(fichier.joindre(web, "index.html"), remplacertexte(LIRE_TEXTE(fichier.joindre(res, "index.html")), "{{titre}}", XML(PROJ.titre)))
  PUBLICATION_RAFRAICHIR()
  STATUT("Site web publié : " + fichier.joindre(web, "index.html") + " · " + PLURIEL(#site.documents, "document") + ", " + ;
         PLURIEL(#site.presentations, "présentation") + ", " + PLURIEL(#site.storyboards, "storyboard") + " · " + arrondi((horodatage() - t0) * 1000) + " ms")
retourner

&& lecteur intégré : le site dans une WebView (processus séparé), sinon le navigateur
procedure OUVRIR_LECTEUR(ev)
  locale idx = CHEMIN("publication", "web", "index.html")
  si non fichier.existe(idx)
    PUBLIER_WEB(nul)
  finsi
  locale prog = fichier.joindre(systeme.dossierprogramme(), "ressources", "lecteur.prg")
  essayer
    lexis.executer(prog, {arguments = {idx}})
    STATUT("Lecteur web intégré ouvert.")
  capturer e
    OUVRIR_EXTERNE(idx)
  finessayer
retourner

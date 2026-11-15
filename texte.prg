&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : éditeur Markdown enrichi (source, mixte, aperçu) et aperçu paginé en direct.
&&
&& L'éditeur (coloration Markdown, complétion des composants et variables, recherche,
&& annulation) est à gauche ; l'aperçu est le document publié lui-même : le moteur de mise en
&& page (paquet publication) produit les pages affichées par la toile, comme dans le PDF.

procedure CONSTRUIRE_DOCUMENT(o)
  globale ed, apercu, sepdoc, DOCS_OUVERTS, APERCU_ETAT, lbldoc
  DOCS_OUVERTS = {}
  APERCU_ETAT = {demande = 0, version = 0, titres = {}, uid = nul, pages = 0}
  locale info = o:ajouter(ui.rangee())
  info.ancrage = "haut"
  info.marge = 4
  lbldoc = info:ajouter(ui.etiquette(""))
  lbldoc.poids = 1
  lbldoc.couleur = "#CBD5E1"
  sepdoc = o:ajouter(ui.separateur{vertical = vrai, position = 0.52})
  sepdoc.ancrage = "centre"
  ed = sepdoc:ajouter(ui.editeur{minicarte = faux})
  ed.surchangement = @DOC_CHANGE
  ed.surselection = @DOC_SIGNAL
  ed:accueil({"Kaléido", "Aucun document ouvert", "", "Double-cliquez un document", "ou un composant de la bibliothèque", "", ;
              "Cmd+K  commandes", "Cmd+Maj+N  nouveau composant"})
  apercu = sepdoc:ajouter(ui.toile{mode = "galerie"})
  apercu.surselection = @APERCU_CLIC
  apercu.surdoubleclic = @APERCU_DOUBLE
retourner

procedure RUBAN_DOCUMENT(r)
  globale combo_variante, bmode_source, bmode_mixte, bmode_apercu, bextraits
  ICONE(r, "nouveau", "Nouveau document", "Nouveau document (à partir d'un modèle)", @DOC_NOUVEAU)
  ICONE(r, "enregistrer", "Enregistrer", "Enregistrer (Cmd+S)", @DOC_ENREGISTRER)
  FILET(r)
  ICONE(r, "k-h1", "Titre", "Titre : # au début de la ligne (répéter : niveau suivant)", @FMT_TITRE)
  ICONE(r, "k-bold", "Gras", "**gras** (Cmd+B dans l'éditeur)", @FMT_GRAS)
  ICONE(r, "k-italic", "Italique", "*italique*", @FMT_ITALIQUE)
  ICONE(r, "k-list", "Liste", "Liste à puces", @FMT_LISTE)
  ICONE(r, "k-olist", "Liste numérotée", "Liste numérotée", @FMT_LISTE_NUM)
  ICONE(r, "k-checklist", "Cases", "Liste de tâches [ ] / [x]", @FMT_CASES)
  ICONE(r, "k-quote", "Citation", "Citation", @FMT_CITATION)
  ICONE(r, "k-callout", "Encadré", "Encadré : remarque, astuce, attention, important, danger", @FMT_ENCADRE)
  ICONE(r, "k-source", "Code", "Bloc de code", @FMT_CODE)
  ICONE(r, "k-table", "Tableau", "Tableau", @FMT_TABLEAU)
  ICONE(r, "k-link", "Lien", "Lien [texte](adresse) ; #ancre pour un renvoi interne", @FMT_LIEN)
  ICONE(r, "k-image", "Image", "Insérer une image (copiée dans medias/) ou un SVG", @FMT_IMAGE)
  FILET(r)
  ICONE(r, "k-component", "Composant", "Insérer une référence de composant {{> id}}", @DOC_CHOISIR_COMPOSANT)
  ICONE(r, "k-variable", "Variable", "Insérer une variable ou une macro {{…}}", @DOC_CHOISIR_VARIABLE)
  bextraits = ICONE(r, "k-snippet", "Extraits", "Extraits : blocs prêts à l'emploi", @DOC_EXTRAITS)
  bextraits.surselection = @DOC_EXTRAIT_CHOIX
  ICONE(r, "k-variant", "Extraire", "Faire de la sélection un composant réutilisable (remplacée par sa référence)", @DOC_EXTRAIRE_COMPOSANT)
  FILET(r)
  bmode_source = OUTIL(r, "Source", @MODE_SOURCE, "Mode source : l'éditeur seul")
  bmode_mixte = OUTIL(r, "Mixte", @MODE_MIXTE, "Mode mixte : source et aperçu côte à côte")
  bmode_apercu = OUTIL(r, "Aperçu", @MODE_APERCU, "Mode aperçu (lecture, WYSIWYG) : le document mis en page")
  FILET(r)
  LIBELLE(r, "Variante", 66)
  combo_variante = r:ajouter(ui.combo("standard", "client", "produit", "marketing", "pedagogique"))
  combo_variante:selectionner(1)
  combo_variante.largeurfixe = 120
  combo_variante.surselection = @DOC_VARIANTE
  combo_variante.infobulle = "Variante de composition : chaque composant qui en possède une l'utilise"
  ICONE(r, "k-settings", "Gabarit", "Gabarit du document : format, marges, polices, couleurs, en-têtes", @DOC_GABARIT)
  ICONE(r, "pdf", "PDF", "Publier ce document en PDF (Cmd+P)", @PUBLIER_PDF_COURANT)
  locale e = r:ajouter(ui.etiquette(""))
  e.poids = 1
  ICONE(r, "zoommoins", "Zoom -", "Réduire l'aperçu", @APERCU_ZOOM_MOINS)
  ICONE(r, "zoomplus", "Zoom +", "Agrandir l'aperçu", @APERCU_ZOOM_PLUS)
  ICONE(r, "ajuster", "Ajuster", "Pages à la largeur de l'aperçu", @APERCU_AJUSTER)
retourner

&&
&& Documents ouverts
&&

procedure OUVRIR_DOCUMENT(nom)
  globale DOC_COURANT
  locale d = DOC(nom)
  si d = nul
    retourner
  finsi
  locale uid = ed:ouvrir(d.chemin)
  DOCS_OUVERTS[chaine(uid)] = {genre = "document", id = d.nom}
  ed:pastille("doc", uid, "#6366F1")
  COMBO_FIXER(combo_variante, VARIANTES_DOC(), sisinon(d.meta.variante = nul, "standard", d.meta.variante))
  DOC_MAJ_NOMS()
  APERCU_DEMANDER()
  APERCU_MAINTENANT()
retourner

procedure DOC_OUVRIR_COMPOSANT(c, variante)
  locale f = FICHIER_COMPOSANT(c, variante)
  si non fichier.existe(f)
    ECRIRE_TEXTE(f, CONTENU_COMPOSANT(c, nul))
  finsi
  locale uid = ed:ouvrir(f)
  DOCS_OUVERTS[chaine(uid)] = {genre = "composant", id = c.id, variante = variante}
  ed:pastille(sisinon(variante = nul, "comp", variante), uid, "#10B981")
  ed:langage("markdown", uid)
  DOC_MAJ_NOMS()
  APERCU_DEMANDER()
  APERCU_MAINTENANT()
retourner

&& document ou composant de l'onglet actif : {genre, id, variante} ou nul
fonction DOC_ACTIF()
  locale uid = ed:actif()
  si uid = nul ou uid < 0
    && aucun onglet ouvert
    retourner nul
  finsi
  locale x = DOCS_OUVERTS[chaine(uid)]
  si x = nul
    && fichier ouvert autrement : on le retrouve par son chemin
    locale ch = ed:chemin(uid)
    pour chaque d dans DOCS
      si d.chemin = ch
        x = {genre = "document", id = d.nom}
        DOCS_OUVERTS[chaine(uid)] = x
      finsi
    suivant
  finsi
retourner x

procedure DOC_MAJ_NOMS
  && complétion : composants et variables
  locale noms = {}
  pour chaque id, c dans COMPOSANTS
    inserer(noms, c.id + car(9) + "composant · " + c.titre)
  suivant
  pour chaque k, v dans PROJ.variables
    inserer(noms, minuscule(k) + car(9) + "variable = " + v)
  suivant
  pour chaque m dans {"date", "heure", "projet", "auteur", "toc", "index", "saut"}
    inserer(noms, m + car(9) + "macro")
  suivant
  pour chaque k, v dans MACROS
    inserer(noms, minuscule(k) + car(9) + "macro (extension)")
  suivant
  ed:noms(noms)
retourner

procedure DOC_CHANGE(ev)
  APERCU_DEMANDER()
retourner

procedure DOC_SIGNAL(ev)
  locale s = ev.texte
  faire cas
  cas s = "cmd:save"
    DOC_ENREGISTRER(nul)
  cas commencepar(s, "cmd:close:")
    && croix (ou clic du milieu) sur un onglet : l'éditeur demande, Kaléido décide
    DOC_FERMER(nombre(souschaine(s, 11)))
  cas commencepar(s, "doc:")
    && changement d'onglet
    locale x = DOC_ACTIF()
    si x <> nul
      SELECTIONNER(x.genre, x.id)
      si x.genre = "document"
        locale d = DOC(x.id)
        COMBO_FIXER(combo_variante, VARIANTES_DOC(), sisinon(d.meta.variante = nul, "standard", d.meta.variante))
      finsi
    finsi
    APERCU_DEMANDER()
  cas commencepar(s, "pos:")
    lblinfo.libelle = "Ligne " + remplacertexte(souschaine(s, 5), ":", " · col. ")
  fincas
retourner

procedure DOC_FERMER(uid)
  globale DOCS_OUVERTS
  locale x = DOCS_OUVERTS[chaine(uid)]
  si ed:modifie(uid)
    si x <> nul et x.genre = "composant"
      && un composant partagé n'est jamais enregistré en silence : l'impact doit être montré
      locale c = COMPOSANT(x.id)
      locale nom_ = sisinon(c = nul, x.id, c.titre)
      si non ui.confirmer("Le composant « " + nom_ + " » a des modifications non enregistrées." + car(10) + ;
                          "Fermer l'onglet en les abandonnant ?" + car(10) + car(10) + ;
                          "(Pour les garder : annulez, puis Cmd+S — l'analyse d'impact s'affichera.)", "question")
        ed:activer(uid)
        retourner
      finsi
    sinon
      && un document est enregistré à la fermeture, comme lors de l'enregistrement automatique
      essayer
        ed:enregistrer(nul, uid)
        si x <> nul
          INDEXER_LIVRABLE("document", x.id)
        finsi
      capturer e
        si non ui.confirmer("Impossible d'enregistrer ce document (" + e + ")." + car(10) + "Fermer quand même ?", "attention")
          retourner
        finsi
      finessayer
    finsi
  finsi
  ed:fermer(uid)
  DOCS_OUVERTS[chaine(uid)] = nul
  si ed:actif() < 0
    && plus aucun onglet : aperçu et fiche vidés
    apercu:chargerpages({}, {colonnes = 1, ecart = 24})
    APERCU_ETAT.uid = nul
    lbldoc.libelle = "Aucun document ouvert : double-cliquez un document (vue Projet) ou un composant de la bibliothèque."
    SELECTIONNER(nul, nul)
  finsi
retourner

procedure DOC_ENREGISTRER(ev)
  locale x = DOC_ACTIF()
  si x = nul
    retourner
  finsi
  si x.genre = "composant"
    && un composant partagé : l'impact est montré avant toute modification
    locale c = COMPOSANT(x.id)
    locale nouveau = ed:texte()
    si nouveau = CONTENU_COMPOSANT(c, x.variante)
      retourner
    finsi
    DEMANDER_IMPACT(c, nouveau, x.variante, @DOC_APRES_IMPACT)
    retourner
  finsi
  ed:enregistrer()
  INDEXER_LIVRABLE("document", x.id)
  STATUT("Document enregistré (" + heure() + ").")
retourner

&& après la décision de l'utilisateur sur l'impact (propager, ignorer, variante, branche)
procedure DOC_APRES_IMPACT(res)
  si res = nul
    retourner
  finsi
  && le fichier sur disque a été écrit par la décision : l'onglet est marqué enregistré
  essayer
    ed:fixertexte(ed:texte(), nul, vrai)
  capturer e
  finessayer
  APERCU_DEMANDER()
retourner

procedure DOC_ENREGISTRER_SI_MODIFIE
  essayer
    pour chaque d dans ed:documents()
      si d.modifie
        locale x = DOCS_OUVERTS[chaine(d.uid)]
        si x = nul ou x.genre = "document"
          ed:enregistrer(nul, d.uid)
        finsi
      finsi
    suivant
  capturer e
  finessayer
retourner

procedure DOC_INSERER(t)
  OUVRIR_ESPACE("document")
  ed:inserer(t)
  ed:focus()
  APERCU_DEMANDER()
retourner

&&
&& Mise en forme
&&

procedure ENTOURER(avant, apres, defaut)
  locale s = ed:selection()
  si s = nul ou s = ""
    s = defaut
  finsi
  ed:inserer(avant + s + apres)
  ed:focus()
retourner

procedure PREFIXER_LIGNES(prefixe, numeroter)
  locale s = ed:selection()
  si s = nul ou s = ""
    ed:inserer(car(10) + prefixe + "élément" + car(10))
    retourner
  finsi
  locale r = {}
  locale n = 1
  pour chaque l dans LIGNES(s)
    si rogner(l) <> ""
      inserer(r, sisinon(numeroter, n + ". ", prefixe) + l)
      n += 1
    sinon
      inserer(r, l)
    finsi
  suivant
  ed:inserer(joindre(r, car(10)))
  ed:focus()
retourner

procedure FMT_TITRE(ev)
  locale s = ed:selection()
  si s = nul ou s = ""
    ed:inserer(car(10) + "## Titre" + car(10))
  sinonsi commencepar(s, "#")
    ed:inserer("#" + s)
  sinon
    ed:inserer("## " + s)
  finsi
  ed:focus()
retourner
procedure FMT_GRAS(ev)
  ENTOURER("**", "**", "gras")
retourner
procedure FMT_ITALIQUE(ev)
  ENTOURER("*", "*", "italique")
retourner
procedure FMT_LISTE(ev)
  PREFIXER_LIGNES("- ", faux)
retourner
procedure FMT_LISTE_NUM(ev)
  PREFIXER_LIGNES("", vrai)
retourner
procedure FMT_CASES(ev)
  PREFIXER_LIGNES("- [ ] ", faux)
retourner
procedure FMT_CITATION(ev)
  PREFIXER_LIGNES("> ", faux)
retourner
procedure FMT_ENCADRE(ev)
  locale s = ed:selection()
  ed:inserer(car(10) + "> [!TIP] Astuce" + car(10) + "> " + sisinon(s = nul ou s = "", "Votre texte.", remplacertexte(s, car(10), car(10) + "> ")) + car(10))
  ed:focus()
retourner
procedure FMT_CODE(ev)
  locale s = ed:selection()
  si s <> nul et s <> "" et non contient(s, car(10))
    ENTOURER("`", "`", "")
    retourner
  finsi
  ed:inserer(car(10) + "```lexis" + car(10) + sisinon(s = nul ou s = "", "", s + car(10)) + "```" + car(10))
  ed:focus()
retourner
procedure FMT_TABLEAU(ev)
  ed:inserer(car(10) + "| Colonne | Valeur | Remarque |" + car(10) + "|:--|--:|---|" + car(10) + "| A | 1 | |" + car(10) + "| B | 2 | |" + car(10))
  ed:focus()
retourner
procedure FMT_LIEN(ev)
  locale s = ed:selection()
  locale u = ui.demander("Adresse du lien (https://… ou #ancre) :", "https://")
  si u <> nul et rogner(u) <> "" et rogner(u) <> "https://"
    ed:inserer("[" + sisinon(s = nul ou s = "", "lien", s) + "](" + u + ")")
  finsi
  ed:focus()
retourner

procedure FMT_IMAGE(ev)
  locale f = ui.ouvrirfichier{titre = "Image à insérer", filtre = "Images et PDF|*.png;*.jpg;*.jpeg;*.gif;*.bmp;*.svg;*.webp;*.pdf"}
  si f = nul
    retourner
  finsi
  locale dest = IMPORTER_MEDIA(f)
  si dest = nul
    ui.alerte("Image illisible : " + f, "attention")
    retourner
  finsi
  ed:inserer(car(10) + "![" + fichier.nom(dest) + "](../medias/" + fichier.nom(dest) + ")" + car(10))
  ed:focus()
retourner

&& copie (ou convertit) un fichier dans medias/ ; renvoie le chemin
fonction IMPORTER_MEDIA(f)
  locale ext = minuscule(fichier.extension(f))
  locale base_ = pub.ancre(gauche(fichier.nom(f), #fichier.nom(f) - #ext))
  si commencepar(ext, ".")
    ext = souschaine(ext, 2)
  finsi
  si ext = "png" ou ext = "jpg" ou ext = "jpeg" ou ext = "svg" ou ext = "bmp"
    locale dest = CHEMIN("medias", base_ + "." + ext)
    fichier.copier(f, dest)
    retourner dest
  finsi
  locale dest = CHEMIN("medias", base_ + ".png")
  si pub.importer(f, dest) = nul
    retourner nul
  finsi
retourner dest

&& extraits (snippets)
procedure DOC_EXTRAITS(ev)
  bextraits:menucontextuel("Encadré : remarque", "Encadré : attention", "Figure avec légende", "Tableau comparatif", ;
                             "Liste de tâches", "Définition", "Sommaire", "Index", "Saut de page", "En-tête du document (variables)", ;
                             "Section avec renvoi")
retourner

procedure DOC_EXTRAIT_CHOIX(ev)
  locale n = car(10)
  faire cas
  cas ev.texte = "Encadré : remarque"
    ed:inserer(n + "> [!NOTE]" + n + "> Information complémentaire." + n)
  cas ev.texte = "Encadré : attention"
    ed:inserer(n + "> [!WARNING] Attention" + n + "> Point de vigilance." + n)
  cas ev.texte = "Figure avec légende"
    ed:inserer(n + '![Schéma](../medias/schema.svg "Légende de la figure"){largeur=70%}' + n)
  cas ev.texte = "Tableau comparatif"
    ed:inserer(n + "| Critère | Option A | Option B |" + n + "|:--|:-:|:-:|" + n + "| Coût | ✓ | |" + n + "| Délai | | ✓ |" + n)
  cas ev.texte = "Liste de tâches"
    ed:inserer(n + "- [x] Fait" + n + "- [ ] À faire" + n)
  cas ev.texte = "Définition"
    ed:inserer(n + "**Terme**[[i:terme]] — définition du terme." + n)
  cas ev.texte = "Sommaire"
    ed:inserer(n + "{{toc}}" + n)
  cas ev.texte = "Index"
    ed:inserer(n + "{{index}}" + n)
  cas ev.texte = "Saut de page"
    ed:inserer(n + "{{saut}}" + n)
  cas ev.texte = "En-tête du document (variables)"
    ed:inserer("---" + n + "titre: Titre du document" + n + "soustitre: Sous-titre" + n + "auteur: " + sisinon(PROJ.auteur = nul, "", PROJ.auteur) + n + "---" + n)
  cas ev.texte = "Section avec renvoi"
    ed:inserer(n + "## Nouvelle section {#nouvelle-section}" + n + n + "Voir la page {{ref:nouvelle-section}}." + n)
  fincas
  ed:focus()
retourner

procedure DOC_CHOISIR_COMPOSANT(ev)
  locale items = {}
  pour chaque id, c dans COMPOSANTS
    inserer(items, {libelle = ICONE_GENRE(c.genre) + " " + c.titre, detail = c.id + sisinon(#c.variantes > 0, " · " + joindre(c.variantes, ", "), ""), valeur = c.id})
  suivant
  trier(items, @ITEM_ORDRE)
  QUICKPICK("Insérer un composant", items, @DOC_COMPOSANT_CHOISI)
retourner

procedure DOC_COMPOSANT_CHOISI(v)
  INSERER_COMPOSANT(v)
retourner

procedure DOC_CHOISIR_VARIABLE(ev)
  locale items = {}
  pour chaque k, v dans PROJ.variables
    inserer(items, {libelle = "{{" + minuscule(k) + "}}", detail = "variable du projet = " + v, valeur = "{{" + minuscule(k) + "}}"})
  suivant
  pour chaque m dans {{"date", "date du jour"}, {"projet", "titre du projet"}, {"auteur", "auteur du projet"}, {"toc", "sommaire"}, ;
                      {"index", "index alphabétique"}, {"index:terme", "entrée d'index"}, {"ref:ancre", "renvoi de page"}, {"saut", "saut de page"}}
    inserer(items, {libelle = "{{" + m[1] + "}}", detail = m[2], valeur = "{{" + m[1] + "}}"})
  suivant
  pour chaque k, v dans MACROS
    inserer(items, {libelle = "{{" + minuscule(k) + "}}", detail = "macro d'extension", valeur = "{{" + minuscule(k) + "}}"})
  suivant
  QUICKPICK("Insérer une variable ou une macro", items, @DOC_INSERER_VALEUR)
retourner

procedure DOC_INSERER_VALEUR(v)
  DOC_INSERER(v)
retourner

fonction ITEM_ORDRE(a, b)
retourner minuscule(a.libelle) < minuscule(b.libelle)

&& la sélection devient un composant (et est remplacée par sa référence)
procedure DOC_EXTRAIRE_COMPOSANT(ev)
  locale s = ed:selection()
  si s = nul ou rogner(s) = ""
    ui.alerte("Sélectionnez d'abord le texte à rendre réutilisable.", "information")
    retourner
  finsi
  locale premiere = rogner(remplacertexte(LIGNES(s)[1], "#", ""))
  locale t = ui.demander("Titre du composant :", COURT(premiere, 48))
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale genre = "texte"
  si commencepar(rogner(s), "#")
    genre = "chapitre"
  sinonsi commencepar(rogner(s), "- ") ou commencepar(rogner(s), "1.")
    genre = "liste"
  sinonsi commencepar(rogner(s), "|")
    genre = "tableau"
  finsi
  locale id = ENREGISTRER_COMPOSANT({titre = rogner(t), genre = genre, dossier = "Extraits", tags = {}}, s, nul)
  ed:inserer("{{> " + id + "}}")
  RAFRAICHIR_BIBLIOTHEQUE()
  DOC_MAJ_NOMS()
  STATUT("Composant « " + t + " » créé : le texte est désormais réutilisable partout ({{> " + id + "}}).")
retourner

procedure DOC_VARIANTE(ev)
  locale x = DOC_ACTIF()
  si x <> nul et x.genre = "document"
    locale d = DOC(x.id)
    locale v = COMBO_VAL(combo_variante, VARIANTES_DOC())
    d.meta.variante = sisinon(v = "standard", nul, v)
    ECRIRE_JSON(CHEMIN("documents", d.nom + ".json"), d.meta)
  finsi
  APERCU_DEMANDER()
retourner

&&
&& Modes : source, mixte, aperçu
&&

procedure MODE_SOURCE(ev)
  DOC_MODE("source")
retourner
procedure MODE_MIXTE(ev)
  DOC_MODE("mixte")
retourner
procedure MODE_APERCU(ev)
  DOC_MODE("apercu")
retourner

procedure DOC_MODE(m)
  reglages.mode_doc = m
  ed.visible = m <> "apercu"
  apercu.visible = m <> "source"
  pour chaque x dans {{bmode_source, "source"}, {bmode_mixte, "mixte"}, {bmode_apercu, "apercu"}}
    x[1].fond = sisinon(x[2] = m, "#312E81", "")
  suivant
  APERCU_DEMANDER()
retourner

&&
&& Aperçu paginé en direct
&&

procedure APERCU_DEMANDER
  APERCU_ETAT.demande = horodatage()
retourner

procedure APERCU_DIFFERE
  si APERCU_ETAT.demande > 0 et horodatage() - APERCU_ETAT.demande > 0.35
    APERCU_MAINTENANT()
  finsi
retourner

procedure APERCU_MAINTENANT
  APERCU_ETAT.demande = 0
  locale x = DOC_ACTIF()
  si x = nul ou non apercu.visible
    retourner
  finsi
  locale t0 = horodatage()
  locale texte_ = ed:texte()
  locale r = nul
  locale g = nul
  si x.genre = "document"
    locale d = DOC(x.id)
    r = COMPOSER_DOCUMENT(d, texte_, d.meta.variante)
    g = r.gabarit
  sinon
    locale c = COMPOSANT(x.id)
    r = COMPOSER(texte_, {variante = x.variante, pile = {c.id}})
    g = copier(PROJ.gabarit)
    g.couverture = faux
    g.entete = "Composant « " + c.titre + " »" + sisinon(x.variante <> nul, " @" + x.variante, "") + "||"
    g.pied = ""
    g.titre = c.titre
    g.dossier = CHEMIN("composants")
  finsi
  locale p = pub.paginer(r.texte, g)
  APERCU_ETAT.titres = p.titres
  APERCU_ETAT.pages = p.nbpages
  apercu:chargerpages(p.pages, {colonnes = 1, ecart = 24, garderposition = (APERCU_ETAT.uid = ed:actif())})
  APERCU_ETAT.uid = ed:actif()
  locale msg = PLURIEL(p.nbpages, "page") + " · " + PLURIEL(NB_MOTS(r.texte), "mot") + " · " + PLURIEL(#r.utilises, "composant") + ;
               " · mise en page " + p.duree + " ms"
  si #r.problemes > 0
    msg = msg + " · ⚠ " + r.problemes[1] + sisinon(#r.problemes > 1, " (+" + (#r.problemes - 1) + ")", "")
  finsi
  lbldoc.libelle = sisinon(x.genre = "document", "▤ " + DOC(x.id).titre, "◆ Composant " + x.id + sisinon(x.variante <> nul, " @" + x.variante, "")) + ;
                   "   ·   " + msg
  IA_PROPOSER_REUTILISATION(texte_, x)
retourner

procedure APERCU_CLIC(ev)
  si commencepar(ev.texte, "page-")
    lblinfo.libelle = "Page " + souschaine(ev.texte, 6) + " / " + APERCU_ETAT.pages
  finsi
retourner

&& double-clic sur une page : l'éditeur va au titre de cette page (navigation mixte)
procedure APERCU_DOUBLE(ev)
  si non commencepar(ev.texte, "page-")
    retourner
  finsi
  locale n = nombre(souschaine(ev.texte, 6))
  locale cible = nul
  pour chaque t dans APERCU_ETAT.titres
    si t.page <= n
      cible = t
    finsi
  suivant
  si cible <> nul
    ed:aller(1, 1)
    si non ed:chercher(cible.texte)
      ed:chercher(remplacertexte(cible.texte, "  ", " "))
    finsi
    ed:focus()
    STATUT("Page " + n + " : « " + cible.texte + " »")
  finsi
retourner

procedure APERCU_ZOOM_PLUS(ev)
  apercu:zoom(apercu:zoom() * 1.2)
retourner
procedure APERCU_ZOOM_MOINS(ev)
  apercu:zoom(apercu:zoom() / 1.2)
retourner
procedure APERCU_AJUSTER(ev)
  apercu:ajuster(vrai)
retourner

&&
&& Nouveaux documents et modèles
&&

procedure DOC_NOUVEAU(ev)
  locale items = {}
  pour chaque m dans MODELES()
    inserer(items, {libelle = m.titre, detail = m.description, valeur = m.id})
  suivant
  QUICKPICK("Nouveau document : choisissez un modèle", items, @DOC_NOUVEAU_MODELE)
retourner

procedure DOC_NOUVEAU_MODELE(id)
  locale m = nul
  pour chaque x dans MODELES()
    si x.id = id
      m = x
    finsi
  suivant
  locale t = ui.demander("Titre du document :", m.titre)
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale existants = {}
  pour chaque d dans DOCS
    existants[d.nom] = vrai
  suivant
  locale nom = IDENT(t, existants)
  ECRIRE_TEXTE(CHEMIN("documents", nom + ".md"), remplacertexte(m.contenu, "{{titre_document}}", rogner(t)))
  ECRIRE_JSON(CHEMIN("documents", nom + ".json"), {titre = rogner(t)})
  CHARGER_LIVRABLES()
  PROJET_ARBRE()
  OUVRIR_DOCUMENT(nom)
  STATUT("Document « " + t + " » créé à partir du modèle « " + m.titre + " ».")
retourner

fonction MODELES()
  locale n = car(10)
  locale r = { ;
    {id = "vide", titre = "Document vide", description = "Une page blanche", contenu = "# {{titre_document}}" + n + n}, ;
    {id = "rapport", titre = "Rapport", description = "Synthèse, contexte, analyse, recommandations, annexes", ;
     contenu = "---" + n + "titre: {{titre_document}}" + n + "soustitre: Rapport" + n + "---" + n + n + "{{toc}}" + n + n + ;
               "# Synthèse" + n + n + "> [!IMPORTANT] En bref" + n + "> Les trois messages clés." + n + n + "# Contexte" + n + n + ;
               "# Analyse" + n + n + "| Indicateur | Valeur | Tendance |" + n + "|:--|--:|:-:|" + n + "| A | 12 | ↗ |" + n + n + ;
               "# Recommandations" + n + n + "1. Première" + n + "2. Deuxième" + n + n + "# Annexes" + n + n + "{{index}}" + n}, ;
    {id = "manuel", titre = "Manuel utilisateur", description = "Prise en main, tâches, référence, dépannage", ;
     contenu = "---" + n + "titre: {{titre_document}}" + n + "soustitre: Manuel utilisateur" + n + "---" + n + n + "{{toc}}" + n + n + ;
               "# Prise en main" + n + n + "# Tâches courantes" + n + n + "## Créer" + n + n + "## Modifier" + n + n + ;
               "# Référence" + n + n + "# Dépannage" + n + n + "> [!WARNING] Avant de commencer" + n + "> Vérifiez les prérequis." + n + n + "{{index}}" + n}, ;
    {id = "livre", titre = "Livre / e-book", description = "Chapitres en page impaire, sommaire, index", ;
     contenu = "---" + n + "titre: {{titre_document}}" + n + "---" + n + n + "{{toc}}" + n + n + "# Chapitre premier" + n + n + ;
               "Il était une fois…" + n + n + "# Chapitre deux" + n + n + "{{index}}" + n}, ;
    {id = "logiciel", titre = "Documentation logicielle", description = "Installation, concepts, API, exemples de code", ;
     contenu = "---" + n + "titre: {{titre_document}}" + n + "soustitre: Documentation technique" + n + "---" + n + n + "{{toc}}" + n + n + ;
               "# Installation" + n + n + "```sh" + n + "wdlexisrt principal.prg" + n + "```" + n + n + "# Concepts" + n + n + ;
               "# API" + n + n + "| Fonction | Rôle |" + n + "|:--|:--|" + n + "| `ouvrir()` | Ouvre |" + n + n + "{{index}}" + n}, ;
    {id = "presse", titre = "Dossier de presse", description = "Communiqué, chiffres clés, visuels, contacts", ;
     contenu = "---" + n + "titre: {{titre_document}}" + n + "soustitre: Dossier de presse" + n + "---" + n + n + "# Communiqué" + n + n + ;
               "# Chiffres clés" + n + n + "# Visuels" + n + n + "# Contacts" + n}, ;
    {id = "formation", titre = "Support de formation", description = "Objectifs, modules, exercices, évaluation", ;
     contenu = "---" + n + "titre: {{titre_document}}" + n + "soustitre: Support de formation" + n + "---" + n + n + "{{toc}}" + n + n + ;
               "# Objectifs pédagogiques" + n + n + "- [ ] Objectif 1" + n + "- [ ] Objectif 2" + n + n + "# Module 1" + n + n + ;
               "> [!TIP] Exercice" + n + "> Mettez en pratique." + n + n + "# Évaluation" + n}}
  && modèles du projet (modeles/*.md)
  pour chaque nom dans fichier.liste(CHEMIN("modeles"))
    si finitpar(nom, ".md")
      inserer(r, {id = "projet:" + nom, titre = "Modèle du projet : " + gauche(nom, #nom - 3), description = "modeles/" + nom, ;
                  contenu = LIRE_TEXTE(CHEMIN("modeles", nom))})
    finsi
  suivant
retourner r

&&
&& Gabarit du document
&&

procedure DOC_GABARIT(ev)
  locale x = DOC_ACTIF()
  si x = nul ou x.genre <> "document"
    ui.alerte("Le gabarit s'applique à un document : ouvrez-en un.", "information")
    retourner
  finsi
  locale d = DOC(x.id)
  locale g = copier(PROJ.gabarit)
  pour chaque k, v dans d.meta
    g[k] = v
  suivant
  locale items = {}
  pour chaque f dans {"a4", "a5", "lettre", "livre", "16:9"}
    inserer(items, {libelle = "Format " + f, detail = sisinon(g.format = f, "actuel", ""), valeur = "format=" + f})
  suivant
  inserer(items, {libelle = "Justifier le texte : " + sisinon(g.justifier, "oui", "non"), detail = "basculer", valeur = "justifier"})
  inserer(items, {libelle = "Numéroter les titres : " + sisinon(g.numeroter, "oui", "non"), detail = "basculer", valeur = "numeroter"})
  inserer(items, {libelle = "Page de couverture : " + sisinon(g.couverture, "oui", "non"), detail = "basculer", valeur = "couverture"})
  inserer(items, {libelle = "Chapitre en nouvelle page : " + sisinon(g.chapitrenouvellepage, "oui", "non"), detail = "basculer", valeur = "chapitrenouvellepage"})
  inserer(items, {libelle = "Recto verso (marges miroir) : " + sisinon(g.rectoverso, "oui", "non"), detail = "basculer", valeur = "rectoverso"})
  pour chaque p dans {{"Lora", "Poppins"}, {"Poppins", "Poppins"}, {"Lora", "Lora"}}
    inserer(items, {libelle = "Polices : corps " + p[1] + ", titres " + p[2], detail = "", valeur = "polices=" + p[1] + "," + p[2]})
  suivant
  pour chaque c dans {{"Indigo", "#4f46e5"}, {"Océan", "#0369a1"}, {"Émeraude", "#047857"}, {"Corail", "#e11d48"}, {"Ardoise", "#334155"}, {"Ambre", "#b45309"}}
    inserer(items, {libelle = "Couleur d'accent : " + c[1], detail = c[2], valeur = "accent=" + c[2]})
  suivant
  globale GABARIT_DOC
  GABARIT_DOC = d
  QUICKPICK("Gabarit de « " + d.titre + " »", items, @DOC_GABARIT_CHOIX)
retourner

procedure DOC_GABARIT_CHOIX(v)
  locale d = GABARIT_DOC
  locale g = copier(PROJ.gabarit)
  pour chaque k, x dans d.meta
    g[k] = x
  suivant
  faire cas
  cas commencepar(v, "format=")
    d.meta.format = souschaine(v, 8)
  cas commencepar(v, "accent=")
    d.meta.accent = souschaine(v, 8)
  cas commencepar(v, "polices=")
    locale p = decouper(souschaine(v, 9), ",")
    d.meta.policecorps = p[1]
    d.meta.policetitres = p[2]
  autrement
    d.meta[majuscule(v)] = non g[majuscule(v)]
  fincas
  ECRIRE_JSON(CHEMIN("documents", d.nom + ".json"), d.meta)
  APERCU_DEMANDER()
  DOC_GABARIT(nul)
retourner

fonction VARIANTES_DOC()
retourner {"standard", "client", "produit", "marketing", "pedagogique"}

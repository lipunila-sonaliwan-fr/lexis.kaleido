&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : registre des commandes, palette universelle (Cmd+K), menus, choix rapide.
&&
&& Chaque action est une commande {id, libelle, categorie, raccourci, proc} : le menu, la
&& palette et les extensions s'appuient sur ce registre. La palette cherche aussi dans les
&& composants, les documents, les titres des documents et les présentations.

procedure COMMANDE(id, libelle, categorie, raccourci, proc)
  inserer(COMMANDES, {id = id, libelle = libelle, categorie = categorie, raccourci = sisinon(raccourci = nul, "", raccourci), proc = proc})
retourner

procedure ENREGISTRER_COMMANDES
  COMMANDE("doc.nouveau", "Nouveau document…", "Document", "", @DOC_NOUVEAU)
  COMMANDE("doc.enregistrer", "Enregistrer", "Document", "Cmd+S", @ENREGISTRER_TOUT)
  COMMANDE("doc.composant", "Insérer un composant…", "Document", "", @DOC_CHOISIR_COMPOSANT)
  COMMANDE("doc.variable", "Insérer une variable ou une macro…", "Document", "", @DOC_CHOISIR_VARIABLE)
  COMMANDE("doc.extraire", "Faire de la sélection un composant", "Document", "", @DOC_EXTRAIRE_COMPOSANT)
  COMMANDE("doc.source", "Mode source", "Affichage", "", @MODE_SOURCE)
  COMMANDE("doc.mixte", "Mode mixte", "Affichage", "", @MODE_MIXTE)
  COMMANDE("doc.apercu", "Mode aperçu", "Affichage", "", @MODE_APERCU)
  COMMANDE("doc.gabarit", "Gabarit du document…", "Document", "", @DOC_GABARIT)
  COMMANDE("comp.nouveau", "Nouveau composant…", "Bibliothèque", "Cmd+Maj+N", @NOUVEAU_COMPOSANT)
  COMMANDE("comp.reindexer", "Reconstruire l'index", "Bibliothèque", "", @CMD_REINDEXER)
  COMMANDE("dessin.nouveau", "Nouvelle illustration SVG…", "Dessin", "", @DESSIN_NOUVEAU)
  COMMANDE("dessin.importer", "Importer une image ou un PDF…", "Dessin", "", @DESSIN_IMPORTER)
  COMMANDE("dessin.vectoriser", "Vectoriser une image…", "Dessin", "", @VECTORISER_DIALOGUE)
  COMMANDE("dessin.planche", "Importer une planche de symboles SVG…", "Dessin", "", @IMPORTER_PLANCHE)
  COMMANDE("dessin.symbole", "Enregistrer la sélection comme symbole", "Dessin", "", @DESSIN_SYMBOLE)
  COMMANDE("dessin.optimiser", "Optimiser le SVG (nettoyer, simplifier, fusionner)", "Dessin", "", @DESSIN_OPTIMISER)
  COMMANDE("pres.nouvelle", "Nouvelle présentation…", "Présentation", "", @PRES_NOUVELLE)
  COMMANDE("pres.diapo", "Nouvelle diapositive…", "Présentation", "", @PRES_AJOUTER)
  COMMANDE("pres.lancer", "Lancer la présentation (conférence)", "Présentation", "F5", @PRES_LANCER)
  COMMANDE("pres.repetition", "Mode répétition (chronomètre)", "Présentation", "", @PRES_REPETITION)
  COMMANDE("pres.prompteur", "Téléprompteur", "Présentation", "F8", @PRES_TELEPROMPTEUR)
  COMMANDE("sb.nouveau", "Nouveau storyboard…", "Storyboard", "", @SB_NOUVEAU)
  COMMANDE("sb.scene", "Nouvelle scène", "Storyboard", "", @SB_AJOUTER)
  COMMANDE("graphe.impact", "Analyse d'impact de la sélection", "Graphe", "", @CMD_IMPACT)
  COMMANDE("graphe.global", "Graphe global du projet", "Graphe", "", @GRAPHE_GLOBAL)
  COMMANDE("var.nouvelle", "Créer une variante de la sélection…", "Variantes", "", @CMD_VARIANTE)
  COMMANDE("var.branche", "Créer une branche de la sélection…", "Variantes", "", @CMD_BRANCHE)
  COMMANDE("pub.pdf", "Publier le document en PDF", "Publication", "Cmd+P", @PUBLIER_PDF_COURANT)
  COMMANDE("pub.web", "Publier le site web", "Publication", "", @PUBLIER_WEB)
  COMMANDE("pub.lecteur", "Ouvrir le lecteur web intégré", "Publication", "", @OUVRIR_LECTEUR)
  COMMANDE("ia.ouvrir", "Assistant", "Assistant", "Cmd+J", @IA_OUVRIR)
  COMMANDE("ia.doublons", "Détecter les doublons", "Assistant", "", @IA_DOUBLONS)
  COMMANDE("ia.coherence", "Vérifier la cohérence du projet", "Assistant", "", @IA_COHERENCE)
  COMMANDE("app.theme", "Thème clair / sombre", "Affichage", "", @THEME_BASCULER)
  COMMANDE("app.projet", "Ouvrir un projet…", "Projet", "", @CMD_OUVRIR_PROJET)
  COMMANDE("app.extensions", "Recharger les extensions", "Projet", "", @CMD_EXTENSIONS)
  pour chaque e dans ESPACES()
    COMMANDE("espace." + e.id, "Espace : " + e.libelle, "Affichage", e.raccourci, e.proc)
  suivant
retourner

procedure CMD_REINDEXER(ev)
  REINDEXER()
  RAFRAICHIR_BIBLIOTHEQUE()
  STATUT("Index reconstruit : " + PLURIEL(nbelements(COMPOSANTS), "composant") + ".")
retourner

procedure CMD_IMPACT(ev)
  si SEL <> nul et SEL.genre = "composant"
    OUVRIR_ESPACE("graphe")
    GRAPHE_IMPACT(SEL.id)
  finsi
retourner

procedure CMD_VARIANTE(ev)
  si SEL <> nul et SEL.genre = "composant"
    CREER_VARIANTE_DIALOGUE(SEL.id, nul)
  finsi
retourner

procedure CMD_BRANCHE(ev)
  si SEL <> nul et SEL.genre = "composant"
    CREER_BRANCHE(SEL.id, nul)
  finsi
retourner

procedure CMD_OUVRIR_PROJET(ev)
  locale d = ui.demander("Dossier du projet à ouvrir (créé s'il n'existe pas) :", PROJ.dossier)
  si d = nul ou rogner(d) = ""
    retourner
  finsi
  DOC_ENREGISTRER_SI_MODIFIE()
  OUVRIR_PROJET(rogner(d))
  reglages.projet = PROJ.dossier
  ECRIRE_REGLAGES()
  RAFRAICHIR_BIBLIOTHEQUE()
  RAFRAICHIR_PROJET()
  STATUT("Projet ouvert : " + PROJ.dossier)
retourner

&&
&& Menus
&&

fonction MENUS()
retourner { ;
  {"Fichier", {"Nouveau document…", "Nouveau composant…", "Nouvelle illustration SVG…", "Nouvelle présentation…", "Nouveau storyboard…", "-", ;
               "Ouvrir un projet…", "Enregistrer", "-", "Importer une image ou un PDF…", "Importer une planche de symboles SVG…", "Vectoriser une image…", "-", "Quitter"}}, ;
  {"Édition", {"Palette de commandes…", "Rechercher partout", "-", "Insérer un composant…", "Insérer une variable ou une macro…", ;
               "Faire de la sélection un composant"}}, ;
  {"Composants", {"Analyse d'impact de la sélection", "Créer une variante de la sélection…", "Créer une branche de la sélection…", ;
                  "Reconstruire l'index", "Détecter les doublons", "Vérifier la cohérence du projet"}}, ;
  {"Présentation", {"Nouvelle diapositive…", "Lancer la présentation (conférence)", "Mode répétition (chronomètre)", "Téléprompteur"}}, ;
  {"Publier", {"Publier le document en PDF", "Publier le site web", "Ouvrir le lecteur web intégré"}}, ;
  {"Affichage", {"Espace : Document", "Espace : Dessin", "Espace : Présentation", "Espace : Storyboard", "Espace : Graphe", "Espace : Publier", "-", ;
                 "Mode source", "Mode mixte", "Mode aperçu", "-", "Thème clair / sombre"}}, ;
  {"Aide", {"Guide de démarrage", "Raccourcis clavier", "Syntaxe de composition", "Extensions", "À propos de Kaléido"}}}

procedure CONSTRUIRE_MENUS(m)
  pour chaque groupe dans MENUS()
    pour chaque e dans groupe[2]
      m:ajouter(groupe[1], e)
    suivant
  suivant
retourner

procedure MENU(ev)
  locale choix = ev.texte
  si ev.chemin <> nul
    choix = ev.chemin[#ev.chemin]
  finsi
  faire cas
  cas choix = "Quitter"
    FERMETURE(nul)
    ui.quitter()
    retourner
  cas choix = "Palette de commandes…"
    PALETTE(nul)
    retourner
  cas choix = "Rechercher partout"
    recherche:focus()
    retourner
  cas choix = "Guide de démarrage" ou choix = "Raccourcis clavier" ou choix = "Syntaxe de composition" ou choix = "Extensions" ou choix = "À propos de Kaléido"
    AIDE(choix)
    retourner
  fincas
  pour chaque c dans COMMANDES
    si c.libelle = choix
      appeler(c.proc, nul)
      retourner
    finsi
  suivant
retourner

procedure AIDE(sujet)
  locale n = car(10)
  locale md = ""
  faire cas
  cas sujet = "Raccourcis clavier"
    md = "## Raccourcis" + n + n + "| Touche | Action |" + n + "|:--|:--|" + n + ;
         "| Cmd+K | Palette de commandes |" + n + "| Cmd+1 … 6 | Espaces : document, dessin, présentation, storyboard, graphe, publier |" + n + ;
         "| Cmd+S | Enregistrer |" + n + "| Cmd+P | PDF du document |" + n + "| Cmd+J | Assistant |" + n + "| Cmd+F | Rechercher |" + n + ;
         "| Cmd+Maj+N | Nouveau composant |" + n + "| F5 | Lancer la présentation |" + n + "| F8 | Téléprompteur |" + n + ;
         "| V R E L A P T I H N | Outils de dessin (sélection, rectangle, ellipse, ligne, flèche, plume, texte, image, main, nœuds) |" + n + ;
         "| Cmd+G / Cmd+Maj+G | Grouper / dégrouper |" + n + "| Cmd+D | Dupliquer |" + n + "| Cmd+Z / Cmd+Maj+Z | Annuler / rétablir |" + n + ;
         "| Flèches (Maj) | Déplacer de 1 (10) |" + n + "| Espace + glisser | Déplacer la vue |" + n + "| Cmd+molette | Zoom |" + n
  cas sujet = "Syntaxe de composition"
    md = "## Composition" + n + n + "| Syntaxe | Effet |" + n + "|:--|:--|" + n + "| `{{> id}}` | composant |" + n + ;
         "| `{{> id@client}}` | variante |" + n + "| `{{> id#v3}}` | version figée |" + n + "| `{{variable}}` | variable |" + n + ;
         "| `{{toc}}` `{{index}}` | sommaire, index |" + n + "| `{{index:terme}}` | entrée d'index |" + n + "| `{{ref:ancre}}` | renvoi « p. 12 » |" + n + ;
         "| `{{saut}}` | saut de page |" + n + "| `> [!TIP] Titre` | encadré |" + n + "| `![a](f.svg \"légende\"){largeur=60%}` | figure |" + n
  cas sujet = "Extensions"
    md = "## Extensions" + n + n + "Placez un fichier `.prg` dans `plugins/` du projet. Il définit `EXTENSION_<NOM>()` qui appelle " + ;
         "`KALEIDO_ENREGISTRER{genre = \"commande\" | \"macro\" | \"exportateur\" | \"verification\", nom =, libelle =, procedure = @P}`." + n + n + ;
         "Extensions chargées : " + sisinon(#EXTENSIONS = 0, "aucune", joindre(EXTENSIONS, ", ")) + "."
  cas sujet = "À propos de Kaléido"
    md = "## ◆ Kaléido 2026" + n + n + "Conception de contenus visuels et documentaires, écrit en **Lexis+**." + n + n + ;
         "Documents, illustrations SVG, présentations et storyboards assemblés à partir de composants réutilisables, " + ;
         "avec traçabilité complète des dépendances."

    ui.alerte("◆ Kaléido 2026 v1.8.6\nConception de contenus visuels et documentaires\n" +
              "avec traçabilité complète des dépendances.\n\n" +
              "CC BY-NC-SA 4.0 - Jean-Marc QUÉRÉ\n" +
              "⛶ https://sonaliwan.fr  ✉ metalab (at) sonaliwan.fr\n" +
              "SIRET 13033319800013"
              , "information", "À propos")

  autrement
    md = "## Prendre Kaléido en main" + n + n + "1. **Bibliothèque** (à gauche) : vos composants réutilisables (textes, logos, schémas, diapositives, scènes)." + n + ;
         "2. **Document** : écrivez en Markdown ; `{{> id}}` insère un composant ; l'aperçu à droite est le document publié." + n + ;
         "3. **Dessin** : créez ou retouchez des SVG ; importez et vectorisez des images." + n + ;
         "4. **Présentation** et **Storyboard** : assemblez des diapositives et des scènes à partir des mêmes composants." + n + ;
         "5. **Graphe** : qui utilise quoi ; avant chaque modification, Kaléido annonce l'impact et propose propager, ignorer, variante ou branche." + n + ;
         "6. **Publier** : PDF professionnels et site web autonome avec lecteur intégré." + n + n + "**Cmd+K** ouvre la palette : toutes les commandes au clavier."
  fincas
  fiche.valeur = md
  droite.valeur = 1
retourner

&&
&& Choix rapide (palette, insertion de composant, variables, modèles…)
&&

procedure QUICKPICK(titre, items, proc)
  globale fenpalette, qp_saisie, qp_liste, QP
  si fenpalette <> nul
    essayer
      fenpalette:fermer()
    capturer e
    finessayer
  finsi
  QP = {items = items, proc = proc, visibles = {}}
  fenpalette = ui.fenetre{titre = titre, largeur = 640, hauteur = 460, disposition = "bordure", sombre = reglages.sombre, densite = "compacte"}
  fenpalette.surtouchebas = @QP_TOUCHE
  fenpalette.surfermeture = @QP_FERMEE
  qp_saisie = fenpalette:ajouter(ui.saisie{indication = "Tapez pour filtrer — Entrée pour valider, Échap pour fermer"})
  qp_saisie.ancrage = "haut"
  qp_saisie.surchangement = @QP_FILTRER
  qp_saisie.surtouchebas = @QP_TOUCHE
  qp_liste = fenpalette:ajouter(ui.liste())
  qp_liste.ancrage = "centre"
  qp_liste.surdoubleclic = @QP_VALIDER
  qp_liste.surtouchebas = @QP_TOUCHE
  QP_FILTRER(nul)
  qp_saisie:focus()
retourner

procedure QP_FERMEE(ev)
  globale fenpalette
  fenpalette = nul
retourner

procedure QP_FILTRER(ev)
  locale q = minuscule(rogner(qp_saisie.valeur))
  qp_liste:vider()
  QP.visibles = {}
  locale mots = decouper(q, " ")
  pour chaque it dans QP.items
    locale h = minuscule(it.libelle + " " + sisinon(it.detail = nul, "", it.detail))
    locale ok = vrai
    pour chaque m dans mots
      si m <> "" et non contient(h, m)
        ok = faux
      finsi
    suivant
    si ok
      qp_liste:ajouter(it.libelle + sisinon(it.detail = nul ou it.detail = "", "", "      " + it.detail))
      inserer(QP.visibles, it)
      si #QP.visibles >= 400
        sortir
      finsi
    finsi
  suivant
  si #QP.visibles > 0
    qp_liste:selectionner(1)
  finsi
retourner

procedure QP_TOUCHE(ev)
  faire cas
  cas ev.touche = 27
    fenpalette:fermer()
  cas ev.touche = 13 ou ev.touche = 1073741912
    QP_VALIDER(nul)
  cas ev.touche = 1073741905                && bas
    locale i = nombre(qp_liste:selection())
    si i < #QP.visibles
      qp_liste:selectionner(i + 1)
    finsi
    ev:arreter()
  cas ev.touche = 1073741906                && haut
    locale i = nombre(qp_liste:selection())
    si i > 1
      qp_liste:selectionner(i - 1)
    finsi
    ev:arreter()
  fincas
retourner

procedure QP_VALIDER(ev)
  globale fenpalette
  locale i = nombre(qp_liste:selection())
  si i = nul ou i < 1 ou i > #QP.visibles
    retourner
  finsi
  locale it = QP.visibles[i]
  locale proc = QP.proc
  locale f = fenpalette
  fenpalette = nul
  f:fermer()
  appeler(proc, it.valeur)
retourner

&& palette universelle : commandes, composants, documents, titres, présentations, storyboards
procedure PALETTE(ev)
  locale items = {}
  pour chaque c dans COMMANDES
    inserer(items, {libelle = "› " + c.libelle, detail = c.categorie + sisinon(c.raccourci <> "", " · " + c.raccourci, ""), valeur = "cmd:" + c.id})
  suivant
  pour chaque id, c dans COMPOSANTS
    inserer(items, {libelle = ICONE_GENRE(c.genre) + " " + c.titre, detail = "composant · " + c.id, valeur = "comp:" + c.id})
  suivant
  pour chaque d dans DOCS
    inserer(items, {libelle = "▤ " + d.titre, detail = "document", valeur = "doc:" + d.nom})
    pour chaque t dans pub.titres(LIRE_TEXTE(d.chemin))
      si t.niveau <= 2
        inserer(items, {libelle = "   # " + t.texte, detail = "titre dans « " + d.titre + " »", valeur = "titre:" + d.nom + ":" + t.texte})
      finsi
    suivant
  suivant
  pour chaque d dans PRES
    inserer(items, {libelle = "▭ " + d.titre, detail = "présentation", valeur = "pres:" + d.nom})
  suivant
  pour chaque d dans SB
    inserer(items, {libelle = "◫ " + d.titre, detail = "storyboard", valeur = "sb:" + d.nom})
  suivant
  QUICKPICK("Palette — commandes et contenus (Cmd+K)", items, @PALETTE_CHOIX)
retourner

procedure PALETTE_CHOIX(v)
  faire cas
  cas commencepar(v, "cmd:")
    pour chaque c dans COMMANDES
      si "cmd:" + c.id = v
        appeler(c.proc, nul)
      finsi
    suivant
  cas commencepar(v, "comp:")
    OUVRIR_COMPOSANT(souschaine(v, 6))
  cas commencepar(v, "doc:")
    OUVRIR_ESPACE("document")
    OUVRIR_DOCUMENT(souschaine(v, 5))
  cas commencepar(v, "titre:")
    locale reste = souschaine(v, 7)
    locale k = position(":", reste)
    OUVRIR_ESPACE("document")
    OUVRIR_DOCUMENT(gauche(reste, k - 1))
    ed:aller(1, 1)
    ed:chercher(souschaine(reste, k + 1))
  cas commencepar(v, "pres:")
    OUVRIR_ESPACE("presentation")
    PRES_OUVRIR(souschaine(v, 6))
  cas commencepar(v, "sb:")
    OUVRIR_ESPACE("storyboard")
    SB_OUVRIR(souschaine(v, 4))
  fincas
retourner

&& recherche universelle (barre du haut) : filtre la bibliothèque, Entrée ouvre la palette
procedure RECHERCHE_UNIVERSELLE(ev)
  filtre_bib.valeur = recherche.valeur
  gauche.valeur = 1
  BIB_FILTRER(nul)
retourner

procedure RECHERCHE_TOUCHE(ev)
  si MODS(ev).cmd
    TOUCHE(ev)
    retourner
  finsi
  si ev.touche = 13
    locale q = recherche.valeur
    PALETTE(nul)
    qp_saisie.valeur = q
    QP_FILTRER(nul)
  finsi
retourner

&&
&& Saisie de texte sur plusieurs lignes (contenu d'une diapositive, personnages…)
&&

procedure EDITER_TEXTE(titre, aide, texte_, rappel)
  globale fentexte, et_saisie, ET_RAPPEL
  ET_RAPPEL = rappel
  si fentexte <> nul
    essayer
      fentexte:fermer()
    capturer e
    finessayer
  finsi
  fentexte = ui.fenetre{titre = titre, largeur = 640, hauteur = 420, disposition = "bordure", sombre = reglages.sombre, densite = "compacte"}
  fentexte.surfermeture = @ET_FERMEE
  locale a = fentexte:ajouter(ui.etiquette(aide))
  a.ancrage = "haut"
  a.couleur = "#94A3B8"
  et_saisie = fentexte:ajouter(ui.saisie{multiligne = vrai})
  et_saisie.ancrage = "centre"
  et_saisie.valeur = texte_
  locale b = fentexte:ajouter(ui.rangee())
  b.ancrage = "bas"
  b.marge = 8
  b.espacement = 6
  locale e = b:ajouter(ui.etiquette(""))
  e.poids = 1
  locale ok = b:ajouter(ui.bouton("Valider"))
  ok.surclic = @ET_VALIDER
  locale an = b:ajouter(ui.bouton("Annuler"))
  an.surclic = @ET_ANNULER
  et_saisie:focus()
retourner

procedure ET_VALIDER(ev)
  locale v = et_saisie.valeur
  locale r = ET_RAPPEL
  fentexte:fermer()
  appeler(r, v)
retourner

procedure ET_ANNULER(ev)
  fentexte:fermer()
retourner

procedure ET_FERMEE(ev)
  globale fentexte
  fentexte = nul
retourner

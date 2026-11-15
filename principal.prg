&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : conception de contenus visuels et documentaires, écrit en Lexis+.
&&
&&   wdlexisrt principal.prg [dossier_du_projet]
&&
&& Fichiers (le runtime les charge tous) :
&&   principal.prg     fenêtre, espaces de travail, barre de commandes, inspecteur, raccourcis
&&   outils.prg        JSON, textes, requêtes, journal
&&   projet.prg        projet (dossier), composants, livrables, index DuckDB, historique
&&   composition.prg   moteur de composition (composants, variantes, variables, macros)
&&   bibliotheque.prg  bibliothèque de composants (arbre, recherche instantanée, fiche)
&&   texte.prg         éditeur Markdown enrichi, aperçu paginé en direct, extraits, modèles
&&   dessin.prg        éditeur SVG (outils, calques, styles, alignements, booléens, symboles)
&&   vectorisation.prg importation et vectorisation d'images
&&   presentation.prg  présentations (diapositives, modèles, conférence, répétition, téléprompteur)
&&   storyboard.prg    storyboards (plateau, timeline, scènes, personnages, annotations)
&&   graphe.prg        graphe de dépendances, impact, propagation
&&   variantes.prg     variantes, versions, branches
&&   publication.prg   PDF, site web autonome, exports
&&   ia.prg            intelligence assistée (modèle local ou règles)
&&   extensions.prg    système d'extensions (plugins/*.prg)
&&   commandes.prg     registre des commandes, palette (Cmd+K), menus, raccourcis
&&   demo.prg          projet de démonstration
ui = paquet("interface")
pub = paquet("publication")

reglages = LIRE_REGLAGES()
MACROS = {}
COMMANDES = {}
EXTENSIONS = {}
ESPACE = "document"
SEL = nul                 && sélection courante : {genre, id}
PROJ = nul

depart = systeme.args[1]
si depart = nul ou depart = ""
  depart = reglages.projet
finsi
si depart = nul ou depart = ""
  depart = fichier.joindre(fichier.dossierperso(), "Kaleido", "Demonstration")
finsi
nouveau_projet = non fichier.existe(fichier.joindre(depart, "kaleido.json"))
OUVRIR_PROJET(depart)
si nouveau_projet et fichier.nom(depart) = "Demonstration"
  CREER_DEMO()
finsi
reglages.projet = PROJ.dossier
ECRIRE_REGLAGES()

essayer
  ui.icone(fichier.joindre(systeme.dossierprogramme(), "kaleido.png"))
capturer e
finessayer
fen = ui.fenetre{titre = "Kaléido — " + PROJ.titre, largeur = 1600, hauteur = 1000, disposition = "bordure", ;
                 sombre = reglages.sombre, etat = "agrandie", densite = "compacte"}
fen.marge = 0
fen.espacement = 0
fen.surfermeture = @FERMETURE
fen.surtouchebas = @TOUCHE

menu = fen:ajouter(ui.barremenu())
CONSTRUIRE_MENUS(menu)
menu.surselection = @MENU

&& en-tête : espaces de travail · recherche universelle · palette · assistant
tete = fen:ajouter(ui.rangee())
tete.ancrage = "haut"
tete.marge = 4
tete.espacement = 2
marque = tete:ajouter(ui.etiquette("◆ Kaléido"))
marque.couleur = "#A5B4FC"
marque.largeurfixe = 96
BOUTONS_ESPACES = {}
pour chaque e dans ESPACES()
  locale b = tete:ajouter(ui.bouton(e.libelle, {plat = vrai}))
  b.infobulle = e.aide + " (" + e.raccourci + ")"
  b.surclic = e.proc
  BOUTONS_ESPACES[e.id] = b
suivant
ressort = tete:ajouter(ui.etiquette(""))
ressort.poids = 1
recherche = tete:ajouter(ui.saisie{indication = "Rechercher partout…  (Cmd+K : commandes)"})
recherche.largeurfixe = 300
recherche.surchangement = @RECHERCHE_UNIVERSELLE
recherche.surtouchebas = @RECHERCHE_TOUCHE
ICONE(tete, "k-command", "Palette de commandes", "Toutes les actions au clavier (Cmd+K)", @PALETTE)
ICONE(tete, "k-ai", "Assistant", "Intelligence assistée : générer, reformuler, traduire, résumer, illustrer (Cmd+J)", @IA_OUVRIR)
ICONE(tete, sisinon(reglages.sombre, "k-sun", "k-moon"), "Thème", "Thème clair / sombre", @THEME_BASCULER)

&& ruban contextuel : un par espace (et par sélection), un seul visible
zone_rubans = fen:ajouter(ui.colonne())
zone_rubans.ancrage = "haut"
zone_rubans.marge = 0
zone_rubans.espacement = 0
RUBANS = {}

&& barre d'état
pied = fen:ajouter(ui.rangee())
pied.ancrage = "bas"
pied.marge = 2
pied.espacement = 14
pied.hauteurfixe = 22
pied.fond = "#0B1020"
etat = pied:ajouter(ui.etiquette("Prêt"))
etat.poids = 1
etat.couleur = "#94A3B8"
lblimpact = pied:ajouter(ui.etiquette(""))
lblimpact.couleur = "#FBBF24"
lblinfo = pied:ajouter(ui.etiquette(""))
lblinfo.couleur = "#94A3B8"
lblprojet = pied:ajouter(ui.etiquette(""))
lblprojet.couleur = "#64748B"

&& bibliothèque | espace central | inspecteur
sepg = fen:ajouter(ui.separateur{vertical = vrai, position = reglages.sep_gauche})
sepg.ancrage = "centre"
gauche = sepg:ajouter(ui.onglets())
sepd = sepg:ajouter(ui.separateur{vertical = vrai, position = reglages.sep_droite})
centre = sepd:ajouter(ui.onglets())
centre.surchangement = @CENTRE_CHANGE
droite = sepd:ajouter(ui.onglets())

CONSTRUIRE_BIBLIOTHEQUE(gauche)
CONSTRUIRE_INSPECTEUR(droite)
PAGES = {}
PAGES.document = centre:ajouterpage("Document", "bordure")
PAGES.dessin = centre:ajouterpage("Dessin", "bordure")
PAGES.presentation = centre:ajouterpage("Présentation", "bordure")
PAGES.storyboard = centre:ajouterpage("Storyboard", "bordure")
PAGES.graphe = centre:ajouterpage("Graphe", "bordure")
PAGES.publication = centre:ajouterpage("Publication", "bordure")
CONSTRUIRE_DOCUMENT(PAGES.document)
CONSTRUIRE_DESSIN(PAGES.dessin)
CONSTRUIRE_PRESENTATION(PAGES.presentation)
CONSTRUIRE_STORYBOARD(PAGES.storyboard)
CONSTRUIRE_GRAPHE(PAGES.graphe)
CONSTRUIRE_PUBLICATION(PAGES.publication)
CONSTRUIRE_RUBANS()
ENREGISTRER_COMMANDES()
CHARGER_EXTENSIONS()

RAFRAICHIR_BIBLIOTHEQUE()
RAFRAICHIR_PROJET()
OUVRIR_ESPACE(sisinon(reglages.espace = nul, "document", reglages.espace))
si DOC("guide-utilisateur") <> nul
  OUVRIR_DOCUMENT("guide-utilisateur")
sinonsi #DOCS > 0
  OUVRIR_DOCUMENT(DOCS[1].nom)
finsi
ui.minuterie(350, @HORLOGE, vrai)
STATUT("Projet « " + PROJ.titre + " » : " + PLURIEL(nbelements(COMPOSANTS), "composant") + ", " + PLURIEL(#DOCS, "document") + ", " + ;
       PLURIEL(#PRES, "présentation") + ", " + PLURIEL(#SB, "storyboard") + ".")
ui.executer()

&&
&& Espaces de travail
&&

fonction ESPACES()
retourner { ;
  {id = "document", libelle = "Document", aide = "Éditeur Markdown enrichi et aperçu paginé", raccourci = "Cmd+1", proc = @ESP_DOCUMENT}, ;
  {id = "dessin", libelle = "Dessin", aide = "Éditeur SVG : formes, calques, Bézier, symboles", raccourci = "Cmd+2", proc = @ESP_DESSIN}, ;
  {id = "presentation", libelle = "Présentation", aide = "Diapositives, sections, conférence, téléprompteur", raccourci = "Cmd+3", proc = @ESP_PRESENTATION}, ;
  {id = "storyboard", libelle = "Storyboard", aide = "Scènes, séquences, timeline, personnages", raccourci = "Cmd+4", proc = @ESP_STORYBOARD}, ;
  {id = "graphe", libelle = "Graphe", aide = "Dépendances, impact, variantes", raccourci = "Cmd+5", proc = @ESP_GRAPHE}, ;
  {id = "publication", libelle = "Publier", aide = "PDF, site web autonome, exports", raccourci = "Cmd+6", proc = @ESP_PUBLICATION}}

procedure ESP_DOCUMENT(ev)
  OUVRIR_ESPACE("document")
retourner
procedure ESP_DESSIN(ev)
  OUVRIR_ESPACE("dessin")
retourner
procedure ESP_PRESENTATION(ev)
  OUVRIR_ESPACE("presentation")
retourner
procedure ESP_STORYBOARD(ev)
  OUVRIR_ESPACE("storyboard")
retourner
procedure ESP_GRAPHE(ev)
  OUVRIR_ESPACE("graphe")
retourner
procedure ESP_PUBLICATION(ev)
  OUVRIR_ESPACE("publication")
retourner

fonction INDEX_ESPACE(id)
  locale i = 1
  pour chaque e dans ESPACES()
    si e.id = id
      retourner i
    finsi
    i += 1
  suivant
retourner 1

procedure OUVRIR_ESPACE(id)
  globale ESPACE, toile
  ESPACE = id
  && la toile active des commandes de dessin suit l'espace
  si id = "dessin"
    toile = toile_dessin
    DESSIN_ETAT("dessin")
  sinonsi id = "presentation"
    toile = toile_pres
    DESSIN_ETAT("presentation")
  finsi
  reglages.espace = id
  si nombre(centre.valeur) <> INDEX_ESPACE(id)
    centre.valeur = INDEX_ESPACE(id)
  finsi
  pour chaque e dans ESPACES()
    locale b = BOUTONS_ESPACES[e.id]
    si e.id = id
      b.couleur = "#A5B4FC"
      b.libelle = "● " + e.libelle
    sinon
      b.couleur = "#94A3B8"
      b.libelle = e.libelle
    finsi
  suivant
  RUBAN_CONTEXTUEL()
  faire cas
  cas id = "graphe"
    GRAPHE_RAFRAICHIR()
  cas id = "publication"
    PUBLICATION_RAFRAICHIR()
  cas id = "storyboard"
    SB_ACTIVER()
  cas id = "presentation"
    PRES_ACTIVER()
  fincas
retourner

procedure CENTRE_CHANGE(ev)
  locale i = nombre(centre.valeur)
  locale e = ESPACES()[i]
  si e <> nul et e.id <> ESPACE
    OUVRIR_ESPACE(e.id)
  finsi
retourner

&&
&& Ruban contextuel : les outils varient selon l'espace et la sélection
&&

fonction RUBAN(nom)
  locale r = zone_rubans:ajouter(ui.rangee())
  r.marge = 3
  r.espacement = 1
  r.visible = faux
  r.fond = "#111827"
  RUBANS[nom] = r
retourner r

procedure RUBAN_CONTEXTUEL
  && un ruban par espace ; la présentation ajoute celui du dessin ; un texte choisi
  && remplace les outils de dessin par ceux du texte
  locale montrer = {ESPACE}
  si ESPACE = "presentation"
    inserer(montrer, "dessin")
  finsi
  si (ESPACE = "dessin" ou ESPACE = "presentation") et DESSIN_SEL_TEXTE()
    montrer[#montrer] = "dessin_texte"
  finsi
  pour chaque k, r dans RUBANS
    r.visible = LISTE_CONTIENT(montrer, k)
  suivant
retourner

procedure CONSTRUIRE_RUBANS
  RUBAN_DOCUMENT(RUBAN("document"))
  RUBAN_PRESENTATION(RUBAN("presentation"))
  RUBAN_DESSIN(RUBAN("dessin"))
  RUBAN_DESSIN_TEXTE(RUBAN("dessin_texte"))
  RUBAN_STORYBOARD(RUBAN("storyboard"))
  RUBAN_GRAPHE(RUBAN("graphe"))
  RUBAN_PUBLICATION(RUBAN("publication"))
retourner

&&
&& Inspecteur (à droite) : propriétés, dépendances, variantes, assistant
&&

procedure CONSTRUIRE_INSPECTEUR(o)
  globale fiche, pdeps, pvars, pia
  locale pp = o:ajouterpage("Propriétés", "bordure")
  CONSTRUIRE_PROPRIETES(pp)
  pdeps = o:ajouterpage("Liens", "bordure")
  CONSTRUIRE_DEPENDANCES(pdeps)
  pvars = o:ajouterpage("Versions", "bordure")
  CONSTRUIRE_VARIANTES(pvars)
  pia = o:ajouterpage("Assistant", "bordure")
  CONSTRUIRE_IA(pia)
retourner

&&
&& Outils communs de l'interface
&&

fonction ICONE(conteneur, icone, libelle, aide, proc)
  locale b = conteneur:ajouter(ui.bouton(libelle, {icone = icone, bulle = aide}))
  b.surclic = proc
  b.largeurfixe = 30
retourner b

fonction OUTIL(conteneur, libelle, proc, aide)
  locale b = conteneur:ajouter(ui.bouton(libelle, {plat = vrai}))
  b.surclic = proc
  si aide <> nul
    b.infobulle = aide
  finsi
retourner b

procedure FILET(barre)
  locale e = barre:ajouter(ui.etiquette(""))
  e.largeurfixe = 9
retourner

fonction LIBELLE(barre, t, largeur)
  locale e = barre:ajouter(ui.etiquette(t))
  e.couleur = "#94A3B8"
  si largeur <> nul
    e.largeurfixe = largeur
  finsi
retourner e

procedure STATUT(m)
  essayer
    etat.libelle = m
  capturer e
  finessayer
retourner

procedure RAFRAICHIR_PROJET
  lblprojet.libelle = PROJ.dossier
  fen.titre = "Kaléido — " + PROJ.titre
retourner

procedure HORLOGE(ev)
  && minuterie : aperçu différé, autosauvegarde, mode présentation
  APERCU_DIFFERE()
  DESSIN_AUTOSAUVEGARDE()
  PRES_HORLOGE()
retourner

procedure THEME_BASCULER(ev)
  reglages.sombre = non reglages.sombre
  fen:fixertheme("natif", reglages.sombre, "compacte")
  ECRIRE_REGLAGES()
retourner

procedure FERMETURE(ev)
  essayer
    reglages.sep_gauche = nombre(sepg.valeur)
    reglages.sep_droite = nombre(sepd.valeur)
  capturer e
  finessayer
  DOC_ENREGISTRER_SI_MODIFIE()
  DESSIN_ENREGISTRER_SI_MODIFIE()
  ECRIRE_REGLAGES()
  FERMER_FENETRES_SECONDAIRES()
retourner

fonction FICHIER_REGLAGES()
retourner fichier.joindre(fichier.dossierperso(), ".kaleido_reglages.json")

fonction LIRE_REGLAGES()
  locale r = {sombre = vrai, sep_gauche = 0.17, sep_droite = 0.77, espace = "document", projet = "", mode_doc = "mixte", ;
              modele_ia = "", serveur_ia = "", recents = {}}
  locale p = FICHIER_REGLAGES()
  si fichier.existe(p)
    essayer
      pour chaque k, v dans dejson(fichier.lire(p))
        r[majuscule(k)] = v
      suivant
    capturer e
    finessayer
  finsi
retourner r

procedure ECRIRE_REGLAGES
  essayer
    fichier.ecrire(FICHIER_REGLAGES(), JSONK(reglages, ""))
  capturer e
  finessayer
retourner

&& modificateurs : {cmd, maj, alt} (Cmd sur macOS, Ctrl ailleurs)
fonction MODS(ev)
  locale m = sisinon(ev.modificateurs = nul, 0, ev.modificateurs)
  locale ctrl = (m % 256) >= 64
  locale gui = (m % 2048) >= 1024
  locale maj = (m % 4) >= 1
  locale alt = (m % 1024) >= 256
retourner {cmd = ctrl ou gui, maj = maj, alt = alt}

procedure TOUCHE(ev)
  locale m = MODS(ev)
  locale t = ev.touche
  si m.cmd
    faire cas
    cas t = 107                          && Cmd+K : palette
      PALETTE(nul)
    cas t = 106                          && Cmd+J : assistant
      IA_OUVRIR(nul)
    cas t >= 49 et t <= 54               && Cmd+1..6 : espaces
      OUVRIR_ESPACE(ESPACES()[t - 48].id)
    cas t = 115                          && Cmd+S
      ENREGISTRER_TOUT(nul)
    cas t = 112                          && Cmd+P : publier en PDF
      PUBLIER_PDF_COURANT(nul)
    cas t = 102                          && Cmd+F : recherche
      recherche:focus()
    cas t = 110 et m.maj                 && Cmd+Maj+N : nouveau composant
      NOUVEAU_COMPOSANT(nul)
    fincas
    retourner
  finsi
  faire cas
  cas t = 1073741886                     && F5 : lancer la présentation
    PRES_LANCER(nul)
  cas t = 1073741889                     && F8 : téléprompteur
    PRES_TELEPROMPTEUR(nul)
  fincas
retourner

procedure ENREGISTRER_TOUT(ev)
  DOC_ENREGISTRER(nul)
  DESSIN_ENREGISTRER(nul)
  si fenimpact = nul
    STATUT("Tout est enregistré (" + heure() + ").")
  finsi
retourner

procedure FERMER_FENETRES_SECONDAIRES
  pour chaque w dans {fenpalette, fenimpact, fenia, fenconf, fenprompt, fenvect, fenpresentateur}
    si w <> nul
      essayer
        w:fermer()
      capturer e
      finessayer
    finsi
  suivant
retourner

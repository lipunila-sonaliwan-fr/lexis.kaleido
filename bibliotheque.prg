&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : bibliothèque de composants (à gauche) et explorateur du projet.
&&
&& Arborescence : dossiers et sous-dossiers (champ « dossier » : « Marketing/Logos »),
&& collections, catégories, étiquettes, mots-clés, métadonnées. Recherche instantanée
&& (index DuckDB) ; filtre par genre ; double-clic : ouvrir dans l'éditeur adapté ;
&& glisser du sens : insérer dans le document, la diapositive ou la scène courante.

procedure CONSTRUIRE_BIBLIOTHEQUE(o)
  globale arbre_bib, filtre_bib, genre_bib, lprojet, NOEUDS_BIB, NOEUDS_PROJ
  locale pb = o:ajouterpage("Bibliothèque", "bordure")
  locale haut = pb:ajouter(ui.colonne())
  haut.ancrage = "haut"
  haut.marge = 4
  haut.espacement = 3
  filtre_bib = haut:ajouter(ui.saisie{indication = "Filtrer les composants…"})
  filtre_bib.surchangement = @BIB_FILTRER
  locale r = haut:ajouter(ui.rangee())
  r.espacement = 2
  genre_bib = r:ajouter(ui.combo())
  pour chaque g dans GENRES_BIB()
    genre_bib:ajouter(g)
  suivant
  genre_bib:selectionner(1)
  genre_bib.poids = 1
  genre_bib.surselection = @BIB_FILTRER
  ICONE(r, "plus", "Nouveau composant", "Créer un composant (Cmd+Maj+N)", @NOUVEAU_COMPOSANT)
  ICONE(r, "k-component", "Insérer", "Insérer le composant choisi dans l'éditeur courant", @BIB_INSERER)
  arbre_bib = pb:ajouter(ui.arbre())
  arbre_bib.ancrage = "centre"
  arbre_bib.surselection = @BIB_CHOIX
  arbre_bib.surdoubleclic = @BIB_OUVRIR
  arbre_bib.surclicdroit = @BIB_MENU
  arbre_bib.surchangement = @BIB_MENU_CHOIX
  locale pp = o:ajouterpage("Projet", "bordure")
  lprojet = pp:ajouter(ui.arbre())
  lprojet.ancrage = "centre"
  lprojet.surselection = @PROJET_CHOIX
  lprojet.surdoubleclic = @PROJET_CHOIX
  NOEUDS_BIB = {}
  NOEUDS_PROJ = {}
retourner

fonction GENRES_BIB()
retourner {"Tous les genres", "texte", "chapitre", "liste", "tableau", "illustration", "logo", "image", "schema", "graphique", "diapositive", "scene"}

fonction ICONE_GENRE(g)
  faire cas
  cas g = "texte" ou g = "paragraphe"
    retourner "¶"
  cas g = "chapitre" ou g = "section" ou g = "page"
    retourner "§"
  cas g = "liste"
    retourner "☰"
  cas g = "tableau"
    retourner "▦"
  cas g = "logo"
    retourner "◈"
  cas g = "image" ou g = "photo"
    retourner "▣"
  cas g = "schema" ou g = "graphique"
    retourner "◇"
  cas g = "diapositive"
    retourner "▭"
  cas g = "scene"
    retourner "◫"
  fincas
retourner "◆"

procedure RAFRAICHIR_BIBLIOTHEQUE
  BIB_FILTRER(nul)
  PROJET_ARBRE()
retourner

procedure BIB_FILTRER(ev)
  globale NOEUDS_BIB
  arbre_bib:vider()
  NOEUDS_BIB = {}
  locale q = rogner(filtre_bib.valeur)
  locale g = COMBO_VAL(genre_bib, GENRES_BIB())
  si g = "Tous les genres"
    g = ""
  finsi
  locale sp = ui.sep
  locale lignes = {}
  si q = "" et g = ""
    pour chaque id, c dans COMPOSANTS
      inserer(lignes, {id = c.id, titre = c.titre, genre = c.genre, dossier = sisinon(c.dossier = nul, "", c.dossier)})
    suivant
    trier(lignes, @BIB_ORDRE)
  sinon
    lignes = CHERCHER_COMPOSANTS(q, g)
  finsi
  locale n = 0
  pour chaque l dans lignes
    locale chemin_ = ""
    si q = "" et l.dossier <> nul et l.dossier <> ""
      pour chaque partie dans decouper(l.dossier, "/")
        chemin_ = chemin_ + sisinon(chemin_ = "", "", sp) + rogner(partie)
      suivant
    finsi
    locale c = COMPOSANT(l.id)
    locale extra = ""
    si c <> nul et #c.variantes > 0
      extra = "  · " + PLURIEL(#c.variantes + 1, "variante")
    finsi
    locale lib = ICONE_GENRE(l.genre) + " " + l.titre + extra
    locale p = sisinon(chemin_ = "", lib, chemin_ + sp + lib)
    arbre_bib:ajouter(p)
    NOEUDS_BIB[p] = l.id
    n += 1
  suivant
  si q = ""
    pour chaque k, v dans NOEUDS_BIB
      locale parties = decouper(k, sp)
      si #parties > 1
        arbre_bib:deplier(parties[1])
      finsi
    suivant
  finsi
  si n = 0 et q <> ""
    arbre_bib:ajouter("Aucun composant ne correspond à « " + q + " »")
  finsi
retourner

fonction BIB_ORDRE(a, b)
  si a.dossier <> b.dossier
    retourner minuscule(a.dossier) < minuscule(b.dossier)
  finsi
retourner minuscule(a.titre) < minuscule(b.titre)

fonction BIB_ID(ev)
  locale p = ev.texte
  si ev.chemin <> nul
    p = joindre(ev.chemin, ui.sep)
  finsi
retourner NOEUDS_BIB[p]

procedure BIB_CHOIX(ev)
  locale id = BIB_ID(ev)
  si id <> nul
    SELECTIONNER("composant", id)
  finsi
retourner

procedure BIB_OUVRIR(ev)
  locale id = BIB_ID(ev)
  si id = nul et SEL <> nul et SEL.genre = "composant"
    id = SEL.id
  finsi
  si id <> nul
    OUVRIR_COMPOSANT(id)
  finsi
retourner

procedure BIB_MENU(ev)
  locale id = BIB_ID(ev)
  si id <> nul
    SELECTIONNER("composant", id)
  finsi
  arbre_bib:menucontextuel("Ouvrir", "Insérer dans l'éditeur courant", "-", "Renommer…", "Dupliquer", "Créer une variante…", ;
                           "Créer une branche…", "Analyse d'impact", "-", "Exporter…", "Supprimer")
retourner

procedure BIB_MENU_CHOIX(ev)
  si SEL = nul ou SEL.genre <> "composant"
    retourner
  finsi
  locale id = SEL.id
  locale c = COMPOSANT(id)
  faire cas
  cas ev.texte = "Ouvrir"
    OUVRIR_COMPOSANT(id)
  cas ev.texte = "Insérer dans l'éditeur courant"
    INSERER_COMPOSANT(id)
  cas ev.texte = "Renommer…"
    locale t = ui.demander("Nouveau titre du composant", c.titre)
    si t <> nul et rogner(t) <> ""
      c.titre = rogner(t)
      ENREGISTRER_COMPOSANT(c, nul, nul)
      RAFRAICHIR_BIBLIOTHEQUE()
    finsi
  cas ev.texte = "Dupliquer"
    DUPLIQUER_COMPOSANT(id, nul)
  cas ev.texte = "Créer une variante…"
    CREER_VARIANTE_DIALOGUE(id, nul)
  cas ev.texte = "Créer une branche…"
    CREER_BRANCHE(id, nul)
  cas ev.texte = "Analyse d'impact"
    OUVRIR_ESPACE("graphe")
    GRAPHE_IMPACT(id)
  cas ev.texte = "Exporter…"
    locale dest = ui.enregistrerfichier{nom = c.id + "." + c.ext}
    si dest <> nul
      fichier.copier(FICHIER_COMPOSANT(c, nul), dest)
      STATUT("Composant exporté : " + dest)
    finsi
  cas ev.texte = "Supprimer"
    locale imp = IMPACT(id)
    locale msg = "Supprimer le composant « " + c.titre + " » ?"
    si imp.total > 0
      msg = msg + car(10) + car(10) + IMPACT_PHRASE(imp) + car(10) + "Les références deviendront des erreurs signalées."
    finsi
    si ui.confirmer(msg, "attention")
      SUPPRIMER_COMPOSANT(id)
      RAFRAICHIR_BIBLIOTHEQUE()
      SELECTIONNER(nul, nul)
    finsi
  fincas
retourner

procedure BIB_INSERER(ev)
  si SEL <> nul et SEL.genre = "composant"
    INSERER_COMPOSANT(SEL.id)
  sinon
    STATUT("Choisissez d'abord un composant dans la bibliothèque.")
  finsi
retourner

&& insertion selon l'espace courant
procedure INSERER_COMPOSANT(id)
  locale c = COMPOSANT(id)
  si c = nul
    retourner
  finsi
  faire cas
  cas ESPACE = "document"
    DOC_INSERER("{{> " + c.id + "}}")
  cas ESPACE = "dessin"
    DESSIN_INSERER_COMPOSANT(c)
  cas ESPACE = "presentation"
    PRES_INSERER_COMPOSANT(c)
  cas ESPACE = "storyboard"
    SB_INSERER_COMPOSANT(c)
  autrement
    DOC_INSERER("{{> " + c.id + "}}")
  fincas
retourner

&& ouvre un composant dans l'éditeur adapté à son genre
procedure OUVRIR_COMPOSANT(id)
  locale c = COMPOSANT(id)
  si c = nul
    retourner
  finsi
  SELECTIONNER("composant", id)
  si GENRE_TEXTE(c.genre)
    OUVRIR_ESPACE("document")
    DOC_OUVRIR_COMPOSANT(c, nul)
  sinonsi c.ext = "svg"
    OUVRIR_ESPACE("dessin")
    DESSIN_OUVRIR_COMPOSANT(c, nul)
  sinon
    OUVRIR_ESPACE("dessin")
    DESSIN_OUVRIR_IMAGE(c)
  finsi
retourner

procedure NOUVEAU_COMPOSANT(ev)
  locale t = ui.demander("Titre du nouveau composant (texte) :", "Nouveau composant")
  si t = nul ou rogner(t) = ""
    retourner
  finsi
  locale genre = "texte"
  si ESPACE = "dessin" ou ESPACE = "presentation" ou ESPACE = "storyboard"
    genre = "illustration"
  finsi
  locale m = {titre = rogner(t), genre = genre, dossier = "Nouveaux", tags = {}}
  locale contenu = "Nouveau paragraphe réutilisable."
  si genre <> "texte"
    m.ext = "svg"
    contenu = SVG_VIDE(800, 600)
  finsi
  locale id = ENREGISTRER_COMPOSANT(m, contenu, nul)
  RAFRAICHIR_BIBLIOTHEQUE()
  OUVRIR_COMPOSANT(id)
retourner

fonction DUPLIQUER_COMPOSANT(id, titre)
  locale c = COMPOSANT(id)
  locale m = copier(c)
  m.id = nul
  m.cree = nul
  m.version = 0
  m.variantes = {}
  m.titre = sisinon(titre = nul, c.titre + " (copie)", titre)
  locale nid = ENREGISTRER_COMPOSANT(m, CONTENU_COMPOSANT(c, nul), nul)
  RAFRAICHIR_BIBLIOTHEQUE()
  STATUT("Composant dupliqué : " + nid)
retourner nid

&&
&& Explorateur du projet : documents, présentations, storyboards
&&

procedure PROJET_ARBRE
  globale NOEUDS_PROJ
  lprojet:vider()
  NOEUDS_PROJ = {}
  locale sp = ui.sep
  locale rd = "▤ Documents (" + #DOCS + ")"
  lprojet:ajouter(rd)
  pour chaque d dans DOCS
    locale p = rd + sp + d.titre
    lprojet:ajouter(p)
    NOEUDS_PROJ[p] = {genre = "document", id = d.nom}
  suivant
  locale rp = "▭ Présentations (" + #PRES + ")"
  lprojet:ajouter(rp)
  pour chaque d dans PRES
    locale p = rp + sp + d.titre + "  · " + PLURIEL(#d.diapositives, "diapositive")
    lprojet:ajouter(p)
    NOEUDS_PROJ[p] = {genre = "presentation", id = d.nom}
  suivant
  locale rs = "◫ Storyboards (" + #SB + ")"
  lprojet:ajouter(rs)
  pour chaque d dans SB
    locale p = rs + sp + d.titre + "  · " + PLURIEL(#d.scenes, "scène")
    lprojet:ajouter(p)
    NOEUDS_PROJ[p] = {genre = "storyboard", id = d.nom}
  suivant
  lprojet:deplier(rd)
  lprojet:deplier(rp)
  lprojet:deplier(rs)
retourner

procedure PROJET_CHOIX(ev)
  locale p = ev.texte
  si ev.chemin <> nul
    p = joindre(ev.chemin, ui.sep)
  finsi
  locale n = NOEUDS_PROJ[p]
  si n = nul
    retourner
  finsi
  SELECTIONNER(n.genre, n.id)
  faire cas
  cas n.genre = "document"
    OUVRIR_ESPACE("document")
    OUVRIR_DOCUMENT(n.id)
  cas n.genre = "presentation"
    OUVRIR_ESPACE("presentation")
    PRES_OUVRIR(n.id)
  cas n.genre = "storyboard"
    OUVRIR_ESPACE("storyboard")
    SB_OUVRIR(n.id)
  fincas
retourner

&&
&& Sélection courante et fiche de propriétés (inspecteur)
&&

procedure CONSTRUIRE_PROPRIETES(o)
  globale fiche, gprops, PROPS_CIBLE
  locale col = o:ajouter(ui.separateur{vertical = faux, position = 0.42})
  col.ancrage = "centre"
  fiche = col:ajouter(ui.markdown("# Kaléido" + car(10) + "Choisissez un composant ou un livrable."))
  fiche.surselection = @FICHE_LIEN
  gprops = col:ajouter(ui.grille())
  gprops:ajoutercolonne{nom = "prop", titre = "Propriété", largeur = 110}
  gprops:ajoutercolonne{nom = "valeur", titre = "Valeur", largeur = 220}
  gprops:fixermodifiable(vrai)
  gprops.surchangement = @PROPS_CHANGEES
  PROPS_CIBLE = nul
retourner

procedure SELECTIONNER(genre, id)
  globale SEL
  si genre = nul
    SEL = nul
    fiche.valeur = "# Kaléido" + car(10) + "Rien n'est sélectionné."
    gprops:vider()
    retourner
  finsi
  SEL = {genre = genre, id = id}
  FICHE()
  DEPENDANCES_RAFRAICHIR()
  VARIANTES_RAFRAICHIR()
retourner

procedure FICHE
  si SEL = nul
    retourner
  finsi
  locale md = ""
  gprops:vider()
  globale PROPS_CIBLE
  PROPS_CIBLE = SEL
  si SEL.genre = "composant"
    locale c = COMPOSANT(SEL.id)
    si c = nul
      retourner
    finsi
    locale imp = IMPACT(c.id)
    md = "## " + ICONE_GENRE(c.genre) + " " + c.titre + car(10) + car(10) + ;
         "`{{> " + c.id + "}}` · " + c.genre + " · version " + (c.version + 1) + car(10) + car(10)
    si c.description <> nul et c.description <> ""
      md = md + c.description + car(10) + car(10)
    finsi
    md = md + "**Utilisé par** : " + IMPACT_RESUME(imp) + car(10) + car(10)
    si #c.variantes > 0
      md = md + "**Variantes** : standard, " + joindre(c.variantes, ", ") + car(10) + car(10)
    finsi
    si GENRE_TEXTE(c.genre)
      md = md + "---" + car(10) + COURT(CONTENU_COMPOSANT(c, nul), 600)
    finsi
    fiche.valeur = md
    PROP(gprops, "Titre", c.titre)
    PROP(gprops, "Identifiant", c.id)
    PROP(gprops, "Genre", c.genre)
    PROP(gprops, "Dossier", sisinon(c.dossier = nul, "", c.dossier))
    PROP(gprops, "Collections", joindre(sisinon(c.collections = nul, {}, c.collections), ", "))
    PROP(gprops, "Catégorie", sisinon(c.categorie = nul, "", c.categorie))
    PROP(gprops, "Étiquettes", joindre(c.tags, ", "))
    PROP(gprops, "Mots-clés", sisinon(c.motscles = nul, "", c.motscles))
    PROP(gprops, "Description", sisinon(c.description = nul, "", c.description))
    PROP(gprops, "Auteur", sisinon(c.auteur = nul, "", c.auteur))
    PROP(gprops, "Créé", c.cree)
    PROP(gprops, "Modifié", c.modifie)
    retourner
  finsi
  locale titre = ""
  faire cas
  cas SEL.genre = "document"
    locale d = DOC(SEL.id)
    si d = nul
      retourner
    finsi
    titre = d.titre
    md = "## ▤ " + d.titre + car(10) + car(10) + "Document · `documents/" + d.nom + ".md`" + car(10) + car(10)
    locale refs = REFERENCES(LIRE_TEXTE(d.chemin), "md")
    md = md + "**Composants utilisés** : " + #refs + car(10) + car(10)
    pour chaque r dans refs
      locale c = COMPOSANT(r.id)
      md = md + "- " + sisinon(c = nul, "⚠ " + r.id, c.titre) + sisinon(r.variante <> "", " @" + r.variante, "") + sisinon(r.version <> "", " #" + r.version, "") + car(10)
    suivant
    PROP(gprops, "Titre", d.titre)
    PROP(gprops, "Variante", sisinon(d.meta.variante = nul, "standard", d.meta.variante))
  cas SEL.genre = "presentation"
    locale d = PRESENTATION(SEL.id)
    si d = nul
      retourner
    finsi
    md = "## ▭ " + d.titre + car(10) + car(10) + PLURIEL(#d.diapositives, "diapositive") + " · thème " + sisinon(d.theme = nul, "Aurore", d.theme)
    PROP(gprops, "Titre", d.titre)
    PROP(gprops, "Thème", sisinon(d.theme = nul, "aurore", d.theme))
  cas SEL.genre = "storyboard"
    locale d = STORYBOARD(SEL.id)
    si d = nul
      retourner
    finsi
    locale duree = 0
    pour chaque s dans d.scenes
      duree += sisinon(s.duree = nul, 0, s.duree)
    suivant
    md = "## ◫ " + d.titre + car(10) + car(10) + PLURIEL(#d.scenes, "scène") + " · " + duree + " s · " + PLURIEL(#sisinon(d.personnages = nul, {}, d.personnages), "personnage")
    PROP(gprops, "Titre", d.titre)
  autrement
    md = "## " + SEL.genre + car(10) + SEL.id
  fincas
  fiche.valeur = md
retourner

procedure PROP(g, nom, v)
  g:ajouterligne(nom, sisinon(v = nul, "", chaine(v)))
retourner

procedure PROPS_CHANGEES(ev)
  si PROPS_CIBLE = nul
    retourner
  finsi
  locale n = gprops:nombre()
  locale vals = {}
  pour i = 1 a n
    vals[gprops:cellule(i, 1)] = gprops:cellule(i, 2)
  suivant
  faire cas
  cas PROPS_CIBLE.genre = "forme"
    FORME_PROPS_CHANGEES(PROPS_CIBLE.id)
  cas PROPS_CIBLE.genre = "composant"
    locale c = COMPOSANT(PROPS_CIBLE.id)
    si c = nul
      retourner
    finsi
    c.titre = vals["Titre"]
    c.dossier = vals["Dossier"]
    c.collections = LISTE_DE(vals["Collections"])
    c.categorie = vals["Catégorie"]
    c.tags = LISTE_DE(vals["Étiquettes"])
    c.motscles = vals["Mots-clés"]
    c.description = vals["Description"]
    c.auteur = vals["Auteur"]
    locale g = minuscule(rogner(vals["Genre"]))
    si g <> "" et g <> c.genre
      c.genre = g
    finsi
    ENREGISTRER_COMPOSANT(c, nul, nul)
    RAFRAICHIR_BIBLIOTHEQUE()
    STATUT("Métadonnées de « " + c.titre + " » enregistrées.")
  cas PROPS_CIBLE.genre = "document"
    locale d = DOC(PROPS_CIBLE.id)
    si d <> nul
      d.titre = vals["Titre"]
      d.meta.titre = d.titre
      locale v = rogner(vals["Variante"])
      d.meta.variante = sisinon(v = "" ou v = "standard", nul, v)
      ECRIRE_JSON(CHEMIN("documents", d.nom + ".json"), d.meta)
      PROJET_ARBRE()
      APERCU_DEMANDER()
    finsi
  cas PROPS_CIBLE.genre = "presentation"
    locale d = PRESENTATION(PROPS_CIBLE.id)
    si d <> nul
      d.titre = vals["Titre"]
      d.theme = minuscule(vals["Thème"])
      ENREGISTRER_PRESENTATION(d)
      PRES_REGENERER_TOUT()
    finsi
  cas PROPS_CIBLE.genre = "storyboard"
    locale d = STORYBOARD(PROPS_CIBLE.id)
    si d <> nul
      d.titre = vals["Titre"]
      ENREGISTRER_STORYBOARD(d)
      PROJET_ARBRE()
    finsi
  fincas
retourner

procedure FICHE_LIEN(ev)
  STATUT(ev.texte)
retourner

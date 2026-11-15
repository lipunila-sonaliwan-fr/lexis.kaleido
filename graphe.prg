&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : graphe de dépendances, analyse d'impact et décision avant modification.
&&
&& Tables (index DuckDB) : composants, utilisations(source_genre, source_id, cible, variante, version).
&& Vues : globale (tout le projet), impact (descendante : qui dépend, directement ou non, du
&& composant), ascendante (ce que le livrable ou le composant utilise).
&& Avant d'enregistrer un composant partagé, Kaléido calcule l'impact et propose :
&&   propager · ignorer (les usages existants sont figés sur la version précédente) ·
&&   créer une variante · créer une branche (copie indépendante).

&& impact transitif : {documents, presentations, storyboards, composants, total, liste}
fonction IMPACT(id)
  locale vus = {}
  locale file_ = {minuscule(id)}
  locale res = {documents = {}, presentations = {}, storyboards = {}, composants = {}, total = 0}
  tantque #file_ > 0
    locale cur = retirer(file_, 1)
    pour chaque u dans RQ("select distinct source_genre, source_id from utilisations where cible = ?", {cur})
      locale cle_ = u.source_genre + ":" + u.source_id
      si vus[cle_] = nul
        vus[cle_] = vrai
        faire cas
        cas u.source_genre = "document"
          inserer(res.documents, u.source_id)
        cas u.source_genre = "presentation"
          inserer(res.presentations, u.source_id)
        cas u.source_genre = "storyboard"
          inserer(res.storyboards, u.source_id)
        cas u.source_genre = "composant"
          inserer(res.composants, u.source_id)
          inserer(file_, u.source_id)
        fincas
      finsi
    suivant
  fintantque
  res.total = #res.documents + #res.presentations + #res.storyboards
retourner res

fonction IMPACT_PHRASE(imp)
retourner "Cette modification impactera " + PLURIEL(#imp.documents, "document") + ", " + PLURIEL(#imp.presentations, "présentation") + ;
          " et " + PLURIEL(#imp.storyboards, "storyboard") + "." + ;
          sisinon(#imp.composants > 0, " (via " + PLURIEL(#imp.composants, "composant") + " intermédiaire" + sisinon(#imp.composants > 1, "s", "") + ")", "")

fonction IMPACT_RESUME(imp)
  si imp.total = 0 et #imp.composants = 0
    retourner "aucun livrable"
  finsi
retourner PLURIEL(#imp.documents, "document") + ", " + PLURIEL(#imp.presentations, "présentation") + ", " + PLURIEL(#imp.storyboards, "storyboard")

&& utilisations directes d'un composant : {genre, id, variante, version}
fonction UTILISATIONS(id)
retourner RQ("select source_genre as genre, source_id as id, variante, version from utilisations where cible = ? order by 1, 2", {minuscule(id)})

&& ce que la source utilise
fonction DEPENDANCES_DE(genre, id)
retourner RQ("select distinct cible, variante, version from utilisations where source_genre = ? and source_id = ? order by 1", {genre, id})

&&
&& Décision avant modification
&&

procedure DEMANDER_IMPACT(c, contenu, variante, rappel)
  globale fenimpact, IMPACT_EN_COURS
  locale imp = IMPACT(c.id)
  IMPACT_EN_COURS = {composant = c, contenu = contenu, variante = variante, rappel = rappel, impact = imp}
  si imp.total = 0 et #imp.composants = 0
    IMPACT_APPLIQUER("propager")
    retourner
  finsi
  si variante <> nul et variante <> "" et variante <> "standard"
    && une variante n'impacte que les usages qui la demandent
    IMPACT_APPLIQUER("propager")
    retourner
  finsi
  si fenimpact <> nul
    essayer
      fenimpact:fermer()
    capturer e
    finessayer
  finsi
  fenimpact = ui.fenetre{titre = "Impact de la modification — " + c.titre, largeur = 640, hauteur = 470, disposition = "bordure", ;
                         sombre = reglages.sombre, densite = "compacte"}
  fenimpact.surfermeture = @IMPACT_FERMEE
  locale n = car(10)
  locale md = "## ⚠ " + IMPACT_PHRASE(imp) + n + n + "Composant **" + c.titre + "** (`" + c.id + "`), version " + (c.version + 1) + "." + n + n
  pour chaque d dans imp.documents
    locale x = DOC(d)
    md = md + "- ▤ " + sisinon(x = nul, d, x.titre) + n
  suivant
  pour chaque d dans imp.presentations
    locale x = PRESENTATION(d)
    md = md + "- ▭ " + sisinon(x = nul, d, x.titre) + n
  suivant
  pour chaque d dans imp.storyboards
    locale x = STORYBOARD(d)
    md = md + "- ◫ " + sisinon(x = nul, d, x.titre) + n
  suivant
  md = md + n + "**Propager** : tous les livrables utilisent la nouvelle version. " + ;
       "**Ignorer** : les livrables existants restent figés sur la version actuelle (`#v" + (c.version + 1) + "`). " + ;
       "**Variante** : la modification devient une variante nommée. **Branche** : une copie indépendante est créée."
  locale m = fenimpact:ajouter(ui.markdown(md))
  m.ancrage = "centre"
  locale b = fenimpact:ajouter(ui.rangee())
  b.ancrage = "bas"
  b.marge = 8
  b.espacement = 6
  locale e = b:ajouter(ui.etiquette(""))
  e.poids = 1
  locale b1 = b:ajouter(ui.bouton("Propager", {defaut = vrai}))
  b1.surclic = @IMPACT_PROPAGER
  locale b2 = b:ajouter(ui.bouton("Ignorer"))
  b2.surclic = @IMPACT_IGNORER
  locale b3 = b:ajouter(ui.bouton("Créer une variante…"))
  b3.surclic = @IMPACT_VARIANTE
  locale b4 = b:ajouter(ui.bouton("Créer une branche…"))
  b4.surclic = @IMPACT_BRANCHE
  locale b5 = b:ajouter(ui.bouton("Annuler", {annuler = vrai}))
  b5.surclic = @IMPACT_ANNULER
  lblimpact.libelle = "⚠ " + IMPACT_RESUME(imp)
retourner

procedure IMPACT_FERMEE(ev)
  globale fenimpact
  fenimpact = nul
retourner

procedure IMPACT_PROPAGER(ev)
  IMPACT_APPLIQUER("propager")
retourner
procedure IMPACT_IGNORER(ev)
  IMPACT_APPLIQUER("ignorer")
retourner
procedure IMPACT_VARIANTE(ev)
  IMPACT_APPLIQUER("variante")
retourner
procedure IMPACT_BRANCHE(ev)
  IMPACT_APPLIQUER("branche")
retourner
procedure IMPACT_ANNULER(ev)
  globale fenimpact
  locale f = fenimpact
  fenimpact = nul
  f:fermer()
  appeler(IMPACT_EN_COURS.rappel, nul)
  STATUT("Modification non enregistrée.")
retourner

procedure IMPACT_APPLIQUER(choix)
  locale x = IMPACT_EN_COURS
  locale c = x.composant
  locale msg = ""
  faire cas
  cas choix = "propager"
    ENREGISTRER_COMPOSANT(c, x.contenu, x.variante)
    msg = "Modification propagée : " + IMPACT_RESUME(x.impact) + " à jour."
  cas choix = "ignorer"
    && les usages actuels sont figés sur la version en cours, puis la nouvelle est enregistrée
    locale figee = "v" + (c.version + 1)
    ECRIRE_TEXTE(CHEMIN(".kaleido", "historique", c.id + "/" + figee + "." + c.ext), CONTENU_COMPOSANT(c, nul))
    FIGER_REFERENCES(c.id, figee, x.impact)
    ENREGISTRER_COMPOSANT(c, x.contenu, nul)
    msg = "Nouvelle version enregistrée ; les livrables existants restent sur " + figee + "."
  cas choix = "variante"
    locale v = ui.demander("Nom de la variante (client, produit, marketing, pédagogique…) :", "client")
    si v = nul ou rogner(v) = ""
      retourner
    finsi
    v = pub.ancre(v)
    ENREGISTRER_COMPOSANT(c, x.contenu, v)
    msg = "Variante « " + v + " » créée : utilisez {{> " + c.id + "@" + v + "}} ou la variante du document."
  cas choix = "branche"
    locale t = ui.demander("Titre de la branche :", c.titre + " (branche)")
    si t = nul ou rogner(t) = ""
      retourner
    finsi
    locale m = copier(c)
    m.id = nul
    m.cree = nul
    m.version = 0
    m.variantes = {}
    m.titre = rogner(t)
    m.branche_de = c.id
    locale nid = ENREGISTRER_COMPOSANT(m, x.contenu, nul)
    msg = "Branche « " + t + " » créée ({{> " + nid + "}}) ; l'original est inchangé."
  fincas
  si fenimpact <> nul
    globale fenimpact
    locale f = fenimpact
    fenimpact = nul
    f:fermer()
  finsi
  lblimpact.libelle = ""
  REINDEXER()
  RAFRAICHIR_BIBLIOTHEQUE()
  si SEL <> nul
    FICHE()
    DEPENDANCES_RAFRAICHIR()
    VARIANTES_RAFRAICHIR()
  finsi
  PRES_COMPOSANT_MODIFIE(c.id)
  SB_COMPOSANT_MODIFIE(c.id)
  appeler(x.rappel, choix)
  STATUT(msg)
  JOURNAL("info", c.id + " : " + choix)
retourner

&& remplace {{> id}} par {{> id#vN}} dans les livrables impactés (et data-composant dans les SVG)
procedure FIGER_REFERENCES(id, version, imp)
  pour chaque nom dans imp.documents
    locale d = DOC(nom)
    si d <> nul
      locale t = LIRE_TEXTE(d.chemin)
      t = remplacertexte(t, "{{> " + id + "}}", "{{> " + id + "#" + version + "}}")
      t = remplacertexte(t, "{{>" + id + "}}", "{{> " + id + "#" + version + "}}")
      ECRIRE_TEXTE(d.chemin, t)
      essayer
        locale uid = ed:chercherdocument(d.chemin)
        si uid <> nul
          ed:fixertexte(t, uid, vrai)
        finsi
      capturer e
      finessayer
    finsi
  suivant
  pour chaque cid dans imp.composants
    locale cc = COMPOSANT(cid)
    si cc <> nul et GENRE_TEXTE(cc.genre)
      locale f = FICHIER_COMPOSANT(cc, nul)
      ECRIRE_TEXTE(f, remplacertexte(LIRE_TEXTE(f), "{{> " + id + "}}", "{{> " + id + "#" + version + "}}"))
    finsi
  suivant
  && diapositives et scènes : l'occurrence pointe vers le fichier figé de l'historique
  locale fig = CHEMIN(".kaleido", "historique", id + "/" + version + "." + COMPOSANT(id).ext)
  pour chaque nom dans imp.presentations
    locale d = PRESENTATION(nom)
    pour chaque s dans d.diapositives
      FIGER_SVG(CHEMIN(s.svg), id, fig, version)
    suivant
  suivant
  pour chaque nom dans imp.storyboards
    locale d = STORYBOARD(nom)
    pour chaque s dans d.scenes
      FIGER_SVG(CHEMIN(s.svg), id, fig, version)
    suivant
  suivant
retourner

procedure FIGER_SVG(f, id, fig, version)
  locale t = LIRE_TEXTE(f)
  si contient(t, 'data-composant="' + id + '"')
    t = remplacertexte(t, FICHIER_COMPOSANT(COMPOSANT(id), nul), fig)
    t = remplacertexte(t, 'data-composant="' + id + '"', 'data-composant="' + id + "#" + version + '"')
    ECRIRE_TEXTE(f, t)
  finsi
retourner

&&
&& Panneau « Liens » de l'inspecteur : utilisations et dépendances de la sélection
&&

procedure CONSTRUIRE_DEPENDANCES(o)
  globale gdeps, lbldeps
  lbldeps = o:ajouter(ui.etiquette(""))
  lbldeps.ancrage = "haut"
  lbldeps.couleur = "#FBBF24"
  gdeps = o:ajouter(ui.grille())
  gdeps.ancrage = "centre"
  gdeps:ajoutercolonne{nom = "sens", titre = "", largeur = 30}
  gdeps:ajoutercolonne{nom = "genre", titre = "Genre", largeur = 90}
  gdeps:ajoutercolonne{nom = "nom", titre = "Élément", largeur = 170}
  gdeps:ajoutercolonne{nom = "detail", titre = "Variante / version", largeur = 110}
  gdeps.surdoubleclic = @DEPS_OUVRIR
retourner

procedure DEPENDANCES_RAFRAICHIR
  gdeps:vider()
  lbldeps.libelle = ""
  si SEL = nul
    retourner
  finsi
  si SEL.genre = "composant"
    locale imp = IMPACT(SEL.id)
    lbldeps.libelle = sisinon(imp.total > 0, "⚠ ", "") + IMPACT_RESUME(imp)
    pour chaque u dans UTILISATIONS(SEL.id)
      gdeps:ajouterligne("←", u.genre, NOM_ELEMENT(u.genre, u.id), joindre({sisinon(u.variante = nul, "", u.variante), sisinon(u.version = nul, "", u.version)}, " "))
    suivant
  finsi
  pour chaque d dans DEPENDANCES_DE(SEL.genre, SEL.id)
    gdeps:ajouterligne("→", "composant", NOM_ELEMENT("composant", d.cible), joindre({sisinon(d.variante = nul, "", d.variante), sisinon(d.version = nul, "", d.version)}, " "))
  suivant
retourner

fonction NOM_ELEMENT(genre, id)
  faire cas
  cas genre = "composant"
    locale c = COMPOSANT(id)
    retourner sisinon(c = nul, "⚠ " + id, c.titre)
  cas genre = "document"
    locale d = DOC(id)
    retourner sisinon(d = nul, id, d.titre)
  cas genre = "presentation"
    locale d = PRESENTATION(id)
    retourner sisinon(d = nul, id, d.titre)
  cas genre = "storyboard"
    locale d = STORYBOARD(id)
    retourner sisinon(d = nul, id, d.titre)
  fincas
retourner id

procedure DEPS_OUVRIR(ev)
  locale i = ev.index
  si i = nul ou i < 1
    retourner
  finsi
  locale genre = gdeps:cellule(i, 2)
  locale nom = gdeps:cellule(i, 3)
  && retrouve l'identifiant par le titre
  faire cas
  cas genre = "composant"
    pour chaque id, c dans COMPOSANTS
      si c.titre = nom
        OUVRIR_COMPOSANT(id)
      finsi
    suivant
  cas genre = "document"
    pour chaque d dans DOCS
      si d.titre = nom
        OUVRIR_ESPACE("document")
        OUVRIR_DOCUMENT(d.nom)
      finsi
    suivant
  cas genre = "presentation"
    pour chaque d dans PRES
      si d.titre = nom
        OUVRIR_ESPACE("presentation")
        PRES_OUVRIR(d.nom)
      finsi
    suivant
  cas genre = "storyboard"
    pour chaque d dans SB
      si d.titre = nom
        OUVRIR_ESPACE("storyboard")
        SB_OUVRIR(d.nom)
      finsi
    suivant
  fincas
retourner

&&
&& Espace « Graphe » : graphe interactif (diagramme), vues globale / impact / ascendante
&&

procedure CONSTRUIRE_GRAPHE(o)
  globale dia, lblgraphe, GRAPHE
  GRAPHE = {vue = "globale", centre = nul}
  lblgraphe = o:ajouter(ui.etiquette(""))
  lblgraphe.ancrage = "haut"
  lblgraphe.couleur = "#CBD5E1"
  dia = o:ajouter(ui.diagramme{modifiable = faux, direction = "droite"})
  dia.ancrage = "centre"
  dia.surselection = @GRAPHE_CHOIX
  dia.surdoubleclic = @GRAPHE_OUVRIR
retourner

procedure RUBAN_GRAPHE(r)
  OUTIL(r, "◉ Global", @GRAPHE_GLOBAL, "Tout le projet : composants et livrables")
  OUTIL(r, "⇣ Impact", @GRAPHE_VUE_IMPACT, "Vue descendante : ce qui dépend de la sélection (directement ou non)")
  OUTIL(r, "⇡ Ascendante", @GRAPHE_VUE_ASC, "Vue ascendante : ce que la sélection utilise")
  FILET(r)
  OUTIL(r, "Disposer →", @GRAPHE_DROITE, "Disposition en couches de gauche à droite")
  OUTIL(r, "Disposer ↓", @GRAPHE_BAS, "Disposition en couches de haut en bas")
  ICONE(r, "ajuster", "Ajuster", "Tout le graphe dans la vue", @GRAPHE_AJUSTER)
  FILET(r)
  OUTIL(r, "Composants orphelins", @GRAPHE_ORPHELINS, "Composants qu'aucun livrable n'utilise")
  OUTIL(r, "Références cassées", @GRAPHE_CASSEES, "Références vers des composants absents")
retourner

fonction COULEUR_GENRE(g)
  faire cas
  cas g = "document"
    retourner "#6366F1"
  cas g = "presentation"
    retourner "#EC4899"
  cas g = "storyboard"
    retourner "#F59E0B"
  fincas
retourner "#10B981"

procedure GRAPHE_NOEUD(genre, id)
  locale titre = NOM_ELEMENT(genre, id)
  locale ic = sisinon(genre = "document", "▤", sisinon(genre = "presentation", "▭", sisinon(genre = "storyboard", "◫", "◆")))
  locale sous = genre
  si genre = "composant"
    locale c = COMPOSANT(id)
    si c <> nul
      sous = c.genre + sisinon(#c.variantes > 0, " · " + PLURIEL(#c.variantes + 1, "variante"), "") + " · v" + (c.version + 1)
    finsi
  finsi
  dia:noeud{id = genre + ":" + id, titre = ic + " " + titre, soustitre = sous, couleur = COULEUR_GENRE(genre), forme = "boite"}
retourner

procedure GRAPHE_RAFRAICHIR
  faire cas
  cas GRAPHE.vue = "impact" et GRAPHE.centre <> nul
    GRAPHE_IMPACT(GRAPHE.centre)
  cas GRAPHE.vue = "ascendante" et GRAPHE.centre <> nul
    GRAPHE_ASCENDANTE(GRAPHE.centre)
  autrement
    GRAPHE_GLOBAL(nul)
  fincas
retourner

procedure GRAPHE_GLOBAL(ev)
  GRAPHE.vue = "globale"
  dia:vider()
  locale vus = {}
  pour chaque id, c dans COMPOSANTS
    GRAPHE_NOEUD("composant", id)
  suivant
  pour chaque d dans DOCS
    GRAPHE_NOEUD("document", d.nom)
  suivant
  pour chaque d dans PRES
    GRAPHE_NOEUD("presentation", d.nom)
  suivant
  pour chaque d dans SB
    GRAPHE_NOEUD("storyboard", d.nom)
  suivant
  locale n = 0
  pour chaque u dans RQ("select distinct source_genre, source_id, cible, variante from utilisations", nul)
    si COMPOSANT(u.cible) <> nul
      dia:lien{de = "composant:" + u.cible, a = u.source_genre + ":" + u.source_id, libelle = sisinon(u.variante = nul ou u.variante = "", "", "@" + u.variante), ;
               couleur = COULEUR_GENRE(u.source_genre)}
      n += 1
    finsi
  suivant
  dia:disposer("droite")
  dia:ajuster(40)
  lblgraphe.libelle = "Graphe global : " + PLURIEL(nbelements(COMPOSANTS), "composant") + ", " + PLURIEL(#DOCS + #PRES + #SB, "livrable") + ", " + ;
                      PLURIEL(n, "lien") + ". Cliquez un nœud pour l'inspecter, double-cliquez pour l'ouvrir."
retourner

procedure GRAPHE_IMPACT(id)
  GRAPHE.vue = "impact"
  GRAPHE.centre = id
  dia:vider()
  GRAPHE_NOEUD("composant", id)
  locale vus = {}
  locale file_ = {id}
  tantque #file_ > 0
    locale cur = retirer(file_, 1)
    pour chaque u dans RQ("select distinct source_genre, source_id, variante from utilisations where cible = ?", {cur})
      locale k = u.source_genre + ":" + u.source_id
      si vus[k] = nul
        vus[k] = vrai
        GRAPHE_NOEUD(u.source_genre, u.source_id)
        si u.source_genre = "composant"
          inserer(file_, u.source_id)
        finsi
      finsi
      dia:lien{de = "composant:" + cur, a = k, libelle = sisinon(u.variante = nul ou u.variante = "", "", "@" + u.variante), couleur = COULEUR_GENRE(u.source_genre)}
    suivant
  fintantque
  dia:disposer("droite")
  dia:ajuster(50)
  dia:selectionner("composant:" + id)
  lblgraphe.libelle = "Impact de « " + NOM_ELEMENT("composant", id) + " » — " + IMPACT_PHRASE(IMPACT(id))
retourner

procedure GRAPHE_ASCENDANTE(cle_)
  GRAPHE.vue = "ascendante"
  GRAPHE.centre = cle_
  dia:vider()
  locale p = position(":", cle_)
  locale genre = gauche(cle_, p - 1)
  locale id = souschaine(cle_, p + 1)
  GRAPHE_NOEUD(genre, id)
  locale file_ = {{genre = genre, id = id}}
  locale vus = {}
  tantque #file_ > 0
    locale cur = retirer(file_, 1)
    pour chaque d dans DEPENDANCES_DE(cur.genre, cur.id)
      si vus[d.cible] = nul
        vus[d.cible] = vrai
        GRAPHE_NOEUD("composant", d.cible)
        inserer(file_, {genre = "composant", id = d.cible})
      finsi
      dia:lien{de = "composant:" + d.cible, a = cur.genre + ":" + cur.id, libelle = sisinon(d.variante = nul ou d.variante = "", "", "@" + d.variante)}
    suivant
  fintantque
  dia:disposer("droite")
  dia:ajuster(50)
  lblgraphe.libelle = "Vue ascendante de « " + NOM_ELEMENT(genre, id) + " » : tout ce qu'il utilise."
retourner

procedure GRAPHE_VUE_IMPACT(ev)
  locale s = dia:selection()
  si s.genre = "noeud" et commencepar(s.id, "composant:")
    GRAPHE_IMPACT(souschaine(s.id, 11))
  sinonsi SEL <> nul et SEL.genre = "composant"
    GRAPHE_IMPACT(SEL.id)
  sinon
    STATUT("Choisissez un composant (graphe ou bibliothèque).")
  finsi
retourner

procedure GRAPHE_VUE_ASC(ev)
  locale s = dia:selection()
  si s.genre = "noeud"
    GRAPHE_ASCENDANTE(s.id)
  sinonsi SEL <> nul
    GRAPHE_ASCENDANTE(SEL.genre + ":" + SEL.id)
  finsi
retourner

procedure GRAPHE_DROITE(ev)
  dia:disposer("droite")
  dia:ajuster(40)
retourner
procedure GRAPHE_BAS(ev)
  dia:disposer("bas")
  dia:ajuster(40)
retourner
procedure GRAPHE_AJUSTER(ev)
  dia:ajuster()
retourner

procedure GRAPHE_CHOIX(ev)
  locale t = ev.texte
  si t = "" ou commencepar(t, "lien:")
    retourner
  finsi
  locale p = position(":", t)
  SELECTIONNER(gauche(t, p - 1), souschaine(t, p + 1))
retourner

procedure GRAPHE_OUVRIR(ev)
  locale t = ev.texte
  si t = "" ou commencepar(t, "lien:")
    retourner
  finsi
  locale p = position(":", t)
  locale genre = gauche(t, p - 1)
  locale id = souschaine(t, p + 1)
  faire cas
  cas genre = "composant"
    OUVRIR_COMPOSANT(id)
  cas genre = "document"
    OUVRIR_ESPACE("document")
    OUVRIR_DOCUMENT(id)
  cas genre = "presentation"
    OUVRIR_ESPACE("presentation")
    PRES_OUVRIR(id)
  cas genre = "storyboard"
    OUVRIR_ESPACE("storyboard")
    SB_OUVRIR(id)
  fincas
retourner

procedure GRAPHE_ORPHELINS(ev)
  locale n = car(10)
  locale md = "## Composants orphelins" + n + n
  locale k = 0
  pour chaque u dans RQ("select id, titre from composants where id not in (select cible from utilisations) order by titre", nul)
    md = md + "- " + u.titre + " (`" + u.id + "`)" + n
    k += 1
  suivant
  si k = 0
    md = md + "Tous les composants sont utilisés."
  finsi
  fiche.valeur = md
  droite.valeur = 1
retourner

procedure GRAPHE_CASSEES(ev)
  locale n = car(10)
  locale md = "## Références cassées" + n + n
  locale k = 0
  pour chaque u dans RQ("select source_genre, source_id, cible from utilisations where cible not in (select id from composants)", nul)
    md = md + "- " + u.source_genre + " **" + NOM_ELEMENT(u.source_genre, u.source_id) + "** → `" + u.cible + "`" + n
    k += 1
  suivant
  si k = 0
    md = md + "Aucune référence cassée."
  finsi
  fiche.valeur = md
  droite.valeur = 1
retourner

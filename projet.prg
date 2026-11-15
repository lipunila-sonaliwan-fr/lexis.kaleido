&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : projet (dossier), manifeste, index DuckDB, historique des versions.
&&
&& <projet>/kaleido.json                     manifeste : titre, auteur, variables, gabarit, thème
&& <projet>/composants/<id>.json             métadonnées d'un composant
&& <projet>/composants/<id>.<md|svg|png…>    contenu (version standard)
&& <projet>/composants/<id>@<variante>.<ext> variantes
&& <projet>/documents/<nom>.md (+ .json)     documents composés
&& <projet>/presentations/<nom>.json (+ dossier des diapositives SVG)
&& <projet>/storyboards/<nom>.json (+ dossier des scènes SVG)
&& <projet>/medias/                          fichiers importés
&& <projet>/plugins/*.prg                    extensions
&& <projet>/.kaleido/index.duckdb            index (recherche, graphe), reconstruit au besoin
&& <projet>/.kaleido/historique/<id>/vN.ext  versions successives

fonction CHEMIN(a, b, c)
  si c <> nul
    retourner fichier.joindre(PROJ.dossier, a, b, c)
  finsi
  si b <> nul
    retourner fichier.joindre(PROJ.dossier, a, b)
  finsi
retourner fichier.joindre(PROJ.dossier, a)

procedure OUVRIR_PROJET(dossier_)
  globale PROJ, COMPOSANTS, DOCS, PRES, SB
  dossier_ = fichier.absolu(dossier_)
  fichier.creerdossier(dossier_)
  PROJ = LIRE_JSON(fichier.joindre(dossier_, "kaleido.json"), nul)
  si PROJ = nul
    PROJ = {titre = fichier.nom(dossier_), auteur = "", variables = {}, cree = MAINTENANT_ISO()}
  finsi
  PROJ.dossier = dossier_
  si PROJ.variables = nul
    PROJ.variables = {}
  finsi
  si PROJ.gabarit = nul
    PROJ.gabarit = GABARIT_DEFAUT()
  finsi
  pour chaque d dans {"composants", "documents", "presentations", "storyboards", "medias", "plugins", "modeles", ".kaleido", "publication"}
    fichier.creerdossier(CHEMIN(d))
  suivant
  && index local : une base par projet
  essayer
    fermerbase()
  capturer e
  finessayer
  essayer
    ouvrirbase(CHEMIN(".kaleido", "index.duckdb"))
  capturer e
    ouvrirbase(":memoire:")
    JOURNAL("attention", "index en mémoire : " + e)
  finessayer
  requete("create table if not exists composants (id varchar primary key, titre varchar, genre varchar, dossier varchar, tags varchar, texte varchar, modifie varchar, version integer)")
  requete("create table if not exists utilisations (source_genre varchar, source_id varchar, cible varchar, variante varchar, version varchar)")
  CHARGER_COMPOSANTS()
  CHARGER_LIVRABLES()
  REINDEXER()
  ECRIRE_MANIFESTE()
  JOURNAL("info", "projet ouvert : " + dossier_)
retourner

procedure ECRIRE_MANIFESTE
  locale m = copier(PROJ)
  m.dossier = nul
  ECRIRE_JSON(fichier.joindre(PROJ.dossier, "kaleido.json"), m)
retourner

fonction GABARIT_DEFAUT()
retourner {format = "a4", justifier = vrai, numeroter = faux, couverture = vrai, accent = "#4f46e5", ;
           policecorps = "Lora", policetitres = "Poppins", taille = 10.5, entete = "{titre}||{chapitre}", ;
           pied = "||{page} / {pages}", chapitrenouvellepage = faux}

&&
&& Composants
&&

procedure CHARGER_COMPOSANTS
  globale COMPOSANTS
  COMPOSANTS = {}
  pour chaque nom dans fichier.liste(CHEMIN("composants"))
    si finitpar(nom, ".json")
      locale m = LIRE_JSON(CHEMIN("composants", nom), nul)
      si m <> nul et m.id <> nul
        si m.variantes = nul
          m.variantes = {}
        finsi
        si m.tags = nul
          m.tags = {}
        finsi
        COMPOSANTS[m.id] = m
      finsi
    finsi
  suivant
retourner

fonction COMPOSANT(id)
  si id = nul
    retourner nul
  finsi
retourner COMPOSANTS[minuscule(id)]

fonction GENRE_TEXTE(genre)
retourner contient({"texte", "paragraphe", "liste", "chapitre", "page", "section", "tableau"}, genre)

fonction GENRE_IMAGE(genre)
retourner contient({"image", "logo", "photo"}, genre)

&& fichier du contenu d'un composant (variante facultative)
fonction FICHIER_COMPOSANT(c, variante)
  si c = nul
    retourner nul
  finsi
  locale ext = sisinon(c.ext = nul, "md", c.ext)
  si variante <> nul et variante <> "" et variante <> "standard"
    retourner CHEMIN("composants", c.id + "@" + variante + "." + ext)
  finsi
retourner CHEMIN("composants", c.id + "." + ext)

fonction CONTENU_COMPOSANT(c, variante)
  locale f = FICHIER_COMPOSANT(c, variante)
  si f <> nul et non fichier.existe(f)
    f = FICHIER_COMPOSANT(c, nul)
  finsi
retourner LIRE_TEXTE(f)

&& crée ou met à jour un composant ; contenu nul : contenu inchangé
fonction ENREGISTRER_COMPOSANT(m, contenu, variante)
  globale COMPOSANTS
  si m.id = nul
    m.id = IDENT(m.titre, COMPOSANTS)
  finsi
  m.id = minuscule(m.id)
  si m.cree = nul
    m.cree = MAINTENANT_ISO()
  finsi
  si m.ext = nul
    m.ext = sisinon(GENRE_TEXTE(m.genre) ou m.genre = nul, "md", "svg")
  finsi
  si m.genre = nul
    m.genre = "texte"
  finsi
  si m.variantes = nul
    m.variantes = {}
  finsi
  si m.tags = nul
    m.tags = {}
  finsi
  si m.version = nul
    m.version = 0
  finsi
  si contenu <> nul
    locale f = FICHIER_COMPOSANT(m, variante)
    && historique : la version précédente est conservée
    si fichier.existe(f) et (variante = nul ou variante = "" ou variante = "standard")
      locale ancien = LIRE_TEXTE(f)
      si ancien <> contenu
        m.version += 1
        ECRIRE_TEXTE(CHEMIN(".kaleido", "historique", m.id + "/v" + m.version + "." + m.ext), ancien)
      finsi
    finsi
    ECRIRE_TEXTE(f, contenu)
    si variante <> nul et variante <> "" et variante <> "standard" et non LISTE_CONTIENT(m.variantes, variante)
      inserer(m.variantes, variante)
    finsi
  finsi
  m.modifie = MAINTENANT_ISO()
  COMPOSANTS[m.id] = m
  ECRIRE_JSON(CHEMIN("composants", m.id + ".json"), m)
  INDEXER_COMPOSANT(m)
retourner m.id

procedure SUPPRIMER_COMPOSANT(id)
  globale COMPOSANTS
  locale c = COMPOSANT(id)
  si c = nul
    retourner
  finsi
  && corbeille : le composant reste récupérable
  locale corb = CHEMIN(".kaleido", "corbeille")
  fichier.creerdossier(corb)
  pour chaque nom dans fichier.liste(CHEMIN("composants"))
    si commencepar(nom, c.id + ".") ou commencepar(nom, c.id + "@")
      fichier.deplacer(CHEMIN("composants", nom), fichier.joindre(corb, nom))
    finsi
  suivant
  COMPOSANTS[c.id] = nul
  RQ("delete from composants where id = ?", {c.id})
  JOURNAL("info", "composant supprimé (corbeille) : " + c.id)
retourner

&& versions conservées : liste {numero, chemin, date}
fonction VERSIONS(c)
  locale r = {}
  locale d = CHEMIN(".kaleido", "historique", c.id)
  si non fichier.existe(d)
    retourner r
  finsi
  pour chaque nom dans fichier.liste(d)
    si commencepar(nom, "v")
      locale n = nombre(souschaine(nom, 2, position(".", nom) - 2))
      si n <> nul
        locale inf = fichier.infos(fichier.joindre(d, nom))
        inserer(r, {numero = n, chemin = fichier.joindre(d, nom), date = sisinon(inf = nul, "", inf.modifie)})
      finsi
    finsi
  suivant
  trier(r, @VERSION_DESC)
retourner r

fonction VERSION_DESC(a, b)
retourner a.numero > b.numero

fonction CONTENU_VERSION(c, n)
retourner LIRE_TEXTE(CHEMIN(".kaleido", "historique", c.id + "/v" + n + "." + c.ext))

&&
&& Livrables : documents, présentations, storyboards
&&

procedure CHARGER_LIVRABLES
  globale DOCS, PRES, SB
  DOCS = {}
  PRES = {}
  SB = {}
  pour chaque nom dans fichier.liste(CHEMIN("documents"))
    si finitpar(nom, ".md")
      locale n = gauche(nom, #nom - 3)
      locale meta = LIRE_JSON(CHEMIN("documents", n + ".json"), {})
      inserer(DOCS, {nom = n, titre = sisinon(meta.titre = nul, n, meta.titre), chemin = CHEMIN("documents", nom), meta = meta})
    finsi
  suivant
  pour chaque nom dans fichier.liste(CHEMIN("presentations"))
    si finitpar(nom, ".json")
      locale d = LIRE_JSON(CHEMIN("presentations", nom), nul)
      si d <> nul
        d.nom = gauche(nom, #nom - 5)
        inserer(PRES, d)
      finsi
    finsi
  suivant
  pour chaque nom dans fichier.liste(CHEMIN("storyboards"))
    si finitpar(nom, ".json")
      locale d = LIRE_JSON(CHEMIN("storyboards", nom), nul)
      si d <> nul
        d.nom = gauche(nom, #nom - 5)
        inserer(SB, d)
      finsi
    finsi
  suivant
  trier(DOCS, @PAR_TITRE)
  trier(PRES, @PAR_TITRE)
  trier(SB, @PAR_TITRE)
retourner

fonction PAR_TITRE(a, b)
retourner minuscule(sisinon(a.titre = nul, a.nom, a.titre)) < minuscule(sisinon(b.titre = nul, b.nom, b.titre))

fonction DOC(nom)
  pour chaque d dans DOCS
    si d.nom = nom
      retourner d
    finsi
  suivant
retourner nul

fonction PRESENTATION(nom)
  pour chaque d dans PRES
    si d.nom = nom
      retourner d
    finsi
  suivant
retourner nul

fonction STORYBOARD(nom)
  pour chaque d dans SB
    si d.nom = nom
      retourner d
    finsi
  suivant
retourner nul

procedure ENREGISTRER_PRESENTATION(d)
  locale c = copier(d)
  c.nom = nul
  ECRIRE_JSON(CHEMIN("presentations", d.nom + ".json"), c)
  INDEXER_LIVRABLE("presentation", d.nom)
retourner

procedure ENREGISTRER_STORYBOARD(d)
  locale c = copier(d)
  c.nom = nul
  ECRIRE_JSON(CHEMIN("storyboards", d.nom + ".json"), c)
  INDEXER_LIVRABLE("storyboard", d.nom)
retourner

&&
&& Index (recherche instantanée, graphe des dépendances)
&&

procedure INDEXER_COMPOSANT(m)
  locale txt = ""
  si GENRE_TEXTE(m.genre)
    txt = pub.textebrut(CONTENU_COMPOSANT(m, nul))
  finsi
  locale meta = joindre(m.tags, " ") + " " + sisinon(m.motscles = nul, "", m.motscles) + " " + ;
                sisinon(m.description = nul, "", m.description) + " " + sisinon(m.categorie = nul, "", m.categorie) + " " + ;
                joindre(sisinon(m.collections = nul, {}, m.collections), " ")
  RQ("delete from composants where id = ?", {m.id})
  RQ("insert into composants values (?, ?, ?, ?, ?, ?, ?, ?)", ;
     {m.id, m.titre, m.genre, sisinon(m.dossier = nul, "", m.dossier), meta, txt, m.modifie, m.version})
  && utilisations du composant lui-même (composants composés)
  RQ("delete from utilisations where source_genre = 'composant' and source_id = ?", {m.id})
  pour chaque r dans REFERENCES(CONTENU_COMPOSANT(m, nul), m.ext)
    RQ("insert into utilisations values ('composant', ?, ?, ?, ?)", {m.id, r.id, r.variante, r.version})
  suivant
retourner

procedure INDEXER_LIVRABLE(genre, nom)
  RQ("delete from utilisations where source_genre = ? and source_id = ?", {genre, nom})
  pour chaque r dans REFERENCES_LIVRABLE(genre, nom)
    RQ("insert into utilisations values (?, ?, ?, ?, ?)", {genre, nom, r.id, r.variante, r.version})
  suivant
retourner

procedure REINDEXER
  requete("delete from composants")
  requete("delete from utilisations")
  pour chaque id, c dans COMPOSANTS
    INDEXER_COMPOSANT(c)
  suivant
  pour chaque d dans DOCS
    INDEXER_LIVRABLE("document", d.nom)
  suivant
  pour chaque d dans PRES
    INDEXER_LIVRABLE("presentation", d.nom)
  suivant
  pour chaque d dans SB
    INDEXER_LIVRABLE("storyboard", d.nom)
  suivant
retourner

&& recherche instantanée : titre, identifiant, étiquettes, mots-clés, texte
fonction CHERCHER_COMPOSANTS(q, genre)
  locale motif = "%" + minuscule(rogner(q)) + "%"
  locale sql = "select id, titre, genre, dossier, " + ;
    "(case when lower(titre || ' ' || id) like ? then 3 when lower(tags) like ? then 2 else 1 end) as score " + ;
    "from composants where lower(titre || ' ' || id || ' ' || tags || ' ' || texte) like ?"
  si genre <> nul et genre <> ""
    retourner RQ(sql + " and genre = ? order by score desc, titre limit 300", {motif, motif, motif, genre})
  finsi
retourner RQ(sql + " order by score desc, titre limit 300", {motif, motif, motif})

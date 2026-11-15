&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : système d'extensions (plugins).
&&
&& Une extension est un fichier .prg du dossier plugins/ du projet (ou du dossier plugins/ de
&& l'application). Il ne contient que des procédures ; lexis.charger les ajoute au programme.
&& Son point d'entrée EXTENSION_<NOM>() (NOM = nom du fichier en majuscules) appelle :
&&   KALEIDO_ENREGISTRER{genre = "commande",    nom =, libelle =, procedure = @P}   palette et menus
&&   KALEIDO_ENREGISTRER{genre = "macro",       nom =, procedure = @F}              {{nom argument}}
&&   KALEIDO_ENREGISTRER{genre = "exportateur", nom =, libelle =, procedure = @E}   E(document, texte composé) -> chemin
&&   KALEIDO_ENREGISTRER{genre = "verification",nom =, procedure = @V}              V() -> texte Markdown ou nul
&& API utilisable : P (projet), COMPOSANTS, DOCS, PRES, SB, COMPOSANT(id), CONTENU_COMPOSANT(c),
&& ENREGISTRER_COMPOSANT(m, contenu), COMPOSER(texte), STATUT(message), DOC_INSERER(texte)…

procedure CHARGER_EXTENSIONS
  globale EXTENSIONS, EXT_REG
  EXTENSIONS = {}
  si EXT_REG = nul
    EXT_REG = {}
  finsi
  pour chaque dossier_ dans {fichier.joindre(systeme.dossierprogramme(), "plugins"), CHEMIN("plugins")}
    si fichier.existe(dossier_)
      pour chaque nom dans fichier.liste(dossier_)
        si finitpar(nom, ".prg")
          locale base_ = gauche(nom, #nom - 4)
          essayer
            && les extensions livrées avec l'application sont déjà chargées par le runtime
            locale entree = lexis.procedure("EXTENSION_" + majuscule(base_))
            si entree = nul
              lexis.charger(fichier.joindre(dossier_, nom))
              entree = lexis.procedure("EXTENSION_" + majuscule(base_))
            finsi
            si entree <> nul
              appeler(entree)
            finsi
            si non LISTE_CONTIENT(EXTENSIONS, base_)
              inserer(EXTENSIONS, base_)
            finsi
          capturer e
            JOURNAL("erreur", "extension " + nom + " : " + e)
            STATUT("Extension « " + nom + " » ignorée : " + e)
          finessayer
        finsi
      suivant
    finsi
  suivant
  si #EXTENSIONS > 0
    JOURNAL("info", "extensions : " + joindre(EXTENSIONS, ", "))
  finsi
retourner

procedure KALEIDO_ENREGISTRER(x)
  globale EXT_REG
  si x = nul ou x.genre = nul ou x.nom = nul
    erreur "KALEIDO_ENREGISTRER : {genre=, nom=, procedure=} attendu"
  finsi
  inserer(EXT_REG, x)
  faire cas
  cas x.genre = "commande"
    COMMANDE("ext." + x.nom, sisinon(x.libelle = nul, x.nom, x.libelle), "Extensions", "", x.procedure)
  cas x.genre = "macro"
    MACROS[minuscule(x.nom)] = x.procedure
  cas x.genre = "exportateur"
    COMMANDE("exp." + x.nom, "Exporter : " + sisinon(x.libelle = nul, x.nom, x.libelle), "Extensions", "", @EXT_EXPORTER)
  fincas
retourner

fonction EXTENSIONS_DE(genre)
  locale r = {}
  pour chaque x dans sisinon(EXT_REG = nul, {}, EXT_REG)
    si x.genre = genre
      inserer(r, x)
    finsi
  suivant
retourner r

&& exportateurs : proposés dans la palette ; chacun reçoit le document courant composé
procedure EXT_EXPORTER(ev)
  locale x = DOC_ACTIF()
  si x = nul ou x.genre <> "document"
    ui.alerte("Ouvrez d'abord un document.", "information")
    retourner
  finsi
  locale items = {}
  pour chaque e dans EXTENSIONS_DE("exportateur")
    inserer(items, {libelle = sisinon(e.libelle = nul, e.nom, e.libelle), detail = "extension", valeur = e.nom})
  suivant
  QUICKPICK("Exporter avec une extension", items, @EXT_EXPORTER_CHOIX)
retourner

procedure EXT_EXPORTER_CHOIX(nom)
  locale x = DOC_ACTIF()
  locale d = DOC(x.id)
  locale r = COMPOSER_DOCUMENT(d, ed:texte(), d.meta.variante)
  pour chaque e dans EXTENSIONS_DE("exportateur")
    si e.nom = nom
      locale chemin_ = appeler(e.procedure, d, r.texte)
      STATUT("Exporté : " + chemin_)
      PUBLICATION_AJOUTER(chemin_)
    finsi
  suivant
retourner

procedure CMD_EXTENSIONS(ev)
  CHARGER_EXTENSIONS()
  DOC_MAJ_NOMS()
  STATUT("Extensions : " + sisinon(#EXTENSIONS = 0, "aucune", joindre(EXTENSIONS, ", ")))
retourner

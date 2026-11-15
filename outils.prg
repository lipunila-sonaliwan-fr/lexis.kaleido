&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : outils communs (JSON lisible, textes, dates, requêtes, journal).

&& JSON avec des clefs en minuscules (dejson les met en majuscules : l'écriture les rétablit)
fonction JSONK(v, ind)
  locale t = type(v)
  si ind = nul
    ind = ""
  finsi
  faire cas
  cas v = nul
    retourner "null"
  cas t = "logique"
    retourner sisinon(v, "true", "false")
  cas t = "nombre"
    retourner chaine(v)
  cas t = "chaine"
    retourner json(v)
  cas t = "table"
    locale n = #v
    locale nk = nbelements(v)
    locale ind2 = ind + "  "
    locale parts = {}
    si n > 0 et n = nk
      locale simple = vrai
      pour chaque x dans v
        si type(x) = "table"
          simple = faux
        finsi
      suivant
      pour chaque x dans v
        inserer(parts, JSONK(x, ind2))
      suivant
      si simple
        retourner "[" + joindre(parts, ", ") + "]"
      finsi
      retourner "[" + car(10) + ind2 + joindre(parts, "," + car(10) + ind2) + car(10) + ind + "]"
    finsi
    si nk = 0
      retourner "{}"
    finsi
    locale ks = clefs(v)
    trier(ks)
    pour chaque k dans ks
      inserer(parts, json(minuscule(chaine(k))) + ": " + JSONK(v[k], ind2))
    suivant
    retourner "{" + car(10) + ind2 + joindre(parts, "," + car(10) + ind2) + car(10) + ind + "}"
  fincas
retourner json(texte(v))

procedure ECRIRE_JSON(chemin, v)
  fichier.creerdossier(fichier.dossier(chemin))
  fichier.ecrire(chemin, JSONK(v, "") + car(10))
retourner

fonction LIRE_JSON(chemin, defaut)
  si non fichier.existe(chemin)
    retourner defaut
  finsi
  essayer
    retourner dejson(fichier.lire(chemin))
  capturer e
    JOURNAL("erreur", "JSON illisible : " + chemin + " (" + e + ")")
  finessayer
retourner defaut

fonction LIRE_TEXTE(chemin)
  si non fichier.existe(chemin)
    retourner ""
  finsi
  essayer
    retourner fichier.lire(chemin)
  capturer e
  finessayer
retourner ""

procedure ECRIRE_TEXTE(chemin, t)
  fichier.creerdossier(fichier.dossier(chemin))
  fichier.ecrire(chemin, t)
retourner

fonction MAINTENANT_ISO()
retourner systeme.date("%Y-%m-%d %H:%M:%S")

fonction NL()
retourner car(10)

&& identifiant lisible : minuscules sans accents, tirets ; unique dans la table existants
fonction IDENT(texte_, existants)
  locale base_ = pub.ancre(texte_)
  si base_ = "" ou base_ = "section"
    base_ = "element"
  finsi
  base_ = gauche(base_, 40)
  locale id = base_
  locale n = 2
  tantque existants <> nul et existants[id] <> nul
    id = base_ + "-" + n
    n += 1
  fintantque
retourner id

fonction COURT(s, n)
  si s = nul
    retourner ""
  finsi
  s = remplacertexte(remplacertexte(chaine(s), car(10), " "), car(13), "")
  si #s <= n
    retourner s
  finsi
retourner gauche(s, n - 1) + "…"

fonction PLURIEL(n, mot)
  si n = 1 ou n = 0
    retourner n + " " + mot
  finsi
  si finitpar(mot, "al")
    retourner n + " " + gauche(mot, #mot - 2) + "aux"
  finsi
retourner n + " " + mot + "s"

fonction LISTE_CONTIENT(l, v)
  si l = nul
    retourner faux
  finsi
  pour chaque x dans l
    si x = v
      retourner vrai
    finsi
  suivant
retourner faux

fonction RETIRER_VALEUR(l, v)
  locale r = {}
  pour chaque x dans l
    si x <> v
      inserer(r, x)
    finsi
  suivant
retourner r

&& n-ièmes occurrences : découpe « a, b ; c » en liste rognée
fonction LISTE_DE(texte_)
  locale r = {}
  si texte_ = nul
    retourner r
  finsi
  si type(texte_) = "table"
    retourner texte_
  finsi
  pour chaque p dans decouper(remplacertexte(chaine(texte_), ";", ","), ",")
    p = rogner(p)
    si p <> ""
      inserer(r, p)
    finsi
  suivant
retourner r

&& requête DuckDB paramétrée (0 à 8 paramètres)
fonction RQ(sql, p)
  locale n = sisinon(p = nul, 0, #p)
  faire cas
  cas n = 0
    retourner requete(sql)
  cas n = 1
    retourner requete(sql, p[1])
  cas n = 2
    retourner requete(sql, p[1], p[2])
  cas n = 3
    retourner requete(sql, p[1], p[2], p[3])
  cas n = 4
    retourner requete(sql, p[1], p[2], p[3], p[4])
  cas n = 5
    retourner requete(sql, p[1], p[2], p[3], p[4], p[5])
  cas n = 6
    retourner requete(sql, p[1], p[2], p[3], p[4], p[5], p[6])
  cas n = 7
    retourner requete(sql, p[1], p[2], p[3], p[4], p[5], p[6], p[7])
  fincas
retourner requete(sql, p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8])

procedure JOURNAL(niveau, message)
  essayer
    si PROJ <> nul et PROJ.dossier <> nul
      fichier.ajouter(fichier.joindre(PROJ.dossier, ".kaleido", "journal.txt"), MAINTENANT_ISO() + " [" + niveau + "] " + message + car(10))
    finsi
  capturer e
  finessayer
retourner

&& taille lisible
fonction OCTETS(n)
  faire cas
  cas n < 1024
    retourner n + " o"
  cas n < 1048576
    retourner arrondi(n / 1024, 1) + " Ko"
  fincas
retourner arrondi(n / 1048576, 1) + " Mo"

&& échappement XML (SVG)
fonction XML(s)
retourner remplacertexte(remplacertexte(remplacertexte(remplacertexte(chaine(s), "&", "&amp;"), "<", "&lt;"), ">", "&gt;"), '"', "&quot;")

&& lignes d'un texte
fonction LIGNES(t)
retourner decouper(remplacertexte(chaine(t), car(13), ""), car(10))

&& nombre de mots
fonction NB_MOTS(t)
  locale n = 0
  pour chaque l dans LIGNES(t)
    pour chaque m dans decouper(l, " ")
      si rogner(m) <> ""
        n += 1
      finsi
    suivant
  suivant
retourner n

&& listes déroulantes : valeur lue et fixée par le texte de l'élément
fonction COMBO_VAL(c, liste)
  locale i = nombre(c:selection())
  si i = nul ou i < 1 ou i > #liste
    retourner liste[1]
  finsi
retourner liste[i]

procedure COMBO_FIXER(c, liste, v)
  pour i = 1 a #liste
    si liste[i] = v
      c:selectionner(i)
      retourner
    finsi
  suivant
  c:selectionner(1)
retourner

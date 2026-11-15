&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : moteur de composition.
&&
&& Un document n'est pas un copier-coller : il référence des composants, résolus à chaque
&& aperçu et à chaque publication (recomposition dynamique).
&&   {{> id}}            composant (version standard, ou la variante active du document)
&&   {{> id@client}}     variante nommée
&&   {{> id#v3}}         version figée (historique) : la propagation ne la touche pas
&&   {{variable}}        variable du document (en-tête ---), du projet ou de la variante
&&   {{date}} {{heure}} {{projet}} {{auteur}} {{version}} {{titre}}
&&   {{toc}} {{index}} {{index:terme}} {{ref:ancre}} {{saut}}
&&   {{macro arg}}       macros des extensions (plugins)
&& Un composant texte peut lui-même référencer d'autres composants (cycles détectés).

&& en-tête « --- clé: valeur --- » : {variables, corps}
fonction ENTETE(texte_)
  locale vars = {}
  locale l = LIGNES(texte_)
  si #l > 0 et rogner(l[1]) = "---"
    pour i = 2 a #l
      si rogner(l[i]) = "---"
        locale corps = {}
        pour j = i + 1 a #l
          inserer(corps, l[j])
        suivant
        retourner {variables = vars, corps = joindre(corps, car(10)), lignes = i}
      finsi
      locale k = position(":", l[i])
      si k > 1
        vars[majuscule(rogner(gauche(l[i], k - 1)))] = rogner(souschaine(l[i], k + 1))
      finsi
    suivant
  finsi
retourner {variables = vars, corps = texte_, lignes = 0}

&& références {id, variante, version} d'un texte Markdown ou d'un SVG
fonction REFERENCES(texte_, ext)
  locale r = {}
  si texte_ = nul
    retourner r
  finsi
  si ext = "svg"
    locale reste = texte_
    locale k = position('data-composant="', reste)
    tantque k > 0
      reste = souschaine(reste, k + 16)
      locale f = position('"', reste)
      locale id = gauche(reste, f - 1)
      si id <> "" et non contient(id, "=") et COMPOSANT(PARTIE_ID(id)) <> nul
        inserer(r, REF_DE(id))
      finsi
      k = position('data-composant="', reste)
    fintantque
    retourner r
  finsi
  texte_ = HORS_CODE(texte_)
  locale reste = texte_
  locale k = position("{{>", reste)
  tantque k > 0
    reste = souschaine(reste, k + 3)
    locale f = position("}}", reste)
    si f = 0
      sortir
    finsi
    inserer(r, REF_DE(rogner(gauche(reste, f - 1))))
    k = position("{{>", reste)
  fintantque
  && images de la bibliothèque : ![...](composants/x.svg)
  reste = texte_
  k = position("composants/", reste)
  tantque k > 0
    reste = souschaine(reste, k + 11)
    locale f = 1
    tantque f <= #reste et non contient({".", "@", ")", '"', " "}, souschaine(reste, f, 1))
      f += 1
    fintantque
    locale id = gauche(reste, f - 1)
    si COMPOSANT(id) <> nul
      inserer(r, {id = minuscule(id), variante = "", version = ""})
    finsi
    k = position("composants/", reste)
  fintantque
retourner r

fonction PARTIE_ID(ref)
  locale id = ref
  si position("@", id) > 0
    id = gauche(id, position("@", id) - 1)
  finsi
  si position("#", id) > 0
    id = gauche(id, position("#", id) - 1)
  finsi
retourner minuscule(rogner(id))

fonction REF_DE(ref)
  locale v = ""
  locale ver = ""
  si position("#", ref) > 0
    ver = souschaine(ref, position("#", ref) + 1)
  finsi
  si position("@", ref) > 0
    v = souschaine(ref, position("@", ref) + 1)
    si position("#", v) > 0
      v = gauche(v, position("#", v) - 1)
    finsi
  finsi
retourner {id = PARTIE_ID(ref), variante = v, version = ver}

fonction REFERENCES_LIVRABLE(genre, nom)
  locale r = {}
  faire cas
  cas genre = "document"
    locale d = DOC(nom)
    si d <> nul
      r = REFERENCES(LIRE_TEXTE(d.chemin), "md")
    finsi
  cas genre = "presentation" ou genre = "storyboard"
    locale d = sisinon(genre = "presentation", PRESENTATION(nom), STORYBOARD(nom))
    si d <> nul
      locale items = sisinon(genre = "presentation", d.diapositives, d.scenes)
      pour chaque it dans sisinon(items = nul, {}, items)
        si it.svg <> nul
          pour chaque x dans REFERENCES(LIRE_TEXTE(CHEMIN(it.svg)), "svg")
            inserer(r, x)
          suivant
        finsi
        pour chaque m dans sisinon(it.medias = nul, {}, it.medias)
          si COMPOSANT(PARTIE_ID(m)) <> nul
            inserer(r, REF_DE(m))
          finsi
        suivant
      suivant
    finsi
  fincas
retourner r

&& compose un texte : renvoie {texte, problemes, utilises}
fonction COMPOSER(texte_, ctx)
  si ctx = nul
    ctx = {}
  finsi
  si ctx.pile = nul
    ctx.pile = {}
  finsi
  si ctx.problemes = nul
    ctx.problemes = {}
  finsi
  si ctx.utilises = nul
    ctx.utilises = {}
  finsi
  si ctx.variables = nul
    locale e = ENTETE(texte_)
    ctx.variables = {}
    texte_ = e.corps
    && les valeurs de l'en-tête peuvent elles-mêmes utiliser variables et macros
    pour chaque k, v dans e.variables
      si contient(v, "{{")
        locale r = COMPOSER(v, {variante = ctx.variante, variables = ctx.variables, pile = ctx.pile, problemes = ctx.problemes, utilises = ctx.utilises})
        ctx.variables[k] = r.texte
      sinon
        ctx.variables[k] = v
      finsi
    suivant
  finsi
  && le code (blocs ``` et `segments`) reste littéral : on y montre la syntaxe sans l'exécuter
  locale sortie = ""
  locale blocs = decouper(texte_, "```")
  pour i = 1 a #blocs
    si i > 1
      sortie = sortie + "```"
    finsi
    si i % 2 = 0
      sortie = sortie + blocs[i]
    sinon
      locale segs = decouper(blocs[i], "`")
      pour j = 1 a #segs
        si j > 1
          sortie = sortie + "`"
        finsi
        sortie = sortie + sisinon(j % 2 = 0, segs[j], COMPOSER_SEGMENT(segs[j], ctx))
      suivant
    finsi
  suivant
retourner {texte = sortie, problemes = ctx.problemes, utilises = ctx.utilises, variables = ctx.variables}

&& texte sans code : chaque {{…}} est résolu
fonction COMPOSER_SEGMENT(texte_, ctx)
  locale sortie = ""
  locale reste = texte_
  locale k = position("{{", reste)
  tantque k > 0
    sortie = sortie + gauche(reste, k - 1)
    reste = souschaine(reste, k + 2)
    locale f = position("}}", reste)
    si f = 0
      sortie = sortie + "{{"
      sortir
    finsi
    locale jeton = rogner(gauche(reste, f - 1))
    reste = souschaine(reste, f + 2)
    sortie = sortie + RESOUDRE(jeton, ctx)
    k = position("{{", reste)
  fintantque
retourner sortie + reste

&& texte sans le code (pour la recherche des références)
fonction HORS_CODE(texte_)
  locale r = ""
  locale blocs = decouper(texte_, "```")
  pour i = 1 a #blocs
    si i % 2 = 1
      locale segs = decouper(blocs[i], "`")
      pour j = 1 a #segs
        si j % 2 = 1
          r = r + segs[j] + " "
        finsi
      suivant
    finsi
  suivant
retourner r

fonction RESOUDRE(jeton, ctx)
  locale mj = minuscule(jeton)
  && composant
  si commencepar(jeton, ">")
    locale ref = REF_DE(rogner(souschaine(jeton, 2)))
    locale c = COMPOSANT(ref.id)
    si c = nul
      inserer(ctx.problemes, "Composant introuvable : " + ref.id)
      retourner "**[composant introuvable : " + ref.id + "]**"
    finsi
    si LISTE_CONTIENT(ctx.pile, c.id)
      inserer(ctx.problemes, "Cycle de composition : " + joindre(ctx.pile, " → ") + " → " + c.id)
      retourner "**[cycle : " + c.id + "]**"
    finsi
    si non LISTE_CONTIENT(ctx.utilises, c.id)
      inserer(ctx.utilises, c.id)
    finsi
    locale variante = ref.variante
    si variante = "" et ctx.variante <> nul et LISTE_CONTIENT(c.variantes, ctx.variante)
      variante = ctx.variante
    finsi
    si GENRE_TEXTE(c.genre)
      locale contenu = ""
      si ref.version <> ""
        contenu = CONTENU_VERSION(c, nombre(remplacertexte(minuscule(ref.version), "v", "")))
        si contenu = ""
          contenu = CONTENU_COMPOSANT(c, variante)
        finsi
      sinon
        contenu = CONTENU_COMPOSANT(c, variante)
      finsi
      inserer(ctx.pile, c.id)
      locale r = COMPOSER(contenu, ctx)
      retirer(ctx.pile)
      retourner r.texte
    finsi
    && illustration, logo, schéma, diapositive, scène : figure
    locale f = FICHIER_COMPOSANT(c, variante)
    si non fichier.existe(f)
      f = FICHIER_COMPOSANT(c, nul)
    finsi
    retourner car(10) + car(10) + "![" + c.titre + "](" + f + ")" + car(10) + car(10)
  finsi
  && macros intégrées
  faire cas
  cas mj = "date"
    retourner systeme.date("%d/%m/%Y")
  cas mj = "heure"
    retourner heure()
  cas mj = "projet"
    retourner PROJ.titre
  cas mj = "auteur"
    retourner sisinon(PROJ.auteur = nul, "", PROJ.auteur)
  cas mj = "toc" ou mj = "sommaire"
    retourner "[[toc]]"
  cas mj = "index"
    retourner "[[index]]"
  cas mj = "saut"
    retourner car(10) + "[[saut]]" + car(10)
  cas commencepar(mj, "index:")
    retourner "[[i:" + rogner(souschaine(jeton, 7)) + "]]"
  cas commencepar(mj, "ref:")
    retourner "[[ref:" + rogner(souschaine(jeton, 5)) + "]]"
  cas mj = "composants"
    retourner chaine(nbelements(COMPOSANTS))
  fincas
  && variables : document, variante, projet
  locale nomv = majuscule(jeton)
  si ctx.variables[nomv] <> nul
    retourner chaine(ctx.variables[nomv])
  finsi
  si ctx.variante <> nul et PROJ.variantes <> nul et PROJ.variantes[majuscule(ctx.variante)] <> nul
    locale vv = PROJ.variantes[majuscule(ctx.variante)]
    si vv[nomv] <> nul
      retourner chaine(vv[nomv])
    finsi
  finsi
  si PROJ.variables[nomv] <> nul
    retourner chaine(PROJ.variables[nomv])
  finsi
  && macros des extensions : {{nom argument}}
  locale sp = position(" ", jeton)
  locale nm = minuscule(sisinon(sp > 0, gauche(jeton, sp - 1), jeton))
  si MACROS[nm] <> nul
    essayer
      retourner chaine(appeler(MACROS[nm], rogner(sisinon(sp > 0, souschaine(jeton, sp + 1), "")), ctx))
    capturer e
      inserer(ctx.problemes, "Macro « " + nm + " » : " + e)
      retourner "**[macro " + nm + " : erreur]**"
    finessayer
  finsi
  inserer(ctx.problemes, "Variable inconnue : {{" + jeton + "}}")
retourner "{{" + jeton + "}}"

&& composition d'un document du projet : {texte, problemes, utilises, variables, gabarit}
fonction COMPOSER_DOCUMENT(d, texte_, variante)
  si texte_ = nul
    texte_ = LIRE_TEXTE(d.chemin)
  finsi
  locale r = COMPOSER(texte_, {variante = variante})
  locale g = copier(PROJ.gabarit)
  pour chaque k, v dans sisinon(d.meta = nul, {}, d.meta)
    si k <> "TITRE" et k <> "VARIANTE"
      g[k] = v
    finsi
  suivant
  g.titre = sisinon(r.variables.TITRE <> nul, r.variables.TITRE, sisinon(d.titre = nul, d.nom, d.titre))
  si r.variables.SOUSTITRE <> nul
    g.soustitre = r.variables.SOUSTITRE
  finsi
  g.auteur = sisinon(r.variables.AUTEUR <> nul, r.variables.AUTEUR, PROJ.auteur)
  si g.date = nul
    g.date = systeme.date("%B %Y")
  finsi
  g.dossier = fichier.dossier(d.chemin)
  r.gabarit = g
retourner r

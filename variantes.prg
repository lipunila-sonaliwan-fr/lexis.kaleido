&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : variantes, versions et branches (un « Git » simplifié).
&&
&& * Variante : autre contenu du même composant (standard, client, produit, marketing,
&&   pédagogique…) ; un document choisit sa variante, ou une référence la nomme (@client).
&& * Version : chaque enregistrement conserve la précédente (historique) ; restaurer,
&&   comparer, figer une référence (#v3).
&& * Branche : copie indépendante qui garde la trace de son origine (branche_de).

procedure CONSTRUIRE_VARIANTES(o)
  globale lvariantes, lversions, lbldiff
  locale h = o:ajouter(ui.colonne())
  h.ancrage = "haut"
  h.marge = 4
  locale l1 = h:ajouter(ui.etiquette("Variantes"))
  l1.couleur = "#A5B4FC"
  locale r = h:ajouter(ui.rangee())
  ICONE(r, "plus", "Nouvelle variante", "Créer une variante du composant", @VAR_NOUVELLE)
  ICONE(r, "ouvrir", "Ouvrir", "Ouvrir la variante choisie", @VAR_OUVRIR)
  ICONE(r, "k-up", "Promouvoir", "Faire de la variante la version standard", @VAR_PROMOUVOIR)
  ICONE(r, "supprimer", "Supprimer", "Supprimer la variante", @VAR_SUPPRIMER)
  ICONE(r, "k-branch", "Branche", "Créer une branche (copie indépendante)", @VAR_BRANCHE)
  lvariantes = h:ajouter(ui.liste())
  lvariantes.hauteurfixe = 130
  lvariantes.surdoubleclic = @VAR_OUVRIR
  locale l2 = h:ajouter(ui.etiquette("Historique des versions"))
  l2.couleur = "#A5B4FC"
  locale r2 = h:ajouter(ui.rangee())
  ICONE(r2, "k-history", "Restaurer", "Restaurer la version choisie (devient la version courante)", @VERS_RESTAURER)
  ICONE(r2, "k-split", "Comparer", "Comparer la version choisie à la version courante", @VERS_COMPARER)
  lversions = h:ajouter(ui.liste())
  lversions.hauteurfixe = 140
  lversions.surselection = @VERS_COMPARER
  lbldiff = o:ajouter(ui.markdown(""))
  lbldiff.ancrage = "centre"
retourner

procedure VARIANTES_RAFRAICHIR
  lvariantes:vider()
  lversions:vider()
  lbldiff.valeur = ""
  si SEL = nul ou SEL.genre <> "composant"
    retourner
  finsi
  locale c = COMPOSANT(SEL.id)
  si c = nul
    retourner
  finsi
  lvariantes:ajouter("standard")
  pour chaque v dans c.variantes
    lvariantes:ajouter(v)
  suivant
  lversions:ajouter("v" + (c.version + 1) + " · actuelle · " + c.modifie)
  pour chaque v dans VERSIONS(c)
    lversions:ajouter("v" + v.numero + " · " + v.date)
  suivant
  si c.branche_de <> nul
    lbldiff.valeur = "Branche de **" + NOM_ELEMENT("composant", c.branche_de) + "** (`" + c.branche_de + "`)."
  finsi
retourner

fonction VARIANTE_CHOISIE()
  locale i = nombre(lvariantes:selection())
  si i = nul ou i < 1
    retourner nul
  finsi
retourner lvariantes:element(i)

procedure CREER_VARIANTE_DIALOGUE(id, contenu)
  locale c = COMPOSANT(id)
  locale v = ui.demander("Nom de la variante (client, produit, marketing, pedagogique…) :", "client")
  si v = nul ou rogner(v) = ""
    retourner
  finsi
  v = pub.ancre(v)
  si contenu = nul
    contenu = CONTENU_COMPOSANT(c, nul)
  finsi
  ENREGISTRER_COMPOSANT(c, contenu, v)
  RAFRAICHIR_BIBLIOTHEQUE()
  SELECTIONNER("composant", c.id)
  STATUT("Variante « " + v + " » de « " + c.titre + " » créée : modifiez-la, elle ne touche que ses usages.")
  si GENRE_TEXTE(c.genre)
    OUVRIR_ESPACE("document")
    DOC_OUVRIR_COMPOSANT(c, v)
  sinon
    OUVRIR_ESPACE("dessin")
    DESSIN_OUVRIR_COMPOSANT(c, v)
  finsi
retourner

procedure CREER_BRANCHE(id, contenu)
  locale c = COMPOSANT(id)
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
  locale nid = ENREGISTRER_COMPOSANT(m, sisinon(contenu = nul, CONTENU_COMPOSANT(c, nul), contenu), nul)
  RAFRAICHIR_BIBLIOTHEQUE()
  SELECTIONNER("composant", nid)
  STATUT("Branche « " + t + " » créée ({{> " + nid + "}}).")
retourner

procedure VAR_NOUVELLE(ev)
  si SEL <> nul et SEL.genre = "composant"
    CREER_VARIANTE_DIALOGUE(SEL.id, nul)
  finsi
retourner

procedure VAR_BRANCHE(ev)
  si SEL <> nul et SEL.genre = "composant"
    CREER_BRANCHE(SEL.id, nul)
  finsi
retourner

procedure VAR_OUVRIR(ev)
  locale v = VARIANTE_CHOISIE()
  si v = nul ou SEL = nul
    retourner
  finsi
  locale c = COMPOSANT(SEL.id)
  locale var = sisinon(v = "standard", nul, v)
  si GENRE_TEXTE(c.genre)
    OUVRIR_ESPACE("document")
    DOC_OUVRIR_COMPOSANT(c, var)
  sinon
    OUVRIR_ESPACE("dessin")
    DESSIN_OUVRIR_COMPOSANT(c, var)
  finsi
retourner

procedure VAR_PROMOUVOIR(ev)
  locale v = VARIANTE_CHOISIE()
  si v = nul ou v = "standard"
    retourner
  finsi
  locale c = COMPOSANT(SEL.id)
  si ui.confirmer("La variante « " + v + " » devient la version standard de « " + c.titre + " » (l'actuelle est conservée dans l'historique). Continuer ?", "question")
    DEMANDER_IMPACT(c, CONTENU_COMPOSANT(c, v), nul, @VAR_APRES)
  finsi
retourner

procedure VAR_APRES(res)
  VARIANTES_RAFRAICHIR()
retourner

procedure VAR_SUPPRIMER(ev)
  locale v = VARIANTE_CHOISIE()
  si v = nul ou v = "standard"
    retourner
  finsi
  locale c = COMPOSANT(SEL.id)
  si ui.confirmer("Supprimer la variante « " + v + " » de « " + c.titre + " » ?", "attention")
    fichier.supprimer(FICHIER_COMPOSANT(c, v))
    c.variantes = RETIRER_VALEUR(c.variantes, v)
    ENREGISTRER_COMPOSANT(c, nul, nul)
    VARIANTES_RAFRAICHIR()
    RAFRAICHIR_BIBLIOTHEQUE()
  finsi
retourner

fonction VERSION_CHOISIE()
  locale i = nombre(lversions:selection())
  si i = nul ou i <= 1
    retourner nul
  finsi
  locale c = COMPOSANT(SEL.id)
retourner VERSIONS(c)[i - 1]

procedure VERS_RESTAURER(ev)
  locale v = VERSION_CHOISIE()
  si v = nul
    retourner
  finsi
  locale c = COMPOSANT(SEL.id)
  si ui.confirmer("Restaurer la version v" + v.numero + " de « " + c.titre + " » ?", "question")
    DEMANDER_IMPACT(c, LIRE_TEXTE(v.chemin), nul, @VAR_APRES)
  finsi
retourner

&& comparaison ligne à ligne (plus longue sous-suite commune)
procedure VERS_COMPARER(ev)
  locale v = VERSION_CHOISIE()
  si v = nul
    retourner
  finsi
  locale c = COMPOSANT(SEL.id)
  si non GENRE_TEXTE(c.genre)
    lbldiff.valeur = "Version v" + v.numero + " : " + OCTETS(#LIRE_TEXTE(v.chemin)) + " (comparaison visuelle : ouvrez-la dans l'éditeur SVG)."
    retourner
  finsi
  lbldiff.valeur = "### v" + v.numero + " → actuelle" + car(10) + car(10) + DIFF_MD(LIGNES(LIRE_TEXTE(v.chemin)), LIGNES(CONTENU_COMPOSANT(c, nul)))
retourner

fonction DIFF_MD(a, b)
  locale n = #a
  locale m = #b
  si n * m > 40000
    retourner "Textes trop longs pour une comparaison détaillée."
  finsi
  locale L = {}
  pour i = 1 a n + 1
    L[i] = {}
    pour j = 1 a m + 1
      L[i][j] = 0
    suivant
  suivant
  pour i = n a 1 pas -1
    pour j = m a 1 pas -1
      si a[i] = b[j]
        L[i][j] = L[i + 1][j + 1] + 1
      sinon
        L[i][j] = max(L[i + 1][j], L[i][j + 1])
      finsi
    suivant
  suivant
  locale out = {}
  locale i = 1
  locale j = 1
  tantque i <= n ou j <= m
    si i <= n et j <= m et a[i] = b[j]
      i += 1
      j += 1
    sinonsi j <= m et (i > n ou L[i][j + 1] >= L[i + 1][j])
      inserer(out, "- + `" + b[j] + "`")
      j += 1
    sinon
      inserer(out, "- − ~~" + a[i] + "~~")
      i += 1
    finsi
  fintantque
  si #out = 0
    retourner "Aucune différence."
  finsi
retourner joindre(out, car(10))

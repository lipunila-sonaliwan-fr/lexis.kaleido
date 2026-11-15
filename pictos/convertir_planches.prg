&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : convertir_planches.prg 
&& 
&& Convertit des planches SVG (pictogrammes dessinés dans des groupes
&& <g transform="translate(x y) scale(k)"> munis d'un <title>) en planches de symboles
&& importables par Kaléido : chaque pictogramme devient un <symbol> dans <defs>
&& (viewBox local, titre, attributs de style) et la planche l'affiche par un <use>
&& au même endroit : le fichier reste visuellement identique.
&&
&& Utilisation : wdlexisrt convertir_planches.prg <dossier source> <dossier destination>
&&
&& Traduction en Lexis+ de convertir_planches.py ; la boîte englobante de chaque
&& pictogramme est calculée par le moteur SVG de Kaléido (publication.boitesvg) :
&& le fichier bbox.json n'est plus nécessaire.

pub = paquet("publication")

PRES = {"fill", "stroke", "stroke-width", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit", ;
        "stroke-dasharray", "opacity", "fill-rule"}
GEOMETRIE = {"d", "cx", "cy", "r", "rx", "ry", "x", "y", "width", "height", "points"}

PRINCIPAL()

procedure PRINCIPAL
  locale src = systeme.args[1]
  locale dst = systeme.args[2]
  si src = nul ou dst = nul
    ? "Utilisation : wdlexisrt convertir_planches.prg <dossier source> <dossier destination>"
    systeme.quitter(1)
  finsi
  fichier.creerdossier(dst)
  locale noms = fichier.liste(src)
  trier(noms)
  locale total = 0
  pour chaque f dans noms
    si non finitpar(minuscule(f), ".svg")
      boucler
    finsi
    locale rapport = CONVERTIR(fichier.joindre(src, f), fichier.joindre(dst, f))
    total += #rapport
    locale titres = {}
    pour chaque r dans rapport
      inserer(titres, r.nom)
    suivant
    ? f, #rapport, "symboles :", joindre(titres, ", ")
  suivant
  ? "total", total
retourner

&& =================================================================== XML minimal
&& Nœuds : {genre = "element", nom, attrs = {{nom, valeur}...}, enfants, parent}
&&         {genre = "texte" | "brut", texte}  (brut : commentaire, déclaration, CDATA)
&& Les valeurs et les textes restent tels qu'écrits dans le fichier (entités comprises).

fonction XML_LIRE(src)
  locale morceaux = decouper(src, "<")
  locale doc = {genre = "document", enfants = {}}
  locale pile = {doc}
  XML_TEXTE(pile, morceaux[1])
  locale i = 2
  tantque i <= #morceaux
    locale m = morceaux[i]
    i += 1
    si commencepar(m, "!--") ou commencepar(m, "![CDATA[")
      locale fin_ = sisinon(commencepar(m, "!--"), "-->", "]]>")
      tantque position(fin_, m) = 0 et i <= #morceaux
        m = m + "<" + morceaux[i]
        i += 1
      fintantque
      locale p = position(fin_, m) + #fin_ - 1
      XML_AJOUTER(pile, {genre = "brut", texte = "<" + gauche(m, p)})
      XML_TEXTE(pile, souschaine(m, p + 1))
    sinonsi commencepar(m, "?") ou commencepar(m, "!")
      locale p = position(">", m)
      XML_AJOUTER(pile, {genre = "brut", texte = "<" + gauche(m, p)})
      XML_TEXTE(pile, souschaine(m, p + 1))
    sinonsi commencepar(m, "/")
      locale p = position(">", m)
      si #pile > 1
        retirer(pile)
      finsi
      XML_TEXTE(pile, souschaine(m, p + 1))
    sinon
      && un « < » dans une valeur d'attribut a coupé la balise : on recolle
      locale fin_ = XML_FIN_BALISE(m)
      tantque fin_ = 0 et i <= #morceaux
        m = m + "<" + morceaux[i]
        i += 1
        fin_ = XML_FIN_BALISE(m)
      fintantque
      locale corps = rognerd(gauche(m, fin_ - 1))
      locale auto_ = finitpar(corps, "/")
      si auto_
        corps = gauche(corps, #corps - 1)
      finsi
      locale el = XML_BALISE(corps)
      XML_AJOUTER(pile, el)
      si non auto_
        inserer(pile, el)
      finsi
      XML_TEXTE(pile, souschaine(m, fin_ + 1))
    finsi
  fintantque
retourner doc

fonction XML_FIN_BALISE(m)
  && position du « > » qui ferme la balise, hors guillemets (0 si absent)
  locale q = ""
  pour k = 1 a #m
    locale c = souschaine(m, k, 1)
    si q <> ""
      si c = q
        q = ""
      finsi
    sinonsi c = '"' ou c = "'"
      q = c
    sinonsi c = ">"
      retourner k
    finsi
  suivant
retourner 0

fonction XML_BALISE(corps)
  && « nom attr="valeur" ... » -> élément
  locale el = {genre = "element", nom = "", attrs = {}, enfants = {}}
  locale n = #corps
  locale k = 1
  tantque k <= n et non BLANC(souschaine(corps, k, 1))
    k += 1
  fintantque
  el.nom = gauche(corps, k - 1)
  tantque k <= n
    tantque k <= n et BLANC(souschaine(corps, k, 1))
      k += 1
    fintantque
    si k > n
      sortir
    finsi
    locale d = k
    tantque k <= n et souschaine(corps, k, 1) <> "=" et non BLANC(souschaine(corps, k, 1))
      k += 1
    fintantque
    locale nom_ = souschaine(corps, d, k - d)
    tantque k <= n et souschaine(corps, k, 1) <> "="
      k += 1
    fintantque
    k += 1
    tantque k <= n et BLANC(souschaine(corps, k, 1))
      k += 1
    fintantque
    locale q = souschaine(corps, k, 1)
    locale reste = souschaine(corps, k + 1)
    locale p = position(q, reste)
    si p = 0
      p = #reste + 1
    finsi
    inserer(el.attrs, {nom = nom_, valeur = gauche(reste, p - 1)})
    k = k + 1 + p
  fintantque
retourner el

fonction BLANC(c)
retourner c = " " ou c = car(10) ou c = car(13) ou c = car(9)

procedure XML_AJOUTER(pile, n)
  locale parent = pile[#pile]
  n.parent = parent
  inserer(parent.enfants, n)
retourner

procedure XML_TEXTE(pile, t)
  si t <> nul et t <> ""
    XML_AJOUTER(pile, {genre = "texte", texte = t})
  finsi
retourner

fonction XML_ECRIRE(n)
  locale parts = {}
  XML_SERIALISER(n, parts)
retourner joindre(parts, "")

procedure XML_SERIALISER(n, parts)
  faire cas
  cas n.genre = "texte" ou n.genre = "brut"
    inserer(parts, n.texte)
  cas n.genre = "document"
    pour chaque e dans n.enfants
      XML_SERIALISER(e, parts)
    suivant
  autrement
    inserer(parts, "<" + n.nom)
    pour chaque a dans n.attrs
      inserer(parts, " " + a.nom + '="' + a.valeur + '"')
    suivant
    si #n.enfants = 0
      inserer(parts, "/>")
    sinon
      inserer(parts, ">")
      pour chaque e dans n.enfants
        XML_SERIALISER(e, parts)
      suivant
      inserer(parts, "</" + n.nom + ">")
    finsi
  fincas
retourner

fonction ELEMENT(nom_)
retourner {genre = "element", nom = nom_, attrs = {}, enfants = {}}

fonction ATTR(el, nom_)
  pour chaque a dans el.attrs
    si a.nom = nom_
      retourner a.valeur
    finsi
  suivant
retourner nul

procedure FIXER(el, nom_, v)
  pour chaque a dans el.attrs
    si a.nom = nom_
      a.valeur = v
      retourner
    finsi
  suivant
  inserer(el.attrs, {nom = nom_, valeur = v})
retourner

procedure ENLEVER_ATTR(el, nom_)
  pour i = #el.attrs a 1 pas -1
    si el.attrs[i].nom = nom_
      retirer(el.attrs, i)
    finsi
  suivant
retourner

fonction ENFANT(el, nom_)
  pour chaque e dans el.enfants
    si e.genre = "element" et e.nom = nom_
      retourner e
    finsi
  suivant
retourner nul

fonction ELEMENTS(n, nom_, liste)
  && descendants (ordre du document) ; nom_ = nul : tous les éléments
  si liste = nul
    liste = {}
  finsi
  pour chaque e dans n.enfants
    si e.genre = "element"
      si nom_ = nul ou e.nom = nom_
        inserer(liste, e)
      finsi
      ELEMENTS(e, nom_, liste)
    finsi
  suivant
retourner liste

fonction INDICE(parent, n)
  pour i = 1 a #parent.enfants
    si parent.enfants[i] = n
      retourner i
    finsi
  suivant
retourner 0

procedure REMPLACER(ancien, nouveau)
  locale p = ancien.parent
  locale i = INDICE(p, ancien)
  p.enfants[i] = nouveau
  nouveau.parent = p
retourner

procedure INSERER_APRES(ref, n)
  locale p = ref.parent
  inserer(p.enfants, n, INDICE(p, ref) + 1)
  n.parent = p
retourner

procedure ADOPTER(parent, n)
  locale ancien = n.parent
  si ancien <> nul
    locale i = INDICE(ancien, n)
    si i > 0
      retirer(ancien.enfants, i)
    finsi
  finsi
  n.parent = parent
  inserer(parent.enfants, n)
retourner

fonction TEXTE_DE(el)
  locale t = ""
  pour chaque e dans el.enfants
    si e.genre = "texte"
      t = t + e.texte
    finsi
  suivant
retourner t

&& =================================================================== nombres
fonction FMT(v)
  && 3 décimales au plus, sans zéros inutiles
  locale r = arrondi(v, 3)
  si r = 0
    retourner "0"
  finsi
retourner chaine(r)

fonction NOMBRES(s)
  && nombres d'un texte (attributs transform, points…)
  locale res = {}
  pour chaque t dans JETONS(s)
    si non LETTRE(t)
      inserer(res, nombre(t))
    finsi
  suivant
retourner res

fonction LETTRE(t)
retourner #t = 1 et minuscule(t) <> majuscule(t)

fonction JETONS(d)
  && découpe un attribut d (ou une liste de nombres) en commandes et nombres,
  && comme l'expression [MmLl…Zz]|-?\d*\.?\d+(?:e-?\d+)?
  locale res = {}
  locale cur = ""
  locale point = faux
  locale k = 1
  locale n = #d
  tantque k <= n
    locale c = souschaine(d, k, 1)
    si c >= "0" et c <= "9"
      cur = cur + c
    sinonsi c = "."
      si point
        inserer(res, cur)
        cur = ""
      finsi
      cur = cur + c
      point = vrai
    sinonsi c = "-"
      si cur <> "" et cur <> "-"
        inserer(res, cur)
      finsi
      cur = "-"
      point = faux
    sinonsi (c = "e" ou c = "E") et cur <> "" et cur <> "-"
      && exposant
      cur = cur + "e"
      si souschaine(d, k + 1, 1) = "-"
        cur = cur + "-"
        k += 1
      finsi
    sinon
      si cur <> "" et cur <> "-"
        inserer(res, cur)
      finsi
      cur = ""
      point = faux
      si minuscule(c) <> majuscule(c)
        inserer(res, c)
      finsi
    finsi
    k += 1
  fintantque
  si cur <> "" et cur <> "-"
    inserer(res, cur)
  finsi
retourner res

fonction TRANSFORMATION(t)
  && « translate(x y) scale(k) » -> {tx, ty, k}, sinon nul
  si t = nul
    retourner nul
  finsi
  locale s = rogner(t)
  si non commencepar(s, "translate(")
    retourner nul
  finsi
  locale p = position(")", s)
  si p = 0
    retourner nul
  finsi
  locale a = NOMBRES(souschaine(s, 11, p - 11))
  locale reste = rogner(souschaine(s, p + 1))
  si #a <> 2 ou non commencepar(reste, "scale(") ou non finitpar(reste, ")")
    retourner nul
  finsi
  locale b = NOMBRES(souschaine(reste, 7, #reste - 7))
  si #b <> 1
    retourner nul
  finsi
retourner {tx = a[1], ty = a[2], k = b[1]}

fonction TITRE(lab)
  lab = rogner(lab)
  si lab = ""
    retourner lab
  finsi
retourner majuscule(gauche(lab, 1)) + souschaine(lab, 2)

fonction CONTEXTE(sid, lab)
  && libellés trop courts hors de leur planche : préciser la famille
  si commencepar(sid, "p5-fleche-")
    retourner "flèche " + lab
  finsi
  si commencepar(sid, "p5-direction-")
    retourner "direction " + lab
  finsi
  si commencepar(sid, "p5-connecteur-") et non commencepar(lab, "terminaison")
    retourner "connecteur " + lab
  finsi
retourner lab

&& découpe rectangulaire (clip-path)
&& Kaléido ne gère pas clip-path : les formes découpées sont recalculées
&& (remplissage découpé sans contour + contour d'origine limité au rectangle).

fonction QUAD(p0, p1, p2, n)
  locale res = {}
  pour i = 1 a n
    locale t = i / n
    inserer(res, {(1 - t) ^ 2 * p0[1] + 2 * t * (1 - t) * p1[1] + t * t * p2[1], ;
                  (1 - t) ^ 2 * p0[2] + 2 * t * (1 - t) * p1[2] + t * t * p2[2]})
  suivant
retourner res

fonction CUBIQUE(p0, p1, p2, p3, n)
  locale res = {}
  pour i = 1 a n
    locale t = i / n
    locale a = (1 - t) ^ 3, b = 3 * t * (1 - t) ^ 2, c = 3 * t * t * (1 - t), d = t ^ 3
    inserer(res, {a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1], a * p0[2] + b * p1[2] + c * p2[2] + d * p3[2]})
  suivant
retourner res

procedure AJOUTER_TOUS(liste, pts)
  pour chaque p dans pts
    inserer(liste, p)
  suivant
retourner

fonction POLYGONES_CHEMIN(d)
  locale toks = JETONS(d)
  locale polys = {}
  locale cur = {}
  locale pos = {0, 0}
  locale debut_ = {0, 0}
  locale cmd = nul
  locale i = 1
  tantque i <= #toks
    si LETTRE(toks[i])
      cmd = toks[i]
      i += 1
    finsi
    si cmd = "Z" ou cmd = "z"
      si #cur > 0
        inserer(polys, cur)
        cur = {}
      finsi
      pos = debut_
      boucler
    finsi
    locale rel = (cmd = minuscule(cmd))
    locale C = majuscule(cmd)
    locale ox = sisinon(rel, pos[1], 0)
    locale oy = sisinon(rel, pos[2], 0)
    faire cas
    cas C = "M"
      si #cur > 0
        inserer(polys, cur)
      finsi
      pos = {ox + nombre(toks[i]), oy + nombre(toks[i + 1])}
      i += 2
      debut_ = pos
      cur = {pos}
      cmd = sisinon(rel, "l", "L")
    cas C = "L"
      pos = {ox + nombre(toks[i]), oy + nombre(toks[i + 1])}
      i += 2
      inserer(cur, pos)
    cas C = "H"
      pos = {sisinon(rel, pos[1], 0) + nombre(toks[i]), pos[2]}
      i += 1
      inserer(cur, pos)
    cas C = "V"
      pos = {pos[1], sisinon(rel, pos[2], 0) + nombre(toks[i])}
      i += 1
      inserer(cur, pos)
    cas C = "Q"
      locale p1 = {ox + nombre(toks[i]), oy + nombre(toks[i + 1])}
      locale p2 = {ox + nombre(toks[i + 2]), oy + nombre(toks[i + 3])}
      i += 4
      AJOUTER_TOUS(cur, QUAD(pos, p1, p2, 24))
      pos = p2
    cas C = "C"
      locale p1 = {ox + nombre(toks[i]), oy + nombre(toks[i + 1])}
      locale p2 = {ox + nombre(toks[i + 2]), oy + nombre(toks[i + 3])}
      locale p3 = {ox + nombre(toks[i + 4]), oy + nombre(toks[i + 5])}
      i += 6
      AJOUTER_TOUS(cur, CUBIQUE(pos, p1, p2, p3, 32))
      pos = p3
    autrement
      erreur("commande de chemin non gérée : " + cmd)
    fincas
  fintantque
  si #cur > 0
    inserer(polys, cur)
  finsi
retourner polys

fonction NUM(el, nom_)
  locale v = ATTR(el, nom_)
retourner sisinon(v = nul, 0, nombre(v))

fonction POLYGONES_FORME(el)
  faire cas
  cas el.nom = "path"
    retourner POLYGONES_CHEMIN(ATTR(el, "d"))
  cas el.nom = "circle" ou el.nom = "ellipse"
    locale cx = NUM(el, "cx"), cy = NUM(el, "cy")
    locale rx = sisinon(ATTR(el, "r") <> nul, NUM(el, "r"), NUM(el, "rx"))
    locale ry = sisinon(ATTR(el, "r") <> nul, NUM(el, "r"), NUM(el, "ry"))
    locale pts = {}
    pour k = 0 a 95
      inserer(pts, {cx + rx * cos(2 * pi() * k / 96), cy + ry * sin(2 * pi() * k / 96)})
    suivant
    retourner {pts}
  cas el.nom = "rect"
    locale x = NUM(el, "x"), y = NUM(el, "y"), w = NUM(el, "width"), h = NUM(el, "height")
    retourner {{{x, y}, {x + w, y}, {x + w, y + h}, {x, y + h}}}
  cas el.nom = "polygon"
    locale v = NOMBRES(ATTR(el, "points"))
    locale pts = {}
    pour k = 1 a #v - 1 pas 2
      inserer(pts, {v[k], v[k + 1]})
    suivant
    retourner {pts}
  fincas
  erreur("forme non gérée dans un clip : " + el.nom)
retourner nul

&& Sutherland-Hodgman : polygone limité au rectangle
fonction DEDANS(p, cote, v)
  faire cas
  cas cote = 1
    retourner p[1] >= v
  cas cote = 2
    retourner p[1] <= v
  cas cote = 3
    retourner p[2] >= v
  fincas
retourner p[2] <= v

fonction INTERSECTION(a, b, cote, v)
  si cote <= 2
    retourner {v, a[2] + (b[2] - a[2]) * (v - a[1]) / (b[1] - a[1])}
  finsi
retourner {a[1] + (b[1] - a[1]) * (v - a[2]) / (b[2] - a[2]), v}

fonction DECOUPER_POLYGONE(poly, x0, y0, x1, y1)
  locale p = poly
  locale bornes = {x0, x1, y0, y1}
  pour cote = 1 a 4
    si #p = 0
      sortir
    finsi
    locale v = bornes[cote]
    locale res = {}
    pour k = 1 a #p
      locale a = p[sisinon(k = 1, #p, k - 1)]
      locale b = p[k]
      locale ia = DEDANS(a, cote, v), ib = DEDANS(b, cote, v)
      si ib
        si non ia
          inserer(res, INTERSECTION(a, b, cote, v))
        finsi
        inserer(res, b)
      sinonsi ia
        inserer(res, INTERSECTION(a, b, cote, v))
      finsi
    suivant
    p = res
  suivant
retourner p

&& Liang-Barsky : segment [a, b] limité au rectangle, ou nul
fonction DECOUPER_SEGMENT(a, b, x0, y0, x1, y1)
  locale dx = b[1] - a[1], dy = b[2] - a[2]
  locale t0 = 0, t1 = 1
  locale ps = {-dx, dx, -dy, dy}
  locale qs = {a[1] - x0, x1 - a[1], a[2] - y0, y1 - a[2]}
  pour j = 1 a 4
    si abs(ps[j]) < 1e-12
      si qs[j] < 0
        retourner nul
      finsi
    sinon
      locale r = qs[j] / ps[j]
      si ps[j] < 0
        t0 = max(t0, r)
      sinon
        t1 = min(t1, r)
      finsi
    finsi
  suivant
  si t0 > t1
    retourner nul
  finsi
retourner {{a[1] + t0 * dx, a[2] + t0 * dy}, {a[1] + t1 * dx, a[2] + t1 * dy}}

fonction CHEMIN_DE(polys, fermer)
  locale morceaux = {}
  pour chaque p dans polys
    si #p >= sisinon(fermer, 3, 2)
      locale pts = {}
      pour chaque q dans p
        inserer(pts, FMT(q[1]) + "," + FMT(q[2]))
      suivant
      inserer(morceaux, "M" + joindre(pts, " L") + sisinon(fermer, " Z", ""))
    finsi
  suivant
retourner joindre(morceaux, " ")

procedure APLATIR_DECOUPES(sym)
  && remplace <g clip-path="url(#c)"> par des chemins découpés ; supprime les <clipPath>
  locale clips = {}
  pour chaque c dans ELEMENTS(sym, "clipPath")
    clips[ATTR(c, "id")] = c
  suivant
  pour chaque g dans ELEMENTS(sym, "g")
    locale ref = ATTR(g, "clip-path")
    si ref = nul
      boucler
    finsi
    locale cid = souschaine(ref, 6, #ref - 6)
    locale rects = {}
    pour chaque e dans clips[cid].enfants
      si e.genre = "element" et e.nom = "rect"
        inserer(rects, e)
      finsi
    suivant
    si #rects <> 1
      erreur("clipPath non rectangulaire : " + cid)
    finsi
    locale x0 = NUM(rects[1], "x"), y0 = NUM(rects[1], "y")
    locale x1 = x0 + NUM(rects[1], "width"), y1 = y0 + NUM(rects[1], "height")
    ENLEVER_ATTR(g, "clip-path")
    pour chaque el dans copier(g.enfants)
      si el.genre <> "element"
        boucler
      finsi
      locale srcp = POLYGONES_FORME(el)
      locale polys = {}
      pour chaque p dans srcp
        inserer(polys, DECOUPER_POLYGONE(p, x0, y0, x1, y1))
      suivant
      && attributs hors géométrie
      locale garder = {}
      pour chaque a dans el.attrs
        si non contient(GEOMETRIE, a.nom)
          inserer(garder, a)
        finsi
      suivant
      && remplissage découpé, sans contour (le bord de découpe ne doit pas être tracé)
      locale remp = ELEMENT("path")
      pour chaque a dans garder
        FIXER(remp, a.nom, a.valeur)
      suivant
      FIXER(remp, "d", CHEMIN_DE(polys, vrai))
      FIXER(remp, "stroke", "none")
      REMPLACER(el, remp)
      && contour d'origine limité au rectangle : polylignes ouvertes
      locale trait = ATTR(el, "stroke") ou ATTR(g, "stroke") ou "inherit"
      si trait <> "none"
        locale segs = {}
        pour chaque p dans srcp
          locale run = {}
          pour k = 1 a #p
            locale c_ = DECOUPER_SEGMENT(p[sisinon(k = 1, #p, k - 1)], p[k], x0, y0, x1, y1)
            si c_ = nul
              si #run > 1
                inserer(segs, run)
              finsi
              run = {}
              boucler
            finsi
            si #run > 0 et abs(run[#run][1] - c_[1][1]) < 1e-6 et abs(run[#run][2] - c_[1][2]) < 1e-6
              inserer(run, c_[2])
            sinon
              si #run > 1
                inserer(segs, run)
              finsi
              run = {c_[1], c_[2]}
            finsi
          suivant
          si #run > 1
            inserer(segs, run)
          finsi
        suivant
        si #segs > 0
          locale st_ = ELEMENT("path")
          pour chaque a dans garder
            FIXER(st_, a.nom, a.valeur)
          suivant
          FIXER(st_, "fill", "none")
          FIXER(st_, "stroke-linecap", "butt")
          FIXER(st_, "d", CHEMIN_DE(segs, faux))
          INSERER_APRES(remp, st_)
        finsi
      finsi
    suivant
  suivant
  pour chaque c dans ELEMENTS(sym, "clipPath")
    locale p = c.parent
    retirer(p.enfants, INDICE(p, c))
  suivant
retourner

&& conversion d'une planche
fonction BOITE(g, contenu)
  && boîte des formes du pictogramme, dans son repère local (moteur SVG de Kaléido)
  locale style_ = ""
  pour chaque a dans PRES
    si ATTR(g, a) <> nul
      style_ = style_ + " " + a + '="' + ATTR(g, a) + '"'
    finsi
  suivant
  locale b = pub.boitesvg('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" ' + ;
                          'width="4096" height="4096"><g' + style_ + ">" + contenu + "</g></svg>")
  si b = nul
    retourner {x = 0, y = 0, largeur = 100, hauteur = 100}
  finsi
retourner b

procedure RENOMMER_IDS(sym, sid)
  && identifiants internes uniques à l'échelle de toutes les planches
  locale tous = ELEMENTS(sym, nul)
  pour chaque el dans tous
    locale ancien = ATTR(el, "id")
    si ancien = nul
      boucler
    finsi
    locale nouveau = sid + "-" + ancien
    FIXER(el, "id", nouveau)
    pour chaque e2 dans tous
      pour chaque a dans e2.attrs
        si a.valeur = "#" + ancien ou position("#" + ancien + ")", a.valeur) > 0
          a.valeur = remplacertexte(a.valeur, "#" + ancien, "#" + nouveau)
        finsi
      suivant
    suivant
  suivant
retourner

fonction CONVERTIR(src, dst)
  locale doc = XML_LIRE(fichier.lire(src))
  locale racine = nul
  pour chaque e dans doc.enfants
    si e.genre = "element" et e.nom = "svg"
      racine = e
    finsi
  suivant
  si racine = nul
    erreur(src + " : pas de racine <svg>")
  finsi
  locale defs = ENFANT(racine, "defs")
  si defs = nul
    defs = ELEMENT("defs")
    locale t = ENFANT(racine, "title")
    inserer(racine.enfants, defs, sisinon(t = nul, 1, INDICE(racine, t) + 1))
    defs.parent = racine
  finsi
  && pictogrammes : <g transform="translate() scale()"> avec un <title>
  locale syms = {}
  pour chaque g dans ELEMENTS(racine, "g")
    locale tr = TRANSFORMATION(ATTR(g, "transform"))
    locale tt = ENFANT(g, "title")
    si tr <> nul et tt <> nul
      locale lab = TEXTE_DE(tt)
      si rogner(lab) = ""
        lab = ATTR(g, "inkscape:label") ou ATTR(g, "id")
      finsi
      inserer(syms, {g = g, tr = tr, tt = tt, nom = TITRE(CONTEXTE(ATTR(g, "id"), lab))})
    finsi
  suivant
  && titres en double dans une même planche : préciser par le libellé du groupe parent
  locale vus = {}
  pour chaque s dans syms
    vus[s.nom] = (vus[s.nom] ou 0) + 1
  suivant
  locale rapport = {}
  pour chaque s dans syms
    locale g = s.g
    locale sid = ATTR(g, "id")
    locale nom_ = s.nom
    si vus[nom_] > 1
      locale par = ATTR(g.parent, "inkscape:label") ou ATTR(g.parent, "id")
      nom_ = nom_ + " (" + minuscule(gauche(par, 1)) + souschaine(par, 2) + ")"
    finsi
    && contenu du pictogramme (sans son titre) et boîte englobante
    locale parts = {}
    pour chaque e dans g.enfants
      si e <> s.tt
        XML_SERIALISER(e, parts)
      finsi
    suivant
    locale b = BOITE(g, joindre(parts, ""))
    locale marge = 3                              && demi-épaisseur de trait max et marge
    locale x0 = min(0, plancher(b.x - marge)), y0 = min(0, plancher(b.y - marge))
    locale x1 = max(100, plafond(b.x + b.largeur + marge)), y1 = max(100, plafond(b.y + b.hauteur + marge))
    && le <symbol>
    locale sym = ELEMENT("symbol")
    FIXER(sym, "id", sid)
    FIXER(sym, "viewBox", FMT(x0) + " " + FMT(y0) + " " + FMT(x1 - x0) + " " + FMT(y1 - y0))
    pour chaque a dans PRES
      si ATTR(g, a) <> nul
        FIXER(sym, a, ATTR(g, a))
      finsi
    suivant
    locale ti = ELEMENT("title")
    ADOPTER(ti, {genre = "texte", texte = nom_})
    ADOPTER(sym, ti)
    pour chaque e dans copier(g.enfants)
      si e <> s.tt
        ADOPTER(sym, e)
      finsi
    suivant
    ADOPTER(defs, sym)
    RENOMMER_IDS(sym, sid)
    APLATIR_DECOUPES(sym)
    && le <use> qui l'affiche à la place du groupe
    locale k = s.tr.k
    locale u = ELEMENT("use")
    FIXER(u, "href", "#" + sid)
    FIXER(u, "xlink:href", "#" + sid)
    FIXER(u, "x", FMT(s.tr.tx + x0 * k))
    FIXER(u, "y", FMT(s.tr.ty + y0 * k))
    FIXER(u, "width", FMT((x1 - x0) * k))
    FIXER(u, "height", FMT((y1 - y0) * k))
    si ATTR(g, "inkscape:label") <> nul
      FIXER(u, "inkscape:label", ATTR(g, "inkscape:label"))
    finsi
    REMPLACER(g, u)
    inserer(rapport, {id = sid, nom = nom_})
  suivant
  && espace de noms xlink déclaré sur la racine
  si ATTR(racine, "xmlns:xlink") = nul
    FIXER(racine, "xmlns:xlink", "http://www.w3.org/1999/xlink")
  finsi
  INSERER_APRES(defs, {genre = "brut", texte = "<!-- Planche de symboles Kaléido : " + #rapport + ;
                       " <symbol> dans <defs>, affichés par <use>. Import : Fichier > Importer une planche de symboles SVG… -->"})
  fichier.ecrire(dst, XML_ECRIRE(doc))
retourner rapport

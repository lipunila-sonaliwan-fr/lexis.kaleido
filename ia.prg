&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : intelligence assistée.
&&
&& Architecture : chaque tâche (générer, reformuler, traduire, résumer, synthétiser, illustrer,
&& rechercher, proposer une réutilisation, détecter doublons et incohérences) passe par
&& IA_TACHE(tache, texte, consigne) ; avec un modèle local GGUF (paquet llm, réglage
&& « modele_ia »), le modèle répond ; sinon des méthodes déterministes prennent le relais quand
&& c'est possible (résumé extractif, recherche lexicale, schéma SVG, doublons par similarité,
&& vérifications de cohérence). Les extensions peuvent fournir d'autres moteurs.

procedure CONSTRUIRE_IA(o)
  globale ia_action, ia_consigne, ia_resultat, IA
  IA = {modele = nul, dernier = "", empreintes = {}, propose = ""}
  locale h = o:ajouter(ui.colonne())
  h.ancrage = "haut"
  h.marge = 4
  h.espacement = 4
  ia_action = h:ajouter(ui.combo())
  pour chaque a dans IA_ACTIONS()
    ia_action:ajouter(a)
  suivant
  ia_action:selectionner(1)
  ia_consigne = h:ajouter(ui.saisie{multiligne = vrai, indication = "Consigne ou texte (sinon : la sélection de l'éditeur)"})
  ia_consigne.hauteurfixe = 90
  locale r = h:ajouter(ui.rangee())
  OUTIL(r, "✦ Exécuter", @IA_EXECUTER, "Lancer la tâche")
  OUTIL(r, "Insérer", @IA_INSERER, "Insérer le résultat dans l'éditeur courant")
  OUTIL(r, "Composant", @IA_COMPOSANT, "Faire du résultat un composant")
  OUTIL(r, "Modèle…", @IA_MODELE, "Choisir un modèle local GGUF")
  ia_resultat = o:ajouter(ui.markdown(IA_ACCUEIL()))
  ia_resultat.ancrage = "centre"
retourner

fonction IA_ACCUEIL()
  locale n = car(10)
retourner "### ✦ Assistant" + n + n + "Modèle : " + sisinon(reglages.modele_ia = nul ou reglages.modele_ia = "", "*aucun* (méthodes intégrées : résumé, recherche, schéma SVG, doublons, cohérence)", "`" + fichier.nom(reglages.modele_ia) + "`") + n + n + ;
  "Choisissez une tâche, écrivez une consigne (ou sélectionnez un texte dans l'éditeur), puis **Exécuter**."

procedure IA_OUVRIR(ev)
  droite.valeur = 4
  ia_consigne:focus()
retourner

procedure IA_MODELE(ev)
  locale f = ui.ouvrirfichier{titre = "Modèle de langage GGUF", filtre = "Modèles GGUF|*.gguf"}
  si f <> nul
    reglages.modele_ia = f
    ECRIRE_REGLAGES()
    IA.modele = nul
    ia_resultat.valeur = IA_ACCUEIL()
  finsi
retourner

fonction IA_MODELE_CHARGE()
  si IA.modele <> nul
    retourner IA.modele
  finsi
  si reglages.modele_ia = nul ou reglages.modele_ia = "" ou non fichier.existe(reglages.modele_ia)
    retourner nul
  finsi
  essayer
    IA.modele = llm.charger(reglages.modele_ia)
  capturer e
    STATUT("Modèle illisible : " + e)
    IA.modele = nul
  finessayer
retourner IA.modele

fonction IA_DEMANDER(systeme_, texte_)
  locale m = IA_MODELE_CHARGE()
  si m = nul
    retourner nul
  finsi
  locale c = m:conversation({systeme = systeme_, contexte = 4096, maxtokens = 900, langue = "fr"})
retourner c:demander(texte_).texte

procedure IA_EXECUTER(ev)
  locale a = COMBO_VAL(ia_action, IA_ACTIONS())
  locale consigne = rogner(ia_consigne.valeur)
  locale sel = ""
  essayer
    sel = ed:selection()
  capturer e
  finessayer
  locale entree = sisinon(sel <> nul et sel <> "", sel, consigne)
  STATUT("Assistant : " + a + "…")
  locale r = IA_TACHE(a, entree, consigne)
  IA.dernier = sisinon(r = nul, "", r)
  ia_resultat.valeur = sisinon(r = nul, "*Cette tâche demande un modèle de langage : bouton « Modèle… ».*", r)
  STATUT("Assistant : terminé.")
retourner

fonction IA_TACHE(a, texte_, consigne)
  locale n = car(10)
  faire cas
  cas a = "Générer un texte"
    retourner IA_DEMANDER("Tu écris des contenus documentaires clairs en Markdown, en français.", consigne)
  cas a = "Reformuler la sélection"
    retourner IA_DEMANDER("Reformule le texte en français, plus clair et plus concis, en gardant le Markdown et les {{…}}.", texte_)
  cas a = "Traduire (anglais)"
    retourner IA_DEMANDER("Translate into English. Keep Markdown and every {{…}} token unchanged.", texte_)
  cas a = "Résumer" ou a = "Synthèse du document"
    locale src = texte_
    si a = "Synthèse du document" ou src = ""
      src = ed:texte()
    finsi
    locale r = IA_DEMANDER("Résume en français en 5 points au plus.", src)
    si r = nul
      r = "#### Résumé (extractif)" + n + n + RESUME_EXTRACTIF(pub.textebrut(src), 5)
    finsi
    retourner r
  cas a = "Illustration SVG"
    locale r = IA_DEMANDER("Réponds uniquement par un SVG 800x450 propre (formes simples, texte Poppins) illustrant la demande.", consigne)
    locale svg = nul
    si r <> nul
      svg = dessin.extrairesvg(r)
    finsi
    si svg = nul
      svg = SCHEMA_SVG(consigne)
    finsi
    IA.svg = svg
    locale id = ENREGISTRER_COMPOSANT({titre = "Illustration : " + COURT(consigne, 40), genre = "schema", ext = "svg", dossier = "Assistant", tags = {"assistant"}}, svg, nul)
    RAFRAICHIR_BIBLIOTHEQUE()
    OUVRIR_ESPACE("dessin")
    DESSIN_OUVRIR_COMPOSANT(COMPOSANT(id), nul)
    retourner "Illustration créée : composant `" + id + "` (ouvert dans l'éditeur SVG)."
  cas a = "Rechercher des composants"
    locale md = "#### Composants pour « " + consigne + " »" + n + n
    locale k = 0
    pour chaque mot dans decouper(consigne, " ")
      si #mot > 2
        pour chaque l dans CHERCHER_COMPOSANTS(mot, "")
          si k < 15
            md = md + "- " + ICONE_GENRE(l.genre) + " **" + l.titre + "** `{{> " + l.id + "}}`" + n
            k += 1
          finsi
        suivant
      finsi
    suivant
    retourner sisinon(k = 0, md + "Aucun composant trouvé.", md)
  cas a = "Doublons"
    retourner DOUBLONS_MD()
  cas a = "Cohérence du projet"
    retourner COHERENCE_MD()
  fincas
retourner nul

&& résumé extractif : phrases les mieux notées (fréquence des mots significatifs)
fonction RESUME_EXTRACTIF(t, n)
  locale phrases = {}
  locale cur = ""
  pour chaque l dans LIGNES(t)
    pour chaque p dans decouper(remplacertexte(remplacertexte(l, "! ", ". "), "? ", ". "), ". ")
      si #rogner(p) > 30
        inserer(phrases, rogner(p))
      finsi
    suivant
  suivant
  locale freq = {}
  pour chaque p dans phrases
    pour chaque m dans decouper(minuscule(p), " ")
      si #m > 4
        freq[m] = sisinon(freq[m] = nul, 1, freq[m] + 1)
      finsi
    suivant
  suivant
  locale notes = {}
  locale i = 1
  pour chaque p dans phrases
    locale s = 0
    pour chaque m dans decouper(minuscule(p), " ")
      si freq[m] <> nul
        s += freq[m]
      finsi
    suivant
    inserer(notes, {i = i, s = s / max(1, NB_MOTS(p)) + sisinon(i <= 2, 0.5, 0), p = p})
    i += 1
  suivant
  trier(notes, @NOTE_DESC)
  locale choix = {}
  pour k = 1 a min(n, #notes)
    inserer(choix, notes[k])
  suivant
  trier(choix, @NOTE_ORDRE)
  locale r = ""
  pour chaque c dans choix
    r = r + "- " + c.p + "." + car(10)
  suivant
retourner sisinon(r = "", "Texte trop court pour être résumé.", r)

fonction NOTE_DESC(a, b)
retourner a.s > b.s
fonction NOTE_ORDRE(a, b)
retourner a.i < b.i

&& schéma SVG déterministe : « A, B, C » -> blocs reliés
fonction SCHEMA_SVG(consigne)
  locale items = LISTE_DE(remplacertexte(remplacertexte(consigne, "->", ","), "→", ","))
  si #items < 2
    items = {"Idée", "Conception", "Réalisation", "Publication"}
  finsi
  locale n = min(6, #items)
  locale W = 1200
  locale H = 420
  locale couleurs = {"#4F46E5", "#7C3AED", "#EC4899", "#0EA5E9", "#10B981", "#F59E0B"}
  locale bl = (W - 120 - (n - 1) * 50) / n
  locale svg = '<svg xmlns="http://www.w3.org/2000/svg" width="' + W + '" height="' + H + '"><rect id="fond" width="' + W + '" height="' + H + '" fill="#FFFFFF"/>'
  pour i = 1 a n
    locale x = 60 + (i - 1) * (bl + 50)
    svg = svg + '<rect x="' + x + '" y="150" width="' + bl + '" height="120" rx="18" fill="' + couleurs[i] + '" data-ombre="1"/>' + ;
          SVG_TEXTE(x + 12, 188, bl - 24, items[i], "Poppins", 22, "#FFFFFF", vrai, "middle", 1.15)
    si i < n
      svg = svg + '<path d="M ' + (x + bl + 8) + ' 210 L ' + (x + bl + 42) + ' 210" stroke="#334155" stroke-width="4" fill="none" data-fleche-fin="1"/>'
    finsi
  suivant
retourner svg + "</svg>"

&& similarité de Jaccard sur des triplets de mots
fonction EMPREINTE(t)
  locale mots = {}
  pour chaque m dans decouper(minuscule(pub.textebrut(t)), " ")
    m = rogner(m)
    si #m > 1
      inserer(mots, m)
    finsi
  suivant
  locale e = {}
  pour i = 1 a #mots - 2
    e[mots[i] + " " + mots[i + 1] + " " + mots[i + 2]] = vrai
  suivant
retourner e

fonction SIMILARITE(a, b)
  locale inter = 0
  locale na = nbelements(a)
  locale nb = nbelements(b)
  si na = 0 ou nb = 0
    retourner 0
  finsi
  pour chaque k, v dans a
    si b[k] <> nul
      inter += 1
    finsi
  suivant
retourner inter / (na + nb - inter)

fonction EMPREINTE_COMPOSANT(c)
  locale k = c.id + "|" + c.modifie
  si IA.empreintes[k] = nul
    IA.empreintes[k] = EMPREINTE(CONTENU_COMPOSANT(c, nul))
  finsi
retourner IA.empreintes[k]

&& proposition de réutilisation : un paragraphe du document ressemble-t-il à un composant ?
procedure IA_PROPOSER_REUTILISATION(texte_, x)
  si x = nul ou x.genre <> "document"
    retourner
  finsi
  locale meilleur = nul
  locale score = 0
  locale para = ""
  pour chaque p dans decouper(texte_, car(10) + car(10))
    si #p > 120 et non contient(p, "{{")
      locale e = EMPREINTE(p)
      pour chaque id, c dans COMPOSANTS
        si GENRE_TEXTE(c.genre)
          locale s = SIMILARITE(e, EMPREINTE_COMPOSANT(c))
          si s > score
            score = s
            meilleur = c
            para = p
          finsi
        finsi
      suivant
    finsi
  suivant
  si meilleur <> nul et score >= 0.45
    lblimpact.libelle = "♻ Un paragraphe ressemble à « " + meilleur.titre + " » (" + arrondi(score * 100) + " %) : remplacez-le par {{> " + meilleur.id + "}}"
    IA.propose = meilleur.id
  sinonsi commencepar(lblimpact.libelle, "♻")
    lblimpact.libelle = ""
  finsi
retourner

fonction DOUBLONS_MD()
  locale n = car(10)
  locale ids = {}
  pour chaque id, c dans COMPOSANTS
    si GENRE_TEXTE(c.genre)
      inserer(ids, c)
    finsi
  suivant
  locale md = "#### Doublons probables" + n + n
  locale k = 0
  pour i = 1 a #ids
    pour j = i + 1 a #ids
      locale s = SIMILARITE(EMPREINTE_COMPOSANT(ids[i]), EMPREINTE_COMPOSANT(ids[j]))
      si s >= 0.35
        md = md + "- **" + ids[i].titre + "** ≈ **" + ids[j].titre + "** (" + arrondi(s * 100) + " %) : fusionnez-les ou faites de l'un une variante de l'autre." + n
        k += 1
      finsi
    suivant
  suivant
  && documents : paragraphes recopiés au lieu d'être référencés
  pour chaque d dans DOCS
    pour chaque p dans decouper(LIRE_TEXTE(d.chemin), car(10) + car(10))
      si #p > 120 et non contient(p, "{{")
        locale e = EMPREINTE(p)
        pour chaque c dans ids
          locale s = SIMILARITE(e, EMPREINTE_COMPOSANT(c))
          si s >= 0.5
            md = md + "- ▤ **" + d.titre + "** recopie « " + c.titre + " » (" + arrondi(s * 100) + " %) : utilisez `{{> " + c.id + "}}`." + n
            k += 1
          finsi
        suivant
      finsi
    suivant
  suivant
retourner sisinon(k = 0, md + "Aucun doublon détecté.", md)

fonction COHERENCE_MD()
  locale n = car(10)
  locale md = "#### Vérification de cohérence" + n + n
  locale k = 0
  pour chaque d dans DOCS
    locale r = COMPOSER_DOCUMENT(d, nul, d.meta.variante)
    pour chaque p dans r.problemes
      md = md + "- ▤ **" + d.titre + "** : " + p + n
      k += 1
    suivant
    && hiérarchie des titres
    locale prec = 0
    pour chaque t dans pub.titres(r.texte)
      si prec > 0 et t.niveau > prec + 1
        md = md + "- ▤ **" + d.titre + "** : saut de niveau de titre avant « " + t.texte + " » (h" + prec + " → h" + t.niveau + ")." + n
        k += 1
      finsi
      prec = t.niveau
    suivant
    && images sans texte de remplacement
    si contient(r.texte, "![](")
      md = md + "- ▤ **" + d.titre + "** : image sans texte de remplacement (accessibilité)." + n
      k += 1
    finsi
  suivant
  pour chaque u dans RQ("select source_genre, source_id, cible from utilisations where cible not in (select id from composants)", nul)
    md = md + "- ⚠ " + u.source_genre + " **" + NOM_ELEMENT(u.source_genre, u.source_id) + "** référence `" + u.cible + "` (absent)." + n
    k += 1
  suivant
  pour chaque id, c dans COMPOSANTS
    pour chaque v dans c.variantes
      si non fichier.existe(FICHIER_COMPOSANT(c, v))
        md = md + "- ◆ **" + c.titre + "** : la variante « " + v + " » n'a pas de fichier." + n
        k += 1
      finsi
    suivant
  suivant
  && extensions : vérifications supplémentaires
  pour chaque x dans EXTENSIONS_DE("verification")
    essayer
      locale r = appeler(x.procedure)
      si r <> nul et r <> ""
        md = md + r + n
        k += 1
      finsi
    capturer e
      md = md + "- Extension « " + x.nom + " » : " + e + n
    finessayer
  suivant
retourner sisinon(k = 0, md + "✓ Aucune incohérence détectée.", md)

procedure IA_DOUBLONS(ev)
  COMBO_FIXER(ia_action, IA_ACTIONS(), "Doublons")
  ia_resultat.valeur = DOUBLONS_MD()
  droite.valeur = 4
retourner

procedure IA_COHERENCE(ev)
  COMBO_FIXER(ia_action, IA_ACTIONS(), "Cohérence du projet")
  ia_resultat.valeur = COHERENCE_MD()
  droite.valeur = 4
retourner

procedure IA_INSERER(ev)
  si IA.dernier <> ""
    DOC_INSERER(IA.dernier)
  finsi
retourner

procedure IA_COMPOSANT(ev)
  si IA.dernier = ""
    retourner
  finsi
  locale t = ui.demander("Titre du composant :", "Texte de l'assistant")
  si t <> nul et rogner(t) <> ""
    ENREGISTRER_COMPOSANT({titre = rogner(t), genre = "texte", dossier = "Assistant", tags = {"assistant"}}, IA.dernier, nul)
    RAFRAICHIR_BIBLIOTHEQUE()
  finsi
retourner

fonction IA_ACTIONS()
retourner {"Générer un texte", "Reformuler la sélection", "Traduire (anglais)", "Résumer", "Synthèse du document", ;
           "Illustration SVG", "Rechercher des composants", "Doublons", "Cohérence du projet"}

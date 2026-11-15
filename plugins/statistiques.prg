&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Extension d'exemple de Kaléido : statistiques de rédaction.
&&   - commande « Statistiques du document » (palette, menu)
&&   - macro {{mots}} : nombre de mots du document ; {{lecture}} : temps de lecture
&&   - exportateur « Texte brut (.txt) »
&&   - vérification : phrases de plus de 40 mots

procedure EXTENSION_STATISTIQUES
  KALEIDO_ENREGISTRER{genre = "commande", nom = "stats", libelle = "Statistiques du document", procedure = @STATS_DOCUMENT}
  KALEIDO_ENREGISTRER{genre = "macro", nom = "mots", procedure = @STATS_MACRO_MOTS}
  KALEIDO_ENREGISTRER{genre = "macro", nom = "lecture", procedure = @STATS_MACRO_LECTURE}
  KALEIDO_ENREGISTRER{genre = "exportateur", nom = "txt", libelle = "Texte brut (.txt)", procedure = @STATS_EXPORT_TXT}
  KALEIDO_ENREGISTRER{genre = "verification", nom = "phrases", procedure = @STATS_PHRASES_LONGUES}
retourner

procedure STATS_DOCUMENT(ev)
  locale t = pub.textebrut(ed:texte())
  locale n = NB_MOTS(t)
  fiche.valeur = "## Statistiques" + car(10) + car(10) + "- **" + n + "** mots" + car(10) + "- **" + #t + "** caractères" + car(10) + ;
                 "- lecture : **" + max(1, arrondi(n / 230)) + " min**" + car(10) + "- titres : **" + #pub.titres(ed:texte()) + "**"
  droite.valeur = 1
retourner

fonction STATS_MACRO_MOTS(arg, ctx)
retourner chaine(NB_MOTS(pub.textebrut(ed:texte())))

fonction STATS_MACRO_LECTURE(arg, ctx)
retourner max(1, arrondi(NB_MOTS(pub.textebrut(ed:texte())) / 230)) + " min"

fonction STATS_EXPORT_TXT(d, texte_)
  locale dest = CHEMIN("publication", d.nom + ".txt")
  ECRIRE_TEXTE(dest, pub.textebrut(texte_))
retourner dest

fonction STATS_PHRASES_LONGUES()
  locale r = ""
  pour chaque d dans DOCS
    && une phrase se termine par un point suivi d'une espace ou d'un retour à la ligne
    pour chaque p dans decouper(remplacertexte(pub.textebrut(LIRE_TEXTE(d.chemin)), car(10), " "), ". ")
      si NB_MOTS(p) > 40
        r = r + "- ▤ **" + d.titre + "** : phrase de " + NB_MOTS(p) + " mots (« " + COURT(p, 60) + " »)." + car(10)
      finsi
    suivant
  suivant
retourner sisinon(r = "", nul, r)

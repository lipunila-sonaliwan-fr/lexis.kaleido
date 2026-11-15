&& CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
&& Kaléido : projet de démonstration (créé au premier lancement dans ~/Kaleido/Demonstration).
&& Il montre la composition (composants imbriqués, variantes, variables, versions figées),
&& les illustrations SVG, une présentation, un storyboard et le graphe de dépendances.

procedure CREER_DEMO
  locale n = car(10)
  PROJ.titre = "Démonstration Kaléido"
  PROJ.auteur = "Studio Lumen"
  PROJ.variables = {produit = "Kaléido", version = "1.0", societe = "Atelier Lumen", contact = "contact@lumen.example"}
  PROJ.variantes = {client = {produit = "Kaléido Entreprise"}, marketing = {produit = "Kaléido Studio"}}
  ECRIRE_MANIFESTE()

  && --- composants texte
  ENREGISTRER_COMPOSANT({id = "presentation-produit", titre = "Présentation du produit", genre = "texte", dossier = "Marketing", ;
    tags = {"produit", "accroche"}, motscles = "présentation, produit, résumé", description = "Le paragraphe d'accroche commun à tous les supports.", collections = {"Lancement"}}, ;
    "**{{produit}}** réunit l'écriture, l'illustration, la présentation et le storyboard dans un seul atelier. " + ;
    "Chaque contenu devient un *composant* réutilisable[[i:composant]] : un paragraphe, un logo, un schéma, une scène. " + ;
    "Les documents sont **assemblés**, pas recopiés : une correction faite une fois se propage partout où le composant est utilisé.", nul)
  ENREGISTRER_COMPOSANT(COMPOSANT("presentation-produit"), ;
    "**{{produit}}** met à la disposition de vos équipes un atelier unique pour produire documentation, supports de formation et présentations. " + ;
    "Vos contenus validés deviennent des composants partagés : chaque mise à jour est tracée, chaque livrable reste cohérent avec votre charte.", "client")
  ENREGISTRER_COMPOSANT(COMPOSANT("presentation-produit"), ;
    "Écrivez une fois. Publiez partout. **{{produit}}** transforme chaque idée en composant vivant : documents, présentations et storyboards se mettent à jour d'eux-mêmes.", "marketing")
  ENREGISTRER_COMPOSANT({id = "principes", titre = "Les quatre piliers", genre = "liste", dossier = "Marketing", tags = {"piliers"}, collections = {"Lancement"}}, ;
    "1. **Éditeur de texte** Markdown enrichi, aperçu paginé en direct." + n + "2. **Éditeur SVG** natif : formes, calques, courbes de Bézier." + n + ;
    "3. **Bibliothèque de composants** classés, étiquetés, retrouvés instantanément." + n + "4. **Composition et traçabilité** : graphe de dépendances et analyse d'impact[[i:impact]].", nul)
  ENREGISTRER_COMPOSANT({id = "chiffres-cles", titre = "Chiffres clés", genre = "tableau", dossier = "Marketing", tags = {"chiffres"}}, ;
    "| Indicateur | Avant | Avec {{produit}} |" + n + "|:--|--:|--:|" + n + "| Temps de mise à jour d'un manuel | 3 jours | 2 heures |" + n + ;
    "| Copies d'un même paragraphe | 37 | 1 |" + n + "| Livrables cohérents après une correction | 61 % | 100 % |" + n, nul)
  ENREGISTRER_COMPOSANT({id = "prerequis", titre = "Prérequis", genre = "liste", dossier = "Documentation/Installation", tags = {"installation"}}, ;
    "- macOS 13, Windows 10 ou Linux (x64, arm64)" + n + "- 4 Go de mémoire, 300 Mo d'espace disque" + n + "- [x] Aucune connexion réseau n'est nécessaire" + n, nul)
  ENREGISTRER_COMPOSANT({id = "chapitre-installation", titre = "Chapitre : installation", genre = "chapitre", dossier = "Documentation/Installation", tags = {"installation", "chapitre"}}, ;
    "# Installation {#installation}" + n + n + "{{> prerequis}}" + n + n + "Décompressez l'archive puis lancez l'application[[i:installation]] :" + n + n + ;
    "```sh" + n + "wdlexisrt exemples/kaleido/principal.prg" + n + "```" + n + n + ;
    "> [!TIP] Premier lancement" + n + "> Un projet de démonstration est créé dans votre dossier personnel : explorez-le avant de créer le vôtre." + n, nul)
  ENREGISTRER_COMPOSANT({id = "mentions-legales", titre = "Mentions légales", genre = "texte", dossier = "Juridique", tags = {"légal"}}, ;
    "© {{societe}} — {{produit}} {{version}}. Document généré le {{date}}. Contact : {{contact}}.", nul)

  && --- illustrations
  ENREGISTRER_COMPOSANT({id = "logo", titre = "Logo Kaléido", genre = "logo", ext = "svg", dossier = "Identité", tags = {"logo", "identité"}, collections = {"Charte"}}, SVG_LOGO(), nul)
  ENREGISTRER_COMPOSANT({id = "schema-architecture", titre = "Schéma d'architecture", genre = "schema", ext = "svg", dossier = "Documentation/Schémas", tags = {"architecture"}}, SVG_ARCHI(), nul)
  ENREGISTRER_COMPOSANT({id = "personnage-ana", titre = "Ana, cheffe de projet", genre = "illustration", ext = "svg", dossier = "Storyboard/Personnages", tags = {"personnage"}}, SVG_ANA(), nul)
  ENREGISTRER_COMPOSANT({id = "decor-bureau", titre = "Décor : bureau", genre = "illustration", ext = "svg", dossier = "Storyboard/Décors", tags = {"décor"}}, SVG_BUREAU(), nul)
  ENREGISTRER_COMPOSANT({id = "graphique-gains", titre = "Graphique des gains", genre = "graphique", ext = "svg", dossier = "Marketing", tags = {"graphique", "chiffres"}}, SVG_GRAPHIQUE(), nul)

  && une seconde version de l'accroche (historique) ; la version 1 reste disponible (#v1)
  locale c = COMPOSANT("presentation-produit")
  ENREGISTRER_COMPOSANT(c, CONTENU_COMPOSANT(c, nul) + " Le graphe de dépendances indique, avant chaque modification, quels livrables seront touchés.", nul)

  && --- documents
  ECRIRE_TEXTE(CHEMIN("documents", "guide-utilisateur.md"), ;
    "---" + n + "titre: Guide de l'utilisateur" + n + "soustitre: Concevoir, composer et publier avec {{produit}}" + n + "---" + n + n + ;
    "{{toc}}" + n + n + "# Bienvenue" + n + n + "{{> presentation-produit}}" + n + n + ;
    "## Les piliers" + n + n + "{{> principes}}" + n + n + "## En chiffres" + n + n + "{{> chiffres-cles}}" + n + n + ;
    "{{> graphique-gains}}" + n + n + "{{> chapitre-installation}}" + n + n + "# Composer un document {#composer}" + n + n + ;
    "Un document est une suite de références : `{{> id}}` insère un composant, `{{> id@client}}` sa variante, `{{> id#v1}}` une version figée[[i:version]]. " + ;
    "Les variables (`{{produit}}`) et les macros (`{{date}}`, `{{toc}}`, `{{index}}`) sont résolues à chaque aperçu." + n + n + ;
    "> [!NOTE] Propagation" + n + "> Avant d'enregistrer un composant partagé, Kaléido affiche son impact : propager, ignorer, créer une variante ou une branche." + n + n + ;
    "{{> schema-architecture}}" + n + n + "## Variantes" + n + n + "La même accroche existe en version *client* et *marketing* : choisissez la variante du document dans le ruban. " + ;
    "Pour l'installation, voir {{ref:installation}}." + n + n + "# Publier" + n + n + "| Format | Contenu | Usage |" + n + "|:--|:--|:--|" + n + ;
    "| PDF | texte réel, signets, liens, index | impression, diffusion |" + n + "| Site web | lecteur autonome, recherche | intranet, tablette |" + n + ;
    "| SVG | illustrations propres | intégration |" + n + n + "{{saut}}" + n + n + "{{index}}" + n + n + "---" + n + n + "{{> mentions-legales}}" + n)
  ECRIRE_JSON(CHEMIN("documents", "guide-utilisateur.json"), {titre = "Guide de l'utilisateur"})
  ECRIRE_TEXTE(CHEMIN("documents", "dossier-de-presse.md"), ;
    "---" + n + "titre: Dossier de presse" + n + "soustitre: {{produit}} {{version}}" + n + "---" + n + n + "# Communiqué" + n + n + ;
    "{{> presentation-produit}}" + n + n + "{{> chiffres-cles}}" + n + n + "# Visuels" + n + n + "{{> logo}}" + n + n + "{{> graphique-gains}}" + n + n + ;
    "# Contact" + n + n + "{{> mentions-legales}}" + n)
  ECRIRE_JSON(CHEMIN("documents", "dossier-de-presse.json"), {titre = "Dossier de presse", variante = "marketing", couverture = vrai, accent = "#e11d48"})
  ECRIRE_TEXTE(CHEMIN("modeles", "note-interne.md"), "---" + n + "titre: {{titre_document}}" + n + "soustitre: Note interne" + n + "---" + n + n + ;
    "# Objet" + n + n + "# Décision" + n + n + "{{> mentions-legales}}" + n)

  && --- présentation
  locale d = {nom = "lancement", titre = "Lancement de Kaléido", theme = "aurore", diapositives = { ;
    {id = "d1", disposition = "titre", titre = "Kaléido", soustitre = "Écrire une fois, publier partout", transition = "fondu", duree = 30, ;
     notes = "Bonjour à tous. En deux minutes : pourquoi nos contenus divergent, et comment Kaléido l'empêche."}, ;
    {id = "d2", disposition = "contenu", titre = "Le problème", texte = "- 37 copies du même paragraphe dans nos supports" + n + "- Chaque correction se perd dans les versions" + n + "- Personne ne sait quels documents mettre à jour", ;
     transition = "glissement", duree = 60, notes = "Insister sur le coût caché des copies : trois jours par mise à jour de manuel."}, ;
    {id = "d3", disposition = "chiffres", titre = "Ce que nous avons mesuré", texte = "2 h | au lieu de 3 jours pour mettre un manuel à jour" + n + "1 | seule copie de chaque paragraphe (contre 37)" + n + "100 % | des livrables cohérents", ;
     transition = "zoom", duree = 45, notes = "Chiffres du pilote sur la documentation produit."}, ;
    {id = "d4", disposition = "deux-colonnes", titre = "Une architecture simple", texte = "- Composants réutilisables" + n + "- Composition dynamique" + n + "- Graphe de dépendances" + n + "- Publication PDF et web", ;
     medias = {"schema-architecture"}, transition = "fondu", duree = 60, notes = "Le schéma est un composant : s'il change, cette diapositive change aussi."}, ;
    {id = "d5", disposition = "citation", titre = "Citation", texte = "La simplicité est la sophistication suprême.", soustitre = "Léonard de Vinci", transition = "fondu", duree = 20, notes = "Transition vers la démonstration."}, ;
    {id = "d6", disposition = "fin", titre = "Merci", soustitre = "Questions ?", transition = "fondu", duree = 30, notes = "Ouvrir la démonstration en direct."}}}
  locale i = 1
  pour chaque s dans d.diapositives
    DIAPO_ECRIRE(d, s, i)
    i += 1
  suivant
  ENREGISTRER_PRESENTATION(d)

  && --- storyboard
  locale sb = {nom = "film-de-lancement", titre = "Film de lancement (60 s)", colonnes = 4, ;
    personnages = {{nom = "Ana", couleur = "#6366F1", description = "cheffe de projet"}, {nom = "Léo", couleur = "#F59E0B", description = "rédacteur"}}, ;
    scenes = { ;
      {id = "s1", titre = "Le bureau, lundi matin", sequence = "Acte 1 · Le problème", duree = 6, personnages = {"Ana"}, medias = {"decor-bureau"}, commentaire = "Plan large, lumière froide."}, ;
      {id = "s2", titre = "37 versions d'un même texte", sequence = "Acte 1 · Le problème", duree = 8, personnages = {"Léo"}, medias = {}, commentaire = "Gros plan sur l'écran, fichiers « final_v7 »."}, ;
      {id = "s3", titre = "La correction oubliée", sequence = "Acte 1 · Le problème", duree = 7, personnages = {"Ana", "Léo"}, medias = {}, commentaire = "Tension : le client signale l'erreur."}, ;
      {id = "s4", titre = "Découverte de Kaléido", sequence = "Acte 2 · La solution", duree = 9, personnages = {"Ana"}, medias = {"logo"}, commentaire = "Le logo apparaît, musique qui s'ouvre."}, ;
      {id = "s5", titre = "Un composant, partout", sequence = "Acte 2 · La solution", duree = 10, personnages = {}, medias = {"schema-architecture"}, commentaire = "Animation : le paragraphe se propage."}, ;
      {id = "s6", titre = "L'impact avant la modification", sequence = "Acte 2 · La solution", duree = 8, personnages = {"Léo"}, medias = {"graphique-gains"}, commentaire = "Message « impactera 37 documents »."}, ;
      {id = "s7", titre = "Publication en un clic", sequence = "Acte 3 · Le résultat", duree = 6, personnages = {"Ana", "Léo"}, medias = {}, commentaire = "PDF et site web générés."}, ;
      {id = "s8", titre = "Signature", sequence = "Acte 3 · Le résultat", duree = 6, personnages = {}, medias = {"logo"}, commentaire = "Logo, slogan : Écrire une fois, publier partout."}}}
  pour chaque s dans sb.scenes
    SCENE_ECRIRE(sb, s)
  suivant
  ENREGISTRER_STORYBOARD(sb)

  CHARGER_LIVRABLES()
  REINDEXER()
  JOURNAL("info", "projet de démonstration créé")
retourner

fonction SVG_LOGO()
  locale s = '<svg xmlns="http://www.w3.org/2000/svg" width="640" height="220" viewBox="0 0 640 220">' + ;
    '<defs><linearGradient id="g1" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#6366F1"/><stop offset="1" stop-color="#EC4899"/></linearGradient></defs>' + ;
    '<rect x="10" y="10" width="200" height="200" rx="48" fill="url(#g1)"/>' + '<g transform="translate(110 110)">'
  pour i = 0 a 5
    s = s + '<ellipse cx="0" cy="-42" rx="22" ry="44" fill="#FFFFFF" opacity="0.30" transform="rotate(' + (i * 60) + ')"/>'
  suivant
  s = s + '<circle cx="0" cy="0" r="18" fill="#FFFFFF"/></g>' + ;
    '<text x="240" y="132" font-family="Poppins" font-size="76" font-weight="bold" fill="#1E1B4B">Kaléido</text>' + ;
    '<text x="244" y="172" font-family="Poppins" font-size="22" fill="#6366F1">écrire une fois · publier partout</text></svg>'
retourner s

fonction SVG_ARCHI()
  locale t = '<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="560" viewBox="0 0 1200 560"><rect id="fond" width="1200" height="560" rx="24" fill="#F8FAFC"/>'
  locale blocs = {{"Éditeur de texte", "#4F46E5", 60, 70}, {"Éditeur SVG", "#7C3AED", 60, 230}, {"Médias importés", "#0EA5E9", 60, 390}}
  pour chaque b dans blocs
    t = t + '<rect x="' + b[3] + '" y="' + b[4] + '" width="280" height="110" rx="20" fill="' + b[2] + '" data-ombre="1"/>' + ;
        SVG_TEXTE(b[3] + 20, b[4] + 36, 240, b[1], "Poppins", 26, "#FFFFFF", vrai, "middle", 1.1)
    t = t + '<path d="M ' + (b[3] + 290) + " " + (b[4] + 55) + ' L 455 280" stroke="#94A3B8" stroke-width="3" fill="none" data-fleche-fin="1"/>'
  suivant
  t = t + '<rect x="470" y="190" width="300" height="180" rx="28" fill="#1E1B4B"/>' + ;
      SVG_TEXTE(490, 228, 260, "Bibliothèque de composants", "Poppins", 26, "#FFFFFF", vrai, "middle", 1.15) + ;
      SVG_TEXTE(490, 300, 260, "graphe · variantes · versions", "Poppins", 18, "#C7D2FE", faux, "middle", 1.2) + ;
      '<path d="M 780 280 L 870 280" stroke="#94A3B8" stroke-width="3" fill="none" data-fleche-fin="1"/>'
  locale sorties = {{"PDF", "#EC4899", 80}, {"Site web", "#10B981", 235}, {"Présentation", "#F59E0B", 390}}
  pour chaque o dans sorties
    t = t + '<rect x="890" y="' + o[3] + '" width="250" height="90" rx="20" fill="' + o[2] + '"/>' + SVG_TEXTE(905, o[3] + 26, 220, o[1], "Poppins", 26, "#FFFFFF", vrai, "middle", 1.1)
    t = t + '<path d="M 870 280 L 885 ' + (o[3] + 45) + '" stroke="#94A3B8" stroke-width="3" fill="none"/>'
  suivant
retourner t + "</svg>"

fonction SVG_ANA()
retourner '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="420" viewBox="0 0 300 420">' + ;
  '<path d="M 60 420 C 60 300 100 250 150 250 C 200 250 240 300 240 420 Z" fill="#6366F1"/>' + ;
  '<rect x="128" y="200" width="44" height="60" rx="16" fill="#F2C29B"/>' + ;
  '<circle cx="150" cy="150" r="70" fill="#F2C29B"/>' + ;
  '<path d="M 78 150 C 70 70 230 60 222 150 C 210 110 180 96 150 96 C 120 96 92 110 78 150 Z" fill="#3F2E1E"/>' + ;
  '<circle cx="125" cy="160" r="7" fill="#1F2937"/><circle cx="175" cy="160" r="7" fill="#1F2937"/>' + ;
  '<path d="M 128 190 C 140 202 160 202 172 190" stroke="#B4533A" stroke-width="5" fill="none"/>' + ;
  '<rect x="186" y="300" width="70" height="90" rx="8" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="3"/></svg>'

fonction SVG_BUREAU()
retourner '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="450" viewBox="0 0 800 450">' + ;
  '<rect width="800" height="450" fill="#E0F2FE"/><rect x="0" y="330" width="800" height="120" fill="#CBD5E1"/>' + ;
  '<rect x="520" y="60" width="200" height="150" rx="8" fill="#BAE6FD" stroke="#FFFFFF" stroke-width="10"/>' + ;
  '<rect x="120" y="250" width="420" height="22" rx="6" fill="#92400E"/><rect x="140" y="272" width="16" height="110" fill="#78350F"/><rect x="504" y="272" width="16" height="110" fill="#78350F"/>' + ;
  '<rect x="250" y="150" width="170" height="100" rx="8" fill="#1F2937"/><rect x="262" y="162" width="146" height="76" rx="4" fill="#6366F1" opacity="0.85"/>' + ;
  '<rect x="320" y="250" width="30" height="8" fill="#334155"/><circle cx="640" cy="300" r="36" fill="#10B981"/><rect x="630" y="320" width="20" height="60" fill="#78350F"/></svg>'

fonction SVG_GRAPHIQUE()
  locale t = '<svg xmlns="http://www.w3.org/2000/svg" width="900" height="420" viewBox="0 0 900 420"><rect id="fond" width="900" height="420" rx="20" fill="#FFFFFF"/>' + ;
    SVG_TEXTE(40, 24, 820, "Heures par mise à jour d'un manuel", "Poppins", 24, "#0F172A", vrai, nul, 1.1) + ;
    '<line x1="80" y1="350" x2="860" y2="350" stroke="#CBD5E1" stroke-width="2"/>'
  locale vals = {{"Janv.", 24}, {"Févr.", 22}, {"Mars", 18}, {"Avr.", 9}, {"Mai", 4}, {"Juin", 2}}
  locale i = 0
  pour chaque v dans vals
    locale h = v[2] * 11
    locale x = 110 + i * 125
    t = t + '<rect x="' + x + '" y="' + (350 - h) + '" width="70" height="' + h + '" rx="10" fill="' + sisinon(i >= 3, "#10B981", "#94A3B8") + '"/>' + ;
        SVG_TEXTE(x - 10, 360, 90, v[1], "Poppins", 16, "#64748B", faux, "middle", 1) + ;
        SVG_TEXTE(x - 10, 350 - h - 34, 90, v[2] + " h", "Poppins", 18, "#0F172A", vrai, "middle", 1)
    i += 1
  suivant
retourner t + "</svg>"

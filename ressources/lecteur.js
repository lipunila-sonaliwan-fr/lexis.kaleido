/* Kaléido — lecteur web autonome (CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026)
 * Données : window.KALEIDO (contenu.js) ; aucune dépendance ; fonctionne en file://,
 * sur ordinateur, tablette, téléphone et dans la WebView de Lexis+.
 * Routes : #accueil, #doc/<id>[/<ancre>], #pres/<id>[/<n>], #jouer/<id>/<n>, #sb/<id>, #annotations
 */
(function () {
  "use strict";
  var K = window.KALEIDO || { titre: "Kaléido", documents: [], presentations: [], storyboards: [] };
  K.documents = K.documents || []; K.presentations = K.presentations || []; K.storyboards = K.storyboards || [];
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };
  var cle = "kaleido:" + (K.titre || "site") + ":";
  function lire(k, d) { try { var v = localStorage.getItem(cle + k); return v ? JSON.parse(v) : d; } catch (e) { return d; } }
  function ecrire(k, v) { try { localStorage.setItem(cle + k, JSON.stringify(v)); } catch (e) {} }
  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function sansAccents(s) { return String(s || "").normalize ? String(s).normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase() : String(s).toLowerCase(); }

  /* ---------- état ---------- */
  var etat = { zoom: lire("zoom", 1), theme: lire("theme", null), favoris: lire("favoris", []), recents: lire("recents", []),
               annotations: lire("annotations", {}), route: "" };
  function appliquerTheme() {
    var t = etat.theme || (window.matchMedia && matchMedia("(prefers-color-scheme: dark)").matches ? "sombre" : "clair");
    document.documentElement.setAttribute("data-theme", t);
  }
  function appliquerZoom() { document.documentElement.style.setProperty("--zoom", etat.zoom); }

  /* ---------- navigation hiérarchique ---------- */
  function nav() {
    var h = [];
    h.push('<a href="#accueil" data-r="accueil">⌂ Accueil</a>');
    if (K.documents.length) {
      h.push("<h4>Documents</h4>");
      K.documents.forEach(function (d) {
        h.push('<a href="#doc/' + d.id + '" data-r="doc/' + d.id + '">📄 ' + esc(d.titre) + "</a>");
        var t = (d.titres || []).filter(function (x) { return x.niveau <= 2; });
        if (t.length && etat.route.indexOf("doc/" + d.id) === 0) {
          h.push('<div class="sous">');
          t.forEach(function (x) { h.push('<a class="n' + x.niveau + '" href="#doc/' + d.id + "/" + x.id + '">' + esc(x.texte) + "</a>"); });
          h.push("</div>");
        }
      });
    }
    if (K.presentations.length) {
      h.push("<h4>Présentations</h4>");
      K.presentations.forEach(function (p) { h.push('<a href="#pres/' + p.id + '" data-r="pres/' + p.id + '">▭ ' + esc(p.titre) + "</a>"); });
    }
    if (K.storyboards.length) {
      h.push("<h4>Storyboards</h4>");
      K.storyboards.forEach(function (s) { h.push('<a href="#sb/' + s.id + '" data-r="sb/' + s.id + '">🎬 ' + esc(s.titre) + "</a>"); });
    }
    if (etat.favoris.length) {
      h.push("<h4>Favoris</h4>");
      etat.favoris.forEach(function (f) { h.push('<a href="#' + f.route + '">★ ' + esc(f.titre) + "</a>"); });
    }
    if (etat.recents.length) {
      h.push("<h4>Historique</h4>");
      etat.recents.slice(0, 8).forEach(function (f) { h.push('<a href="#' + f.route + '">↺ ' + esc(f.titre) + "</a>"); });
    }
    h.push('<h4>Notes</h4><a href="#annotations">✎ Annotations (' + compterAnnotations() + ")</a>");
    $("#nav").innerHTML = h.join("");
    $$("#nav a[data-r]").forEach(function (a) { if (etat.route.indexOf(a.getAttribute("data-r")) === 0 && a.getAttribute("data-r") !== "accueil" || etat.route === a.getAttribute("data-r")) a.classList.add("actif"); });
  }
  function compterAnnotations() { var n = 0; Object.keys(etat.annotations).forEach(function (k) { n += etat.annotations[k].length; }); return n; }

  function memoriser(route, titre) {
    etat.recents = [{ route: route, titre: titre }].concat(etat.recents.filter(function (r) { return r.route !== route; })).slice(0, 20);
    ecrire("recents", etat.recents);
    etat.titreCourant = titre;
    majFavori();
  }
  function majFavori() {
    var est = etat.favoris.some(function (f) { return f.route === etat.route; });
    $("#b-favori").textContent = est ? "★" : "☆";
  }

  /* ---------- vues ---------- */
  function accueil() {
    var h = ['<div class="accueil"><h1>' + esc(K.titre) + '</h1><div class="sous">' + esc(K.auteur || "") + (K.genere ? " · publié le " + esc(K.genere) : "") + "</div>"];
    if (K.documents.length) {
      h.push("<h2>Documents</h2><div class=\"grille\">");
      K.documents.forEach(function (d) {
        h.push('<a class="carte" href="#doc/' + d.id + '"><div class="vignette-doc">📄</div><div class="ct"><b>' + esc(d.titre) + "</b><small>" +
               (d.titres || []).length + " sections · " + Math.max(1, Math.round((d.texte || "").split(/\s+/).length / 230)) + " min de lecture</small></div></a>");
      });
      h.push("</div>");
    }
    if (K.presentations.length) {
      h.push("<h2>Présentations</h2><div class=\"grille\">");
      K.presentations.forEach(function (p) {
        var s = p.diapositives[0] || {};
        h.push('<a class="carte" href="#pres/' + p.id + '"><img loading="lazy" src="' + esc(s.svg) + '" alt=""><div class="ct"><b>' + esc(p.titre) + "</b><small>" + p.diapositives.length + " diapositives</small></div></a>");
      });
      h.push("</div>");
    }
    if (K.storyboards.length) {
      h.push("<h2>Storyboards</h2><div class=\"grille\">");
      K.storyboards.forEach(function (s) {
        var d = s.scenes.reduce(function (a, x) { return a + (x.duree || 0); }, 0);
        h.push('<a class="carte" href="#sb/' + s.id + '"><img loading="lazy" src="' + esc((s.scenes[0] || {}).svg) + '" alt=""><div class="ct"><b>' + esc(s.titre) + "</b><small>" + s.scenes.length + " scènes · " + d + " s</small></div></a>");
      });
      h.push("</div>");
    }
    $("#contenu").innerHTML = h.join("") + "</div>";
    $("#toc").innerHTML = "";
    memoriser("accueil", "Accueil");
  }

  function documentVue(id, ancre) {
    var d = K.documents.filter(function (x) { return x.id === id; })[0];
    if (!d) return introuvable();
    var mots = (d.texte || "").split(/\s+/).length;
    $("#contenu").innerHTML = '<div class="entete-doc"><span>' + mots + " mots</span><span>" + Math.max(1, Math.round(mots / 230)) + ' min de lecture</span><a href="javascript:print()">Imprimer</a></div>' +
      '<article class="doc">' + d.html + "</article>" + annotationsVue(id);
    surligner(id);
    var t = (d.titres || []).filter(function (x) { return x.niveau <= 3; });
    $("#toc").innerHTML = t.length ? "<h5>Sur cette page</h5>" + t.map(function (x) { return '<a class="n' + x.niveau + '" href="#doc/' + id + "/" + x.id + '" data-id="' + x.id + '">' + esc(x.texte) + "</a>"; }).join("") : "";
    if (ancre) { var el = document.getElementById(ancre); if (el) el.scrollIntoView(); } else $("#contenu").scrollTop = 0;
    memoriser("doc/" + id, d.titre);
    espionner();
  }

  /* sommaire dynamique : la section visible est surlignée */
  function espionner() {
    var c = $("#contenu");
    c.onscroll = function () {
      var hs = $$(".doc h1[id], .doc h2[id], .doc h3[id]");
      var cur = null;
      hs.forEach(function (h) { if (h.getBoundingClientRect().top < 120) cur = h.id; });
      $$("#toc a").forEach(function (a) { a.classList.toggle("actif", a.getAttribute("data-id") === cur); });
    };
  }

  function presentationVue(id) {
    var p = K.presentations.filter(function (x) { return x.id === id; })[0];
    if (!p) return introuvable();
    var h = ['<div class="accueil"><h1>' + esc(p.titre) + '</h1><div class="sous">' + p.diapositives.length + " diapositives</div>",
             '<div class="boutons"><a class="btn principal" href="#jouer/' + id + '/1">▶ Présenter</a></div><div class="grille pres-liste">'];
    p.diapositives.forEach(function (s, i) {
      h.push('<a class="carte" href="#jouer/' + id + "/" + (i + 1) + '"><img loading="lazy" src="' + esc(s.svg) + '" alt="' + esc(s.titre) + '"><div class="ct"><b>' + (i + 1) + ". " + esc(s.titre) + "</b><small>" + esc((s.notes || "").slice(0, 90)) + "</small></div></a>");
    });
    $("#contenu").innerHTML = h.join("") + "</div></div>";
    $("#toc").innerHTML = "";
    memoriser("pres/" + id, p.titre);
  }

  /* mode présentation : plein écran, transitions, notes (N), plein écran (F), Échap */
  function jouer(id, n) {
    var p = K.presentations.filter(function (x) { return x.id === id; })[0];
    if (!p) return introuvable();
    n = Math.max(1, Math.min(p.diapositives.length, n || 1));
    var s = p.diapositives[n - 1];
    var sc = $(".scene-pres");
    if (!sc) { sc = document.createElement("div"); sc.className = "scene-pres"; document.body.appendChild(sc); }
    var notes = lire("notesvisibles", false);
    sc.innerHTML = '<a class="fermer" href="#pres/' + id + '">✕ Quitter</a><div class="aide">← → espace · N notes · F plein écran · Échap</div>' +
      '<img class="t-' + esc(s.transition || "fondu") + '" src="' + esc(s.svg) + '" alt="' + esc(s.titre) + '">' +
      '<div class="progres" style="width:' + (100 * n / p.diapositives.length) + '%"></div>' +
      (notes && s.notes ? '<div class="notes">' + esc(s.notes) + "</div>" : "");
    sc.onclick = function (e) { if (e.target.tagName === "IMG") aller("#jouer/" + id + "/" + Math.min(p.diapositives.length, n + 1)); };
    etat.jeu = { id: id, n: n, total: p.diapositives.length };
    memoriser("pres/" + id, p.titre);
  }
  function quitterJeu() { var sc = $(".scene-pres"); if (sc) sc.remove(); etat.jeu = null; }

  function storyboardVue(id) {
    var s = K.storyboards.filter(function (x) { return x.id === id; })[0];
    if (!s) return introuvable();
    var total = s.scenes.reduce(function (a, x) { return a + (x.duree || 0); }, 0) || 1;
    var couleurs = ["#6366F1", "#EC4899", "#10B981", "#F59E0B", "#0EA5E9", "#8B5CF6", "#EF4444"], seq = {};
    var tl = s.scenes.map(function (x, i) {
      var q = x.sequence || "—"; if (!(q in seq)) seq[q] = couleurs[Object.keys(seq).length % couleurs.length];
      return '<a href="#sbs/' + id + "/" + (i + 1) + '" title="' + esc(x.titre) + " · " + x.duree + ' s" style="flex:' + (x.duree || 1) + ";background:" + seq[q] + '">' + (i + 1) + "</a>";
    }).join("");
    var h = ['<div class="accueil"><h1>' + esc(s.titre) + '</h1><div class="sous">' + s.scenes.length + " scènes · " + total + ' s</div>',
             '<div class="boutons"><button class="btn principal" id="b-anim">▶ Animatique</button></div><div class="timeline">' + tl + '</div><div class="grille">'];
    s.scenes.forEach(function (x, i) {
      h.push('<div class="carte" id="scene-' + (i + 1) + '"><img loading="lazy" src="' + esc(x.svg) + '" alt=""><div class="ct"><b>' + (i + 1) + ". " + esc(x.titre) + "</b><small>" +
             esc(x.sequence || "") + " · " + x.duree + " s" + (x.commentaire ? " — " + esc(x.commentaire) : "") + "</small></div></div>");
    });
    $("#contenu").innerHTML = h.join("") + "</div></div>";
    $("#toc").innerHTML = "";
    $("#b-anim").onclick = function () { animatique(s, 0); };
    memoriser("sb/" + id, s.titre);
  }
  function animatique(s, i) {
    if (i >= s.scenes.length) { quitterJeu(); return; }
    var x = s.scenes[i];
    var sc = $(".scene-pres");
    if (!sc) { sc = document.createElement("div"); sc.className = "scene-pres"; document.body.appendChild(sc); }
    sc.innerHTML = '<a class="fermer" href="javascript:void(0)">✕</a><img class="t-fondu" src="' + esc(x.svg) + '"><div class="notes">' + (i + 1) + ". " + esc(x.titre) + (x.commentaire ? " — " + esc(x.commentaire) : "") +
                   '</div><div class="progres" style="width:' + (100 * (i + 1) / s.scenes.length) + '%"></div>';
    $(".fermer", sc).onclick = function () { clearTimeout(etat.anim); quitterJeu(); };
    etat.anim = setTimeout(function () { animatique(s, i + 1); }, (x.duree || 3) * 1000);
  }

  /* ---------- recherche plein texte ---------- */
  var index = [];
  function construireIndex() {
    K.documents.forEach(function (d) {
      var tmp = document.createElement("div"); tmp.innerHTML = d.html;
      var courant = { id: "", titre: d.titre };
      Array.prototype.forEach.call(tmp.children, function (el) {
        if (/^H[1-4]$/.test(el.tagName)) courant = { id: el.id, titre: el.textContent.replace(/#$/, "") };
        var t = el.textContent.trim();
        if (t) index.push({ route: "doc/" + d.id + (courant.id ? "/" + courant.id : ""), titre: d.titre + (courant.id ? " › " + courant.titre : ""), texte: t, norm: sansAccents(t) });
      });
    });
    K.presentations.forEach(function (p) { p.diapositives.forEach(function (s, i) { var t = s.titre + " " + (s.texte || "") + " " + (s.notes || ""); index.push({ route: "jouer/" + p.id + "/" + (i + 1), titre: p.titre + " › " + (i + 1) + ". " + s.titre, texte: t, norm: sansAccents(t) }); }); });
    K.storyboards.forEach(function (sb) { sb.scenes.forEach(function (s, i) { var t = s.titre + " " + (s.sequence || "") + " " + (s.commentaire || ""); index.push({ route: "sb/" + sb.id, titre: sb.titre + " › " + (i + 1) + ". " + s.titre, texte: t, norm: sansAccents(t) }); }); });
  }
  function chercher(q) {
    var box = $("#resultats");
    var mots = sansAccents(q).split(/\s+/).filter(Boolean);
    if (!mots.length) { box.hidden = true; return; }
    var r = index.filter(function (e) { return mots.every(function (m) { return e.norm.indexOf(m) >= 0; }); }).slice(0, 40);
    if (!r.length) { box.innerHTML = '<div class="vide">Aucun résultat pour « ' + esc(q) + " »</div>"; box.hidden = false; return; }
    box.innerHTML = r.map(function (e, i) {
      var p = e.norm.indexOf(mots[0]), a = Math.max(0, p - 50), extrait = e.texte.slice(a, a + 150);
      var x = esc(extrait);
      mots.forEach(function (m) { x = x.replace(new RegExp("(" + m.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "ig"), "<mark>$1</mark>"); });
      return '<a href="#' + e.route + '"' + (i === 0 ? ' class="actif"' : "") + "><b>" + esc(e.titre) + "</b><small>" + (a > 0 ? "…" : "") + x + "…</small></a>";
    }).join("");
    box.hidden = false;
  }

  /* ---------- annotations (texte sélectionné) ---------- */
  function annotationsVue(id) {
    var l = etat.annotations[id] || [];
    if (!l.length) return "";
    return '<section class="annotations"><h3>Vos annotations</h3><ul>' + l.map(function (a, i) {
      return "<li><q>" + esc(a.citation) + "</q> — " + esc(a.note) + ' <a href="javascript:void(0)" data-suppr="' + i + '">supprimer</a></li>';
    }).join("") + "</ul></section>";
  }
  function surligner(id) {
    (etat.annotations[id] || []).forEach(function (a) {
      var marche = document.createTreeWalker($(".doc"), NodeFilter.SHOW_TEXT, null), n;
      while ((n = marche.nextNode())) {
        var k = n.nodeValue.indexOf(a.citation);
        if (k >= 0) {
          var r = document.createRange(); r.setStart(n, k); r.setEnd(n, k + a.citation.length);
          var m = document.createElement("mark"); m.className = "annot"; m.title = a.note;
          try { r.surroundContents(m); } catch (e) {}
          break;
        }
      }
    });
    $$("[data-suppr]").forEach(function (b) {
      b.onclick = function () { etat.annotations[id].splice(+b.getAttribute("data-suppr"), 1); ecrire("annotations", etat.annotations); documentVue(id); nav(); };
    });
  }
  document.addEventListener("selectionchange", function () {
    var b = $("#b-annoter"), s = window.getSelection();
    if (!s || s.isCollapsed || !etat.route.startsWith("doc/") || !$(".doc") || !$(".doc").contains(s.anchorNode)) { b.hidden = true; return; }
    var r = s.getRangeAt(0).getBoundingClientRect();
    b.style.left = Math.max(8, r.left + r.width / 2 - 50) + "px"; b.style.top = Math.max(60, r.top - 44) + "px"; b.hidden = false;
  });
  $("#b-annoter").addEventListener("mousedown", function (e) {
    e.preventDefault();
    var s = window.getSelection().toString().trim();
    if (!s) return;
    var note = prompt("Annotation pour : « " + s.slice(0, 80) + " »", "");
    if (note === null) return;
    var id = etat.route.split("/")[1];
    (etat.annotations[id] = etat.annotations[id] || []).push({ citation: s.slice(0, 300), note: note, quand: new Date().toISOString() });
    ecrire("annotations", etat.annotations);
    $("#b-annoter").hidden = true;
    documentVue(id); nav();
  });
  function toutesAnnotations() {
    var h = ['<div class="accueil"><h1>Annotations</h1>'];
    var vide = true;
    K.documents.forEach(function (d) {
      var l = etat.annotations[d.id] || [];
      if (!l.length) return; vide = false;
      h.push("<h3>" + esc(d.titre) + "</h3><ul>" + l.map(function (a) { return "<li><q>" + esc(a.citation) + "</q> — " + esc(a.note) + "</li>"; }).join("") + "</ul>");
    });
    if (vide) h.push('<p class="vide">Sélectionnez un passage d\'un document puis « ✎ Annoter ».</p>');
    $("#contenu").innerHTML = h.join("") + "</div>"; $("#toc").innerHTML = "";
    memoriser("annotations", "Annotations");
  }

  function introuvable() { $("#contenu").innerHTML = '<div class="vide">Contenu introuvable. <a href="#accueil">Accueil</a></div>'; }

  /* ---------- routeur ---------- */
  function aller(h) { if (location.hash === h) route(); else location.hash = h; }
  function route() {
    var h = (location.hash || "#accueil").slice(1);
    var p = h.split("/").map(decodeURIComponent);
    if (p[0] !== "jouer") quitterJeu();
    etat.route = h;
    $("#resultats").hidden = true;
    $("#nav").classList.remove("ouverte"); $("#voile").hidden = true;
    switch (p[0]) {
      case "doc": documentVue(p[1], p[2]); break;
      case "pres": presentationVue(p[1]); break;
      case "jouer": jouer(p[1], parseInt(p[2], 10) || 1); break;
      case "sb": storyboardVue(p[1]); break;
      case "sbs": storyboardVue(p[1]); var el = document.getElementById("scene-" + p[2]); if (el) el.scrollIntoView({ behavior: "smooth" }); break;
      case "annotations": toutesAnnotations(); break;
      default: accueil();
    }
    nav();
    document.title = (etat.titreCourant ? etat.titreCourant + " — " : "") + K.titre;
  }

  /* ---------- clavier et commandes ---------- */
  document.addEventListener("keydown", function (e) {
    var tag = (e.target.tagName || "").toLowerCase();
    if (etat.jeu) {
      var j = etat.jeu;
      if (["ArrowRight", " ", "PageDown", "Enter"].indexOf(e.key) >= 0) { aller("#jouer/" + j.id + "/" + Math.min(j.total, j.n + 1)); e.preventDefault(); }
      else if (["ArrowLeft", "PageUp", "Backspace"].indexOf(e.key) >= 0) { aller("#jouer/" + j.id + "/" + Math.max(1, j.n - 1)); e.preventDefault(); }
      else if (e.key === "Escape") aller("#pres/" + j.id);
      else if (e.key === "n" || e.key === "N") { ecrire("notesvisibles", !lire("notesvisibles", false)); jouer(j.id, j.n); }
      else if (e.key === "f" || e.key === "F") { if (document.fullscreenElement) document.exitFullscreen(); else if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen(); }
      return;
    }
    if (e.key === "/" && tag !== "input") { $("#q").focus(); e.preventDefault(); }
    if ((e.ctrlKey || e.metaKey) && (e.key === "+" || e.key === "=")) { zoom(0.1); e.preventDefault(); }
    if ((e.ctrlKey || e.metaKey) && e.key === "-") { zoom(-0.1); e.preventDefault(); }
  });
  function zoom(d) { etat.zoom = Math.max(0.7, Math.min(1.8, Math.round((etat.zoom + d) * 10) / 10)); ecrire("zoom", etat.zoom); appliquerZoom(); }

  $("#q").addEventListener("input", function () { chercher(this.value); });
  $("#q").addEventListener("keydown", function (e) {
    if (e.key === "Enter") { var a = $("#resultats a.actif") || $("#resultats a"); if (a) { location.hash = a.getAttribute("href"); this.blur(); } }
    if (e.key === "Escape") { this.value = ""; $("#resultats").hidden = true; this.blur(); }
  });
  document.addEventListener("click", function (e) { if (!e.target.closest(".recherche")) $("#resultats").hidden = true; });
  $("#b-plus").onclick = function () { zoom(0.1); };
  $("#b-moins").onclick = function () { zoom(-0.1); };
  $("#b-theme").onclick = function () {
    var t = document.documentElement.getAttribute("data-theme") === "sombre" ? "clair" : "sombre";
    etat.theme = t; ecrire("theme", t); appliquerTheme();
  };
  $("#b-favori").onclick = function () {
    var i = etat.favoris.findIndex(function (f) { return f.route === etat.route; });
    if (i >= 0) etat.favoris.splice(i, 1); else etat.favoris.push({ route: etat.route, titre: etat.titreCourant || etat.route });
    ecrire("favoris", etat.favoris); majFavori(); nav();
  };
  $("#b-menu").onclick = function () { var n = $("#nav"); n.classList.toggle("ouverte"); $("#voile").hidden = !n.classList.contains("ouverte"); };
  $("#voile").onclick = function () { $("#nav").classList.remove("ouverte"); this.hidden = true; };
  /* gestes : balayage horizontal en présentation (tablette, téléphone) */
  var x0 = null;
  document.addEventListener("touchstart", function (e) { x0 = e.touches[0].clientX; }, { passive: true });
  document.addEventListener("touchend", function (e) {
    if (!etat.jeu || x0 === null) return;
    var dx = e.changedTouches[0].clientX - x0; x0 = null;
    if (Math.abs(dx) > 50) aller("#jouer/" + etat.jeu.id + "/" + Math.max(1, Math.min(etat.jeu.total, etat.jeu.n + (dx < 0 ? 1 : -1))));
  });

  $("#titre-site").textContent = K.titre;
  appliquerTheme(); appliquerZoom(); construireIndex();
  window.addEventListener("hashchange", route);
  route();
  /* pont Lexis+ (WebView) : navigation demandée par le programme */
  window.kaleidoAller = function (h) { aller(h.charAt(0) === "#" ? h : "#" + h); return true; };
})();

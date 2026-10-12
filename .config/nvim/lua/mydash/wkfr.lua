local spec = {
  { "<leader>w", group = "fenêtres" }, { "<leader>b", group = "pages ouvertes" },
  { "<leader>c", group = "amusement" }, { "<leader>d", group = "canards" }, { "<leader>u", group = "interface" },
  { "<c-w>", group = "fenêtres" },
  { "a", group = "autour (avec les délimiteurs)", mode = { "o", "x" } },
  { "i", group = "intérieur", mode = { "o", "x" } },
}

local function add(mode, tbl)
  for lhs, desc in pairs(tbl) do
    table.insert(spec, { lhs, desc = desc, mode = mode })
  end
end

-- Fenêtres (Ctrl+w) et replis (z)
add("n", {
  ["<c-w>h"] = "Aller à la fenêtre de gauche", ["<c-w>j"] = "Aller à la fenêtre du dessous",
  ["<c-w>k"] = "Aller à la fenêtre du dessus", ["<c-w>l"] = "Aller à la fenêtre de droite",
  ["<c-w>H"] = "Déplacer la fenêtre tout à gauche", ["<c-w>J"] = "Déplacer la fenêtre tout en bas",
  ["<c-w>K"] = "Déplacer la fenêtre tout en haut", ["<c-w>L"] = "Déplacer la fenêtre tout à droite",
  ["<c-w>s"] = "Diviser la fenêtre (en dessous)", ["<c-w>v"] = "Diviser verticalement (à côté)",
  ["<c-w>w"] = "Passer à la fenêtre suivante", ["<c-w>x"] = "Échanger avec la fenêtre suivante",
  ["<c-w>q"] = "Fermer cette fenêtre", ["<c-w>c"] = "Fermer cette fenêtre", ["<c-w>o"] = "Fermer toutes les autres fenêtres",
  ["<c-w>T"] = "Sortir la fenêtre dans un nouvel onglet", ["<c-w>+"] = "Augmenter la hauteur",
  ["<c-w>-"] = "Diminuer la hauteur", ["<c-w>>"] = "Augmenter la largeur", ["<c-w><"] = "Diminuer la largeur",
  ["<c-w>="] = "Égaliser hauteur et largeur", ["<c-w>_"] = "Hauteur maximale", ["<c-w>|"] = "Largeur maximale",
  ["za"] = "Ouvrir ou fermer le repli", ["zA"] = "Ouvrir ou fermer tous les replis ici",
  ["zc"] = "Fermer le repli", ["zC"] = "Fermer tous les replis ici", ["zo"] = "Ouvrir le repli",
  ["zO"] = "Ouvrir tous les replis ici", ["zd"] = "Supprimer le repli", ["zD"] = "Supprimer tous les replis ici",
  ["zE"] = "Supprimer tous les replis du fichier", ["zf"] = "Créer un repli", ["zi"] = "Activer ou désactiver les replis",
  ["zm"] = "Replier plus", ["zr"] = "Replier moins", ["zM"] = "Fermer tous les replis", ["zR"] = "Ouvrir tous les replis",
  ["zx"] = "Mettre à jour les replis", ["zz"] = "Centrer cette ligne", ["zt"] = "Cette ligne en haut",
  ["zb"] = "Cette ligne en bas", ["zs"] = "Aligner à gauche", ["ze"] = "Aligner à droite",
  ["zH"] = "Demi-écran à gauche", ["zL"] = "Demi-écran à droite", ["zv"] = "Faire apparaître la ligne du curseur",
  ["zg"] = "Ajouter le mot au dictionnaire", ["zw"] = "Marquer le mot comme incorrect", ["z="] = "Suggestions d'orthographe",
})

-- Opérateurs
add({ "n", "x" }, {
  ["!"] = "Passer le texte à une commande", ["<"] = "Décaler vers la gauche", [">"] = "Décaler vers la droite",
  ["V"] = "Sélectionner des lignes entières", ["c"] = "Changer (supprimer puis écrire)", ["d"] = "Supprimer",
  ["gU"] = "Majuscules", ["gu"] = "Minuscules", ["g~"] = "Inverser la casse", ["gw"] = "Reformater le texte",
  ["r"] = "Remplacer", ["v"] = "Sélectionner", ["y"] = "Copier", ["zf"] = "Créer un repli", ["~"] = "Inverser la casse",
})

-- Déplacements
add({ "o", "x", "n" }, {
  ["$"] = "Fin de ligne", ["%"] = "Parenthèse, crochet ou accolade correspondant", ["0"] = "Début de ligne",
  ["F"] = "Aller au caractère précédent", ["G"] = "Dernière ligne", ["T"] = "Aller juste avant le caractère précédent",
  ["^"] = "Début de ligne (hors espaces)", ["b"] = "Mot précédent", ["e"] = "Fin du mot suivant",
  ["f"] = "Aller au caractère suivant", ["ge"] = "Fin du mot précédent", ["gg"] = "Première ligne",
  ["h"] = "Gauche", ["j"] = "Bas", ["k"] = "Haut", ["l"] = "Droite",
  ["t"] = "Aller juste avant le caractère suivant", ["w"] = "Mot suivant",
  ["{"] = "Ligne vide précédente", ["}"] = "Ligne vide suivante",
  [";"] = "Répéter f/t/F/T (même sens)", [","] = "Répéter f/t/F/T (sens inverse)",
  ["/"] = "Chercher vers l'avant", ["?"] = "Chercher vers l'arrière",
  ["B"] = "Gros mot précédent", ["E"] = "Fin du gros mot suivant", ["W"] = "Gros mot suivant",
})

-- Objets texte (autour = avec les délimiteurs, intérieur = sans)
add({ "o", "x" }, {
  ['a"'] = "texte entre guillemets (inclus)", ["a'"] = "texte entre apostrophes (inclus)",
  ["a("] = "bloc ( ) (inclus)", ["a)"] = "bloc ( ) (inclus)", ["ab"] = "bloc ( ) (inclus)",
  ["a<"] = "bloc < > (inclus)", ["a>"] = "bloc < > (inclus)",
  ["aB"] = "bloc { } (inclus)", ["a{"] = "bloc { } (inclus)", ["a}"] = "bloc { } (inclus)",
  ["a["] = "bloc [ ] (inclus)", ["a]"] = "bloc [ ] (inclus)", ["a`"] = "texte entre accents graves (inclus)",
  ["aW"] = "gros mot avec l'espace", ["aw"] = "mot avec l'espace", ["ap"] = "paragraphe", ["as"] = "phrase",
  ["at"] = "balise HTML complète", ["an"] = "élément de code parent (autour)",
  ['i"'] = "texte entre guillemets", ["i'"] = "texte entre apostrophes",
  ["i("] = "intérieur de ( )", ["i)"] = "intérieur de ( )", ["ib"] = "intérieur de ( )",
  ["i<"] = "intérieur de < >", ["i>"] = "intérieur de < >",
  ["iB"] = "intérieur de { }", ["i{"] = "intérieur de { }", ["i}"] = "intérieur de { }",
  ["i["] = "intérieur de [ ]", ["i]"] = "intérieur de [ ]", ["i`"] = "texte entre accents graves",
  ["iW"] = "gros mot", ["iw"] = "mot", ["ip"] = "paragraphe", ["is"] = "phrase",
  ["it"] = "contenu entre balises HTML", ["in"] = "élément de code enfant (intérieur)",
})

-- Navigation et menu g
add("n", {
  ["H"] = "Première ligne visible de l'écran", ["L"] = "Dernière ligne visible de l'écran", ["M"] = "Ligne du milieu de l'écran",
  ["[%"] = "Groupe non fermé précédent", ["[("] = "Parenthèse précédente", ["[<"] = "Chevron précédent",
  ["[M"] = "Fin de la méthode précédente", ["[m"] = "Début de la méthode précédente",
  ["[s"] = "Mot mal orthographié précédent", ["[{"] = "Accolade précédente",
  ["]%"] = "Groupe non fermé suivant", ["]("] = "Parenthèse suivante", ["]<"] = "Chevron suivant",
  ["]M"] = "Fin de la méthode suivante", ["]m"] = "Début de la méthode suivante",
  ["]s"] = "Mot mal orthographié suivant", ["]{"] = "Accolade suivante",
  ["g%"] = "Parcourir les résultats en arrière", ["g,"] = "Position de modification plus récente",
  ["g;"] = "Position de modification plus ancienne", ["gN"] = "Chercher en arrière et sélectionner",
  ["gT"] = "Onglet précédent", ["gf"] = "Ouvrir le fichier sous le curseur",
  ["gi"] = "Retourner là où tu écrivais", ["gn"] = "Chercher en avant et sélectionner",
  ["gt"] = "Onglet suivant", ["gv"] = "Refaire la dernière sélection", ["gx"] = "Ouvrir avec l'application du système",
})

return spec

local fr = {
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
}

local spec = {
  { "<leader>w", group = "fenêtres" }, { "<leader>b", group = "pages ouvertes" },
  { "<leader>c", group = "amusement" }, { "<leader>d", group = "canards" }, { "<leader>u", group = "interface" },
  { "<leader>Tt", desc = "Transformer le texte en tableau" },
  { "<leader>Ts", desc = "Trier le tableau" },

  { "<leader>v", group = "jeux" }, { "<leader>T", group = "tableaux" },
  { "<leader>Tm", desc = "Activer/désactiver le mode tableau" }, { "<leader>Tr", desc = "Réaligner le tableau" },
  { "<leader>Tic", desc = "Insérer une colonne" }, { "<leader>Tdc", desc = "Supprimer la colonne" },
  { "<leader>Tdd", desc = "Supprimer la ligne" },
}
for lhs, desc in pairs(fr) do table.insert(spec, { lhs, desc = desc, mode = "n" }) end
return spec

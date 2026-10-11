local M = {}

M.list = {
  [[ciw change le mot sous le curseur (change inner word).]],
  [[dd supprime la ligne, yy la copie, p la colle en dessous.]],
  [[u annule, Ctrl+r rétablit.]],
  [[gg va au début du fichier, G à la fin.]],
  [[0 va au début de la ligne, $ à la fin, ^ au premier caractère.]],
  [[w avance d'un mot, b recule d'un mot, e va à la fin du mot.]],
  [[* cherche le mot sous le curseur ; n et N passent au résultat suivant ou précédent.]],
  [[/mot cherche vers le bas, ?mot vers le haut.]],
  [[:%s/ancien/nouveau/g remplace dans tout le fichier.]],
  [[ci" change le texte entre guillemets ; ci( change celui entre parenthèses.]],
  [[diw supprime un mot entier, dap supprime un paragraphe.]],
  [[Ctrl+d et Ctrl+u défilent d'une demi-page vers le bas et vers le haut.]],
  [[zz centre l'écran sur la ligne du curseur.]],
  [[% saute à la parenthèse ou à l'accolade correspondante.]],
  [[. (point) répète la dernière modification.]],
  [[qa enregistre une macro dans le registre a ; q l'arrête ; @a la rejoue.]],
  [[v sélectionne caractère par caractère, V ligne par ligne, Ctrl+v en colonne.]],
  [[Ctrl+v, puis I, permet d'écrire sur plusieurs lignes à la fois.]],
  [[gv re-sélectionne la dernière sélection.]],
  [[Ctrl+o revient à la position précédente, Ctrl+i avance.]],
  [[m suivi d'une lettre pose un repère ; ' suivi de la lettre y retourne.]],
  [[:w enregistre, :q quitte, :wq fait les deux.]],
  [[ZZ enregistre et quitte ; ZQ quitte sans enregistrer.]],
  [[Ctrl+w v et Ctrl+w s divisent la fenêtre ; Ctrl+w h/j/k/l pour naviguer.]],
  [[:vsplit fichier ouvre un fichier à côté de celui-ci.]],
  [[:e fichier ouvre un fichier ; :ls liste les fichiers ouverts.]],
  [[gf ouvre le fichier dont le chemin est sous le curseur.]],
  [[gx ouvre le lien sous le curseur dans le navigateur.]],
  [[:help mot ouvre l'aide ; Ctrl+] suit un lien dans l'aide.]],
  [[:set relativenumber affiche les numéros de ligne relatifs.]],
  [[gUiw met le mot en majuscules, guiw en minuscules, ~ change un caractère.]],
  [[J joint la ligne suivante à la ligne courante.]],
  [[>> et << décalent la ligne ; == réindente.]],
  [[o ouvre une ligne en dessous et passe en insertion ; O au-dessus.]],
  [[A ajoute à la fin de la ligne ; I insère au début.]],
  [[Espace puis une courte pause : which-key affiche les raccourcis disponibles.]],
  [[Espace + y : historique du presse-papier ; Espace + S : catalogue de plugins.]],
  [[Espace + z : mode zen ; Espace + . : bloc-notes temporaire.]],
  [[Ctrl+w o garde seulement la fenêtre active.]],
  [[:Lazy ouvre le gestionnaire de plugins ; :checkhealth vérifie la santé de Neovim.]],
}

function M.setup()
  if not require("mydash.modules").is_on("tips") then return end
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.defer_fn(function()
        math.randomseed(os.time())
        vim.notify(M.list[math.random(#M.list)], vim.log.levels.INFO, { title = "Astuce Neovim", timeout = 6000 })
      end, 600)
    end,
  })
end

return M

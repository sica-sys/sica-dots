# nom: Effets KooL
# groupe: 1-KooL Dots, natif
# duree: 16
# flou: non
clip() {
  titre "Effets de fond" "18 effets ImageMagick inclus"; sleep 1.5
  vu 4 "$S/WallpaperEffects.sh"
  local b; b=$(base_fond)
  magick "$b" -colorspace gray -sigmoidal-contrast 10,40% "$RUN/eff1.png" && fond "$RUN/eff1.png" wipe; titre "Noir et blanc" "" 1.5; sleep 3
  magick "$b" -paint 4 "$RUN/eff2.png" && fond "$RUN/eff2.png" wipe; titre "Peinture à l'huile" "" 1.5; sleep 3
  magick "$b" -sepia-tone 65% "$RUN/eff3.png" && fond "$RUN/eff3.png" wipe; titre "Sépia" "" 1.5; sleep 3.5
}

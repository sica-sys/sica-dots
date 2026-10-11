# nom: Agenda et météo
# groupe: 5-Productivité
# duree: 18
# flou: oui
clip() {
  local A="$U/AgendaMeteo.sh"
  titre "Agenda et météo" "au clic sur la date et l'heure" 2; sleep 1.5
  clic_sur DATE $A mini; sleep 3.5; $A mini
  clic_sur METEO $A meteo; sleep 4; $A meteo
  clic_sur HORLOGE $A agenda; flou_fenetre 1.2; sleep 4; flou_fin; $A agenda      # tes rendez-vous sont floutés
}

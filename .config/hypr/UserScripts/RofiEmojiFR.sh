#!/usr/bin/env bash
# Copie de scripts/RofiEmoji.sh (KooL) avec noms et mots-clés en français (Unicode CLDR) — UserScripts/RofiEmojiFR.sh
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================

# Dependencies: bash, coreutils (mkdir/mktemp/mv/touch/sort/cut), sed, awk,
#   procps (pidof/pkill), util-linux (flock), rofi, wl-clipboard (wl-copy)

# Variables
rofi_theme="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-emoji.rasi"
msg='👀 Tape en français (cœur, feu, rire…) ou en anglais · Entrée = copier · Ctrl+V pour coller'
usage_file="${XDG_STATE_HOME:-$HOME/.local/state}/rofi-emoji/usage"

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true

# Emoji list as a quoted here-doc: bash parses it as data, not code,
# so static tooling (bash -n, shellcheck, shfmt) all succeed. No
# marker line or bare 'exit' guard is needed.
read -r -d '' data <<'EMOJI_DATA' || true
😀 visage rieur  ·  content, dents, émoticône, grand sourire, heureux, joyeux, rire, sourire, super, visage, visage très souriant  ·  grinning face face smile happy joy :D grin  emoticone visage tres souriant
😃 visage souriant avec de grands yeux  ·  content, dents, émoticône, formidable, grand sourire, heureux, sourire, super, visage très souriant avec la bouche ouverte  ·  grinning face with big eyes face happy joy haha :D :) smile funny  emoticone visage tres souriant avec la bouche ouverte
😄 visage très souriant aux yeux rieurs  ·  content, émoticône, grand sourire, heureux, joyeux, lol, mdr, rire, sourire, sourire mignon, visage avec la bouche ouverte et les yeux souriants  ·  grinning face with smiling eyes face happy joy funny haha laugh like :D :) smile  visage tres souriant aux yeux rieurs emoticone
😁 visage souriant aux yeux rieurs  ·  content, dents, émoticône, grand sourire, heureux, sourire, sourire de toutes ses dents, super, visage, visage souriant avec yeux souriants, yeux souriants  ·  beaming face with smiling eyes face happy smile joy kawaii  emoticone
😆 visage souriant avec yeux plissés  ·  ahah, bouche, content, émoticône, lol, mdr, rire, sourire, visage, visage souriant avec bouche ouverte et yeux fermés  ·  grinning squinting face happy joy lol satisfied haha face glad XD laugh  visage souriant avec yeux plisses emoticone visage souriant avec bouche ouverte et yeux fermes
😅 visage souriant avec une goutte de sueur  ·  émoticône, excité, froid, goutte, sourire, sourire nerveux, stressé, sueur, sueurs froides  ·  grinning face with sweat face hot happy laugh sweat smile relief  emoticone excite stresse
🤣 se rouler par terre de rire  ·  content, drôle, émoticône, hilare, joyeux, larmes, lol, mdr, pleurer de rire, rire, rire aux larmes, se rouler par terre, se tordre de rire, visage, visage qui rit aux larmes  ·  rolling on the floor laughing face rolling floor laughing lol haha rofl  drole emoticone
😂 visage riant aux larmes  ·  content, émoticône, heureux, joie, larmes, lol, mdr, pleurer de joie, pleurer de rire, rire aux larmes, sourire  ·  face with tears of joy face cry tears weep happy happytears haha  emoticone
🙂 visage avec un léger sourire  ·  content, émoticône, heureux, léger sourire, sourire, visage souriant  ·  slightly smiling face face smile  visage avec un leger sourire emoticone leger sourire
🙃 tête à l’envers  ·  émoticône, incroyable, renversée, tête, visage  ·  upside down face face flipped silly smile  tete a l'envers emoticone renversee tete
😉 visage faisant un clin d’œil  ·  blague, clin d’œil, émoticône, flirter, plaisanter, sexy, visage  ·  winking face face happy mischievous secret ;) smile eye  visage faisant un clin d'oeil clin d'oeil emoticone
😊 visage souriant avec yeux rieurs  ·  content, émoticône, heureux, œil, rougir, satisfait, sourire, visage, visage qui rougit, visage souriant avec yeux souriants, yeux  ·  smiling face with smiling eyes face smile happy flushed crush embarrassed shy joy  emoticone oeil
😇 visage souriant avec auréole  ·  ange, angélique, auréole, béni, Bible, émoticône, heureux, innocent, paix, sourire, spirituel  ·  smiling face with halo face angel heaven halo  visage souriant avec aureole angelique aureole beni emoticone
🥰 visage souriant avec cœurs  ·  adorer, aimer, amour, béguin, coeur, cœurs, j’adore, Je t’aime, smiley avec 3 coeurs, sourire  ·  smiling face with hearts face love like affection valentines infatuation crush hearts adore  visage souriant avec coeurs beguin coeurs j'adore Je t'aime
😍 visage souriant avec yeux en forme de cœur  ·  amour, amoureux, cœur, émoticône, œil, romantique, sourire, visage, yeux  ·  smiling face with heart eyes face love like affection valentines infatuation crush heart  visage souriant avec yeux en forme de coeur coeur emoticone oeil
🤩 visage avec des étoiles à la place des yeux  ·  étoile, étoiles dans les yeux, grand sourire, heureux, pressé, surexcité, tête avec étoiles, visage, wow, yeux  ·  star struck face smile starry eyes grinning  visage avec des etoiles a la place des yeux etoile etoiles dans les yeux presse surexcite tete avec etoiles
😘 visage envoyant un bisou  ·  amour, baiser, bise, bisou et cœur, bonjour, bonne nuit, cœur, embrasser, émoticône, je t’aime, visage qui fait une bise avec un cœur  ·  face blowing a kiss face love like affection valentines infatuation kiss  bisou et coeur coeur emoticone je t'aime visage qui fait une bise avec un coeur
😗 visage faisant un bisou  ·  amour, baiser, bise, bisou, embrasser, émoticône, je t’aime, petit bisou, visage qui fait une bise  ·  kissing face love like face 3 valentines infatuation kiss  emoticone je t'aime
☺️ visage souriant  ·  content, décontracté, détendu, émoticône, heureux, sourire, visage souriant avec les yeux fermés  ·  smiling face face blush massage happiness  decontracte detendu emoticone visage souriant avec les yeux fermes
😚 visage faisant un bisou avec les yeux fermés  ·  baiser, bise, bisou, bisou les yeux fermés, embrasser, émoticône, rougir, visage qui fait une bise avec les yeux fermés, visage rougissant, yeux fermés  ·  kissing face with closed eyes face love like affection valentines infatuation kiss  visage faisant un bisou avec les yeux fermes bisou les yeux fermes emoticone visage qui fait une bise avec les yeux fermes yeux fermes
😙 visage aux yeux rieurs faisant un bisou  ·  amour, baiser, bise, bisou, embrasser, émoticône, gros bisou, je t’aime, sourire, visage aux yeux souriants qui fait une bise, yeux fermés  ·  kissing face with smiling eyes face affection valentines infatuation kiss  emoticone je t'aime yeux fermes
😋 miam  ·  bon, content, délicieux, émoticône, faim, heureux, langue, manger, savourer, sourire, visage souriant qui tire la langue  ·  face savoring food happy joy tongue smile face silly yummy nom delicious savouring  delicieux emoticone
😛 visage qui tire la langue  ·  cool, émoticône, génial, langue, super, visage  ·  face with tongue face prank childish playful mischievous smile tongue  emoticone genial
😜 visage qui tire la langue et fait un clin d’œil  ·  amusant, blague, clin d’œil, émoticône, fou, langue, loufoque, marrant, œil, rigolo, visage  ·  winking face with tongue face prank childish playful mischievous smile wink tongue  visage qui tire la langue et fait un clin d'oeil clin d'oeil emoticone oeil
🤪 tête de fou  ·  grand, large, oeil, œil, petit, tête folle, yeux, yeux fous  ·  zany face face goofy crazy  tete de fou oeil tete folle
😝 visage qui tire la langue les yeux plissés  ·  dégoûtant, émoticône, goût, horrible, langue, œil, omd, on ne vit qu’une fois, peu importe, visage qui tire la langue et ferme les yeux, yeux fermés  ·  squinting face with tongue face prank playful mischievous smile tongue  visage qui tire la langue les yeux plisses degoutant emoticone gout oeil on ne vit qu'une fois yeux fermes
🤑 argent dans les yeux et la bouche  ·  argent, bouche, dollars, émoticône, yeux  ·  money mouth face face rich dollar money  emoticone
🤗 visage qui fait un câlin  ·  câlin, émoticône, gentil, mains, visage  ·  hugging face face smile hug  visage qui fait un calin calin emoticone
🤭 visage avec une main sur la bouche  ·  malin, oops, oups, rigole, secret, surprise, visage avec main devant la bouche  ·  face with hand over mouth face whoops shock surprise
🤫 visage avec un doigt sur la bouche  ·  chut, pas un bruit, silence, tête qui dit chut  ·  shushing face face quiet shhh  tete qui dit chut
🤔 visage en pleine réflexion  ·  émoticône, hum, méditer, penser, réfléchir, réflexion, visage  ·  thinking face face hmmm think consider  visage en pleine reflexion emoticone mediter reflechir reflexion
🤐 visage avec bouche fermeture éclair  ·  bouche, bouche cousue, émoticône, fermeture éclair, motus, se taire, secret, visage, visage avec bouche cousue  ·  zipper mouth face face sealed zipper secret  visage avec bouche fermeture eclair emoticone fermeture eclair
🤨 visage avec les sourcils relevés  ·  euh, hein, incrédule, méfiant, pas vrai, quoi, sceptique, surprise, tête avec sourcil levé  ·  face with raised eyebrow face distrust scepticism disapproval disbelief surprise  visage avec les sourcils releves incredule mefiant tete avec sourcil leve
😐 visage neutre  ·  émoticône, gêné, neutre, ni chaud ni froid, pas drôle, peu importe, rester de marbre, sans commentaires, sans rire, visage sans expression  ·  neutral face indifference meh :| neutral  emoticone gene pas drole
😑 visage sans expression  ·  émoticône, inexpressif, mécontent, neutre, peu importe, sans expression, visage  ·  expressionless face face indifferent - - meh deadpan  emoticone mecontent
😶 visage sans bouche  ·  émoticône, muet, ne rien dire, neutre, sans commentaires, sans expression, sans voix, se taire, secret, silence, sourdine  ·  face without mouth face hellokitty  emoticone
😏 visage avec un sourire malin  ·  arrogant, charmeur, émoticône, malin, ricaner, rusé, séducteur, sourire, sourire suffisant, suspicieux, visage avec un sourire suffisant  ·  smirking face face smile mean prank smug sarcasm  emoticone ruse seducteur
😒 visage blasé  ·  bizarre, blasé, émoticône, énervé, fâché, jaloux, pas content, peu importe, visage, visage qui s’ennuie  ·  unamused face indifference bored straight face serious sarcasm unimpressed skeptical dubious side eye  visage blase blase emoticone enerve fache visage qui s'ennuie
🙄 visage roulant des yeux  ·  agacé, émoticône, excédé, incrédulité, roulement, visage qui lève les yeux au ciel, visage qui roule des yeux, yeux  ·  face with rolling eyes face eyeroll frustrated  agace emoticone excede incredulite visage qui leve les yeux au ciel
😬 visage grimaçant  ·  dents, émoticône, gêné, grimace, rien, sourire, visage  ·  grimacing face face grimace teeth  visage grimacant emoticone gene
🤥 visage de menteur  ·  émoticône, mensonge, menteur, pinocchio, visage, visage dont le nez s’allonge  ·  lying face face lie pinocchio  emoticone visage dont le nez s'allonge
😌 visage soulagé  ·  calme, émoticône, sérénité, soulagement, visage, zen  ·  relieved face face relaxed phew massage happiness  visage soulage emoticone serenite
😔 visage pensif  ·  abattu, déçu, émoticône, horrible, mort, pensif, perdu, triste, visage  ·  pensive face face sad depressed upset  decu emoticone
😪 visage endormi  ·  émoticône, fatigué, larme, pleurer, sommeil, triste, visage  ·  sleepy face face tired rest nap  emoticone fatigue
🤤 visage qui bave  ·  baver, délicieux, émoticône, mmh, visage  ·  drooling face face  delicieux emoticone
😴 visage somnolent  ·  bonne nuit, coucher, dormir, émoticône, endormi, fatigué, sieste, sommeil, visage, zzz  ·  sleeping face face tired sleepy night zzz  emoticone fatigue
😷 visage avec masque  ·  bactéries, dentiste, docteur, émoticône, germes, malade, masque, masque chirurgical, médecin, rhume  ·  face with medical mask face sick ill disease  bacteries emoticone medecin
🤒 visage avec thermomètre  ·  indisposé, malade, thermomètre, visage  ·  face with thermometer sick temperature thermometer cold fever  visage avec thermometre indispose thermometre
🤕 visage avec bandage autour de la tête  ·  aïe, bandage, blessure, bobo, émoticône, pansement, tête, tête avec un bandage, visage  ·  face with head bandage injured clumsy bandage hurt  visage avec bandage autour de la tete aie emoticone tete tete avec un bandage
🤢 visage nauséeux  ·  dégoûtant, écœuré, émoticône, malade, nausée, visage, visage vert qui a la nausée, vomir  ·  nauseated face face vomit gross green sick throw up ill  visage nauseeux degoutant ecoeure emoticone nausee visage vert qui a la nausee
🤮 visage qui vomit  ·  gerbe, gerber, malade, tête qui vomit, vomi, vomissure  ·  face vomiting face sick  tete qui vomit
🤧 visage qui éternue  ·  à tes souhaits, atchoum, émoticône, éternuement, éternuer, fièvre, grippe, malade, mouchoir, rhume, se moucher  ·  sneezing face face gesundheit sneeze sick allergy  visage qui eternue a tes souhaits emoticone eternuement eternuer fievre
🥵 visage rouge et chaud  ·  chaleur, chaud, coup de chaleur, coup de chaud, fièvre, sue, suer, toute rouge, transpiration, trop chaud, visage tout rouge  ·  hot face face feverish heat red sweating  fievre
🥶 visage bleu et froid  ·  bleu, ça caille, froid, gel, gelé, gelure, glacé, glacial, glaçon, visage bleu  ·  cold face face blue freezing frozen frostbite icicles  ca caille gele glace glacon
🥴 visage éméché  ·  bouche ondulée, bourré, bourrée, dans les vapes, hébété, pas clair, pompette, rond, saoul, souler, tête qui tourne  ·  woozy face face dizzy intoxicated tipsy wavy  visage emeche bouche ondulee bourre bourree hebete tete qui tourne
😵 visage étourdi  ·  émoticône, fatigué, malade, mort, tournis, visage, visage avec le tournis  ·  dizzy face spent unconscious xox dizzy  visage etourdi emoticone fatigue
🤯 tête qui explose  ·  choc, choqué, surpris, surprise, tête choquée  ·  exploding head face shocked mind blown  tete qui explose choque tete choquee
🤠 visage avec chapeau de cowboy  ·  chapeau, cowboy, visage  ·  cowboy hat face face cowgirl hat
🥳 visage festif  ·  anniversaire, célébration, chapeau pointu, émoticône, fête, heureux, hourra, joyeux anniversaire, sifflet, visage de fête, youpi  ·  partying face face celebration woohoo  celebration emoticone fete visage de fete
😎 visage avec lunettes de soleil  ·  cool, lunettes de soleil, posé, tranquille  ·  smiling face with sunglasses face cool smile summer beach sunglass  pose
🤓 visage de geek  ·  doué, futé, geek, idiot, intelligent, lunettes, personne, premier de la classe, ringard, surdoué, tronche  ·  nerd face face nerdy geek dork  doue fute surdoue
🧐 visage avec un monocle  ·  classe, collet monté, fortune, monocle, riche, tête avec monocle, vieux jeu  ·  face with monocle face stuffy wealthy  collet monte tete avec monocle
😕 visage confus  ·  confus, désolé, émoticône, ennuyé, je ne sais pas, triste, visage  ·  confused face face indifference huh weird hmmm :/  desole emoticone ennuye
😟 visage inquiet  ·  anxieux, émoticône, inquiet, préoccupé, stressé, surpris, triste, visage  ·  worried face face concern nervous :(  emoticone preoccupe stresse
🙁 visage légèrement mécontent  ·  émoticône, mécontent, triste, visage  ·  slightly frowning face face frowning disappointed sad upset  visage legerement mecontent emoticone mecontent
☹️ visage mécontent  ·  émoticône, malheureux, mécontent, triste, visage  ·  frowning face face sad upset frown  visage mecontent emoticone mecontent
😮 visage avec bouche ouverte  ·  bouche bée, bouche ouverte, choqué, émoticône, épaté, incroyable, omd, oubli, surpris, visage avec la bouche ouverte, visage étonné  ·  face with open mouth face surprise impressed wow whoa :O  bouche bee choque emoticone epate visage etonne
😯 visage ébahi  ·  émoticône, incroyable, omd, sans voix, stupéfait, stupeur, surpris, visage, visage à la bouche ouverte, visage sans voix  ·  hushed face face woo shh  visage ebahi emoticone stupefait visage a la bouche ouverte
😲 visage stupéfait  ·  choc, choqué, émoticône, étonné, impossible, incroyable, omd, stupéfait, visage  ·  astonished face face xox surprised poisoned  visage stupefait choque emoticone etonne stupefait
😳 visage qui rougit  ·  chaud, comment, ébahi, émoticône, étonné, gêné, impressionné, incrédule, incroyable, quoi, rouge  ·  flushed face face blush shy flattered  ebahi emoticone etonne gene impressionne incredule
🥺 visage implorant  ·  embarrassé, excuse, gros yeux, pardon, pitié, s’il te plaît, supplication, supplie, yeux de chiens battus  ·  pleading face face begging mercy  embarrasse pitie s'il te plait
😦 visage mécontent avec bouche ouverte  ·  bouche, déçu, effrayé, émoticône, ouverte, peur, pris au dépourvu, surpris, visage, visage déçu avec bouche ouverte  ·  frowning face with open mouth face aw what  visage mecontent avec bouche ouverte decu effraye emoticone pris au depourvu visage decu avec bouche ouverte
😧 visage angoissé  ·  angoisse, comment, émoticône, hein, mécontent, oubli, peur, quoi, stressé, surpris, terrifié  ·  anguished face face stunned nervous  visage angoisse emoticone mecontent stresse terrifie
😨 visage effrayé  ·  anxieux, apeuré, blême, effrayé, émoticône, inquiet, peur, terrifié, visage  ·  fearful face face scared terrified nervous oops huh  visage effraye apeure bleme effraye emoticone terrifie
😰 visage anxieux avec goutte de sueur  ·  aah, bleu, bouche bée, effrayé, émoticône, froid, mince, nerveux, peur bleue, sueurs froides, terrifié, visage en sueur bouche ouverte  ·  anxious face with sweat face nervous sweat  bouche bee effraye emoticone terrifie
😥 visage triste mais soulagé  ·  déçu, émoticône, ouf, pfiou, soulagé, sueur, triste, visage déçu mais soulagé  ·  sad but relieved face face phew sweat nervous  visage triste mais soulage decu emoticone soulage visage decu mais soulage
😢 visage qui pleure  ·  émoticône, horrible, larme, larmes, malheureux, pleurer, triste  ·  crying face face tears sad depressed upset :'(  emoticone
😭 visage qui pleure à chaudes larmes  ·  émoticône, larme, larmes, malheureux, pleurer, pleurs, sangloter, triste, visage  ·  loudly crying face face cry tears sad upset depressed  visage qui pleure a chaudes larmes emoticone
😱 visage qui hurle de peur  ·  choqué, cri, effrayé, Munch, omd, peur, surpris, terreur, visage  ·  face screaming in fear face munch scared omg  choque effraye
😖 visage déconcerté  ·  confus, déconcerté, émoticône, fâché, frustré, irrité, triste, visage, yeux fermés  ·  confounded face face confused sick unwell oops :S  visage deconcerte deconcerte emoticone fache frustre irrite yeux fermes
😣 visage persévérant  ·  concentré, émoticône, mal de tête, migraine, persévérant, visage  ·  persevering face face sick no upset oops  visage perseverant concentre emoticone mal de tete perseverant
😞 visage déçu  ·  abattu, affreux, découragé, déçu, émoticône, malheureux, tort, triste, visage  ·  disappointed face face sad upset depressed :(  visage decu decourage decu emoticone
😓 visage démoralisé avec goutte de sueur  ·  émoticône, froide, mal de tête, migraine, mince, ouf, peur, sueur, triste, visage, visage et sueurs froides  ·  downcast face with sweat face hot sad tired exercise  visage demoralise avec goutte de sueur emoticone mal de tete
😩 visage épuisé  ·  échec, émoticône, épuisé, faim, fatigué, mécontent, non, pleurer, sommeil, triste, visage, visage las  ·  weary face face tired sleepy sad frustrated upset  visage epuise echec emoticone epuise fatigue mecontent
😫 visage fatigué  ·  contrarié, émoticône, fatigue, mécontent, triste, visage  ·  tired face sick whine upset frustrated  visage fatigue contrarie emoticone mecontent
🥱 visage bâillant  ·  bâille, bâiller, dormir, émoticône, ennui, fatigant, fatigue, sieste  ·  yawning face tired sleepy  visage baillant baille bailler emoticone
😤 visage avec fumée sortant des narines  ·  colère, émoticône, énervé, fâché, mécontent, triomphe, victoire, visage  ·  face with steam from nose face gas phew proud pride  visage avec fumee sortant des narines colere emoticone enerve fache mecontent
😡 visage boudeur  ·  colère, émoticône, énervé, exaspéré, fâché, furieux, mécontent, rageur, rouge, rouge de colère, sourcils froncés  ·  pouting face angry mad hate despise  colere emoticone enerve exaspere fache mecontent rouge de colere sourcils fronces
😠 visage en colère  ·  colère, émoticône, exaspéré, fâché, frustré, mécontent, rageur, sourcils froncés  ·  angry face mad face annoyed frustrated  visage en colere colere emoticone exaspere fache frustre mecontent sourcils fronces
🤬 visage avec des symboles dans la bouche  ·  censuré, colère, gros mots, insulter, insultes, jurer, juron, tête avec des symboles sur la bouche  ·  face with symbols on mouth face swearing cursing cussing profanity expletive  censure colere tete avec des symboles sur la bouche
😈 visage souriant avec des cornes  ·  cornes, émoticône, fâché, fantastique, sourire, visage  ·  smiling face with horns devil horns  emoticone fache
👿 visage en colère avec des cornes  ·  démon, diable, diablotin, émoticône, fantastique, malicieux, mauvais, visage  ·  angry face with horns devil angry horns  visage en colere avec des cornes demon emoticone
💀 crâne  ·  corps, dead, fantastique, je suis mort, mort, squelette, tête de mort, visage, yolo  ·  skull dead skeleton creepy death  crane tete de mort
☠️ tête de mort  ·  crâne, mort, os, tête  ·  skull and crossbones poison danger deadly scary death pirate evil  tete de mort crane tete
💩 tas de crotte  ·  bande dessinée, BD, caca, crotte, dessin, excrément, odeur, popo, puer, sentir mauvais, visage  ·  pile of poo hankey shitface fail turd shit  bande dessinee excrement
🤡 visage de clown  ·  clown, émoticône, maquillage, visage  ·  clown face face  emoticone
👹 ogre  ·  créature, effrayant, fantastique, japonais, masque, monstre  ·  ogre monster red mask halloween scary creepy devil demon japanese ogre  creature
👺 monstre japonais  ·  colère, créature, fantastique, farfadet, japonais, masque, méchant, monstre  ·  goblin red evil mask monster scary creepy japanese goblin  colere creature mechant
👻 fantôme  ·  blague, bouh, créature, effrayant, fantastique, Halloween, hanter, monstre, peur, visage, visage de fantôme  ·  ghost halloween spooky scary  fantome creature visage de fantome
👽 alien  ·  créature, émoticône, espace, extraterrestre, monstre, ovni, science-fiction, visage  ·  alien UFO paul weird outer space  creature emoticone
👾 monstre de l’espace  ·  alien, créature, envahisseur, espace, extraterrestre, fantastique, jeu vidéo, monstre, ovni, pixels  ·  alien monster game arcade play  monstre de l'espace creature jeu video
🤖 robot  ·  androïde, automate, machine, monstre, visage, visage de robot  ·  robot computer machine bot  androide
😺 chat qui sourit  ·  animal, bouche ouverte, chat, sourire, visage  ·  grinning cat animal cats happy smile
😸 chat qui sourit avec des yeux rieurs  ·  animal, chat, chat avec un grand sourire, sourire, visage, yeux rieurs, yeux souriants  ·  grinning cat with smiling eyes animal cats smile
😹 chat qui pleure de joie  ·  animal, chat, chat qui rit aux larmes, joie, larmes, lol, mdr, pleurer de rire, rire, rire aux larmes  ·  cat with tears of joy animal cats haha happy tears
😻 chat souriant aux yeux en cœurs  ·  amour, amoureux, chat, chat souriant avec des coeurs dans les yeux, cœur, coeurs, coeurs dans les yeux, sourire, yeux  ·  smiling cat with heart eyes animal love like affection cats valentines heart  chat souriant aux yeux en coeurs coeur
😼 chat avec sourire en coin  ·  animal, chat, ironique, narquois, sourire en coin, sourire narquois, tête de chat, visage  ·  cat with wry smile animal cats smirk  tete de chat
😽 chat qui fait un bisou  ·  animal, baiser, bise, bisou, chat, chat qui embrasse, chat qui fait une bise avec les yeux fermés, embrasser, tête de chat  ·  kissing cat animal cats kiss  chat qui fait une bise avec les yeux fermes tete de chat
🙀 chat fatigué  ·  animal, chat, fatigue, inquiet, oh, surpris, tête de chat avec la bouche ouverte, visage  ·  weary cat animal cats munch scared scream  chat fatigue tete de chat avec la bouche ouverte
😿 chat qui pleure  ·  animal, chat, larme, pleurer, tête de chat, triste, visage  ·  crying cat animal tears weep sad cats upset cry  tete de chat
😾 chat qui boude  ·  animal, bouder, chat, chat en colère, colère, désaccord, ennui, tête de chat, visage  ·  pouting cat animal cats  chat en colere colere desaccord tete de chat
🙈 singe ne rien voir  ·  animal, caché, effrayé, embarras, gêne, geste, interdit, ne pas voir, non, omd, oubli, peur, rien vu rien entendu, secret, singe, visage, voir, yeux  ·  see no evil monkey monkey animal nature haha  cache effraye gene
🙉 singe ne rien entendre  ·  animal, écouter, geste, interdit, ne pas entendre, non, oreilles, rien vu rien entendu, secret, singe, sourd, visage  ·  hear no evil monkey animal monkey nature  ecouter
🙊 singe ne rien dire  ·  animal, bouche cousue, chut, geste, interdit, motus, muet, non, parler, se taire, secret, silence, singe, visage  ·  speak no evil monkey monkey animal nature omg
💋 trace de rouge à lèvres  ·  baiser, bise, bisou, bouche, embrasser, lèvres, rendez-vous, rouge, sexy  ·  kiss mark face lips love like affection valentines  trace de rouge a levres levres
💌 lettre d’amour  ·  amour, cœur, lettre, Saint-Valentin  ·  love letter email like affection envelope valentines  lettre d'amour coeur
💘 cœur et flèche  ·  amour, cœur, coeur transpercé, Cupidon, flèche, sentiment  ·  heart with arrow love like heart affection valentines  coeur et fleche coeur coeur transperce fleche
💝 cœur avec ruban  ·  amour, anniversaire, cœur, ruban, Saint-Valentin, sentiment  ·  heart with ribbon love valentines  coeur avec ruban coeur
💖 cœur étincelant  ·  amour, cœur, étincelles, sentiment  ·  sparkling heart love like affection valentines  coeur etincelant coeur etincelles
💗 cœur grandissant  ·  amour, cœur, cœur battant, cœur qui bat, pulsations, sentiment  ·  growing heart like love affection valentines pink  coeur grandissant coeur coeur battant coeur qui bat
💓 cœur battant  ·  amour, cardio, cœur, cœur qui bat, pulsations, sentiment  ·  beating heart love like affection valentines pink heart  coeur battant coeur coeur qui bat
💞 cœurs qui tournent  ·  amour, anniversaire, cœurs, deux cœurs, sentiment, tourbillon  ·  revolving hearts love like affection valentines  coeurs qui tournent coeurs deux coeurs
💕 deux cœurs  ·  amour, anniversaire, cœurs, deux cœurs roses, petits cœurs, rendez-vous, sentiment  ·  two hearts love like affection valentines heart  deux coeurs coeurs deux coeurs roses petits coeurs
💟 décoration avec cœur  ·  amour, cœur, cœur blanc, cœur décoré, cœur violet, sentiment  ·  heart decoration purple-square love like  decoration avec coeur coeur coeur blanc coeur decore coeur violet
❣️ cœur point d’exclamation  ·  amour, cœur, exclamation, ponctuation  ·  heart exclamation decoration love  coeur point d'exclamation coeur
💔 cœur brisé  ·  amour, cœur, malheureux, sentiment, séparé, triste  ·  broken heart sad sorry break heart heartbreak  coeur brise coeur separe
❤️ cœur rouge  ·  amour, cœur, sentiment  ·  red heart love like valentines  coeur rouge coeur
🧡 cœur orange  ·  coeur orange, orange  ·  orange heart love like affection valentines  coeur orange
💛 cœur jaune  ·  amour, cœur, sentiment  ·  yellow heart love like affection valentines  coeur jaune coeur
💚 cœur vert  ·  amour, cœur, sentiment, vert  ·  green heart love like affection valentines  coeur vert coeur
💙 cœur bleu  ·  amour, cœur, sentiment  ·  blue heart love like affection valentines  coeur bleu coeur
💜 cœur violet  ·  amour, cœur, sentiment, violet  ·  purple heart love like affection valentines  coeur violet coeur
🤎 cœur marron  ·  brun, cœur, marron  ·  brown heart coffee  coeur marron coeur
🖤 cœur noir  ·  cœur, noir  ·  black heart evil  coeur noir coeur
🤍 cœur blanc  ·  blanc, cœur  ·  white heart pure  coeur blanc coeur
💯 cent points  ·  100, cent, score  ·  hundred points score perfect numbers century exam quiz test pass hundred
💢 symbole de colère  ·  bande dessinée, BD, colère, dessin, furieux  ·  anger symbol angry mad  symbole de colere bande dessinee colere
💥 explosion  ·  bande dessinée, BD, bombe, boum, collision, détonation, étincelles  ·  collision bomb explode explosion collision blown  bande dessinee detonation etincelles
💫 étourdissement  ·  bande dessinée, BD, étincelles, étoile, étoile filante, tournis, voir des étoiles  ·  dizzy star sparkle shoot magic  etourdissement bande dessinee etincelles etoile etoile filante voir des etoiles
💦 gouttes de sueur  ·  bande dessinée, BD, eau, éclabousser, éclaboussures, effort, entraînement, gouttes, sueur  ·  sweat droplets water drip oops  bande dessinee eclabousser eclaboussures entrainement
💨 décamper  ·  bande dessinée, BD, déguerpir, détaler, filer, fumée, nuage, partir en courant, pet, vent, vite  ·  dashing away wind air fast shoo fart smoke puff  decamper bande dessinee deguerpir detaler fumee
🕳️ trou  ·  hole embarrassing
💣 bombe  ·  bande dessinée, BD, boum, danger, dessin, explosion  ·  bomb boom explode explosion terrorism  bande dessinee
💬 bulle de parole  ·  bande dessinée, BD, bulle, dialogue, écrire, message, SMS  ·  speech balloon bubble words message talk chatting  bande dessinee ecrire
👁️‍🗨️ œil dans une bulle de BD  ·  bande dessinée, BD, bulle de BD, œil, témoin, voir  ·  eye in speech bubble info  oeil dans une bulle de BD bande dessinee oeil temoin
🗨️ bulle de parole gauche  ·  bulle, bulle à gauche, dialogue, gauche  ·  left speech bubble words message talk chatting  bulle a gauche
🗯️ bulle colère droite  ·  bande dessinée, BD, bulle, colère, crier, droite, hurler  ·  right anger bubble caption speech thinking mad  bulle colere droite bande dessinee colere
💭 bulle de pensée  ·  bande dessinée, BD, bulle, idée, imaginer, inventer, invention, pensée, penser, rêve, rêver  ·  thought balloon bubble cloud speech thinking dream  bulle de pensee bande dessinee idee pensee reve rever
💤 endormi  ·  bande dessinée, BD, bonne nuit, dormir, fatigué, ronfler, zzz  ·  zzz sleepy tired dream  bande dessinee fatigue
👋 signe de la main  ·  à bientôt, à plus tard, au revoir, bonjour, bye, coucou, hello, il y a quelqu’un ?, main, main qui salue, salut, signe  ·  waving hand hands gesture goodbye solong farewell hello hi palm  a bientot a plus tard il y a quelqu'un ?
🤚 dos de main levée  ·  levée, main  ·  raised back of hand fingers raised backhand  dos de main levee levee
🖐️ main levée doigts écartés  ·  doigts, main, paume, stop  ·  hand with fingers splayed hand fingers palm  main levee doigts ecartes
✋ main levée  ·  feuille, main, paume de la main, stop, tope là  ·  raised hand fingers stop highfive palm ban  main levee tope la
🖖 salut vulcain  ·  doigts, main, Spock, Star Trek, vulcain  ·  vulcan salute hand fingers spock star trek
👌 ok  ·  compris, d’accord, geste, main, nickel, OK, parfait, super, tout va bien  ·  ok hand fingers limbs perfect ok okay  d'accord
🤏 pouce et index rapprochés  ·  à deux doigts, petit, petite, petite quantité, petite somme, peu, un peu  ·  pinching hand tiny small size  pouce et index rapproches a deux doigts petite quantite
✌️ V de la victoire  ·  ciseaux, doigts, main, paix et amour, peace and love, victoire  ·  victory hand fingers ohyeah hand peace victory two
🤞 doigts croisés  ·  bonne chance, chance, croisés, doigts, main  ·  crossed fingers good lucky  doigts croises croises
🤟 signe je t’aime  ·  amour, geste pour je t’aime, ILY, je t’aime, main, trois doigts  ·  love you gesture hand fingers gesture  signe je t'aime geste pour je t'aime je t'aime
🤘 cornes avec les doigts  ·  cornes, cornes du diable, doigts, main, rock, rock’n roll, yeah  ·  sign of the horns hand fingers evil eye sign of horns rock on  rock'n roll
🤙 signe appel téléphonique avec les doigts  ·  appel, main, signe, téléphone  ·  call me hand hands gesture shaka  signe appel telephonique avec les doigts telephone
👈 main avec index pointant à gauche  ·  doigt, gauche, index, index pointé vers la gauche, main  ·  backhand index pointing left direction fingers hand left  main avec index pointant a gauche index pointe vers la gauche
👉 main avec index pointant à droite  ·  doigt, droite, index, index pointé vers la droite, main  ·  backhand index pointing right fingers hand direction right  main avec index pointant a droite index pointe vers la droite
👆 main avec index pointant vers le haut  ·  doigt, haut, index, index vers le haut, main, montrer  ·  backhand index pointing up fingers hand direction up
🖕 doigt d’honneur  ·  doigt, main, majeur  ·  middle finger hand fingers rude middle flipping  doigt d'honneur
👇 main avec index pointant vers le bas  ·  bas, doigt, index, index vers le bas, main, montrer  ·  backhand index pointing down fingers hand direction down
☝️ index pointant vers le haut  ·  doigt, haut, index, index pointé vers le haut, main, moi  ·  index pointing up hand fingers direction up  index pointe vers le haut
👍 pouce vers le haut  ·  bien, compris, d’accord, génial, haut, main, moi aussi, OK, oui, pouce levé, super, top  ·  thumbs up thumbsup yes awesome good agree accept cool hand like +1  d'accord genial pouce leve
👎 pouce vers le bas  ·  bas, main, mauvais, non, nul, pouce, pouce baissé  ·  thumbs down thumbsdown no dislike hand -1  pouce baisse
✊ poing levé  ·  main, pierre, poing, poing serré, solidarité  ·  raised fist fingers hand grasp  poing leve poing serre solidarite
👊 poing de face  ·  absolument, battre, boum, correct, coup de poing, d’accord, main, mon pote, poing, serrer  ·  oncoming fist angry violence fist hit attack hand  d'accord
🤛 poing à gauche  ·  fistbump, gauche, main, poing  ·  left facing fist hand fistbump  poing a gauche
🤜 poing à droite  ·  droite, main, poing  ·  right facing fist hand fistbump  poing a droite
👏 applaudissements  ·  bien joué, bon travail, bravo, félicitations, formidable, geste, mains, mains qui applaudissent, super  ·  clapping hands hands praise applause congrats yay  bien joue felicitations
🙌 mains levées  ·  air, geste, hourra, mains, mains en l’air, youpi  ·  raising hands gesture hooray yea celebration hands  mains levees mains en l'air
👐 mains ouvertes  ·  main, mains écartées, ouvert  ·  open hands fingers butterfly hands open  mains ecartees
🤲 paume contre paume doigts vers le haut  ·  espérer, mains, paumes des mains ensemble, prier, prière  ·  palms up together hands gesture cupped prayer  esperer priere
🤝 poignée de main  ·  d’accord, main, mains, marché conclu, poignée, présentation, rencontre, serrer la main  ·  handshake agreement shake  poignee de main d'accord marche conclu poignee presentation
🙏 mains en prière  ·  demander, félicitations, mains, mains l’une contre l’autre, merci, prier, prière, s’il te plaît, s’il vous plaît, salut, se taper dans la main, tope là  ·  folded hands please hope wish namaste highfive pray  mains en priere felicitations mains l'une contre l'autre priere s'il te plait s'il vous plait tope la
✍️ main qui écrit  ·  écrire, main  ·  writing hand lower left ballpoint pen stationery write compose  main qui ecrit ecrire
💅 vernis à ongles  ·  cosmétiques, manucure, maquillage, peu importe, s’ennuyer  ·  nail polish beauty manicure finger fashion nail  vernis a ongles cosmetiques s'ennuyer
🤳 selfie  ·  appareil photo, photo, téléphone  ·  selfie camera phone  telephone
💪 biceps contracté  ·  bande dessinée, BD, biceps, bodybuilding, contracté, corps, culturisme, entraînement, exercice, force, haltérophilie, muscle, muscles, soulever  ·  flexed biceps arm flex hand summer strong biceps  biceps contracte bande dessinee contracte entrainement halterophilie
🦾 bras mécanique  ·  accessibilité, bras, bras robot, handicap, prothèse, prothèse de bras  ·  mechanical arm accessibility  bras mecanique accessibilite prothese prothese de bras
🦿 jambe mécanique  ·  accessibilité, handicap, jambe artificielle, jambe robot, prothèse, prothèse de jambe  ·  mechanical leg accessibility  jambe mecanique accessibilite prothese prothese de jambe
🦵 jambe  ·  coup de pied, cuisse, genou, genou fléchi, genoux, membre, pied  ·  leg kick limb  genou flechi
🦶 pied  ·  cheville, coup de pied, pas lourd  ·  foot kick stomp
👂 oreille  ·  corps, écouter, entendre, ouïe, son  ·  ear face hear sound listen  ecouter ouie
🦻 oreille appareillée  ·  accessibilité, handicap, malentendant, prothèse auditive, sonotone, sourd, surdité  ·  ear with hearing aid accessibility  oreille appareillee accessibilite prothese auditive surdite
👃 nez  ·  corps, narines, odeur, sentir  ·  nose smell sniff
🧠 cerveau  ·  intelligent, intelligente  ·  brain smart intelligent
🦷 dent  ·  carie, dentiste, émail diamant  ·  tooth teeth dentist  email diamant
🦴 os  ·  chien, halloween, squelette  ·  bone skeleton
👀 yeux  ·  chercher, corps, coup d’œil, œil, regarder, visage, voir  ·  eyes look watch stalk peek see  coup d'oeil oeil
👁️ œil  ·  corps  ·  eye face look see watch stare  oeil
👅 langue  ·  corps, lécher  ·  tongue mouth playful  lecher
👄 bouche  ·  baiser, beauté, bise, bisou, corps, embrasser, lèvres, rouge à lèvres  ·  mouth mouth kiss  beaute levres rouge a levres
👶 bébé  ·  émoticône, enceinte, enfant, nouveau-né, petit  ·  baby child boy girl toddler  bebe emoticone nouveau-ne
🧒 enfant  ·  genre neutre, jeune, non-genré  ·  child gender-neutral young  non-genre
👦 garçon  ·  émoticône, enfant, jeune, personne  ·  boy man male guy teenager  garcon emoticone
👧 fille  ·  couettes, émoticône, enfant, grands yeux, jeune, nattes, personne, petite fille, tresses, vierge, visage, zodiaque  ·  girl female woman teenager  emoticone
🧑 adulte  ·  genre neutre, non-genré  ·  person gender-neutral person  non-genre
👱 personne blonde  ·  blond, cheveux, garçon, homme, humain, tête, visage  ·  person blond hair hairstyle  garcon tete
👨 homme  ·  ami, garçon, personne, petit ami, pote  ·  man mustache father dad guy classy sir moustache  garcon
🧔 personne barbue  ·  barbe, barbu, personne avec une barbe  ·  man beard person bewhiskered
👨‍🦰 homme : cheveux roux  ·  ami, cheveux roux, garçon, homme, personne, petit ami, pote  ·  man red hair hairstyle  garcon
👨‍🦱 homme : cheveux bouclés  ·  ami, cheveux bouclés, garçon, homme, personne, petit ami, pote  ·  man curly hair hairstyle  homme : cheveux boucles cheveux boucles garcon
👨‍🦳 homme : cheveux blancs  ·  ami, cheveux blancs, garçon, homme, personne, petit ami, pote  ·  man white hair old elder  garcon
👨‍🦲 homme : chauve  ·  ami, chauve, garçon, homme, personne, petit ami, pote  ·  man bald hairless  garcon
👩 femme  ·  blonde, coupe de cheveux, personne  ·  woman female girls lady
👩‍🦰 femme : cheveux roux  ·  blonde, cheveux roux, coupe de cheveux, femme, personne  ·  woman red hair hairstyle
🧑‍🦰 adulte : cheveux roux  ·  adulte, cheveux roux, genre neutre, non-genré  ·  person red hair hairstyle  non-genre
👩‍🦱 femme : cheveux bouclés  ·  blonde, cheveux bouclés, coupe de cheveux, femme, personne  ·  woman curly hair hairstyle  femme : cheveux boucles cheveux boucles
🧑‍🦱 adulte : cheveux bouclés  ·  adulte, cheveux bouclés, genre neutre, non-genré  ·  person curly hair hairstyle  adulte : cheveux boucles cheveux boucles non-genre
👩‍🦳 femme : cheveux blancs  ·  blonde, cheveux blancs, coupe de cheveux, femme, personne  ·  woman white hair old elder
🧑‍🦳 adulte : cheveux blancs  ·  adulte, cheveux blancs, genre neutre, non-genré  ·  person white hair elder old  non-genre
👩‍🦲 femme : chauve  ·  blonde, chauve, coupe de cheveux, femme, personne  ·  woman bald hairless
🧑‍🦲 adulte : chauve  ·  adulte, chauve, genre neutre, non-genré  ·  person bald hairless  non-genre
👱‍♀️ femme blonde  ·  blonde, cheveux, femme, personne  ·  woman blond hair woman female girl blonde person
👱‍♂️ homme blond  ·  blond, cheveux  ·  man blond hair man male boy blonde guy person
🧓 personne âgée  ·  adulte, âgé, genre neutre, non-genré  ·  older person human elder senior gender-neutral  personne agee age non-genre
👴 homme âgé  ·  âgé, chauve, émoticône, grand-père, homme, papi, personne, personne âgée, sage, vieux monsieur  ·  old man human male men old elder senior  homme age age emoticone grand-pere personne agee
👵 femme âgée  ·  âgée, blonde, dame, émoticône, femme, grand-mère, mamie, personne, sage  ·  old woman human female women lady old elder senior  femme agee agee emoticone grand-mere
🙍 personne fronçant les sourcils  ·  contrariée, déçue, embêtée, femme, froncer, gênée, geste, mécontente, pas contente, personne, sourcils, triste  ·  person frowning worried  personne froncant les sourcils contrariee decue embetee genee mecontente
🙍‍♂️ homme fronçant les sourcils  ·  froncement, geste, homme, homme mécontent, homme renfrogné  ·  man frowning male boy man sad depressed discouraged unhappy  homme froncant les sourcils homme mecontent homme renfrogne
🙍‍♀️ femme fronçant les sourcils  ·  femme, froncement, geste  ·  woman frowning female girl woman sad depressed discouraged unhappy  femme froncant les sourcils
🙎 personne qui boude  ·  bouder, déçue, énervée, expression, fâchée, faire la tête, femme, froncer les sourcils, geste, inquiète, moue, personne  ·  person pouting upset  decue enervee fachee faire la tete inquiete
🙎‍♂️ homme qui boude  ·  boude, bouder, faire la moue, geste, homme, moue  ·  man pouting male boy man
🙎‍♀️ femme qui boude  ·  boude, femme, geste  ·  woman pouting female girl woman
🙅 personne faisant un geste d’interdiction  ·  aucune chance, bloquer, femme, geste, impossible, interdit, main, niet, non, pas possible, stop  ·  person gesturing no decline  personne faisant un geste d'interdiction
🙅‍♂️ homme faisant un geste d’interdiction  ·  geste, homme, interdit, main, non  ·  man gesturing no male boy man nope  homme faisant un geste d'interdiction
🙅‍♀️ femme faisant un geste d’interdiction  ·  femme, geste, interdit, main  ·  woman gesturing no female girl woman nope  femme faisant un geste d'interdiction
🙆 personne faisant un geste d’acceptation  ·  d’accord, danser, exercice, femme, geste, grandir, lever les bras, main, OK, personne  ·  person gesturing ok agree  personne faisant un geste d'acceptation d'accord
🙆‍♂️ homme faisant un geste d’acceptation  ·  d’accord, geste, homme, homme faisant un geste d’accord, main, ok  ·  man gesturing ok men boy male blue human man  homme faisant un geste d'acceptation d'accord homme faisant un geste d'accord
🙆‍♀️ femme faisant un geste d’acceptation  ·  femme, geste d’accord, main, ok  ·  woman gesturing ok women girl female pink human woman  femme faisant un geste d'acceptation geste d'accord
💁 personne paume vers le haut  ·  aide, diva, femme, information, insouciante, main, personne, peu importe, potins, prétentieuse, sarcastique, sophistiqué  ·  person tipping hand information  pretentieuse sophistique
💁‍♂️ homme paume vers le haut  ·  aide, apporter, diva, homme, homme avec paume vers le haut, informations, insolent, main, paume vers le haut, peu importe, potins, sarcastique  ·  man tipping hand male boy man human information
💁‍♀️ femme paume vers le haut  ·  femme, paume vers le haut  ·  woman tipping hand female girl woman human information
🙋 personne qui lève la main  ·  compte sur moi, content, femme qui lève la main, geste, ici, je sais, levée, main, moi, participer, présente  ·  person raising hand question  personne qui leve la main femme qui leve la main levee presente
🙋‍♂️ homme qui lève la main  ·  geste, homme, je sais, main, main levée, moi, personne qui lève la main, répondre  ·  man raising hand male boy man  homme qui leve la main main levee personne qui leve la main repondre
🙋‍♀️ femme qui lève la main  ·  femme, geste, main levée  ·  woman raising hand female girl woman  femme qui leve la main main levee
🧏 personne sourde  ·  accessibilité, entendre, malentendant, oreille, sourd, surdité  ·  deaf person accessibility  accessibilite surdite
🧏‍♂️ homme sourd  ·  accessibilité, entendre, malentendant, oreille, sourd  ·  deaf man accessibility  accessibilite
🧏‍♀️ femme sourde  ·  accessibilité, entendre, malentendant, oreille, sourd  ·  deaf woman accessibility  accessibilite
🙇 personne qui s’incline  ·  confus, désolé, excuses, geste, gronder, incliné, j’ai compris, OK, pardon, personne inclinée  ·  person bowing respectiful  personne qui s'incline desole incline j'ai compris personne inclinee
🙇‍♂️ homme qui s’incline  ·  désolé, geste, homme, incliné  ·  man bowing man male boy  homme qui s'incline desole incline
🙇‍♀️ femme qui s’incline  ·  désolée, excuses, femme, femme qui se prosterne, geste, inclinée, méditation, méditer  ·  woman bowing woman female girl  femme qui s'incline desolee inclinee meditation mediter
🤦 personne avec la paume sur le visage  ·  drame, exaspération, femme avec paume sur visage, geste, incrédulité, incroyable, j’en peux plus, main, pas possible, paume de main, personne, visage  ·  person facepalming disappointed  exasperation incredulite j'en peux plus
🤦‍♂️ homme avec la paume sur le visage  ·  encore, exaspération, homme, incrédulité, incroyable, main sur le visage, oh non, oubli, paume, personne  ·  man facepalming man male boy disbelief  exasperation incredulite
🤦‍♀️ femme avec la paume sur le visage  ·  encore, exaspération, femme, incrédulité, incroyable, j’y crois pas, main sur le visage, oh non, oubli, paume, personne  ·  woman facepalming woman female girl disbelief  exasperation incredulite j'y crois pas
🤷 personne qui hausse les épaules  ·  aucune idée, c’est comme ça, doute, femme qui hausse les épaules, haussement d’épaules, ignorance, indifférence, je ne sais pas, personne, peut-être, que faire, qui sait  ·  person shrugging regardless  personne qui hausse les epaules aucune idee c'est comme ca femme qui hausse les epaules haussement d'epaules indifference peut-etre
🤷‍♂️ homme qui hausse les épaules  ·  aucune idée, doute, haussement, haussement d’épaules, homme, ignorance, indifférence, pas moi, personne, rien vu, sais pas  ·  man shrugging man male boy confused indifferent doubt  homme qui hausse les epaules aucune idee haussement d'epaules indifference
🤷‍♀️ femme qui hausse les épaules  ·  aucune idée, doute, femme, haussement, haussement d’épaules, ignorance, indifférence, je sais pas, pas moi, personne, rien vu  ·  woman shrugging woman female girl confused indifferent doubt  femme qui hausse les epaules aucune idee haussement d'epaules indifference
🧑‍⚕️ professionnel de la santé (tous genres)  ·  docteur, infirmier, médecin, santé, thérapeute  ·  health worker hospital  professionnel de la sante (tous genres) medecin sante therapeute
👨‍⚕️ professionnel de la santé  ·  docteur, homme, homme profession médicale, infirmier, médecin, métier, profession médicale, santé  ·  man health worker doctor nurse therapist healthcare man human  professionnel de la sante homme profession medicale medecin metier profession medicale sante
👩‍⚕️ professionnelle de la santé  ·  docteur, docteure, femme, femme profession médicale, infirmière, médecin, métier, profession médicale, santé  ·  woman health worker doctor nurse therapist healthcare woman human  professionnelle de la sante femme profession medicale infirmiere medecin metier profession medicale sante
🧑‍🎓 étudiant (tous genres)  ·  diplôme, étudiant, étudiante  ·  student learn  etudiant (tous genres) diplome etudiant etudiante
👨‍🎓 étudiant  ·  diplômé, homme  ·  man student graduate man human  etudiant diplome
👩‍🎓 étudiante  ·  diplômée, femme  ·  woman student graduate woman human  etudiante diplomee
🧑‍🏫 personnel enseignant  ·  enseignant, enseignante, formateur, formatrice, professeur  ·  teacher professor
👨‍🏫 enseignant  ·  homme, instituteur, instructeur, métier, professeur  ·  man teacher instructor professor man human  metier
👩‍🏫 enseignante  ·  femme, institutrice, instructrice, professeure  ·  woman teacher instructor professor woman human
🧑‍⚖️ juge  ·  balance  ·  judge law
👨‍⚖️ juge homme  ·  balance, homme, juge, justice, métier  ·  man judge justice court man human  metier
👩‍⚖️ juge femme  ·  balance, femme, juge, justice, métier  ·  woman judge justice court woman human  metier
🧑‍🌾 fermier (tous genres)  ·  fermier, fermière, jardinier, jardinière  ·  farmer crops  fermiere jardiniere
👨‍🌾 fermier  ·  agriculteur, homme, jardinier, métier  ·  man farmer rancher gardener man human  metier
👩‍🌾 fermière  ·  agricultrice, femme, jardinière, métier  ·  woman farmer rancher gardener woman human  fermiere jardiniere metier
🧑‍🍳 cuisinier (tous genres)  ·  chef, cuisinier, cuisinière  ·  cook food kitchen culinary  cuisiniere
👨‍🍳 cuisinier  ·  chef, homme, métier  ·  man cook chef man human  metier
👩‍🍳 cuisinière  ·  chef, femme, métier  ·  woman cook chef woman human  cuisiniere metier
🧑‍🔧 mécanicien (tous genres)  ·  artisan, électricien, électricienne, mécanicien, mécanicienne, plombier  ·  mechanic worker technician  mecanicien (tous genres) electricien electricienne mecanicien mecanicienne
👨‍🔧 mécanicien  ·  électricien, homme, mécanique, métier, ouvrier, plombier  ·  man mechanic plumber man human wrench  mecanicien electricien mecanique metier
👩‍🔧 mécanicienne  ·  électricienne, femme, mécanique, métier, ouvrière, plombier  ·  woman mechanic plumber woman human wrench  mecanicienne electricienne mecanique metier ouvriere
🧑‍🏭 ouvrier (tous genres)  ·  assemblage, industrie, ouvrier, ouvrière, usine  ·  factory worker labor  ouvriere
👨‍🏭 ouvrier  ·  assemblage, homme, industrie, métier, montage, usine  ·  man factory worker assembly industrial man human  metier
👩‍🏭 ouvrière  ·  assemblage, femme, industrie, métier, montage, usine  ·  woman factory worker assembly industrial woman human  ouvriere metier
🧑‍💼 employé de bureau (tous genres)  ·  affaires, architecte, bureau, employé de bureau, employée de bureau  ·  office worker business  employe de bureau (tous genres) employe de bureau employee de bureau
👨‍💼 employé de bureau  ·  affaires, architecte, bureau, cadre, directeur, homme, métier  ·  man office worker business manager man human  employe de bureau metier
👩‍💼 employée de bureau  ·  affaires, architecte, bureau, cadre, directrice, femme, métier  ·  woman office worker business manager woman human  employee de bureau metier
🧑‍🔬 scientifique  ·  chimiste  ·  scientist chemistry
👨‍🔬 scientifique homme  ·  biologiste, chimiste, homme, ingénieur, mathématicien, métier, physicien, scientifique  ·  man scientist biologist chemist engineer physicist man human  ingenieur mathematicien metier
👩‍🔬 scientifique femme  ·  biologiste, chimiste, femme, ingénieure, mathématicienne, métier, physicienne, scientifique  ·  woman scientist biologist chemist engineer physicist woman human  ingenieure mathematicienne metier
🧑‍💻 informaticien (tous genres)  ·  développeur, développeuse, informaticien, informaticienne, logiciels, technologie  ·  technologist computer  developpeur developpeuse
👨‍💻 informaticien  ·  codeur, développeur, homme, inventeur, logiciels, métier, technologie  ·  man technologist coder developer engineer programmer software man human laptop computer  developpeur metier
👩‍💻 informaticienne  ·  codeuse, développeuse, femme, inventrice, logiciels, métier, technologie  ·  woman technologist coder developer engineer programmer software woman human laptop computer  developpeuse metier
🧑‍🎤 chanteur (tous genres)  ·  artiste, chanteur, chanteuse, rock, star  ·  singer song artist performer
👨‍🎤 chanteur  ·  acteur, artiste, homme, métier, rock, rockeur, star  ·  man singer rockstar entertainer man human  metier
👩‍🎤 chanteuse  ·  actrice, artiste, femme, métier, rock, rockeuse, star  ·  woman singer rockstar entertainer woman human  metier
🧑‍🎨 artiste  ·  palette  ·  artist painting draw creativity
👨‍🎨 artiste homme  ·  artiste, homme, métier, palette, peintre  ·  man artist painter man human  metier
👩‍🎨 artiste femme  ·  artiste, femme, métier, palette, peintre  ·  woman artist painter woman human  metier
🧑‍✈️ pilote  ·  avion  ·  pilot fly plane airplane
👨‍✈️ pilote homme  ·  avion, homme, métier, pilote  ·  man pilot aviator plane man human  metier
👩‍✈️ pilote femme  ·  avion, femme, métier, pilote  ·  woman pilot aviator plane woman human  metier
🧑‍🚀 astronaute  ·  fusée  ·  astronaut outerspace  fusee
👨‍🚀 astronaute homme  ·  astronaute, casque, cosmonaute, espace, fusée, homme, métier, spationaute  ·  man astronaut space rocket man human  fusee metier
👩‍🚀 astronaute femme  ·  astronaute, casque, cosmonaute, espace, femme, fusée, métier, spationaute  ·  woman astronaut space rocket woman human  fusee metier
🧑‍🚒 pompier  ·  camion de pompiers  ·  firefighter fire
👨‍🚒 pompier homme  ·  camion de pompiers, casque, casque de pompier, homme, métier, pompier  ·  man firefighter fireman man human  metier
👩‍🚒 pompier femme  ·  camion de pompiers, casque, femme, métier, pompier  ·  woman firefighter fireman woman human  metier
👮 officier de police  ·  autorité, flic, homme, loi, métier, officier, personne, police, policier, tenue, uniforme  ·  police officer cop  autorite metier
👮‍♂️ policier  ·  flic, homme, officier, police  ·  man police officer man police law legal enforcement arrest 911
👮‍♀️ policière  ·  autorité, femme, flic, loi, métier, officier, personne, police, tenue, uniforme  ·  woman police officer woman police law legal enforcement arrest 911 female  policiere autorite metier
🕵️ détective  ·  enquêteur, espion, homme  ·  detective human spy detective  detective enqueteur
🕵️‍♂️ détective homme  ·  détective, enquêteur, espion, homme  ·  man detective crime  detective homme detective enqueteur
🕵️‍♀️ détective femme  ·  détective, enquêteuse, enquêtrice, espionne, femme  ·  woman detective human spy detective female woman  detective femme detective enqueteuse enquetrice
💂 garde  ·  Buckingham Palace, casque, garde homme, Londres  ·  guard protect
💂‍♂️ garde homme  ·  garde, homme  ·  man guard uk gb british male guy royal
💂‍♀️ garde femme  ·  Buckingham Palace, casque, femme, garde, Londres, métier  ·  woman guard uk gb british female royal woman  metier
👷 personnel du bâtiment  ·  bâtiment, BTP, casque, chantier, construction, homme, métier, ouvrier, personne, réparer  ·  construction worker labor build  personnel du batiment batiment metier reparer
👷‍♂️ ouvrier du bâtiment  ·  bâtiment, homme, ouvrier  ·  man construction worker male human wip guy build construction worker labor  ouvrier du batiment batiment
👷‍♀️ ouvrière du bâtiment  ·  bâtiment, casque, casque de chantier, chantier, femme, métier, ouvrier du bâtiment femme, ouvrière  ·  woman construction worker female human wip build construction worker labor woman  ouvriere du batiment batiment metier ouvrier du batiment femme ouvriere
🤴 prince  ·  couronne, royal, royauté  ·  prince boy man male crown royal king  royaute
👸 princesse  ·  conte de fées, couronne, fantastique, personne, reine  ·  princess girl woman female blond crown royal queen  conte de fees
👳 personne en turban  ·  homme avec turban, oriental, personne avec turban, turban, visage  ·  person wearing turban headdress
👳‍♂️ homme en turban  ·  homme, turban  ·  man wearing turban male indian hinduism arabs
👳‍♀️ femme en turban  ·  femme, femme avec turban, turban  ·  woman wearing turban female indian hinduism arabs woman
👲 homme avec casquette chinoise  ·  casquette mao, chapeau, homme  ·  man with skullcap male boy chinese
🧕 femme avec foulard  ·  bandana, femme avec un voile, foulard, hijab, mantilla, tichel, voile  ·  woman with headscarf female hijab mantilla tichel
🤵 personne en smoking  ·  élégant, homme, marié, personne mariée, smoking  ·  man in tuxedo couple marriage wedding groom  elegant marie personne mariee
👰 personne mariée avec voile  ·  mariage, mariée, mariée avec voile, voile  ·  bride with veil couple marriage wedding woman bride  personne mariee avec voile mariee mariee avec voile
🤰 femme enceinte  ·  enceinte, femme  ·  pregnant woman baby
🤱 allaitement  ·  bébé, maman, nourrice, nourrir le bébé, sein, soins  ·  breast feeding nursing baby  bebe nourrir le bebe
👼 bébé ange  ·  ailes, ange, auréole, bébé, église, émoticône, fantastique, visage  ·  baby angel heaven wings halo  bebe ange aureole bebe eglise emoticone
🎅 père Noël  ·  bonnet, fêtes, magie, noël, Noël, père, Santa Claus, tradition  ·  santa claus festival man male xmas father christmas  pere Noel fetes noel Noel pere
🤶 mère Noël  ·  bonnet, fêtes, mère, Noël, Santa  ·  mrs claus woman female xmas mother christmas  mere Noel fetes mere Noel
🦸 super-héros  ·  bien, cape, force, heroïne, héroïne, héros, personnage, sauver le monde, super pouvoir, super-pouvoir, superhéros, superman, vengeur, voler  ·  superhero marvel  super-heros heroine heros superheros
🦸‍♂️ super-héros homme  ·  bien, héros, homme, super-pouvoir  ·  man superhero man male good hero superpowers  super-heros homme heros
🦸‍♀️ super-héroïne  ·  bien, femme, héroïne, héros, super-pouvoir  ·  woman superhero woman female good heroine superpowers  super-heroine heroine heros
🦹 super-vilain  ·  cape, criminel, déguisement, diabolique, mal, mauvais, méchant, personnage, super pouvoir, super vilain, super-pouvoir  ·  supervillain marvel  deguisement mechant
🦹‍♂️ super-vilain homme  ·  criminel, homme, mal, méchant, super-pouvoir  ·  man supervillain man male evil bad criminal hero superpowers  mechant
🦹‍♀️ super-vilain femme  ·  criminelle, femme, mal, méchante, super-pouvoir  ·  woman supervillain woman female evil bad criminal heroine superpowers  mechante
🧙 mage  ·  chapeau, enchantement, ensorceleur, envoûtement, jeu de rôle, magicien, personnage, sorcier, sorcière, sortilège  ·  mage magic  envoutement jeu de role sorciere sortilege
🧙‍♂️ mage homme  ·  magicien, sorcier  ·  man mage man male mage sorcerer
🧙‍♀️ mage femme  ·  ensorceleuse, sorcière  ·  woman mage woman female mage witch  sorciere
🧚 personnage féérique  ·  ailes, déguisement, fée, Fée clochette, féerie, magie, Obéron, Puck, Titania, voler  ·  fairy wings magical  personnage feerique deguisement fee Fee clochette feerie Oberon
🧚‍♂️ féetaud  ·  Obéron, Puck  ·  man fairy man male  feetaud Oberon
🧚‍♀️ fée  ·  Titania  ·  woman fairy woman female  fee
🧛 vampire  ·  canines, cape, conte, déguisement, dents, dracula, Dracula, halloween, mort-vivant, personnage, sang  ·  vampire blood twilight  deguisement
🧛‍♂️ vampire homme  ·  Dracula, mort-vivant  ·  man vampire man male dracula
🧛‍♀️ vampire femme  ·  morte-vivante  ·  woman vampire woman female
🧜 créature aquatique  ·  ariel, folklore, mer, océan, personnage, petite sirène, queue de poisson, sirène, trident, triton  ·  merperson sea  creature aquatique ocean petite sirene sirene
🧜‍♂️ triton  ·  Triton  ·  merman man male triton
🧜‍♀️ sirène  ·  mermaid woman female merwoman ariel  sirene
🧝 elfe  ·  conte, elf, le seigneur des anneaux, legolas, magique, oreilles, personnage  ·  elf magical
🧝‍♂️ elfe homme  ·  magique  ·  man elf man male
🧝‍♀️ elfe femme  ·  magique  ·  woman elf woman female
🧞 génie  ·  aladin, djinn, homme génie, lampe magique, magie, personnage, souhait, voeu, vœu  ·  genie magical wishes  genie homme genie voeu
🧞‍♂️ génie homme  ·  djinn  ·  man genie man male  genie homme
🧞‍♀️ génie femme  ·  djinn  ·  woman genie woman female  genie femme
🧟 zombie  ·  effrayant, flippant, halloween, horreur, mort vivant, mort-vivant, personnage, peur  ·  zombie dead
🧟‍♂️ zombie homme  ·  mort-vivant  ·  man zombie man male dracula undead walking dead
🧟‍♀️ zombie femme  ·  morte-vivante  ·  woman zombie woman female undead walking dead
💆 personne qui se fait masser  ·  détente, femme qui se fait masser, fermer les yeux, massage, relaxation, repos, salon, tête, thérapie, visage, zen  ·  person getting massage relax  detente tete therapie
💆‍♂️ homme qui se fait masser  ·  apaiser, homme, homme qui se fait masser le visage, mal de tête, massage, migraine, relaxation, salon, tension, visage  ·  man getting massage male boy man head  mal de tete
💆‍♀️ femme qui se fait masser  ·  femme, massage, visage  ·  woman getting massage female girl woman head
💇 personne qui se fait couper les cheveux  ·  barbier, beauté, cheveux, ciseaux, coiffure, coupe de cheveux, couper, femme qui se fait couper les cheveux, personne, salon, style  ·  person getting haircut hairstyle  beaute
💇‍♂️ homme qui se fait couper les cheveux  ·  coiffeur, coiffure, coupe de cheveux, couper les cheveux, homme, homme chez le coiffeur, salon de coiffure  ·  man getting haircut male boy man
💇‍♀️ femme qui se fait couper les cheveux  ·  coiffure, femme  ·  woman getting haircut female girl woman
🚶 personne qui marche  ·  balade, en route, flâner, homme, marche, marcher, nonchalant, personne, piéton, promenade, se balader  ·  person walking move  flaner pieton
🚶‍♂️ homme qui marche  ·  homme, marche, piéton  ·  man walking human feet steps  pieton
🚶‍♀️ femme qui marche  ·  femme, marche, marcher, piétonne, randonneuse  ·  woman walking human feet steps woman female  pietonne
🧍 personne debout  ·  debout  ·  person standing still
🧍‍♂️ homme debout  ·  debout, homme  ·  man standing still
🧍‍♀️ femme debout  ·  debout, femme  ·  woman standing still
🧎 personne à genoux  ·  à genoux, prière, religion  ·  person kneeling pray respectful  personne a genoux a genoux priere
🧎‍♂️ homme à genoux  ·  à genoux, homme  ·  man kneeling pray respectful  homme a genoux a genoux
🧎‍♀️ femme à genoux  ·  à genoux, femme  ·  woman kneeling respectful pray  femme a genoux a genoux
🧑‍🦯 personne avec une canne blanche  ·  accessibilité, aveugle  ·  person with probing cane blind  accessibilite
👨‍🦯 homme avec canne blanche  ·  accessibilité, aveugle, déficient visuel, handicap, handicap visuel, homme, malvoyant  ·  man with probing cane blind  accessibilite deficient visuel
👩‍🦯 femme avec canne blanche  ·  accessibilité, aveugle, déficiente visuelle, femme, handicap, malvoyante  ·  woman with probing cane blind  accessibilite deficiente visuelle
🧑‍🦼 personne en fauteuil motorisé  ·  accessibilité, fauteuil roulant  ·  person in motorized wheelchair disability accessibility  personne en fauteuil motorise accessibilite
👨‍🦼 homme en fauteuil motorisé  ·  accessibilité, fauteuil roulant, handicap, homme  ·  man in motorized wheelchair disability accessibility  homme en fauteuil motorise accessibilite
👩‍🦼 femme en fauteuil motorisé  ·  accessibilité, fauteuil roulant, femme, handicap  ·  woman in motorized wheelchair disability accessibility  femme en fauteuil motorise accessibilite
🧑‍🦽 personne en fauteuil roulant manuel  ·  accessibilité, fauteuil roulant  ·  person in manual wheelchair disability accessibility  accessibilite
👨‍🦽 homme en fauteuil roulant manuel  ·  accessibilité, fauteuil roulant, handicap, homme  ·  man in manual wheelchair disability accessibility  accessibilite
👩‍🦽 femme en fauteuil roulant manuel  ·  accessibilité, fauteuil roulant, femme, handicap  ·  woman in manual wheelchair disability accessibility  accessibilite
🏃 personne qui court  ·  arriver, coureur, courir, course à pied, homme qui court, jogging, marathon, marathonien, pressé, rapide, sportif, vite  ·  person running move  course a pied presse
🏃‍♂️ homme qui court  ·  course à pied, homme, jogging, marathon  ·  man running man walking exercise race running  course a pied
🏃‍♀️ femme qui court  ·  course à pied, femme, joggeuse, jogging, marathon, running, se dépêcher, vite, vitesse  ·  woman running woman walking exercise race running female  course a pied se depecher
💃 danseuse  ·  danse, femme, femme qui danse, fête, flamenco, rythme, salsa, sortir danser, tango  ·  woman dancing female girl woman fun  fete
🕺 danseur  ·  danse, femme, fête, flamenco, homme, homme qui danse, rythme, salsa  ·  man dancing male boy fun dancer  fete
🕴️ homme d’affaires en lévitation  ·  affaires, costume, homme  ·  man in suit levitating suit business levitate hover jump  homme d'affaires en levitation
👯 personnes avec des oreilles de lapin  ·  amies, bunny, danseuse, déguisement, double, femme, femmes, fête, fille, filles, jumelles, oreilles de lapin, synchro  ·  people with bunny ears perform costume  deguisement fete
👯‍♂️ hommes avec des oreilles de lapin  ·  amis, danseur, faire la fête, fête, homme, oreilles de lapin  ·  men with bunny ears male bunny men boys  faire la fete fete
👯‍♀️ femmes avec des oreilles de lapin  ·  danseuse, femme, fête, oreilles de lapin  ·  women with bunny ears female bunny women girls  fete
🧖 personne au hammam  ·  bien-être, chaud, détente, hammam, personne dans un sauna, relaxation, sauna, spa, vapeur  ·  person in steamy room relax spa  bien-etre detente
🧖‍♂️ homme au hammam  ·  hammam, sauna  ·  man in steamy room male man spa steamroom sauna
🧖‍♀️ femme au hammam  ·  hammam, sauna  ·  woman in steamy room female woman spa steamroom sauna
🧗 personne qui grimpe  ·  alpiniste, escalader, grimper, grimpeur, montagne, personne qui escalade, sport  ·  person climbing sport
🧗‍♂️ homme qui grimpe  ·  alpiniste, grimpeur  ·  man climbing sports hobby man male rock
🧗‍♀️ femme qui grimpe  ·  alpiniste, grimpeuse  ·  woman climbing sports hobby woman female rock
🤺 escrimeur  ·  épée, escrime, escrimeuse, personne, sport  ·  person fencing sports fencing sword  epee
🏇 course hippique  ·  cheval, course de chevaux, jockey, sport  ·  horse racing animal betting competition gambling luck
⛷️ skieur  ·  neige, ski, sport  ·  skier sports winter snow
🏂 snowboardeur  ·  homme, neige, ski, snowboard, sport  ·  snowboarder sports winter
🏌️ joueur de golf  ·  balle, golf, golfeur, green, homme, personne, pga, pitch, sport  ·  person golfing sports business
🏌️‍♂️ golfeur  ·  golf, homme  ·  man golfing sport
🏌️‍♀️ golfeuse  ·  femme, golf, practice, sport  ·  woman golfing sports business woman female
🏄 personne faisant du surf  ·  glisse, homme, mer, océan, personne, plage, planche, sport, surf, vagues  ·  person surfing sport sea  ocean
🏄‍♂️ surfeur  ·  homme, surf  ·  man surfing sports ocean sea summer beach
🏄‍♀️ surfeuse  ·  femme, mer, océan, plage, sport, surf, vagues  ·  woman surfing sports ocean sea summer beach woman female  ocean
🚣 personne ramant dans une barque  ·  barque, bateau, lac, naviguer, pêche, personne, ramer, rameur, rivière, sport  ·  person rowing boat sport move  peche riviere
🚣‍♂️ rameur dans une barque  ·  barque, bateau, homme  ·  man rowing boat sports hobby water ship
🚣‍♀️ rameuse dans une barque  ·  barque, bateau, femme, lac, navigation, pêche, plaisance, ramer, rivière, sport  ·  woman rowing boat sports hobby water ship woman female  peche riviere
🏊 personne nageant  ·  crawl, eau, exercice, homme, nage, nageur, natation, personne, piscine, sport  ·  person swimming sport pool
🏊‍♂️ nageur  ·  homme, nage  ·  man swimming sports exercise human athlete water summer
🏊‍♀️ nageuse  ·  femme, nage, natation, sport  ·  woman swimming sports exercise human athlete water summer woman female
⛹️ personne avec ballon  ·  athlétique, ballon, basket-ball, basketteur, dribble, joueur, match, personne, rebond, sport  ·  person bouncing ball sports human  athletique
⛹️‍♂️ homme avec ballon  ·  ballon, homme  ·  man bouncing ball sport
⛹️‍♀️ femme avec ballon  ·  ballon, basket-ball, basketteuse, femme, sport  ·  woman bouncing ball sports human woman female
🏋️ haltérophile  ·  bodybuilding, entraînement, force, haltérophilie, homme, lever des poids, muscles, personne, poids, sport  ·  person lifting weights sports training exercise  halterophile entrainement halterophilie
🏋️‍♂️ homme haltérophile  ·  haltérophile, homme  ·  man lifting weights sport  homme halterophile halterophile
🏋️‍♀️ femme haltérophile  ·  entraînement, exercice, femme, haltérophile, sport  ·  woman lifting weights sports training exercise woman female  femme halterophile entrainement halterophile
🚴 cycliste  ·  course, guidon, homme, pédaler, personne, rouler, sport, tour de france, vélo  ·  person biking sport move  pedaler velo
🚴‍♂️ cycliste homme  ·  cyclisme, cycliste, homme, vélo  ·  man biking sports bike exercise hipster  velo
🚴‍♀️ cycliste femme  ·  cyclisme, cycliste, femme, sport, vélo  ·  woman biking sports bike exercise hipster woman female  velo
🚵 personne en VTT  ·  coureur, cyclisme, grimper, homme en VTT, montagne, personne, sport, tour de France, vélo, VTT  ·  person mountain biking sport move  velo
🚵‍♂️ homme en VTT  ·  cycliste, homme, vélo, VTT  ·  man mountain biking transportation sports human race bike  velo
🚵‍♀️ femme en VTT  ·  cycliste, femme, montagne, sport, vélo, VTT, VTTiste  ·  woman mountain biking transportation sports human race bike woman female  velo
🤸 personne faisant la roue  ·  agilité, athlète, faire la roue, femme faisant la roue, gymnaste, gymnastique, personne, roue, sport  ·  person cartwheeling sport gymnastic  agilite athlete
🤸‍♂️ homme faisant la roue  ·  acrobatie, content, faire la roue, garçon, gymnastique, homme, personne, roue, souple, sport  ·  man cartwheeling gymnastics  garcon
🤸‍♀️ femme faisant la roue  ·  acrobatie, exercice, faire la roue, femme, gymnaste, gymnastique, personne, roue, sport  ·  woman cartwheeling gymnastics
🤼 personnes faisant de la lutte  ·  bataille, lutte, lutteur, lutteurs, personnes, sport  ·  people wrestling sport
🤼‍♂️ lutteurs  ·  athlètes, bataille, force, hommes, lutte, personne, personnes, sport, sur le ring  ·  men wrestling sports wrestlers  athletes
🤼‍♀️ lutteuses  ·  bataille, combat, duel, femmes, lutte, lutteuse, personne, personnes, sport  ·  women wrestling sports wrestlers
🤽 personne jouant au water-polo  ·  ballon, homme qui joue au water-polo, personne, piscine, sport, water-polo  ·  person playing water polo sport
🤽‍♂️ joueur de water-polo  ·  ballon, eau, homme, jeu, match, personne, piscine, sport, water-polo  ·  man playing water polo sports pool
🤽‍♀️ joueuse de water-polo  ·  ballon, femme, nager, personne, piscine, sport, water-polo  ·  woman playing water polo sports pool
🤾 personne jouant au handball  ·  athlète, ballon, handball, handballeur, lancer, personne, sport  ·  person playing handball sport  athlete
🤾‍♂️ handballeur  ·  handball, homme, sport  ·  man playing handball sports
🤾‍♀️ handballeuse  ·  athlète, attaquante, ballon, femme, handball, personne, sport, tir  ·  woman playing handball sports  athlete
🤹 personne qui jongle  ·  artiste, cirque, gérer, jongler, jongleur, multitâche  ·  person juggling performance balance  gerer multitache
🤹‍♂️ jongleur  ·  acrobatie, artiste, balles, cirque, homme, jonglage, multitâche, personne  ·  man juggling juggle balance skill multitask  multitache
🤹‍♀️ jongleuse  ·  femme, jonglage, multitâche  ·  woman juggling juggle balance skill multitask  multitache
🧘 personne dans la posture du lotus  ·  détendu, femme, lotus, méditation, personne assise en position du lotus, position du lotus, relax, relaxation, tailleur, yoga, zen  ·  person in lotus position meditate  detendu meditation
🧘‍♂️ homme dans la posture du lotus  ·  méditation, position du lotus, yoga  ·  man in lotus position man male meditation yoga serenity zen mindfulness  meditation
🧘‍♀️ femme dans la posture du lotus  ·  méditation, position du lotus, yoga  ·  woman in lotus position woman female meditation yoga serenity zen mindfulness  meditation
🛀 personne prenant un bain  ·  baignoire, bain, personne qui prend un bain  ·  person taking bath clean shower bathroom
🛌 personne au lit  ·  auberge, bonne nuit, coucher, dodo, dormir, fatigué, hôtel, lit, sieste  ·  person in bed bed rest  fatigue hotel
🧑‍🤝‍🧑 deux personnes se tenant la main  ·  couple, couple homosexuel, gay, main, personne, personnes se tenant par la main, poignée de main, tenir la main  ·  people holding hands friendship  poignee de main
👭 deux femmes se tenant la main  ·  amies, amitié, amoureuses, couple, deux femmes se donnant la main, femmes, filles, gay, homosexuelles, jumelles, lesbiennes, LGBT, LGBTQ, LGBTQIA, main dans la main, meilleures amies, petite amie, rendez-vous, sœurs  ·  women holding hands pair friendship couple love like female people human  amitie soeurs
👫 femme et homme se tenant la main  ·  amis, amoureux, couple, femme, homme, homme et femme se donnant la main, main dans la main, petit ami, petite amie, rendez-vous  ·  woman and man holding hands pair people human love date dating like affection valentines marriage
👬 deux hommes se tenant la main  ·  amis, amitié, amoureux, couple, deux hommes se donnant la main, fils, frères, gay, Gémeaux, hommes, homosexuels, jumeaux, LGBT, main dans la main, meilleurs amis, petit ami, rendez-vous, zodiaque  ·  men holding hands pair couple love like bromance friendship people human  amitie freres Gemeaux
💏 bisou  ·  amour, anniversaire, baiser, couple, femme, homme  ·  kiss pair valentines love like dating marriage
👩‍❤️‍💋‍👨 bisou : femme et homme  ·  amour, anniversaire, baiser, bisou, couple, femme, homme  ·  kiss woman man love
👨‍❤️‍💋‍👨 bisou : homme et homme  ·  amour, anniversaire, baiser, bisou, couple, femme, homme  ·  kiss man man pair valentines love like dating marriage
👩‍❤️‍💋‍👩 bisou : femme et femme  ·  amour, anniversaire, baiser, bisou, couple, femme, homme  ·  kiss woman woman pair valentines love like dating marriage
💑 couple avec cœur  ·  amour, anniversaire, cœur, couple, femme, homme, rendez-vous  ·  couple with heart pair love like affection human dating valentines marriage  couple avec coeur coeur
👩‍❤️‍👨 couple avec cœur : femme et homme  ·  amour, anniversaire, cœur, couple, couple avec cœur, femme, homme, rendez-vous  ·  couple with heart woman man love  couple avec coeur : femme et homme coeur couple avec coeur
👨‍❤️‍👨 couple avec cœur : homme et homme  ·  amour, anniversaire, cœur, couple, couple avec cœur, femme, homme, rendez-vous  ·  couple with heart man man pair love like affection human dating valentines marriage  couple avec coeur : homme et homme coeur couple avec coeur
👩‍❤️‍👩 couple avec cœur : femme et femme  ·  amour, anniversaire, cœur, couple, couple avec cœur, femme, homme, rendez-vous  ·  couple with heart woman woman pair love like affection human dating valentines marriage  couple avec coeur : femme et femme coeur couple avec coeur
👪 famille  ·  enfant, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family home parents child mom dad father mother people human  famille avec un pere, une mere et un fils garcon mere pere
👨‍👩‍👦 famille : homme, femme et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family man woman boy love  famille : homme, femme et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👩‍👧 famille : homme, femme et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man woman girl home parents people human child  famille avec un pere, une mere et un fils garcon mere pere
👨‍👩‍👧‍👦 famille : homme, femme, fille et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man woman girl boy home parents people human children  famille : homme, femme, fille et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👩‍👦‍👦 famille : homme, femme, garçon et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family man woman boy boy home parents people human children  famille : homme, femme, garcon et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👩‍👧‍👧 famille : homme, femme, fille et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man woman girl girl home parents people human children  famille avec un pere, une mere et un fils garcon mere pere
👨‍👨‍👦 famille : homme, homme et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family man man boy home parents people human children  famille : homme, homme et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👨‍👧 famille : homme, homme et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man man girl home parents people human children  famille avec un pere, une mere et un fils garcon mere pere
👨‍👨‍👧‍👦 famille : homme, homme, fille et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man man girl boy home parents people human children  famille : homme, homme, fille et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👨‍👦‍👦 famille : homme, homme, garçon et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family man man boy boy home parents people human children  famille : homme, homme, garcon et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👨‍👧‍👧 famille : homme, homme, fille et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man man girl girl home parents people human children  famille avec un pere, une mere et un fils garcon mere pere
👩‍👩‍👦 famille : femme, femme et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family woman woman boy home parents people human children  famille : femme, femme et garcon famille avec un pere, une mere et un fils garcon mere pere
👩‍👩‍👧 famille : femme, femme et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family woman woman girl home parents people human children  famille avec un pere, une mere et un fils garcon mere pere
👩‍👩‍👧‍👦 famille : femme, femme, fille et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family woman woman girl boy home parents people human children  famille : femme, femme, fille et garcon famille avec un pere, une mere et un fils garcon mere pere
👩‍👩‍👦‍👦 famille : femme, femme, garçon et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family woman woman boy boy home parents people human children  famille : femme, femme, garcon et garcon famille avec un pere, une mere et un fils garcon mere pere
👩‍👩‍👧‍👧 famille : femme, femme, fille et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family woman woman girl girl home parents people human children  famille avec un pere, une mere et un fils garcon mere pere
👨‍👦 famille : homme et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family man boy home parent people human child  famille : homme et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👦‍👦 famille : homme, garçon et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family man boy boy home parent people human children  famille : homme, garcon et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👧 famille : homme et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man girl home parent people human child  famille avec un pere, une mere et un fils garcon mere pere
👨‍👧‍👦 famille : homme, fille et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man girl boy home parent people human children  famille : homme, fille et garcon famille avec un pere, une mere et un fils garcon mere pere
👨‍👧‍👧 famille : homme, fille et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family man girl girl home parent people human children  famille avec un pere, une mere et un fils garcon mere pere
👩‍👦 famille : femme et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family woman boy home parent people human child  famille : femme et garcon famille avec un pere, une mere et un fils garcon mere pere
👩‍👦‍👦 famille : femme, garçon et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fils, garçon, homme, mère, père  ·  family woman boy boy home parent people human children  famille : femme, garcon et garcon famille avec un pere, une mere et un fils garcon mere pere
👩‍👧 famille : femme et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family woman girl home parent people human child  famille avec un pere, une mere et un fils garcon mere pere
👩‍👧‍👦 famille : femme, fille et garçon  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family woman girl boy home parent people human children  famille : femme, fille et garcon famille avec un pere, une mere et un fils garcon mere pere
👩‍👧‍👧 famille : femme, fille et fille  ·  enfant, famille, famille avec un père, une mère et un fils, femme, fille, fils, garçon, homme, mère, père  ·  family woman girl girl home parent people human children  famille avec un pere, une mere et un fils garcon mere pere
🗣️ tête qui parle  ·  parler, silhouette  ·  speaking head user person human sing say talk  tete qui parle
👤 silhouette de buste  ·  buste, mystère, ombre  ·  bust in silhouette user person human  mystere
👥 silhouettes de bustes  ·  amis, bff, bustes, gens, meilleur ami, meilleure amie, meilleures amies, meilleurs amis, personnes, silhouettes, tout le monde  ·  busts in silhouette user person human group team
👣 traces de pas  ·  empreintes, pied, pieds, pieds nus  ·  footprints feet tracking walking beach
🐵 tête de singe  ·  animal, Georges le petit curieux, singe, sourire, visage  ·  monkey face animal nature circus  tete de singe
🐒 singe  ·  animal, primate  ·  monkey animal nature banana circus
🦍 gorille  ·  animal, primate  ·  gorilla animal nature circus
🦧 orang-outan  ·  animal, primate, singe  ·  orangutan animal
🐶 tête de chien  ·  animal, animal domestique, chien, chiot, visage  ·  dog face animal friend nature woof puppy pet faithful  tete de chien
🐕 chien  ·  aboyer, animal, animal domestique  ·  dog animal nature friend doge pet faithful
🦮 chien guide  ·  accessibilité, animal, aveugle, guide, malvoyant, non-voyant  ·  guide dog animal blind  accessibilite
🐕‍🦺 chien d’assistance  ·  accessibilité, aide, animal, assistance, chien-guide, handicap  ·  service dog blind animal  chien d'assistance accessibilite
🐩 caniche  ·  animal, chien  ·  poodle dog animal 101 nature pet
🐺 loup  ·  animal, louve, tête, tête de loup  ·  wolf animal nature wild  tete tete de loup
🦊 renard  ·  animal, nature, tête, visage  ·  fox animal nature face  tete
🦝 raton laveur  ·  animal, curieux, sournois  ·  raccoon animal nature
🐱 tête de chat  ·  animal, chat, chaton, miaou, minou  ·  cat face animal meow nature pet kitten  tete de chat
🐈 chat  ·  animal, animal domestique, chaton, miaou, miauler  ·  cat animal meow pet cats
🦁 tête de lion  ·  animal, astrologie, crinière, fort, horoscope, lion, roi, rugissement, safari, savane, visage, zodiaque  ·  lion animal nature  tete de lion criniere
🐯 tête de tigre  ·  animal, félin, prédateur, tigre, visage  ·  tiger face animal cat danger wild nature roar  tete de tigre felin predateur
🐅 tigre  ·  animal, félin, prédateur, tigresse, zoo  ·  tiger animal nature roar  felin predateur
🐆 léopard  ·  animal, félin, prédateur, zoo  ·  leopard animal nature  leopard felin predateur
🐴 tête de cheval  ·  animal, cheval, dressage, équitation, ferme, jument  ·  horse face animal brown nature  tete de cheval equitation
🐎 cheval  ·  animal, course hippique, hippodrome, tiercé  ·  horse animal gamble luck  tierce
🦄 licorne  ·  animal, licrone, tête, tête de licorne  ·  unicorn animal nature mystical  tete tete de licorne
🦓 zèbre  ·  animal, noir et blanc, rayure, rayures, zébrure  ·  zebra animal nature stripes safari  zebre zebrure
🦌 cerf  ·  animal, bois  ·  deer animal nature horns venison
🐮 tête de vache  ·  animal, lait, meuh, vache, visage  ·  cow face beef ox animal nature moo milk  tete de vache
🐂 bœuf  ·  animal, astrologie, ferme, horoscope, taureau, zodiaque  ·  ox animal cow beef  boeuf
🐃 buffle  ·  animal, corne, zoo  ·  water buffalo animal nature ox cow
🐄 vache  ·  animal, ferme, lait, meuh  ·  cow beef ox animal nature moo milk
🐷 tête de cochon  ·  animal, cochon, ferme, porc, visage  ·  pig face animal oink nature  tete de cochon
🐖 cochon  ·  animal, ferme, gros, jambon, porc, truie  ·  pig animal nature
🐗 sanglier  ·  animal, Game of Thrones  ·  boar animal nature
🐽 groin  ·  animal, cochon, ferme, flair, museau, porc, sentir, tête de cochon  ·  pig nose animal oink  tete de cochon
🐏 bélier  ·  animal, astrologie, corne, ferme, horoscope, mouton, zodiaque  ·  ram animal sheep nature  belier
🐑 mouton  ·  animal, bêler, brebis, doux, ferme, laine, lait  ·  ewe animal nature wool shipit  beler
🐐 chèvre  ·  animal, astrologie, Capricorne, ferme, fromage, horoscope, lait, zodiaque  ·  goat animal nature  chevre
🐪 dromadaire  ·  animal, bosse, désert, une bosse  ·  camel animal hot desert hump  desert
🐫 chameau  ·  animal, bosse, chameau à deux bosses, désert, deux bosses  ·  two hump camel animal nature hot desert hump  chameau a deux bosses desert
🦙 lama  ·  alpaca, alpaga, animal, guanaco, laine, llama, pérou, vicuña, vigogne  ·  llama animal nature alpaca  perou vicuna
🦒 girafe  ·  animal, cou, taches  ·  giraffe animal nature spots safari
🐘 éléphant  ·  animal, pachyderme, trompe  ·  elephant animal nature nose th circus  elephant
🦏 rhinocéros  ·  animal, corne  ·  rhinoceros animal nature horn  rhinoceros
🦛 hippopotame  ·  animal, hippo  ·  hippopotamus animal nature
🐭 tête de souris  ·  animal, souris, visage  ·  mouse face animal nature cheese wedge rodent  tete de souris
🐁 souris  ·  animal  ·  mouse animal nature rodent
🐀 rat  ·  animal  ·  rat animal mouse rodent
🐹 hamster  ·  animal, animal domestique, tête, tête de hamster, visage  ·  hamster animal nature  tete tete de hamster
🐰 tête de lapin  ·  animal, animal domestique, dents, lapin  ·  rabbit face animal nature pet spring magic bunny  tete de lapin
🐇 lapin  ·  animal, animal domestique  ·  rabbit animal nature pet magic spring
🐿️ écureuil  ·  animal, noisettes  ·  chipmunk animal nature rodent squirrel  ecureuil
🦔 hérisson  ·  animal, épines, épineux, piquant, porc-épic  ·  hedgehog animal nature spiny  herisson epines epineux porc-epic
🦇 chauve-souris  ·  animal, vampire  ·  bat animal nature blind vampire
🐻 ours  ·  animal, miel, nounours, ours brun, teddy, tête, visage  ·  bear animal nature wild  tete
🐨 koala  ·  animal, Australie  ·  koala animal nature
🐼 panda  ·  animal, tête, tête de panda, visage  ·  panda animal nature panda  tete tete de panda
🦥 paresseux  ·  aï, animal, endormi, lent  ·  sloth animal  ai
🦦 loutre  ·  animal, joueur, mignon, pêcheur  ·  otter animal  pecheur
🦨 mouffette  ·  animal, odeur, puer, putois  ·  skunk animal
🦘 kangourou  ·  austalie, joey, kangoo, marsupial, marsupiaux, saut  ·  kangaroo animal nature australia joey hop marsupial
🦡 blaireau  ·  animal, ratel  ·  badger animal nature honey
🐾 empreintes d’animaux  ·  empreintes, empreintes de pattes, pattes  ·  paw prints animal tracking footprints dog cat pet feet  empreintes d'animaux
🦃 dindon  ·  action de grâces, animal, dinde, oiseau, thanksgiving, volaille  ·  turkey animal bird  action de graces
🐔 poule  ·  animal, coq, ferme, oiseau, poulet, volaille  ·  chicken animal cluck nature bird
🐓 coq  ·  animal, oiseau, volaille  ·  rooster animal nature chicken
🐣 poussin qui éclôt  ·  animal, bébé, éclosion, naissance, naître, nouveau-né, œuf, oiseau, poussin  ·  hatching chick animal chicken egg born baby bird  poussin qui eclot bebe eclosion naitre nouveau-ne oeuf
🐤 poussin  ·  animal, oiseau, tête de poussin  ·  baby chick animal chicken bird  tete de poussin
🐥 poussin de face  ·  animal, bébé, nouveau-né, oiseau, poussin  ·  front facing baby chick animal chicken baby bird  bebe nouveau-ne
🐦 oiseau  ·  animal, ornithologie  ·  bird animal nature fly tweet spring
🐧 pingouin  ·  animal, Antarctique, banquise, manchot, oiseau  ·  penguin animal nature
🕊️ colombe  ·  animal, oiseau, paix, rameau, voler  ·  dove animal bird
🦅 aigle  ·  animal, oiseau, rapace  ·  eagle animal nature bird
🦆 canard  ·  animal, coin-coin, oiseau  ·  duck animal nature bird mallard
🦢 cygne  ·  animal, jeune cygne, oiseau, vilain petit canard  ·  swan animal nature bird
🦉 chouette  ·  animal, hibou, oiseau, sage  ·  owl animal nature bird hoot
🦩 flamant  ·  animal, oiseau, rose, tropical  ·  flamingo animal
🦚 paon  ·  animal, bel oiseau, coloré, fier, fière, oiseau, paonne, prétentieux  ·  peacock animal nature peahen bird  colore fiere pretentieux
🦜 perroquet  ·  animal, oiseau, parle, pirate, répète  ·  parrot animal nature bird pirate talk  repete
🐸 grenouille  ·  animal, crapaud, tête, tête de grenouille  ·  frog animal nature croak toad  tete tete de grenouille
🐊 crocodile  ·  alligator, animal, caïman, reptile, zoo  ·  crocodile animal nature reptile lizard alligator  caiman
🐢 tortue  ·  animal, carapace, lentement, reptile  ·  turtle animal slow nature tortoise
🦎 lézard  ·  animal, reptile  ·  lizard animal nature reptile  lezard
🐍 serpent  ·  animal, reptile, serpent à sonnette, venin  ·  snake animal evil nature hiss python  serpent a sonnette
🐲 tête de dragon  ·  animal, dragon, mythe, tradition  ·  dragon face animal myth nature chinese green  tete de dragon
🐉 dragon  ·  animal, Chine, chinois, Game of Thrones, mythe, tradition  ·  dragon animal myth nature chinese green
🦕 sauropode  ·  animal, brachiosaure, brontosaure, dinosaure, diplodocus  ·  sauropod animal nature dinosaur brachiosaurus brontosaurus diplodocus extinct
🦖 T-Rex  ·  animal, dinosaure, T. rex, tyrannosaure, Tyrannosaurus rex, Tyrannosaurus Rex  ·  t rex animal nature dinosaur tyrannosaurus extinct
🐳 baleine soufflant par son évent  ·  animal, baleine, baleine avec évent, mer, océan, plage, souffle  ·  spouting whale animal nature sea ocean  baleine soufflant par son event baleine avec event ocean
🐋 baleine  ·  animal, mer, océan, plage  ·  whale animal nature sea ocean  ocean
🐬 dauphin  ·  animal, Flipper, mer, océan, plage  ·  dolphin animal nature fish sea ocean flipper fins beach  ocean
🐟 poisson  ·  alimentation, animal, astrologie, horoscope, manger, nourriture, poissons, Poissons, repas, zodiaque  ·  fish animal food nature
🐠 poisson tropical  ·  animal, poisson  ·  tropical fish animal swim ocean beach nemo
🐡 poisson-lune  ·  animal, poisson  ·  blowfish animal nature food sea ocean
🦈 requin  ·  animal, Dents de la mer, poisson  ·  shark animal nature fish sea ocean jaws fins beach
🐙 pieuvre  ·  animal, créature, mer, mollusque, océan, poulpe  ·  octopus animal creature ocean sea nature beach  creature ocean
🐚 coquille en spirale  ·  animal, conque, coquillage, coquille, mer, plage, spirale  ·  spiral shell nature sea beach
🐌 escargot  ·  animal, jardin, lentement, nature  ·  snail slow animal shell
🦋 papillon  ·  animal, insecte, mignon, printemps  ·  butterfly animal insect nature caterpillar
🐛 chenille  ·  animal, insecte, jardin  ·  bug animal insect nature worm
🐜 fourmi  ·  animal, insecte, jardin  ·  ant animal insect nature bug
🐝 abeille  ·  animal, bourdon, guêpe, insecte, miel, nature, printemps  ·  honeybee animal insect nature bug spring honey  guepe
🐞 coccinelle  ·  animal, bête, insecte, jardin, nature  ·  lady beetle animal insect nature ladybug  bete
🦗 criquet  ·  animal, insecte, sauterelle  ·  cricket animal cricket chirp
🕷️ araignée  ·  animal, insecte  ·  spider animal arachnid  araignee
🕸️ toile d’araignée  ·  araignée, toile  ·  spider web animal insect arachnid silk  toile d'araignee araignee
🦂 scorpion  ·  animal, astrologie, désert, horoscope, zodiaque  ·  scorpion animal arachnid  desert
🦟 moustique  ·  fièvre, infection, insecte, maladie, malaria, piqûre, virus  ·  mosquito animal nature insect malaria  fievre piqure
🦠 microbe  ·  amibe, bactérie, biologie, microorganisme, phagocytose, pseudopode, science, virus  ·  microbe amoeba bacteria germs virus  bacterie
💐 bouquet  ·  amoureux, anniversaire, fleur, fleurs, plante, rendez-vous, roses  ·  bouquet flowers nature spring
🌸 fleur de cerisier  ·  bourgeon, fleur, plante, printemps  ·  cherry blossom nature plant spring flower
💮 fleur blanche  ·  fleur  ·  white flower japanese spring
🏵️ rosette  ·  plante  ·  rosette flower decoration military
🌹 rose  ·  amour, beauté, fleur, plante, rouge, Saint-Valentin  ·  rose flowers valentines love spring  beaute
🥀 fleur fanée  ·  fanée, fleur, mort, rose  ·  wilted flower plant nature flower  fleur fanee fanee
🌺 hibiscus  ·  fleur, plante  ·  hibiscus plant vegetable flowers beach
🌻 tournesol  ·  champs, fleur, plante, soleil  ·  sunflower nature plant fall
🌼 bourgeon  ·  bouton d’or, dent-de-lion, fleur, pissenlit, plante, printemps  ·  blossom nature flowers yellow  bouton d'or
🌷 tulipe  ·  bourgeon, fleur, plante, printemps  ·  tulip flowers plant nature summer spring
🌱 jeune pousse  ·  germe, jeune plant, plante, plantule, pousser, printemps, semis  ·  seedling plant nature grass lawn spring
🌲 conifère  ·  arbre, feuilles persistantes, forêt, pin, plante, sapin, sapin de Noël  ·  evergreen tree plant nature  conifere foret sapin de Noel
🌳 arbre à feuilles caduques  ·  arbre, feuilles caduques, feuillu, forêt, nature, plante  ·  deciduous tree plant nature  arbre a feuilles caduques foret
🌴 palmier  ·  arbre, cocotier, plage, plante, tropical, tropiques  ·  palm tree plant vegetable nature summer beach mojito tropical
🌵 cactus  ·  désert, épines, nature, piquant, plante, sécheresse  ·  cactus vegetable plant nature  desert epines secheresse
🌾 plant de riz  ·  grain, plante, riz  ·  sheaf of rice nature plant
🌿 feuille  ·  arbre, feuilles, plante  ·  herb vegetable plant medicine weed grass lawn
☘️ trèfle  ·  Irlande, plante  ·  shamrock vegetable plant nature irish clover  trefle
🍀 trèfle à quatre feuilles  ·  4, chance, feuilles, Irlande, plante, porte-bonheur, quatre, trèfle  ·  four leaf clover vegetable plant nature lucky irish  trefle a quatre feuilles trefle
🍁 feuille d’érable  ·  automne, érable, feuille, feuille morte, tomber  ·  maple leaf nature plant vegetable ca fall  feuille d'erable erable
🍂 feuille morte  ·  automne, feuille, feuilles mortes, tomber  ·  fallen leaf nature plant vegetable leaves
🍃 feuille virevoltante  ·  bourrasque, feuille, souffle, tourbillon de feuilles, vent, virevolter  ·  leaf fluttering in wind nature plant tree vegetable grass lawn spring
🍇 raisin  ·  fruit, nourriture  ·  grapes fruit food wine
🍈 melon  ·  fruit  ·  melon fruit nature food
🍉 pastèque  ·  fruit  ·  watermelon fruit food picnic summer  pasteque
🍊 mandarine  ·  agrume, clémentine, fruit, nourriture, orange, vitamine C  ·  tangerine food fruit nature orange  clementine
🍋 citron  ·  acide, agrume, fruit, nourriture, zeste  ·  lemon fruit nature
🍌 banane  ·  fruit, nourriture, potassium  ·  banana fruit food monkey
🍍 ananas  ·  fruit, nourriture, tropical  ·  pineapple fruit nature food
🥭 mangue  ·  fruit, nourriture, tropical, tropique  ·  mango fruit food tropical
🍎 pomme rouge  ·  fruit, nourriture, pomme  ·  red apple fruit mac school
🍏 pomme verte  ·  fruit, nourriture, pomme  ·  green apple fruit nature
🍐 poire  ·  fruit, nourriture  ·  pear fruit nature food
🍑 pêche  ·  fruit, nourriture  ·  peach fruit nature food  peche
🍒 cerises  ·  cerise, fruit, nourriture  ·  cherries food fruit
🍓 fraise  ·  fruit, nourriture  ·  strawberry fruit food nature
🥝 kiwi  ·  fruit, nourriture  ·  kiwi fruit fruit food
🍅 tomate  ·  fruit, légume, nourriture, plante  ·  tomato fruit vegetable nature food  legume
🥥 noix de coco  ·  coco, fruit, nourriture, palmier, piña colada  ·  coconut fruit nature food palm  pina colada
🥑 avocat  ·  fruit, nourriture  ·  avocado fruit food
🍆 aubergine  ·  légume, nourriture  ·  eggplant vegetable nature food aubergine  legume
🥔 pomme de terre  ·  légume, nourriture, patate, purée  ·  potato food tuber vegatable starch  legume puree
🥕 carotte  ·  légume, nourriture  ·  carrot vegetable food orange  legume
🌽 épi de maïs  ·  épi, ferme, maïs, nourriture  ·  ear of corn food vegetable plant  epi de mais epi mais
🌶️ piment rouge  ·  nourriture, piment, piquant  ·  hot pepper food spicy chilli chili
🥒 concombre  ·  cornichon, légume, nourriture  ·  cucumber fruit food pickle  legume
🥬 légume à feuilles vertes  ·  bok choy, chou, chou chinois, chou frisé, chou pommé, kale, laitue, salade  ·  leafy green food vegetable plant bok choy cabbage kale lettuce  legume a feuilles vertes chou frise chou pomme
🥦 brocoli  ·  broccoli, chou, chou sauvage, légume  ·  broccoli fruit food vegetable  legume
🧄 ail  ·  aromate, assaisonnement, condiment, légume, vampire  ·  garlic food spice cook  legume
🧅 oignon  ·  assaisonnement, condiment, légume, ognon  ·  onion cook food spice  legume
🍄 champignon  ·  champignon vénéneux, Mario, plante  ·  mushroom plant vegetable  champignon veneneux
🥜 cacahuètes  ·  arachide, cacahuète, noisette, nourriture  ·  peanuts food nut  cacahuetes cacahuete
🌰 châtaigne  ·  marron, nourriture, plante  ·  chestnut food squirrel  chataigne
🍞 pain  ·  miche, nourriture, pain de mie  ·  bread food wheat breakfast toast
🥐 croissant  ·  nourriture, pain, petit-déjeuner, viennoiserie  ·  croissant food bread french  petit-dejeuner
🥖 baguette  ·  nourriture, pain  ·  baguette bread food bread french
🥨 bretzel  ·  nourriture, torsade  ·  pretzel food bread twisted
🥯 bagel  ·  boulangerie, petit-déjeuner, sandwich, schmear  ·  bagel food bread bakery schmear  petit-dejeuner
🥞 pancakes  ·  crêpe, goûter, nourriture, pancake, petit-déjeuner  ·  pancakes food breakfast flapjacks hotcakes  crepe gouter petit-dejeuner
🧇 gaufre  ·  brunch, gourmandise, goûter, moule, pâtisserie, petit déjeuner, petit-déjeuner  ·  waffle food breakfast  gouter patisserie petit dejeuner petit-dejeuner
🧀 part de fromage  ·  fromage, nourriture  ·  cheese wedge food chadder
🍖 viande sur un os  ·  nourriture, os, viande  ·  meat on bone good food drumstick
🍗 cuisse de poulet  ·  cuisse, dinde, nourriture, os, poulet, volaille  ·  poultry leg food meat drumstick bird chicken turkey
🥩 morceau de viande  ·  côtelette, côtelette d’agneau, côtelette de porc, nourriture, steak, viande, viande rouge  ·  cut of meat food cow meat cut chop lambchop porkchop  cotelette cotelette d'agneau cotelette de porc
🥓 lard  ·  bacon, nourriture, porc, viande  ·  bacon food breakfast pork pig meat
🍔 hamburger  ·  burger, cheeseburger, fast food, nourriture  ·  hamburger meat fast food beef cheeseburger mcdonalds burger king
🍟 frites  ·  fast food, potatoes, potatœs  ·  french fries chips snack fast food  potatoes
🍕 pizza  ·  fromage, nourriture, part, pepperoni, tranche  ·  pizza food party
🌭 hot dog  ·  nourriture, saucisse, saucisse de Francfort  ·  hot dog food frankfurter
🥪 sandwich  ·  nourriture, pain, pain de mie, pique-nique  ·  sandwich food lunch bread
🌮 taco  ·  mexicain, nourriture  ·  taco food mexican
🌯 burrito  ·  kebab, mexicain, wrap  ·  burrito food mexican
🥙 kebab  ·  falafel, nourriture, pain pita  ·  stuffed flatbread food flatbread stuffed gyro
🧆 falafels  ·  boulette, boulettes, falafel, pois chiches, seitan, soja, viande  ·  falafel food
🥚 œuf  ·  nourriture  ·  egg food chicken breakfast  oeuf
🍳 œuf au plat  ·  cuisine, friture, nourriture, œuf, petit-déjeuner, poêle, poêle à frire, se faire cuire un œuf  ·  cooking food breakfast kitchen egg  oeuf au plat oeuf petit-dejeuner poele poele a frire se faire cuire un oeuf
🥘 plat mitonné  ·  casserole, Espagne, paella, plat, poêle, riz  ·  shallow pan of food food cooking casserole paella  plat mitonne poele
🍲 marmite  ·  nourriture, ragoût  ·  pot of food food meat soup  ragout
🥣 bol avec cuillère  ·  bol avec une cuillère, céréales, congee, déjeuner, petit déjeuner, soupe  ·  bowl with spoon food breakfast cereal oatmeal porridge  bol avec cuillere bol avec une cuillere cereales dejeuner petit dejeuner
🥗 salade verte  ·  nourriture, salade, verte  ·  green salad food healthy lettuce
🍿 pop-corn  ·  cinéma, nourriture  ·  popcorn food movie theater films snack  cinema
🧈 beurre  ·  gras, produit laitier  ·  butter food cook
🧂 sel  ·  condiment, salé, salière, saveur  ·  salt condiment shaker  sale saliere
🥫 aliments en conserve  ·  boîte de conserve, conserve, nourriture  ·  canned food food soup  boite de conserve
🍱 boîte déjeuner  ·  bento, boîte, déjeuner, nourriture  ·  bento box food japanese box  boite dejeuner boite dejeuner
🍘 galette de riz  ·  cracker, nourriture, riz  ·  rice cracker food japanese
🍙 boulette de riz  ·  japonais, nourriture, onigiri, plat, riz  ·  rice ball food japanese
🍚 bol de riz  ·  nourriture, riz  ·  cooked rice food china asian
🍛 riz au curry  ·  curry, nourriture, riz  ·  curry rice food spicy hot indian
🍜 bol fumant  ·  bol, nouilles, nourriture, ramen, vapeur  ·  steaming bowl food japanese noodle chopsticks
🍝 spaghetti  ·  italien, nourriture, pâtes, restaurant, sauce bolognaise  ·  spaghetti food italian noodle  pates
🍠 patate douce  ·  nourriture, patate, patate douce au four  ·  roasted sweet potato food nature
🍢 brochette de poisson  ·  brochette, fruits de mer, nourriture, restaurant  ·  oden food japanese
🍣 sushi  ·  japonais, nourriture, poisson, riz  ·  sushi food fish japanese rice
🍤 beignet de crevette  ·  crevette  ·  fried shrimp food animal appetizer summer
🍥 croquette de poisson  ·  gâteau, narutomaki, nourriture, poisson, restaurant, surimi  ·  fish cake with swirl food japan sea beach narutomaki pink swirl kamaboko surimi ramen  gateau
🥮 gâteau de lune  ·  automne, festival, moon cake, yuèbǐng  ·  moon cake food autumn  gateau de lune yuebing
🍡 brochette de bonbons  ·  bonbons, dango, dessert, japonais, nourriture  ·  dango food dessert sweet japanese barbecue meat
🥟 boulette de pâte  ·  dumpling, empanada, gyoza, jiaozi, pierogi, potsticker, ravioli  ·  dumpling food empanada pierogi potsticker  boulette de pate
🥠 biscuit chinois  ·  nourriture, prophétie  ·  fortune cookie food prophecy  prophetie
🥡 boîte à emporter  ·  baguettes, carton, chinois, nourriture à emporter  ·  takeout box food leftovers  boite a emporter nourriture a emporter
🦀 crabe  ·  animal, astrologie, Cancer, horoscope, mer, pinces, plage, zodiaque  ·  crab animal crustacean
🦞 homard  ·  animal, bisque, fruit de mer, fruits de mer, pinces  ·  lobster animal nature bisque claws seafood
🦐 crevette  ·  aliment, crustacé, fruits de mer, nourriture  ·  shrimp animal ocean nature seafood  crustace
🦑 calamar  ·  aliment, animal, encornet, mollusque, nourriture  ·  squid animal nature ocean sea
🦪 huître  ·  coquillage, coquille, mollusque, perle  ·  oyster food  huitre
🍦 glace italienne  ·  cornet de glace, dessert, glace, nourriture, sucré  ·  soft ice cream food hot dessert summer  sucre
🍧 granité  ·  coupe de glace, crème glacée, dessert, glace, nourriture, restaurant, sucré  ·  shaved ice hot dessert summer  granite creme glacee sucre
🍨 glace  ·  coupe de glace, crème, crème glacée, dessert, nourriture, restaurant, sucré  ·  ice cream food hot dessert  creme creme glacee sucre
🍩 doughnut  ·  dessert, donut, goûter, nourriture, sucré, sucrerie  ·  doughnut food dessert snack sweet donut  gouter sucre
🍪 cookie  ·  biscuit, dessert, gâteau, goûter, nourriture, pépites de chocolat, sucré  ·  cookie food snack oreo chocolate sweet dessert  gateau gouter pepites de chocolat sucre
🎂 gâteau d’anniversaire  ·  anniversaire, bougies, dessert, fête, gâteau, goûter, joyeux anniversaire, nourriture, pâtisserie  ·  birthday cake food dessert cake  gateau d'anniversaire fete gateau gouter patisserie
🍰 gâteau sablé  ·  dessert, gâteau, goûter, nourriture, pâtisserie, sucré  ·  shortcake food dessert  gateau sable gateau gouter patisserie sucre
🧁 cupcake  ·  dessert, muffin, pâtisserie, sucre, sucrerie  ·  cupcake food dessert bakery sweet  patisserie
🥧 tarte  ·  décoration, garniture, gâteau, nourriture, pâte à tarte, pâtisserie, tarte aux fruits, tourte  ·  pie food dessert pastry  decoration gateau pate a tarte patisserie
🍫 barre chocolatée  ·  barre, chocolat, dessert, goûter, nourriture, sucré  ·  chocolate bar food snack dessert sweet  barre chocolatee gouter sucre
🍬 bonbon  ·  dessert, goûter, nourriture, sucré, sucrerie  ·  candy snack dessert sweet lolly  gouter sucre
🍭 sucette  ·  dessert, goûter, nourriture, sucré, sucrerie  ·  lollipop food snack candy sweet  gouter sucre
🍮 crème renversée  ·  dessert, flan, nourriture, pudding, sucré  ·  custard dessert food  creme renversee sucre
🍯 pot de miel  ·  miel, nourriture, ours, pot, sucré  ·  honey pot bees sweet kitchen  sucre
🍼 biberon  ·  bébé, boisson, lait, naissance, nouveau-né, tétine  ·  baby bottle food container milk  bebe nouveau-ne tetine
🥛 verre de lait  ·  boisson, lait, verre  ·  glass of milk beverage drink cow
☕ boisson chaude  ·  boisson, café, caféine, matin, thé  ·  hot beverage beverage caffeine latte espresso coffee  cafe cafeine the
🍵 tasse  ·  boisson, tasse de thé sans anse, thé  ·  teacup without handle drink bowl breakfast green british  tasse de the sans anse the
🍶 saké  ·  boisson, bouteille, bouteille et verre, restaurant, verre  ·  sake wine drink drunk beverage japanese alcohol booze  sake
🍾 bouteille de champagne  ·  alcool, boisson, bouchon, bouteille, champagne, félicitations, fête, pop  ·  bottle with popping cork drink wine bottle celebration  felicitations fete
🍷 verre de vin  ·  alcool, bar, boisson, club, restaurant, verre, verre à vin, vin  ·  wine glass drink beverage drunk alcohol booze  verre a vin
🍸 cocktail  ·  alcool, bar, boisson, club, martini, verre, verre à cocktail, verre à pied  ·  cocktail glass drink drunk alcohol beverage booze mojito  verre a cocktail verre a pied
🍹 cocktail tropical  ·  alcool, bar, boîte, cocktail, fête, tequila sunrise, verre  ·  tropical drink beverage cocktail summer beach alcohol booze mojito  boite fete
🍺 chope  ·  alcool, bar, bière, boisson, chope de bière, oktoberfest, picoler, pinte, santé  ·  beer mug relax beverage drink drunk party pub summer alcohol booze  biere chope de biere sante
🍻 chopes de bière  ·  alcool, bière, boisson, santé, tchin, trinquer  ·  clinking beer mugs relax beverage drink drunk party pub summer alcohol booze  chopes de biere biere sante
🥂 trinquer  ·  alcool, célébrer, champagne, fêter, santé, tchin, verre, verres  ·  clinking glasses beverage drink party alcohol celebrate cheers wine champagne toast  celebrer feter sante
🥃 verre tumbler  ·  alcool, liqueur, tumbler, verre, whisky  ·  tumbler glass drink beverage drunk alcohol liquor booze bourbon scotch whisky glass shot
🥤 gobelet avec paille  ·  boisson, eau, jus de fruit, jus de fruits, soda, verre avec une paille  ·  cup with straw drink soda
🧃 briquette de jus  ·  boisson, carton, jus, jus de fruits, paille  ·  beverage box drink
🧉 maté  ·  boisson  ·  mate drink tea beverage  mate
🧊 glaçon  ·  cube, froid, glace, iceberg  ·  ice water cold  glacon
🥢 baguettes  ·  hashi  ·  chopsticks food
🍽️ fourchette et couteau avec assiette  ·  assiette, assiette et couverts, couteau, cuisine, fourchette, restaurant, table  ·  fork and knife with plate food eat meal lunch dinner restaurant
🍴 fourchette et couteau  ·  couteau et fourchette, couverts, faim, manger, nourriture, repas, restaurant  ·  fork and knife cutlery kitchen
🥄 cuillère  ·  couvert, manger  ·  spoon cutlery kitchen tableware  cuillere
🔪 couteau de cuisine  ·  arme, chef, couteau, cuisine, outil  ·  kitchen knife knife blade cutlery kitchen weapon
🏺 amphore  ·  astrologie, cuisine, grec, Grèce, horoscope, vase, Verseau, zodiaque  ·  amphora vase jar  Grece
🌍 globe tourné sur l’Afrique et l’Europe  ·  afrique, Afrique, espace, europe, Europe, globe, globe présentant l’Europe et l’Afrique, monde, planète, Terre  ·  globe showing europe africa globe world international  globe tourne sur l'Afrique et l'Europe globe presentant l'Europe et l'Afrique planete
🌎 globe tourné sur les Amériques  ·  amérique, Amérique, espace, globe, globe présentant l’Amérique, monde, planète, Terre  ·  globe showing americas globe world USA international  globe tourne sur les Ameriques amerique Amerique globe presentant l'Amerique planete
🌏 globe tourné sur l’Asie et l’Australie  ·  asie, Asie, australie, Australie, espace, globe, globe présentant l’Asie et l’Australie, monde, planète, Terre  ·  globe showing asia australia globe world east international  globe tourne sur l'Asie et l'Australie globe presentant l'Asie et l'Australie planete
🌐 globe avec méridiens  ·  globe terrestre, Internet, méridiens, monde, net, toile  ·  globe with meridians earth international world internet interweb i18n  globe avec meridiens meridiens
🗺️ carte du monde  ·  carte, monde, planisphère, voyage  ·  world map location direction  planisphere
🗾 carte du Japon  ·  carte, japon, voyage  ·  map of japan nation country japanese asia
🧭 boussole  ·  compas, direction, magnétique, navigation, orientation  ·  compass magnetic navigation orienteering  magnetique
🏔️ montagne enneigée  ·  froid, montagne, neige, sommet, voyage  ·  snow capped mountain photo nature environment winter cold  montagne enneigee
⛰️ montagne  ·  nature, sommet, voyage  ·  mountain photo nature environment
🌋 volcan  ·  éruption, lave, nature  ·  volcano photo nature disaster  eruption
🗻 mont Fuji  ·  montagne, nature, sommet, voyage  ·  mount fuji photo mountain nature japanese
🏕️ camping  ·  nature, tente avec un sapin, voyage  ·  camping photo outdoors tent
🏖️ plage avec parasol  ·  parasol, plage, voyage  ·  beach with umbrella weather summer sunny sand mojito
🏜️ désert  ·  voyage  ·  desert photo warm saharah  desert
🏝️ île déserte  ·  cocotier, île, palmier, voyage  ·  desert island photo tropical mojito  ile deserte ile
🏞️ parc national  ·  nature, voyage  ·  national park photo environment nature
🏟️ stade  ·  stadium photo place sports concert venue
🏛️ monument classique  ·  colonnes, monument, voyage  ·  classical building art culture history
🏗️ construction d’un bâtiment  ·  chantier, construction, grue  ·  building construction wip working progress  construction d'un batiment
🧱 brique  ·  argile, briques, mortier, mur, mur de briques, the wall, voie 9 3/4  ·  brick bricks
🏘️ maisons  ·  bâtiment, bâtiments, maison, pavillons  ·  houses buildings photo  batiment batiments
🏚️ maison abandonnée  ·  maison  ·  derelict house abandon evict broken building  maison abandonnee
🏠 maison  ·  bâtiment, foyer, maison simple, pavillon, résidentiel  ·  house building home  batiment residentiel
🏡 maison avec jardin  ·  foyer, jardin, maison, pavillon, résidentiel  ·  house with garden home plant nature  residentiel
🏢 immeuble de bureaux  ·  bureaux, immeuble, ville  ·  office building building bureau work
🏣 bureau de poste japonais  ·  bâtiment, Japon, poste, poste japonaise, voyage  ·  japanese post office building envelope communication  batiment
🏤 bureau de poste  ·  bâtiment, européen, poste  ·  post office building email  batiment europeen
🏥 hôpital  ·  bâtiment, docteur, médecin, urgences  ·  hospital building health surgery doctor  hopital batiment medecin
🏦 banque  ·  bâtiment  ·  bank building money sales cash business enterprise  batiment
🏨 hôtel  ·  bâtiment, voyage  ·  hotel building accomodation checkin  hotel batiment
🏩 love hotel  ·  amour, bâtiment, cœur, hôtel, voyage  ·  love hotel like affection dating  batiment coeur hotel
🏪 supérette  ·  24h/24, bâtiment, épicerie, magasin, supermarché  ·  convenience store building shopping groceries  superette batiment epicerie supermarche
🏫 école  ·  bâtiment  ·  school building student education learn teach  ecole batiment
🏬 grand magasin  ·  bâtiment, centre commercial, magasin  ·  department store building shopping mall  batiment
🏭 usine  ·  bâtiment  ·  factory building industry pollution smoke  batiment
🏯 château japonais  ·  bâtiment, château, japonais, voyage  ·  japanese castle photo building  chateau japonais batiment chateau
🏰 château  ·  bâtiment, européen, voyage  ·  castle building royalty history  chateau batiment europeen
💒 mariage  ·  amour, chapelle, cœur, église  ·  wedding love like affection couple marriage bride groom  coeur eglise
🗼 tour de Tokyo  ·  Japon, Tokyo, tour, voyage  ·  tokyo tower photo japanese
🗽 statue de la Liberté  ·  liberté, New York, statue, statue de la liberté, voyage  ·  statue of liberty american newyork  statue de la Liberte liberte statue de la liberte
⛪ église  ·  bâtiment, chapelle, chrétien, croix, religion, voyage  ·  church building religion christ  eglise batiment chretien
🕌 mosquée  ·  islam, musulman, musulmane, religion, voyage  ·  mosque islam worship minaret  mosquee
🛕 temple hindou  ·  bouddhisme, hindou, pagode, religion, stupa, temple, temple bouddhiste  ·  hindu temple religion
🕍 synagogue  ·  judaïsme, juif, juive, religion, temple, voyage  ·  synagogue judaism worship temple jewish  judaisme
⛩️ sanctuaire shinto  ·  religion, shinto, voyage  ·  shinto shrine temple japan kyoto
🕋 kaaba  ·  islam, Kaaba, musulman, musulmane, religion, voyage  ·  kaaba mecca mosque islam
⛲ fontaine  ·  eau  ·  fountain photo summer water fresh
⛺ tente  ·  camping, nature, voyage  ·  tent photo camping outdoors
🌁 brume  ·  brouillard, voyage  ·  foggy photo mountain
🌃 nuit étoilée  ·  étoiles, nuit, ville, voyage  ·  night with stars evening city downtown  nuit etoilee etoiles
🏙️ ville  ·  bâtiment, voyage  ·  cityscape photo night life urban  batiment
🌄 soleil levant derrière les montagnes  ·  lever de soleil, matin, nature, soleil, voyage  ·  sunrise over mountains view vacation photo  soleil levant derriere les montagnes
🌅 soleil levant  ·  lever de soleil, matin, nature, soleil, voyage  ·  sunrise morning view vacation photo
🌆 ville au crépuscule  ·  coucher de soleil, crépuscule, immeubles, soir, soleil, tombée de la nuit, ville, voyage  ·  cityscape at dusk photo evening sky buildings  ville au crepuscule crepuscule tombee de la nuit
🌇 coucher de soleil  ·  coucher de soleil en ville, crépuscule, soir, soleil, tombée de la nuit, ville, voyage  ·  sunset photo good morning dawn  crepuscule tombee de la nuit
🌉 pont de nuit  ·  nuit, pont  ·  bridge at night photo sanfrancisco
♨️ sources chaudes  ·  chaud, source, vapeur  ·  hot springs bath warm relax
🎠 cheval de manège  ·  cheval, manège  ·  carousel horse photo carnival  cheval de manege manege
🎡 grande roue  ·  attractions, parc d’attractions, roue  ·  ferris wheel photo carnival londoneye  parc d'attractions
🎢 montagnes russes  ·  attractions, montagnes, parc d’attractions, russes  ·  roller coaster carnival playground photo fun  parc d'attractions
💈 enseigne de barbier  ·  barbier, coiffeur, coiffure, enseigne, salon  ·  barber pole hair salon style
🎪 chapiteau  ·  cirque  ·  circus tent festival carnival party
🚂 locomotive  ·  chemin de fer, machine à vapeur, moyen de transport, rail, tchou tchou, train, vapeur, voyage  ·  locomotive transportation vehicle train  machine a vapeur
🚃 wagon  ·  chemin de fer, moyen de transport, rail, train, tram, tramway, voiture, voyage  ·  railway car transportation vehicle
🚄 TGV  ·  chemin de fer, moyen de transport, rail, rapide, train, train à grande vitesse, vitesse, voyage  ·  high speed train transportation vehicle  train a grande vitesse
🚅 train à grande vitesse  ·  chemin de fer, moyen de transport, rail, rapide, TGV, train, voyage  ·  bullet train transportation vehicle speed fast public travel  train a grande vitesse
🚆 train  ·  arrivée, chemin de fer, moyen de transport, rail, voyage  ·  train transportation vehicle  arrivee
🚇 métro  ·  moyen de transport  ·  metro transportation blue-square mrt underground tube  metro
🚈 métro léger  ·  métro, monorail, moyen de transport, rail, RER  ·  light rail transportation vehicle  metro leger metro
🚉 gare  ·  chemin de fer, moyen de transport, rail, RER, train  ·  station transportation vehicle public
🚊 tramway  ·  moyen de transport, RER, tram, transport, trolley, trolleybus  ·  tram transportation vehicle
🚝 monorail  ·  moyen de transport, véhicule  ·  monorail transportation vehicle  vehicule
🚞 train de montagne  ·  chemin de fer, moyen de transport, rail, train, voyage, wagon  ·  mountain railway transportation vehicle
🚋 wagon de tramway  ·  moyen de transport, tram, trolleybus, voiture, voyage  ·  tram car transportation vehicle carriage public travel
🚌 bus  ·  école, moyen de transport, véhicule  ·  bus car vehicle transportation  ecole vehicule
🚍 bus de face  ·  bus, bus qui arrive, car, moyen de transport  ·  oncoming bus vehicle transportation
🚎 trolleybus  ·  bus, moyen de transport, tram, tramway, trolley  ·  trolleybus bart transportation vehicle
🚐 minibus  ·  bus, moyen de transport, navette, véhicule  ·  minibus vehicle car transportation  vehicule
🚑 ambulance  ·  urgences, véhicule  ·  ambulance health 911 hospital  vehicule
🚒 camion de pompier  ·  pin-pon, pompier  ·  fire engine transportation cars vehicle
🚓 voiture de police  ·  flic, patrouille, police, véhicule  ·  police car vehicle cars transportation law legal enforcement  vehicule
🚔 voiture de police de face  ·  police, véhicule, voiture de police qui arrive  ·  oncoming police car vehicle law legal enforcement 911  vehicule
🚕 taxi  ·  moyen de transport, taxi jaune, uber, véhicule  ·  taxi uber vehicle cars transportation  vehicule
🚖 taxi de face  ·  joe le taxi, new york, taxi, taxi jaune, uber, voiture  ·  oncoming taxi vehicle cars uber
🚗 voiture  ·  automobile, conduire, moyen de transport, véhicule, voyage  ·  automobile red transportation vehicle  vehicule
🚘 voiture de face  ·  automobile, conduire, moyen de transport, véhicule, voiture, voiture qui arrive, voyage  ·  oncoming automobile car vehicle transportation  vehicule
🚙 véhicule utilitaire sport  ·  automobile, conduire, loisirs, moyen de transport, véhicule de loisirs, voiture, voyage  ·  sport utility vehicle transportation vehicle  vehicule utilitaire sport vehicule de loisirs
🚚 camion de livraison  ·  camion, camionnette, moyen de transport, véhicule  ·  delivery truck cars transportation  vehicule
🚛 semi-remorque  ·  camion, moyen de transport, poids lourd, semi, véhicule  ·  articulated lorry vehicle cars transportation express  vehicule
🚜 tracteur  ·  moyen de transport, véhicule  ·  tractor vehicle car farming agriculture  vehicule
🏎️ voiture de course  ·  course, course automobile, formule 1, voiture  ·  racing car sports race fast formula f1
🏍️ moto  ·  course  ·  motorcycle race sports fast
🛵 scooter  ·  motor scooter vehicle vespa sasha
🦽 fauteuil roulant manuel  ·  accessibilité, fauteuil roulant, handicap  ·  manual wheelchair accessibility  accessibilite
🦼 fauteuil motorisé  ·  accessibilité, fauteuil roulant, fauteuil roulant motorisé, handicap  ·  motorized wheelchair accessibility  fauteuil motorise accessibilite fauteuil roulant motorise
🛺 tuk tuk  ·  rickshaw, taxi, thaï, tricycle  ·  auto rickshaw move transportation  thai
🚲 vélo  ·  bicyclette, cyclisme, moyen de transport, voyage  ·  bicycle sports bicycle exercise hipster  velo
🛴 trottinette  ·  kick scooter vehicle kick razor
🛹 planche à roulettes  ·  glisse, longboard, roulettes, skate, skateboard  ·  skateboard board  planche a roulettes
🚏 arrêt de bus  ·  bus  ·  bus stop transportation wait  arret de bus
🛣️ autoroute  ·  route, voyage  ·  motorway road cupertino interstate highway
🛤️ voie ferrée  ·  chemin de fer, rail, train, voyage  ·  railway track train transportation  voie ferree
🛢️ baril de pétrole  ·  baril, pétrole  ·  oil drum barrell  baril de petrole petrole
⛽ pompe à essence  ·  diesel, essence, gazole, station  ·  fuel pump gas station petroleum  pompe a essence
🚨 gyrophare  ·  alarme, alerte, lumière, police, sirène, urgences, voiture  ·  police car light police ambulance 911 emergency alert error pinged law legal  lumiere sirene
🚥 feu tricolore horizontal  ·  carrefour, croisement, feu, feu de circulation, tricolore  ·  horizontal traffic light transportation signal
🚦 feu tricolore vertical  ·  carrefour, croisement, feu, feu de circulation, tricolore  ·  vertical traffic light transportation driving
🛑 stop  ·  octogonal, panneau, signe  ·  stop sign stop
🚧 travaux  ·  barrière  ·  construction wip progress caution warning  barriere
⚓ ancre  ·  bateau, outil, voyage  ·  anchor ship ferry sea boat
⛵ voilier  ·  bateau, mer, moyen de transport, plaisance, voyage, yacht  ·  sailboat ship summer transportation water sailing
🛶 canoë  ·  bateau, rame, ramer  ·  canoe boat paddle water ship  canoe
🚤 hors-bord  ·  bateau, été, luxe, moyen de transport, vedette, voyage  ·  speedboat ship transportation vehicle summer  ete
🛳️ paquebot  ·  bateau, croisière, voyage  ·  passenger ship yacht cruise ferry  croisiere
⛴️ ferry  ·  bateau, moyen de transport, voyage  ·  ferry boat ship yacht
🛥️ bateau à moteur  ·  bateau  ·  motor boat ship  bateau a moteur
🚢 navire  ·  bateau, croisière, moyen de transport, paquebot, Titanic, voyage  ·  ship transportation titanic deploy  croisiere
✈️ avion  ·  avion en vol, jet, moyen de transport, véhicule, vol, voyage  ·  airplane vehicle transportation flight fly  vehicule
🛩️ petit avion  ·  avion, moyen de transport, voyage  ·  small airplane flight transportation fly vehicle
🛫 avion au décollage  ·  avion, décollage, départ, moyen de transport, voyage  ·  airplane departure airport flight landing  avion au decollage decollage depart
🛬 avion à l’atterrissage  ·  arrivée, atterrissage, avion, moyen de transport, voyage  ·  airplane arrival airport flight boarding  avion a l'atterrissage arrivee
🪂 parachute  ·  chute libre, parachute ascensionnel, parapente, sensations fortes  ·  parachute fly glide
💺 siège  ·  chaise, fauteuil, place  ·  seat sit airplane transport bus flight fly  siege
🚁 hélicoptère  ·  hélico, moyen de transport, véhicule  ·  helicopter transportation vehicle fly  helicoptere helico vehicule
🚟 train suspendu  ·  moyen de transport, train, voyage  ·  suspension railway vehicle transportation
🚠 téléphérique  ·  montagne, moyen de transport, ski, télécabine  ·  mountain cableway transportation vehicle ski  telepherique telecabine
🚡 tramway aérien  ·  moyen de transport, télécabine, tramway  ·  aerial tramway transportation vehicle ski  tramway aerien telecabine
🛰️ satellite  ·  espace  ·  satellite communication gps orbit spaceflight NASA ISS
🚀 fusée  ·  décollage, espace, moyen de transport, voyage  ·  rocket launch ship staffmode NASA outer space outer space fly  fusee decollage
🛸 soucoupe volante  ·  alien, extraterrestre, ovni, OVNI  ·  flying saucer transportation vehicle ufo
🛎️ cloche de comptoir  ·  cloche, clochette, hôtel, réception, sonnette  ·  bellhop bell service  hotel reception
🧳 bagage  ·  valise, voyage  ·  luggage packing travel
⌛ sablier  ·  chronomètre, minuteur, sable, temps  ·  hourglass done time clock oldschool limit exam quiz test  chronometre
⏳ sablier avec sable qui coule  ·  attendre, chronomètre, minuteur, sable, sablier, temps  ·  hourglass not done oldschool time countdown  chronometre
⌚ montre  ·  heure  ·  watch time accessories
⏰ réveil  ·  alarme, attendre, dring, heure, matin, retard, sonnerie  ·  alarm clock time wake  reveil
⏱️ chronomètre  ·  heure, temps  ·  stopwatch time deadline  chronometre
⏲️ horloge  ·  heure, minuteur, temps  ·  timer clock alarm
🕰️ pendule  ·  horloge, horloge posée  ·  mantelpiece clock time  horloge posee
🕛 midi/minuit  ·  0 h, 12 h, heure, horloge, midi, midi pile, minuit, minuit pile  ·  twelve o clock time noon midnight midday late early schedule
🕧 midi/minuit et demie  ·  00 h 30, 12 h 30, heure, horloge, midi et demi, minuit et demi  ·  twelve thirty time late early schedule
🕐 une heure  ·  1 h, 13 h, heure, horloge, treize heures  ·  one o clock time late early schedule
🕜 une heure et demie  ·  1 h 30, 13 h 30, heure, horloge, treize heures trente  ·  one thirty time late early schedule
🕑 deux heures  ·  14 h, 2 h, heure, horloge, quatorze heures  ·  two o clock time late early schedule
🕝 deux heures et demie  ·  14 h 30, 2 h 30, heure, horloge, quatorze heures trente  ·  two thirty time late early schedule
🕒 trois heures  ·  15 h, 3 h, heure, horloge, quinze heures  ·  three o clock time late early schedule
🕞 trois heures et demie  ·  15 h 30, 3 h 30, heure, horloge, quinze heures trente  ·  three thirty time late early schedule
🕓 quatre heures  ·  16 h, 4 h, seize heures  ·  four o clock time late early schedule
🕟 quatre heures et demie  ·  16 h 30, 4 h 30, heure, horloge, seize heures trente  ·  four thirty time late early schedule
🕔 cinq heures  ·  17 h, 5 h, dix-sept heures, heure, horloge  ·  five o clock time late early schedule
🕠 cinq heures et demie  ·  17 h 30, 5 h 30, dix-sept heures trente, heure, horloge  ·  five thirty time late early schedule
🕕 six heures  ·  18 h, 6 h, dix-huit heures, heure, horloge  ·  six o clock time late early schedule dawn dusk
🕡 six heures et demie  ·  18 h 30, 6 h 30, dix-huit heures trente, heure, horloge  ·  six thirty time late early schedule
🕖 sept heures  ·  19 h, 7 h, dix-neuf heures, heure, horloge  ·  seven o clock time late early schedule
🕢 sept heures et demie  ·  19 h 30, 7 h 30, dix-neuf heures trente, heure, horloge  ·  seven thirty time late early schedule
🕗 huit heures  ·  20 h, 8 h, heure, horloge, vingt heures  ·  eight o clock time late early schedule
🕣 huit heures et demie  ·  20 h 30, 8 h 30, heure, horloge, vingt heures trente  ·  eight thirty time late early schedule
🕘 neuf heures  ·  21 h, 9 h  ·  nine o clock time late early schedule
🕤 neuf heures et demie  ·  21 h 30, 9 h 30, heure, horloge, vingt et une heures trente  ·  nine thirty time late early schedule
🕙 dix heures  ·  10 h, 22 h, heure, horloge, vingt-deux heures  ·  ten o clock time late early schedule
🕥 dix heures et demie  ·  10 h 30, 22 h 30, heure, horloge, vingt-deux heures trente  ·  ten thirty time late early schedule
🕚 onze heures  ·  11 h, 23 h, heure, horloge, vingt-trois heures  ·  eleven o clock time late early schedule
🕦 onze heures et demie  ·  11 h 30, 23 h 30, heure, horloge, vingt-trois heures trente  ·  eleven thirty time late early schedule
🌑 nouvelle lune  ·  espace, lune, sombre  ·  new moon nature twilight planet space night evening sleep
🌒 lune croissante  ·  espace, lune, nuit  ·  waxing crescent moon nature twilight planet space night evening sleep
🌓 premier quartier de lune  ·  espace, lune, nuit, premier quartier, quartier  ·  first quarter moon nature twilight planet space night evening sleep
🌔 lune gibbeuse croissante  ·  croissant, espace, gibbeux, lune, nuit  ·  waxing gibbous moon nature night sky gray twilight planet space evening sleep
🌕 pleine lune  ·  espace, lune, nuit  ·  full moon nature yellow twilight planet space night evening sleep
🌖 lune gibbeuse décroissante  ·  décroissant, espace, gibbeux, lune, nuit  ·  waning gibbous moon nature twilight planet space night evening sleep waxing gibbous moon  lune gibbeuse decroissante decroissant
🌗 dernier quartier de lune  ·  dernier quartier, espace, lune, quartier  ·  last quarter moon nature twilight planet space night evening sleep
🌘 lune décroissante  ·  croissant, croissant de lune, espace, lune, lune descendante, nuit  ·  waning crescent moon nature twilight planet space night evening sleep  lune decroissante
🌙 croissant de lune  ·  croissant, espace, lune, nuit, Ramadan  ·  crescent moon night sleep sky evening magic
🌚 nouvelle lune avec visage  ·  espace, lune, nouvelle lune à visage, nuit, visage  ·  new moon face nature twilight planet space night evening sleep  nouvelle lune a visage
🌛 premier quartier de lune avec visage  ·  croissant de lune, espace, lune, lune à visage, nuit, premier quartier de lune, quartier, visage  ·  first quarter moon face nature twilight planet space night evening sleep  lune a visage
🌜 dernier quartier de lune avec visage  ·  croissant de lune, dernier quartier de lune, lune, lune à visage, nuit, quartier, visage  ·  last quarter moon face nature twilight planet space night evening sleep  lune a visage
🌡️ thermomètre  ·  météo  ·  thermometer weather temperature hot cold  thermometre meteo
☀️ soleil  ·  beau temps, brillant, espace, grand soleil, météo, rayons  ·  sun weather nature brightness summer beach spring  meteo
🌝 pleine lune avec visage  ·  lune, lune à visage, nuit, pleine lune, sourire, visage  ·  full moon face nature twilight planet space night evening sleep  lune a visage
🌞 soleil avec visage  ·  chaleur, chaud, éclatant, ensoleillé, jour, lumière, météo, plage, rayon de soleil, soleil, soleil à visage  ·  sun with face nature morning sky  eclatant ensoleille lumiere meteo soleil a visage
🪐 planète à anneaux  ·  anneaux, saturne, saturnien, saturnienne  ·  ringed planet outerspace  planete a anneaux
⭐ étoile  ·  astronomie, nuit  ·  star night yellow  etoile
🌟 étoile brillante  ·  éclat, étincelant, étincelle, étoile, nuit, nuit étoilée, succès  ·  glowing star night sparkle awesome good magic  etoile brillante eclat etincelant etincelle etoile nuit etoilee succes
🌠 étoile filante  ·  espace, étoile, nuit  ·  shooting star night photo  etoile filante etoile
🌌 voie lactée  ·  espace  ·  milky way photo space stars  voie lactee
☁️ nuage  ·  gris, météo  ·  cloud weather sky  meteo
⛅ soleil derrière les nuages  ·  caché, météo, nuage, nuageux, soleil, soleil derrière nuages  ·  sun behind cloud weather nature cloudy morning fall spring  soleil derriere les nuages cache meteo soleil derriere nuages
⛈️ nuage avec éclair et pluie  ·  éclair, météo, nuage, orage, pluie  ·  cloud with lightning and rain weather lightning  nuage avec eclair et pluie eclair meteo
🌤️ soleil derrière un petit nuage  ·  caché, météo, nuage, soleil, soleil derrière petit nuage  ·  sun behind small cloud weather  soleil derriere un petit nuage cache meteo soleil derriere petit nuage
🌥️ soleil derrière un gros nuage  ·  caché, météo, nuage, soleil, soleil derrière gros nuage  ·  sun behind large cloud weather  soleil derriere un gros nuage cache meteo soleil derriere gros nuage
🌦️ soleil derrière un nuage de pluie  ·  caché, gouttes, météo, nuage, pluie, soleil, soleil derrière un nuage  ·  sun behind rain cloud weather  soleil derriere un nuage de pluie cache meteo soleil derriere un nuage
🌧️ nuage avec pluie  ·  averse, gouttes, mauvais temps, météo, nuage, nuage de pluie, pluie  ·  cloud with rain weather  meteo
🌨️ nuage avec neige  ·  flocons, froid, hiver, météo, neige, nuage, nuage de neige  ·  cloud with snow weather  meteo
🌩️ nuage avec éclair  ·  éclair, nuage, nuage avec un éclair, orage, orageux, temps  ·  cloud with lightning weather thunder  nuage avec eclair eclair nuage avec un eclair
🌪️ tornade  ·  cyclone, météo, nuage, tourbillon  ·  tornado weather cyclone twister  meteo
🌫️ brouillard  ·  brume, fog, météo, nuage  ·  fog weather  meteo
🌬️ vent avec visage  ·  météo, nuage, souffle, vent, visage, visage du vent  ·  wind face gust air  meteo
🌀 cyclone  ·  spirale, tourbillon, typhon, vertige  ·  cyclone weather swirl blue cloud vortex spiral whirlpool spin tornado hurricane typhoon
🌈 arc-en-ciel  ·  bisexuelle, Gay Pride, homosexuelle, lesbienne, LGBTQIA, météo, nature, pluie, transgenre  ·  rainbow nature happy unicorn face photo sky spring  meteo
🌂 parapluie fermé  ·  météo, parapluie, pluie  ·  closed umbrella weather rain drizzle  parapluie ferme meteo
☂️ parapluie ouvert  ·  parapluie, pluie  ·  umbrella weather spring
☔ parapluie avec gouttes de pluie  ·  gouttes, météo, parapluie, parapluie avec gouttes, pluie  ·  umbrella with rain drops rainy weather spring  meteo
⛱️ parasol sur le sol  ·  météo, parapluie, parapluie au sol, parasol, plage, pluie, soleil, voyage  ·  umbrella on ground weather summer  meteo
⚡ haute tension  ·  courant, danger, éclair, électricité, nature, orage, symbole haute tension, tension, vitesse  ·  high voltage thunder weather lightning bolt fast  eclair electricite
❄️ flocon  ·  flocon de neige, froid, météo, neige  ·  snowflake winter season cold weather christmas xmas  meteo
☃️ bonhomme de neige  ·  bonhomme de neige avec flocons, flocons, neige  ·  snowman winter season cold weather christmas xmas frozen
⛄ bonhomme de neige sans neige  ·  bonhomme de neige, bonhomme de neige sans flocons, froid, neige  ·  snowman without snow winter season cold weather christmas xmas frozen without snow
☄️ comète  ·  espace, météore  ·  comet space  comete meteore
🔥 feu  ·  allumer, brûler, chaud, flamme, fournaise, incendie  ·  fire hot cook flame  bruler
💧 goutte d’eau  ·  BD, eau, froid, goutte, larme, météo, nature, pluie, sueurs froides, tristesse  ·  droplet water drip faucet spring  goutte d'eau meteo
🌊 vague  ·  eau, Kanagawa, lame, large, marée, mer, nature, océan, remous, rouleau, surf  ·  water wave sea water wave nature tsunami disaster  maree ocean
🎃 citrouille  ·  halloween, Halloween, lanterne  ·  jack o lantern halloween light pumpkin creepy fall
🎄 sapin de Noël  ·  arbre, fête, fêtes, guirlandes, Noël, Sapin de Noël  ·  christmas tree festival vacation december xmas celebration  sapin de Noel fete fetes Noel Sapin de Noel
🎆 feu d’artifice  ·  14 juillet, artifice, fête  ·  fireworks photo festival carnival congratulations  feu d'artifice fete
🎇 cierge magique  ·  14 juillet, artifice, étincelle, étincelles, fête, feu d’artifice  ·  sparkler stars night shine  etincelle etincelles fete feu d'artifice
🧨 pétard  ·  dynamite, étincelle, explosif, explosive, feu d’artifice, tnt  ·  firecracker dynamite boom explode explosion explosive  petard etincelle feu d'artifice
✨ étincelles  ·  *, étoile, étoiles, magie, nuit, nuit étoilée, scintiller  ·  sparkles stars shine shiny cool awesome good magic  etincelles etoile etoiles nuit etoilee
🎈 ballon gonflable  ·  anniversaire, ballon, ballon de baudruche, fête  ·  balloon party celebration birthday circus  fete
🎉 cotillons  ·  anniversaire, fête, super  ·  party popper party congratulations birthday magic circus celebration tada  fete
🎊 confettis  ·  anniversaire, fête  ·  confetti ball festival party birthday circus  fete
🎋 arbre à vœux  ·  arbre, fête, Japon, prières, Tanabata, vœux  ·  tanabata tree plant nature branch summer  arbre a voeux fete prieres voeux
🎍 bambou décoratif  ·  bambou, fête, japonais, plante  ·  pine decoration plant nature vegetable panda pine decoration  bambou decoratif fete
🎎 poupées japonaises  ·  festival, Japon, poupées  ·  japanese dolls japanese toy kimono  poupees japonaises poupees
🎏 koinobori  ·  carpe, fête  ·  carp streamer fish japanese koinobori carp banner  fete
🎐 carillon éolien  ·  carillon, clochette, fête, vent  ·  wind chime nature ding spring bell  carillon eolien fete
🎑 cérémonie de la lune  ·  cérémonie, lune  ·  moon viewing ceremony photo japan asia tsukimi  ceremonie de la lune ceremonie
🧧 enveloppe rouge  ·  argent, bonne chance, cadeau, hóngbāo, lai see  ·  red envelope gift  hongbao
🎀 ruban  ·  fête, nœud, ruban rose  ·  ribbon decoration pink girl bowtie  fete noeud
🎁 cadeau  ·  anniversaire, cadeau emballé, fête, Noël, nœud, surprise  ·  wrapped gift present birthday christmas xmas  cadeau emballe fete Noel noeud
🎗️ ruban de mémoire  ·  mémoire, ruban, souvenir  ·  reminder ribbon sports cause support awareness  ruban de memoire memoire
🎟️ billet d’entrée  ·  place, spectacle  ·  admission tickets sports concert entrance  billet d'entree
🎫 billet  ·  place, spectacle  ·  ticket event concert pass
🎖️ médaille militaire  ·  médaille  ·  military medal award winning army  medaille militaire medaille
🏆 trophée  ·  champion, championne, coupe, gagner, prix, victoire  ·  trophy win award contest place ftw ceremony  trophee
🏅 médaille sportive  ·  champion, championne, médaille, médaille d’or, sport, vainqueur, victoire  ·  sports medal award winning  medaille sportive medaille medaille d'or
🥇 médaille d’or  ·  1er, médaille, or, premier  ·  1st place medal award winning first  medaille d'or medaille
🥈 médaille d’argent  ·  2e, argent, deuxième, médaille  ·  2nd place medal award second  medaille d'argent deuxieme medaille
🥉 médaille de bronze  ·  3e, bronze, médaille, troisième  ·  3rd place medal award third  medaille de bronze medaille troisieme
⚽ ballon de football  ·  balle, ballon, football, sport  ·  soccer ball sports football
⚾ baseball  ·  balle, balle de baseball, sport  ·  baseball sports balls
🥎 softball  ·  balle, gant, sports  ·  softball sports balls
🏀 basket  ·  ballon, basket-ball, panier, sport  ·  basketball sports balls NBA
🏐 volley-ball  ·  ballon, jeu, match, sport, volley  ·  volleyball sports balls
🏈 football américain  ·  ballon, sport, Super Bowl  ·  american football sports balls NFL  football americain
🏉 rugby  ·  ballon, sport  ·  rugby football sports team
🎾 tennis  ·  balle, balle de tennis, sport  ·  tennis sports balls green
🥏 disque volant  ·  discoplane, disque, disque-volant, frisbee, sport, ultimate, ultime-passe  ·  flying disc sports frisbee ultimate
🎳 bowling  ·  boule, jeu, partie, quilles, sport, strike  ·  bowling sports fun play
🏏 cricket  ·  balle, balle de cricket, batte, jeu, match, sport  ·  cricket game sports
🏑 hockey sur gazon  ·  balle, crosse, hockey, sport  ·  field hockey sports
🏒 hockey sur glace  ·  crosse, hockey, palet, sport  ·  ice hockey sports
🥍 crosse  ·  balle, but, lacrosse, raquette, sport  ·  lacrosse sports ball stick
🏓 ping-pong  ·  balle, jeu, partie, raquette, sport, tennis de table  ·  ping pong sports pingpong
🏸 badminton  ·  jeu, match, raquette, sport, volant  ·  badminton sports
🥊 gant de boxe  ·  boxe, gant, sport  ·  boxing glove sports fighting
🥋 tenue d’arts martiaux  ·  arts martiaux, judo, karaté, kimono, sport, taekwondo, tenue  ·  martial arts uniform judo karate taekwondo  tenue d'arts martiaux karate
🥅 cage  ·  but, filet, sport  ·  goal net sports
⛳ drapeau de golf  ·  golf, sport, trou  ·  flag in hole sports business flag hole summer
⛸️ patin à glace  ·  glace, patin, patiner, patinoire, sport  ·  ice skate sports  patin a glace
🎣 pêche à la ligne  ·  canne à pêche, pêche, sport  ·  fishing pole food hobby summer  peche a la ligne canne a peche peche
🤿 masque de plongée  ·  apnée, masque, masque et tuba, plongée, plonger, snorkeling, tuba  ·  diving mask sport ocean  masque de plongee apnee plongee
🎽 maillot de course  ·  athlétisme, course à pied, jogging, running, sport, tee-shirt de course  ·  running shirt play pageant  athletisme course a pied
🎿 ski  ·  neige, sport  ·  skis sports winter cold snow
🛷 luge  ·  glisser, neige, traîneau  ·  sled sleigh luge toboggan  traineau
🥌 pierre de curling  ·  curling, granit, jeu, match, partie, pierre, sport  ·  curling stone sports
🎯 dans le mille  ·  cible, fléchettes, jeu  ·  direct hit game play bar target bullseye  flechettes
🪀 yoyo  ·  descendre, jouet, monter, osciller  ·  yo yo toy
🪁 cerf-volant  ·  planer, voler  ·  kite wind fly
🎱 boule de billard  ·  8, billard, boule magique, huit, jeu, pool  ·  pool 8 ball pool hobby game luck magic
🔮 boule de cristal  ·  avenir, cristal, magie, voyant, voyante  ·  crystal ball disco party magic circus fortune teller
🧿 mauvais œil  ·  amulette, l’oeil bleu, mauvais oeil, nazar, nazar boncuk, nazarboncuk, œil bleu, perle, superstition, talisman, talisman turc  ·  nazar amulet bead charm  mauvais oeil l'oeil bleu oeil bleu
🎮 jeu vidéo  ·  joystick, manette, playstation, xbox  ·  video game play console PS4 controller  jeu video
🕹️ manette de jeu  ·  jeu, jeu vidéo, joystick  ·  joystick game play  jeu video
🎰 machine à sous  ·  casino, jeu  ·  slot machine bet gamble vegas fruit machine luck casino  machine a sous
🎲 dés  ·  dé, hasard, jeu  ·  game die dice random tabletop play luck  des de
🧩 pièce de puzzle  ·  assemblage, énigme, indice, interloqué, pièce manquante, puzzle  ·  puzzle piece interlocking puzzle piece  piece de puzzle enigme interloque piece manquante
🧸 ours en peluche  ·  jeu, jouet, nounours, ours, peluche  ·  teddy bear plush stuffed
♠️ pique  ·  carte, couleur, jeu  ·  spade suit poker cards suits magic
♥️ cœur cartes  ·  cartes à jouer, cœur, couleur, jeu, rouge  ·  heart suit poker cards magic suits  coeur cartes cartes a jouer coeur
♦️ carreau  ·  carreaux, carte, couleur, jeu  ·  diamond suit poker cards magic suits
♣️ trèfle cartes  ·  cartes à jouer, couleur, jeu, noir, trèfle  ·  club suit poker cards magic suits  trefle cartes cartes a jouer trefle
♟️ pion d’échec  ·  duper, échec, sacrifiable  ·  chess pawn expendable  pion d'echec echec
🃏 carte Joker  ·  cartes à jouer, jeu, Joker  ·  joker poker cards game play magic  cartes a jouer
🀄 dragon rouge mahjong  ·  jeu, mah-jong, mahjong, rouge  ·  mahjong red dragon game play chinese kanji
🎴 jeu des fleurs  ·  carte, carte à jouer, fleur, fleurs, japonais, jeu  ·  flower playing cards game sunset red  carte a jouer
🎭 spectacle vivant  ·  acteur, actrice, art, masque, spectacle, théâtre  ·  performing arts acting theater drama  theatre
🖼️ cadre avec image  ·  art, image, musée, peinture, tableau, tableau encadré  ·  framed picture photography  musee tableau encadre
🎨 palette de peinture  ·  art, artiste, couleurs, musée de peinture, peindre, peintre, peinture  ·  artist palette design paint draw colors  musee de peinture
🧵 bobine de fil  ·  aiguille, bobine, coudre, couture, ficelle, fil  ·  thread needle sewing spool string
🧶 fil  ·  boule, crochet, laine, pelote, tricot  ·  yarn ball crochet knit
👓 lunettes de vue  ·  accessoire, lunettes, œil, vêtements, yeux  ·  glasses fashion accessories eyesight nerdy dork geek  oeil vetements
🕶️ lunettes de soleil  ·  lunettes, lunettes noires, soleil  ·  sunglasses face cool accessories
🥽 lunettes  ·  lunettes de chimiste, lunettes de labo, lunettes de piscine, lunettes de protection, lunettes de soudage, lunettes de soudure, masque, natation, protection des yeux, soudage  ·  goggles eyes protection safety
🥼 blouse blanche  ·  blouse, docteur, expérience, expérimentation, labo, laboratoire, manteau blanc, médecin, scientifique, vêtements  ·  lab coat doctor experiment scientist chemist  experience experimentation medecin vetements
🦺 gilet de sécurité  ·  chantier, fluo, gilet jaune, gilet orange, sécurité, sûreté, visibilité  ·  safety vest protection  gilet de securite securite surete visibilite
👔 cravate  ·  chemise, travail, vêtements  ·  necktie shirt suitup formal fashion cloth business  vetements
👕 T-shirt  ·  bleu, chemise, courses, décontracté, polo, shopping, tee-shirt, vêtements, week-end  ·  t shirt fashion cloth casual shirt tee  decontracte vetements
👖 jean  ·  bleu, courses, denim, pantalon, shopping, vêtements, week-end  ·  jeans fashion shopping  vetements
🧣 foulard  ·  cou, écharpe, froid, glagla, vêtements  ·  scarf neck winter clothes  echarpe vetements
🧤 gants  ·  gant, main, vêtements  ·  gloves hands winter clothes  vetements
🧥 manteau  ·  froid, glagla, veste, vêtements  ·  coat jacket  vetements
🧦 chaussettes  ·  pieds, vêtements  ·  socks stockings clothes  vetements
👗 robe  ·  courses, élégante, jolie, shopping, vêtements  ·  dress clothes fashion shopping  elegante vetements
👘 kimono  ·  vêtements  ·  kimono dress fashion women female japanese  vetements
🥻 sari  ·  inde, mode, robe, traditionnel, vêtement  ·  sari dress  vetement
🩱 maillot de bain une pièce  ·  maillot, maillot de bain, maillot une pièce  ·  one piece swimsuit fashion  maillot de bain une piece maillot une piece
🩲 slip  ·  maillot de bain, slip de bain, sous-vêtement, une pièce  ·  briefs clothing  sous-vetement une piece
🩳 short  ·  baignade, caleçon, maillot de bain, piscine, plage, short de bain, sous-vêtement  ·  shorts clothing  calecon sous-vetement
👙 bikini  ·  maillot de bain, nager, piscine, plage, vêtements  ·  bikini swimming female woman girl fashion beach summer  vetements
👚 vêtements de femme  ·  chemise, chemisier, courses, femme, shopping, vêtements  ·  woman s clothes fashion shopping bags female  vetements de femme vetements
👛 porte-monnaie  ·  accessoire, courses, monnaie, sac à main, shopping, vêtements  ·  purse fashion accessories money sales shopping  sac a main vetements
👜 sac à main  ·  accessoire, courses, sac, shopping, vêtements  ·  handbag fashion accessory accessories shopping  sac a main vetements
👝 pochette  ·  accessoire, sac, sac à main, trousse, vêtements  ·  clutch bag bag accessories shopping  sac a main vetements
🛍️ sacs de shopping  ·  achats, courses, sac, sacs, shopping  ·  shopping bags mall buy purchase
🎒 cartable  ·  école, sac, sac à dos  ·  backpack student education bag backpack  ecole sac a dos
👞 chaussure d’homme  ·  accessoire, chaussure, coup de pied, courses, homme, marron, pied, shopping, vêtements  ·  man s shoe fashion male  chaussure d'homme vetements
👟 chaussure de sport  ·  accessoire, athlétisme, basket, chaussure, coup de pied, courir, courses, shopping, tennis, vêtements, vite  ·  running shoe shoes sports sneakers  athletisme vetements
🥾 chaussure de randonnée  ·  camping, chaussure de marche, chaussures de chantier, chaussures de montagne, chaussures de sécurité, chaussures marron, marche, rando, randonnée, timberland, vêtements  ·  hiking boot backpacking camping hiking  chaussure de randonnee chaussures de securite randonnee vetements
🥿 chaussure plate  ·  ballerine, chaussure sans lacets, chaussures plates, mule, vêtements  ·  flat shoe ballet slip-on slipper  vetements
👠 chaussure à talon haut  ·  accessoire, chaussure, chaussure à talon, chaussure de femme, courses, mode, shopping, stilletto, talon aiguille, talon haut, vêtements  ·  high heeled shoe fashion shoes female pumps stiletto  chaussure a talon haut chaussure a talon vetements
👡 sandale de femme  ·  chaussure, chaussure à talon, chaussure de femme, femme, sandale, talon haut, vêtements  ·  woman s sandal shoes fashion flip flops  chaussure a talon vetements
🩰 chaussons de danse  ·  ballerines, ballet, chaussures, classique, danse  ·  ballet shoes dance
👢 botte de femme  ·  accessoire, botte, chaussure, courses, femme, shopping, vêtements  ·  woman s boot shoes fashion  vetements
👑 couronne  ·  accessoire, famille royale, monarchie, monarque, reine, roi, royauté, succès, vêtements  ·  crown king kod leader royalty lord  royaute succes vetements
👒 chapeau de femme  ·  chapeau, femme, vêtements  ·  woman s hat fashion accessories female lady spring  vetements
🎩 haut de forme  ·  accessoire, chapeau, élégant, haut-de-forme, magie, vêtements  ·  top hat magic gentleman classy circus  elegant vetements
🎓 toque universitaire  ·  accessoire, chapeau, diplôme, étudiant, université, vêtements  ·  graduation cap school college degree university graduation cap hat legal learn education  diplome etudiant universite vetements
🧢 casquette américaine  ·  baseball cap, casquette, casquette de baseball, chapeau, vêtements  ·  billed cap cap baseball  casquette americaine vetements
⛑️ casque de secouriste  ·  assistance, casque, casque croix blanche, casque de sauveteur, croix, secours  ·  rescue worker s helmet construction build
📿 chapelet  ·  accessoire, collier, perles, prière, religion, vêtements  ·  prayer beads dhikr religious  priere vetements
💄 rouge à lèvres  ·  cosmétiques, maquillage, rendez-vous  ·  lipstick female girl fashion woman  rouge a levres cosmetiques
💍 bague  ·  alliance, amour, brillant, diamant, étincelant, fiançailles, mariage, solitaire  ·  ring wedding propose marriage valentines diamond fashion jewelry gem engagement  etincelant fiancailles
💎 pierre précieuse  ·  argent, bijou, diamant, fiançailles, joyau, mariage, romantique  ·  gem stone blue ruby diamond jewelry  pierre precieuse fiancailles
🔇 muet  ·  chut, enceinte, haut-parleur barré, haut-parleur d’enceinte, silence, son, sourdine  ·  muted speaker sound volume silence quiet  haut-parleur barre haut-parleur d'enceinte
🔈 volume des enceintes faible  ·  enceinte, haut-parleur, haut-parleur d’enceinte, son, volume bas  ·  speaker low volume sound volume silence broadcast  haut-parleur d'enceinte
🔉 volume des enceintes moyen  ·  enceinte, haut-parleur, haut-parleur d’enceinte, son, volume moyen  ·  speaker medium volume volume speaker broadcast  haut-parleur d'enceinte
🔊 volume des enceintes élevé  ·  enceinte, fort, haut-parleur, haut-parleur d’enceinte, musique, son, volume élevé  ·  speaker high volume volume noise noisy speaker broadcast  volume des enceintes eleve haut-parleur d'enceinte volume eleve
📢 haut-parleur  ·  communication, fort, mégaphone, message, son  ·  loudspeaker volume sound  megaphone
📣 porte-voix  ·  encourager, hourra, manifestation, mégaphone  ·  megaphone sound speaker volume  megaphone
📯 cor postal  ·  cor de facteur, facteur, poste  ·  postal horn instrument music
🔔 cloche  ·  clochette, sonner  ·  bell sound notification christmas xmas chime
🔕 alarme désactivée  ·  barrée, cloche, silence  ·  bell with slash sound volume mute quiet silent  alarme desactivee barree
🎼 partition  ·  musique, note  ·  musical score treble clef compose
🎵 note de musique  ·  musique, note  ·  musical note score tone sound
🎶 notes de musique  ·  musique, note, notes, partition  ·  musical notes music score
🎙️ micro de studio  ·  chant, enregistrement, micro, microphone, musique, studio  ·  studio microphone sing recording artist talkshow
🎚️ curseur de niveau  ·  curseur, musique, niveau  ·  level slider scale
🎛️ boutons de réglage  ·  boutons, boutons de commande, boutons de contrôle, commande, musique, réglages  ·  control knobs dial  boutons de reglage boutons de controle reglages
🎤 micro  ·  chanter, karaoke, karaoké, microphone, musique  ·  microphone sound music PA sing talkshow  karaoke
🎧 casque  ·  écouteur, écouteurs, musique, son  ·  headphone music score gadgets  ecouteur ecouteurs
📻 radio  ·  actualités, communication, loisirs, musique, vidéo  ·  radio communication music podcast program  actualites video
🎷 saxophone  ·  instrument, musique  ·  saxophone music instrument jazz blues
🎸 guitare  ·  guitare électrique, instrument, musique  ·  guitar music instrument  guitare electrique
🎹 piano  ·  clavier, instrument, musique, touches  ·  musical keyboard piano instrument compose
🎺 trompette  ·  instrument, musique  ·  trumpet music brass
🎻 violon  ·  instrument, musique  ·  violin music instrument orchestra symphony
🪕 banjo  ·  cordes, instrument, instrument à cordes, musique  ·  banjo music instructment  instrument a cordes
🥁 batterie  ·  baguette, baguettes, musique, tambour  ·  drum music instrument drumsticks snare
📱 téléphone portable  ·  communication, smartphone, téléphone  ·  mobile phone technology apple gadgets dial  telephone portable telephone
📲 appel entrant  ·  appel, communication, recevoir un appel, smartphone, téléphone portable avec une flèche  ·  mobile phone with arrow iphone incoming  telephone portable avec une fleche
☎️ téléphone  ·  téléphone rouge  ·  telephone technology communication dial telephone  telephone telephone rouge
📞 combiné téléphonique  ·  communication, téléphone  ·  telephone receiver technology communication dial  combine telephonique telephone
📟 bipeur  ·  bip, communication, pager  ·  pager bbcall oldschool 90s
📠 fax  ·  communication, télécopieur  ·  fax machine communication technology  telecopieur
🔋 pile  ·  battery power energy sustain
🔌 câble avec fiche électrique  ·  branché, électricité, prise, prise électrique  ·  electric plug charger power  cable avec fiche electrique branche electricite prise electrique
💻 ordinateur portable  ·  bureau, ordinateur, travail  ·  laptop technology laptop screen display monitor
🖥️ ordinateur de bureau  ·  moniteur, ordinateur  ·  desktop computer technology computing screen
🖨️ imprimante  ·  imprimer, ordinateur  ·  printer paper ink
⌨️ clavier  ·  informatique, ordinateur  ·  keyboard technology computer type input text
🖱️ souris d’ordinateur  ·  informatique, souris  ·  computer mouse click  souris d'ordinateur
🖲️ boule de commande  ·  informatique, ordinateur, souris à boule, trackball  ·  trackball technology trackpad  souris a boule
💽 disque d’ordinateur  ·  disque, minidisc  ·  computer disk technology record data disk 90s  disque d'ordinateur
💾 disquette  ·  disque, informatique, ordinateur  ·  floppy disk oldschool technology save 90s 80s
💿 CD  ·  blu-ray, disque, DVD  ·  optical disk technology dvd disk disc 90s
📀 DVD  ·  blu-ray, CD, disque  ·  dvd cd disk disc
🧮 abaque  ·  boulier, calcul, calculation, math, mathématiques  ·  abacus calculation  mathematiques
🎥 caméra  ·  cinéma, film, filmer, réalisateur, réalisatrice, vidéo  ·  movie camera film record  camera cinema realisateur realisatrice video
🎞️ pellicule  ·  bande, cinéma, film  ·  film frames movie  cinema
📽️ projecteur cinématographique  ·  cinéma, film, projecteur, vidéo  ·  film projector video tape record movie  projecteur cinematographique cinema video
🎬 clap  ·  action, ça tourne, film  ·  clapper board movie film record  ca tourne
📺 téléviseur  ·  petit écran, télé, télévision, TV  ·  television technology program oldschool show television  televiseur petit ecran tele television
📷 appareil photo  ·  photo, selfie, vidéo  ·  camera gadgets photography  video
📸 appareil photo avec flash  ·  appareil photo, flash  ·  camera with flash photography gadgets
📹 caméscope  ·  caméra, filmer, vidéo  ·  video camera film record  camescope camera video
📼 cassette vidéo  ·  magnétoscope, vhs, vidéocassette, vintage  ·  videocassette record video oldschool 90s 80s  cassette video magnetoscope videocassette
🔍 loupe orientée à gauche  ·  agrandir, chercher, détective, loupe, loupe gauche, recherche  ·  magnifying glass tilted left search zoom find detective  loupe orientee a gauche detective
🔎 loupe orientée à droite  ·  agrandir, chercher, détective, loupe, loupe droite, recherche  ·  magnifying glass tilted right search zoom find detective  loupe orientee a droite detective
🕯️ bougie  ·  chandelle, lumière  ·  candle fire wax  lumiere
💡 ampoule  ·  allumer, bande dessinée, BD, dessin, idée, lampe, lumière  ·  light bulb light electricity idea  bande dessinee idee lumiere
🔦 torche  ·  lampe électrique, lampe torche, lumière, outil  ·  flashlight dark camping sight night  lampe electrique lumiere
🏮 lampion rouge  ·  japonais, lanterne, lumière, restaurant, rouge  ·  red paper lantern light paper halloween spooky  lumiere
🪔 diya  ·  ārtī, Diwali, fête inde, huile, lampe, lampe à beurre, lampe inde  ·  diya lamp lighting  arti fete inde lampe a beurre
📔 carnet avec couverture  ·  cahier, carnet, école, écrire, livre  ·  notebook with decorative cover classroom notes record paper study  ecole ecrire
📕 livre fermé  ·  apprendre, école, enseignement, lire, littérature, livre, livre rouge, manuel scolaire, savoir  ·  closed book read library knowledge textbook learn  livre ferme ecole litterature
📖 livre ouvert  ·  apprendre, bibliothèque, école, enseignement, étudier, lecture, lire, littérature, manuel scolaire, roman, savoir  ·  open book book read library knowledge literature learn study  bibliotheque ecole etudier litterature
📗 livre vert  ·  apprendre, bibliothèque, école, enseignement, étudier, lecture, lire, littérature, livre, manuel scolaire, savoir  ·  green book read library knowledge study  bibliotheque ecole etudier litterature
📘 livre bleu  ·  apprendre, école, éducation, lecture, lire, littérature, livre, manuel scolaire, roman  ·  blue book read library knowledge learn study  ecole education litterature
📙 livre orange  ·  apprendre, école, éducation, lecture, lire, littérature, livre, manuel scolaire, roman  ·  orange book read library knowledge textbook study  ecole education litterature
📚 livres  ·  apprendre, bibliothèque, école, enseignement, étudier, lecture, lire, littérature, manuels scolaires, roman, savoir  ·  books literature library study  bibliotheque ecole etudier litterature
📓 carnet  ·  cahier, écrire  ·  notebook stationery record notes paper study  ecrire
📒 carnet de compte  ·  cahier, classeur, grand livre  ·  ledger notes paper
📃 page enroulée  ·  document, page  ·  page with curl documents office paper  page enroulee
📜 parchemin  ·  papier  ·  scroll documents ancient history paper
📄 page  ·  document  ·  page facing up documents office paper information
📰 journal  ·  actualités, communication, gros titres, presse, une  ·  newspaper press headline  actualites
🗞️ journal roulé  ·  actualités, journal, presse  ·  rolled up newspaper press headline  journal roule actualites
📑 signets  ·  marque, marqueur, onglets, signet  ·  bookmark tabs favorite save order tidy
🔖 marque-page  ·  marqueur, signet  ·  bookmark favorite label save
🏷️ étiquette  ·  label sale tag  etiquette
💰 sac plein d’argent  ·  argent, avare, banque, dollar, parier, payer, sac, sac d’argent  ·  money bag dollar payment coins sale  sac plein d'argent sac d'argent
💴 billet en yens  ·  argent, billet, billet de banque, payer, yens  ·  yen banknote money sales japanese dollar currency
💵 billet en dollars  ·  argent, billet, billet de banque, dollar, payer  ·  dollar banknote money sales bill currency
💶 billet en euros  ·  argent, billet, billet de banque, euros, payer  ·  euro banknote money sales dollar currency
💷 billet en livres  ·  argent, billet, billet de banque, livres, payer  ·  pound banknote british sterling money sales bills uk england currency
💸 billet avec des ailes  ·  ailes, argent, billet, billet de banque, dollars, payer  ·  money with wings dollar bills payment sale
💳 carte bancaire  ·  argent, bancaire, banque, carte, carte de crédit, payer  ·  credit card money sales dollar bill payment shopping  carte de credit
🧾 reçu  ·  compta, comptabilité, comptable, facture, faire les comptes, justificatif, preuve, ticket de caisse  ·  receipt accounting expenses  recu comptabilite
💹 courbe avec yen en hausse  ·  banque, croissance, devise, graphique, hausse, marché, monnaie, tendance, yen  ·  chart increasing with yen green-square graph presentation stats  marche
💱 conversion de devise  ·  argent, banque, change, conversion, devise  ·  currency exchange money sales dollar travel
💲 symbole dollar  ·  argent, devise, dollar, espèces, payer  ·  heavy dollar sign money sales payment currency buck  especes
✉️ enveloppe  ·  courrier électronique, e-mail, lettre, message  ·  envelope letter postal inbox communication  courrier electronique
📧 e-mail  ·  courriel, courrier électronique, lettre, message  ·  e mail communication inbox  courrier electronique
📨 message reçu  ·  courriel, courrier, courrier électronique, e-mail, enveloppe, envoyer, lettre, message, message électronique, recevoir  ·  incoming envelope email inbox  message recu courrier electronique message electronique
📩 enveloppe avec flèche  ·  communication, courriel, courrier électronique, e-mail, enveloppe, envoi, envoyer, flèche, message, message électronique, message envoyé  ·  envelope with arrow email communication  enveloppe avec fleche courrier electronique fleche message electronique message envoye
📤 boîte d’envoi  ·  courriel, courrier électronique, e-mail, envoyer, flèche, lettre, message, message électronique  ·  outbox tray inbox email  boite d'envoi courrier electronique fleche message electronique
📥 boîte de réception  ·  courriel, courrier électronique, e-mail, flèche, lettre, message, message électronique, recevoir  ·  inbox tray email documents  boite de reception courrier electronique fleche message electronique
📦 colis  ·  boîte, livraison, paquet  ·  package mail gift cardboard box moving  boite
📫 boîte aux lettres fermée drapeau levé  ·  boîte aux lettres, courrier  ·  closed mailbox with raised flag email inbox communication  boite aux lettres fermee drapeau leve boite aux lettres
📪 boîte aux lettres fermée drapeau baissé  ·  boîte aux lettres, courrier  ·  closed mailbox with lowered flag email communication inbox  boite aux lettres fermee drapeau baisse boite aux lettres
📬 boîte aux lettres ouverte drapeau levé  ·  boîte aux lettres, courrier  ·  open mailbox with raised flag email inbox communication  boite aux lettres ouverte drapeau leve boite aux lettres
📭 boîte aux lettres ouverte drapeau baissé  ·  boîte aux lettres, courrier  ·  open mailbox with lowered flag email inbox  boite aux lettres ouverte drapeau baisse boite aux lettres
📮 boîte aux lettres  ·  courrier, poste  ·  postbox email letter envelope  boite aux lettres
🗳️ urne électorale  ·  a voté, bulletin de vote, urne, urne électorale avec un bulletin, voter  ·  ballot box with ballot election vote  urne electorale a vote urne electorale avec un bulletin
✏️ crayon  ·  crayon à papier, gomme, mine  ·  pencil stationery write paper writing school study  crayon a papier
✒️ stylo plume noir  ·  écrire, stylo  ·  black nib pen stationery writing write  ecrire
🖋️ stylo plume  ·  écrire, stylo  ·  fountain pen stationery writing write  ecrire
🖊️ stylo  ·  écrire, stylo bille, stylo-bille  ·  pen stationery writing write  ecrire
🖌️ pinceau  ·  peinture  ·  paintbrush drawing creativity art
🖍️ crayon pastel  ·  pastel, rouge  ·  crayon drawing creativity
📝 mémo  ·  bloc-notes, crayon, écrire  ·  memo write documents stationery pencil paper writing legal exam quiz test study compose  memo ecrire
💼 porte-documents  ·  accessoire, bureau, cartable  ·  briefcase business documents work law legal job career
📁 dossier  ·  fichier, répertoire  ·  file directory documents business office  repertoire
📂 dossier ouvert  ·  dossier, ouvrir, ouvrir le dossier, répertoire  ·  open file directory documents load  repertoire
🗂️ intercalaires  ·  classement, classeur, index, intercalaire  ·  card index dividers organizing business stationery
📅 calendrier  ·  date  ·  calendar calendar schedule
📆 éphéméride  ·  agenda, calendrier, date, planning  ·  tear off calendar schedule date planning  ephemeride
🗒️ bloc-notes à spirale  ·  bloc-notes à spirales, cahier, notes  ·  spiral notepad memo stationery  bloc-notes a spirale bloc-notes a spirales
🗓️ calendrier à spirale  ·  bloc-notes, calendrier, calendrier à spirales  ·  spiral calendar date schedule planning  calendrier a spirale calendrier a spirales
📇 carnet d’adresses  ·  carte, fiche, index, rolodex, vintage  ·  card index business stationery  carnet d'adresses
📈 graphique en hausse  ·  croissance, données, graphique, hausse, haut, tendance  ·  chart increasing graph presentation stats recovery business economics money sales good success  donnees
📉 graphique en baisse  ·  baisse, bas, chute, données, graphique, négatif, tendance  ·  chart decreasing graph presentation stats recession business economics money sales bad failure  donnees negatif
📊 graphiques à barres  ·  données, graphique  ·  bar chart graph presentation stats  graphiques a barres donnees
📋 porte-bloc  ·  fournitures, liste, presse-papiers  ·  clipboard stationery documents
📌 punaise  ·  fournitures  ·  pushpin stationery mark here
📍 épingle  ·  carte, emplacement, fournitures, punaise ronde  ·  round pushpin stationery location map here  epingle
📎 trombone  ·  fournitures  ·  paperclip documents stationery
🖇️ trombones  ·  fournitures  ·  linked paperclips documents stationery
📏 règle  ·  fournitures, mathématiques, règle plate  ·  straight ruler stationery calculate length math school drawing architect sketch  regle mathematiques regle plate
📐 équerre  ·  fournitures, mathématiques  ·  triangular ruler stationery math architect sketch  equerre mathematiques
✂️ ciseaux  ·  couper, découper, fournitures, papier  ·  scissors stationery cut  decouper
🗃️ boîte à dossiers  ·  classeur, dossier  ·  card file box business stationery  boite a dossiers
🗄️ meuble à dossiers  ·  classement, classer, classeur, dossier, meuble  ·  file cabinet filing organizing  meuble a dossiers
🗑️ corbeille à papiers  ·  corbeille, poubelle  ·  wastebasket bin trash rubbish garbage toss  corbeille a papiers
🔒 cadenas fermé  ·  cadenas, privé, verrouillé, verrouiller  ·  locked security password padlock  cadenas ferme prive verrouille
🔓 cadenas ouvert  ·  cadenas, déverrouiller, ouvert, ouvrir  ·  unlocked privacy security  deverrouiller
🔏 cadenas fermé avec stylo  ·  cadenas avec un stylo plume, confidentiel, privé, stylo plume, verrouillé  ·  locked with pen security secret  cadenas ferme avec stylo prive verrouille
🔐 cadenas fermé avec clé  ·  cadenas, cadenas avec une clé, clé, fermé, privé, sécurisé, verrouillé  ·  locked with key security privacy  cadenas ferme avec cle cadenas avec une cle cle ferme prive securise verrouille
🔑 clé  ·  mot de passe, ouvrir, serrure  ·  key lock door password  cle
🗝️ clé ancienne  ·  clé, fermer, indice, serrure, verrouiller  ·  old key lock door password  cle ancienne cle
🔨 marteau  ·  outil, réparer, travaux  ·  hammer tools build create  reparer
🪓 hache  ·  bois, bûcheron, fendre, hachette  ·  axe tool chop cut  bucheron
⛏️ pioche  ·  mine, outil  ·  pick tools dig
⚒️ marteau et pioche  ·  burin, marteau, marteau et burin, outil, outils, pioche  ·  hammer and pick tools build create
🛠️ marteau et clé à molette  ·  clé, clé à molette, marteau, outil, outils  ·  hammer and wrench tools build create  marteau et cle a molette cle cle a molette
🗡️ dague  ·  arme, couteau, poignard  ·  dagger weapon
⚔️ épées croisées  ·  arme, armes, croisées, épées  ·  crossed swords weapon  epees croisees croisees epees
🔫 pistolet à eau  ·  arme, arme à feu, flingue, pistolet, revolver  ·  pistol violence weapon pistol revolver  pistolet a eau arme a feu
🏹 arc et flèche  ·  arc, archer, astrologie, flèche, horoscope, Sagittaire, sport, tir à l’arc, zodiaque  ·  bow and arrow sports  arc et fleche fleche tir a l'arc
🛡️ bouclier  ·  arme  ·  shield protection security
🔧 clé à molette  ·  clé, outil, travaux  ·  wrench tools diy ikea fix maintainer  cle a molette cle
🔩 vis et écrou  ·  boulon, écrou, outil, travaux, vis  ·  nut and bolt handy tools fix  vis et ecrou ecrou
⚙️ roue dentée  ·  engrenage, outil  ·  gear cog  roue dentee
🗜️ serre-joint  ·  compresser, comprimer, outil, serre-joints  ·  clamp tool
⚖️ balance à poids  ·  astrologie, balance, horoscope, justice, poids, zodiaque  ·  balance scale law fairness weight  balance a poids
🦯 canne blanche  ·  accessibilité, aveugle, déficient visuel, malvoyant  ·  probing cane accessibility  accessibilite deficient visuel
🔗 chaînons  ·  chaîne, maillons, mousqueton  ·  link rings url  chainons chaine
⛓️ chaînes  ·  chaîne  ·  chains lock arrest  chaines chaine
🧰 boîte à outils  ·  caisse à outils, coffre, mécanique, mécano, outil, outils  ·  toolbox tools diy fix maintainer mechanic  boite a outils caisse a outils mecanique mecano
🧲 aimant  ·  aimanter, attirer, attraction, fer à cheval, magnet, magnétique, positif négatif  ·  magnet attraction magnetic  fer a cheval magnetique positif negatif
⚗️ alambic  ·  chimie, outil  ·  alembic distilling science experiment chemistry
🧪 tube à essai  ·  chimie, chimiste, expérience, expérimentation, labo, laboratoire, réaction, science, sciences  ·  test tube chemistry experiment lab science  tube a essai experience experimentation reaction
🧫 boîte de pétri  ·  bactérie, bactériologie, biologie, biologiste, boîte de petri, culture, labo, laboratoire, micro-organismes, microbiologie, science  ·  petri dish bacteria biology culture lab  boite de petri bacterie bacteriologie
🧬 adn  ·  biologie, biologiste, évolution, gène, génétique, science, vie  ·  dna biologist genetics life  evolution gene genetique
🔬 microscope  ·  expérience, laboratoire, outil, science  ·  microscope laboratory experiment zoomin science study  experience
🔭 télescope  ·  astronomie, espace, outil, planètes, science  ·  telescope stars space zoom science astronomy  telescope planetes
📡 antenne satellite  ·  antenne, antenne parabolique, parabole, satellite, science  ·  satellite antenna communication future radio space
💉 seringue  ·  aiguille, docteur, malade, médecine, piqûre, vaccin, vaccination  ·  syringe health hospital drugs blood medicine needle doctor nurse  medecine piqure
🩸 goutte de sang  ·  don du sang, médecine, menstruation, menstruations, règles, sang  ·  drop of blood period hurt harm wound  medecine regles
💊 pilule  ·  docteur, gélule, malade, médecine, médicament, vitamines  ·  pill health medicine doctor pharmacy drug  gelule medecine medicament
🩹 sparadrap  ·  bandage, bobo, médecine, pansement, premiers secours  ·  adhesive bandage heal  medecine
🩺 stéthoscope  ·  cœur, diagnostic, docteur, médecin, médecine, poumons  ·  stethoscope health  stethoscope coeur medecin medecine
🚪 porte  ·  placard, porte d’entrée  ·  door house entry exit  porte d'entree
🛏️ lit  ·  dormir, hôtel  ·  bed sleep rest  hotel
🛋️ canapé et lampe  ·  canapé, canapé avec une lampe, lampe  ·  couch and lamp read chill  canape et lampe canape canape avec une lampe
🪑 chaise  ·  assis, siège  ·  chair sit furniture  siege
🚽 toilettes  ·  cabinets, WC  ·  toilet restroom wc washroom bathroom potty
🚿 douche  ·  eau, pommeau de douche  ·  shower clean water bathroom
🛁 baignoire  ·  bain, mousse  ·  bathtub clean shower bathroom
🪒 rasoir  ·  coupant, lame, raser, tranchant  ·  razor cut
🧴 bouteille de lotion  ·  après-shampoing, crème hydratante, crème pour le corps, crème solaire, flacon, hydratant, lotion, shampoing, shampooing  ·  lotion bottle moisturizer sunscreen  apres-shampoing creme hydratante creme pour le corps creme solaire
🧷 épingle de sûreté  ·  couche, épingle à nourrice, épingle de nourrice, imperdable, lange, punk rock  ·  safety pin diaper  epingle de surete epingle a nourrice epingle de nourrice
🧹 balai  ·  balais, balayage, ménage, nettoie, nettoyage, nettoyé, nettoyer, sorcière  ·  broom cleaning sweeping witch  menage nettoye sorciere
🧺 panier  ·  agriculture, cueillette, lessive, linge, pique-nique  ·  basket laundry
🧻 rouleau de papier  ·  essuie-tout, papier hygiénique, papier toilette, rouleau de pq  ·  roll of paper roll  papier hygienique
🧼 savon  ·  bain, bulles, lavage, laver, me lave, me laver, mousse, pain de savon, porte-savon, se lave, se laver  ·  soap bar bathing cleaning lather
🧽 éponge  ·  absorbante, absorbe, laver, nettoyage, nettoyer, poreuse, savonner  ·  sponge absorbing cleaning porous  eponge
🧯 extincteur  ·  chaud, éteindre, feu, fire, incendie  ·  fire extinguisher quench  eteindre
🛒 chariot  ·  caddie, courses, panier, shopping, supermarché  ·  shopping cart trolley  supermarche
🚬 cigarette  ·  cigarette allumée, fumer, fumeur, signe Fumeur  ·  cigarette kills tobacco cigarette joint smoke  cigarette allumee
⚰️ cercueil  ·  enterrement, mort, obsèques, vampire  ·  coffin vampire dead die death rip graveyard cemetery casket funeral box  obseques
⚱️ urne funéraire  ·  cendres, mort, obsèques, urne  ·  funeral urn dead die death rip ashes  urne funeraire obseques
🗿 moai  ·  île de Pâques, moaï, monolithe, statue, voyage  ·  moai rock easter island moai  ile de Paques moai
🏧 distributeur de billets  ·  argent, banque, dab, distributeur, distributeur automatiques de billets, guichet automatique, retrait  ·  atm sign money sales cash blue-square payment bank
🚮 icône Poubelle  ·  corbeille, déchets, jeter, poubelle  ·  litter in bin sign blue-square sign human info  icone Poubelle dechets
🚰 eau potable  ·  eau, eau du robinet, robinet  ·  potable water blue-square liquid restroom cleaning faucet
♿ symbole Accès handicapés  ·  accès, accès handicapés, fauteuil roulant, mobilité réduite  ·  wheelchair symbol blue-square disabled accessibility  symbole Acces handicapes acces acces handicapes mobilite reduite
🚹 symbole Toilettes hommes  ·  homme, symbole Homme, toilettes, WC  ·  men s room toilet restroom wc blue-square gender male
🚺 symbole Toilettes femmes  ·  femme, symbole Femme, toilettes, WC  ·  women s room purple-square woman female toilet loo restroom gender
🚻 panneau Toilettes  ·  toilettes, WC  ·  restroom blue-square toilet refresh wc gender
🚼 symbole Bébé  ·  bébé, espace de change  ·  baby symbol orange-square child  symbole Bebe bebe
🚾 WC  ·  toilettes  ·  water closet toilet restroom blue-square
🛂 contrôle des passeports  ·  contrôle, passeport  ·  passport control custom blue-square  controle des passeports controle
🛃 douane  ·  douanes  ·  customs passport border blue-square
🛄 retrait des bagages  ·  aéroport, arrivée, avion, bagages, valise, voyage  ·  baggage claim blue-square airport transport  aeroport arrivee
🛅 consigne  ·  bagages, casier, clé, valise  ·  left luggage blue-square travel  cle
⚠️ symbole d’avertissement  ·  attention, avertissement  ·  warning exclamation wip alert error problem issue  symbole d'avertissement
🚸 traversée d’enfants  ·  circulation, école, enfants, piétons  ·  children crossing school warning danger sign driving yellow-diamond  traversee d'enfants ecole pietons
⛔ sens interdit  ·  circulation, entrée interdite, interdiction, interdit, non, panneau  ·  no entry limit security privacy bad denied stop circle  entree interdite
🚫 symbole d’interdiction  ·  entrée interdite, interdiction, interdit  ·  prohibited forbid stop limit denied disallow circle  symbole d'interdiction entree interdite
🚳 vélos interdits  ·  bicyclette, interdiction, interdit, vélo  ·  no bicycles cyclist prohibited circle  velos interdits velo
🚭 interdiction de fumer  ·  cigarette barrée, fumer, interdiction, interdit, interdit de fumer  ·  no smoking cigarette blue-square smell smoke  cigarette barree
🚯 dépôt d’ordures interdit  ·  déchets, interdiction, interdit, ne pas jeter  ·  no littering trash bin garbage circle  depot d'ordures interdit dechets
🚱 eau non potable  ·  eau, imbuvable, interdiction, interdit, ne pas boire  ·  non potable water drink faucet tap circle
🚷 interdit aux piétons  ·  interdiction, interdit  ·  no pedestrians rules crossing walking circle  interdit aux pietons
📵 téléphones portables interdits  ·  interdiction, interdit, portable, téléphone  ·  no mobile phones iphone mute circle  telephones portables interdits telephone
🔞 18 ans et plus  ·  dix-huit, interdiction, interdit, interdit aux mineurs, interdit aux moins de dix-huit ans, limite d’âge, majorité, mineur  ·  no one under eighteen 18 drink pub night minor circle  limite d'age majorite
☢️ radioactif  ·  radioactivité, symbole  ·  radioactive nuclear danger  radioactivite
☣️ danger biologique  ·  danger, symbole  ·  biohazard danger
⬆️ flèche haut  ·  direction, flèche, nord, sens  ·  up arrow blue-square continue top direction  fleche haut fleche
↗️ flèche haut droite  ·  direction, flèche, nord-est, sens  ·  up right arrow blue-square point direction diagonal northeast  fleche haut droite fleche
➡️ flèche droite  ·  direction, droite, est, flèche, sens  ·  right arrow blue-square next  fleche droite fleche
↘️ flèche bas droite  ·  direction, flèche, sens, sud-est  ·  down right arrow blue-square direction diagonal southeast  fleche bas droite fleche
⬇️ flèche bas  ·  direction, flèche, sens, sud  ·  down arrow blue-square direction bottom  fleche bas fleche
↙️ flèche bas gauche  ·  direction, flèche, sens, sud-ouest  ·  down left arrow blue-square direction diagonal southwest  fleche bas gauche fleche
⬅️ flèche gauche  ·  direction, flèche, ouest, sens  ·  left arrow blue-square previous back  fleche gauche fleche
↖️ flèche haut gauche  ·  direction, flèche, nord-ouest, sens  ·  up left arrow blue-square point direction diagonal northwest  fleche haut gauche fleche
↕️ flèche haut bas  ·  flèche, flèche dans les deux sens  ·  up down arrow blue-square direction way vertical  fleche haut bas fleche fleche dans les deux sens
↔️ flèche gauche droite  ·  flèche  ·  left right arrow shape direction horizontal sideways  fleche gauche droite fleche
↩️ flèche courbe gauche  ·  flèche  ·  right arrow curving left back return blue-square undo enter  fleche courbe gauche fleche
↪️ flèche courbe droite  ·  flèche  ·  left arrow curving right blue-square return rotate direction  fleche courbe droite fleche
⤴️ flèche courbe haut  ·  flèche, flèche courbe vers la droite et le haut  ·  right arrow curving up blue-square direction top  fleche courbe haut fleche fleche courbe vers la droite et le haut
⤵️ flèche courbe bas  ·  bas, flèche  ·  right arrow curving down blue-square direction bottom  fleche courbe bas fleche
🔃 flèches dans le sens horaire  ·  actualiser, flèche, sens des aiguilles d’une montre, sens horaire, symbole Recharger  ·  clockwise vertical arrows sync cycle round repeat  fleches dans le sens horaire fleche sens des aiguilles d'une montre
🔄 flèches dans le sens antihoraire  ·  actualiser, flèche, flèches, retour, sens antihoraire, sens contraire des aiguilles d’une montre, sens horaire inverse, sens inverse des aiguilles d’une montre  ·  counterclockwise arrows button blue-square sync cycle  fleches dans le sens antihoraire fleche fleches sens contraire des aiguilles d'une montre sens inverse des aiguilles d'une montre
🔙 flèche Retour  ·  flèche, flèche vers la gauche, retour  ·  back arrow arrow words return  fleche Retour fleche fleche vers la gauche
🔚 flèche Fin  ·  fin, flèche, flèche vers la gauche  ·  end arrow words arrow  fleche Fin fleche fleche vers la gauche
🔛 flèche Activé  ·  activé, droite et gauche, flèche, flèche dans les deux sens  ·  on arrow arrow words  fleche Active active fleche fleche dans les deux sens
🔜 flèche Bientôt  ·  bientôt, flèche  ·  soon arrow arrow words  fleche Bientot bientot fleche
🔝 flèche En haut  ·  flèche, flèche vers le haut, haut  ·  top arrow words blue-square  fleche En haut fleche fleche vers le haut
🛐 lieu de culte  ·  culte, prier, religion  ·  place of worship religion church temple prayer
⚛️ symbole de l’atome  ·  athée, atome  ·  atom symbol science physics chemistry  symbole de l'atome athee
🕉️ om  ·  hindou, religion  ·  om hinduism buddhism sikhism jainism
✡️ étoile de David  ·  David, étoile, judaïsme, juif, Juif, juive, religion  ·  star of david judaism  etoile de David etoile judaisme
☸️ roue du Dharma  ·  bouddhisme, bouddhiste, dharma, religion, roue, roue de dharma  ·  wheel of dharma hinduism buddhism sikhism jainism
☯️ yin yang  ·  complémentaire, religion, tao, taoïsme, yang, yin  ·  yin yang balance  complementaire taoisme
✝️ croix latine  ·  chrétien, chrétienne, croix, religion  ·  latin cross christianity  chretien chretienne
☦️ croix orthodoxe  ·  chrétien, chrétienne, croix, religion  ·  orthodox cross suppedaneum religion  chretien chretienne
☪️ lune et étoile  ·  étoile, islam, lune, musulman, musulmane, ramadan, religion  ·  star and crescent islam  lune et etoile etoile
☮️ symbole de paix  ·  paix, paix et amour, peace and love  ·  peace symbol hippie
🕎 chandelier à sept branches  ·  candélabre, chandelier, Hanoucca, Hanoukka, judaïsme, juif, juive, menora, menorah, religion  ·  menorah hanukkah candles jewish  chandelier a sept branches candelabre judaisme
🔯 étoile à 6 branches  ·  chance, étoile, judaïsme, juif, juive  ·  dotted six pointed star purple-square religion jewish hexagram  etoile a 6 branches etoile judaisme
♈ bélier zodiaque  ·  astrologie, Bélier, horoscope, zodiaque  ·  aries sign purple-square zodiac astrology  belier zodiaque Belier
♉ taureau  ·  astrologie, horoscope, Taureau, zodiaque  ·  taurus purple-square sign zodiac astrology
♊ gémeaux  ·  astrologie, Gémeaux, horoscope, zodiaque  ·  gemini sign zodiac purple-square astrology  gemeaux Gemeaux
♋ cancer  ·  astrologie, Cancer, crabe, horoscope, zodiaque  ·  cancer sign zodiac purple-square astrology
♌ lion  ·  astrologie, horoscope, Lion, zodiaque  ·  leo sign purple-square zodiac astrology
♍ vierge  ·  astrologie, horoscope, Vierge, zodiaque  ·  virgo sign zodiac purple-square astrology
♎ balance  ·  astrologie, Balance, horoscope, justice, zodiaque  ·  libra sign purple-square zodiac astrology
♏ scorpion zodiaque  ·  astrologie, horoscope, Scorpion, zodiaque  ·  scorpio sign zodiac purple-square astrology scorpio
♐ sagittaire  ·  astrologie, horoscope, Sagittaire, zodiaque  ·  sagittarius sign zodiac purple-square astrology
♑ capricorne  ·  astrologie, Capricorne, chèvre, horoscope, zodiaque  ·  capricorn sign zodiac purple-square astrology  chevre
♒ verseau  ·  astrologie, eau, horoscope, Verseau, zodiaque  ·  aquarius sign purple-square zodiac astrology
♓ poissons  ·  astrologie, horoscope, Poissons, zodiaque  ·  pisces purple-square sign zodiac astrology
⛎ serpentaire  ·  ophiuchus, Ophiuchus, serpent, zodiaque  ·  ophiuchus sign purple-square constellation astrology
🔀 bouton lecture aléatoire  ·  flèche, flèches croisées, lecture aléatoire  ·  shuffle tracks button blue-square shuffle music random  bouton lecture aleatoire fleche fleches croisees lecture aleatoire
🔁 bouton répétition  ·  bouton répéter, flèche, flèches en cercle, répéter, sens des aiguilles d’une montre, sens horaire  ·  repeat button loop record  bouton repetition bouton repeter fleche fleches en cercle repeter sens des aiguilles d'une montre
🔂 bouton répétition de la piste  ·  flèche, flèches en cercle avec n°1, répéter, répéter une fois, sens des aiguilles d’une montre, sens horaire  ·  repeat single button blue-square loop  bouton repetition de la piste fleche fleches en cercle avec n°1 repeter repeter une fois sens des aiguilles d'une montre
▶️ bouton lecture  ·  droite, flèche, lecture, lire, triangle  ·  play button blue-square right direction play  fleche
⏩ bouton avance rapide  ·  avance, avance rapide, bouton, double flèche, flèche Avance rapide  ·  fast forward button blue-square play speed continue  double fleche fleche Avance rapide
⏭️ bouton piste suivante  ·  bouton suivant, double flèche, piste suivante, scène suivante, suivant, triangle  ·  next track button forward next blue-square  double fleche scene suivante
⏯️ bouton lecture/pause  ·  flèche, lecture, pause, triangle  ·  play or pause button blue-square play pause  fleche
◀️ bouton retour  ·  flèche, gauche, retour, triangle  ·  reverse button blue-square left direction  fleche
⏪ bouton retour rapide  ·  bouton, double flèche, flèche, flèche Retour rapide, retour, retour rapide  ·  fast reverse button play blue-square  double fleche fleche fleche Retour rapide
⏮️ bouton piste précédente  ·  bouton précédent, flèche, piste précédente, précédent, scène précédente, triangle  ·  last track button backward  bouton piste precedente bouton precedent fleche piste precedente precedent scene precedente
🔼 petit triangle haut  ·  bouton haut, flèche, haut  ·  upwards button blue-square triangle direction point forward top  fleche
⏫ double flèche vers le haut  ·  flèche double, flèche vers le haut, haut, rapide  ·  fast up button blue-square direction top  double fleche vers le haut fleche double fleche vers le haut
🔽 petit triangle bas  ·  bas, bouton bas, flèche  ·  downwards button blue-square direction bottom  fleche
⏬ double flèche vers le bas  ·  bas, flèche double, flèche vers le bas, rapide  ·  fast down button blue-square direction bottom  double fleche vers le bas fleche double fleche vers le bas
⏸️ bouton pause  ·  pause  ·  pause button pause blue-square
⏹️ bouton stop  ·  carré, stop  ·  stop button blue-square  carre
⏺️ bouton enregistrer  ·  cercle, enregistrement, enregistrer, point blanc  ·  record button blue-square
⏏️ bouton éjecter  ·  éjecter  ·  eject button blue-square  bouton ejecter ejecter
🎦 cinéma  ·  caméra, film  ·  cinema blue-square record film movie curtain stage theater  cinema camera
🔅 luminosité faible  ·  brillance, lumière, luminosité, soleil  ·  dim button sun afternoon warm summer  luminosite faible lumiere luminosite
🔆 luminosité élevée  ·  brillance, lumière, luminosité, soleil  ·  bright button sun light  luminosite elevee lumiere luminosite
📶 barres de réseau  ·  communication, couverture, portable, réception, réseau, téléphone  ·  antenna bars blue-square reception phone internet connection wifi bluetooth bars  barres de reseau reception reseau telephone
📳 mode vibreur  ·  communication, portable, téléphone, vibreur  ·  vibration mode orange-square phone  telephone
📴 téléphone éteint  ·  éteindre, portable, téléphone  ·  mobile phone off mute orange-square silence quiet  telephone eteint eteindre telephone
♀️ symbole de la femme  ·  femme  ·  female sign woman women lady girl
♂️ symbole de l’homme  ·  homme  ·  male sign man boy men  symbole de l'homme
⚕️ caducée  ·  docteur, Esculape, médecine, personnel  ·  medical symbol health hospital  caducee medecine
♾️ infini  ·  éternité, illimité, universel  ·  infinity forever  eternite illimite
♻️ symbole Recyclage  ·  recyclage  ·  recycling symbol arrow environment garbage trash
⚜️ fleur de lys  ·  blason, fleur de lis, reine, roi, royauté française  ·  fleur de lis decorative scout  royaute francaise
🔱 trident  ·  ancre, bateau, fourche, mer, Poséidon  ·  trident emblem weapon spear  Poseidon
📛 badge nominatif  ·  badge, nom  ·  name badge fire forbid
🔰 symbole japonais de débutant  ·  chevron, chevron jaune et vert, débutant, symbole japonais  ·  japanese symbol for beginner badge shield  symbole japonais de debutant debutant
⭕ cercle rouge  ·  0, anneau, cercle, gros cercle, o, O, rouge  ·  hollow red circle circle round
✅ bouton coché  ·  ✓, carré, coche, coche blanche, marque, OK, oui, sélection, terminé, voilà  ·  check mark button green-square ok agree vote election answer tick  bouton coche carre selection termine voila
☑️ case cochée  ·  ✓, bouton, carré, coche, OK, oui, sélection, terminé, voilà  ·  check box with check ok agree confirm black-square vote election yes tick  case cochee carre selection termine voila
✔️ coche  ·  ✓, coche noire, OK, oui, sélection, terminé, voilà  ·  check mark ok nike answer yes tick  selection termine voila
✖️ signe multiplier  ·  *, ×, annuler, croix noire, multiplication, multiplier, non, x  ·  multiplication sign math calculation
❌ croix  ·  ×, annuler, croix rouge, multiplication, multiplier, x  ·  cross mark no delete remove cancel red
❎ bouton croix  ·  ×, croix, multiplier, vert, x  ·  cross mark button x green-square no deny
➕ plus  ·  +, addition, ajouter, arithmétique, mathématiques, signe plus, signe Plus, somme  ·  plus sign math calculation addition more increase  arithmetique mathematiques
➖ moins  ·  -, −, arithmétique, mathématiques, signe moins, signe Moins, soustraction, soustraire  ·  minus sign math calculation subtract less  arithmetique mathematiques
➗ signe diviser  ·  ÷, algèbre, diviser, division, math, mathématique, mathématiques, signe  ·  division sign divide math calculation  algebre mathematique mathematiques
➰ boucle  ·  bouclette  ·  curly loop scribble draw shape squiggle
➿ double boucle  ·  boucle  ·  double curly loop tape cassette
〽️ alternance  ·  symbole  ·  part alternation mark graph presentation stats business economics bad
✳️ astérisque huit branches  ·  *, astérique, astérique huit branches, astérisque, étoile, huit  ·  eight spoked asterisk star sparkle green-square  asterisque huit branches asterique asterique huit branches asterisque etoile
✴️ étoile huit branches  ·  *, astérisque, étoile, huit  ·  eight pointed star orange-square shape polygon  etoile huit branches asterisque etoile
❇️ éclat  ·  *, briller, étinceler, étincelle, scintiller  ·  sparkle stars green-square awesome good fireworks  eclat etinceler etincelle
‼️ double point d’exclamation  ·  !, !!, exclamation, point, ponctuation, surprise  ·  double exclamation mark exclamation surprise  double point d'exclamation
⁉️ points d’exclamation et d’interrogation  ·  !, !?, ?, exclamation, interrogation, point d’exclamation et d’interrogation, ponctuation, question, surprise  ·  exclamation question mark wat punctuation surprise  points d'exclamation et d'interrogation point d'exclamation et d'interrogation
❓ point d’interrogation rouge  ·  ?, interrogation, point d’interrogation, ponctuation, question  ·  question mark doubt confused  point d'interrogation rouge point d'interrogation
❔ point d’interrogation blanc  ·  ?, interrogation, ponctuation, question  ·  white question mark doubts gray huh confused  point d'interrogation blanc
❕ point d’exclamation blanc  ·  !, exclamation, ponctuation, surprise  ·  white exclamation mark surprise punctuation gray wow warning  point d'exclamation blanc
❗ point d’exclamation rouge  ·  !, exclamation, point d’exclamation, ponctuation  ·  exclamation mark heavy exclamation mark danger surprise punctuation wow warning  point d'exclamation rouge point d'exclamation
〰️ ligne ondulée  ·  ponctuation, tiret, trait d’union ondulé, vague  ·  wavy dash draw line moustache mustache squiggle scribble  ligne ondulee trait d'union ondule
©️ symbole copyright  ·  ©, c, copyright, droits d’auteur, propriété intellectuelle, symbole Copyright  ·  copyright ip license circle law legal  droits d'auteur propriete intellectuelle
®️ marque déposée  ·  ®, marque commerciale, r  ·  registered alphabet circle  marque deposee
™️ marque commerciale déposée  ·  marque déposée, TM  ·  trade mark trademark brand law legal  marque commerciale deposee marque deposee
ycap  symbol blue-square twitter
*️⃣ touches : *  ·  touches  ·  keycap  star keycap
0️⃣ touches : 0  ·  0, touches, zéro  ·  keycap 0 0 numbers blue-square null  zero
1️⃣ touches : 1  ·  1, touches, un  ·  keycap 1 blue-square numbers 1
2️⃣ touches : 2  ·  2, deux, touches  ·  keycap 2 numbers 2 prime blue-square
3️⃣ touches : 3  ·  3, touches, trois  ·  keycap 3 3 numbers prime blue-square
4️⃣ touches : 4  ·  4, quatre, touches  ·  keycap 4 4 numbers blue-square
5️⃣ touches : 5  ·  5, cinq, touches  ·  keycap 5 5 numbers blue-square prime
6️⃣ touches : 6  ·  6, six, touches  ·  keycap 6 6 numbers blue-square
7️⃣ touches : 7  ·  7, sept, touches  ·  keycap 7 7 numbers blue-square prime
8️⃣ touches : 8  ·  8, huit, touches  ·  keycap 8 8 blue-square numbers
9️⃣ touches : 9  ·  9, neuf, touches  ·  keycap 9 blue-square numbers 9
🔟 touches : 10  ·  touches  ·  keycap 10 numbers 10 blue-square
🔠 majuscules  ·  ABCD, alphabet latin, lettres, lettres latines, saisie, saisie en lettres majuscules  ·  input latin uppercase alphabet words blue-square
🔡 minuscules  ·  abcd, alphabet latin, lettre, lettres, lettres latines, saisie, saisie de lettres minuscules  ·  input latin lowercase blue-square alphabet
🔢 saisie de chiffres  ·  1234, chiffres, saisie  ·  input numbers numbers blue-square
🔣 saisie de symboles  ·  saisie, symboles  ·  input symbols blue-square music note ampersand percent glyphs characters
🔤 alphabet latin  ·  abc, alphabet, lettres, saisie, saisie de lettres  ·  input latin letters blue-square alphabet
🅰️ groupe sanguin A  ·  A, groupe sanguin  ·  a button red-square alphabet letter
🆎 groupe sanguin AB  ·  AB, groupe sanguin  ·  ab button red-square alphabet
🅱️ groupe sanguin B  ·  B, groupe sanguin  ·  b button red-square alphabet letter
🆑 bouton Effacer  ·  CL, effacer, icône Effacer  ·  cl button alphabet words red-square  icone Effacer
🆒 bouton Cool  ·  cool, icône Cool  ·  cool button words blue-square  icone Cool
🆓 bouton Gratuit  ·  gratuit, icône Gratuit  ·  free button blue-square words  icone Gratuit
ℹ️ source d’informations  ·  guichet d’informations, i, informations  ·  information blue-square alphabet letter  source d'informations guichet d'informations
🆔 bouton Identifiant  ·  bouton, icône Identifiant, ID, identifiant  ·  id button purple-square words  icone Identifiant
Ⓜ️ m encerclé  ·  cercle, m  ·  circled m alphabet blue-circle letter  m encercle
🆕 bouton Nouveau  ·  icône Nouveau, nouveau, nouveauté  ·  new button blue-square words start  icone Nouveau nouveaute
🆖 bouton Pas bien  ·  bouton NG, interdit, mauvais, NG  ·  ng button blue-square words shape icon
🅾️ groupe sanguin O  ·  groupe sanguin, O  ·  o button alphabet red-square letter
🆗 bouton OK  ·  icône OK, OK  ·  ok button good agree yes blue-square  icone OK
🅿️ bouton P  ·  bouton, P, panneau parking, parking  ·  p button cars blue-square alphabet letter
🆘 bouton SOS  ·  à l’aide, au secours, icône SOS, SOS  ·  sos button help red-square words emergency 911  a l'aide icone SOS
🆙 bouton Vers le haut  ·  icône Nouveauté, nouveau, nouveauté, up  ·  up button blue-square above high  icone Nouveaute nouveaute
🆚 bouton VS  ·  contre, icône Contre, versus, vs  ·  vs button words orange-square  icone Contre
🈁 bouton ici en japonais  ·  ici, idéogramme, idéogramme katakana ici, japonais  ·  japanese here button blue-square here katakana japanese destination  ideogramme ideogramme katakana ici
🈂️ bouton frais de service en japonais  ·  frais de service, idéogramme katakana, japonais  ·  japanese service charge button japanese blue-square katakana  ideogramme katakana
🈷️ bouton montant mensuel en japonais  ·  idéogramme, japonais, montant mensuel  ·  japanese monthly amount button chinese month moon japanese orange-square kanji  ideogramme
🈶 bouton pas gratuit en japonais  ·  idéogramme, japonais, pas gratuit, payant  ·  japanese not free of charge button orange-square chinese have kanji  ideogramme
🈯 bouton réservé en japonais  ·  idéogramme, japonais, réservé  ·  japanese reserved button chinese point green-square kanji  bouton reserve en japonais ideogramme reserve
🉐 bouton bonne affaire en japonais  ·  bonne affaire, idéogramme, idéogramme avantage, japonais  ·  japanese bargain button chinese kanji obtain get circle  ideogramme ideogramme avantage
🈹 bouton réduction en japonais  ·  idéogramme, japonais, rabais, réduction  ·  japanese discount button cut divide chinese kanji pink-square  bouton reduction en japonais ideogramme reduction
🈚 bouton gratuit en japonais  ·  gratuit, idéogramme, japonais  ·  japanese free of charge button nothing chinese kanji japanese orange-square  ideogramme
🈲 bouton interdit en japonais  ·  idéogramme, idéogramme interdit, japonais  ·  japanese prohibited button kanji japanese chinese forbidden limit restricted red-square  ideogramme ideogramme interdit
🉑 bouton accepter en japonais  ·  acceptable, accepter, idéogramme, japonais  ·  japanese acceptable button ok good chinese kanji agree yes orange-circle  ideogramme
🈸 bouton application en japonais  ·  application, idéogramme, idéogramme appliquer, japonais  ·  japanese application button chinese japanese kanji orange-square  ideogramme ideogramme appliquer
🈴 bouton note pour réussir en japonais  ·  idéogramme, japonais, note de passage, note pour réussir  ·  japanese passing grade button japanese chinese join kanji red-square  bouton note pour reussir en japonais ideogramme note pour reussir
🈳 bouton chambres disponibles en japonais  ·  chambres disponibles, idéogramme, idéogramme vide, japonais  ·  japanese vacancy button kanji japanese chinese empty sky blue-square  ideogramme ideogramme vide
㊗️ bouton félicitations en japonais  ·  félicitations, idéogramme, japonais  ·  japanese congratulations button chinese kanji japanese red-circle  bouton felicitations en japonais felicitations ideogramme
㊙️ bouton secret en japonais  ·  idéogramme, japonais, secret  ·  japanese secret button privacy chinese sshh kanji red-circle  ideogramme
🈺 bouton ouvert pour affaires en japonais  ·  idéogramme, japonais, ouvert, ouvert pour affaires  ·  japanese open for business button japanese opening hours orange-square  ideogramme
🈵 bouton complet en japonais  ·  complet, idéogramme, idéogramme plénitude, japonais  ·  japanese no vacancy button full chinese japanese red-square kanji  ideogramme ideogramme plenitude
🔴 disque rouge  ·  cercle, forme géométrique, géométrie, rond, rouge  ·  red circle shape error danger  forme geometrique geometrie
🟠 disque orange  ·  cercle, forme géométrique, géométrie, orange, rond  ·  orange circle round  forme geometrique geometrie
🟡 disque jaune  ·  cercle, forme géométrique, géométrie, jaune, rond  ·  yellow circle round  forme geometrique geometrie
🟢 disque vert  ·  cercle, forme géométrique, géométrie, rond, vert  ·  green circle round  forme geometrique geometrie
🔵 disque bleu  ·  bleu, cercle, forme géométrique, géométrie, rond  ·  blue circle shape icon button  forme geometrique geometrie
🟣 disque violet  ·  cercle, forme géométrique, géométrie, rond, violet  ·  purple circle round  forme geometrique geometrie
🟤 disque marron  ·  brun, cercle, disque brun, forme géométrique, géométrie, marron, rond  ·  brown circle round  forme geometrique geometrie
⚫ disque noir  ·  cercle, forme géométrique, géométrie, noir, rond  ·  black circle shape button round  forme geometrique geometrie
⚪ disque blanc  ·  blanc, cercle, forme géométrique, géométrie, rond  ·  white circle shape round  forme geometrique geometrie
🟥 carré rouge  ·  carré, forme géométrique, géométrie, rouge  ·  red square  carre rouge carre forme geometrique geometrie
🟧 carré orange  ·  carré, forme géométrique, géométrie, orange  ·  orange square  carre orange carre forme geometrique geometrie
🟨 carré jaune  ·  carré, forme géométrique, géométrie, jaune  ·  yellow square  carre jaune carre forme geometrique geometrie
🟩 carré vert  ·  carré, forme géométrique, géométrie, vert  ·  green square  carre vert carre forme geometrique geometrie
🟦 carré bleu  ·  bleu, carré, forme géométrique, géométrie  ·  blue square  carre bleu carre forme geometrique geometrie
🟪 carré violet  ·  carré, forme géométrique, géométrie, violet  ·  purple square  carre violet carre forme geometrique geometrie
🟫 carré marron  ·  carré, carré brun, forme géométrique, géométrie, marron  ·  brown square  carre marron carre carre brun forme geometrique geometrie
⬛ grand carré noir  ·  carré, forme, forme géométrique, géométrie  ·  black large square shape icon button  grand carre noir carre forme geometrique geometrie
⬜ grand carré blanc  ·  carré, forme, géométrie  ·  white large square shape icon stone button  grand carre blanc carre geometrie
◼️ carré moyen noir  ·  carré, forme, forme géométrique, géométrie  ·  black medium square shape button icon  carre moyen noir carre forme geometrique geometrie
◻️ carré moyen blanc  ·  carré, forme, forme géométrique, géométrie  ·  white medium square shape stone icon  carre moyen blanc carre forme geometrique geometrie
◾ carré petit moyen noir  ·  carré, forme, géométrie  ·  black medium small square icon shape button  carre petit moyen noir carre geometrie
◽ carré petit moyen blanc  ·  carré, forme, géométrie  ·  white medium small square shape stone icon button  carre petit moyen blanc carre geometrie
▪️ petit carré noir  ·  carré, forme, forme géométrique, géométrie  ·  black small square shape icon  petit carre noir carre forme geometrique geometrie
▫️ petit carré blanc  ·  carré, forme, forme géométrique, géométrie  ·  white small square shape icon  petit carre blanc carre forme geometrique geometrie
🔶 grand losange orange  ·  forme géométrique, géométrie, losange  ·  large orange diamond shape jewel gem  forme geometrique geometrie
🔷 grand losange bleu  ·  forme géométrique, géométrie, grand losange orange, losange  ·  large blue diamond shape jewel gem  forme geometrique geometrie
🔸 petit losange orange  ·  forme géométrique, géométrie, losange  ·  small orange diamond shape jewel gem  forme geometrique geometrie
🔹 petit losange bleu  ·  forme géométrique, géométrie, losange  ·  small blue diamond shape jewel gem  forme geometrique geometrie
🔺 triangle rouge pointant vers le haut  ·  flèche, forme géométrique, géométrie, rouge, triangle haut, triangle rouge pointé vers le haut  ·  red triangle pointed up shape direction up top  fleche forme geometrique geometrie triangle rouge pointe vers le haut
🔻 triangle rouge pointant vers le bas  ·  bas, flèche, forme, géométrie, rouge, triangle bas, triangle rouge pointé vers le bas  ·  red triangle pointed down shape direction bottom  fleche geometrie triangle rouge pointe vers le bas
💠 diamant avec un point  ·  bande dessinée, BD, dessin, diamant, géométrie, géométrique, intérieur  ·  diamond with a dot jewel blue gem crystal fancy  bande dessinee geometrie geometrique interieur
🔘 bouton radio  ·  bouton, forme, géométrie, géométrique, radio, rond  ·  radio button input old music circle  geometrie geometrique
🔳 carré blanc  ·  bouton, carré, forme, géométrie  ·  white square button shape input  carre blanc carre geometrie
🔲 carré noir  ·  bouton, carré, forme, géométrie  ·  black square button shape input frame  carre noir carre geometrie
🏁 drapeau à damier  ·  course automobile, damier, drapeau, formule 1, ligne d’arrivée, sport automobile, vainqueur  ·  chequered flag contest finishline race gokart  drapeau a damier ligne d'arrivee
🚩 drapeau triangulaire  ·  drapeau, drapeau rouge, fanion, golf  ·  triangular flag mark milestone place
🎌 drapeaux croisés  ·  drapeaux, japonais  ·  crossed flags japanese nation country border  drapeaux croises
🏴 drapeau noir  ·  drapeau, drapeau qui flotte au vent  ·  black flag pirate
🏳️ drapeau blanc  ·  drapeau, drapeau qui flotte au vent  ·  white flag losing loser lost surrender give up fail
🏳️‍🌈 drapeau arc-en-ciel  ·  arc-en-ciel, drapeau, lgbt  ·  rainbow flag flag rainbow pride gay lgbt glbt queer homosexual lesbian bisexual transgender
🏴‍☠️ drapeau de pirate  ·  pillage, piller, pirate, trésor  ·  pirate flag skull crossbones flag banner  tresor
🇦🇨 drapeau : Île de l’Ascension  ·  drapeau  ·  flag ascension island  drapeau : Ile de l'Ascension
🇦🇩 drapeau : Andorre  ·  drapeau  ·  flag andorra ad flag nation country banner andorra
🇦🇪 drapeau : Émirats arabes unis  ·  drapeau  ·  flag united arab emirates united arab emirates flag nation country banner united arab emirates  drapeau : Emirats arabes unis
🇦🇫 drapeau : Afghanistan  ·  drapeau  ·  flag afghanistan af flag nation country banner afghanistan
🇦🇬 drapeau : Antigua-et-Barbuda  ·  drapeau  ·  flag antigua barbuda antigua barbuda flag nation country banner antigua barbuda
🇦🇮 drapeau : Anguilla  ·  drapeau  ·  flag anguilla ai flag nation country banner anguilla
🇦🇱 drapeau : Albanie  ·  drapeau  ·  flag albania al flag nation country banner albania
🇦🇲 drapeau : Arménie  ·  drapeau  ·  flag armenia am flag nation country banner armenia  drapeau : Armenie
🇦🇴 drapeau : Angola  ·  drapeau  ·  flag angola ao flag nation country banner angola
🇦🇶 drapeau : Antarctique  ·  drapeau  ·  flag antarctica aq flag nation country banner antarctica
🇦🇷 drapeau : Argentine  ·  drapeau  ·  flag argentina ar flag nation country banner argentina
🇦🇸 drapeau : Samoa américaines  ·  drapeau  ·  flag american samoa american ws flag nation country banner american samoa  drapeau : Samoa americaines
🇦🇹 drapeau : Autriche  ·  drapeau  ·  flag austria at flag nation country banner austria
🇦🇺 drapeau : Australie  ·  drapeau  ·  flag australia au flag nation country banner australia
🇦🇼 drapeau : Aruba  ·  drapeau  ·  flag aruba aw flag nation country banner aruba
🇦🇽 drapeau : Îles Åland  ·  drapeau  ·  flag aland islands Åland islands flag nation country banner aland islands  drapeau : Iles Aland
🇦🇿 drapeau : Azerbaïdjan  ·  drapeau  ·  flag azerbaijan az flag nation country banner azerbaijan  drapeau : Azerbaidjan
🇧🇦 drapeau : Bosnie-Herzégovine  ·  drapeau  ·  flag bosnia herzegovina bosnia herzegovina flag nation country banner bosnia herzegovina  drapeau : Bosnie-Herzegovine
🇧🇧 drapeau : Barbade  ·  drapeau  ·  flag barbados bb flag nation country banner barbados
🇧🇩 drapeau : Bangladesh  ·  drapeau  ·  flag bangladesh bd flag nation country banner bangladesh
🇧🇪 drapeau : Belgique  ·  drapeau  ·  flag belgium be flag nation country banner belgium
🇧🇫 drapeau : Burkina Faso  ·  drapeau  ·  flag burkina faso burkina faso flag nation country banner burkina faso
🇧🇬 drapeau : Bulgarie  ·  drapeau  ·  flag bulgaria bg flag nation country banner bulgaria
🇧🇭 drapeau : Bahreïn  ·  drapeau  ·  flag bahrain bh flag nation country banner bahrain  drapeau : Bahrein
🇧🇮 drapeau : Burundi  ·  drapeau  ·  flag burundi bi flag nation country banner burundi
🇧🇯 drapeau : Bénin  ·  drapeau  ·  flag benin bj flag nation country banner benin  drapeau : Benin
🇧🇱 drapeau : Saint-Barthélemy  ·  drapeau  ·  flag st barthelemy saint barthélemy flag nation country banner st barthelemy  drapeau : Saint-Barthelemy
🇧🇲 drapeau : Bermudes  ·  drapeau  ·  flag bermuda bm flag nation country banner bermuda
🇧🇳 drapeau : Brunei  ·  drapeau  ·  flag brunei bn darussalam flag nation country banner brunei
🇧🇴 drapeau : Bolivie  ·  drapeau  ·  flag bolivia bo flag nation country banner bolivia
🇧🇶 drapeau : Pays-Bas caribéens  ·  drapeau  ·  flag caribbean netherlands bonaire flag nation country banner caribbean netherlands  drapeau : Pays-Bas caribeens
🇧🇷 drapeau : Brésil  ·  drapeau  ·  flag brazil br flag nation country banner brazil  drapeau : Bresil
🇧🇸 drapeau : Bahamas  ·  drapeau  ·  flag bahamas bs flag nation country banner bahamas
🇧🇹 drapeau : Bhoutan  ·  drapeau  ·  flag bhutan bt flag nation country banner bhutan
🇧🇻 drapeau : Île Bouvet  ·  drapeau  ·  flag bouvet island norway  drapeau : Ile Bouvet
🇧🇼 drapeau : Botswana  ·  drapeau  ·  flag botswana bw flag nation country banner botswana
🇧🇾 drapeau : Biélorussie  ·  drapeau  ·  flag belarus by flag nation country banner belarus  drapeau : Bielorussie
🇧🇿 drapeau : Belize  ·  drapeau  ·  flag belize bz flag nation country banner belize
🇨🇦 drapeau : Canada  ·  drapeau  ·  flag canada ca flag nation country banner canada
🇨🇨 drapeau : Îles Cocos  ·  drapeau  ·  flag cocos islands cocos keeling islands flag nation country banner cocos islands  drapeau : Iles Cocos
🇨🇩 drapeau : Congo-Kinshasa  ·  drapeau  ·  flag congo kinshasa congo democratic republic flag nation country banner congo kinshasa
🇨🇫 drapeau : République centrafricaine  ·  drapeau  ·  flag central african republic central african republic flag nation country banner central african republic  drapeau : Republique centrafricaine
🇨🇬 drapeau : Congo-Brazzaville  ·  drapeau  ·  flag congo brazzaville congo flag nation country banner congo brazzaville
🇨🇭 drapeau : Suisse  ·  drapeau  ·  flag switzerland ch flag nation country banner switzerland
🇨🇮 drapeau : Côte d’Ivoire  ·  drapeau  ·  flag cote d ivoire ivory coast flag nation country banner cote d ivoire  drapeau : Cote d'Ivoire
🇨🇰 drapeau : Îles Cook  ·  drapeau  ·  flag cook islands cook islands flag nation country banner cook islands  drapeau : Iles Cook
🇨🇱 drapeau : Chili  ·  drapeau  ·  flag chile flag nation country banner chile
🇨🇲 drapeau : Cameroun  ·  drapeau  ·  flag cameroon cm flag nation country banner cameroon
🇨🇳 drapeau : Chine  ·  drapeau  ·  flag china china chinese prc flag country nation banner china
🇨🇴 drapeau : Colombie  ·  drapeau  ·  flag colombia co flag nation country banner colombia
🇨🇵 drapeau : Île Clipperton  ·  drapeau  ·  flag clipperton island  drapeau : Ile Clipperton
🇨🇷 drapeau : Costa Rica  ·  drapeau  ·  flag costa rica costa rica flag nation country banner costa rica
🇨🇺 drapeau : Cuba  ·  drapeau  ·  flag cuba cu flag nation country banner cuba
🇨🇻 drapeau : Cap-Vert  ·  drapeau  ·  flag cape verde cabo verde flag nation country banner cape verde
🇨🇼 drapeau : Curaçao  ·  drapeau  ·  flag curacao curaçao flag nation country banner curacao  drapeau : Curacao
🇨🇽 drapeau : Île Christmas  ·  drapeau  ·  flag christmas island christmas island flag nation country banner christmas island  drapeau : Ile Christmas
🇨🇾 drapeau : Chypre  ·  drapeau  ·  flag cyprus cy flag nation country banner cyprus
🇨🇿 drapeau : Tchéquie  ·  drapeau  ·  flag czechia cz flag nation country banner czechia  drapeau : Tchequie
🇩🇪 drapeau : Allemagne  ·  drapeau  ·  flag germany german nation flag country banner germany
🇩🇬 drapeau : Diego Garcia  ·  drapeau  ·  flag diego garcia
🇩🇯 drapeau : Djibouti  ·  drapeau  ·  flag djibouti dj flag nation country banner djibouti
🇩🇰 drapeau : Danemark  ·  drapeau  ·  flag denmark dk flag nation country banner denmark
🇩🇲 drapeau : Dominique  ·  drapeau  ·  flag dominica dm flag nation country banner dominica
🇩🇴 drapeau : République dominicaine  ·  drapeau  ·  flag dominican republic dominican republic flag nation country banner dominican republic  drapeau : Republique dominicaine
🇩🇿 drapeau : Algérie  ·  drapeau  ·  flag algeria dz flag nation country banner algeria  drapeau : Algerie
🇪🇦 drapeau : Ceuta et Melilla  ·  drapeau  ·  flag ceuta melilla
🇪🇨 drapeau : Équateur  ·  drapeau  ·  flag ecuador ec flag nation country banner ecuador  drapeau : Equateur
🇪🇪 drapeau : Estonie  ·  drapeau  ·  flag estonia ee flag nation country banner estonia
🇪🇬 drapeau : Égypte  ·  drapeau  ·  flag egypt eg flag nation country banner egypt  drapeau : Egypte
🇪🇭 drapeau : Sahara occidental  ·  drapeau  ·  flag western sahara western sahara flag nation country banner western sahara
🇪🇷 drapeau : Érythrée  ·  drapeau  ·  flag eritrea er flag nation country banner eritrea  drapeau : Erythree
🇪🇸 drapeau : Espagne  ·  drapeau  ·  flag spain spain flag nation country banner spain
🇪🇹 drapeau : Éthiopie  ·  drapeau  ·  flag ethiopia et flag nation country banner ethiopia  drapeau : Ethiopie
🇪🇺 drapeau : Union européenne  ·  drapeau  ·  flag european union european union flag banner  drapeau : Union europeenne
🇫🇮 drapeau : Finlande  ·  drapeau  ·  flag finland fi flag nation country banner finland
🇫🇯 drapeau : Fidji  ·  drapeau  ·  flag fiji fj flag nation country banner fiji
🇫🇰 drapeau : Îles Malouines  ·  drapeau  ·  flag falkland islands falkland islands malvinas flag nation country banner falkland islands  drapeau : Iles Malouines
🇫🇲 drapeau : Micronésie  ·  drapeau  ·  flag micronesia micronesia federated states flag nation country banner micronesia  drapeau : Micronesie
🇫🇴 drapeau : Îles Féroé  ·  drapeau  ·  flag faroe islands faroe islands flag nation country banner faroe islands  drapeau : Iles Feroe
🇫🇷 drapeau : France  ·  drapeau  ·  flag france banner flag nation france french country france
🇬🇦 drapeau : Gabon  ·  drapeau  ·  flag gabon ga flag nation country banner gabon
🇬🇧 drapeau : Royaume-Uni  ·  drapeau  ·  flag united kingdom united kingdom great britain northern ireland flag nation country banner british UK english england union jack united kingdom
🇬🇩 drapeau : Grenade  ·  drapeau  ·  flag grenada gd flag nation country banner grenada
🇬🇪 drapeau : Géorgie  ·  drapeau  ·  flag georgia ge flag nation country banner georgia  drapeau : Georgie
🇬🇫 drapeau : Guyane française  ·  drapeau  ·  flag french guiana french guiana flag nation country banner french guiana  drapeau : Guyane francaise
🇬🇬 drapeau : Guernesey  ·  drapeau  ·  flag guernsey gg flag nation country banner guernsey
🇬🇭 drapeau : Ghana  ·  drapeau  ·  flag ghana gh flag nation country banner ghana
🇬🇮 drapeau : Gibraltar  ·  drapeau  ·  flag gibraltar gi flag nation country banner gibraltar
🇬🇱 drapeau : Groenland  ·  drapeau  ·  flag greenland gl flag nation country banner greenland
🇬🇲 drapeau : Gambie  ·  drapeau  ·  flag gambia gm flag nation country banner gambia
🇬🇳 drapeau : Guinée  ·  drapeau  ·  flag guinea gn flag nation country banner guinea  drapeau : Guinee
🇬🇵 drapeau : Guadeloupe  ·  drapeau  ·  flag guadeloupe gp flag nation country banner guadeloupe
🇬🇶 drapeau : Guinée équatoriale  ·  drapeau  ·  flag equatorial guinea equatorial gn flag nation country banner equatorial guinea  drapeau : Guinee equatoriale
🇬🇷 drapeau : Grèce  ·  drapeau  ·  flag greece gr flag nation country banner greece  drapeau : Grece
🇬🇸 drapeau : Géorgie du Sud-et-les Îles Sandwich du Sud  ·  drapeau  ·  flag south georgia south sandwich islands south georgia sandwich islands flag nation country banner south georgia south sandwich islands  drapeau : Georgie du Sud-et-les Iles Sandwich du Sud
🇬🇹 drapeau : Guatemala  ·  drapeau  ·  flag guatemala gt flag nation country banner guatemala
🇬🇺 drapeau : Guam  ·  drapeau  ·  flag guam gu flag nation country banner guam
🇬🇼 drapeau : Guinée-Bissau  ·  drapeau  ·  flag guinea bissau gw bissau flag nation country banner guinea bissau  drapeau : Guinee-Bissau
🇬🇾 drapeau : Guyana  ·  drapeau  ·  flag guyana gy flag nation country banner guyana
🇭🇰 drapeau : R.A.S. chinoise de Hong Kong  ·  drapeau  ·  flag hong kong sar china hong kong flag nation country banner hong kong sar china
🇭🇲 drapeau : Îles Heard-et-MacDonald  ·  drapeau  ·  flag heard mcdonald islands  drapeau : Iles Heard-et-MacDonald
🇭🇳 drapeau : Honduras  ·  drapeau  ·  flag honduras hn flag nation country banner honduras
🇭🇷 drapeau : Croatie  ·  drapeau  ·  flag croatia hr flag nation country banner croatia
🇭🇹 drapeau : Haïti  ·  drapeau  ·  flag haiti ht flag nation country banner haiti  drapeau : Haiti
🇭🇺 drapeau : Hongrie  ·  drapeau  ·  flag hungary hu flag nation country banner hungary
🇮🇨 drapeau : Îles Canaries  ·  drapeau  ·  flag canary islands canary islands flag nation country banner canary islands  drapeau : Iles Canaries
🇮🇩 drapeau : Indonésie  ·  drapeau  ·  flag indonesia flag nation country banner indonesia  drapeau : Indonesie
🇮🇪 drapeau : Irlande  ·  drapeau  ·  flag ireland ie flag nation country banner ireland
🇮🇱 drapeau : Israël  ·  drapeau  ·  flag israel il flag nation country banner israel  drapeau : Israel
🇮🇲 drapeau : Île de Man  ·  drapeau  ·  flag isle of man isle man flag nation country banner isle of man  drapeau : Ile de Man
🇮🇳 drapeau : Inde  ·  drapeau  ·  flag india in flag nation country banner india
🇮🇴 drapeau : Territoire britannique de l’océan Indien  ·  drapeau  ·  flag british indian ocean territory british indian ocean territory flag nation country banner british indian ocean territory  drapeau : Territoire britannique de l'ocean Indien
🇮🇶 drapeau : Irak  ·  drapeau  ·  flag iraq iq flag nation country banner iraq
🇮🇷 drapeau : Iran  ·  drapeau  ·  flag iran iran islamic republic flag nation country banner iran
🇮🇸 drapeau : Islande  ·  drapeau  ·  flag iceland is flag nation country banner iceland
🇮🇹 drapeau : Italie  ·  drapeau  ·  flag italy italy flag nation country banner italy
🇯🇪 drapeau : Jersey  ·  drapeau  ·  flag jersey je flag nation country banner jersey
🇯🇲 drapeau : Jamaïque  ·  drapeau  ·  flag jamaica jm flag nation country banner jamaica  drapeau : Jamaique
🇯🇴 drapeau : Jordanie  ·  drapeau  ·  flag jordan jo flag nation country banner jordan
🇯🇵 drapeau : Japon  ·  drapeau  ·  flag japan japanese nation flag country banner japan
🇰🇪 drapeau : Kenya  ·  drapeau  ·  flag kenya ke flag nation country banner kenya
🇰🇬 drapeau : Kirghizstan  ·  drapeau  ·  flag kyrgyzstan kg flag nation country banner kyrgyzstan
🇰🇭 drapeau : Cambodge  ·  drapeau  ·  flag cambodia kh flag nation country banner cambodia
🇰🇮 drapeau : Kiribati  ·  drapeau  ·  flag kiribati ki flag nation country banner kiribati
🇰🇲 drapeau : Comores  ·  drapeau  ·  flag comoros km flag nation country banner comoros
🇰🇳 drapeau : Saint-Christophe-et-Niévès  ·  drapeau  ·  flag st kitts nevis saint kitts nevis flag nation country banner st kitts nevis  drapeau : Saint-Christophe-et-Nieves
🇰🇵 drapeau : Corée du Nord  ·  drapeau  ·  flag north korea north korea nation flag country banner north korea  drapeau : Coree du Nord
🇰🇷 drapeau : Corée du Sud  ·  drapeau  ·  flag south korea south korea nation flag country banner south korea  drapeau : Coree du Sud
🇰🇼 drapeau : Koweït  ·  drapeau  ·  flag kuwait kw flag nation country banner kuwait  drapeau : Koweit
🇰🇾 drapeau : Îles Caïmans  ·  drapeau  ·  flag cayman islands cayman islands flag nation country banner cayman islands  drapeau : Iles Caimans
🇰🇿 drapeau : Kazakhstan  ·  drapeau  ·  flag kazakhstan kz flag nation country banner kazakhstan
🇱🇦 drapeau : Laos  ·  drapeau  ·  flag laos lao democratic republic flag nation country banner laos
🇱🇧 drapeau : Liban  ·  drapeau  ·  flag lebanon lb flag nation country banner lebanon
🇱🇨 drapeau : Sainte-Lucie  ·  drapeau  ·  flag st lucia saint lucia flag nation country banner st lucia
🇱🇮 drapeau : Liechtenstein  ·  drapeau  ·  flag liechtenstein li flag nation country banner liechtenstein
🇱🇰 drapeau : Sri Lanka  ·  drapeau  ·  flag sri lanka sri lanka flag nation country banner sri lanka
🇱🇷 drapeau : Liberia  ·  drapeau  ·  flag liberia lr flag nation country banner liberia
🇱🇸 drapeau : Lesotho  ·  drapeau  ·  flag lesotho ls flag nation country banner lesotho
🇱🇹 drapeau : Lituanie  ·  drapeau  ·  flag lithuania lt flag nation country banner lithuania
🇱🇺 drapeau : Luxembourg  ·  drapeau  ·  flag luxembourg lu flag nation country banner luxembourg
🇱🇻 drapeau : Lettonie  ·  drapeau  ·  flag latvia lv flag nation country banner latvia
🇱🇾 drapeau : Libye  ·  drapeau  ·  flag libya ly flag nation country banner libya
🇲🇦 drapeau : Maroc  ·  drapeau  ·  flag morocco ma flag nation country banner morocco
🇲🇨 drapeau : Monaco  ·  drapeau  ·  flag monaco mc flag nation country banner monaco
🇲🇩 drapeau : Moldavie  ·  drapeau  ·  flag moldova moldova republic flag nation country banner moldova
🇲🇪 drapeau : Monténégro  ·  drapeau  ·  flag montenegro me flag nation country banner montenegro  drapeau : Montenegro
🇲🇫 drapeau : Saint-Martin  ·  drapeau  ·  flag st martin
🇲🇬 drapeau : Madagascar  ·  drapeau  ·  flag madagascar mg flag nation country banner madagascar
🇲🇭 drapeau : Îles Marshall  ·  drapeau  ·  flag marshall islands marshall islands flag nation country banner marshall islands  drapeau : Iles Marshall
🇲🇰 drapeau : Macédoine du Nord  ·  drapeau  ·  flag north macedonia macedonia flag nation country banner north macedonia  drapeau : Macedoine du Nord
🇲🇱 drapeau : Mali  ·  drapeau  ·  flag mali ml flag nation country banner mali
🇲🇲 drapeau : Myanmar (Birmanie)  ·  drapeau  ·  flag myanmar mm flag nation country banner myanmar
🇲🇳 drapeau : Mongolie  ·  drapeau  ·  flag mongolia mn flag nation country banner mongolia
🇲🇴 drapeau : R.A.S. chinoise de Macao  ·  drapeau  ·  flag macao sar china macao flag nation country banner macao sar china
🇲🇵 drapeau : Îles Mariannes du Nord  ·  drapeau  ·  flag northern mariana islands northern mariana islands flag nation country banner northern mariana islands  drapeau : Iles Mariannes du Nord
🇲🇶 drapeau : Martinique  ·  drapeau  ·  flag martinique mq flag nation country banner martinique
🇲🇷 drapeau : Mauritanie  ·  drapeau  ·  flag mauritania mr flag nation country banner mauritania
🇲🇸 drapeau : Montserrat  ·  drapeau  ·  flag montserrat ms flag nation country banner montserrat
🇲🇹 drapeau : Malte  ·  drapeau  ·  flag malta mt flag nation country banner malta
🇲🇺 drapeau : Maurice  ·  drapeau  ·  flag mauritius mu flag nation country banner mauritius
🇲🇻 drapeau : Maldives  ·  drapeau  ·  flag maldives mv flag nation country banner maldives
🇲🇼 drapeau : Malawi  ·  drapeau  ·  flag malawi mw flag nation country banner malawi
🇲🇽 drapeau : Mexique  ·  drapeau  ·  flag mexico mx flag nation country banner mexico
🇲🇾 drapeau : Malaisie  ·  drapeau  ·  flag malaysia my flag nation country banner malaysia
🇲🇿 drapeau : Mozambique  ·  drapeau  ·  flag mozambique mz flag nation country banner mozambique
🇳🇦 drapeau : Namibie  ·  drapeau  ·  flag namibia na flag nation country banner namibia
🇳🇨 drapeau : Nouvelle-Calédonie  ·  drapeau  ·  flag new caledonia new caledonia flag nation country banner new caledonia  drapeau : Nouvelle-Caledonie
🇳🇪 drapeau : Niger  ·  drapeau  ·  flag niger ne flag nation country banner niger
🇳🇫 drapeau : Île Norfolk  ·  drapeau  ·  flag norfolk island norfolk island flag nation country banner norfolk island  drapeau : Ile Norfolk
🇳🇬 drapeau : Nigeria  ·  drapeau  ·  flag nigeria flag nation country banner nigeria
🇳🇮 drapeau : Nicaragua  ·  drapeau  ·  flag nicaragua ni flag nation country banner nicaragua
🇳🇱 drapeau : Pays-Bas  ·  drapeau  ·  flag netherlands nl flag nation country banner netherlands
🇳🇴 drapeau : Norvège  ·  drapeau  ·  flag norway no flag nation country banner norway  drapeau : Norvege
🇳🇵 drapeau : Népal  ·  drapeau  ·  flag nepal np flag nation country banner nepal  drapeau : Nepal
🇳🇷 drapeau : Nauru  ·  drapeau  ·  flag nauru nr flag nation country banner nauru
🇳🇺 drapeau : Niue  ·  drapeau  ·  flag niue nu flag nation country banner niue
🇳🇿 drapeau : Nouvelle-Zélande  ·  drapeau  ·  flag new zealand new zealand flag nation country banner new zealand  drapeau : Nouvelle-Zelande
🇴🇲 drapeau : Oman  ·  drapeau  ·  flag oman om symbol flag nation country banner oman
🇵🇦 drapeau : Panama  ·  drapeau  ·  flag panama pa flag nation country banner panama
🇵🇪 drapeau : Pérou  ·  drapeau  ·  flag peru pe flag nation country banner peru  drapeau : Perou
🇵🇫 drapeau : Polynésie française  ·  drapeau  ·  flag french polynesia french polynesia flag nation country banner french polynesia  drapeau : Polynesie francaise
🇵🇬 drapeau : Papouasie-Nouvelle-Guinée  ·  drapeau  ·  flag papua new guinea papua new guinea flag nation country banner papua new guinea  drapeau : Papouasie-Nouvelle-Guinee
🇵🇭 drapeau : Philippines  ·  drapeau  ·  flag philippines ph flag nation country banner philippines
🇵🇰 drapeau : Pakistan  ·  drapeau  ·  flag pakistan pk flag nation country banner pakistan
🇵🇱 drapeau : Pologne  ·  drapeau  ·  flag poland pl flag nation country banner poland
🇵🇲 drapeau : Saint-Pierre-et-Miquelon  ·  drapeau  ·  flag st pierre miquelon saint pierre miquelon flag nation country banner st pierre miquelon
🇵🇳 drapeau : Îles Pitcairn  ·  drapeau  ·  flag pitcairn islands pitcairn flag nation country banner pitcairn islands  drapeau : Iles Pitcairn
🇵🇷 drapeau : Porto Rico  ·  drapeau  ·  flag puerto rico puerto rico flag nation country banner puerto rico
🇵🇸 drapeau : Territoires palestiniens  ·  drapeau  ·  flag palestinian territories palestine palestinian territories flag nation country banner palestinian territories
🇵🇹 drapeau : Portugal  ·  drapeau  ·  flag portugal pt flag nation country banner portugal
🇵🇼 drapeau : Palaos  ·  drapeau  ·  flag palau pw flag nation country banner palau
🇵🇾 drapeau : Paraguay  ·  drapeau  ·  flag paraguay py flag nation country banner paraguay
🇶🇦 drapeau : Qatar  ·  drapeau  ·  flag qatar qa flag nation country banner qatar
🇷🇪 drapeau : La Réunion  ·  drapeau  ·  flag reunion réunion flag nation country banner reunion  drapeau : La Reunion
🇷🇴 drapeau : Roumanie  ·  drapeau  ·  flag romania ro flag nation country banner romania
🇷🇸 drapeau : Serbie  ·  drapeau  ·  flag serbia rs flag nation country banner serbia
🇷🇺 drapeau : Russie  ·  drapeau  ·  flag russia russian federation flag nation country banner russia
🇷🇼 drapeau : Rwanda  ·  drapeau  ·  flag rwanda rw flag nation country banner rwanda
🇸🇦 drapeau : Arabie saoudite  ·  drapeau  ·  flag saudi arabia flag nation country banner saudi arabia
🇸🇧 drapeau : Îles Salomon  ·  drapeau  ·  flag solomon islands solomon islands flag nation country banner solomon islands  drapeau : Iles Salomon
🇸🇨 drapeau : Seychelles  ·  drapeau  ·  flag seychelles sc flag nation country banner seychelles
🇸🇩 drapeau : Soudan  ·  drapeau  ·  flag sudan sd flag nation country banner sudan
🇸🇪 drapeau : Suède  ·  drapeau  ·  flag sweden se flag nation country banner sweden  drapeau : Suede
🇸🇬 drapeau : Singapour  ·  drapeau  ·  flag singapore sg flag nation country banner singapore
🇸🇭 drapeau : Sainte-Hélène  ·  drapeau  ·  flag st helena saint helena ascension tristan cunha flag nation country banner st helena  drapeau : Sainte-Helene
🇸🇮 drapeau : Slovénie  ·  drapeau  ·  flag slovenia si flag nation country banner slovenia  drapeau : Slovenie
🇸🇯 drapeau : Svalbard et Jan Mayen  ·  drapeau  ·  flag svalbard jan mayen
🇸🇰 drapeau : Slovaquie  ·  drapeau  ·  flag slovakia sk flag nation country banner slovakia
🇸🇱 drapeau : Sierra Leone  ·  drapeau  ·  flag sierra leone sierra leone flag nation country banner sierra leone
🇸🇲 drapeau : Saint-Marin  ·  drapeau  ·  flag san marino san marino flag nation country banner san marino
🇸🇳 drapeau : Sénégal  ·  drapeau  ·  flag senegal sn flag nation country banner senegal  drapeau : Senegal
🇸🇴 drapeau : Somalie  ·  drapeau  ·  flag somalia so flag nation country banner somalia
🇸🇷 drapeau : Suriname  ·  drapeau  ·  flag suriname sr flag nation country banner suriname
🇸🇸 drapeau : Soudan du Sud  ·  drapeau  ·  flag south sudan south sd flag nation country banner south sudan
🇸🇹 drapeau : Sao Tomé-et-Principe  ·  drapeau  ·  flag sao tome principe sao tome principe flag nation country banner sao tome principe  drapeau : Sao Tome-et-Principe
🇸🇻 drapeau : Salvador  ·  drapeau  ·  flag el salvador el salvador flag nation country banner el salvador
🇸🇽 drapeau : Saint-Martin (partie néerlandaise)  ·  drapeau  ·  flag sint maarten sint maarten dutch flag nation country banner sint maarten  drapeau : Saint-Martin (partie neerlandaise)
🇸🇾 drapeau : Syrie  ·  drapeau  ·  flag syria syrian arab republic flag nation country banner syria
🇸🇿 drapeau : Eswatini  ·  drapeau  ·  flag eswatini sz flag nation country banner eswatini
🇹🇦 drapeau : Tristan da Cunha  ·  drapeau  ·  flag tristan da cunha
🇹🇨 drapeau : Îles Turques-et-Caïques  ·  drapeau  ·  flag turks caicos islands turks caicos islands flag nation country banner turks caicos islands  drapeau : Iles Turques-et-Caiques
🇹🇩 drapeau : Tchad  ·  drapeau  ·  flag chad td flag nation country banner chad
🇹🇫 drapeau : Terres australes françaises  ·  drapeau  ·  flag french southern territories french southern territories flag nation country banner french southern territories  drapeau : Terres australes francaises
🇹🇬 drapeau : Togo  ·  drapeau  ·  flag togo tg flag nation country banner togo
🇹🇭 drapeau : Thaïlande  ·  drapeau  ·  flag thailand th flag nation country banner thailand  drapeau : Thailande
🇹🇯 drapeau : Tadjikistan  ·  drapeau  ·  flag tajikistan tj flag nation country banner tajikistan
🇹🇰 drapeau : Tokelau  ·  drapeau  ·  flag tokelau tk flag nation country banner tokelau
🇹🇱 drapeau : Timor oriental  ·  drapeau  ·  flag timor leste timor leste flag nation country banner timor leste
🇹🇲 drapeau : Turkménistan  ·  drapeau  ·  flag turkmenistan flag nation country banner turkmenistan  drapeau : Turkmenistan
🇹🇳 drapeau : Tunisie  ·  drapeau  ·  flag tunisia tn flag nation country banner tunisia
🇹🇴 drapeau : Tonga  ·  drapeau  ·  flag tonga to flag nation country banner tonga
🇹🇷 drapeau : Turquie  ·  drapeau  ·  flag turkey turkey flag nation country banner turkey
🇹🇹 drapeau : Trinité-et-Tobago  ·  drapeau  ·  flag trinidad tobago trinidad tobago flag nation country banner trinidad tobago  drapeau : Trinite-et-Tobago
🇹🇻 drapeau : Tuvalu  ·  drapeau  ·  flag tuvalu flag nation country banner tuvalu
🇹🇼 drapeau : Taïwan  ·  drapeau  ·  flag taiwan tw flag nation country banner taiwan  drapeau : Taiwan
🇹🇿 drapeau : Tanzanie  ·  drapeau  ·  flag tanzania tanzania united republic flag nation country banner tanzania
🇺🇦 drapeau : Ukraine  ·  drapeau  ·  flag ukraine ua flag nation country banner ukraine
🇺🇬 drapeau : Ouganda  ·  drapeau  ·  flag uganda ug flag nation country banner uganda
🇺🇲 drapeau : Îles mineures éloignées des États-Unis  ·  drapeau  ·  flag u s outlying islands  drapeau : Iles mineures eloignees des Etats-Unis
🇺🇳 drapeau : Nations Unies  ·  drapeau  ·  flag united nations un flag banner
🇺🇸 drapeau : États-Unis  ·  drapeau  ·  flag united states united states america flag nation country banner united states  drapeau : Etats-Unis
🇺🇾 drapeau : Uruguay  ·  drapeau  ·  flag uruguay uy flag nation country banner uruguay
🇺🇿 drapeau : Ouzbékistan  ·  drapeau  ·  flag uzbekistan uz flag nation country banner uzbekistan  drapeau : Ouzbekistan
🇻🇦 drapeau : État de la Cité du Vatican  ·  drapeau  ·  flag vatican city vatican city flag nation country banner vatican city  drapeau : Etat de la Cite du Vatican
🇻🇨 drapeau : Saint-Vincent-et-les Grenadines  ·  drapeau  ·  flag st vincent grenadines saint vincent grenadines flag nation country banner st vincent grenadines
🇻🇪 drapeau : Venezuela  ·  drapeau  ·  flag venezuela ve bolivarian republic flag nation country banner venezuela
🇻🇬 drapeau : Îles Vierges britanniques  ·  drapeau  ·  flag british virgin islands british virgin islands bvi flag nation country banner british virgin islands  drapeau : Iles Vierges britanniques
🇻🇮 drapeau : Îles Vierges des États-Unis  ·  drapeau  ·  flag u s virgin islands virgin islands us flag nation country banner u s virgin islands  drapeau : Iles Vierges des Etats-Unis
🇻🇳 drapeau : Viêt Nam  ·  drapeau  ·  flag vietnam viet nam flag nation country banner vietnam  drapeau : Viet Nam
🇻🇺 drapeau : Vanuatu  ·  drapeau  ·  flag vanuatu vu flag nation country banner vanuatu
🇼🇫 drapeau : Wallis-et-Futuna  ·  drapeau  ·  flag wallis futuna wallis futuna flag nation country banner wallis futuna
🇼🇸 drapeau : Samoa  ·  drapeau  ·  flag samoa ws flag nation country banner samoa
🇽🇰 drapeau : Kosovo  ·  drapeau  ·  flag kosovo xk flag nation country banner kosovo
🇾🇪 drapeau : Yémen  ·  drapeau  ·  flag yemen ye flag nation country banner yemen  drapeau : Yemen
🇾🇹 drapeau : Mayotte  ·  drapeau  ·  flag mayotte yt flag nation country banner mayotte
🇿🇦 drapeau : Afrique du Sud  ·  drapeau  ·  flag south africa south africa flag nation country banner south africa
🇿🇲 drapeau : Zambie  ·  drapeau  ·  flag zambia zm flag nation country banner zambia
🇿🇼 drapeau : Zimbabwe  ·  drapeau  ·  flag zimbabwe zw flag nation country banner zimbabwe
🏴󠁧󠁢󠁥󠁮󠁧󠁿 drapeau : Angleterre  ·  drapeau  ·  flag england flag english
🏴󠁧󠁢󠁳󠁣󠁴󠁿 drapeau : Écosse  ·  drapeau  ·  flag scotland flag scottish  drapeau : Ecosse
🏴󠁧󠁢󠁷󠁬󠁳󠁿 drapeau : Pays de Galles  ·  drapeau  ·  flag wales flag welsh
🥲 visage souriant avec une larme  ·  ému, fier, heureux, larme, reconnaissant, smiley, soulagé, souriant, touché  ·  smiling face with tear sad cry pretend  emu soulage touche
🥸 visage déguisé  ·  déguisement, espion, faux nez, grimer, incognito, lunettes, moustache, postiche, smiley, sourcils ébouriffés  ·  disguised face pretent brows glasses moustache  visage deguise deguisement sourcils ebouriffes
🤌 bout des doigts joints  ·  agacement, argumentation, doigts, geste, interrogation, main, parler avec les mains, patience, silence !  ·  pinched fingers size tiny small
🫀 cœur  ·  anatomie, battement de coeur, battements, cardiologie, organe, pouls, pulsation  ·  anatomical heart health heartbeat  coeur
🫁 poumons  ·  anatomie, expiration, inspiration, organe, respiration, respirer, souffle  ·  lungs breathe
🥷 ninja  ·  assassin, combat, furtif, guerrier, masqué, personne, sabre, secret, soldat  ·  ninja ninjutsu skills japanese  masque
🤵‍♂️ homme en smoking  ·  homme, smoking  ·  man in tuxedo formal fashion
🤵‍♀️ femme en smoking  ·  femme, smoking  ·  woman in tuxedo formal fashion
👰‍♂️ homme avec voile  ·  homme, voile  ·  man with veil wedding marriage
👰‍♀️ femme avec voile  ·  femme, voile  ·  woman with veil wedding marriage
👩‍🍼 femme allaitant un bébé  ·  allaitement, bébé, biberon, femme, maman, mère, nounou, nouveau-né, personne  ·  woman feeding baby birth food  femme allaitant un bebe bebe mere nouveau-ne
👨‍🍼 homme allaitant un bébé  ·  allaitement, bébé, biberon, homme, nouveau-né, papa, père, personne  ·  man feeding baby birth food  homme allaitant un bebe bebe nouveau-ne pere
🧑‍🍼 personne allaitant un bébé  ·  allaitement, bébé, biberon, homme, maman, mère, nounou, nouveau-né, papa, père, personne  ·  person feeding baby birth food  personne allaitant un bebe bebe mere nouveau-ne pere
🧑‍🎄 santa  ·  joyeux Noël, noël, Noël, Papa Noël, Père Noël, personne, Saint-Nicolas, Santa  ·  mx claus christmas  joyeux Noel noel Noel Papa Noel Pere Noel
🫂 étreinte  ·  accolade, amitié, au revoir, bonjour, câlin, embrassades, gratitude, merci, personne  ·  people hugging care  etreinte amitie calin
🐈‍⬛ chat noir  ·  animal, chat, chaton, félin, halloween, malchanceux, matou, miaou, noir, superstition  ·  black cat superstition luck  felin
🦬 bison  ·  animal, buffle, cornes, herbivore, nature, troupeau  ·  bison ox
🦣 mammouth  ·  animal, défenses, extinction, géant, grand, laineux  ·  mammoth elephant tusks  defenses geant
🦫 castor  ·  animal, barrage, dents, rongeur  ·  beaver animal rodent
🐻‍❄️ ours polaire  ·  arctique, blanc, ours  ·  polar bear animal arctic
🦤 dodo  ·  animal, Dronte, espèce éteinte, extinction, grand, Maurice, oiseau  ·  dodo animal bird  espece eteinte
🪶 plume  ·  écrire, écrivain, léger, oiseau, plumage, voler  ·  feather bird fly  ecrire ecrivain leger
🦭 phoque  ·  animal, lion de mer, océan, otarie  ·  seal animal creature sea  ocean
🪲 scarabée  ·  animal, insecte  ·  beetle insect  scarabee
🪳 cafard  ·  animal, blatte, coquerelle, insecte, nuisible  ·  cockroach insect pests
🪰 mouche  ·  animal, asticot, insecte, maladie, nuisible, pourrissement, puanteur, putréfaction, tsé-tsé  ·  fly insect  putrefaction tse-tse
🪱 lombric  ·  animal, annélide, insecte, parasite, ver, ver de terre  ·  worm animal  annelide
🪴 plante en pot  ·  décoration, ennuyeux, faire pousser, intérieur, nature, plante, pousser, prendre soin  ·  potted plant greenery house  decoration interieur
🫐 myrtilles  ·  airelles, baies, bleu, bleuets, fruit, nourriture, violet  ·  blueberries fruit
🫒 olive  ·  aliment, apéritif, apéro, nourriture, olivier, rameau  ·  olive fruit  aperitif apero
🫑 poivron  ·  légume, piment, poivron rouge, poivron vert  ·  bell pepper fruit plant  legume
🫓 galette  ·  arepa, gordita, lavash, naan, nourriture, pain plat, pita  ·  flatbread flour food
🫔 tamal  ·  mexicain, nourriture, pamonha, papillote  ·  tamale food masa
🫕 fondue  ·  bourguignonne, chocolat, fromage, plat, poêlon, savoyarde, ski, suisse, Suisse  ·  fondue cheese pot food  poelon
🫖 théière  ·  boisson, boisson chaude, infusion, thé  ·  teapot drink hot  theiere the
🧋 thé aux perles  ·  boba, boisson, bubble tea, bulle, lait, paille, perle, thé aux bulles, thé froid, zenzou  ·  bubble tea taiwan boba milk tea straw  the aux perles the aux bulles the froid
🪨 rocher  ·  caillou, dur, lourd, pierre, roc, roche, solide  ·  rock stone
🪵 bois  ·  arbre, bûche, bûcheron, rondins, tronc  ·  wood nature timber trunk  buche bucheron
🛖 hutte  ·  abri, case, maison, maisonnette, yourte  ·  hut house structure
🛻 pick-up  ·  auto, camion benne, camionnette, pickup, plateau, poids lourd, transports, véhicule  ·  pickup truck car transportation  vehicule
🛼 patin à roulettes  ·  derby, roller, roulette, roulettes, sport  ·  roller skate footwear sports  patin a roulettes
🪄 baguette magique  ·  abracadabra, magicien, magie, sorcier, sorcière, sort, tour de magie  ·  magic wand supernature power  sorciere
🪅 piñata  ·  5 mai, bonbons, cinco de mayo, confiseries, fête, mexicain  ·  pinata mexico candy celebration  pinata fete
🪆 poupées russes  ·  emboîté, empiler, jouet, matriochka, poupée gigogne, poupée russe, russe, russie  ·  nesting dolls matryoshka toy  poupees russes emboite poupee gigogne poupee russe
🪡 aiguille à coudre  ·  broderie, coudre, couture, fil à coudre, points, suture, tailleur  ·  sewing needle stitches  aiguille a coudre fil a coudre
🪢 nœud  ·  attacher, corde, entrelacer, lien, noué, tordre  ·  knot rope scout  noeud noue
🩴 tong  ·  claquettes, été, mer, plage, sandales, sandales de plage, tatanes, tongs  ·  thong sandal footwear summer  ete
🪖 casque militaire  ·  armée, casque, équipement, guerre, guerrier, militaire, protection, soldat  ·  military helmet army protection  armee equipement
🪗 accordéon  ·  bandonéon, concert, concertina, instrument, mélodie, musique, piano à bretelles  ·  accordion music  accordeon bandoneon melodie piano a bretelles
🪘 djembé  ·  battement, conga, instrument, musique, percussions, rythme, tambour  ·  long drum music  djembe
🪙 pièce  ·  argent, euro, fortune, métal, or, pièce de monnaie, riche, sou, trésor  ·  coin money currency  piece metal piece de monnaie tresor
🪃 boomerang  ·  aborigène, australie, jeu, outil, répercussion, retour  ·  boomerang weapon  aborigene repercussion
🪚 scie  ·  bois, outil, scie à bois, scie égoïne, scier  ·  carpentry saw cut chop  scie a bois scie egoine
🪛 tournevis  ·  outil, outillage, vis  ·  screwdriver tools
🪝 crochet  ·  accrocher, appâter, attraper, capitaine, ferrer, hameçon, hameçonner  ·  hook tools  appater hamecon hameconner
🪜 échelle  ·  ascension, barreau, échelon, escabeau, grimper, monter  ·  ladder tools  echelle echelon
🛗 ascenseur  ·  accessibilité, descente, monte-charge, monte-personnes, montée  ·  elevator lift  accessibilite montee
🪞 miroir  ·  beauté, glace, image, maquillage, psyché, reflet  ·  mirror reflection  beaute psyche
🪟 fenêtre  ·  air frais, cadre, carreaux, ouverture, transparent, vitre, vue  ·  window scenery  fenetre
🪠 ventouse  ·  bouché, déboucheur, dégorgement, outil, plombier, succion, toilettes  ·  plunger toilet  bouche deboucheur degorgement
🪤 tapette à souris  ·  apât, appât, fromage, leurre, piège, piège à souris, rat, tapette  ·  mouse trap cheese  tapette a souris apat appat piege piege a souris
🪣 seau  ·  conteneur, plage  ·  bucket water container
🪥 brosse à dents  ·  brosse, brosser les dents, dentaire, dents, hygiène, laver, laver les dents, salle de bain  ·  toothbrush hygiene dental  brosse a dents hygiene
🪦 pierre tombale  ·  cimetière, enterrement, funérailles, mémorial, mort, RIP, sépulture, stèle, tombe  ·  headstone death rip grave  cimetiere funerailles memorial sepulture stele
🪧 pancarte  ·  affiche, écriteau, grève, manifestation, panneau, protestation, signe  ·  placard announcement  ecriteau greve
⚧️ symbole de la communauté transgenre  ·  transgenre  ·  transgender symbol lgbtq  symbole de la communaute transgenre
🏳️‍⚧️ drapeau transgenre  ·  blanc, bleu clair, rose, transgenre  ·  transgender flag lgbtq
😶‍🌫️ visage dans les nuages  ·  brouillard, dans les nuages, distrait, visage dans le brouillard  ·  face in clouds shower steam dream
😮‍💨 visage expirant  ·  chuchoter, découragé, déçu, expiration, exténué, fatigué, siffler, souffler, soulagement, soupir, sursaut  ·  face exhaling relieve relief tired sigh  decourage decu extenue fatigue
😵‍💫 visage aux yeux en spirales  ·  confusion, étourdi, hagard, malade, nausée, ouh la la, tête qui tourne  ·  face with spiral eyes sick ill confused nauseous nausea  etourdi nausee tete qui tourne
❤️‍🔥 cœur enflammé  ·  amour, désir, feu, passion  ·  heart on fire passionate enthusiastic  coeur enflamme desir
❤️‍🩹 cœur avec bandages  ·  réconforter, réparer, soigner  ·  mending heart broken heart bandage wounded  coeur avec bandages reconforter reparer
🧔‍♂️ homme barbu  ·  barbe  ·  man beard facial hair
🧔‍♀️ femme barbue  ·  barbe  ·  woman beard facial hair
🫠 visage qui fond  ·  disparaître, fondre, gêne, liquéfié, liquide, sarcasme, se dissoudre  ·  melting face hot heat  disparaitre gene liquefie
🫢 visage avec yeux ouverts et main sur la bouche  ·  choqué, embarrassé, étonné, gêné, impressionné, stupéfait, surpris  ·  face with open eyes and hand over mouth silence secret shock surprise  choque embarrasse etonne gene impressionne stupefait
🫣 visage qui regarde entre ses doigts  ·  captivé, effrayé, fasciné, jeter un coup d’œil, regarder fixement, se cacher, timide  ·  face with peeking eye scared frightening embarrassing  captive effraye fascine jeter un coup d'oeil
🫡 visage qui fait un salut militaire  ·  armée, bonne chance, compris, OK, oui, respect, salut  ·  saluting face respect salute  armee
🫥 visage en pointillés  ·  déprimé, disparaître, introverti, invisible, se cacher  ·  dotted line face invisible lonely isolation depression  visage en pointilles deprime disparaitre
🫤 visage avec bouche en diagonale  ·  bof, confus, déçu, euh, frustration, incertain, sceptique  ·  face with diagonal mouth skeptic confuse frustrated indifferent  decu
🥹 visage retenant ses larmes  ·  admiration, ému, fierté, gratitude, larmes de joie, pleurs, retenir ses larmes, triste  ·  face holding back tears touched gratitude  emu fierte
🫱 main vers la droite  ·  droite, serrer la main, tenir la main, vers la droite  ·  rightwards hand palm offer
🫲 main vers la gauche  ·  gauche, serrer la main, tenir la main, vers la gauche  ·  leftwards hand palm offer
🫳 main paume vers le bas  ·  chasser, choisir, faire partir, laisser tomber, ouste, rejeter  ·  palm down hand palm drop
🫴 main paume vers le haut  ·  appeler de la main, attirer, faire venir, offre  ·  palm up hand lift offer demand
🫰 main avec index et pouce croisés  ·  amour, argent, cher, claquer des doigts, cœur  ·  hand with index finger and thumb crossed heart love money expensive  main avec index et pouce croises coeur
🫵 index pointant vers l’utilisateur  ·  pointer, toi  ·  index pointing at the viewer you recruit  index pointant vers l'utilisateur
🫶 mains qui forment un cœur  ·  amour, cœur  ·  heart hands love appreciation support  mains qui forment un coeur coeur
🫦 lèvres qui se mordent  ·  anxieux, flirt, inquiet, lèvre mordue, mal à l’aise, nerveux  ·  biting lip flirt sexy pain worry  levres qui se mordent levre mordue mal a l'aise
🫅 personne avec une couronne  ·  monarque, noble, royal, royauté  ·  person with crown royalty power  royaute
🫃 homme enceint  ·  enceinte, grossesse, homme enceinte, personne enceinte, trop mangé, ventre  ·  pregnant man baby belly  trop mange
🫄 personne enceinte  ·  enceinte, grossesse, trop mangé, ventre  ·  pregnant person baby belly  trop mange
🧌 troll  ·  conte de fées, légende, monstre, mythe, troller  ·  troll mystical monster  conte de fees legende
🪸 corail  ·  océan, réchauffement climatique, récif  ·  coral ocean sea reef  ocean rechauffement climatique recif
🪷 lotus  ·  beauté, bouddhisme, calme, fleur, hindouisme, pureté, sérénité  ·  lotus flower calm meditation  beaute purete serenite
🪹 nid vide  ·  branches, faire son nid, maison, nid  ·  empty nest bird
🪺 nid avec œufs  ·  branches, faire son nid, nid, oiseau  ·  nest with eggs bird  nid avec oeufs
🫘 haricots  ·  haricot rouge, légume, légumineuse, nourriture, petit, rognon  ·  beans food  legume legumineuse
🫗 verser un liquide  ·  accident, boisson, eau, oups, renverser, verre, verser, vider  ·  pouring liquid cup water
🫙 bocal  ·  condiments, conserver, pot, récipient, rien, sauce, vide  ·  jar container sauce  recipient
🛝 toboggan  ·  aire de jeu, glissade, jouer  ·  playground slide fun park
🛞 roue  ·  cercle, pneu, tourner, véhicule, voiture  ·  wheel car transport  vehicule
🛟 bouée de sauvetage  ·  flotter, sauver, sauveteur, secours, sécurité  ·  ring buoy life saver life preserver  bouee de sauvetage securite
🪬 main de Fatma  ·  amulette, chance, Fatma, hamsa, khamsa, Myriam, protection  ·  hamsa religion protection
🪩 boule à facettes  ·  briller, danse, disco, fête, soirée  ·  mirror ball disco dance party  boule a facettes fete soiree
🪫 pile faible  ·  batterie, batterie faible, déchargé, électronique, énergie faible  ·  low battery drained dead  decharge electronique energie faible
🩼 béquille  ·  accident, aide, blessé, boiter, canne, handicap  ·  crutch accessibility assist  bequille blesse
🩻 radiographie  ·  cage thoracique, docteur, médical, os, rayons X, squelette  ·  x-ray skeleton medicine  medical
🫧 bulles  ·  bulle, propre, savon, sous l’eau  ·  bubbles soap fun carbonation sparkling  sous l'eau
🪪 carte d’identité  ·  justificatif, papiers, permis de conduire, pièce d’identité, sécurité  ·  identification card document  carte d'identite piece d'identite securite
🟰 signe égal gras  ·  égal, égalité, mathématiques, réponse  ·  heavy equals sign math  signe egal gras egal egalite mathematiques reponse
EMOJI_DATA

# Order list by usage count (descending). Sorting is stable, so emojis
# that were never picked keep their original order at the bottom.
sorted="$(printf '%s\n' "$data" | awk -v uf="$usage_file" '
  BEGIN {
    # Usage file is "emoji<TAB>count"; the emoji list is space-separated
    while ((getline line < uf) > 0) {
      split(line, a, "\t")
      count[a[1]] = a[2]
    }
    close(uf)
  }
  NF { print (count[$1] + 0) "\t" $0 }
' | LC_ALL=C sort -s -k1,1nr | cut -f2-)"

# Increment the counter for a picked emoji. flock serializes the whole
# read -> increment -> rename sequence so two concurrent picks can't both
# read the same count and lose an update (the atomic rename alone only
# prevents a torn file, not a lost update). The lock is released by the
# kernel when the fd closes, even if the script dies.
bump_usage() {
  local emoji="$1" tmp
  mkdir -p "${usage_file%/*}"
  touch "$usage_file"
  {
    flock -x 9
    # Temp file next to the destination so mv is an atomic rename(2)
    # even when /tmp lives on a different filesystem (e.g. tmpfs)
    tmp="$(mktemp "${usage_file}.XXXXXX")"
    awk -v e="$emoji" '
      BEGIN { FS = "\t" }
      $1 == e { print $1 "\t" ($2 + 1); found = 1; next }
      { print }
      END { if (!found) print e "\t1" }
    ' "$usage_file" > "$tmp"
    mv "$tmp" "$usage_file"
  } 9>"${usage_file}.lock"
}

# Ask rofi for "<0-based row index><TAB><typed filter>". A real row is
# reported with index 0..N-1; a hand-typed custom entry with index -1
# (rofi passes UINT32_MAX through an int). Esc/cancel returns nothing.
output="$(printf '%s\n' "$sorted" | rofi -i -dmenu -format $'i\tf' -mesg "$msg" -config "$rofi_theme")"

if [ -n "$output" ]; then
  idx="${output%%$'\t'*}"
  filter="${output#*$'\t'}"
  line=""
  case "$idx" in
    ''|*[!0-9]*) ;; # -1 or malformed: custom entry, not a row
    *) line="$(printf '%s\n' "$sorted" | sed -n "$((idx + 1))p")" ;;
  esac

  if [ -n "$line" ]; then
    # Real row from the list: count the pick, then copy its emoji
    emoji="$(awk '{print $1}' <<< "$line")"
    bump_usage "$emoji"
    printf '%s' "$emoji" | wl-copy
  elif [ -n "$filter" ]; then
    # Hand-typed custom text: copy it (first word, as before) but
    # never track it, so the history only holds real list rows
    printf '%s' "$(awk '{print $1}' <<< "$filter")" | wl-copy
  fi
fi


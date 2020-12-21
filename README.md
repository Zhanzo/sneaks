# Sneaks
Godot-project, space-shooter med smygande fiender med mycket juciness och game
feel för PC. 

## Bullets
Innehåller basklassen Bullet vilken sköter skottens rörelse, att skotten
exploderar vid kontakt med spelare/fiender och väggar samt att de försvinner när
de försvinner utanför spelarens synfält.
Skillnaden mellan player_bullet och enemy_bullet är, förutom texturerna, att
spelarens skott endast kolliderar med fiender och väggar, medan fiendernas skott
endast kolliderar med spelaren och väggar. 

## Camera
Används för att kunna utföra screenshake då spelaren träffar fiender eller blir
träffad själv, samt för att sätta gränser på hur långt åt varje håll (höger, 
vänster, ner och upp) kameran får röra sig.

## Entities
Entity klassen är basklassen för spelare och fiender och samlar därmed de faktorer
som både spelare och fiender har. Exempel på detta är liv, skada och hur ofta
skotten får avlfyras.

### Player
Spelare klassen sköter animationer för rörelse samt för när spelaren blir träffad
av en fiendes skott, reaktioner på användarens input där WAD används för att styra
spelaren och mellanslag används för att skjuta. Om spelaren inte har träffats på
ett tag så återgenererar den sitt liv.

### Enemies
Samlar de två sorterna av fiender som finns, Cruiser och Stalker. Cruisers är de
synliga fienderna som jagar spelaren när den kommer nära samt letar efter spelaren
om den har setts. Om spelaren inte kan hittas återanvänder Cruisern till sin
startposition. Stalkers smälter in i miljön och rör sig lite långsammare. De 
försöker även hålla sig stationära så länge som spelaren är i deras sikte. Om
alla Cruisers i en nivå har blivit besegrade så blir de kvarvarande Stalkers 
synliga.

## Interface
Visar små menyer som overlays, GameOver visas när spelaren har dött och 
LevelComplete visas när alla fiender i nivån har besegrats.

## Levels
De olika nivåerna som finns i spelet. Level är basklassen som de andra nivåerna
byggs utifrån. Den ser till så att en grå overlay visas, samt gör spelet
långsammare och ljudet otydligare då spelaren har lågt med liv. Utöver detta visar
de en pil till närmaste fiende utifrån spelarens position, visar Stalkers när alla
Cruisers har besegrats samt sköter screenshake.

## Menus
Innehåller startmenyn och menyn för att välja nivåer. Menyn för att välja nivåer
visar endast de nivåer som har avklarats samt nivån efter det baserat på en
sparfil som innehåller vilka nivåer som har avklarats.

## Singletons
Filerna som laddas automatiskt när spelet körs. background_music ser till så att
musik spelas i bakgrunden och save_data sköter sparandet och laddandet av en
sparfil.
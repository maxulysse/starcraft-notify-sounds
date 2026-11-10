#!/usr/bin/env bash
# Download StarCraft unit voice clips from the StarCraft wiki into the
# orc-work-notify folders submit/, attention/ and stop/ under $SOUNDS_DIR (default ~/.claude/sounds).
set -euo pipefail

API=https://starcraft.fandom.com/api.php
# The wiki's file host returns 403 to browser user agents and to requests without a wiki referer.
UA=curl/8
REF=https://starcraft.fandom.com/
DEST="${SOUNDS_DIR:-$HOME/.claude/sounds}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# StarCraft 2 clips are not in race categories, so each race lists its units (file name prefixes).
SC2_Protoss="Adept Alarak Annihilator Arbiter Archon Artanis ArtanisVoid Ascendant Avenger Carrier CarrierVoid
  Colossus ColossusPurifier Corsair CorsairWoL DarkArchon DarkTemplar DarkTemplarVoid Destroyer DragoonVoid Energizer
  Fenix Havoc HighTemplar HighTemplarVoid Immortal ImmortalVoid Instigator Karass Karax Mirage Mohandar Mothership
  MothershipVoid Observer PhasePrism Phoenix PhoenixVoid Probe Reaver Scout Selendis Sentry ShadowHunter Stalker StalkerVoid
  StoneZealot TempestVoid Urun Vanguard VoidRay VoidRayVoid Vorazun Wrathwalker Zealot ZealotAlarak ZealotNerazim
  ZealotPurifier ZealotVoid Zeratul ZeratulVoid"
SC2_Terran="Banshee Battlecruiser Cyclone DavisHeroVO Diamondback Firebat Ghost Goliath Han Hellion Hercules Marauder
  Marine Medic Medivac Mule Nova Predator Raven Raynor Reaper ScienceVessel Scientist SCV SiegeTank Spectre Stetmann
  Swann TaurenSpaceMarine TerranFlyer Thor Tosh Trooper TrooperMengsk TychusHeroVO Viking Vulture Warbot WidowMine Wraith"
SC2_Zerg="Baneling Broodling BroodLord Changeling Corruptor Drone Egg Hydralisk InfestedTerran Infestor Larva Lurker
  Mutalisk NydusWorm"

USAGE="usage: $0 --<protoss|terran|zerg>-<sc1|sc2> ...  (e.g. --zerg-sc1 --protoss-sc2)"
JOBS=()
for ARG in "$@"; do
  case "$ARG" in
    --protoss-sc[12]) JOBS+=("Protoss ${ARG##*-}") ;;
    --terran-sc[12]) JOBS+=("Terran ${ARG##*-}") ;;
    --zerg-sc[12]) JOBS+=("Zerg ${ARG##*-}") ;;
    *) echo "$USAGE" >&2; exit 1 ;;
  esac
done
(( ${#JOBS[@]} )) || { echo "$USAGE" >&2; exit 1; }

# Reads "<url> <name>" lines; saves each clip as <event>/<name>.wav, picking the event from the clip type.
save() {
  awk '{ print $1, tolower($2) }' | while read -r URL NAME; do
    [[ "$NAME" =~ (yes|attack|what|help|ready)[0-9]*$ ]] || continue
    case "${BASH_REMATCH[1]}" in yes|attack) EVENT=submit ;; what|help) EVENT=attention ;; *) EVENT=stop ;; esac
    OUT="$DEST/$EVENT/$NAME.wav"
    [[ -f "$OUT" ]] && continue
    # Convert to .part first: an interrupted run must not leave a cut-off .wav that later runs skip.
    if curl -sSfL -A "$UA" -e "$REF" -o "$TMP/clip.ogg" "$URL" && mkdir -p "$DEST/$EVENT" &&
      ffmpeg -loglevel error -y -i "$TMP/clip.ogg" -f wav "$OUT.part" </dev/null; then
      mv "$OUT.part" "$OUT"
      echo "$EVENT/${OUT##*/}"
    else
      echo "failed: $NAME" >&2
    fi
  done
}

for JOB in "${JOBS[@]}"; do
  RACE="${JOB% *}"
  if [[ "$JOB" == *sc1 ]]; then
    # shortcut: no paging, categories hold <500 files (Terran 383 in 2026-11); add gcmcontinue past that.
    curl -sSfL -A "$UA" "$API?action=query&generator=categorymembers&gcmtitle=Category:StarCraft_${RACE}_unit_sounds&gcmlimit=500&prop=imageinfo&iiprop=url&format=json" |
      grep -oE "\"url\":\"[^\"]+/${RACE}[A-Za-z]+(Yes|What|Ready)[0-9]+SC1\.ogg[^\"]*" | cut -d'"' -f4 | sort -u |
      sed -E "s#(.*/${RACE}([A-Za-z]+[0-9]+)SC1\.ogg.*)#\1 sc1-\2#" | save   # e.g. sc1-ZerglingYes00
    continue
  fi
  UNITS="SC2_$RACE"
  for UNIT in ${!UNITS}; do
    curl -sSfL -A "$UA" "$API?action=query&list=allimages&aiprefix=${UNIT}_&aiprop=url&ailimit=500&format=json" |
      grep -oE "\"url\":\"[^\"]+/${UNIT}_(Yes|What|Ready|Help|Attack)[0-9]*\.ogg[^\"]*" | cut -d'"' -f4 |
      sed -E "s#(.*/${UNIT}_([A-Za-z]+[0-9]*)\.ogg.*)#\1 sc2-${UNIT}\2#" | save || echo "no clips: $UNIT" >&2   # e.g. sc2-MarineYes00
  done
done

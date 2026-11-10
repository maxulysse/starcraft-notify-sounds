#!/usr/bin/env bash
# Download StarCraft 1 Yes/What/Ready clips from the StarCraft wiki into the
# orc-work-notify folders submit/, attention/ and stop/ under $SOUNDS_DIR (default ~/.claude/sounds).
set -euo pipefail

API=https://starcraft.fandom.com/api.php
# The wiki's file host returns 403 to browser user agents and to requests without a wiki referer.
UA=curl/8
REF=https://starcraft.fandom.com/
DEST="${SOUNDS_DIR:-$HOME/.claude/sounds}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

USAGE="usage: $0 [-p|--protoss] [-t|--terran] [-z|--zerg]"
RACES=()
for ARG in "$@"; do
  case "$ARG" in
    --protoss) RACES+=(Protoss) ;;
    --terran) RACES+=(Terran) ;;
    --zerg) RACES+=(Zerg) ;;
    -?*) # short options, also combined: -ptz
      for (( I = 1; I < ${#ARG}; I++ )); do
        case "${ARG:I:1}" in
          p) RACES+=(Protoss) ;;
          t) RACES+=(Terran) ;;
          z) RACES+=(Zerg) ;;
          *) echo "$USAGE" >&2; exit 1 ;;
        esac
      done ;;
    *) echo "$USAGE" >&2; exit 1 ;;
  esac
done
(( ${#RACES[@]} )) || { echo "$USAGE" >&2; exit 1; }

for RACE in "${RACES[@]}"; do
  # shortcut: no paging, categories hold <500 files (Terran 383 in 2026-11); add gcmcontinue past that.
  curl -sSfL -A "$UA" "$API?action=query&generator=categorymembers&gcmtitle=Category:StarCraft_${RACE}_unit_sounds&gcmlimit=500&prop=imageinfo&iiprop=url&format=json" |
    grep -oE "\"url\":\"[^\"]+/${RACE}[A-Za-z]+(Yes|What|Ready)[0-9]+SC1\.ogg[^\"]*" | cut -d'"' -f4 | sed 's#\\/#/#g' | sort -u |
    while read -r URL; do
      NAME="${URL%%SC1.ogg*}"; NAME="${NAME##*/$RACE}"   # e.g. ZerglingYes00
      case "$NAME" in *Yes*) EVENT=submit ;; *What*) EVENT=attention ;; *) EVENT=stop ;; esac
      OUT="$DEST/$EVENT/${NAME,,}.wav"
      [[ -f "$OUT" ]] && continue
      if curl -sSfL -A "$UA" -e "$REF" -o "$TMP/clip.ogg" "$URL"; then
        mkdir -p "$DEST/$EVENT"
        ffmpeg -loglevel error -y -i "$TMP/clip.ogg" "$OUT" </dev/null && echo "$EVENT/${OUT##*/}"
      else
        echo "failed: $NAME" >&2
      fi
    done
done

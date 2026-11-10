#!/usr/bin/env bash
# Download StarCraft 1 Yes/What/Ready clips from the StarCraft wiki into the
# orc-work-notify folders submit/, attention/ and stop/ under $SOUNDS_DIR (default ~/.claude/sounds).
set -euo pipefail

API=https://starcraft.fandom.com/api.php
# The wiki's file host returns 403 to browser user agents and to requests without a wiki referer.
UA="${UA:-curl/8}"
REF=https://starcraft.fandom.com/
DEST="${SOUNDS_DIR:-$HOME/.claude/sounds}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

USAGE="usage: $0 [-p|--protoss] [-t|--terran] [-z|--zerg]"
RACES=()
for ARG in "$@"; do
  case "$ARG" in
    -p|--protoss) RACES+=(Protoss) ;;
    -t|--terran) RACES+=(Terran) ;;
    -z|--zerg) RACES+=(Zerg) ;;
    *) echo "$USAGE" >&2; exit 1 ;;
  esac
done
(( ${#RACES[@]} )) || { echo "$USAGE" >&2; exit 1; }

for RACE in "${RACES[@]}"; do
  curl -sfL -A "$UA" "$API?action=query&list=categorymembers&cmtitle=Category:StarCraft_${RACE}_unit_sounds&cmlimit=500&format=json" |
    grep -oE "File:${RACE}[A-Za-z]+(Yes|What|Ready)[0-9]+SC1\.ogg" | sort -u |
    while read -r TITLE; do
      NAME="${TITLE#File:$RACE}"; NAME="${NAME%SC1.ogg}"   # e.g. ZerglingYes00
      case "$NAME" in *Yes*) EVENT=submit ;; *What*) EVENT=attention ;; *) EVENT=stop ;; esac
      OUT="$DEST/$EVENT/$(tr 'A-Z' 'a-z' <<<"$NAME").wav"
      [[ -f "$OUT" ]] && continue
      URL=$(curl -sfL -A "$UA" "$API?action=query&titles=$TITLE&prop=imageinfo&iiprop=url&format=json" |
        grep -oE '"url":"[^"]+' | cut -d'"' -f4 | sed 's#\\/#/#g')
      if [[ -n "$URL" ]] && curl -sfL -A "$UA" -e "$REF" -o "$TMP/clip.ogg" "$URL"; then
        mkdir -p "$DEST/$EVENT"
        ffmpeg -loglevel error -y -i "$TMP/clip.ogg" "$OUT" </dev/null && echo "$EVENT/${OUT##*/}"
      else
        echo "failed: $TITLE" >&2
      fi
    done
done

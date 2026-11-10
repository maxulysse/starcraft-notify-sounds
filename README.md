# starcraft-notify-sounds

Download StarCraft 1 unit voice lines from the [StarCraft wiki](https://starcraft.fandom.com/) as sounds for the Claude Code plugin [orc-work-notify](https://github.com/vagkaratzas/orc-work-notify).

## Usage

Needs `bash`, `curl` and `ffmpeg`.

```bash
./fetch-starcraft.sh -p -t -z
```

| Option            | Race    |
| ----------------- | ------- |
| `-p`, `--protoss` | Protoss |
| `-t`, `--terran`  | Terran  |
| `-z`, `--zerg`    | Zerg    |

Clips are saved as `.wav` in `~/.claude/sounds`, or in `$SOUNDS_DIR` if set:

| Clip    | Folder       | Event                       |
| ------- | ------------ | --------------------------- |
| `Yes`   | `submit/`    | prompt sent                 |
| `What`  | `attention/` | Claude waits for your input |
| `Ready` | `stop/`      | Claude finishes             |

orc-work-notify plays a random clip from the folder on each event.
Existing clips are skipped.
Heroes and some buildings are included; delete unwanted ones, e.g. `rm ~/.claude/sounds/*/infested*`.

## Legal

This repository contains no audio.
StarCraft sounds are © Blizzard Entertainment; use them for personal use only.

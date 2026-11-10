# starcraft-notify-sounds

Download StarCraft 1 and 2 unit voice lines from the [StarCraft wiki](https://starcraft.fandom.com/) as sounds for the Claude Code plugin [orc-work-notify](https://github.com/vagkaratzas/orc-work-notify).

## Usage

Needs `bash`, `curl` and `ffmpeg`.

```bash
./fetch-starcraft.sh --zerg-sc1 --protoss-sc2
```

Pick any of `--protoss-sc1`, `--terran-sc1`, `--zerg-sc1`, `--protoss-sc2`, `--terran-sc2` and `--zerg-sc2`.

Clips are saved as `.wav` in `~/.claude/sounds`, or in `$SOUNDS_DIR` if set:

| Clip                  | Folder       | Event                       |
| --------------------- | ------------ | --------------------------- |
| `Yes`, `Attack` (SC2) | `submit/`    | prompt sent                 |
| `What`, `Help` (SC2)  | `attention/` | Claude waits for your input |
| `Ready`               | `stop/`      | Claude finishes             |

orc-work-notify plays a random clip from the folder on each event.
Clips are named `sc1-<unit><clip>.wav` or `sc2-<unit><clip>.wav`. Existing clips are skipped.
Heroes and some buildings are included; delete unwanted ones, e.g. `rm ~/.claude/sounds/*/sc1-infested*`.

## Legal

This repository contains no audio.
StarCraft sounds are © Blizzard Entertainment; use them for personal use only.

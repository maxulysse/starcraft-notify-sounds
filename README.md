# starcraft-notify-sounds

Fetch StarCraft 1 unit voice lines from the [StarCraft wiki](https://starcraft.fandom.com/) as notification sounds for [orc-work-notify](https://github.com/vagkaratzas/orc-work-notify), the Claude Code sound plugin.

Each unit line goes to the folder for the matching event:

| Clip    | Folder       | Plays when                   |
| ------- | ------------ | ---------------------------- |
| `Yes`   | `submit/`    | you send a prompt            |
| `What`  | `attention/` | Claude needs your input      |
| `Ready` | `stop/`      | Claude finishes              |

orc-work-notify plays a random `.wav` from the folder on each event.

## Usage

Needs `bash`, `curl` and `ffmpeg`.

```bash
./fetch-starcraft.sh -p          # Protoss
./fetch-starcraft.sh -t -z       # Terran and Zerg
./fetch-starcraft.sh -p -t -z    # all three
```

| Option             | Race    |
| ------------------ | ------- |
| `-p`, `--protoss`  | Protoss |
| `-t`, `--terran`   | Terran  |
| `-z`, `--zerg`     | Zerg    |

Clips go to `~/.claude/sounds/{submit,attention,stop}/`, named like `zerglingyes00.wav`.
Set `SOUNDS_DIR` to write somewhere else, e.g. `<project>/.claude/sounds` for one project only.
Clips already there are skipped, so the script is safe to re-run.

The wiki also files campaign heroes (Artanis, Infested Kerrigan, ...) and some buildings under unit sounds, so those come along.
Delete what you don't want, e.g. `rm ~/.claude/sounds/*/infested*`.

## Legal

This repository holds only the download script, no audio.
StarCraft and its sounds are © Blizzard Entertainment. Use the clips for personal use only.

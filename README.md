# pomo.sh

A simple command-line pomodoro app.

![demo][demo]

## Motivation

- Monospaced fonts like [FiraCode][firacode] and [MonoLisa][monolisa] :heart: have recently added progress-bar glyphs. (So, I wrote a quick & dirty script to try them out. 😄)

## Dependencies

- Monospaced fonts with progress-bar glyphs support. (Here's a list of some monospaced fonts in alphabetical order)

    |                                              |                             |
    | -------------------------------------------- | --------------------------- |
    | [Fira Code][firacode] (`v6+`)                | Free (open-source)          |
    | [Iosevka][iosevka] (`v11.2+`)                | Free (open-source)          |
    | [MonoLisa][monolisa] (`prerelease v2.001+`) | paid (free trial available) |

- notify-send (optional) - for sending desktop notifications

## Install instructions

- Copy `pomo.sh` file somewhere in your `$PATH`, and make it executable. (I keep the script in `~/.local/bin`)

    for example:

    ```sh
    wget https://raw.githubusercontent.com/krish-r/pomo.sh/main/pomo.sh -O ~/.local/bin/pomo.sh

    # adds executable permission to user
    chmod u+x ~/.local/bin/pomo.sh
    ```

## Uninstall instructions

- Simply remove the script from your path.

    for example:

    ```sh
    rm -i $(which pomo.sh)
    ```

## Options

![screenshot][screenshot]

```sh
# (15 minutes timer, 0 mins break) x 1 session
pomo.sh

# (15 minutes timer, 5 mins break) x 3 sessions
pomo.sh -b 5 -s 3

# (10 minutes timer, 5 mins break) x 2 sessions
pomo.sh -t 10 -b 5 -s 2 -n "test pomodoro"
```

[screenshot]: https://user-images.githubusercontent.com/54745129/204151412-cb4ad5be-74b7-4e9f-b804-9ea8418db317.png
[demo]: https://user-images.githubusercontent.com/54745129/204151236-e87048f4-ccd5-4471-92f0-d6cda0e8b86c.gif
[firacode]: https://github.com/tonsky/FiraCode/
[monolisa]: https://www.monolisa.dev/
[iosevka]: https://github.com/be5invis/Iosevka/

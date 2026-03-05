# Notes-Manager
Simple manager for notes on my website

The code is clunky and made to work, not be efficient. It's also tailored to my file organization, so probably not useful for anyone else. But you're welcome to copy if it's helpful.

Features:

- `help`: print documentation
- `open`: open project (options for: pdf, book pdf, vscode)
- `new`: register new project
- `edit`: edit existing project details
- `delete`: delete project
- `commit`: update project pdf to my local site and commit to github
- `clear`: clear screen

---

<img src="/notes_manager_example.png" width="500" />

I developed the look for <a href="https://cmder.app/">cmder</a> (a ConEmu wrapper) with the <a href="https://github.com/PandaTheme/Panda-Theme-Cmder">Panda theme</a>. An icon to launch `main.sh` was pinned to my taskbar by creating a new desktop shortcut with target `C:\Users\user\cmder\vendor\conemu-maximus5\ConEmu.exe -run cmd /k "bash main.sh"`. The folder should be set to the one `main.sh` is in.

When committing, files are first copied to my local website folder, specifically in `data/documents/`. Then these are committed and pushed to <a href="https://github.com/gyang0/gyang0.github.io">my site on GitHub</a>. I mostly made this because I was tired of updating files individually. Hopefully, it'll be useful later, since I'm planning to add more readings/notes to my site.

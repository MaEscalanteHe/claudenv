# claudenv

Fish plugin to manage multiple Claude CLI accounts.

## Requirements

- [Fish shell](https://fishshell.com/)
- [Fisher](https://github.com/jorgebucaran/fisher)
- [fzf](https://github.com/junegunn/fzf)

## Installation

```fish
fisher install MaEscalanteHe/claudenv
```

## How it works

The plugin manages Claude configurations in `~/.claude-accounts/`:

```
~/.claude-accounts/
├── personal/     # Config for personal account
├── work/         # Config for work account
└── .current      # Tracks active account
```

Each directory becomes a `CLAUDE_CONFIG_DIR` with separate auth, settings, and history.

## Commands

| Command            | Description                        |
| ------------------ | ---------------------------------- |
| `claudenv`         | Interactive account selector (fzf) |
| `claudenv switch`  | Same as above                      |
| `claudenv add`     | Add a new account                  |
| `claudenv list`    | List all accounts                  |
| `claudenv current` | Print active account name          |
| `claudenv remove`  | Remove an account                  |
| `claudenv help`    | Show help                          |

## First time setup

```fish
claudenv          # Creates 'personal' by default
claude            # Authenticate
claudenv add work # Add more accounts as needed
```

## Prompt integration

```fish
function fish_prompt
    if set -q CLAUDE_CONFIG_DIR
        echo -n "["(claudenv current)"] "
    end
    # ...
end
```

## License

MIT

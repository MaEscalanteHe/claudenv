### Subcommands
complete -c claudenv -f -n "__fish_use_subcommand" -a "switch" -d "Switch between accounts (default)"
complete -c claudenv -f -n "__fish_use_subcommand" -a "add" -d "Add a new account"
complete -c claudenv -f -n "__fish_use_subcommand" -a "list" -d "List all accounts"
complete -c claudenv -f -n "__fish_use_subcommand" -a "ls" -d "List all accounts"
complete -c claudenv -f -n "__fish_use_subcommand" -a "current" -d "Show active account"
complete -c claudenv -f -n "__fish_use_subcommand" -a "remove" -d "Remove an account"
complete -c claudenv -f -n "__fish_use_subcommand" -a "rm" -d "Remove an account"
complete -c claudenv -f -n "__fish_use_subcommand" -a "help" -d "Show help"

### Dynamic completions for specific subcommands
complete -c claudenv -f -n "__fish_seen_subcommand_from add" -a "(__claudenv_accounts)" -d "Existing account"
complete -c claudenv -f -n "__fish_seen_subcommand_from switch" -a "(__claudenv_accounts)" -d "Account"

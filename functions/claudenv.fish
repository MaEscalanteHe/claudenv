function claudenv -d "Manage multiple Claude CLI accounts"
    set -l base_dir $HOME/.claude-accounts
    set -l current_file $base_dir/.current
    set -l subcommand $argv[1]

    # Default to switch if no subcommand
    if test -z "$subcommand"
        set subcommand switch
    end

    switch $subcommand
        case switch
            __claudenv_switch
        case add
            __claudenv_add $argv[2]
        case list ls
            __claudenv_list
        case current
            __claudenv_current
        case remove rm
            __claudenv_remove
        case help -h --help
            __claudenv_help
        case '*'
            set_color red
            echo "Error: Unknown subcommand '$subcommand'"
            set_color normal
            echo ""
            __claudenv_help
            return 1
    end
end

function __claudenv_switch
    if not command -q fzf
        set_color red
        echo "Error: fzf is required but not installed."
        set_color normal
        echo "Install it from: https://github.com/junegunn/fzf"
        return 1
    end

    set -l base_dir $HOME/.claude-accounts
    set -l current_file $base_dir/.current

    if not test -d $base_dir
        mkdir -p $base_dir
    end

    set -l accounts (find $base_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

    if test (count $accounts) -eq 0
        set_color yellow
        echo "No accounts found. Creating 'personal' as default..."
        set_color normal
        mkdir -p $base_dir/personal
        set accounts personal
    end

    set -l current ""
    if test -f $current_file
        set current (cat $current_file | string trim)
    end

    set -l fzf_input
    for account in $accounts
        if test "$account" = "$current"
            set -a fzf_input "$account <- current"
        else
            set -a fzf_input "$account"
        end
    end
    set -a fzf_input "+ Add new account"

    set -l selection (printf '%s\n' $fzf_input | fzf --height=40% --reverse --prompt="Select Claude account: ")

    if test -z "$selection"
        set_color yellow
        echo "Cancelled."
        set_color normal
        return 1
    end

    if string match -q "+*" "$selection"
        read -P "Enter new account name: " new_account
        
        if test -z "$new_account"
            set_color red
            echo "Error: Account name cannot be empty."
            set_color normal
            return 1
        end

        if not string match -qr '^[a-zA-Z0-9_-]+$' "$new_account"
            set_color red
            echo "Error: Invalid name. Use only letters, numbers, hyphens and underscores."
            set_color normal
            return 1
        end

        if test -d $base_dir/$new_account
            set_color red
            echo "Error: Account '$new_account' already exists."
            set_color normal
            return 1
        end

        mkdir -p $base_dir/$new_account
        set_color green
        echo "Created account: $new_account"
        set_color normal
        set selection $new_account
    else
        set selection (echo $selection | string replace " <- current" "")
    end

    echo $selection > $current_file
    set -Ux CLAUDE_CONFIG_DIR $base_dir/$selection

    set_color green
    echo "Switched to: $selection"
    set_color normal
    echo "CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR"
end

function __claudenv_add
    set -l base_dir $HOME/.claude-accounts

    if not test -d $base_dir
        mkdir -p $base_dir
    end

    set -l account_name $argv[1]

    if test -z "$account_name"
        read -P "Enter new account name: " account_name
    end

    if test -z "$account_name"
        set_color red
        echo "Error: Account name cannot be empty."
        set_color normal
        return 1
    end

    if not string match -qr '^[a-zA-Z0-9_-]+$' "$account_name"
        set_color red
        echo "Error: Invalid name. Use only letters, numbers, hyphens and underscores."
        set_color normal
        return 1
    end

    if test -d $base_dir/$account_name
        set_color red
        echo "Error: Account '$account_name' already exists."
        set_color normal
        return 1
    end

    mkdir -p $base_dir/$account_name
    set_color green
    echo "Created account: $account_name"
    set_color normal
    echo ""
    echo "Run 'claudenv switch' to switch to this account."
end

function __claudenv_list
    set -l base_dir $HOME/.claude-accounts
    set -l current_file $base_dir/.current

    if not test -d $base_dir
        set_color yellow
        echo "No accounts directory found. Run 'claudenv' to create one."
        set_color normal
        return 1
    end

    set -l accounts (find $base_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

    if test (count $accounts) -eq 0
        set_color yellow
        echo "No accounts found. Run 'claudenv' to create one."
        set_color normal
        return 1
    end

    set -l current ""
    if test -f $current_file
        set current (cat $current_file | string trim)
    end

    echo "Claude accounts:"
    echo ""
    for account in $accounts
        if test "$account" = "$current"
            set_color green
            echo "  * $account (active)"
            set_color normal
        else
            echo "    $account"
        end
    end
    echo ""
    echo "Config dir: $CLAUDE_CONFIG_DIR"
end

function __claudenv_current
    set -l current_file $HOME/.claude-accounts/.current

    if not test -f $current_file
        set_color yellow
        echo "No account selected. Run 'claudenv' to select one."
        set_color normal
        return 1
    end

    cat $current_file | string trim
end

function __claudenv_remove
    if not command -q fzf
        set_color red
        echo "Error: fzf is required but not installed."
        set_color normal
        echo "Install it from: https://github.com/junegunn/fzf"
        return 1
    end

    set -l base_dir $HOME/.claude-accounts
    set -l current_file $base_dir/.current

    if not test -d $base_dir
        set_color yellow
        echo "No accounts directory found."
        set_color normal
        return 1
    end

    set -l accounts (find $base_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort)

    if test (count $accounts) -eq 0
        set_color yellow
        echo "No accounts to remove."
        set_color normal
        return 1
    end

    set -l selection (printf '%s\n' $accounts | fzf --height=40% --reverse --prompt="Select account to remove: ")

    if test -z "$selection"
        set_color yellow
        echo "Cancelled."
        set_color normal
        return 1
    end

    read -P "Remove '$selection' and all its data? [y/N] " confirm

    if not string match -qir '^y' "$confirm"
        set_color yellow
        echo "Cancelled."
        set_color normal
        return 1
    end

    rm -rf $base_dir/$selection

    if test -f $current_file
        if test (cat $current_file | string trim) = "$selection"
            rm $current_file
            set -e CLAUDE_CONFIG_DIR
            set_color green
            echo "Removed active account. Run 'claudenv' to select another."
            set_color normal
            return 0
        end
    end

    set_color green
    echo "Removed: $selection"
    set_color normal
end

function __claudenv_help
    echo "Usage: claudenv [command]"
    echo ""
    echo "Commands:"
    echo "  switch      Switch between accounts (default, uses fzf)"
    echo "  add [name]  Add a new account"
    echo "  list, ls    List all accounts"
    echo "  current     Show active account"
    echo "  remove, rm  Remove an account"
    echo "  help        Show this help"
    echo ""
    echo "Examples:"
    echo "  claudenv              # Interactive switch (fzf)"
    echo "  claudenv add work     # Create 'work' account"
    echo "  claudenv list         # List accounts"
end

### Helper function for completions
function __claudenv_accounts
    set -l base_dir $HOME/.claude-accounts
    if test -d $base_dir
        find $base_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \; 2>/dev/null | sort
    end
end

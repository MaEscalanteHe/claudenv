### Restore last used Claude account on shell start
set -l _ce_base $HOME/.claude-accounts
set -l _ce_current_file $_ce_base/.current

if test -f $_ce_current_file
    set -l _ce_saved (cat $_ce_current_file | string trim)
    if test -d $_ce_base/$_ce_saved
        set -gx CLAUDE_CONFIG_DIR $_ce_base/$_ce_saved
    end
end

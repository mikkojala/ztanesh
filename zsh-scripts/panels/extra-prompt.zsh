# Extra Prompt panel
# Calls user-defined extra_prompt_panel function if it exists

function setup_extra_prompt_panel {
    if typeset -f extra_prompt_panel > /dev/null
    then
        local extra="$(extra_prompt_panel)"
        if [[ -n "$extra" ]]
        then
            PROMPT="$extra$PROMPT"
        fi
    fi
}
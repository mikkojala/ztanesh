# Python Virtual Environment prompt panel
# Shows active virtualenv and warns about unset venvs

function setup_virtualenv_panel {
    # Check if dependency function exists, degrade gracefully if not
    if ! typeset -f check_unset_venv > /dev/null; then
        # Simplified mode - just show active venv if exists
        if [[ "$VIRTUAL_ENV" != "" ]]; then
            local envname=$(basename "$VIRTUAL_ENV")
            PROMPT=$(echo -ne "%{\033[1;36m%}[%{\033[1;34m%}$envname%{\033[36m%}]%{\033[0m%}")"$PROMPT"
        fi
        return 0
    fi

    # Original logic with full dependency available
    # Check that if we are in a Python virtualenv folder
    # but virtualenv is not activated
    local proposed_virtual_env=$(check_unset_venv)
    local proposed_envname=$(basename "$proposed_virtual_env")

    if [[ "$VIRTUAL_ENV" != "" ]]
    then
        local envname=$(basename "$VIRTUAL_ENV")

        if [[ "$proposed_virtual_env" != "" && "$proposed_virtual_env" != "$VIRTUAL_ENV" ]]
        then
            PROMPT=$(echo -ne "%{\033[1;33m%}[%{\033[0;31;43m%}$proposed_envname%{\033[0;33;1m%}]%{\033[0m%}")"$PROMPT"
        fi

        PROMPT=$(echo -ne "%{\033[1;36m%}[%{\033[1;34m%}$envname%{\033[36m%}]%{\033[0m%}")"$PROMPT"
    else
        if [[ "$proposed_envname" != "" ]]
        then
            PROMPT=$(echo -ne "%{\033[1;31m%}[%{\033[0;30;41;5m%}$proposed_envname%{\033[0;31;1m%}]%{\033[0m%}")"$PROMPT"
        fi
    fi
}
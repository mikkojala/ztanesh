# Modular Prompt Panel System
# Allows loading and configuring prompt features from a panels directory

# Configuration array for enabled panels (set this before sourcing)
# Example: ZTANESH_ENABLED_PANELS=(aws virtualenv wireguard-kube server-status)
if [[ -z "$ZTANESH_ENABLED_PANELS" ]]; then
    typeset -a ZTANESH_ENABLED_PANELS
    ZTANESH_ENABLED_PANELS=()
fi

# Panel directory path
ZTANESH_PANELS_DIR="${0:A:h}/../panels"

# Array to store panel functions for ordered execution
typeset -a _ztanesh_panel_functions
_ztanesh_panel_functions=()

# Load and register a panel
function _load_panel() {
    local panel_name="$1"
    local panel_file="$ZTANESH_PANELS_DIR/${panel_name}.zsh"
    
    if [[ -f "$panel_file" ]]; then
        source "$panel_file"
        # Check if panel provides a setup function
        if typeset -f "setup_${panel_name//-/_}_panel" > /dev/null; then
            _ztanesh_panel_functions+=("setup_${panel_name//-/_}_panel")
        fi
        return 0
    else
        echo "Warning: Panel '$panel_name' not found at $panel_file" >&2
        return 1
    fi
}

# Initialize panel system
function init_prompt_panels() {
    # Clear previous panel functions
    _ztanesh_panel_functions=()
    
    # Load enabled panels in order
    for panel in "${ZTANESH_ENABLED_PANELS[@]}"; do
        _load_panel "$panel"
    done
}

# Execute all loaded panels
function setup_prompt_panels() {
    for panel_func in "${_ztanesh_panel_functions[@]}"; do
        if typeset -f "$panel_func" > /dev/null; then
            "$panel_func"
        fi
    done
}

# List available panels
function list_available_panels() {
    if [[ -d "$ZTANESH_PANELS_DIR" ]]; then
        for panel_file in "$ZTANESH_PANELS_DIR"/*.zsh; do
            [[ -f "$panel_file" ]] && basename "$panel_file" .zsh
        done
    fi
}

# Show panel status
function show_panel_status() {
    echo "Enabled panels: ${ZTANESH_ENABLED_PANELS[*]}"
    echo ""
    echo "Available panels:"
    list_available_panels | while read panel; do
        if [[ " ${ZTANESH_ENABLED_PANELS[*]} " =~ " ${panel} " ]]; then
            echo "  ✓ $panel"
        else
            echo "    $panel"
        fi
    done
}
# Ztanesh Modular Prompt Panels

This directory contains modular prompt panels that can be enabled/disabled individually to customize your prompt appearance.

## Available Panels

- **aws.zsh**: Shows current AWS profile when `$AWS_PROFILE` is set
- **server-status.zsh**: Shows server status from `/etc/server-status` file
- **virtualenv.zsh**: Shows Python virtual environment status and warnings
- **extra-prompt.zsh**: Calls user-defined `extra_prompt_panel` function

## Configuration

Edit the panel configuration file to customize which panels are enabled:

- Default: `~/tools/zsh-scripts/config/panel-config.zsh`
- Or use CLI: `ztanesh-panels config`

Example configuration:

```bash
ZTANESH_ENABLED_PANELS=(
    server-status
    aws
    virtualenv
    extra-prompt
)
```

**Order matters**: Panels are processed left-to-right but appear right-to-left in the prompt.

## Management

Use the `ztanesh-panels` command to manage panels:

```bash
# List all available panels
ztanesh-panels list

# Show status of all panels
ztanesh-panels status

# Edit configuration
ztanesh-panels config
```

## Creating Custom Panels

1. Create a new `.zsh` file in this directory
2. Implement a function named `setup_<panel_name>_panel` (replace hyphens with underscores)
3. The function should modify the `$PROMPT` variable as needed
4. Add your panel name to `ZTANESH_ENABLED_PANELS` in the config file

### Example Panel

```bash
# panels/example.zsh
function setup_example_panel {
    if [[ "$SOME_ENV_VAR" != "" ]]; then
        PROMPT=$(echo -ne "%{\033[1;32m%}[$SOME_ENV_VAR]%{\033[0m%}")"$PROMPT"
    fi
}
```

Then add `example` to your enabled panels list.

## Panel Function Naming

Panel filenames are converted to function names by:
1. Removing the `.zsh` extension
2. Replacing hyphens with underscores
3. Prefixing with `setup_` and suffixing with `_panel`

Examples:
- `server-status.zsh` → `setup_server_status_panel`
- `my-custom-panel.zsh` → `setup_my_custom_panel_panel`

# Ztanesh Prompt Panel Configuration
# Customize which panels are enabled and their order

# Available panels:
# - server-status: Shows server status from /etc/server-status
# - aws: Shows AWS profile when set
# - virtualenv: Shows Python virtual environment status
# - extra-prompt: Calls user-defined extra_prompt_panel function

# Configure enabled panels (order matters - leftmost panels appear rightmost in prompt)
ZTANESH_ENABLED_PANELS=(
    server-status
    aws
    virtualenv
    extra-prompt
)

# Export for use by the panel system
export ZTANESH_ENABLED_PANELS

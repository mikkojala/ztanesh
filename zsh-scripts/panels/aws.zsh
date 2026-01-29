# AWS Profile prompt panel
# Shows current AWS profile when set

function setup_aws_panel {
    if [[ "$AWS_PROFILE" != "" ]]
    then
        PROMPT=$(echo -ne "%{\033[1;37m%}[%{\033[1;33m\033[38;2;255;153;0m%}$AWS_PROFILE%{\033[0;37;1m%}]%{\033[0m%}")"$PROMPT"
    fi
}
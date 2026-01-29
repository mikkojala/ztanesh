# Server Status prompt panel
# Shows server status from /etc/server-status file

function setup_server_status_panel {
    if [[ "$SERVER_STATUS_ENABLED" == "1" ]]
    then
        SERVER_STATUS=$(xargs echo -ne < /etc/server-status)
        if [[ $SERVER_STATUS == 'LIVE!' ]]
        then
            COLOR="1;5;41;33m"
        else
            COLOR="0;30;46m"
        fi
        PROMPT=$(echo -ne "%{\033[1;37m%}[%{\033[$COLOR%}$SERVER_STATUS%{\033[0;37;1m%}]%{\033[0m%}")"$PROMPT"
        unset COLOR
    fi
}
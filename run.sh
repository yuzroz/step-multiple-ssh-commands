if [ ! -n "$WERCKER_MULTIPLE_SSH_COMMANDS_DEPLOY_USER" ] ; then
    error "deploy-user property is not set or empty."
    exit 1
fi

if [ ! -n "$WERCKER_MULTIPLE_SSH_COMMANDS_DEPLOY_HOST" ] ; then
    error "deploy-host property is not set or empty."
    exit 1
fi

if [ ! -n "$WERCKER_MULTIPLE_SSH_COMMANDS_PROXY_VARS" ] ; then
    error "proxy-vars property is not set or empty."
    exit 1
fi

if [ ! -n "$WERCKER_MULTIPLE_SSH_COMMANDS_COMMANDS" ] ; then
    error "commands property is not set or empty."
    exit 1
fi

##
# Include vars to the SSH command.
# borrowed from: https://github.com/anka-sirota/step-script-ssh/
##
ENV=''

for f in $WERCKER_MULTIPLE_SSH_COMMANDS_PROXY_VARS ; do
    var=$f;
    ENV+="export $f='${!var}'; "
done


##
# Wercker automatically escapes $ signs. However, this makes this step unusable
# since it parses it as a local variable. This needs to be replaced...
##
COMMANDS_SRC="${WERCKER_MULTIPLE_SSH_COMMANDS_COMMANDS/_DOLLAR_/\$}"

##
# Extract the commands from the property and combine them.
# Each line in the option is a command, but do test whether it is not empty.
##
COMMANDS=''

IFS="
"

for c in $COMMANDS_SRC ; do
    if [ -n "$c" ] ; then
        COMMANDS+="$c && "
        info "including command: $c"
    fi
done

if [ -n "$COMMANDS" ] ; then
    COMMANDS=${COMMANDS::${#COMMANDS} - 4}
fi

info "combined environment variables: $ENV"
info "combined run commands: $COMMANDS"

ssh $DEPLOY_USER@$DEPLOY_HOST $ENV $COMMANDS


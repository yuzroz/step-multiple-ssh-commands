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
    ENV+=" export $f='${!var}';"
done
info "environment variables $ENV"

##
# Extract the commands from the property and combine them.
##
COMMANDS=''

IFS="
"

for c in $WERCKER_MULTIPLE_SSH_COMMANDS_COMMANDS ; do
    COMMANDS+="$c && "
done

if [ -n "$COMMANDS" ] ; then
    COMMANDS=${COMMANDS::${#COMMANDS} - 4}
fi

info "run commands: $COMMANDS"

ssh $DEPLOY_USER@$DEPLOY_HOST $ENV $COMMANDS


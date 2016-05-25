if [ ! -n "$WERCKER_MULTIPLE_SSH_COMMANDS_DEPLOY_USER" ] ; then
    error "deploy-user property is not set or empty."
    exit 1
fi

if [ ! -n "$WERCKER_MULTIPLE_SSH_COMMANDS_DEPLOY_HOST" ] ; then
    error "deploy-host property is not set or empty."
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
# Include options to the SSH command
##
OPTIONS=''

if [ -n "$WERCKER_MULTIPLE_SSH_COMMANDS_SSH_OPTIONS" ] ; then
    OPTIONS="$WERCKER_MULTIPLE_SSH_COMMANDS_SSH_OPTIONS"
fi

##
# Wercker automatically escapes $ signs. However, this makes this step unusable
# since it parses it as a local variable. This needs to be replaced...
##
COMMANDS_SRC="${WERCKER_MULTIPLE_SSH_COMMANDS_COMMANDS//_DOLLAR_/\$}"

##
# Wercker automatically replaces newlines the string value \n. This means that
# looping becomes hard. Solution: replace the \n string with an actual newline
# char. This can be used for looping again :).
# Unfortunately it is an ugly solution, because EACH \n is replaced with a 
# newline. This needs to be taken into account during development.
##
NEWLINE=$'\n'
COMMANDS_SRC=${COMMANDS_SRC//\\n/$NEWLINE}

##
# Extract the commands from the property and combine them.
# Each line in the option is a command, but do test whether it is not empty.
##
COMMANDS=''

IFS=$NEWLINE

for c in $COMMANDS_SRC ; do
    if [ -n "$c" ] ; then
        COMMANDS+="$c && "
        info "including command: $c"
    fi
done

unset IFS

if [ -n "$COMMANDS" ] ; then
    COMMANDS=${COMMANDS::${#COMMANDS} - 4}
fi

info "combined environment variables: $ENV"
info "combined run commands: $COMMANDS"
info "combined run options: $OPTIONS"
info "finaly: ssh $OPTIONS $DEPLOY_USER@$DEPLOY_HOST $ENV $COMMANDS"

ssh $OPTIONS $DEPLOY_USER@$DEPLOY_HOST $ENV $COMMANDS


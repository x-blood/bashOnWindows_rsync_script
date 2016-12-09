#!/bin/sh

set -eu

#Incoming WebHooks URL
WEBHOOKURL=""
#temp file for send message
MESSAGEFILE=$(mktemp -t sendResultToSlack.XXXX)
trap "
rm ${MESSAGEFILE}
" 0

usage_exit() {
    echo "Usage: $0 [-m message] [-c channel] [-i icon] [-n botname]" 1>&2
    exit 0
}

while getopts c:i:n:m: opts
do
    case $opts in
        c)
            CHANNEL=$OPTARG
            ;;
        i)
            FACEICON=$OPTARG
            ;;
        n)
            BOTNAME=$OPTARG
            ;;
        m)
            MESSAGE=$OPTARG"\n"
            ;;
        \?)
            usage_exit
            ;;
    esac
done
#slack channel
CHANNEL=${CHANNEL:-"#rsync_notification"}
#slack bot name
BOTNAME=${BOTNAME:-"rsync_notification"}
#slack icon
FACEICON=${FACEICON:-":ghost:"}
#title message
MESSAGE=${MESSAGE:-""}

if [ -p /dev/stdin ] ; then
    #convert kaigyo for slack
    cat - | tr '\n' '\\' | sed 's/\\/\\n/g'  > ${MESSAGEFILE}
else
    echo "nothing stdin"
    exit 1
fi

WEBMESSAGE='```'`cat ${MESSAGEFILE}`'```'

#send Incoming WebHooks
curl -s -S -X POST --data-urlencode "payload={\"channel\": \"${CHANNEL}\", \"username\": \"${BOTNAME}\", \"icon_emoji\": \"${FACEICON}\", \"text\": \"${MESSAGE}${WEBMESSAGE}\" }" ${WEBHOOKURL} >/dev/null

#!/bin/sh

KEY_KIND=
KEY_KIND_NAME=User
OUTFILE=/etc/ssh/user_ca_key
DOMAINS='*.example.com'
KEY_TYPE=rsa

while [ -z "$DONE" ]; do
    case "$1" in
        -#|--debug)
            set -x;;
        -o*|--output-file)
            OUTPUT_FILE=
            shift;;
        --output-file*)
            OUTPUT_FILE=$geta
    esac
done

HOST_MESSAGE="$KEY_KIND_NAME Certificate Authority for $DOMAINS"

$ECHO ssh-keygen $KEY_KIND -t "$KEY_TYPE" -f "$OUTFILE" -C "$HOST_MESSAGE"

#!/bin/sh
ECHO=
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o uhdeD:t:f: -l user,host,debug,echo,domain-list:,cipher:,outfile: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

KEY_KIND=
KIND_NAME=User
OUTFILE=user_ca_key
CIPHER=rsa
while [ $# -gt 0 ]
do
  case $1 in
    -u|--user)           KEY_KIND=; OUTFILE=user_ca_key; KIND_NAME="User";;
    -h|--host)           KEY_KIND=-h; OUTFILE=host_ca_key; KIND_NAME="Host" ;;
    -d|--debug)          set -v;;
    -e|--echo)           ECHO="echo :---: ";;
    # for options with required arguments, an additional shift is required
    -D|--domain-list)    DOMAINS="$2" ; shift;;
    -t|--cipher)         CIPHER="$2"; shift;;
    -f|--outfile)        OUTFILE="$2"; shift;;
    (--)                 shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

$ECHO ssh-keygen $KEY_KIND -t "$CIPHER" -f "$OUTFILE" -C "$KIND_NAME Certificate Authority for $DOMAINS"

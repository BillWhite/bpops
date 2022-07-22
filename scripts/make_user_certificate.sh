#!/bin/sh
ECHO=
CA_DIR=/etc/ssh
CA_FILE=user_ca_key
OUTFILE=ssh_certificate
PASSPHRASE=
TARFILE=/tmp/user_cert.tgz
# options may be followed by one colon to indicate they have a required argument
SHORT_OPTS="uhdxep:U:M:D:t:f:n:W:A:C:V:i:z:"
LONG_OPTS="user,host,debug,xdebug,echo,priority:,user-name:,user-home:,domain-list:,cipher:,tarfile:,outfile:,principals:,workdir:,authority:,ca-dir:,expiration:,key-id:,serial-number:"
if ! options=$(getopt -u -o "$SHORT_OPTS" -l "$LONG_OPTS" -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

CIPHER=rsa
USER_NAME="$USER"
USER_HOME="$HOME"
KEY_ID="kid"
SERIAL_NUMBER="0000"
PRIORITY=10
while [ $# -gt 0 ]
do
  echo "opts: $1 $2"
  case $1 in
    -u|--user)           KEY_KIND=; KIND_NAME="User";;
    -h|--host)           KEY_KIND=-h; KIND_NAME="Host"; CA_FILE=host_ca_key ;;
    -d|--debug)          set -v;;
    -x|--xdebug)         set -x;;
    -e|--echo)           ECHO="echo :---: ";;
    # for options with required arguments, an additional shift is required
    -U|--user-name)      USER_NAME="$2"; shift;;
    -M|--user-home)      USER_HOME="$2"; shift;;
    -D|--domain-list)    DOMAIN_LIST="$2" ; shift;;
    -t|--cipher)         CIPHER="$2"; shift;;
    -f|--outfile)        OUTFILE="$2"; shift;;
    --tarfile)           TARFILE="$2"; shift;;
    -i|--key-id)         KEY_ID="$2"; shift;;
    -z|--serial-number)  SERIAL_NUMBER="$2"; shift;;
    -n|--principals)     PRINCIPALS="$2"; shift;;
    -W|--workdir)        WORKDIR="$2"; SAVEWORKDIR=yes; 
	                 rm -rf "$WORKDIR"; # Delete it. It's old work.
	                 shift;;
    -A|--authority)      CA_FILE="$2"; shift;;
    -C|--ca-dir)         CA_DIR="$2"; shift;;
    -V|--expiration)     EXPIRY="$2"; shift;;
    -p|--priority)       PRIORITY="$2"; shift;;
    (--)                 shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done
if [ -z "$DOMAIN_LIST" ] ; then
    HOST_NAME="$(uname -n)"
    DOMAIN="$(echo "$HOST_NAME" | sed 's/^[^.]*\.//')"
    set -f
    DOMAIN_LIST="*.$DOMAIN"
    set +f
fi
if [ -z "$WORKDIR" ] ; then
    WORKDIR="$(mktemp --directory)"
fi
if [ ! -d "$WORKDIR" ] ; then
    mkdir -p "$WORKDIR"
fi

# 0. Figure out the CA files.
CA_PATH="$CA_DIR"/"$CA_FILE"
CA_PATH_PUB="${CA_PATH}.pub"
if [ -f "$CA_PATH" ] && [ -f "$CA_PATH_PUB" ] ; then
    CA_FILE_PUB="${CA_FILE}.pub"
else
    echo "$0: Cannot find CA file $CA_PATH or $CA_PATH.pub"
    exit 1
fi
mkdir -p $WORKDIR/.ssh/ssh_config.d
# 1. Create a new key pair to sign.
echo $0: Creating a user key pair in $OUTFILE and ${OUTFILE}.pub
$ECHO ssh-keygen -t "${CIPHER}" $EXPIRY -f "$WORKDIR/.ssh/$OUTFILE" -N "$PASSPHRASE"
# 2. Sign the new key pair.
echo $0: Signing public key ${OUTFILE}.pub
if [ -z "$PRINCIPALS" ] ; then
    PRINCIPALS="$USER_NAME"
fi
$ECHO ssh-keygen -s "${CA_PATH}" -I "${KEY_ID}" -z "${SERIAL_NUMBER}" \
	-n "$PRINCIPALS" "$WORKDIR/.ssh/${OUTFILE}.pub"
# 3. Create a stanza for $WORKDIR/.ssh_config.d.
cat > $WORKDIR/.ssh/ssh_config.d/$PRIORITY.ssh_certificate_${OUTFILE} << EOF
Host $DOMAIN_LIST
        Hostname %h
        User $USER_NAME
        IdentityFile $USER_HOME/.ssh/${OUTFILE}
        CertificateFile $USER_HOME/.ssh/${OUTFILE}-cert.pub
EOF
# 4. Packing up the tar file.
echo $0: Packing it all up in ${OUTFILE}.tgz
$ECHO tar --directory "$WORKDIR" --create --gzip --file ${TARFILE}.tgz .ssh
# N. Delete the workdir.
if [ -z "$SAVEWORKDIR" ] ; then
    echo $0: Deleting working $WORKDIR
    cd "$(/bin/pwd)/.."
    $ECHO rm -rf "$WORKDIR"
fi

#!/bin/sh

# Run with -h option to see full usage
show_usage(){
    printf "Usage:\n\n  $0 [options [parameters]]\n"
    printf "\n"
    printf "Sets up tests on the Cardano testnet.\n"
    printf "\n"
    printf "Options [parameters]:\n"
    printf "\n"
    printf "  -k|--key|--keygen [verification key filename] [signing key filename]   Generate keypair given two filenames; if special characters are\n                             used use single quotes.\n"
    printf "  -s|--send [sender address file] [receiver address file]    Sends transaction given two address files and integer amount in lovelace; if special characters are\n                             used use single quotes.\n"
    printf "  -h|--help                  Print this help.\n"
    printf "\n"
    printf "Checklist:\n"
    printf "\n"
    printf ""
exit
}

keygen=false
filename1=default-filename1.txt
filename2=default-filename2.txt

send=false
filename3=default-filename3.txt
filename4=default-filename4.txt
amt_lovelace=0

if [ $# -eq 0 ]; then
    show_usage
    exit
fi

while [ -n "$1" ]; do
    case "$1" in
        --keygen|--key|-k)
            if [ -n "$2" ] && [ -n "$3" ]
            then
                if [ -e "$2" ] || [ -e "$3" ]
                then
                    echo "One or more of the spcified files already exists. Remove them or use a different name."
                    exit
                else
                    keygen=true
                    filename1="$2"
                    filename2="$3"
                    shift 3
                fi
            else
                echo "-k flag requires two filename inputs"
                exit
            fi
            ;;
        --send|-s)
            if [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]
            then
                if [ ! -f "$2" ] || [ ! -f "$3" ]
                then
                    echo "The address files don't exist."
                    exit
                else
                    case $4 in
                        ''|*[!0-9]*)
                            echo "The lovelace amount needs to be a positive integer"
                            exit
                            ;;
                        *)
                            send=true
                            filename3="$2"
                            filename4="$3"
                            amt_lovelace="$4"
                            shift 4
                            ;;
                    esac
                fi
            else
                echo "-s flag requires two filename inputs and a positive integer"
                exit
            fi
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            ;;
    esac
done

### Advanced: can we run the nix shell and execute this script (again) if cardano-cli command is not found? ###
#command -v cardano-cli 2>&1 >/dev/null || { echo "cardano-cli not found\nStarting nix-shell from default ~/plutus-apps/"; pwd=`pwd`; cd ~/plutus-apps/; nix-shell; echo "Error: this error won't run until nix-shell is exited"; cd $pwd; exit; }

if [ $keygen = true ]
then
cardano-cli address key-gen \
    --verification-key-file $filename1 \
    --signing-key-file $filename2
fi

if [ $send = true ]
then

# Better spot for this export ?
export CARDANO_NODE_SOCKET_PATH=node.socket

cardano-cli transaction build \
    --alonzo-era \
    --testnet-magic 1097911063 \
    --change-address $(cat $filename3) \
    --tx-in dfc1a522cd34fe723a0e89f68ed43a520fd218e20d8e5705b120d2cedc7f45ad#0 \
    --tx-out "$(cat $filename4) $amt_lovelace lovelace" \
    --out-file tx.body

cardano-cli transaction sign \
    --tx-body-file tx.body \
    --signing-key-file 01.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
    --tx-file tx.signed
fi




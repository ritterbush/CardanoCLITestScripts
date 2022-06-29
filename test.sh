#!/bin/sh

# Run with -h option to see full usage

show_usage(){
    printf "Usage:\n\n  $0 [options [parameters]]\n"
    printf "\n"
    printf "Sets up tests on the Cardano testnet.\n"
    printf "\n"
    printf "Options [parameters]:\n"
    printf "\n"
    printf "  -k|--keygen [verification key filename] [signing key filename]   Generate keypair given two filenames; if special characters are\n                             used use single quotes.\n"
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
                    echo "One of the spcified files already exists. Remove it or use a different name."
                    exit
                else
                    keygen=true
                    filename1="$2"
                    filename2="$3"
                    shift 2
            fi
            else
                echo "-k flag requires two filename inputs"
                exit
            fi
            ;;
        --filename|--file|-f)
            if [ -n "$2" ]
            then
                filename="$2"
                shift 2
            else
                echo "-f flag requires a filename"
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

if [ $keygen = true ]
then
cardano-cli address key-gen --verification-key-file $filename1 --signing-key-file $filename2
fi

if [ $send = true ]
then
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




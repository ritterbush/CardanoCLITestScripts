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

# If wipe disk option used, check a diskname has been given
if [ $keygen = true ]
then
cardano-cli address key-gen --verification-key-file $filename1 --signing-key-file $filename2
fi



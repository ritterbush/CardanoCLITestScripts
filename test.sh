#!/bin/sh

# Run with -h option to see full usage

show_usage(){
    printf "Usage:\n\n  $0 [options [parameters]]\n"
    printf "\n"
    printf "Sets up tests on the Cardano testnet.\n"
    printf "\n"
    printf "Options [parameters]:\n"
    printf "\n"
    printf "  -u|--username [username]   Specify username; if special characters are\n                             used use single quotes.\n"
    printf "  -p|--password [password]   Specify password; if special characters are\n                             used use single quotes.\n"
    printf "  -o|--hostname [hostname]   Specify hostname:~ the name of the computer\n                             of this operating system.\n"
    printf "  -t|--timezone [timezone]   Specify timezone; use single quotes.\n                             To see options: ls /usr/share/zoneinfo\n"
    printf "  -s|--staticip [staticip]   Specify local static ip address (setup with\n                             your router). Do not use if no local static\n                             ip address has been set up. Use single quotes.\n"
    printf "  -f|--full                  Install ComfyOS setup after basic Arch\n                             installation.\n"
    printf "  -a|--amdcpu                Use amd cpu microcode.\n"
    printf "  -i|--intelcpu              Use intel cpu microcode.\n"
    printf "  --wipe-disk                Wipes the disk (ALL DATA ERASED!) of\n                             /dev/--diskname specified by -d|--diskname\n"
    printf "  -d|--diskname [diskname]   Specify diskname to be wiped; e.g.\n                             'sdc'. Do not include /dev/. \n"
    printf "  -h|--help                  Print this help.\n"
    printf "\n"
    printf "Checklist:\n"
    printf "\n"
    printf ""
exit
}

username=newuser # Change with -u
password=password # Change with -p
timezone=America/Los_Angeles # Change with -t. To see options: ls /usr/share/zoneinfo
hostname=arch # Change with -o
staticip=127.0.1.1 # Change with -s
full=false # If -f option used, fully install ComfyOS desktop, otherwise do a basic installation 
cpu=other # Must be other or amd or intel
wipe=false # If -w option is used, wipes disk clean and makes partitions according to the below variables
disk=none # Wipes the disk '/dev/disk', can be changed with -d; use the letters that follow /dev/ and that specify the disk to wipe
efipart="$disk"1 # Same name as disk above but with 1 at the end
rootpart="$disk"2 # Same name as disk above but 2 instead of 1 at the end
homepart="$disk"3 # Same name as disk above but 3 instead of 2 at the end
mirrors=default

while [ -n "$1" ]; do
    case "$1" in
        --username|-u)
            if [ -n "$2"  ]
            then
                username="$2"
                shift 2
            else
                echo "-u flag requires a username"
                exit
            fi
            ;;
        --password|-p)
            if [ -n "$2"  ]
            then
                password="$2"
                shift 2
            else
                echo "-p option requires a password"
                exit
            fi
            ;;
        --hostname|-o)
            if [ -n "$2"  ]
            then
                hostname="$2"
                shift 2
            else
                echo "-o option requires a hostname"
                exit
            fi
            ;;
        --timezone|-t)
            if [ -n "$2"  ]
            then
                timezone="$2"
                shift 2
            else
                echo "-t option requires a timezone"
                exit
            fi
            ;;
        --staticip|-s)
            if [ -n "$2"  ]
            then
                staticip="$2"
                shift 2
            else
                echo "-s option requires a static ip address"
                exit
            fi
            ;;
        --full|-f)
            full=true
            shift
            ;;
        --amdcpu|-a)
            cpu=amd
            shift
            ;;
        --intelcpu|-i)
            cpu=intel
            shift
            ;;
        --wipe-disk)
            wipe=true
            shift
            ;;
        --diskname|-d)
            if [ -n "$2"  ]
            then
                disk="$2"
                efipart="$disk"1 # Same name as disk above but with 1 at the end
                rootpart="$disk"2 # Same name as disk above but 2 instead of 1 at the end
                homepart="$disk"3 # Same name as disk above but 3 instead of 2 at the end
                shift 2
            else
                echo "-d option requires a diskname"
                exit
            fi
            ;;
        --help|-h)
            show_usage
            ;;
        --usa-sw-mirrors)
            mirrors='usa-sw'
            shift
            ;;
        *)
            echo "Unknown option $1"
            show_usage
            ;;
    esac
done

# If wipe disk option used, check a diskname has been given
[ $wipe = true ] && [ $disk = none ] && { echo "Specify diskname with -d|--diskname when using --wipe-disk option"; exit; }

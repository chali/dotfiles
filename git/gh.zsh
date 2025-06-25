gho_help(){
    echo "Usage: gho <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    browse   Open a GitHub project page in the default browser"
    echo "    cd       Go to the directory of the specified repository"
    echo "    clone    Clone a remote repository"
    echo ""
    echo "For help with each subcommand run:"
    echo "gho <subcommand> -h|--help"
    echo ""
}
  
gho_browse() {
    open `git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@'`| head -n1
}
  
gho_clone() {
    if [[ "$1" == corp/* ]]; then
        : ${GHE_HOST?"GHE_HOST must be set"}
        git clone --recursive "https://$GHE_HOST/$1.git" ~/Projects/github/$1
    else
        git clone --recursive "ssh://git@github.com/$1.git" ~/Projects/github/$1
    fi
    gho_cd "$1"
}

gho_cd() {
    cd ~/Projects/github/$1
}

gho() {
    subcommand=$1
    case $subcommand in
        "" | "-h" | "--help")
            gho_help
            ;;
        *)
            shift
            gho_${subcommand} $@
            if [ $? = 127 ]; then
                echo "Error: '$subcommand' is not a known subcommand." >&2
                echo "       Run 'gho --help' for a list of known subcommands." >&2
                return 1
            fi
            ;;
    esac
}

compdef '_files -W ~/Projects/github' gh

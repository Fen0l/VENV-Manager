#!/bin/sh

OPTIND=1
python_version="2.7"
venv="venv"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# static Vars
SOURCE_DIRECTORY=$(cd $(dirname "$0"); pwd)

# Parse variables
while getopts "p:e:" opt; do
    case "$opt" in
    p)  python_version=$OPTARG
        ;;
    e)  venv=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

####################################################
# Check the current python version
function check_python {
	# Is Python is installed
	echo -e "${ORANGE}[–] Checking the Python version${NC}"
	if command -v "python$python_version" &>/dev/null; then
	    echo -e "${GREEN}[–] Python$python_version is installed, processing...${NC}"
	else
	    echo -e "${RED}[–] Python$python_version is not installed.${NC}"
	    echo -e "${RED}[–] Exiting.${NC}"
	    exit
	fi
}

# Check the current pip version
function check_pip {
	# Are virtualenv tools are installed
	IFS='.' read -r -a array <<< "$python_version"
	echo -e "${ORANGE}[–] Checking the PIP version${NC}"
	pip_version="pip${array[0]}"
	if command -v "$pip_version" &>/dev/null; then
	    echo -e "${GREEN}[–] $pip_version is installed, processing...${NC}"
	else
	    echo -e "${RED}[–] $pip_version is not installed.${NC}"
	    echo -e "${RED}[–] Exiting.${NC}"
	    exit
	fi
}

function create_venv_startup {
	echo -e "${ORANGE}[–] Creating the VENV startup file"
	echo "#!/bin/sh" > "venv.sh"
	echo "source $venv/bin/activate" >> "venv.sh"
	chmod +x "venv.sh"
}
# Create VENV
function create_venv {
	check_python
	check_pip

	echo -e "${ORANGE}[–] Installing virtualenv & virtualenvwrapper${NC}"
	"$pip_version" install virtualenv virtualenvwrapper --upgrade

	echo -e "${ORANGE}[–] Setup ENV${NC}"
	source /usr/local/bin/virtualenvwrapper.sh
	virtualenv -p "python$python_version" "$venv"

	create_venv_startup

}



echo -e "${ORANGE}[–] Virtualenv manager${NC}"
# If there is not current VENV, Create one
if [ ! -f "$SOURCE_DIRECTORY/venv.sh" ] || [ ! -d "$SOURCE_DIRECTORY/$venv" ]; then
	rm -rf "$SOURCE_DIRECTORY/$venv"
	rm "$SOURCE_DIRECTORY/venv.sh"
    create_venv
else
	echo -e "${GREEN}[–] VENV present, run . ./venv.sh${NC}"
fi


exit


NOCOLOR='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

isGCPVM(){
    #https://cloud.google.com/compute/docs/instances/detect-compute-engine#use_the_metadata_server_to_detect_if_a_vm_is_running_in
    if [ "$(curl --max-time 1 -s metadata.google.internal -i | grep -c "200")" -eq 1 ]; then
        echo true
    else
        echo false # It is not VM in GCP
    fi
}

INFO(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo -e "[$timeAndDate] [${GREEN}INFO${NOCOLOR}] [${0}] [$function_name] $msg"
}

ERROR(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo -e "[$timeAndDate] [${RED}ERROR${NOCOLOR}] [${0}] [$function_name] $msg"
    exit 1
}

WARN(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo -e "[$timeAndDate] [${YELLOW}WARN${NOCOLOR}] [${0}] [$function_name] $msg"
}

WARN_CONFIRM(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo -e "[$timeAndDate] [${YELLOW}WARN${NOCOLOR}] [${0}] [$function_name] $msg"
    read -n 1 -r -s -p "Press any key to continue..."
}
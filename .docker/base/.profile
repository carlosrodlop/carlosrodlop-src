DEBUG=${DEBUG:-false}

setDebugLevel(){
    if [ "$DEBUG" = true ]; then
        shopt -s expand_aliases # bash
        set -x # bash
        alias helm="helm --debug"
        alias helmfile="helmfile --debug"
        alias gcloud="gcloud --verbosity=debug"
        export TF_LOG="DEBUG"
        export TF_LOG_PATH="${HERE}/terraform/terraform.log"
    fi
}

## Logging

INFO(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo "[$timeAndDate] [INFO] [${0}] [$function_name] $msg"
}

ERROR(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo "[$timeAndDate] [ERROR] [${0}] [$function_name] $msg"
    exit 1
}

WARN(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    echo "[$timeAndDate] [WARN] [${0}] [$function_name] $msg"
}

WARN_CONFIRM(){
    local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=$(date)
    read -n 1 -r -s -p "[$timeAndDate] [WARN] [${0}] [$function_name] $msg. Press any key to continue..."
}

## Cloud

isGCPVM(){
    #https://cloud.google.com/compute/docs/instances/detect-compute-engine#use_the_metadata_server_to_detect_if_a_vm_is_running_in
    if [ "$(curl -s metadata.google.internal -i | grep -c "200")" -eq 1 ]; then
        echo true
    else
        echo false # It is not VM in GCP
    fi
}

ssh-remote(){
    ip=${IP:-}
    if [ -z "$ip" ]; then
        echo "Enter the IP to connect:"
        read -r ip
    fi
    ssh-keygen -R "$ip" || WARN "There is no "$ip" to remove"
    ssh -i "$HOME/.ssh/carlosrodlop-flash" carlosrodlop@"${ip}"
}

# Set up aliases
alias cl="clear"
alias x="exit"
alias k="kubectl"
alias t="terraform"
#!/bin/bash
# default values 
STUDENT_LIST="student_list.csv"
PORT_MAP="port_map.csv"

# deployment variables
PASSWORD="kth-rocky" # in practice this is never used
MODULEPATH="/opt/tools/modules"
CONTAINER_IMAGE="kth-rocky:2024.5"
TOOL_NFS_DIR="/ee/tools/"
TOOL_CONTAINER_DIR="/opt/tools"
PDK_NFS_DIR="/ee/pdk/.symlinks"
PDK_CONTAINER_DIR="/opt/pdk"

# parse flags
# -n --name-prefix [mandatory]
# -l --user-list [default: user_list.csv]
# -p --port-map [default: port_map.csv]
# -i --image [default: kth-rocky:2024.5]
# -d --home-dirs [mandatory]
# -t --tool-dir [default: /opt/tools]
# -k --pdks [list of pdk, available ones: tsmc90, tsmc28, kista, sky130, xfab]

# print help message
function print_help() {
    echo "Usage: deploy_containers.sh [OPTIONS]"
    echo "Options:"
    echo "  -n, --name-prefix          Prefix for the container name"
    echo "  -l, --user-list            CSV file containing username and ssh key"
    echo "  -p, --port-map             CSV file containing username and port mapping"
    echo "  -i, --image                Container image to deploy"
    echo "  -d, --home-dirs            Directory containing home directories"
    echo "  -k, --pdks                 List of PDKs to mount. Available PDKs: tsmc90, tsmc28, kista, sky130, xfab"
}
while [[ $# -gt 0 ]]
do
    case $1 in
        -h|--help)
            print_help
            return 0
            ;;
        -n|--name-prefix)
            CONTAINER_PREFIX=$2
            shift
            shift
            ;;
        -l|--user-list)
            STUDENT_LIST=$2
            shift
            shift
            ;;
        -p|--port-map)
            PORT_MAP=$2
            shift
            shift
            ;;
        -i|--image)
            CONTAINER_IMAGE=$2
            shift
            shift
            ;;
        -d|--home-dirs)
            HOME_DIRS=$2
            shift
            shift
            ;;
        -k|--pdks)
            PDK_LIST=$2
            shift
            shift
            ;;
    esac
done

# check if mandatory flags are set
if [ -z ${HOME_DIRS} ]; then
    echo "Please provide home directories for the students"
    print_help
    return 1
fi
if [ -z ${CONTAINER_PREFIX} ]; then
    echo "Please provide container name prefix"
    print_help
    return 1
fi
# check if PDK is a list separated by comma, each element should be a valid pdk
# valid pdks: tsmc90, tsmc28, kista, sky130, xfab
for pdk in $(echo $PDK_LIST | sed "s/,/ /g")
do
    if [ $pdk != "tsmc90" ] && [ $pdk != "tsmc28" ] && [ $pdk != "kista" ] && [ $pdk != "sky130" ] && [ $pdk != "xfab" ]; then
        echo "Invalid PDK: $pdk"
        return 1
    fi
done

# create PDK mount argument
PDK_MOUNTS=""
for pdk in $(echo $PDK_LIST | sed "s/,/ /g")
do
    PDK_MOUNTS="${PDK_MOUNTS} -v ${PDK_NFS_DIR}/${pdk}:${PDK_CONTAINER_DIR}/${pdk}:ro"
done
# read csv file
while IFS=, read -r username key
do
    echo "Deploying container for $username"
    docker run -d --name ${CONTAINER_PREFIX}${username} \
        --restart unless-stopped \
        -e STUDENTID=${username} \
        -e PASSWORD=${PASSWORD} \
            -e SSH_KEY="${key}" \
        -e MODULEPATH=${MODULEPATH} \
        -p 22 \
        -v ${HOME_DIRS}${username}:/home/${username} \
        -v ${TOOL_NFS_DIR}:${TOOL_CONTAINER_DIR}:ro \
        ${PDK_MOUNTS} \
        ${CONTAINER_IMAGE}

    # get the port number
    port=$(docker port ${CONTAINER_PREFIX}${username} 22 | cut -d ':' -f 2)
    echo "${username},${port}" >> ${PORT_MAP}
done < ${STUDENT_LIST}



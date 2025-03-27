#!/bin/bash
# default values 
STUDENT_LIST="student_list.csv"
PORT_MAP="port_map.csv"

# deployment variables
PASSWORD="kth-rocky" # in practice this is never used
MODULEPATH="/opt/tools/modules"
CONTAINER_IMAGE="kth-rocky:2024.6"
TOOL_NFS_DIR="/ee/tools/"
TOOL_CONTAINER_DIR="/opt/tools"
PDK_NFS_DIR="/ee/pdk/.symlinks"
PDK_CONTAINER_DIR="/opt/pdk"
SHARE_NFS_DIR="/ee/"
SHARE_CONTAINER_DIR="/media/shares"

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
    echo "  -s, --shares               List of shared directories to mount"
}

# Parse flags
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
        -s|--shares)
            SHARE_LIST=$2
            shift
            shift
            ;;
    esac
done

# Check if mandatory flags are set
if [ -z "${HOME_DIRS}" ]; then
    echo "Please provide home directories for the students"
    print_help
    return 1
fi
if [ -z "${CONTAINER_PREFIX}" ]; then
    echo "Please provide container name prefix"
    print_help
    return 1
else
    if [[ $CONTAINER_PREFIX =~ ^[a-z]{2,3}[0-9]{4}(ht|vt)[0-9]{2}$ ]]; then
      ACCOUNT_TYPE="student"
      COURSE_CODE=${CONTAINER_PREFIX}
    elif [[ $CONTAINER_PREFIX =~ ^[a-zA-Z0-9_]*_research$ ]]; then
      ACCOUNT_TYPE="research"
    else
      echo "Invalid container name prefix"
      echo "The prefix should be in the format [a-z]{2,3}[0-9]{4}(ht|vt)[0-9]{2} or [a-zA-Z0-9_]*_research"
      return 1
    fi
    CONTAINER_PREFIX="${CONTAINER_PREFIX}_"
fi

# Validate PDK list
valid_pdks="tsmc90 tsmc28 kista sky130 xfab gf22"
for pdk in $(echo "$PDK_LIST" | sed "s/,/ /g"); do
    if [[ ! $valid_pdks =~ $pdk ]]; then
        echo "Invalid PDK: $pdk"
        return 1
    fi
done

# Trim all directory variables to remove potential spaces
PDK_NFS_DIR=$(echo "${PDK_NFS_DIR}" | sed 's/^ *//; s/ *$//')
PDK_CONTAINER_DIR=$(echo "${PDK_CONTAINER_DIR}" | sed 's/^ *//; s/ *$//')
TOOL_NFS_DIR=$(echo "${TOOL_NFS_DIR}" | sed 's/^ *//; s/ *$//')
TOOL_CONTAINER_DIR=$(echo "${TOOL_CONTAINER_DIR}" | sed 's/^ *//; s/ *$//')
HOME_DIRS=$(echo "${HOME_DIRS}" | sed 's/^ *//; s/ *$//')

# Create a single string to store volume mounts instead of using an array
PDK_MOUNTS=""

# Build the PDK_MOUNTS string by iterating through the comma-separated list in PDK_LIST
for pdk in $(echo "$PDK_LIST" | sed "s/,/ /g"); do
    host_path=$(echo "${PDK_NFS_DIR}/${pdk}" | sed 's/^ *//; s/ *$//')
    container_path=$(echo "${PDK_CONTAINER_DIR}/${pdk}" | sed 's/^ *//; s/ *$//')

    # Append each mount to the string, ensuring no leading or trailing spaces
    PDK_MOUNTS="${PDK_MOUNTS} -v ${host_path}:${container_path}:ro"
done

# Build the SHARE_MOUNTS string by iterating through the comma-separated list in SHARE_LIST
for share in $(echo "$SHARE_LIST" | sed "s/,/ /g"); do
    # if ACCOUNT_TYPE is student, then the share is in the format course_code/share_name
    # if [ $ACCOUNT_TYPE == "student" ]; then
    if [[ $ACCOUNT_TYPE == "student" ]]; then
        host_path=$(echo "${SHARE_NFS_DIR}/${COURSE_CODE}/shares/${share}" | sed 's/^ *//; s/ *$//')
    elif [[ $ACCOUNT_TYPE == "research" ]]; then
        host_path=$(echo "${SHARE_NFS_DIR}/research/shares/${share}" | sed 's/^ *//; s/ *$//')
    fi
    container_path=$(echo "${SHARE_CONTAINER_DIR}/${share}" | sed 's/^ *//; s/ *$//')

    # Append each mount to the string, ensuring no leading or trailing spaces
    SHARE_MOUNTS="${SHARE_MOUNTS} -v ${host_path}:${container_path}:ro"
done

# Read the student list CSV and deploy containers
while IFS=, read -r username key port; do
    # Check if port is empty, set default port if not specified
    if [ -z ${port} ]; then
        PORT=22
    else
        PORT=${port}:22
    fi

    # Construct the complete Docker command as a single string
    docker_cmd="docker run -d --name ${CONTAINER_PREFIX}${username} \
        --restart unless-stopped \
        -e STUDENTID=${username} \
        -e PASSWORD=${PASSWORD} \
        -e SSH_KEY=\"${key}\" \
        -e MODULEPATH=${MODULEPATH} \
        -p ${PORT} \
        -v ${HOME_DIRS}/${username}:/home/${username} \
        -v ${TOOL_NFS_DIR}:${TOOL_CONTAINER_DIR}:ro \
        ${PDK_MOUNTS} \
        ${SHARE_MOUNTS} \
        ${CONTAINER_IMAGE}"

    # Print and run the Docker command
    # echo "Running command: $docker_cmd"
    eval $docker_cmd

    # Check if container was created successfully and get its port
    if [ $? -eq 0 ]; then
        port=$(docker port "${CONTAINER_PREFIX}${username}" 22 | cut -d ':' -f 2)
        echo "${username},${port}" >> "${PORT_MAP}"
        echo "Deployed container for ${username} on port ${port}"
    else
        echo "Failed to deploy container for ${username}"
    fi
done < "${STUDENT_LIST}"

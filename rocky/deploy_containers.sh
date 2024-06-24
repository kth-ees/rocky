STUDENT_LIST="student_list.csv"
PORT_MAP="port_map.csv"
PASSWORD="kth-rocky" # in practice this is never used
MODULEPATH="/opt/tools/modules"
CONTAINER_PREFIX="il2225_ht24_"
CONTAINER_IMAGE="kth-rocky:2024.5"
HOME_DIRS="/ee/courses/il2225/ht24/"
TOOL_DIR="/ee/tools/"

# read csv file
while IFS=, read -r username key
do
    echo "Deploying container for $username"
    docker run -d --name ${CONTAINER_PREFIX}${username} -e STUDENTID=${username} -e PASSWORD=${PASSWORD} \
        -e SSH_KEY="${key}" -e MODULEPATH=${MODULEPATH} -p 22 \
        -v ${HOME_DIRS}${username}:/home/${username} \
        -v ${TOOL_DIR}:/opt/tools \
        ${CONTAINER_IMAGE}

    # get the port number
    port=$(docker port ${CONTAINER_PREFIX}${username} 22 | cut -d ':' -f 2)
    echo "${username},${port}" >> ${PORT_MAP}
done < ${STUDENT_LIST}



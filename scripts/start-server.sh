#!/bin/bash
# Check if directories exist and create them if they don't
if [ ! -d ${STEAMCMD_DIR} ]; then
    echo "Creating SteamCMD directory..."
    mkdir -p ${STEAMCMD_DIR}
fi

if [ ! -d ${SERVER_DIR} ]; then
    echo "Creating Server directory..."
    mkdir -p ${SERVER_DIR}
fi

if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

echo "---Update Server---"
if [ "${USERNAME}" == "" ]; then
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${GAME_ID} \
        +quit
    fi
else
    if [ "${VALIDATE}" == "true" ]; then
    	echo "---Validating installation---"
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} validate \
        +quit
    else
        ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USERNAME} ${PASSWRD} \
        +app_update ${GAME_ID} \
        +quit
    fi
fi

echo "---Prepare Server---"
if [ ! -f ${DATA_DIR}/.steam/sdk32/steamclient.so ]; then
	if [ ! -d ${DATA_DIR}/.steam ]; then
    	mkdir ${DATA_DIR}/.steam
    fi
	if [ ! -d ${DATA_DIR}/.steam/sdk32 ]; then
    	mkdir ${DATA_DIR}/.steam/sdk32
    fi
    if [ -d ${STEAMCMD_DIR}/linux32 ]; then
        cp -R ${STEAMCMD_DIR}/linux32/* ${DATA_DIR}/.steam/sdk32/
    else
        echo "Warning: ${STEAMCMD_DIR}/linux32 directory not found, skipping copy operation"
    fi
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}

# Check for various server executables
if [ -f ${SERVER_DIR}/srcds_run ]; then
    # Source Dedicated Server
    echo "Starting Source Dedicated Server..."
    ${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}
elif [ -f ${SERVER_DIR}/server.exe ]; then
    # Windows server executable with Wine
    if command -v wine &> /dev/null; then
        echo "Starting Windows server with Wine..."
        wine ${SERVER_DIR}/server.exe ${GAME_PARAMS}
    else
        echo "Warning: Windows server executable found (server.exe), but Wine is not installed."
        echo "To run Windows executables, set INSTALL_WINE=true in your environment variables."
        echo "Keeping container running. You can connect to it and start the server manually."
        # Keep the container running
        tail -f /dev/null
    fi
elif [ -f ${SERVER_DIR}/server ] && [ -x ${SERVER_DIR}/server ]; then
    # Generic Linux server executable
    echo "Starting Linux server..."
    ${SERVER_DIR}/server ${GAME_PARAMS}
elif [ -f ${SERVER_DIR}/start_server.sh ] && [ -x ${SERVER_DIR}/start_server.sh ]; then
    # Server with start script
    echo "Starting server with start_server.sh..."
    ${SERVER_DIR}/start_server.sh ${GAME_PARAMS}
elif [ -f ${SERVER_DIR}/start.sh ] && [ -x ${SERVER_DIR}/start.sh ]; then
    # Server with start.sh script
    echo "Starting server with start.sh..."
    ${SERVER_DIR}/start.sh ${GAME_PARAMS}
else
    # Try to find any executable files
    EXECUTABLES=$(find ${SERVER_DIR} -type f -executable -not -path "*/\.*" | sort)
    if [ -n "$EXECUTABLES" ]; then
        echo "Found potential server executables:"
        echo "$EXECUTABLES"
        echo "Attempting to start the first executable..."
        FIRST_EXECUTABLE=$(echo "$EXECUTABLES" | head -n 1)
        echo "Starting with: $FIRST_EXECUTABLE"
        $FIRST_EXECUTABLE ${GAME_PARAMS}
    else
        echo "Warning: No server executable found. Server may not be properly installed."
        echo "Please check your GAME_ID (${GAME_ID}) and make sure it's correct."
        echo "Available files in server directory:"
        ls -la ${SERVER_DIR}
        echo "Keeping container running. You can connect to it and start the server manually."
        # Keep the container running
        tail -f /dev/null
    fi
fi

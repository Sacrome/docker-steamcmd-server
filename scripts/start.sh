#!/bin/bash
echo "---Ensuring UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Ensuring GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
cp -f /opt/custom/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:
cp -f /opt/scripts/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:

if [ -f /opt/scripts/start-user.sh ]; then
    echo "---Found optional script, executing---"
    chmod -f +x /opt/scripts/start-user.sh ||:
    /opt/scripts/start-user.sh || echo "---Optional Script has thrown an Error---"
else
    echo "---No optional script found, continuing---"
fi

echo "---Taking ownership of data...---"
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}

# Install Wine if requested
if [ "${INSTALL_WINE}" == "true" ]; then
    if ! command -v wine &> /dev/null; then
        echo "---Installing Wine for Windows executables---"
        apt-get update
        apt-get install -y --no-install-recommends wine wine64 && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*
        echo "---Wine installation completed---"
    else
        echo "---Wine is already installed---"
    fi
fi

# Fix for CSDM not working properly
if [ -f "${SERVER_DIR}/cstrike/addons/sourcemod/gamedata/cssdm.games.txt" ]; then
  chmod 550 ${SERVER_DIR}/cstrike/addons/sourcemod/gamedata/cssdm.games.txt
fi

echo "---Starting...---"
term_handler() {
	kill -SIGTERM "$killpid"
	wait "$killpid" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done

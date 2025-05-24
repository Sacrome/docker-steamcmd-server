# SteamCMD in Docker optimized for Unraid
This Docker will download and install SteamCMD and the according game that is pulled via specifying the Tag.

**Please see the different Tags/Branches which games are available.**

## Example Env params for CS:Source
| Name | Value | Example |
| --- | --- | --- |
| STEAMCMD_DIR | Folder for SteamCMD | /serverdata/steamcmd |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| GAME_ID | The GAME_ID that the container downloads at startup. If you want to install a static or beta version of the game change the value to: '232330 -beta YOURBRANCH' (without quotes, replace YOURBRANCH with the branch or version you want to install). | 232330 |
| GAME_NAME | SRCDS gamename | cstrike |
| GAME_PARAMS | Values to start the server | -secure +maxplayers 32 +map de_dust2 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| GAME_PORT | Port the server will be running on | 27015 |
| VALIDATE | Validates the game data | blank |
| USERNAME | Leave blank for anonymous login | blank |
| PASSWRD | Leave blank for anonymous login | blank |
| INSTALL_WINE | Set to "true" to install Wine for Windows executables | false |

## Run example for CS:Source
```
docker run --name CSSource -d \
	-p 27015:27015 -p 27015:27015/udp \
	--env 'GAME_ID=232330' \
	--env 'GAME_NAME=cstrike' \
	--env 'GAME_PORT=27015' \
	--env 'GAME_PARAMS=-secure +maxplayers 32 +map de_dust2' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'USERNAME=yoursteamusername' \
	--env 'PASSWRD=yoursteampassword' \
	--env 'INSTALL_WINE=false' \
	--volume /path/to/steamcmd:/serverdata/steamcmd \
	--volume /path/to/cstrikesource:/serverdata/serverfiles \
	ich777/steamcmd:latest
```

> **Note**: If you don't need to use a Steam account (for games that support anonymous login), you can remove the USERNAME and PASSWRD environment variables or leave them blank.
>
> **Server Executable Detection**: The container now automatically detects and runs the appropriate server executable. It checks for the following executables in order:
> 1. Source Dedicated Server (srcds_run)
> 2. Windows server executable (server.exe) - requires Wine (set INSTALL_WINE=true)
> 3. Generic Linux server executable (server)
> 4. Server with start_server.sh script
> 5. Server with start.sh script
> 6. Any executable file found in the server directory
>
> If no executable is found, the container will keep running so you can connect to it and start the server manually.

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

This Docker is forked from mattieserver, thank you for this wonderfull Docker.

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/

#!/bin/sh

if [ -z "${jarType}" ]; then 
	echo "Unknows jar type, use one of these:"
	echo " -> vanilla, paper, purpur"
	exit 1
fi

if [ -z "${version}" ]; then
	echo "Version angeben (example: 1.20.4)"
	exit 1
fi

case "$jarType" in
    paper)
        LATEST_BUILD=$(wget -O - -q https://api.papermc.io/v2/projects/paper/versions/${version}/builds | \
                jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

        if [ -z "$LATEST_BUILD" ]; then
            echo "Invalid version"
            exit 1
        fi
        if [ "$LATEST_BUILD" = "null" ]; then
            echo "No stable build for version $version found :("
            exit 2
        fi
        rmident=paper
        jarFile=${rmident}-${version}-${LATEST_BUILD}.jar
        url="https://api.papermc.io/v2/projects/paper/versions/${version}/builds/${LATEST_BUILD}/downloads/${jarFile}"
        ;;
    
    vanilla)
        versionurl=$(wget -O - -q https://piston-meta.mojang.com/mc/game/version_manifest_v2.json | \
            jq -r ".versions | map(select(.id == \"$version\") | .url) | .[0]")
        url=$(wget -O - -q $versionurl | jq -r '.downloads.server.url')
        rmident=vanilla
        jarFile=${rmident}-${version}.jar
        ;;

    purpur)
        LATEST_BUILD=$(wget -O - -q https://api.purpurmc.org/v2/purpur/${version}/ | \
            jq -r ".builds.latest")
	
        if [ -z "$LATEST_BUILD" ]; then
            echo "Invalid version"
            exit 1
        fi
        if [ "$LATEST_BUILD" = "null" ]; then
            echo "No stable build for version $version found :("
            exit 2
        fi

        url=https://api.purpurmc.org/v2/purpur/${version}/${LATEST_BUILD}/download
        rmident=purpur
        jarFile=${rmident}-${version}-${LATEST_BUILD}.jar
        ;;

    *)
	echo "Unknows jar type, use one of these:"
	echo " -> vanilla, paper, purpur"
        exit 1
        ;;
esac

if ! [ -f "$jarFile" ]; then
    rm -f ${rmident}-*.jar
    if ! wget -O "$jarFile" -q "$url"; then
        echo "Could not download server file"
        exit 2
    else
        echo "Download successful"
    fi
fi

if [ "$EULA" = "true" ]; then 
	echo "eula=true" > ./eula.txt
	exec java -jar "$jarFile" -nogui
else
	echo "eula=false" > ./eula.txt
        echo "Accept the eula"
	echo "enviroment variable: EULA=true"
fi	

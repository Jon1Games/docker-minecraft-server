#!/bin/sh

# ENV: EULA, jarType, Version, BUILD(not for Vanilla), redownload, reinstall

if [ -z "${jarType}" ]; then 
	echo "Unknows jar type, use one of these:"
	echo " -> vanilla, paper, purpur"
    echo " -> TODO: Forge, NeoForge, Fabrik"
	exit 1
fi

if [ -z "${version}" ]; then
	echo "Version angeben (example: 1.20.4)"
	exit 1
fi

if [ -z "${reinstall}" ]; then
    rm *
fi

# Check if wisched jar already exist, if set to ${jarFile} to allow starting
## Check for Vanilla Jar
if [ -e "${jarType}-${version}.jar" ]; then
    jarFile="${jarType}-${version}.jar"
    if [ -z "${redownload}" ]; then
        rm ${jarFile} 
        echo "redowloading jar"
    else 
        echo "using existing Jar"
    fi
## Check for Paper,PurPur,Fabric Jar
elif [ -e "${jarType}-${version}-${BUILD}.jar" ]; then
    jarFile="${jarType}-${version}-${BUILD}.jar"
    if [ -z "${redownload}" ]; then
        rm ${jarFile} 
        echo "redowloading jar"
    else 
        echo "using existing Jar"
    fi
# Download Jar
else
    case "$jarType" in
        paper)
            if [ "$BUILD" = "latest"]; then
                BUILD=$(wget -O - -q https://api.papermc.io/v2/projects/paper/versions/${version}/builds | \
                    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')
            
                if [ -z "$BUILD" ]; then
                    echo "Invalid version"
                    exit 1
                fi
                if [ "$BUILD" = "null" ]; then
                    echo "No stable build for version $version found :("
                    exit 2
                fi
            fi
            rmident=paper
            jarFile=${rmident}-${version}-${BUILD}.jar
            url="https://api.papermc.io/v2/projects/paper/versions/${version}/builds/${BUILD}/downloads/${jarFile}"
            ;;
        
        vanilla)
            versionurl=$(wget -O - -q https://piston-meta.mojang.com/mc/game/version_manifest_v2.json | \
                jq -r ".versions | map(select(.id == \"$version\") | .url) | .[0]")
            url=$(wget -O - -q $versionurl | jq -r '.downloads.server.url')
            rmident=vanilla
            jarFile=${rmident}-${version}.jar
            ;;

        purpur)
            if [ "$BUILD" = "latest"]; then
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
            fi
            url=https://api.purpurmc.org/v2/purpur/${version}/${LATEST_BUILD}/download
            rmident=purpur
            jarFile=${rmident}-${version}-${LATEST_BUILD}.jar
            ;;

        fabric)
            if [ "$BUILD" = "latest"]; then
                LATEST_BUILD=$(wget -O - -q https://meta.fabricmc.net/v2/versions/loader/${version}/ | \
                    jq -r ".[0].loader.version")
            
                if [ -z "$LATEST_BUILD" ]; then
                    echo "Invalid version"
                    exit 1
                fi
                if [ "$LATEST_BUILD" = "null" ]; then
                    echo "No stable build for version $version found :("
                    exit 2
                fi
            fi
            INSTALLER=$(wget -O - -q https://meta.fabricmc.net/v2/versions/installer/ | \
                    jq -r ".[0].version")
            url=https://meta.fabricmc.net/v2/versions/loader/${version}/${LATEST_BUILD}/${INSTALLER}/server/jar
            rmident=fabric
            jarFile=${rmident}-${version}-${LATEST_BUILD}.jar
            ;;

        *)
        echo "Unknows jar type, use one of these:"
        echo " -> vanilla, paper, purpur"
        echo " -> TODO: Forge, NeoForge, Fabrik"
            exit 1
            ;;
    esac

    if ! [ -f "$jarFile" ]; then
        rm -f ${rmident}-*.jar
        if ! wget -O "$jarFile" -q "$url"; then
            echo "Could not download server file, have you checked if the build exist?"
            exit 2
        else
            echo "Download successful"
        fi
    fi
fi

if [ "$EULA" = "true" ]; then 
	echo "eula=true" > ./eula.txt
    # different start arguments for different server types
    case "$jarType" in
        vanilla)
            exec java -jar "$jarFile" -nogui
            ;;
        paper)
            exec java -jar "$jarFile" -nogui
            ;;
        purpur)
            exec java -jar "$jarFile" -nogui
            ;;
        fabric)
            exec java -jar "$jarFile" -nogui
            ;;
else
	echo "eula=false" > ./eula.txt
    echo "Accept the eula"
	echo "enviroment variable: EULA=true"
fi	

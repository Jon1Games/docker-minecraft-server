# docker-minecraft-server

## Start

```sh
sudo docker run -it \
-p 25565:25565 \
-v ./minecraft-server:/data/ \
-e jarType=vanilla -e version=1.20.4 -e EULA=true \
--name Minecraft-Server \
Jon1Games/minecraft-server
```

supported jar types are:

- vanilla
- paper
- purpur

First you need to create an volume for the server
```sh
sudo docker volume  create minecraft-server
```

Then to start the Docker Container you can use this command:
```sh
sudo docker run -it \
--mount 'type=volume,src=minecraft-server,dst=/data' \
-e jarType=vanilla -e version=1.20.4 -e EULA=true \
-p 25565:25565 \
Jon1Games/minecraft-server
```

supported jar types are:
- vanilla
- paper
- purpur

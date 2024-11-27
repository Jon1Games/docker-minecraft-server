FROM eclipse-temurin:21-jre

VOLUME ["/data"]
WORKDIR /data

RUN apt update
RUN apt -y install jq wget

COPY --chmod=755 scripts/start.sh /

EXPOSE 25565/tcp

CMD ["/bin/sh", "/start.sh"]

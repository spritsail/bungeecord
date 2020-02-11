ARG BUNGEECORD_BUILD=1478

FROM spritsail/alpine:3.11 AS compile

ARG BUNGEECORD_BUILD

WORKDIR /build

RUN apk --no-cache add jq maven openjdk8 nss && \
    COMMIT="$(wget -O- https://ci.md-5.net/job/BungeeCord/${BUNGEECORD_BUILD}/api/json | \
        jq -r '.actions[] | select(.["_class"] == "hudson.plugins.git.util.BuildData").buildsByBranchName["refs/remotes/origin/master"].marked.SHA1')" && \
    wget -O- https://github.com/SpigotMC/BungeeCord/tarball/${COMMIT} \
        | tar xz --strip-components=1 && \
    \
    # Apply custom patches here
    wget -O- https://patch-diff.githubusercontent.com/raw/SpigotMC/BungeeCord/pull/2615.diff | patch -p1 && \
    \
    mvn package -Dbuild.number=${BUNGEECORD_BUILD} -U

FROM spritsail/alpine:3.11

ARG BUNGEECORD_BUILD

LABEL maintainer="Spritsail <bungeecord@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Bungeecord" \
      org.label-schema.url="https://www.spigotmc.org/wiki/bungeecord/" \
      org.label-schema.description="A minecraft server proxy" \
      org.label-schema.version=${BUNGEECORD_BUILD} \
      io.spritsail.version.bungeecord=${BUNGEECORD_BUILD}

COPY --from=compile /build/bootstrap/target/BungeeCord.jar /bungeecord.jar
RUN apk --no-cache add openjdk8-jre nss

WORKDIR /config
VOLUME /config

# Default as per https://github.com/SpigotMC/BungeeCord/blob/730715e68b7a6fe4b64e3b7a9b3b166d35f30abe/log/src/main/java/net/md_5/bungee/log/ConciseFormatter.java#L13
ENV DATE_FORMAT=HH:mm:ss

CMD exec java \
        -Dnet.md_5.bungee.log-date-format=${DATE_FORMAT} \
        -jar /bungeecord.jar

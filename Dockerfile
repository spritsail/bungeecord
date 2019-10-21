ARG BUNGEECORD_BUILD=1421

FROM spritsail/alpine:3.10 AS compile

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

FROM spritsail/alpine:3.10

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

CMD [ "java", "-jar", "/bungeecord.jar" ]

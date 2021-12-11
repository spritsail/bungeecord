ARG BUNGEECORD_BUILD=1619

FROM spritsail/alpine:3.15 AS compile

ARG BUNGEECORD_BUILD

WORKDIR /build

RUN apk --no-cache add jq maven openjdk17 nss git && \
    COMMIT="$(wget -O- https://ci.md-5.net/job/BungeeCord/${BUNGEECORD_BUILD}/api/json | \
        jq -r '.actions[] | select(.["_class"] == "hudson.plugins.git.util.BuildData").buildsByBranchName["refs/remotes/origin/master"].marked.SHA1')" && \
    \
	git init && \
	git remote add origin https://github.com/SpigotMC/BungeeCord.git && \
	git fetch --depth 1 origin "${COMMIT}" && \
	git checkout ${COMMIT} && \
	git config --local user.name docker && \
	git config --local user.email docker@builder.ci && \
    \
    # Apply custom patches here
    git fetch origin pull/2615/head && git cherry-pick FETCH_HEAD && \
    \
    mvn package -Dbuild.number=${BUNGEECORD_BUILD} -U

FROM spritsail/alpine:3.15

ARG BUNGEECORD_BUILD

LABEL maintainer="Spritsail <bungeecord@spritsail.io>" \
      org.label-schema.vendor="Spritsail" \
      org.label-schema.name="Bungeecord" \
      org.label-schema.url="https://www.spigotmc.org/wiki/bungeecord/" \
      org.label-schema.description="A minecraft server proxy" \
      org.label-schema.version=${BUNGEECORD_BUILD} \
      io.spritsail.version.bungeecord=${BUNGEECORD_BUILD}

COPY --from=compile /build/bootstrap/target/BungeeCord.jar /bungeecord.jar
RUN apk --no-cache add openjdk17-jre-headless nss

WORKDIR /config
VOLUME /config

# Date format default: https://github.com/SpigotMC/BungeeCord/blob/730715e68b7a6fe4b64e3b7a9b3b166d35f30abe/log/src/main/java/net/md_5/bungee/log/ConciseFormatter.java#L13
ENV SNAPSHOT=true \
    DATE_FORMAT=HH:mm:ss \
    CONSOLE_LOG_LEVEL=INFO \
    FILE_LOG_LEVEL=INFO

CMD exec java \
        -Dlog4j2.formatMsgNoLookups=true \
        -Dnet.md_5.bungee.protocol.snapshot=${SNAPSHOT} \
        -Dnet.md_5.bungee.log-date-format=${DATE_FORMAT} \
        -Dnet.md_5.bungee.file-log-level=${CONSOLE_LOG_LEVEL} \
        -Dnet.md_5.bungee.console-log-level=${FILE_LOG_LEVEL} \
        -jar /bungeecord.jar

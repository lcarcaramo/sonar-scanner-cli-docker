FROM quay.io/ibmz/alpine:3.12
ENV JAVA_VERSION="jdk-11.0.6+10" \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

#
# musl setup
#

RUN set -eux; \
    apk add --no-cache musl zlib; \
    
#
# AdoptOpenJDK/openjdk11 setup
#

WORKDIR /opt/java/openjdk

RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps curl; \
    ARCH="$(apk --print-arch)"; \
    case "${ARCH}" in \
       s390x) \
         ESUM='bcb3f46cbad742b08c81e922e313549c029f436ac7d91ef3c9bed8e4049d67d2'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jre_s390x_linux_hotspot_11.0.6_10.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    apk del --purge .fetch-deps; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/openjdk.tar.gz;

ARG SONAR_SCANNER_HOME=/opt/sonar-scanner
ARG SONAR_SCANNER_VERSION=4.5.0.2216
ARG NODEJS_HOME=/opt/nodejs
ARG UID=1000
ARG GID=1000
ENV JAVA_HOME=/opt/java/openjdk \
    HOME=/tmp \
    XDG_CONFIG_HOME=/tmp \
    SONAR_SCANNER_HOME=${SONAR_SCANNER_HOME} \
    SONAR_USER_HOME=${SONAR_SCANNER_HOME}/.sonar \
    NODEJS_HOME=${NODEJS_HOME} \
    NODEJS_VERSION=v12.18.2 \
    PATH=/opt/java/openjdk/bin:${SONAR_SCANNER_HOME}/bin:${NODEJS_HOME}/bin:${PATH} \
    NODE_PATH=${NODEJS_HOME}/lib/node_modules \
    SRC_PATH=/usr/src

WORKDIR /opt

RUN set -ex \
    && addgroup -S -g ${GID} scanner-cli \
    && adduser -S -D -u ${UID} -G scanner-cli scanner-cli \
    && apk add --no-cache --virtual build-dependencies wget unzip gnupg \
    && apk add --no-cache git python3 bash shellcheck \
    && wget -U "scannercli" -q -O /opt/sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip \
    && wget -U "scannercli" -q -O /opt/sonar-scanner-cli.zip.asc https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip.asc \
    && wget -U "scannercli" -q -O /opt/sonarsource-public.key https://binaries.sonarsource.com/sonarsource-public.key \
    && gpg --import /opt/sonarsource-public.key \
    && gpg --verify /opt/sonar-scanner-cli.zip.asc /opt/sonar-scanner-cli.zip \
    && unzip sonar-scanner-cli.zip \
    && rm sonar-scanner-cli.zip sonar-scanner-cli.zip.asc \
    && mv sonar-scanner-${SONAR_SCANNER_VERSION} ${SONAR_SCANNER_HOME} \
    && wget -U "nodejs" -q -O node-${NODEJS_VERSION}-linux-x64.tar.xz https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.xz \
    && wget -U "nodejs" -q -O SHASUMS256.txt https://nodejs.org/dist/${NODEJS_VERSION}/SHASUMS256.txt \
    && wget -U "nodejs" -q -O SHASUMS256.txt.sig https://nodejs.org/dist/${NODEJS_VERSION}/SHASUMS256.txt.sig \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 4ED778F539E3634C779C87C6D7062848A1AB005C \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 108F52B48DB57BB0CC439B2997B01419BD92F80A \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    && gpg --verify SHASUMS256.txt.sig SHASUMS256.txt \
    && grep node-${NODEJS_VERSION}-linux-x64.tar.xz SHASUMS256.txt | sha256sum -c - \
    && tar Jxf node-${NODEJS_VERSION}-linux-x64.tar.xz --no-same-owner \
    && rm node-${NODEJS_VERSION}-linux-x64.tar.xz SHASUMS256.txt SHASUMS256.txt.sig /tmp/.gnupg/pubring.kbx /tmp/.gnupg/trustdb.gpg \
    && mv node-${NODEJS_VERSION}-linux-x64 ${NODEJS_HOME} \
    && npm install -g typescript@3.7.5 \
    && pip3 install --upgrade pip \
    && pip install pylint \
    && apk del --purge build-dependencies \
    && mkdir -p "${SRC_PATH}" "${SONAR_USER_HOME}" "${SONAR_USER_HOME}/cache"\
    && chown -R scanner-cli:scanner-cli "${SONAR_SCANNER_HOME}" "${SRC_PATH}" \
    && chmod -R 777 "${SRC_PATH}" "${SONAR_USER_HOME}"

COPY --chown=scanner-cli:scanner-cli bin /usr/bin/

WORKDIR ${SRC_PATH}

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["sonar-scanner"]

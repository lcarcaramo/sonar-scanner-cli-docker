FROM quay.io/ibmz/openjdk:11.0.8

ARG SONAR_SCANNER_HOME=/opt/sonar-scanner
ARG SONAR_SCANNER_VERSION=4.5.0.2216
ARG UID=1001
ARG GID=1001
ENV HOME=/tmp \
    XDG_CONFIG_HOME=/tmp \
    SONAR_SCANNER_HOME=${SONAR_SCANNER_HOME} \
    SONAR_USER_HOME=${SONAR_SCANNER_HOME}/.sonar \
    PATH=${SONAR_SCANNER_HOME}/bin:${PATH} \
    SRC_PATH=/usr/src

WORKDIR /opt

RUN set -ex; \
    addgroup --system --gid ${GID} scanner-cli; \
    adduser --system --uid ${UID} --gid ${GID} --disabled-password scanner-cli; \
    apt-get update && apt-get install -y --no-install-recommends \
                            wget \
                            unzip \
                            gnupg \
                            git \
                            python3 \
                            bash \
                            shellcheck; \
    wget -U "scannercli" -q -O /opt/sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip; \
    wget -U "scannercli" -q -O /opt/sonar-scanner-cli.zip.asc https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip.asc; \
    wget -U "scannercli" -q -O /opt/sonarsource-public.key https://binaries.sonarsource.com/sonarsource-public.key; \
    gpg --import /opt/sonarsource-public.key; \
    gpg --verify /opt/sonar-scanner-cli.zip.asc /opt/sonar-scanner-cli.zip; \
    unzip sonar-scanner-cli.zip; \
    rm sonar-scanner-cli.zip sonar-scanner-cli.zip.asc; \
    mv sonar-scanner-${SONAR_SCANNER_VERSION} ${SONAR_SCANNER_HOME}; \
    npm install -g typescript@3.7.5; \
    pip install --upgrade pip; \
    pip install pylint; \
    apt-get remove -y wget gnupg unzip; \
    apt-get autoremove -y && apt-get clean; \
    mkdir -p "${SRC_PATH}" "${SONAR_USER_HOME}" "${SONAR_USER_HOME}/cache"; \
    chown -R scanner-cli:scanner-cli "${SONAR_SCANNER_HOME}" "${SRC_PATH}"; \
    chmod -R 777 "${SRC_PATH}" "${SONAR_USER_HOME}"

COPY --chown=scanner-cli:scanner-cli bin /usr/bin/

WORKDIR ${SRC_PATH}

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["sonar-scanner"]

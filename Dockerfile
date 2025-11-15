FROM alpine:3.20 AS base

ENV BUN_INSTALL=/usr/local/bin/bun
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

# 必要パッケージ
RUN apk add --no-cache curl unzip libstdc++ libgcc

# install bun
RUN curl -fsSL https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64-musl.zip -o /tmp/bun.zip \
    && unzip /tmp/bun.zip -d /tmp/. \
    && rm /tmp/bun.zip \
    && mv /tmp/bun-linux-x64-musl/bun ${BUN_INSTALL} \
    && chmod +x $BUN_INSTALL

# test
RUN bun --version

WORKDIR /app
COPY . .
CMD ["bun", "run", "start"]

# FROM alpine:3.22.2 as base

# ENV WORKDIR_PATH=/workdir

# # Installs latest Chromium package.
# RUN apk upgrade --no-cache --available \
#     && apk add --no-cache \
#     chromium-swiftshader

# # Add Chrome as a user
# RUN mkdir -p ${WORKDIR_PATH} \
#     && adduser -D chrome \
#     && chown -R chrome:chrome ${WORKDIR_PATH}
# # Run Chrome as non-privileged
# USER chrome
# WORKDIR ${WORKDIR_PATH}

# ENV CHROME_BIN=/usr/bin/chromium \
#     CHROME_PATH=/usr/lib/chromium/

# # Autorun chrome headless
# ENV CHROMIUM_FLAGS="--disable-software-rasterizer --disable-dev-shm-usage"
# ENTRYPOINT ["chromium", "--headless"]

# USER root
# RUN apk add --no-cache \
#     tini \
#     nodejs


FROM base as builder

WORKDIR ${WORKDIR_PATH}

USER root
RUN apk add --no-cache \
    npm

COPY --chown=chrome package.json package-lock.json ./
RUN npm ci --only=prod --no-audit


FROM base

ARG WORKDIR_PATH

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium
ENV NODE_ENV production
WORKDIR ${WORKDIR_PATH}
# COPY --from=builder --chown=chrome:chrome ${WORKDIR_PATH}/node_modules ./node_modules
COPY --chown=chrome src ./src
# ENTRYPOINT ["tini", "--"]
CMD ["node", "${WORKDIR_PATH}/src/useragent"]

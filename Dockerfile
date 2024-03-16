FROM alpine:3.19 as base

# Installs latest Chromium package.
RUN apk upgrade --no-cache --available \
    && apk add --no-cache \
    chromium-swiftshader

# Add Chrome as a user
RUN mkdir -p /usr/src/app \
    && adduser -D chrome \
    && chown -R chrome:chrome /usr/src/app
# Run Chrome as non-privileged
USER chrome
WORKDIR /usr/src/app

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

# Autorun chrome headless
ENV CHROMIUM_FLAGS="--disable-software-rasterizer --disable-dev-shm-usage"
ENTRYPOINT ["chromium-browser", "--headless"]

FROM base as node

USER root
RUN apk add --no-cache \
    tini \
    nodejs npm

USER chrome
ENTRYPOINT ["tini", "--"]

FROM node as playwright

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium-browser
WORKDIR /usr/src/app
COPY --chown=chrome package.json package-lock.json ./
RUN npm install
COPY --chown=chrome . ./
ENTRYPOINT ["tini", "--"]
CMD ["node", "/usr/src/app/src/useragent"]

FROM node:12.12-alpine

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY package*.json ./

# Install chromium & system fonts
RUN apt-get install -y --no-install-recommends libgconf-2-4 fontconfig curl sudo \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
       >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-unstable \
         ttf-freefont fonts-ipafont-gothic \
    && mkdir -p /usr/share/fonts/emoji \
    && curl --location --silent --show-error --out /usr/share/fonts/emoji/emojione-android.ttf \
         https://github.com/emojione/emojione-assets/releases/download/3.1.2/emojione-android.ttf \
    && chmod -R +rx /usr/share/fonts/ \
    && fc-cache -fv \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /var/lib/apt/lists/* /usr/share/icons/Adwaita/256x256/apps

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Uncomment to skip the chromium download when installing puppeteer. 
# If you do, you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true    

USER node
RUN npm install
COPY --chown=node:node . .
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD [ "npm", "start" ]
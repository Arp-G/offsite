FROM elixir:1.12.2

# Install node js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs zip

# Install global node dependencies
RUN npm install --verbose --global command-line-args transmission

WORKDIR /app
COPY . /app

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile

ENTRYPOINT ["sh", "./startup.sh"]

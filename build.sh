#!/bin/bash

apt install nodejs -g   # install nodejs
apt install npm -g  # update npm to latest version
apt install jq

mkdir workspace
cd workspace
npm init -y
touch index.html
npm install http-server --save
echo "<h1>Hello World</h1>" > index.html
```

```bash

jq '.scripts.start = "http-server"' package.json > temp.json && mv temp.json package.json
/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for
 * license information.
 */

'use strict';

const http = require('http');
const EventDrivenSecretCache = require('../secret-cache');

const hostname = '127.0.0.1';
const port = 3000;

process.env['AZURE_KEYVAULT_NAME'] = 'kv-secret-cache';
process.env['AZURE_CLIENT_ID'] = '55d7e915-8dda-45f9-b67f-69222d7264fd';
process.env['AZURE_CLIENT_SECRET'] = '327491ae-b4f2-4da7-9b39-e360562a9d1b';
process.env['AZURE_TENANT_ID'] = '215fd765-750e-4adf-8bb7-7a009994dde6';

const server = http.createServer(async (req, res) => {
  var cache = new EventDrivenSecretCache();
  await cache.init();

  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  const json = cache.secrets['ServiceDiscoveryData'];
  res.end(json);
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
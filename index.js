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

process.env['AZURE_KEYVAULT_NAME'] = 't-akv-2n-searchpage-01';
process.env['AZURE_CLIENT_ID'] = '';
process.env['AZURE_CLIENT_SECRET'] = '';
process.env['AZURE_TENANT_ID'] = '';

const server = http.createServer(async (req, res) => {
  var cache = new EventDrivenSecretCache();
  await cache.init();

  const json = { message: 'hello azure.' }
  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(json));
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
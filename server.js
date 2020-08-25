/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for
 * license information.
 */

const http = require('http');
const EventDrivenSecretCache = require('@mcs/secret-cache');

process.env['AZURE_KEYVAULT_NAME'] = '';
process.env['AZURE_CLIENT_ID'] = '';
process.env['AZURE_CLIENT_SECRET'] = '';
process.env['AZURE_TENANT_ID'] = '';

const server = http.createServer(async (req, res) => {
  var cache = new EventDrivenSecretCache();
  await cache.init();

  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  const json = cache.secrets['ServiceDiscoveryData'];
  res.end(json);
});

const port = process.env.PORT || 3000;

server.listen(port, () => {
  console.log(`Server running at http://${process.env.HOST}:${port}/`);
});

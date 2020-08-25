/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for
 * license information.
 */

const express = require('express');
const EventDrivenSecretCache = require('@mcs/secret-cache');

process.env['AZURE_KEYVAULT_NAME'] = '';
process.env['AZURE_CLIENT_ID'] = '';
process.env['AZURE_CLIENT_SECRET'] = '';
process.env['AZURE_TENANT_ID'] = '';

const server = express();
const port = process.env.PORT || 3000;
const cache = new EventDrivenSecretCache(server);

server.get("/", (_req, res) => {
  res.status(200).set('Content-Type', 'application/json').end(JSON.stringify(cache.secrets));
});

server.listen(port, async () => {
  await cache.init();
  console.log(`🚀 Server running on port ${port}!`);
});
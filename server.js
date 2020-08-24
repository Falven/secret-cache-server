/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for
 * license information.
 */

const express = require('express');
const EventDrivenSecretCache = require('@mcs/secret-cache');

process.env['AZURE_KEYVAULT_NAME'] = 'kv-secret-cache';
process.env['AZURE_CLIENT_ID'] = '55d7e915-8dda-45f9-b67f-69222d7264fd';
process.env['AZURE_CLIENT_SECRET'] = '327491ae-b4f2-4da7-9b39-e360562a9d1b';
process.env['AZURE_TENANT_ID'] = '215fd765-750e-4adf-8bb7-7a009994dde6';

const server = express();
const port = process.env.PORT || 3000;
const cache = new EventDrivenSecretCache();

server.get("/", (_req, res) => {
  res.status(200).set('Content-Type', 'application/json').end(JSON.stringify(cache.secrets));
});

server.listen(port, async () => {
  await cache.init();
  console.log(`🚀 Server running on port ${port}`);
});
/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for
 * license information.
 */

const express = require('express');
const bodyParser = require('body-parser');
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

server.use(bodyParser.json());

server.post("/api/updates", async (req, res) => {
  console.log('Received Event.');
  console.log('Headers:\n' + JSON.stringify(req.headers));
  console.log('Body:\n' + JSON.stringify(req.body));

  var header = req.get("Aeg-Event-Type");
  if (header && req.body && Object.keys(req.body).length > 0) {
    console.log('Header exists.');
    var event = req.body[0];

    if (event && event.eventType && event.data) {
      console.log('Body exists.');
      // Check for Webhook validation handshake event type.
      if (header === 'SubscriptionValidation') {
        console.log('SubscriptionValidation event.');
        if (event.data.validationCode && event.eventType == 'Microsoft.EventGrid.SubscriptionValidationEvent') {
          console.log('Microsoft.EventGrid.SubscriptionValidationEvent');
          return res.send({"validationResponse": event.data.validationCode})
        }
      }

      // Check for KeyVault secret event type.
      if (header === 'Notification') {
        console.log('Notification event.');
        if (event.eventType == 'Microsoft.KeyVault.SecretNewVersionCreated') {
          console.log('Microsoft.KeyVault.SecretNewVersionCreated');
          await cache.updateSecret(event.data.ObjectName);
          return res.status(200).end();
        }
      }
    }
  }
});

server.listen(port, async () => {
  await cache.init();
  console.log(`🚀 Server running on port ${port}`);
});
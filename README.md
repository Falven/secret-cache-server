# Azure Key Vault + Azure Event Grid: a match made in the cloud.

Let's say you have an application that needs to maintain secrets such as passwords and database connection strings, Cryptographic keys or other secrets.  

So you look to the cloud and find that Azure Key Vault perfectly meets your needs of securely storing and managing your application secrets.

However, maybe your application frequently uses these secrets, but keeping your application secrets on disk is not an option from a security standpoint, a common issue with enterprise applications.

## Polling Solution

You begin to design a solution. The first solution that comes to mind involves keeping a cache of your secrets in memory. It sounds great in theory, however, an issue comes to mind:

*How would we update the application when we change any of our secrets in Key Vault?*

![Polling Design](https://raw.githubusercontent.com/Falven/secret-cache-server/master/images/Polling Design.jpg)

1. The application goes to Azure and retrieves our secrets.
2. Secrets are kept in-memory and accessed as needed.
3. Our application continues to poll Azure at an interval (say, 5 minutes) for any changes to our secrets.

While a decent solution, several issues come to mind:
- What if any of our secrets expire? Our application wouldn't be in sync with azure until it polls again 5 minutes later.
- Polling is an expensive operation; we don't want our application needlessly and frequently sending requests to Azure, saturating our network bandwidth, CPU, increasing our cost, and reducing our application throughput.
- Our application would have to needlessly fetch all secrets each interval as it would not know which have changed. This can be exponentially expensive with many secrets.

## Event Grid Solution

Azure Event Grid to the rescue. With Event Grid, we can have event-driven secrets management. What this means is event grid can seamlessly notify our application when a secret has been updated.

![EventGrid Design](https://raw.githubusercontent.com/Falven/secret-cache-server/master/images/EventGrid Design.jpg)

1. The application goes to Azure and retrieves our secrets.
2. Secrets are kept in-memory and accessed as needed.
3. Whenever a secret changes, KeyVault notifies EventGrid in the cloud.
4. EventGrid then notifies our application of the specific change, allowing the application to react to specific changes in our KeyVault.

## Setup

This repository represents a simplified Event Grid solution implementation.
It is a simple express server that uses our [secret-cache](https://github.com/Falven/secret-cache) implementation to maintain our cache of secrets. It is written in [Node.js](https://nodejs.org/en/) and uses [Express.js](https://expressjs.com/). Initial setup of Node and NPM is not covered here.

The first thing that needs to be done is to set up some Azure infrastructure. We will need a Web App and Key Vault instances on Azure. I have provided 2 scripts that greatly simplify creating these resources on Azure.

Creating the Event Grid event subscription requires our server to be running with our **/api/updates** endpoint available, as Event Grid will attempt to perform a **SubscriptionValidation Handshake** with our application to validate the endpoint. So Event Grid should be the last resource you set up on Azure after deploying our application.

### 1. Infrastructure setup
To run each script, first fill out all of the [Powershell Core](https://github.com/PowerShell/PowerShell) variables on the top, identifying things such as the subscription where you want to provision your infrastructure and the resource group to put the resources under.

### 2. Server deployment
Building the server is simply a matter of downloading the source and running an `npm install`, ensuring that it retrieves our [secret-cache](https://github.com/Falven/secret-cache) module. From there you may deploy the solution to our Azure Web App in a myriad of ways.

### 3. Event Grid subscription
To set up our Event Grid subscription you can follow the [**Creating an Event Grid subscription** steps outlined in this article](https://docs.microsoft.com/en-us/azure/key-vault/general/event-grid-tutorial#create-an-event-grid-subscription).

When creating the subscription as shown in the article:
1. You may pick any event subscription name.
2. Select Event Grid Schema.
3. Our topic source should be the Key Vault you created.
4. Select all of the Key Vault secret events under event types.
5. Select a webhookk endpoint type and enter our application endpoint in the form of `https://ourapplicationname.azurewebsites.net/api/updates`.
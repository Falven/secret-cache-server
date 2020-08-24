# It is recommended to follow [Azure Naming and Tagging Best Practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

# You can get this from the Azure Portal under "Navigate" select "Subscriptions" and copy the appropriate ID.
# Or you can use the Get-AzureSubscription cmdlet.
$SUBSCRIPTION_ID = ''

$RESOURCE_GROUP_NAME = ''
$RESOURCE_GROUP_LOCATION = ''

$KEYVAULT_NAME = ''
$SERVICE_PRINCIPAL_NAME = ''

$EVENT_GRID_TOPIC_NAME = ''
$EVENT_GRID_SUB_NAME = ''
$EVENT_GRID_ENDPOINT = ''

$NL = [Environment]::NewLine

Write-Host "$($NL)Log into our Azure Account" -ForegroundColor DarkBlue
az login

Write-Host "$($NL)Set our subscription" -ForegroundColor DarkBlue
az account set --subscription $SUBSCRIPTION_ID

$rgExists = az group exists -n $RESOURCE_GROUP_NAME
if ($rgExists -eq 'false') {
  Write-Host "$($NL)Create a Resource Group for our Event Grid" -ForegroundColor DarkBlue
  az group create --name $RESOURCE_GROUP_NAME --location $RESOURCE_GROUP_LOCATION
}

Write-Host "$($NL)Register the Event Grid resource provider" -ForegroundColor DarkBlue
az provider register --namespace Microsoft.EventGrid

Write-Host "$($NL)Create Event Grid topic" -ForegroundColor DarkBlue
az eventgrid topic create --name $EVENT_GRID_TOPIC_NAME -l $RESOURCE_GROUP_LOCATION -g $RESOURCE_GROUP_NAME

Write-Host "$($NL)Subscribe our endpoint to our topic" -ForegroundColor DarkBlue
az eventgrid event-subscription create --source-resource-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.EventGrid/topics/$EVENT_GRID_TOPIC_NAME" --name $EVENT_GRID_SUB_NAME --endpoint-type 'webhook' --endpoint $EVENT_GRID_ENDPOINT

Write-Host @"
Azure Event Grid Parameters:
Client Id:          $SERVICE_PRINCIPAL_APP_ID
Client Secret:      $SERVICE_PRINCIPAL_PASSWORD
Tenant Id:          $TENANT_ID
Subscription Id:    $SUBSCRIPTION_ID
Vault Uri:          $KEYVAULT_URI
Api Version:        2016-10-01
Key Vault Resource: https://vault.azure.net
"@ -ForegroundColor DarkGreen
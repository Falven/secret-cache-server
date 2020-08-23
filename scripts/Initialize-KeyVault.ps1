# It is recommended to follow [Azure Naming and Tagging Best Practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

# You can get this from the Azure Portal under "Navigate" select "Subscriptions" and copy the appropriate ID.
# Or you can use the Get-AzureSubscription cmdlet.
$SUBSCRIPTION_ID = ''

$RESOURCE_GROUP_NAME = ''
$RESOURCE_GROUP_LOCATION = ''

$KEYVAULT_NAME = ''

$KEYVAULT = @{
}

$SERVICE_PRINCIPAL_NAME = ''

$NL = [Environment]::NewLine

Write-Host "$($NL)Log into our Azure Account" -ForegroundColor DarkBlue
az login

Write-Host "$($NL)Set our subscription" -ForegroundColor DarkBlue
az account set --subscription $SUBSCRIPTION_ID

$rgExists = az group exists -n $RESOURCE_GROUP_NAME
if ($rgExists -eq 'false') {
  Write-Host "$($NL)Create a Resource Group to hold our Key Vault" -ForegroundColor DarkBlue
  az group create --name $RESOURCE_GROUP_NAME --location $RESOURCE_GROUP_LOCATION
}

Write-Host "$($NL)Create Our Key Vault within our Resource Group" -ForegroundColor DarkBlue
az keyvault create --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP_NAME

Write-Host "$($NL)Get our Key Vault's URI" -ForegroundColor DarkBlue
$KEYVAULT_URI = $(az keyvault show --name $KEYVAULT_NAME --query properties.vaultUri -otsv)

Write-Host "$($NL)Populate our secrets" -ForegroundColor DarkBlue
foreach ($secret in $KEYVAULT.GetEnumerator()) { az keyvault secret set --name $secret.Name --vault-name $KEYVAULT_NAME --value $secret.Value }

Write-Host "$($NL)Create a service principal to access the Key Vault" -ForegroundColor DarkBlue
$SERVICE_PRINCIPAL_PASSWORD = $((az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME) | Out-String | ConvertFrom-Json).password

Write-Host "$($NL)Get the App ID for our Service Principal" -ForegroundColor DarkBlue
$SERVICE_PRINCIPAL_APP_ID = $(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query [0].appId -otsv)
Write-Host $SERVICE_PRINCIPAL_APP_ID

Write-Host "$($NL)Give our Service Principal 'get' access to our Key Vault" -ForegroundColor DarkBlue
az keyvault set-policy --name $KEYVAULT_NAME --spn http://$SERVICE_PRINCIPAL_NAME --secret-permissions get

Write-Host "$($NL)Get the tenant id for our account" -ForegroundColor DarkBlue
$TENANT_ID = $(az account show --query tenantId -otsv)

Write-Host @"
Azure Key Vault Parameters:
Client Id:          $SERVICE_PRINCIPAL_APP_ID
Client Secret:      $SERVICE_PRINCIPAL_PASSWORD
Tenant Id:          $TENANT_ID
Subscription Id:    $SUBSCRIPTION_ID
Vault Uri:          $KEYVAULT_URI
Api Version:        2016-10-01
Key Vault Resource: https://vault.azure.net
"@ -ForegroundColor DarkGreen
# It is recommended to follow [Azure Naming and Tagging Best Practices](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

# You can get this from the Azure Portal under "Navigate" select "Subscriptions" and copy the appropriate ID.
# Or you can use the Get-AzureSubscription cmdlet.
$SUBSCRIPTION_ID = ''

$RESOURCE_GROUP_NAME = ''
$RESOURCE_GROUP_LOCATION = ''

$WEB_APP_NAME = ''
$WEB_APP_SKU = ''

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

Write-Host "$($NL)Create an App Service plan in $WEB_APP_SKU tier" -ForegroundColor DarkBlue
az appservice plan create --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --sku $WEB_APP_SKU --is-linux

Write-Host "$($NL)Create our Web App" -ForegroundColor DarkBlue
az webapp create --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME --plan $WEB_APP_NAME --runtime '"node|12.9"'

Write-Host "$($NL)Opening our Web App" -ForegroundColor DarkBlue
az webapp browse --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME

Write-Host @"
Azure Web App:
https://$WEB_APP_NAME.azurewebsites.net/
$GIT_REPO
$GIT_REPO_BRANCH
"@ -ForegroundColor DarkGreen
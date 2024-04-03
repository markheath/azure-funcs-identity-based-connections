# Set variables
$subscription = "mysubscription"
$resourceGroupName = "mrh-funcs-identity"
$location = "westeurope"
$functionAppName = "mrh-funcs-identity-01"
$storageAccountName = "mrhfuncsidentity01"
$serviceBusNamespace = "mrhfuncsidentity01"

az account set --subscription $subscription

# Create a resource group
az group create --name $resourceGroupName --location $location

# Create a storage account
az storage account create --name $storageAccountName `
    --resource-group $resourceGroupName `
    --location $location `
    --sku Standard_LRS `
    --allow-blob-public-access false

# Create an Azure Functions app with managed identity (and will automatically create App Insights)
az functionapp create --name $functionAppName `
    --resource-group $resourceGroupName `
    --consumption-plan-location $location `
    --functions-version 4 `
    --runtime dotnet-isolated `
    --runtime-version 8 `
    --os-type Windows `
    --storage-account $storageAccountName `
    --assign-identity

# Get the managed identity principal ID
$principalId = az functionapp identity show `
    --name $functionAppName `
    --resource-group $resourceGroupName `
    --query principalId `
    --output tsv

# Get the subscription ID of the current subscription
# $subscriptionId = az account show --query id --output tsv

$storageAccountId = az storage account show -n $storageAccountName -g $resourceGroupName --query id --output tsv

# Grant managed identity access to the storage account
az role assignment create `
    --role "Storage Blob Data Contributor" `
    --assignee $principalId `
    --scope $storageAccountId

# other roles as recommended here to enable Durable Functions, Timer Triggers, Blob Triggers, etc.:
# https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob&pivots=programming-language-csharp#connecting-to-host-storage-with-an-identity
az role assignment create `
    --role "Storage Blob Data Owner" `
    --assignee $principalId `
    --scope $storageAccountId

az role assignment create `
    --role "Storage Account Contributor" `
    --assignee $principalId `
    --scope $storageAccountId

az role assignment create `
    --role "Storage Queue Data Contributor" `
    --assignee $principalId `
    --scope $storageAccountId

az role assignment create `
    --role "Storage Table Data Contributor" `
    --assignee $principalId `
    --scope $storageAccountId

# Get rid of the connection string
az functionapp config appsettings delete `
    --name $functionAppName `
    --resource-group $resourceGroupName `
    --setting-names "AzureWebJobsStorage"

# set up the account name for Azure Functions to use managed identities
az functionapp config appsettings set `
    --name $functionAppName `
    --resource-group $resourceGroupName `
    --settings AzureWebJobsStorage__accountName=${storageAccountName}

# to see settings az functionapp config appsettings list -n $functionAppName -g $resourceGroupName

# publish the function app
func azure functionapp publish $functionAppName

# invoke web request to the create-order function
Invoke-WebRequest -Uri "https://$functionAppName.azurewebsites.net/api/createorder"

# kick off the durable functions
$url = "https://$functionAppName.azurewebsites.net/api/startneworderprocess"
$response = Invoke-RestMethod -Uri $url -Method Get
# check on the progress
$status = Invoke-RestMethod -Uri $response.statusQueryGetUri -Method Get
$status.runtimeStatus
$status.output

# Create Azure Service Bus Namespace
az servicebus namespace create `
    --name $serviceBusNamespace `
    --resource-group $resourceGroupName `
    --location $location

# Create a queue
az servicebus queue create --name "orders" `
    --namespace-name $serviceBusNamespace `
    --resource-group $resourceGroupName

# Create a topic
# az servicebus topic create --name "myTopic" --namespace-name $serviceBusNamespace --resource-group $resourceGroupName

# Create a subscription for the topic
# az servicebus topic subscription create --name "mySubscription" --topic-name "myTopic" --namespace-name $serviceBusNamespace --resource-group $resourceGroupName

$serviceBusNamespaceId = az servicebus namespace show `
    --name $serviceBusNamespace `
    --resource-group $resourceGroupName `
    --query id `
    --output tsv


# Grant managed identity access to the Azure Service Bus namespace
az role assignment create `
    --role "Azure Service Bus Data Sender" `
    --assignee $principalId `
    --scope $serviceBusNamespaceId

# Grant managed identity ability to receive messages from Azure Service Bus namespace
az role assignment create `
    --role "Azure Service Bus Data Receiver" `
    --assignee $principalId `
    --scope $serviceBusNamespaceId

# get the service bus fully qualified namespace
$serviceBusNamespaceFqdn = az servicebus namespace show `
    --name $serviceBusNamespace `
    --resource-group $resourceGroupName `
    --query serviceBusEndpoint `
    --output tsv

# get the domain name only from a URL
$serviceBusNamespaceDomain = [System.Uri]::new($serviceBusNamespaceFqdn).Host

# set up the managed identity connection to service bus
# As explained here: https://learn.microsoft.com/en-us/dotnet/api/overview/azure/microsoft.azure.webjobs.extensions.servicebus-readme?view=azure-dotnet#identity-based-authentication
az functionapp config appsettings set `
    --name $functionAppName `
    --resource-group $resourceGroupName `
    --settings ServiceBusConnection__fullyQualifiedNamespace=${serviceBusNamespaceDomain}

# get the service bus connection string (for your local.settings.json file)
$serviceBusConnectionString = az servicebus namespace authorization-rule keys list `
    --name RootManageSharedAccessKey `
    --namespace-name $serviceBusNamespace `
    --resource-group $resourceGroupName `
    --query primaryConnectionString `
    --output tsv

# get the function invocation key
$functionKey = az functionapp keys list `
    --name $functionAppName `
    --resource-group $resourceGroupName `
    --query "functionKeys.default" `
    --output tsv
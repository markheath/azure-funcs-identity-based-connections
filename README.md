# Functions app to test Identity Based Connections

This function app uses managed identities to access a storage account and an Azure Service Bus namespace.

## Creating your local.settings.json

You need to create a local.settings.json file in order to test this locally. Note that locally I'm not bothering with identity based connections, they are only used when deploying to Azure.

```json
{
    "IsEncrypted": false,
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "ServiceBusConnection": "a connection string to a service bus namespace",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated"
    }
}
```

## Deploying to Azure

The `deploy.ps1` script guides you through the steps to deploy this to Azure and test it out. Note that you'll probably need to make a few changes to names of resources to deploy this yourself - it's not intended to be run in one go.

## Useful links

Articles I found helpful when building this sample.

- https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-based-connections-tutorial
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-based-connections-tutorial-2
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-access-azure-sql-with-managed-identity
- https://dev.to/markusmeyer13/azure-function-with-identity-based-connections-58jd
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=table&pivots=programming-language-csharp#configure-an-identity-based-connection
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob&pivots=programming-language-csharp#connecting-to-host-storage-with-an-identity
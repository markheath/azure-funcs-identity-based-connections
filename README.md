# Functions app to test Identity Based Connections

## Creating your local.settings.json

{
    "IsEncrypted": false,
    "Values": {
        "AzureWebJobsStorage": "UseDevelopmentStorage=true",
        "ServiceBusConnection": "a connection string to a service bus namespace",
        "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated"
    }
}

## Useful links

- https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-based-connections-tutorial
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-based-connections-tutorial-2
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-identity-access-azure-sql-with-managed-identity
- https://dev.to/markusmeyer13/azure-function-with-identity-based-connections-58jd
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=table&pivots=programming-language-csharp#configure-an-identity-based-connection
- https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob&pivots=programming-language-csharp#connecting-to-host-storage-with-an-identity
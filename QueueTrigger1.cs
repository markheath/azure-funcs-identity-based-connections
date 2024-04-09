using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using Azure.Storage.Queues.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MarkHeath.AzureFuncs;

public class QueueTrigger1
{
    private readonly ILogger<QueueTrigger1> _logger;

    public QueueTrigger1(ILogger<QueueTrigger1> logger)
    {
        _logger = logger;
    }

    [Function(nameof(QueueTrigger1))]
    public async Task Run([QueueTrigger("orders", Connection = "AzureWebJobsStorage")] QueueMessage message,
        [BlobInput("orders", Connection = "AzureWebJobsStorage")] BlobContainerClient ordersContainer,
        [BlobInput("orders2", Connection = "StorageAccount2")] BlobContainerClient ordersContainer2)
    {
        _logger.LogInformation($"C# Queue trigger function processed: {message.MessageText}");
        foreach(var container in new BlobContainerClient[] { ordersContainer, ordersContainer2 })
        {
            await container.CreateIfNotExistsAsync();
            var blobClient = container.GetBlobClient($"{message.MessageId}.txt");
            await blobClient.UploadAsync(new BinaryData(message.MessageText));
        }
    }

    [Function(nameof(ServiceBusQueueTrigger))]
    public void ServiceBusQueueTrigger([ServiceBusTrigger("orders", Connection = "ServiceBusConnection")] 
        ServiceBusReceivedMessage message)
    {
        _logger.LogInformation($"Received a message {message.Body} from the Service Bus queue");
    }
}

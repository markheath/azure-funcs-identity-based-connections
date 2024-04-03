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
        [BlobInput("orders", Connection = "AzureWebJobsStorage")] BlobContainerClient ordersContainer)
    {
        _logger.LogInformation($"C# Queue trigger function processed: {message.MessageText}");
        await ordersContainer.CreateIfNotExistsAsync();
        var blobClient = ordersContainer.GetBlobClient($"{message.MessageId}.txt");
        await blobClient.UploadAsync(new BinaryData(message.MessageText));
    }
}

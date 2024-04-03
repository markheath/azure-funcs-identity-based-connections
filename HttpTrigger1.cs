using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace MarkHeath.AzureFuncs;
public class HttpTrigger1
{
    private readonly ILogger<HttpTrigger1> _logger;

    public HttpTrigger1(ILogger<HttpTrigger1> logger)
    {
        _logger = logger;
    }

    [Function(nameof(CreateOrder))]
    public async Task<CreateOrderResponse> CreateOrder(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
    {
        _logger.LogInformation("Created an order.");

        var resp = req.CreateResponse();
        resp.StatusCode = System.Net.HttpStatusCode.OK;
        await resp.WriteStringAsync("Order created.");

        return new CreateOrderResponse() { HttpResponse = resp, QueueMessage = "New order received"};
    }

    [Function(nameof(ServiceBusTest))]
    public async Task<ServiceBusTestResponse> ServiceBusTest(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
    {
        _logger.LogInformation("Going to send a service bus message.");

        var resp = req.CreateResponse();
        resp.StatusCode = System.Net.HttpStatusCode.OK;
        await resp.WriteStringAsync("Service Bus message created.");

        return new ServiceBusTestResponse() { HttpResponse = resp, QueueMessage = "Service bus message"};
    }  
}

public class ServiceBusTestResponse
{
    public required HttpResponseData HttpResponse { get; set; }
    [ServiceBusOutput("orders", Connection = "ServiceBusConnection")]
    public required string QueueMessage { get; set; }
}


public class CreateOrderResponse
{
    public required HttpResponseData HttpResponse { get; set; }
    [QueueOutput("orders", Connection = "AzureWebJobsStorage")]
    public required string QueueMessage { get; set; }
}
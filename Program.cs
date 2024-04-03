using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults() // for ASP.NET Core Integration you have to use .ConfigureFunctionsWebApplication()
    .Build();

host.Run();

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;
using WorkWallet.BI.ClientSample.Services;
using WorkWallet.BI.ClientServices;

try
{
    using IHost host = Host.CreateDefaultBuilder(args)
        .ConfigureServices((context, services) =>
        {
            services
                .Configure<ProcessorServiceOptions>(context.Configuration.GetSection("ClientOptions"))
                .AddProcessorService()
                .AddSQLService(options =>
                {
                    options.SqlDbConnectionString = context.Configuration.GetConnectionString("ClientDb")!;
                })
                .AddSingleton<IProgressService, ProgressService>();
        })
        .Build();

    IServiceProvider serviceProvider = host.Services;

    var tokenSource = new CancellationTokenSource();

    if (!Console.IsOutputRedirected)
    {
        Console.WriteLine("Press ESC to cancel . . .");
        // create a task to listen to keyboard key presses
        var keyBoardTask = Task.Run(() =>
        {
            var key = Console.ReadKey(true);
            if (key.Key == ConsoleKey.Escape)
            {
                tokenSource.Cancel();
            }
        });
    }

    await serviceProvider.GetRequiredService<IProcessorService>().RunAsync(tokenSource.Token);

    return 0;
}
catch (OperationCanceledException)
{
    Console.WriteLine();
    Console.ForegroundColor = ConsoleColor.DarkYellow;
    Console.WriteLine("Cancelled");
    Console.ResetColor();
    return 2;
}
catch (Exception ex)
{
    Console.WriteLine();
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine($"Error: {ex.Message}");
    Console.ResetColor();
    return 1;
}

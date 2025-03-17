using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using WorkWallet.BI.ClientCore.Interfaces.Services;

namespace WorkWallet.BI.ClientFunction;

public class BITimerFunction(
    IProcessorService processorService,
    ILogger<BITimerFunction> logger)
{
    [Function("BITimerTrigger")]
    public async Task Run([TimerTrigger("%BITimerTriggerSchedule%"
#if DEBUG
        , RunOnStartup = true
#endif
        )]TimerInfo timerInfo,
        CancellationToken cancellationToken)
    {
        try
        {
            logger.LogInformation("BITimerTrigger invoked");
            await processorService.RunAsync(cancellationToken);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Function BITimerTrigger threw exception: {Message}", ex.Message);
        }
    }
}

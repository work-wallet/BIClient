using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using WorkWallet.BI.ClientCore.Interfaces.Services;

namespace WorkWallet.BI.ClientFunction
{
    public class BITimerFunction
    {
        private readonly IProcessorService _processorService;
        private readonly ILogger<BITimerFunction> _logger;

        public BITimerFunction(
            IProcessorService processorService,
            ILogger<BITimerFunction> logger)
        {
            _processorService = processorService;
            _logger = logger;
        }

        [Function("BITimerTrigger")]
        public async Task Run([TimerTrigger("%BITimerTriggerSchedule%")]TimerInfo _)
        {
            try
            {
                await _processorService.RunAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Function BITimerTrigger threw exception: {Message}", ex.Message);
            }
        }
    }
}

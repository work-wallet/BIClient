using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
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

        [FunctionName("BITimerTrigger")]
        public async Task Run([TimerTrigger("%BITimerTriggerSchedule%")]TimerInfo myTimer)
        {
            try
            {
                await _processorService.RunAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Function BITimerTrigger threw exception: {ex.Message}");
            }
        }
    }
}

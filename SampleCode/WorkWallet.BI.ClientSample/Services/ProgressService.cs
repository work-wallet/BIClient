using WorkWallet.BI.ClientCore.Interfaces.Services;

namespace WorkWallet.BI.ClientSample.Services;

public class ProgressService : IProgressService
{
    public void WriteWallet(string wallet, string dataRegion)
    {
        Console.WriteLine();
        Console.WriteLine($"{wallet} ({dataRegion})");
    }

    public void StartShowProgress(string dataType, bool reset)
    {
        Console.Write($"{dataType}: ");
        if (reset)
        {
            Console.Write("(reset) ");
        }
    }

    public void ShowProgress()
    {
        Console.Write("*");
    }

    public void EndShowProgress(int records)
    {
        Console.Write($" [{records}]");
        Console.WriteLine();
    }

    public void ReportPageSizeReduced(int oldPageSize, int newPageSize)
    {
        Console.WriteLine();
        Console.WriteLine($"Warning: Page size reduced from {oldPageSize} to {newPageSize} due to server constraints.");
    }

    public void ReportHttpRetry(int attemptNumber, TimeSpan delay, int? statusCode, string? retryAfter)
    {
        Console.WriteLine();
        var statusText = statusCode.HasValue ? $"HTTP {statusCode}" : "Network error";
        var delayText = delay.TotalSeconds < 1 ? $"{delay.TotalMilliseconds:0}ms" : $"{delay.TotalSeconds:0}s";
        
        if (statusCode == 429 && !string.IsNullOrEmpty(retryAfter))
        {
            Console.WriteLine($"Rate limited - retry attempt {attemptNumber} in {delayText} (server requested: {retryAfter})");
        }
        else
        {
            Console.WriteLine($"{statusText} - retry attempt {attemptNumber} in {delayText}");
        }
    }
}

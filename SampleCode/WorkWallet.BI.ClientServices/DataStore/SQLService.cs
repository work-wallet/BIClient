using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Data;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.DataStore;

public class SQLService(
    ILogger<SQLService> logger,
    IOptions<SQLServiceOptions> options) : IDataStoreService
{
    private readonly SQLServiceOptions _options = options.Value;

    public async Task<long?> GetLastSynchronizationVersionAsync(Guid walletId, string logType)
    {
        logger.LogDebug("Obtaining last synchronization version for walletId '{walletId}' and logType '{logType}'", walletId, logType);

        string sql = "SELECT LastSynchronizationVersion FROM mart.ETL_ChangeDetection WHERE WalletId = @walletId AND LogType = @logType AND IsLatest = 1";

        using SqlConnection connection = new(ConnectionString);
        connection.Open();

        using SqlCommand command = new(sql, connection);

        command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;
        command.Parameters.Add("@logType", SqlDbType.NVarChar).Value = logType;

        long? lastSynchronizationVersion = (long?)await command.ExecuteScalarAsync(CancellationToken.None);

        if (lastSynchronizationVersion.HasValue)
        {
            logger.LogDebug("Last synchronization version: {lastSynchronizationVersion}", lastSynchronizationVersion.Value);
        }
        else
        {
            logger.LogDebug($"Last synchronization version is null");
        }

        return lastSynchronizationVersion;
    }

    public async Task LoadAsync(string dataType, string json)
    {
        using SqlConnection connection = new(ConnectionString);
        connection.Open();

        string sp = $"mart.ETL_Load{dataType}";

        logger.LogDebug("Load json data: exec {sp}", sp);

        using SqlCommand command = new(sp, connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add("json", SqlDbType.NVarChar).Value = json;

        await command.ExecuteNonQueryAsync(CancellationToken.None);
    }

    public async Task UpdateLastSyncAsync(Guid walletId, string logType, long synchronizationVersion, int rowsProcessed)
    {
        using SqlConnection connection = new(ConnectionString);
        connection.Open();

        string sp = "mart.ETL_UpdateLastSync";

        logger.LogDebug("Update last sync: exec {sp} @walletId = '{walletId}' @logType = '{logType}' @synchronizationVersion = {synchronizationVersion} @rowsProcessed = {rowsProcessed}", sp, walletId, logType, synchronizationVersion, rowsProcessed);

        using SqlCommand command = new(sp, connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;
        command.Parameters.Add("@logType", SqlDbType.NVarChar).Value = logType;
        command.Parameters.Add("@synchronizationVersion", SqlDbType.BigInt).Value = synchronizationVersion;
        command.Parameters.Add("@rowsProcessed", SqlDbType.Int).Value = rowsProcessed;

        await command.ExecuteNonQueryAsync(CancellationToken.None);
    }

    public async Task ResetAsync(Guid walletId, string dataType)
    {
        using SqlConnection connection = new(ConnectionString);
        connection.Open();

        string sp = $"mart.ETL_Reset{dataType}";

        logger.LogDebug("Reset data: exec {sp} @walletId = '{walletId}'", sp, walletId);

        using SqlCommand command = new(sp, connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;

        await command.ExecuteNonQueryAsync(CancellationToken.None);
    }

    public async Task PostProcessAsync(Guid walletId, string dataType)
    {
        using SqlConnection connection = new(ConnectionString);
        connection.Open();

        string sp = $"mart.ETL_PostProcess{dataType}";

        logger.LogDebug("Post process: exec {sp} @walletId = '{walletId}'", sp, walletId);

        using SqlCommand command = new(sp, connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;

        await command.ExecuteNonQueryAsync(CancellationToken.None);
    }

    private string ConnectionString
    {
        get
        {
            var builder = new SqlConnectionStringBuilder(_options.SqlDbConnectionString);
            return builder.ConnectionString;
        }
    }
}

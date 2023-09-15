using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Data;
using System.Threading.Tasks;
using WorkWallet.BI.ClientCore.Interfaces.Services;
using WorkWallet.BI.ClientCore.Options;

namespace WorkWallet.BI.ClientServices.DataStore
{
    public class SQLService : IDataStoreService
    {
        private readonly ILogger<SQLService> _logger;
        private readonly SQLServiceOptions _options;

        public SQLService(
            ILogger<SQLService> logger,
            IOptions<SQLServiceOptions> options)
        {
            _logger = logger;
            _options = options.Value;
        }

        public async Task<long?> GetLastSynchronizationVersionAsync(Guid walletId, string logType)
        {
            _logger.LogInformation($"Obtaining last synchronization version for walletId '{walletId}' and logType '{logType}'");

            string sql = "SELECT LastSynchronizationVersion FROM mart.ETL_ChangeDetection WHERE WalletId = @walletId AND LogType = @logType AND IsLatest = 1";

            using SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();

            using SqlCommand command = new SqlCommand(sql, connection);

            command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;
            command.Parameters.Add("@logType", SqlDbType.NVarChar).Value = logType;

            long? lastSynchronizationVersion = (long?)await command.ExecuteScalarAsync();

            if (lastSynchronizationVersion.HasValue)
            {
                _logger.LogInformation($"Last synchronization version: {lastSynchronizationVersion.Value}");
            }
            else
            {
                _logger.LogInformation($"Last synchronization version is null");
            }

            return lastSynchronizationVersion;
        }

        public async Task LoadAsync(string dataType, string json)
        {
            using SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();

            string sp = $"mart.ETL_Load{dataType}";

            _logger.LogInformation($"Load json data: exec {sp}");

            using SqlCommand command = new SqlCommand(sp, connection);

            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("json", SqlDbType.NVarChar).Value = json;

            await command.ExecuteNonQueryAsync();
        }

        public async Task UpdateLastSyncAsync(Guid walletId, string logType, long synchronizationVersion, int rowsProcessed)
        {
            using SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();

            string sp = "mart.ETL_UpdateLastSync";

            _logger.LogInformation($"Update last sync: exec {sp} @walletId = '{walletId}' @logType = '{logType}' @synchronizationVersion = {synchronizationVersion} @rowsProcessed = {rowsProcessed}");

            using SqlCommand command = new SqlCommand(sp, connection);

            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;
            command.Parameters.Add("@logType", SqlDbType.NVarChar).Value = logType;
            command.Parameters.Add("@synchronizationVersion", SqlDbType.BigInt).Value = synchronizationVersion;
            command.Parameters.Add("@rowsProcessed", SqlDbType.Int).Value = rowsProcessed;

            await command.ExecuteNonQueryAsync();
        }

        public async Task ResetAsync(Guid walletId, string dataType)
        {
            using SqlConnection connection = new SqlConnection(ConnectionString);
            connection.Open();

            string sp = $"mart.ETL_Reset{dataType}";

            _logger.LogInformation($"Reset data: exec {sp} @walletId = '{walletId}'");

            using SqlCommand command = new SqlCommand(sp, connection);

            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@walletId", SqlDbType.UniqueIdentifier).Value = walletId;

            await command.ExecuteNonQueryAsync();
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
}

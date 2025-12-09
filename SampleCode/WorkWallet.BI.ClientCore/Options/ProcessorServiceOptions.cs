namespace WorkWallet.BI.ClientCore.Options;

public record AgentWallet
{
    public required Guid WalletId { get; init; }
    public required string WalletSecret { get; init; }
}

public record ProcessorServiceOptions
{
    public required string ApiAccessAuthority { get; init; }
    public required string ApiAccessClientId { get; init; }
    public required string ApiAccessClientSecret { get; init; }
    public required string ApiAccessScope { get; init; }

    public required string AgentApiUrl { get; init; }
    public required AgentWallet[] AgentWallets { get; init; } = [];
    public int AgentPageSize { get; init; }
    public int AgentTimeout { get; init; } = 100;
    public required string[] DataSets { get; init; } = [];
    public bool? SetBetaFlag { get; init; } = null;
    }

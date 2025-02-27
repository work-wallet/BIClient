namespace WorkWallet.BI.ClientCore.Options;

public class AgentWallet
{
    public required Guid WalletId { get; init; }
    public required string WalletSecret { get; init; }
}

public class ProcessorServiceOptions
{
    public required string ApiAccessAuthority { get; init; }
    public required string ApiAccessClientId { get; init; }
    public required string ApiAccessClientSecret { get; init; }
    public required string ApiAccessScope { get; init; }

    public required string AgentApiUrl { get; init; }
    public required AgentWallet[] AgentWallets { get; init; }
    public int AgentPageSize { get; init; }
    public int AgentTimeout { get; init; } = 100;
}

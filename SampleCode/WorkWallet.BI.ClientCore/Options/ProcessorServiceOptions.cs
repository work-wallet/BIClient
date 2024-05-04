namespace WorkWallet.BI.ClientCore.Options
{
    public class AgentWallet
    {
        public required Guid WalletId { get; set; }
        public required string WalletSecret { get; set; }
    }

    public class ProcessorServiceOptions
    {
        public required string ApiAccessAuthority { get; set; }
        public required string ApiAccessClientId { get; set; }
        public required string ApiAccessClientSecret { get; set; }
        public required string ApiAccessScope { get; set; }

        public required string AgentApiUrl { get; set; }
        public required AgentWallet[] AgentWallets { get; set; }
        public required int AgentPageSize { get; set; }
    }
}

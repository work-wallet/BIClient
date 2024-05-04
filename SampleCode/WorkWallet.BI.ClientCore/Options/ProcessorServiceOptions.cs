namespace WorkWallet.BI.ClientCore.Options
{
    public class AgentWallet
    {
        public Guid WalletId { get; set; }
        public string WalletSecret { get; set; }
    }

    public class ProcessorServiceOptions
    {
        public string ApiAccessAuthority { get; set; }
        public string ApiAccessClientId { get; set; }
        public string ApiAccessClientSecret { get; set; }
        public string ApiAccessScope { get; set; }

        public string AgentApiUrl { get; set; }
        public AgentWallet[] AgentWallets { get; set; }
        public int AgentPageSize { get; set; }
    }
}

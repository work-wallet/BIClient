using System;

namespace WorkWallet.BI.ClientCore.Options
{
    public class ProcessorServiceOptions
    {
        public string ApiAccessAuthority { get; set; }
        public string ApiAccessClientId { get; set; }
        public string ApiAccessClientSecret { get; set; }
        public string ApiAccessScope { get; set; }

        public string AgentApiUrl { get; set; }
        public Guid AgentWalletId { get; set; }
        public string AgentWalletSecret { get; set; }
        public int AgentPageSize { get; set; }
    }
}

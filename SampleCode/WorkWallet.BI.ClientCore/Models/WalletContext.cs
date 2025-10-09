namespace WorkWallet.BI.ClientCore.Models;

public record WalletContext
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public required string DataRegion { get; set; }
}

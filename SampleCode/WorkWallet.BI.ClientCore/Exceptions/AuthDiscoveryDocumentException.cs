namespace WorkWallet.BI.ClientCore.Exceptions;

public class AuthDiscoveryDocumentException(string? error) :
    Exception($"Failed to get discovery document: \"{error}\"")
{
}

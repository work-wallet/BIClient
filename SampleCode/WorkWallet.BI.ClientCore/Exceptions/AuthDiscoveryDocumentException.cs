namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when the OAuth2 discovery document cannot be retrieved from the identity provider.
/// This typically indicates network connectivity issues or incorrect identity service configuration.
/// </summary>
public class AuthDiscoveryDocumentException(string? error) :
    Exception($"Failed to get discovery document: \"{error}\"")
{
}

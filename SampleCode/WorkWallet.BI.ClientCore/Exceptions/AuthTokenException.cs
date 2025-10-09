namespace WorkWallet.BI.ClientCore.Exceptions;

/// <summary>
/// Exception thrown when OAuth2 token acquisition fails using client credentials flow.
/// This typically indicates invalid client credentials or scope configuration issues.
/// </summary>
public class AuthTokenException(string? error) :
    Exception($"Failed to get token: \"{error}\"")
{
}

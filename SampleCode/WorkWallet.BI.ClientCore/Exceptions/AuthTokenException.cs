namespace WorkWallet.BI.ClientCore.Exceptions;

public class AuthTokenException(string? error) :
    Exception($"Failed to get token: \"{error}\"")
{
}

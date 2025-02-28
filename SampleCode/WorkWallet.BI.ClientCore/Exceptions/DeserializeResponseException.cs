﻿namespace WorkWallet.BI.ClientCore.Exceptions;

public class DeserializeResponseException : WalletException
{
    public DeserializeResponseException(Type type, Guid walletId)
        : base($"Failed to deserialize '{type.Name}'", walletId)
    {    
    }

    public DeserializeResponseException(Type type, Guid walletId, string dataType)
        : base($"Failed to deserialize '{type.Name}'", walletId, dataType)
    {      
    }

    public DeserializeResponseException(Type type, string error, Guid walletId, string dataType)
        : base($"Failed to deserialize '{type.Name}' with error \"{error}\"", walletId, dataType)
    {
    }
}

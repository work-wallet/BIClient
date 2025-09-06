# Calling the API Directly

It is strongly recommended that the quick starter solution provided in this repository is used in preference to calling the API directly. Using the quick starter will save you a considerable amount of effort in getting an integration up and running.

If you do require direct integration with the API, the following notes will be useful.

These notes are not comprehensive, and you will need to refer to the quick starter source code for more detailed guidance.

Even if you intend to integrate with the API directly, it can be very helpful to run the quick starter solution in order to gain an insight into how your Wallet data is structured.

## Obtaining an OAuth 2.0 Access Token

The first step is to obtain an access token.
Standard OAuth 2.0 [client credentials](https://oauth.net/2/grant-types/client-credentials/) flow is used.

The secure token service is located at: <https://identity.work-wallet.com>

The discovery document is at: <https://identity.work-wallet.com/.well-known/openid-configuration>

Based on the above, the token endpoint is: <https://identity.work-wallet.com/connect/token>

You will need to set the following scope: `ww_bi_extract`

Refer to guides for your specific integration technology on how to request an OAuth 2.0 access token using client credentials.

## Calling the BI API

The API endpoint takes the form:

`https://bi.work-wallet.com/dataextract/[data type]?walletId=[id]&walletSecret=[secret]&pageNumber=1&pageSize=10`

Currently supported data types:

* ReportedIssues
* Inductions
* Permits
* Actions
* Assets
* SafetyCards
* Audits
* PPEStocks
* PPEStockHistories
* PPEAssignments

When you call the API an Authorization header with value: `Bearer [token]` is required.

Note that `pageSize` must not be set too high. Recommended maximum is around 500. Setting a high value will cause performance issues and create very large payloads. Instead, your solution should implement paging. Review the sample C# code ([Processor.cs](https://github.com/work-wallet/BIClient/blob/main/SampleCode/WorkWallet.BI.ClientServices/Processor/ProcessorService.cs)), which you can consider as pseudo-code to guide your implementation.

The returned JSON includes a `Context` block that gives information about the total number of data rows available.

It is also necessary to implement change detection, so that you only pull data that has changed since you last called the API. You should store the `SynchronizationVersion` value returned (a big integer) for each data type. You should then include an additional parameter, `lastSynchronizationVersion`, in all your API calls:

So your URL becomes:

`https://bi.work-wallet.com/dataextract/[datatype]?walletId=[id]&walletSecret=[secret]&pageNumber=[number]&pageSize=[number]&lastSynchronizationVersion=[number]`

It is okay omit `lastSynchronizationVersion` on the first call or set the value to 0.

Example response (for Audits, truncated):

```json
{
  "Context": {
    "Version": 1,
    "Count": 13,
    "FullCount": 13,
    "PageNumber": 1,
    "PageSize": 500,
    "SynchronizationVersion": 10101,
    "MinValidSynchronizationVersion": 9000,
    "Error": "",
    "UTC": "2025-03-26T14:54:59.127"
  },
  "Wallets": [
    {
      "WalletId": "E6B2E381-34E7-4999-95A9-34D4909050EE",
      "Wallet": "Example Wallet"
    }
  ],
  "Locations": [
    {
      "LocationId": "F9964471-20D4-49D6-A80D-0CB0F6234ED6",
      "LocationTypeCode": 2,
      "LocationType": "Operations Site",
```

## Unpacking the JSON Payload

The API returns data in JSON format.

The sample [SQL database schema](https://github.com/work-wallet/BIClient/tree/main/SampleCode/WorkWallet.BI.ClientDatabaseDeploy/Scripts/Schema) can be use to guide you in understanding what data to expect from the API (including providing reference data values).

The quick starter solution processes the JSON in (database SQL) stored procedures. You can use these as references. For example for site audits see [here](https://github.com/work-wallet/BIClient/blob/main/SampleCode/WorkWallet.BI.ClientDatabaseDeploy/Scripts/StoredProcedures/mart.ETL_LoadSiteAudits.sql).

## Multi-Region Support

Work Wallet data hosting is available in multiple regions (currently UK/Europe, United States, Australia).
The data associated with any given Wallet is held in a single region.

When you call the API your request defaults to your local region.
So, for example, if you make an API request from within the UK you are automatically routed to the UK hosting. If your wallet data is hosted in the UK, then the API call will succeed. If, however, you make a request from the United States, then the call will fail with HTTP response 400 (bad request).

If you need to make cross-region API calls, then it is necessary to add an additional header `DataRegion` to the request.

```text
Authorization: Bearer [access token]
DataRegion: GB
```

The DataRegion code for a Wallet can be obtained from the following API endpoint:

`https://bi.work-wallet.com/wallet?walletId=[id]&walletSecret=[secret]`

Example response:

```json
{
  "id": "e6b2e381-34e7-4999-95a9-34d4909050ee",
  "name": "Example Wallet",
  "dataRegion": "GB"
}
```

## Hubspot Deal Counter

This use case demonstrates how the `hubspot.crm.object.deals` API can be utilized count the number of deals in each stages of the default sales pipeline. The example involves a sequence of actions that leverage the Hubspot CRM API v3 to automate the process of retrieving the deals. For the initial starting point we have used the batch creation API to create two deals in different stages.

## Prerequisites

### 1. Setup the Hubspot developer account

Refer to the [Setup guide](README.md#setup-guide) to obtain necessary credentials (client Id, client secret, Refresh tokens).

### 2. Configuration

Create a `Config.toml` file in the example's root directory and, provide your Twitter account related configurations as follows:

```toml
clientId = "<Client ID>"
clientSecret = "<Client Secret>"
refreshToken = "<Access Token>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
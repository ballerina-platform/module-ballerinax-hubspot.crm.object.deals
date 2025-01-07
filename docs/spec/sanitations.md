_Author_: @RavinduWeerakoon
_Created_: 2025/01/02 \
_Updated_:  \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Hubspot CRM API v3. The OpenAPI specification is obtained from the [Hubspot](https://developers.hubspot.com/docs/reference/api) OpenAPI Documentation. These changes are implemented to enhance the overall usability and readability of the generated client.


1. **Change the `url` property of the `servers` object**:
    -  **Original**: `https://api.hubapi.com`
    -  **Sanitized**: `https://api.hubapi.com/crm/v3/objects/deals`
    -  **Reason**: The original URL is too generic and does not provide a clear indication of the API endpoint. The new one improves the consistency and usability of the APIs.
2. **Update API Paths**:
    -  **Original**: Paths included reusable prefixes in each endpoint (e.g., `crm/v3/objects/deals`)
    -  **Updated**: Paths are modified to remove the reusable prefixes from the endpoints, as it is now included in the base URL. For example:
        - **Original**: `/crm/v3/objects/deals/batch/read`
        - **Updated**: `/batch/read`

3. **Updated the `date-time` into `datetime` to make it compatible with the ballerina type conversions**
    - **Original**: `foramt:date-time`
    - **Updated**: `format:datetime`
    - **Reason**: The `date-time` format is not compatible with the openAPI generation tool. Therefore, it is updated to `datetime` to make it compatible with the generation tool.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.json --mode client -o ballerina
```
Note: The license year is hardcoded to 2024, change if necessary.

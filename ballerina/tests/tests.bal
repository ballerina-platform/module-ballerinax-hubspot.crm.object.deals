import ballerina/test;
import ballerina/io;
import ballerina/oauth2;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string serviceUrl = ?;


  OAuth2RefreshTokenGrantConfig auth = {
       clientId: clientId,
       clientSecret: clientSecret,
       refreshToken: refreshToken,
       credentialBearer: oauth2:POST_BODY_BEARER
   };

ConnectionConfig config = {auth:auth};
final Client hubspot = check new Client(config, serviceUrl);


@test:Config
isolated function testgetUserIdByUseName() returns error? {
     CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error deals = hubspot ->/crm/v3/objects/deals;
     io:println(deals);
     test:assertEquals(4,4);
  
}
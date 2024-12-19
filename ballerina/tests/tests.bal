import ballerina/test;
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

string dealId = "";


@test:Config 
function testCreateDeals() returns error? {
   
    SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal",
            "amount": "100000"
        }
    };

    SimplePublicObject|error out = hubspot ->/crm/v3/objects/deals.post(payload = payload);

    if out is SimplePublicObject {
        dealId = out.id;
        test:assertTrue(out.createdAt !is "");
    } else {
        test:assertFail("Failed to create deal");
    }
    
};

@test:Config
function testgetAllDeals() returns error? {
    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error deals = hubspot ->/crm/v3/objects/deals;
 
    if deals is CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {
        test:assertTrue(deals.results.length() > 0);
    } else {
        test:assertFail("Failed to get deals");
    }
  
};

@test:Config
function testGetDealById() returns error? {
    SimplePublicObject|error deal = hubspot ->/crm/v3/objects/deals/[dealId].get();
    if deal is SimplePublicObject {
       
        test:assertTrue(deal.id == dealId);
    } else {
        test:assertFail("Failed to get deal");
    }
};

@test:Config
function testUpdateDeal() returns error? {
    SimplePublicObjectInput payload = {
        properties: {
            "dealname": "Test Deal Updated",
            "amount": "200000"
        }
    };

    SimplePublicObject|error out = hubspot ->/crm/v3/objects/deals/[dealId].patch(payload = payload);

    if out is SimplePublicObject {
        test:assertTrue(out.updatedAt !is "");
        test:assertEquals(out.properties["dealname"], "Test Deal Updated");
        test:assertEquals(out.properties["amount"], "200000");
    } else {
        test:assertFail("Failed to update deal");
    }
};


// @test:Config
// function testDeleteDeal() returns error? {
//     var response = hubspot ->/crm/v3/objects/deals/[dealId].delete();
//     if
//         response is http:Response {
//         test:assertTrue(response.statusCode == 204);
//     } else {
//         test:assertFail("Failed to delete deal");
//     }
// }

import ballerina/test;
import ballerina/oauth2;
import ballerina/http;

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
#keep the deal id as reference for other tests after creation
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

@test:Config { 
    dependsOn: [testCreateDeals] }
function testgetAllDeals() returns error? {
    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error deals = hubspot ->/crm/v3/objects/deals;
 
    if deals is CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {
        test:assertTrue(deals.results.length() > 0);
    } else {
        test:assertFail("Failed to get deals");
    }
  
};

@test:Config{ 
    dependsOn: [testgetAllDeals] }
function testGetDealById() returns error? {
    SimplePublicObject|error deal = hubspot ->/crm/v3/objects/deals/[dealId].get();
    if deal is SimplePublicObject {
       
        test:assertTrue(deal.id == dealId);
    } else {
        test:assertFail("Failed to get deal");
    }
};

@test:Config{ 
    dependsOn: [testGetDealById] }
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


@test:Config{ 
    dependsOn: [testUpdateDeal] }
function testMergeDeals() returns error? {

    string dealId2 = "";
    SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal2",
            "amount": "300000"
        }
    };

    SimplePublicObject|error out = hubspot ->/crm/v3/objects/deals.post(payload = payload);


    if out is SimplePublicObject {
        dealId2 = out.id;
        PublicMergeInput payload2 = {
            objectIdToMerge: dealId2,
            primaryObjectId: dealId
        };
        SimplePublicObject|error mergeOut = hubspot ->/crm/v3/objects/deals/merge.post(payload = payload2);
        if mergeOut is SimplePublicObject {
            test:assertNotEquals(mergeOut.properties["hs_merged_object_ids"] ,"");
            dealId = mergeOut.id;
        }else{
            test:assertFail("Failed to create the secondary deal");
        }
    } else {
        test:assertFail("Failed to merge deals");
    }
   
};



@test:Config{
    dependsOn: [testUpdateDeal]
}
function testSearchDeals() returns error? {
    PublicObjectSearchRequest qr = {
        query: "test"
    };
    CollectionResponseWithTotalSimplePublicObjectForwardPaging|error search = hubspot ->/crm/v3/objects/deals/search.post(payload = qr);
    if search is CollectionResponseWithTotalSimplePublicObjectForwardPaging {
        test:assertTrue(search.results.length() > 0);
    } else {
        test:assertFail("Failed to search deals");
    }
};


@test:Config{
    dependsOn: [testSearchDeals]
}
function testDeleteDeal() returns error? {
    var response = hubspot ->/crm/v3/objects/deals/[dealId].delete();
    if
        response is http:Response {
        test:assertTrue(response.statusCode == 204);
    } else {
        test:assertFail("Failed to delete deal");
    }
}
import ballerina/http;
import ballerina/io;
import ballerina/oauth2;
import ballerina/test;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

OAuth2RefreshTokenGrantConfig auth = {
    clientId,
    clientSecret,
    refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER
};

final Client hubspot = check new ({ auth });
# keep the deal id as reference for other tests after creation
string dealId = "";

string batchDealId1 = "";
string batchDealId2 = "";

@test:Config
function testCreateDeals() returns error? {

    SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal",
            "amount": "100000"
        }
    };

    SimplePublicObject out = check hubspot->/.post(payload = payload);
    dealId = out.id;
    test:assertTrue(out.createdAt !is "");
    

};

@test:Config {
    dependsOn: [testCreateDeals]
}
function testgetAllDeals() returns error? {
    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging deals = check  hubspot->/;
    test:assertTrue(deals.results.length() > 0);
    

};

@test:Config {
    dependsOn: [testgetAllDeals]
}
function testGetDealById() returns error? {
    SimplePublicObject deal =check hubspot->/[dealId].get();
    io:println(deal);
    test:assertTrue(deal.id == dealId);
};

@test:Config {
    dependsOn: [testGetDealById]
}
function testUpdateDeal() returns error? {
    SimplePublicObjectInput payload = {
        properties: {
            "dealname": "Test Deal Updated",
            "amount": "200000"
        }
    };

    SimplePublicObject out = check  hubspot->/[dealId].patch(payload = payload);

    test:assertTrue(out.updatedAt !is "");
    test:assertEquals(out.properties["dealname"], "Test Deal Updated");
    test:assertEquals(out.properties["amount"], "200000");

};

@test:Config {
    dependsOn: [testUpdateDeal]
}
function testMergeDeals() returns error? {

    string dealId2 = "";
    SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal2",
            "amount": "300000"
        }
    };

    SimplePublicObject out = check  hubspot->/.post(payload = payload);

    dealId2 = out.id;
    PublicMergeInput payload2 = {
        objectIdToMerge: dealId2,
        primaryObjectId: dealId
    };
    SimplePublicObject mergeOut = check hubspot->/merge.post(payload = payload2);
        
    test:assertNotEquals(mergeOut.properties["hs_merged_object_ids"], "");
    dealId = mergeOut.id;

   
};

//for the search test case you should alraedy have some deals in the hubspot as it could take some time to index the deals

@test:Config {
    dependsOn: [testUpdateDeal]
}
function testSearchDeals() returns error? {
    PublicObjectSearchRequest qr = {
        query: "test"
    };
    CollectionResponseWithTotalSimplePublicObjectForwardPaging search = check hubspot->/search.post(payload = qr);
        test:assertTrue(search.results.length() > 0);
 
};

@test:Config {
    dependsOn: [testSearchDeals]
}
function testDeleteDeal() returns error? {
    
    http:Response response = check hubspot->/[dealId].delete();
    test:assertTrue(response.statusCode == 204);
 
}

@test:Config {
    dependsOn: [testDeleteDeal]
}
function testBatchCreate() returns error? {
    SimplePublicObjectInputForCreate payload1 = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal1",
            "amount": "100000"
        }
    };
    SimplePublicObjectInputForCreate payload2 = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal2",
            "amount": "200000"
        }
    };
    BatchInputSimplePublicObjectInputForCreate payloads = {
        inputs: [payload1, payload2]
    };
    BatchResponseSimplePublicObject out = check hubspot->/batch/create.post(payload = payloads);
    test:assertTrue(out.results.length() == 2);
    batchDealId1 = out.results[0].id;
    batchDealId2 = out.results[1].id;
    

}

@test:Config {
    dependsOn: [testBatchCreate]
}
function testBacthUpdate() returns error? {
    SimplePublicObjectBatchInput payload1 = {
        id: batchDealId1,
        properties: {
            "dealname": "Test Deal1 Updated",
            "amount": "300000",
            "test": "testID1"

        }
    };
    SimplePublicObjectBatchInput payload2 = {
        id: batchDealId2,
        properties: {
            "dealname": "Test Deal2 Updated",
            "amount": "400000"
        }
    };
    BatchInputSimplePublicObjectBatchInput payloads = {
        inputs: [payload1, payload2]
    };
    BatchResponseSimplePublicObject out = check hubspot->/batch/update.post(payload = payloads);



        test:assertTrue(out.results.length() == 2);
        SimplePublicObject updatedDeal1 = out.results.filter(function(SimplePublicObject deal) returns boolean {
            return deal.id == batchDealId1;
        })[0];
        test:assertEquals(updatedDeal1.properties["dealname"], "Test Deal1 Updated");


}

//for the this test case you should create a custom unique property for the deals 
//my property comes as `test`
//ref:https://www.youtube.com/watch?v=3p6deGTS12w, 
@test:Config {
    dependsOn: [testBacthUpdate]
}
function testBatchUpsert() returns error? {
    SimplePublicObjectBatchInputUpsert payload1 = {
        id: "testID1",
        idProperty: "test",
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal1",
            "amount": "1034500"
        }
    };
    BatchInputSimplePublicObjectBatchInputUpsert payloads = {
        inputs: [payload1]
    };
    BatchResponseSimplePublicUpsertObject out = check  hubspot->/batch/upsert.post(payload = payloads);
    io:println(out);
    test:assertTrue(out.results.length() == 1);

}

@test:Config {
    dependsOn: [testBatchUpsert]
}
function testBatchInputDelete() returns error? {
    SimplePublicObjectId payload1 = {
        id: batchDealId1
    };

    SimplePublicObjectId payload2 = {
        id: batchDealId2
    };
    BatchInputSimplePublicObjectId payload = {
        inputs: [payload1, payload2]
    };
    http:Response out = check hubspot->/batch/archive.post(payload = payload);
    test:assertTrue(out.statusCode == 204);


}


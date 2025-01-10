// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/oauth2;
import ballerina/os;
import ballerina/test;

configurable string clientId = os:getEnv("clientId");
configurable string clientSecret = os:getEnv("clientSecret");
configurable string refreshToken = os:getEnv("refreshToken");
configurable boolean isLiveServer = os:getEnv("isLiveServer") == "true";
configurable string serviceUrl = isLiveServer ? "https://api.hubapi.com/crm/v3/objects/deals" : "http://localhost:9090";


final Client hubSpotDeals = check initClient();

isolated function initClient() returns Client|error {
    if isLiveServer {
        OAuth2RefreshTokenGrantConfig auth = {
            clientId: clientId,
            clientSecret: clientSecret,
            refreshToken: refreshToken,
            credentialBearer: oauth2:POST_BODY_BEARER
        };
        return check new ({auth}, serviceUrl);
    }
    return check new ({
        auth: {
            token: "test-token"
        }
    }, serviceUrl);
}

string dealId = "";

string batchDealId1 = "";
string batchDealId2 = "";

@test:Config {
    groups: ["mock_tests"]
}
function testCreateDeals() returns error? {
    SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal",
            "amount": "100000"
        }
    };

    SimplePublicObject out = check hubSpotDeals->/.post(payload = payload);
    dealId = out.id;
    test:assertTrue(out.createdAt !is "");

};

@test:Config {
    dependsOn: [testCreateDeals],
    groups: ["mock-tests"]
}
function testgetAllDeals() returns error? {
    CollectionResponseSimplePublicObjectWithAssociationsForwardPaging deals = check hubSpotDeals->/;
    test:assertTrue(deals.results.length() > 0);

};

@test:Config {
    dependsOn: [testgetAllDeals],
    groups: ["live_tests"],
    enable: isLiveServer
}
function testGetDealById() returns error? {
    SimplePublicObject deal = check hubSpotDeals->/[dealId].get();
    test:assertTrue(deal.id == dealId);
};

@test:Config {
    dependsOn: [testGetDealById],
    groups: ["live_tests"],
    enable: isLiveServer
}
function testUpdateDeal() returns error? {
    SimplePublicObjectInput payload = {
        properties: {
            "dealname": "Test Deal Updated",
            "amount": "200000"
        }
    };

    SimplePublicObject out = check hubSpotDeals->/[dealId].patch(payload = payload);

    test:assertTrue(out.updatedAt !is "");
    test:assertEquals(out.properties["dealname"], "Test Deal Updated");
    test:assertEquals(out.properties["amount"], "200000");

};

@test:Config {
    dependsOn: [testUpdateDeal],
    groups: ["live_tests"],
    enable: isLiveServer
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

    SimplePublicObject out = check hubSpotDeals->/.post(payload = payload);

    dealId2 = out.id;
    PublicMergeInput payload2 = {
        objectIdToMerge: dealId2,
        primaryObjectId: dealId
    };
    SimplePublicObject mergeOut = check hubSpotDeals->/merge.post(payload = payload2);

    test:assertNotEquals(mergeOut.properties["hs_merged_object_ids"], "");
    dealId = mergeOut.id;

};

//for the search test case you should alraedy have some deals in the hubspot as it could take some time to index the deals

@test:Config {
    dependsOn: [testUpdateDeal],
    groups: ["live_tests"],
    enable: isLiveServer
}
function testSearchDeals() returns error? {
    PublicObjectSearchRequest qr = {
        query: "test"
    };
    CollectionResponseWithTotalSimplePublicObjectForwardPaging search = check hubSpotDeals->/search.post(payload = qr);
    test:assertTrue(search.results.length() > 0);

};

@test:Config {
    dependsOn: [testSearchDeals],
    groups: ["live_tests"],
    enable: isLiveServer
}
function testDeleteDeal() returns error? {

    http:Response response = check hubSpotDeals->/[dealId].delete();
    test:assertTrue(response.statusCode == 204);

}

@test:Config {
    dependsOn: [testDeleteDeal],
    groups: ["live_tests"],
    enable: isLiveServer
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
    BatchResponseSimplePublicObject out = check hubSpotDeals->/batch/create.post(payload = payloads);
    test:assertTrue(out.results.length() == 2);
    batchDealId1 = out.results[0].id;
    batchDealId2 = out.results[1].id;

}

@test:Config {
    dependsOn: [testBatchCreate],
    groups: ["live_tests"],
    enable: isLiveServer
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
    BatchResponseSimplePublicObject out = check hubSpotDeals->/batch/update.post(payload = payloads);

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
    dependsOn: [testBacthUpdate],
    groups: ["live_tests"],
    enable: isLiveServer
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
    BatchResponseSimplePublicUpsertObject out = check hubSpotDeals->/batch/upsert.post(payload = payloads);
    test:assertTrue(out.results.length() == 1);

}

@test:Config {
    dependsOn: [testBatchUpsert],
    groups: ["live_tests"],
    enable: isLiveServer
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
    http:Response out = check hubSpotDeals->/batch/archive.post(payload = payload);
    test:assertTrue(out.statusCode == 204);

}


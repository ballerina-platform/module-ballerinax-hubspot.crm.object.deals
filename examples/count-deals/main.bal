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

import ballerina/io;
import ballerina/oauth2;
import ballerinax/hubspot.crm.obj.deals;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

deals:OAuth2RefreshTokenGrantConfig auth = {
    clientId,
    clientSecret,
    refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER
};

public function main() {
    final deals:Client hubSpotDeals = check new ({auth});
    deals:SimplePublicObjectInputForCreate payload1 = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal1",
            "dealstage": "appointmentscheduled",
            "amount": "100000"
        }
    };
    deals:SimplePublicObjectInputForCreate payload2 = {
        properties: {
            "pipeline": "default",
            "dealname": "Test Deal2",
            "dealstage": "contractsent",
            "amount": "200000"
        }
    };
    deals:BatchInputSimplePublicObjectInputForCreate payloads = {
        inputs: [payload1, payload2]
    };

    deals:BatchResponseSimplePublicObject|deals:BatchResponseSimplePublicObjectWithErrors|error out = hubSpotDeals->/batch/create.post(payload = payloads);

    if out is deals:BatchResponseSimplePublicObject {
        io:println("Batch Deal 1 created with id: " + out.results[0].id);
        io:println("Batch Deal 2 created with id: " + out.results[1].id);

    } else {
        io:println("Failed to create deals");
        return;
    }

    deals:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error deals = hubSpotDeals->/;
    if deals is deals:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {

        io:println(`Nuber of retreived deals ${deals.results.length()}`);
        int ct;

        map<int> dealStageCount = {};

        foreach var deal in deals.results {
            string dealStage = deal.properties["dealstage"].toString();
            ct = dealStageCount[dealStage] ?: 0;
            dealStageCount[dealStage] = ct + 1;
        }

        foreach var [stage, count] in dealStageCount.entries() {
            io:println(`Deal stage: ${stage}, Count: ${count}`);
        }
    } else {
        io:println("Failed to get deals");
    }

}


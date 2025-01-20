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

final deals:Client hubSpotDeals = check new ({auth});

public function main() returns error? {

    string dealId = "";

    deals:SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealstage": "appointmentscheduled",
            "dealname": "Test Deal Creator Example",
            "amount": "100000"
        }
    };

    deals:SimplePublicObject|error dealCreated = hubSpotDeals->/.post(payload = payload);

    if dealCreated is deals:SimplePublicObject {
        dealId = dealCreated.id;
        io:println(`A deal created with id ${dealId}`);

    } else {
        io:println("Deal Creation Failed");
        return;
    }

    //Now we will update the pipeline stage
    deals:SimplePublicObjectInput newDealDetails = {
        properties: {
            "dealstage": "contractsent"
        }
    };

    deals:SimplePublicObject _ = check  hubSpotDeals->/[dealId].patch(payload = newDealDetails);
    
    io:println("Successfully updated the deal into a new Stage");
 

    //Now all the deal specific things are over time to delete it
    var _ = check hubSpotDeals->/[dealId].delete();
    io:println("sucessfully deleted the deal");
    

}


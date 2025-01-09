// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
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
import ballerina/log;

listener http:Listener httpListener = new (9090);

string isLiveServer = "false";

http:Service mockService = service object {

    resource function post .(@http:Payload SimplePublicObjectInputForCreate payload) returns SimplePublicObject|http:Response {

        return ({
            "createdAt": "2025-01-09T11:20:04.835Z",
            "archived": false,
            "id": "31721379467",
            "properties": {
                "pipeline": null,
                "dealname": "Test Deal",
                "amount": "100000",
                "closedate": null,
                "hs_lastmodifieddate": "2025-01-09T11:20:05.764Z",
                "dealstage": null,
                "hs_object_id": "31721379467",
                "createdate": "2025-01-09T11:20:04.835Z"
            },
            "updatedAt": "2025-01-09T11:20:05.764Z"
        });
    };

    # List
    #
    # + 'limit - The maximum number of results to display per page.
    # + after - The paging cursor token of the last successfully read resource will be returned as the `paging.next.after` JSON property of a paged response containing more results.
    # + properties - A comma separated list of the properties to be returned in the response. If any of the specified properties are not present on the requested object(s), they will be ignored.
    # + propertiesWithHistory - A comma separated list of the properties to be returned along with their history of previous values. If any of the specified properties are not present on the requested object(s), they will be ignored. Usage of this parameter will reduce the maximum number of objects that can be read by a single request.
    # + associations - A comma separated list of object types to retrieve associated IDs for. If any of the specified associations do not exist, they will be ignored.
    # + archived - Whether to return only results that have been archived.
    # + return - returns can be any of following types 
    # http:Ok (successful operation)
    # http:DefaultStatusCodeResponse (An error occurred.)
    resource function get .(string? after, string[]? properties, string[]? propertiesWithHistory, string[]? associations, int:Signed32 'limit = 10, boolean archived = false) returns CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|http:Response {
        return ({
            "results": [
                {
                    "createdAt": "2024-12-20T04:35:07.499Z",
                    "archived": false,
                    "id": "30810555806",
                    "properties": {
                        "pipeline": "default",
                        "dealname": "Test Deal Updated",
                        "amount": "200000",
                        "closedate": null,
                        "hs_lastmodifieddate": "2025-01-06T12:02:21.337Z",
                        "dealstage": "presentationscheduled",
                        "hs_object_id": "30810555806",
                        "createdate": "2024-12-20T04:35:07.499Z"
                    },
                    "updatedAt": "2025-01-06T12:02:21.337Z"
                },
                {
                    "createdAt": "2025-01-08T07:16:29.241Z",
                    "archived": false,
                    "id": "31678812300",
                    "properties": {
                        "pipeline": "default",
                        "dealname": "Test Deal2",
                        "amount": "200000",
                        "closedate": null,
                        "hs_lastmodifieddate": "2025-01-08T08:17:30.129Z",
                        "dealstage": "contractsent",
                        "hs_object_id": "31678812300",
                        "createdate": "2025-01-08T07:16:29.241Z"
                    },
                    "updatedAt": "2025-01-08T08:17:30.129Z"
                },
                {
                    "createdAt": "2025-01-08T07:16:29.241Z",
                    "archived": false,
                    "id": "31678812301",
                    "properties": {
                        "pipeline": "default",
                        "dealname": "Test Deal1",
                        "amount": "100000",
                        "closedate": null,
                        "hs_lastmodifieddate": "2025-01-08T08:17:29.635Z",
                        "dealstage": "appointmentscheduled",
                        "hs_object_id": "31678812301",
                        "createdate": "2025-01-08T07:16:29.241Z"
                    },
                    "updatedAt": "2025-01-08T08:17:29.635Z"
                },
                {
                    "createdAt": "2025-01-09T11:37:48.911Z",
                    "archived": false,
                    "id": "31713422205",
                    "properties": {
                        "pipeline": null,
                        "dealname": "Test Deal",
                        "amount": "100000",
                        "closedate": null,
                        "hs_lastmodifieddate": "2025-01-09T11:37:48.911Z",
                        "dealstage": null,
                        "hs_object_id": "31713422205",
                        "createdate": "2025-01-09T11:37:48.911Z"
                    },
                    "updatedAt": "2025-01-09T11:37:48.911Z"
                }
            ]
        });
    };
};

function init() returns error? {
    if isLiveServer == "true" {
        log:printInfo("Skiping mock server initialization as the tests are running on live server");
        return;
    }
    log:printInfo("Initiating mock server");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
}

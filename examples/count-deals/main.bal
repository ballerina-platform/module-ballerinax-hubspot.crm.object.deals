import ballerina/io;
import ballerinax/hubspot.crm.obj.deals;
import ballerina/oauth2;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;

//auth confguration for hubspot
deals:OAuth2RefreshTokenGrantConfig auth = {
    clientId: clientId,
    clientSecret: clientSecret,
    refreshToken: refreshToken,
    credentialBearer: oauth2:POST_BODY_BEARER
    };

deals:ConnectionConfig config = {auth: auth};
//authorized http client to access hubspot
final deals:Client hubspot = check new deals:Client(config);




public function main(){
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

    deals:BatchResponseSimplePublicObject|deals:BatchResponseSimplePublicObjectWithErrors|error out = hubspot->/batch/create.post(payload = payloads);


    if out is deals:BatchResponseSimplePublicObject {
        io:println("Batch Deal 1 created with id: " + out.results[0].id);
        io:println("Batch Deal 2 created with id: " + out.results[1].id);
        
 
    } else {
        io:println("Failed to create deals");
        return;
    }


    deals:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging|error deals = hubspot->/;
    if deals is deals:CollectionResponseSimplePublicObjectWithAssociationsForwardPaging {
    
    io:println(`Nuber of retreived deals ${deals.results.length()}`);
    int ct;

    map<int> dealStageCount = {};

        foreach var deal in deals.results {
            string dealStage =  deal.properties["dealstage"].toString();
            ct = dealStageCount[dealStage]?:0;
            dealStageCount[dealStage] = ct + 1;
        }

        foreach var [stage, count] in dealStageCount.entries() {
            io:println(`Deal stage: ${stage}, Count: ${count}`);
        }
    } else {
        io:println("Failed to get deals");
        return;
    }

    
    

}


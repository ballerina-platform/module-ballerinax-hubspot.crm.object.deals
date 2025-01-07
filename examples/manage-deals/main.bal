import ballerina/io;
import ballerinax/hubspot.crm.obj.deals;
import ballerina/oauth2;
import ballerina/http;

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

    string dealId = "";

    deals:SimplePublicObjectInputForCreate payload = {
        properties: {
            "pipeline": "default",
            "dealstage":"appointmentscheduled",
            "dealname": "Test Deal Creator Example",
            "amount": "100000"
        }
    };

    deals:SimplePublicObject|error deal = hubspot->/.post(payload = payload);

    if deal is deals:SimplePublicObject {
        dealId = deal.id;
        io:println(`A deal created with id ${dealId}`);
        
    } else {
        io:println("Deal Creation Failed");
        return;
    }

    //Now we will update the pipeline stage
    deals:SimplePublicObjectInput newDealDetails = {
        properties:{
            "dealstage":"contractsent"
        }
    };

    deals:SimplePublicObject|error newDeal = hubspot->/[dealId].patch(payload = newDealDetails);

     if newDeal is deals:SimplePublicObject {
        io:println("Successfully updated the deal into a new Stage");
        io:println(newDeal);
    } else {
        io:println("Failed to Update the deal");
    }



    //Now all the deal specific things are over time to delete it
    var response = hubspot->/[dealId].delete();

    if response is http:Response {
        io:println("sucessfully deleted the deal");
    } else {
        io:println("Failed to delete deal");
    }
    

}

using {sap.cap.productshop as Schema} from '../db/schema';

service ProductShop {

    @odata.draft.enabled
    entity MaterialEntity as projection on Schema.Material

        actions {
            // Bound action: Automatically knows which MaterialEntity it belongs to
            action setPrice(Price: Decimal(10, 2))        returns String;
            action changeDescription(Description: String) returns String;

            // 1. Add the Side Effects annotation directly on the action
            @(Common.SideEffects: {
            // Refresh the vendor association dataset to fetch the new Name/Address
            TargetEntities: [vendor]})

            action addVendor(ID: Integer,
                             Name: String,
                             Address1: String,
                             Address2: String,
                             State: String,
                             Country: String,
                             Pin: String)                 returns String;


            @(Common.SideEffects: {TargetEntities: [vendor]})
            action addExistingVendor(ID: Integer)         returns String;
        };

    @cds.redirection.target
    entity VendorEntity   as projection on Schema.Vendor;

    // Define the custom function
    function getProductDescByNumber(Number: Integer) returns String;

    // Unbound action: Declared at the service root level
    action   getPrice(Number: Integer)               returns Decimal(10, 2);
}

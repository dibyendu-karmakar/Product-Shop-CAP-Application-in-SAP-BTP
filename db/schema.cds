namespace sap.cap.productshop;

using {managed} from '@sap/cds/common';

aspect MaterialPrice {
    Price    : Decimal(10, 2);
    PriceUoM : String;
}

entity Material : managed, MaterialPrice {
    key Number      : Integer not null;
        Description : String;
        Rating      : Integer;
        Criticality : Integer;
        MaxRating   : Integer;

        Location    : Composition of many {
                          key GUID        : UUID;
                              Bin         : String;
                              StorageType : String;
                              StockType   : String;
                              UoM         : String;
                              Quantity    : Decimal(10, 2);
                              Owner       : String;
                      }
        vendor      : Association to one Vendor;
}


entity Vendor {
    key GUID         : UUID;
        Name         : String(100);
        AddressLine1 : String(100);
        AddressLine2 : String(100);
        State        : String(100);
        Country      : String(100);
        Pincode      : String(100);
        ID           : Integer not null;
        materials    : Association to many Material
                           on materials.vendor = $self;
}

type ProductDetails {
    productId   : String;
    name        : String;
    description : String;
    price       : Decimal(10,2);
}

@protocol: 'rest'
service Product {
    function getProductDetails(productId: String) returns ProductDetails;
}
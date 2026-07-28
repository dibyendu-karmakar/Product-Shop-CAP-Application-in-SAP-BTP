using ProductMasterA2X from './external/ProductMasterA2X.cds';

service ProductMasterA2XSampleService {
    @readonly
    entity A_ProductBasicText as projection on ProductMasterA2X.A_ProductBasicText
    {        key Product, key Language, LongText     }    
;
}
using ProductShop as service from '../../srv/product-service';
using from '../../db/schema';

annotate service.MaterialEntity with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Number,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Description',
                Value: Description,
            },
            {
                $Type: 'UI.DataField',
                Value: Price,
                Label: 'Price',
            },
            {
                $Type: 'UI.DataField',
                Value: Rating,
                Label: 'Rating',
            },
        ],
    },
    UI.Facets                     : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneratedFacet1',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Administration',
            ID    : 'Administration',
            Target: '@UI.FieldGroup#Administration1',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Vendor Details',
            ID    : 'VendorDetails',
            Target: '@UI.FieldGroup#VendorDetails',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Bin Data',
            ID    : 'BinData',
            Target: 'Location/@UI.LineItem#BinData',
        },
    ],
    UI.LineItem                   : [
        {
            $Type: 'UI.DataField',
            Value: Number,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Description',
            Value: Description,
        },
        {
            $Type: 'UI.DataField',
            Value: Price,
            Label: '{i18n>MaterialPrice}',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ProductShop.setPrice',
            Label : 'Set Price',
            Inline: true,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ProductShop.changeDescription',
            Label : 'Change Description',
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target: '@UI.DataPoint#Rating1',
            Label : 'Rating',
        },
    ],
    UI.SelectionFields            : [
        Description,
        Number,
    ],
    UI.FieldGroup #Administration : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: createdAt,
            },
            {
                $Type: 'UI.DataField',
                Value: createdBy,
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedAt,
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedBy,
            },
        ],
    },
    UI.FieldGroup #VendorDetails  : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: vendor.ID,
                Label: 'ID',
            },
            {
                $Type: 'UI.DataField',
                Value: vendor.Name,
                Label: 'Name',
            },
            {
                $Type: 'UI.DataField',
                Value: vendor.AddressLine1,
                Label: 'AddressLine1',
            },
            {
                $Type: 'UI.DataField',
                Value: vendor.AddressLine2,
                Label: 'AddressLine2',
            },
            {
                $Type: 'UI.DataField',
                Value: vendor.State,
                Label: 'State',
            },
            {
                $Type: 'UI.DataField',
                Value: vendor.Pincode,
                Label: 'Pincode',
            },
            {
                $Type: 'UI.DataField',
                Value: vendor.Country,
                Label: 'Country',
            },
            {
                $Type : 'UI.DataFieldForAction',
                Action : 'ProductShop.addVendor',
                Label : 'Create Vendor',
            },
            {
                $Type : 'UI.DataFieldForAction',
                Action : 'ProductShop.addExistingVendor',
                Label : 'Add Existing Vendor',
            },
        ],
    },
    UI.Identification             : [{
        $Type  : 'UI.DataFieldForActionGroup',
        Actions: [
            {
                $Type : 'UI.DataFieldForAction',
                Action: 'ProductShop.changeDescription',
                Label : 'changeDescription',
            },
            {
                $Type : 'UI.DataFieldForAction',
                Action: 'ProductShop.setPrice',
                Label : 'setPrice',
            },
        ],
        ID     : 'MoreMethods',
        Label  : 'More Methods',
    }, ],
    UI.FieldGroup #Administration1: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: createdAt,
            },
            {
                $Type: 'UI.DataField',
                Value: createdBy,
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedAt,
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedBy,
            },
        ],
    },
    UI.DataPoint #Rating          : {
        Value        : Rating,
        Visualization: #Rating,
        TargetValue  : 5,
    },
    UI.DataPoint #rating          : {
        $Type        : 'UI.DataPointType',
        Value        : Rating,
        Title        : 'Rating',
        TargetValue  : 5,
        Visualization: #Rating,
    },
    UI.HeaderFacets               : [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'Rating',
        Target: '@UI.DataPoint#rating',
    },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'Rating1',
            Target : '@UI.Chart#Rating3',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'Quantity',
            Target : 'Location/@UI.Chart#Quantity4',
        }, ],
    UI.DataPoint #Rating1         : {
        Value        : Rating,
        Visualization: #Progress,
        TargetValue  : 5,
        Criticality  : Criticality,
    },
    UI.DataPoint #Price           : {
        Value      : Price,
        TargetValue: Rating,
    },
    UI.Chart #Price               : {
        ChartType        : #Donut,
        Title            : 'Price',
        Measures         : [Price, ],
        MeasureAttributes: [{
            DataPoint: '@UI.DataPoint#Price',
            Role     : #Axis1,
            Measure  : Price,
        }, ],
    },
    UI.DataPoint #Rating2 : {
        Value : Rating,
        TargetValue : MaxRating,
        Criticality : Criticality,
    },
    UI.Chart #Rating : {
        ChartType : #Donut,
        Title : 'Rating Circular Value',
        Measures : [
            Rating,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Rating2',
                Role : #Axis1,
                Measure : Rating,
            },
        ],
    },
    UI.DataPoint #Rating3 : {
        Value : Rating,
        MaximumValue : MaxRating,
    },
    UI.Chart #Rating1 : {
        ChartType : #Pie,
        Title : 'Rating',
        Measures : [
            Rating,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Rating3',
                Role : #Axis1,
                Measure : Rating,
            },
        ],
    },
    UI.DataPoint #MaxRating : {
        Value : MaxRating,
        TargetValue : Rating,
    },
    UI.Chart #MaxRating : {
        ChartType : #Donut,
        Title : 'MaxRating',
        Measures : [
            MaxRating,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#MaxRating',
                Role : #Axis1,
                Measure : MaxRating,
            },
        ],
    },
    UI.DataPoint #Rating4 : {
        Value : Rating,
        TargetValue : MaxRating,
    },
    UI.Chart #Rating2 : {
        ChartType : #Donut,
        Title : 'Rating',
        Measures : [
            Rating,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Rating4',
                Role : #Axis1,
                Measure : Rating,
            },
        ],
    },
    UI.DataPoint #Rating5 : {
        Value : Rating,
        TargetValue : MaxRating,
        Criticality : Criticality,
    },
    UI.Chart #Rating3 : {
        ChartType : #Donut,
        Title : 'Rating Circular Value',
        Measures : [
            Rating,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Rating5',
                Role : #Axis1,
                Measure : Rating,
            },
        ],
    },
);

annotate service.MaterialEntity with {
    Description @Common.Label: 'Description'
};

annotate service.MaterialEntity with {
    Number @Common.Label: 'Number'
};

annotate service.MaterialEntity.Location with @(UI.LineItem #BinData: [
    {
        $Type: 'UI.DataField',
        Value: Bin,
        Label: 'Bin',
    },
    {
        $Type: 'UI.DataField',
        Value: StorageType,
        Label: 'StorageType',
    },
    {
        $Type: 'UI.DataField',
        Value: Quantity,
        Label: 'Quantity',
    },
    {
        $Type: 'UI.DataField',
        Value: UoM,
        Label: 'UoM',
    },
    {
        $Type: 'UI.DataField',
        Value: StockType,
        Label: 'StockType',
    },
    {
        $Type: 'UI.DataField',
        Value: Owner,
        Label: 'Owner',
    },
],
    UI.DataPoint #Quantity : {
        Value : Quantity,
    },
    UI.Chart #Quantity : {
        ChartType : #Column,
        Title : 'Quantity',
        Measures : [
            Quantity,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Quantity',
                Role : #Axis1,
                Measure : Quantity,
            },
        ],
        Dimensions : [
            up__Number,
        ],
    },
    UI.DataPoint #Quantity1 : {
        Value : Quantity,
    },
    UI.Chart #Quantity1 : {
        ChartType : #Line,
        Title : 'Quantity',
        Measures : [
            Quantity,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Quantity1',
                Role : #Axis1,
                Measure : Quantity,
            },
        ],
        Dimensions : [
            up__Number,
        ],
    },
    UI.DataPoint #Quantity2 : {
        Value : Quantity,
    },
    UI.Chart #Quantity2 : {
        ChartType : #BarStacked,
        Title : 'Quantity',
        Measures : [
            Quantity,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Quantity2',
                Role : #Axis1,
                Measure : Quantity,
            },
        ],
    },
    UI.DataPoint #Quantity3 : {
        Value : Quantity,
    },
    UI.Chart #Quantity3 : {
        ChartType : #BarStacked,
        Title : 'Quantity',
        Measures : [
            Quantity,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Quantity3',
                Role : #Axis1,
                Measure : Quantity,
            },
        ],
    },
    UI.DataPoint #Quantity4 : {
        Value : Quantity,
    },
    UI.Chart #Quantity4 : {
        ChartType : #BarStacked,
        Title : 'Quantity Distribution in Bins',
        Measures : [
            Quantity,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#Quantity4',
                Role : #Axis1,
                Measure : Quantity,
            },
        ],
    },);
annotate service.VendorEntity with {
    AddressLine1 @Common.FieldControl : #ReadOnly
};

annotate service.VendorEntity with {
    AddressLine2 @Common.FieldControl : #ReadOnly
};

annotate service.VendorEntity with {
    State @Common.FieldControl : #ReadOnly
};

annotate service.VendorEntity with {
    Pincode @Common.FieldControl : #ReadOnly
};

annotate service.VendorEntity with {
    Country @Common.FieldControl : #ReadOnly
};

annotate service.VendorEntity with {
    ID @Common.FieldControl : #ReadOnly
};

annotate service.VendorEntity with {
    Name @Common.FieldControl : #ReadOnly
};


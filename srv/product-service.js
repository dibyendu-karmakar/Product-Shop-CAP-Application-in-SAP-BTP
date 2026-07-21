const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    // Access the database service instance
    const db = await cds.connect.to('db');

    // Get the structural definition of your entity
    const { MaterialEntity } = this.entities;


    //-----------------------------------------------------------------------------//
    // 1. Function: getProductDescByNumber
    // This function retrieves the Description of a material based on its Number
    //-----------------------------------------------------------------------------//
    this.on('getProductDescByNumber', async (req) => {
        const { Number } = req.data;

        // Query the database for the specific Material Number and retrieve the Description
        const material = await SELECT.one.from(MaterialEntity)
            .columns('Description')
            .where({ Number: Number });

        // Handle case where material is not found
        if (!material) {
            return req.error(404, `Material with Number ${Number} not found.`);
        }

        // Return just the string description
        return material.Description;
    });


    //-----------------------------------------------------------------------------//
    // 2. Action: getPrice
    // This function retrieves the Price of a material based on its Number
    //-----------------------------------------------------------------------------//
    this.on('getPrice', async (req) => {
        const { Number } = req.data;                // Extract Material Number from the POST request body
        const { MaterialEntity } = this.entities;   // Fetch the runtime entity reference

        // Query the database for a single material matching the provided Number
        // Note: Ensure 'Price' matches the exact column name in your Schema.Material definition
        const material = await SELECT.one.from(MaterialEntity)
            .columns('Price')
            .where({ Number: Number });

        // Handle case where the material number does not exist
        if (!material) {
            return req.error(404, `Material with Number ${Number} not found.`);
        }

        // Return the Price value (CAP handles converting JavaScript numbers to Decimal format)
        return material.Price;
    });


    //-----------------------------------------------------------------------------//
    // 3. Action: setPrice
    // This Action updates the Price of a material based on its Number
    //-----------------------------------------------------------------------------//
    this.on('setPrice', async (req) => {
        // Extract the context/keys of the target MaterialEntity (e.g., ID or Number)
        const keys = req.params[0];

        // Extract the action parameters from the payload
        const { Price } = req.data;

        if (Price < 0) return req.error(400, 'Price cannot be negative.');

        // Update the specific material record using CAP's Fluent Update API
        const updatedRows = await UPDATE(MaterialEntity)
            .set({ Price: Price })
            .where(keys);

        // If no rows were updated, the target material instance doesn't exist
        if (!updatedRows) return req.error(404, 'Material instance not found.');

        return "Price updated successfully.";
    });


    //-----------------------------------------------------------------------------//
    // 4. Action: changeDescription
    // This Action updates the Description of a material based on its Number
    //-----------------------------------------------------------------------------//
    this.on('changeDescription', async (req) => {
        // Extract the context/keys of the target MaterialEntity
        const keys = req.params[0];

        // Extract the action parameters from the payload
        const { Description } = req.data;

        if (!Description || Description.trim() === "") {
            return req.error(400, 'Description cannot be empty.');
        }

        // Update the specific material description
        const updatedRows = await UPDATE(MaterialEntity)
            .set({ Description: Description })
            .where(keys);

        if (!updatedRows) return req.error(404, 'Material instance not found.');

        return "Description updated successfully.";
    });



    //-----------------------------------------------------------------------------//
    // 5. Before Handler (Hooks)
    // This section contains before handlers that perform validation and preprocessing
    //  before certain operations (like CREATE) are executed on the MaterialEntity.
    //-----------------------------------------------------------------------------//
    this.before('CREATE', 'MaterialEntity', (req) => {
        const { Description, Price, Rating } = req.data;

        // Validate the incoming material description
        if (!Description || Description.trim() === "") {
            req.error(400, 'Material description is required.');
        }

        // Validate the incoming rating
        if (Rating !== undefined && (Rating < 1 || Rating > 5)) {
            req.error(400, 'Rating must be between 1 and 5.');
        }

        // Validate the incoming price
        if (Price !== undefined && Price !== null && Price < 0) {
            req.error(400, 'Base price cannot be negative.');
        }

    });


    //-----------------------------------------------------------------------------//
    // 6. After Handler (Hooks)
    // This section contains after handlers that perform validation and postprocessing
    //  after certain operations (like GET) are executed on the MaterialEntity.
    //-----------------------------------------------------------------------------//
    this.after('READ', 'MaterialEntity', (req) => {
        // CAP passes an array for multi-row queries, or a single object
        const items = Array.isArray(req) ? req : [req];

        for (const item of items) {
            // Only concatenate if both fields exist
            if (item.Price !== undefined && item.PriceUoM) {

                // Converts e.g., -45.99 and "USD" into "-45.99 USD"
                item.Price = `${item.Price} ${item.PriceUoM}`;
            }

            // 2. Remove the individual PriceUoM field from the output response
            delete item.PriceUoM;
        }
    });



    //-----------------------------------------------------------------------------//
    // 7. On Handler : Read
    // This section contains on handlers that perform validation and postprocessing
    //  after certain operations (like READ) are executed on the MaterialEntity.
    //-----------------------------------------------------------------------------//
    this.on('READ', 'MaterialEntity', async (req) => {

        // Standard CAP practice: Execute the incoming request query directly.
        // This automatically handles OData $expand=vendor, $filter, $top, etc.
        const result = await db.run(req.query);

        // Return the result for CAP to automatically map back to the client
        return result;

    });


    //-----------------------------------------------------------------------------//
    // 8. On Handler : Create
    // This section contains on handlers that perform validation and postprocessing
    //  after certain operations (like CREATE) are executed on the MaterialEntity.
    //-----------------------------------------------------------------------------//
    this.on('CREATE', 'MaterialEntity', async (req) => {
        const data = req.data;
        const { Rating } = req.data;

        if (Rating == 1) {
            data.Criticality = 1;
        } else if (Rating == 2 || Rating == 3) {
            data.Criticality = 2;
        } else if (Rating == 4 || Rating == 5) {
            data.Criticality = 3;
        }

        data.MaxRating = 5;

        // 1. Pass req.target instead of the string/variable 'MaterialEntity'.
        // req.target safely references the exact runtime database table context.
        await INSERT.into(req.target).entries(data);

        // 2. Return the processed data back to the client
        return data;
    });



    //-----------------------------------------------------------------------------//
    // 9. Action: addVendor
    // This function adds a vendor to a material
    //-----------------------------------------------------------------------------//
    this.on('addVendor', async (req) => {

        // 1. Extract the Material context/keys (e.g., { Number: 1001 })
        const materialKeys = req.params[0];
        if (!materialKeys) {
            return req.error(400, 'Action must be called on a specific Material instance.');
        }


        // 2. Perform a quick mandatory field check
        const { ID, Name, Address1, Address2, State, Country, Pin } = req.data;

        if (!ID || !Name) {
            return req.error(400, 'Vendor ID and Name are required fields.');
        }

        // 3. Generate a fresh runtime UUID for the Vendor's primary key
        const newVendorGUID = cds.utils.uuid();

        // 4. Fetch your entity structural objects
        const { VendorEntity, MaterialEntity } = this.entities;

        try {
            // 5. Insert the new record into the VendorEntity table
            await INSERT.into(VendorEntity).entries({
                GUID: newVendorGUID,
                ID: ID,
                Name: Name,
                AddressLine1: Address1,
                AddressLine2: Address2,
                State: State,
                Country: Country,
                Pincode: Pin
            });

            // 6. Update the current Material record to assign the new vendor's GUID
            // Note: CAP converts 'vendor : Association to Vendor' into 'vendor_GUID' in the DB
            const updatedRows = await UPDATE(MaterialEntity)
                .set({ vendor_GUID: newVendorGUID })
                .where(materialKeys);

            if (!updatedRows) {
                return req.error(404, `Target Material instance not found to link vendor.`);
            }

            return `Vendor '${Name}' created successfully and linked to Material.`;

        } catch (error) {
            // Handle database constraint exceptions (e.g., unique index violations) safely
            console.error('Error in addVendor action:', error);
            return req.error(500, `Failed to create Vendor: ${error.message}`);
        }

    });



    //-----------------------------------------------------------------------------//
    // 10. Action: addExistingVendor
    // This function adds an existing vendor to a material
    //-----------------------------------------------------------------------------//
    this.on('addExistingVendor', async (req) => {

        // 1. Extract the Material context/keys (e.g., { Number: 1001 })
        const materialKeys = req.params[0];
        if (!materialKeys) {
            return req.error(400, 'Action must be called on a specific Material instance.');
        }


        // 2. Perform a quick mandatory field check
        const { ID } = req.data;
        if (!ID) { return req.error(400, 'Vendor ID is a required field.'); }


        // 3. Fetch your entity structural objects
        const { VendorEntity, MaterialEntity } = this.entities;

        try {

            // 4. Check if the vendor with the given ID exists in the VendorEntity table
            let result = await SELECT.one.from(VendorEntity)
                .columns('GUID')
                .where({ ID: ID });

            let vendorGUID = result?.GUID;

            if (!vendorGUID) {
                return req.error(404, `Vendor with ID '${ID}' not found.`);
            }

            console.log(`Found existing Vendor with ID '${ID}', GUID: ${vendorGUID}`);


            // 5. Update the current Material record to assign the vendor's GUID
            // Note: CAP converts 'vendor : Association to Vendor' into 'vendor_GUID' in the DB
            const updatedRows = await UPDATE(MaterialEntity)
                .set({ vendor_GUID: vendorGUID })
                .where(materialKeys);

            if (!updatedRows) {
                return req.error(404, `Target Material instance not found to link vendor.`);
            }

            return `Vendor '${ID}' linked to Material.`;

        } catch (error) {
            // Handle database constraint exceptions (e.g., unique index violations) safely
            console.error('Error in addExistingVendor action:', error);
            return req.error(500, `Failed to link Vendor: ${error.message}`);
        }

    });



});
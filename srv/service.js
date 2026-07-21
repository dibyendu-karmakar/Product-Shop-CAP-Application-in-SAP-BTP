const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
    
    // Handle the custom function 'getProductDetails'
    this.on('getProductDetails', async (req) => {
        const { productId } = req.data;

        // 1. Validate the input parameter
        if (!productId) {
            return req.error(400, 'Product ID must be provided.');
        }

        // 2. Add your business logic here (e.g., Mocking data for this example)
        // In a real app, you would use: await SELECT.one.from(...).where({ ID: productId })
        if (productId === 'P100') {
            return {
                productId   : 'P100',
                name        : 'Wireless Mouse',
                description : 'Ergonomic 2.4GHz office mouse',
                price       : 29.99,
                stock       : 120
            };
        } else if (productId === 'P200') {
            return {
                productId   : 'P200',
                name        : 'Mechanical Keyboard',
                description : 'RGB Backlit mechanical keyboard with blue switches',
                price       : 89.50,
                stock       : 45
            };
        }

        // 3. Handle case where product is not found
        return req.error(404, `Product with ID ${productId} not found.`);
    });
    
});
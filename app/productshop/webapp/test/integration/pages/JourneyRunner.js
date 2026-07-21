sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"ns/productshop/test/integration/pages/MaterialEntityList.gen",
	"ns/productshop/test/integration/pages/MaterialEntityObjectPage.gen"
], function (JourneyRunner, MaterialEntityListGenerated, MaterialEntityObjectPageGenerated) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('ns/productshop') + '/test/flp.html#app-preview',
        pages: {
			onTheMaterialEntityListGenerated: MaterialEntityListGenerated,
			onTheMaterialEntityObjectPageGenerated: MaterialEntityObjectPageGenerated
        },
        async: true
    });

    return runner;
});


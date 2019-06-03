const Core = require('@alicloud/pop-core'),
    getFormBody = require('body/form');

const CEN_ID = process.env['CEN_ID'];
const SHARED_SECRET = process.env["SHARED_SECRET"];

function scaleHandler(alertName) {
    const client = new Core({
        accessKeyId: context.credentials.accessKeyId,
        accessKeySecret: context.credentials.accessKeySecret,
        securityToken: context.credentials.securityToken,
        endpoint: 'https://cbn.aliyuncs.com',
        apiVersion: '2017-09-12'
    });

    const json = process.env[`scale_strategy_${alertName}`];
    const strategy = JSON.parse(json);

    //////////////////
    // MODIFY CEN BANDWIDTH PACKAGE
    let result = await client.request('DescribeCenBandwidthPackages', {}, { method: 'POST' });
    let currentBandwidth;
    for (const package of result.CenBandwidthPackages.CenBandwidthPackage) {
        currentBandwidth = package.filter(id => id == CEN_ID)[0];
    }
    if (currentBandwidth === undefined) {
        throw new Error("CEN Instance has now active bandwidth package assigned.");
    }
    if (currentBandwidth + strategy.step < 2) {
        return;
    }

    const cenparams = {
        "CenBandwidthPackageId": CEN_ID,
        "Bandwidth": currentBandwidth + strategy.step
    }
    await client.request('ModifyCenBandwidthPackageSpec', cenparams, { method: 'POST' });
    
    //////////////////
    // MODIFY REGION CONNECTION
    result = await client.request('DescribeCenInterRegionBandwidthLimits', { "CenId": CEN_ID }, { methhod: 'POST' });
    const currentRegionBandwidth = 
        result.CenInterRegionBandwidthLimits.CenInterRegionBandwidthLimit
        .filter(i => i.OppositeRegionId == strategy.sourceRegion &&
                     i.LocalRegionId == strategy.targetRegion)[0];
    
    if (currentRegionBandwidth === undefined) {
        throw new Error("Region connectivity is not defined.");
    }
    const rcparams = {
        "CenId": CEN_ID,
        "LocalRegionId": strategy.sourceRegion,
        "OppositeRegionId": strategy.targetRegion,
        "BandwidthLimit": currentRegionBandwidth + strategy.step
    }
    await client.request('SetCenInterRegionBandwidthLimit', rcparams, { method: 'POST' });
}

module.exports.handler = (req, resp, context) => {
    if (req.queries.ss != SHARED_SECRET) {
        resp.send("");
    }
    getFormBody(req, (err, body) => {
        try {
            scaleHandler(body.alertName);
            resp.send("Successfully scaled CEN Bandwidth.");
        } catch(err) {
            console.log(err);
            resp.send(err);
            // TODO: put to error queue
        } 
    }); 
}
const Core = require('@alicloud/pop-core');

const CEN_ID = process.env['CEN_ID'],
 CEN_BWP_ID = process.env['CEN_BWP_ID'];

module.exports.handler = async function (event, context, callback) {
    const client = new Core({
        accessKeyId: context.credentials.accessKeyId,
        accessKeySecret: context.credentials.accessKeySecret,
        securityToken: context.credentials.securityToken,
        endpoint: 'https://cbn.aliyuncs.com',
        apiVersion: '2017-09-12'
    });


    const payload = JSON.parse(event.payload.toString("utf8"));

    try {
        const cenparams = {
            "CenBandwidthPackageId": CEN_BWP_ID,
            "Bandwidth": payload.cenBandwidth
        }

        if (payload.scale === "up") {
            await client.request('ModifyCenBandwidthPackageSpec', cenparams, { method: 'POST' });
            for (const rc of payload.regionConnections) {
                const rcparams = {
                    "CenId": CEN_ID,
                    "LocalRegionId": rc.sourceRegion,
                    "OppositeRegionId": rc.targetRegion,
                    "BandwidthLimit": rc.bandwidth
                }
                await client.request('SetCenInterRegionBandwidthLimit', rcparams, { method: 'POST' });
                callback(null, 'Successfully scaled CEN Bandwidth.'); 
            }
        }
        if (payload.scale === "down") {
            for (const rc of payload.regionConnections) {
                const rcparams = {
                    "CenId": CEN_ID,
                    "LocalRegionId": rc.sourceRegion,
                    "OppositeRegionId": rc.targetRegion,
                    "BandwidthLimit": rc.bandwidth
                }
                await client.request('SetCenInterRegionBandwidthLimit', rcparams, { method: 'POST' });
              
            }
            await client.request('ModifyCenBandwidthPackageSpec', cenparams, { method: 'POST' });
            callback(null, 'Successfully scaled CEN Bandwidth.');
        }
    } catch (err) {
        console.log(err);
        callback(err, 'Error while scaling CEN Bandwidth.'); 
    }
}
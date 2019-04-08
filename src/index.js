const accessToken = process.env['ACCESS_TOKEN'];

module.exports.handler = function (event, context, callback) {
   event = JSON.parse(event);
   
   
}








const eventFormat = {
    cenBandwidth: 20,
    regionConnections: [
        {
            sourceRegion: 'eu-central-1',
            targetRegion: 'cn-bejing',
            bandwidth: 10
        },
        {
            sourceRegion: 'eu-central-1',
            targetRegion: 'cn-shanghai',
            bandwidth: 10
        }
    ]
}
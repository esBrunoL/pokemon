// Listen on a specific host instead of the default '0.0.0.0'.
const host = 'localhost';
// Listen on a specific port.
const port = 8080;

const cors_proxy = require('cors-anywhere');
cors_proxy.createServer({
  originWhitelist: [], // Allow all origins
  requireHeader: ['origin', 'x-requested-with'],
  removeHeaders: ['cookie', 'cookie2']
}).listen(port, host, function() {
  console.log('Running CORS Anywhere on ' + host + ':' + port);
});

# API-Mock 

[![NPM](https://nodei.co/npm/api-mock.png?downloads=true)](https://nodei.co/npm/api-mock/)

API-Mock is a [node.js](http://nodejs.org/) [npm](https://npmjs.org/) module that generates a mock server (express) from your API specification. Document your API in the [API blueprint](http://apiblueprint.org/) format, and API-Mock mocks your routes and sends the responses defined in the api spec.

# Install

API-Mock requires node.js, and npm.

    npm install -g api-mock

## Installing from source

If you wish to install from source, you will need to build the library files manually (only the CoffeeScript source is committed to the repository). To do this, simply run:

    scripts/build

or 
    
    npm build

# Usage

    Usage:
      api-mock <path to blueprint>  [OPTIONS]
    
    Example:
      api-mock ./apiary.md --port 3000
    
    Options:
      --port, -p        Set which port api-mock should listen on.
                                                                     [default: 3000]
      --ssl-enable, -s  Enable SSL support.
                                                                    [default: false]
      --ssl-port        Set which port api-mock should listen on for SSL traffic.
                                                                     [default: 3080]
      --ssl-host        Set hostname for SSL server.

      --ssl-cert        Set path for SSL certificate file.
                                                           [default: "./server.crt"]
      --ssl-key         Set path for SSL key file.
                                                           [default: "./server.key"]
      --cors-disable, -c  Disable CORS headers.
                                                                    [default: false]
      --help              Show usage information.

      --version           Show version number.


## Prefer headers

You can set both `prefer` and `prefer-request` headers to control which example gets returned to the
client. 

```
Prefer: 400
Prefer-Request: valid
```

Will return a response with the name `400` from a request named `valid`

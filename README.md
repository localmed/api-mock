# API-Mock 

API-Mock is a [node.js](http://nodejs.org/) [npm](https://npmjs.org/) module that generates a mock server (express) from your API specification. Document your API in the [API blueprint](http://apiblueprint.org/) format, and API-Mock mocks your routes and sends the responses defined in the api spec.

# Install

API-Mock requires node.js, and npm.

    npm install -g api-mock

# Usage

    Usage:
      api-mock <path to blueprint>  [OPTIONS]
    
    Example:
      api-mock ./apiary.md --port 3000
    
    Options:
      --port, -p          Set which port api-mock should listen on.
                                                                     [default: 3000]
      --cors-disable, -c  Disable CORS headers.
                                                                    [default: false]
      --help              Show usage information.

      --version           Show version number.



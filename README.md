# API-Mock 

[![Build Status](https://travis-ci.org/localmed/api-mock.png?branch=master)](https://travis-ci.org/localmed/api-mock)
[![Coverage Status](https://img.shields.io/coveralls/localmed/api-mock.svg)](https://coveralls.io/r/localmed/api-mock?branch=master)

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
      --port, -p          Set which port api-mock should listen on.
                                                                     [default: 3000]
      --ssl-enable, -s    Enable SSL support.
                                                                    [default: false]
      --ssl-port          Set which port api-mock should listen on for SSL traffic.
                                                                     [default: 3080]
      --ssl-host          Set hostname for SSL server.

      --ssl-cert          Set path for SSL certificate file.
                                                           [default: "./server.crt"]
      --ssl-key           Set path for SSL key file.
                                                           [default: "./server.key"]
      --cors-disable, -c  Disable CORS headers.
                                                                    [default: false]
      --color, -k         Colorize cli output.
                                                                     [default: true]
      --help              Show usage information.

      --version           Show version number.


## Contribution
Contributions in the form of issues or pull requests are more than welcome! Make sure to follow Api-Mock [issues].

### Pull Requests

- Fork from the development branch
- Write good, clean, readable code
- Write tests for your contribution
    + Run tests with `npm test`
    + Other helper scripts available in `/scripts`
    + Keep the [test coverage] high
- Create a pull request

[test coverage]: https://coveralls.io/r/localmed/api-mock?branch=master
[issues]: https://github.com/localmed/api-mock/issues?state=open

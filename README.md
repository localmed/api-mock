# Contractor

Contractor is a [node.js](http://nodejs.org/) [npm](https://npmjs.org/) module that generates a mock server (express) from your API specification. Document your API in the [API blueprint](http://apiblueprint.org/) format, and contractor mocks your routes and sends the responses defined in the api spec.

# Install

Contractor requires node.js, and npm.

    npm install -g contractor

# Usage

    contractor <path to blueprint>  [OPTIONS]

    Example:
      contractor ./apiary.md --port 3000

    Options:
      --port, -p  Set which port contractor should listen on.
                                                                     [default: 3000]
      --help      Show usage information.
      --version   Show version number.



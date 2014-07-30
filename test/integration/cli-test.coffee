{assert} = require 'chai'
{exec} = require 'child_process'


stderr = ''
stdout = ''
exitStatus = null

execCommand = (cmd, callback) ->
  stderr = ''
  stdout = ''
  exitStatus = null

  cli = exec cmd, (error, out, err) ->
    stdout = out
    stderr = err

    if error
      exitStatus = error.code

  exitEventName = if process.version.split('.')[1] is '6' then 'exit' else 'close'

  cli.on exitEventName, (code) ->
    exitStatus = code if exitStatus == null and code != undefined
    callback()


cliForCommand = (cmd) ->
  stderr = ''
  stdout = ''
  exitStatus = null

  cli = exec cmd, (error, out, err) ->
    stdout = out
    stderr = err

    if error
      exitStatus = error.code


waitAndKill = (cli, ms, callback) ->
  setTimeout( () ->
        cli.kill()
        callback()
        return
      , ms)


# describe "Command Line Interface", ()->

#   describe "when blueprint not found", (done) ->
#     before (done) ->
#       cmd = "./bin/api-mock ./test/fixtures/nonexistent_path.apib"
#       execCommand cmd, done

#     it 'should exit with status 1', () ->
#       assert.equal exitStatus, 1

#     it 'should print error message to stderr', () ->
#       assert.include stderr, 'Error: ENOENT'

#   describe "when blueprint exists", () ->

#     before (done) ->
#       cmd = "./bin/api-mock ./test/fixtures/single-get.apib"
#       cli = cliForCommand cmd
#       waitAndKill(cli, 300, done)

#     it "should run the mock server on default port", () ->
#       assert.include stdout, '3000'

#     it "should display CORS information", () ->
#       assert.include stdout, 'Enabled Cross-Origin-Resource-Sharing'

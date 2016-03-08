# Description
#   A hubot script that runs Ansible playbooks
#
# Dependencies:
#   shelljs
#
# Configuration:
#   HUBOT_ANSIBLE_PLAYBOOKS_PATH
#
# Commands:
#   hubot ansible me <command> - runs `ansible-playbook` with the following command
#
# Author:
#   William Durand <will+git@drnd.me>

shell = require 'shelljs'

ansiblePath = process.env.HUBOT_ANSIBLE_PLAYBOOKS_PATH ? '.'

module.exports = (robot) ->

  if ! shell.which 'ansible'
    throw new Error('Cannot find ansible command')

  runAnsiblePlaybook = (msg, command) ->
    command = ['ansible-playbook', command].join(' ')
    command.replace "\u2014", "--"
    msg.send "Running `#{command}`"

    child = shell.exec "cd #{ansiblePath} && #{command}", { async: true }

    buffered = ""
    sendHandler = setInterval () ->
      msg.send buffered if buffered.length > 0
      buffered = ""
    , 500

    child.stdout.on 'data', (data) ->
      buffered += data

    child.stderr.on 'data', (data) ->
      msg.send data

    child.on 'exit', (code, signal) ->
      clearInterval sendHandler
      msg.send 'Finished.'

  robot.respond /ansible\s+me\s+(.+)/i, id: 'respond.ansible-me', (msg) ->
    command = msg.match[1]

    runAnsiblePlaybook msg, command

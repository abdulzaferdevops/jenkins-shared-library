// labSsh(command: ... | script: ..., args: [...], stdin: ..., returnStdout: bool)
//
// Runs something on the app server as the deploy user, with the lab's SSH settings.
//
//   labSsh(command: 'uptime')
//   labSsh(command: 'tar -xzf - -C /tmp/x', stdin: 'release.tgz')
//   labSsh(script: 'scripts/release.sh', args: ['deploy', '/opt/app', env.RELEASE])
//   String out = labSsh(command: 'cat /etc/hostname', returnStdout: true)
//
// Options: host (default env.APP_HOST), user ('deploy'), credentialsId ('app-server-deploy'),
//          returnStdout (false), label.
// BatchMode=yes: an unknown host key or a password prompt fails the build instead of hanging.
def call(Map cfg) {
  String host = cfg.host ?: env.APP_HOST
  String user = cfg.user ?: 'deploy'
  String credentialsId = cfg.credentialsId ?: 'app-server-deploy'
  boolean returnStdout = cfg.returnStdout ? true : false
  if (!host) {
    error('labSsh: no host (set APP_HOST or pass host:)')
  }

  String ssh = "ssh -o BatchMode=yes -o ConnectTimeout=10 ${user}@${host}"
  String commandLine
  if (cfg.script) {
    // ssh joins its arguments and the SERVER's shell parses them again, so quote twice:
    // each argument for the remote shell, then the whole remote command for the local shell.
    List args = (cfg.args ?: []) as List
    String remote = 'bash -s --'
    if (args) {
      remote += ' ' + args.collect { labShellQuote(it as String) }.join(' ')
    }
    commandLine = "${ssh} ${labShellQuote(remote)} < ${labShellQuote(cfg.script as String)}"
  } else if (cfg.command) {
    commandLine = "${ssh} ${labShellQuote(cfg.command as String)}"
    if (cfg.stdin) {
      commandLine += " < ${labShellQuote(cfg.stdin as String)}"
    }
  } else {
    error('labSsh needs command: or script:')
  }

  def result
  sshagent(credentials: [credentialsId]) {
    result = sh(label: (cfg.label ?: "ssh ${user}@${host}") as String,
                script: commandLine, returnStdout: returnStdout)
  }
  return returnStdout ? (result as String).trim() : result
}

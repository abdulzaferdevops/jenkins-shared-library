// labPreflight(vars: ['APP_HOST'], docker: false)
//
// Fails fast, with a clear message, if a required Jenkins global environment
// variable is missing, and (optionally) if Jenkins cannot use Docker.
def call(Map cfg = [:]) {
  List required = (cfg.vars ?: []) as List
  for (String name : required) {
    String value = env."${name}"
    if (!value?.trim()) {
      error("${name} is not set: Manage Jenkins > System > Global properties > Environment variables")
    }
  }
  if (cfg.docker) {
    sh(label: 'docker check',
       script: 'docker info >/dev/null 2>&1 || { echo "Jenkins cannot use Docker"; exit 1; }')
  }
  echo "preflight ok (${required ? required.join(', ') : 'no variables required'}${cfg.docker ? ', docker' : ''})"
}

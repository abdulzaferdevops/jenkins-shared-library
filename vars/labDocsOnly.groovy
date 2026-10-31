// labDocsOnly()  ->  true when every file changed since the last successful
// build is documentation (*.md, docs/, LICENSE, .gitignore, .gitattributes).
//
// Anything uncertain (first build, history rewritten, manual rebuild of the same
// commit) returns false, so the safe default is always to deploy.
// Optional: labDocsOnly(base: '<commit>', head: '<commit>')
boolean call(Map cfg = [:]) {
  String base = cfg.base ?: (env.GIT_PREVIOUS_SUCCESSFUL_COMMIT ?: '')
  String head = cfg.head ?: (env.GIT_COMMIT ?: 'HEAD')
  writeFile(file: '.lab-docs-only.sh', text: libraryResource('lab/docs_only.sh'))
  int rc = sh(label: 'docs-only check', returnStatus: true,
              script: "bash .lab-docs-only.sh ${labShellQuote(base)} ${labShellQuote(head)}")
  sh(label: 'clean up', script: 'rm -f .lab-docs-only.sh')
  return rc == 0
}

// labImageRef(repo: '<registry>/<namespace>/ci-labs/flask-api', ref: '<repo>@sha256:...')
//
// Fails the build unless ref is an immutable digest reference to exactly that repository.
// Returns the reference unchanged so it can be used inline.
String call(Map cfg) {
  if (!cfg.repo || !cfg.ref) {
    error('labImageRef needs repo: and ref:')
  }
  writeFile(file: '.lab-image-ref.sh', text: libraryResource('lab/image_ref.sh'))
  int rc = sh(label: 'image reference check', returnStatus: true,
              script: "bash .lab-image-ref.sh ${labShellQuote(cfg.repo as String)} ${labShellQuote(cfg.ref as String)}")
  sh(label: 'clean up', script: 'rm -f .lab-image-ref.sh')
  if (rc != 0) {
    error("Refusing image '${cfg.ref}': must be ${cfg.repo}@sha256:<64 hex>")
  }
  return cfg.ref as String
}

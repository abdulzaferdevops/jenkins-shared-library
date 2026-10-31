// CI for the ci-labs shared library itself:
// shell tests for the helpers in resources/lab/, then ShellCheck on every shell file.
// Consumers load a tagged version (@Library('ci-labs@vX.Y.Z')), so main can move
// without changing any pipeline until a new tag is adopted.

pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timeout(time: 10, unit: 'MINUTES')
  }

  triggers {
    githubPush()
  }

  environment {
    SHELLCHECK_IMAGE = 'koalaman/shellcheck:v0.10.0'
  }

  stages {
    stage('Shell tests') {
      steps {
        sh 'bash tests/run.sh'
      }
    }

    stage('ShellCheck') {
      steps {
        sh '''
          JC=$(hostname)
          docker inspect "$JC" >/dev/null 2>&1 || JC=jenkins
          docker run --rm --volumes-from "$JC" -w "$WORKSPACE" "$SHELLCHECK_IMAGE" \
            --severity=warning resources/lab/*.sh tests/*.sh
          echo "shellcheck: clean"
        '''
      }
    }

    stage('Library layout') {
      steps {
        sh '''
          for f in vars/*.groovy; do
            name=$(basename "$f" .groovy)
            grep -q "^// $name" "$f" || { echo "$f: first line must document $name(...)"; exit 1; }
          done
          echo "every step in vars/ starts with its usage comment"
          ls -1 vars/ resources/lab/
        '''
      }
    }
  }
}

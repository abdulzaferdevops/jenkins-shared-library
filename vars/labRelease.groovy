// labRelease()  ->  e.g. "00012-3f2a9c1"
//
// Release name used by every lab: zero-padded build number, then the short commit.
// Zero padding keeps release folders and history files sorted by build order.
String call() {
  String sha = env.GIT_COMMIT ?: 'manual'
  String shortSha = sha.length() > 7 ? sha.substring(0, 7) : sha
  int build = (env.BUILD_NUMBER ?: '0') as Integer
  return String.format('%05d-%s', build, shortSha)
}

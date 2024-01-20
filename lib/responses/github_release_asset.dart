class GitHubReleaseAsset {
  late String downloadUrl;
  late String contentType;
  late String name;
  late int size;

  static GitHubReleaseAsset fromJson(Map<String, dynamic> json) {
    var gitHubReleaseAsset = GitHubReleaseAsset();

    gitHubReleaseAsset.downloadUrl = json['browser_download_url'];
    gitHubReleaseAsset.contentType = json['content_type'];
    gitHubReleaseAsset.name = json['name'];
    gitHubReleaseAsset.size = json['size'];

    return gitHubReleaseAsset;
  }

  static GitHubReleaseAsset empty() {
    var gitHubReleaseAsset = GitHubReleaseAsset();

    gitHubReleaseAsset.downloadUrl = '';
    gitHubReleaseAsset.contentType = '';
    gitHubReleaseAsset.name = '';
    gitHubReleaseAsset.size = 0;

    return gitHubReleaseAsset;
  }

  int getVersionCode() {
    RegExp regex = RegExp(r'v(\d+)\.apk');
    var match = regex.firstMatch(name);

    if (match != null) {
      String? versionNumber = match.group(1);

      return int.parse('$versionNumber');
    }

    return 0;
  }
}

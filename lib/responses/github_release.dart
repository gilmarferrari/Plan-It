import 'github_release_asset.dart';

class GitHubRelease {
  late List<GitHubReleaseAsset> assets;

  static GitHubRelease fromJson(Map<String, dynamic> json) {
    var gitHubRelease = GitHubRelease();

    gitHubRelease.assets = ((json['assets'] ?? []) as List)
        .map((a) => GitHubReleaseAsset.fromJson(a))
        .toList();

    return gitHubRelease;
  }

  GitHubReleaseAsset getApkAsset() {
    return assets.firstWhere(
        (a) => a.contentType == 'application/vnd.android.package-archive',
        orElse: () => GitHubReleaseAsset.empty());
  }
}

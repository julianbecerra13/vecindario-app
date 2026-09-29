import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vecindario_app/core/services/mock_media_storage.dart';

Future<bool> openMedia(String url) async {
  if (MockMediaStorage.isLocal(url)) {
    await Share.shareXFiles([XFile(MockMediaStorage.fileFromUrl(url).path)]);
    return true;
  }
  return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:memory_compass/core/error/exceptions.dart';

/// Wraps [GoogleSignIn] and produces an authenticated HTTP client that
/// `googleapis`' [drive.DriveApi] can use. Requests only the `drive.file`
/// scope, i.e. the app can only see/manage the files it creates itself -
/// not the user's whole Drive.
class GoogleAuthDataSource {
  GoogleAuthDataSource()
    : _googleSignIn = GoogleSignIn(
        scopes: const [drive.DriveApi.driveFileScope],
      );

  final GoogleSignIn _googleSignIn;

  Stream<GoogleSignInAccount?> get onAccountChanged =>
      _googleSignIn.onCurrentUserChanged;

  GoogleSignInAccount? get currentAccount => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> restoreSession() =>
      _googleSignIn.signInSilently();

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<void> signOut() => _googleSignIn.signOut();

  Future<http.Client> authenticatedClient() async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw const AuthenticationException('Not signed in to Google.');
    }
    final headers = await account.authHeaders;
    return _GoogleAuthClient(headers);
  }
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

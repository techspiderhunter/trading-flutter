import '../../../global/helpers/Request.dart';
import '../../../global/models/ServerResponse.dart';

class SplashRequest {
  Future<ServerResponse> me() => Request.get('/user/auth/me', auth: true);

  Future<ServerResponse> vehicles() => Request.get(
        '/user/vehicles',
        auth: true,
        query: {'page': 1, 'limit': 10},
      );
}

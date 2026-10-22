import 'package:techspiderhunter/global/helpers/Request.dart';
import 'package:techspiderhunter/includes/Storage.dart';

class CommonRequest {
  static Future<dynamic> getCommonCategories({ int page = 1, int limit = 10,required String code, String? parentId,String? level, bool private = false}) async {

    String query = "?code=$code&business_id=${await LocalStorage.read("active_business_id").toString()}";

    if(parentId != null && parentId.isNotEmpty){
      query += "&parent_id=$parentId";
    }
    if(level != null && level.isNotEmpty){
      query += "&level=$level";
    }

    final endpoint =
        '/get-common-categories$query';

    return await Request.get(endpoint);
  }

  
}
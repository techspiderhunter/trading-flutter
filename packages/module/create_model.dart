import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Please provide a module name (e.g., dart run lib/full_module_create.dart UserSetting)');
    exit(1);
  }

  String moduleName = args[0];
  // Capitalize the module name (e.g., userSetting -> UserSetting)
  moduleName = moduleName.split('_').map((word) =>
  word[0].toUpperCase() + word.substring(1).toLowerCase()).join('');

  // Define paths
  String modulePath = 'lib/modules/$moduleName';
  String controllersPath = '$modulePath/controllers';
  String modelsPath = '$modulePath/models';
  String requestsPath = '$modulePath/requests';
  String routesPath = '$modulePath/routes';
  String viewsPath = '$modulePath/views';
  String widgetsPath = '$viewsPath/widgets';
  String mocksPath = '$modulePath/mocks';
  String shimmersPath = '$modulePath/shimmers';
  String servicesPath = '$modulePath/services';

  // Create directories
  List<String> directories = [
    modulePath,
    controllersPath,
    modelsPath,
    requestsPath,
    routesPath,
    viewsPath,
    widgetsPath,
    mocksPath,
    shimmersPath,
    servicesPath,
  ];

  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
  }

  // Generate files with content
  _generateController(moduleName, '$controllersPath/${moduleName}Controller.dart');
  _generateModel(moduleName, '$modelsPath/${moduleName}Model.dart');
  _generateRequest(moduleName, '$requestsPath/${moduleName}Request.dart');
  _generateRoutes(moduleName, '$routesPath/${moduleName}Routes.dart');
  _generateView(moduleName, '$viewsPath/${moduleName}Index.dart');
  _generateImports(moduleName, '$modulePath/imports.dart');
  _generateWidget(moduleName, '$widgetsPath/${moduleName}CardWidget.dart');
  _generateMock(moduleName, '$mocksPath/${moduleName}Mock.dart');
  _generateShimmer(moduleName, '$shimmersPath/${moduleName}Shimmer.dart');
  _generateService(moduleName, '$servicesPath/${moduleName}Service.dart');

  print('Module $moduleName created successfully at $modulePath');
}

void _generateController(String moduleName, String path) {
  String content = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../global/controllers/MainController.dart';
import '../../../includes/Storage.dart';
import '../imports.dart';
import '../models/${moduleName}Model.dart';
import '../requests/${moduleName}Request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ${moduleName}Controller extends MainController {
  final TextEditingController nameInput = TextEditingController();
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController phoneInput = TextEditingController();
  final TextEditingController companyIdInput = TextEditingController();

  final _apiService = ${moduleName}Request();

  var _${moduleName.toLowerCase()}Model = ${moduleName}Model().obs;
  ${moduleName}Model get ${moduleName.toLowerCase()}Model => _${moduleName.toLowerCase()}Model.value;

  @override
  void onInit() async {
    super.onInit();
    String? phone = await LocalStorage.read('phone');
    String? companyId = await LocalStorage.read('company_id');
    phoneInput.text = phone ?? '';
    companyIdInput.text = companyId ?? '';
    fetch${moduleName}("\${phoneInput.text}", "2a12sgVW5E1dCNRzLRZJTySO3Oi3rbXTASPxrwYaQYkHax4qGd0AOgu");
  }

  Future<void> fetch${moduleName}(String mobile, String secureKey) async {
    try {
      String? companyId = await LocalStorage.read('company_id');
      final response = await http.post(
        Uri.parse('https://dev.syscalls.in/api/${moduleName.toLowerCase()}.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'mobile': mobile,
          'company_id': companyId,
          'secure_key': secureKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          print('${moduleName} fetched successfully');
          nameInput.text = "\${responseData['data']['name']}";
          emailInput.text = "\${responseData['data']['email']}";
          _${moduleName.toLowerCase()}Model.value = ${moduleName}Model.fromJson(responseData['data']);
        } else {
          print('Failed to fetch ${moduleName.toLowerCase()}: \${responseData['message']}');
        }
      } else {
        print('Request failed with status: \${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: \$e');
    }
  }

  Future<void> update${moduleName}() async {
    var url = Uri.parse('https://dev.syscalls.in/api/update-${moduleName.toLowerCase()}.php');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'mobile': '\${phoneInput.text}',
      'secure_key': '2a12sgVW5E1dCNRzLRZJTySO3Oi3rbXTASPxrwYaQYkHax4qGd0AOgu',
      'name': '\${nameInput.text}',
      'email': '\${emailInput.text}',
      'company_id': '\${companyIdInput.text}',
    };

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('${moduleName} updated successfully: \${response.body}');
      } else {
        print('Failed to update ${moduleName.toLowerCase()}. Status code: \${response.statusCode}');
      }
    } catch (e) {
      print('Error: \$e');
    }
  }

  Future<void> delete${moduleName}(String id) async {
    var url = Uri.parse('https://dev.syscalls.in/api/delete-${moduleName.toLowerCase()}.php');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {'id': id};

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('${moduleName} deleted successfully: \${response.body}');
      } else {
        print('Failed to delete ${moduleName.toLowerCase()}. Status code: \${response.statusCode}');
      }
    } catch (e) {
      print('Error: \$e');
    }
  }
}
''';
  File(path).writeAsStringSync(content);
}

void _generateModel(String moduleName, String path) {
  String content = '''
import 'dart:convert';

${moduleName}Model ${moduleName.toLowerCase()}ModelFromJson(String str) => ${moduleName}Model.fromJson(json.decode(str));

String ${moduleName.toLowerCase()}ModelToJson(${moduleName}Model data) => json.encode(data.toJson());

class ${moduleName}Model {
  dynamic id;
  String? name;
  String? email;
  String? mobile;
  String? companyId;
  DateTime? createdAt;

  ${moduleName}Model({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.companyId,
    this.createdAt,
  });

  ${moduleName}Model copyWith({
    dynamic id,
    String? name,
    String? email,
    String? mobile,
    String? companyId,
    DateTime? createdAt,
  }) =>
      ${moduleName}Model(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
        companyId: companyId ?? this.companyId,
        createdAt: createdAt ?? this.createdAt,
      );

  factory ${moduleName}Model.fromJson(Map<String, dynamic> json) => ${moduleName}Model(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        companyId: json["company_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "company_id": companyId,
        "created_at": createdAt?.toIso8601String(),
      };
}
''';
  File(path).writeAsStringSync(content);
}

void _generateRequest(String moduleName, String path) {
  String content = '''
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/${moduleName}Model.dart';

class ${moduleName}Request {
  final String apiUrl = 'https://dev.syscalls.in/api/${moduleName.toLowerCase()}.php';

  Future<${moduleName}Model?> fetch${moduleName}(String mobile, String secureKey) async {
    final url = Uri.parse(apiUrl);
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {
      'mobile': mobile,
      'secure_key': secureKey,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return ${moduleName}Model.fromJson(responseData['data']);
        } else {
          print('Error: \${responseData['message']}');
          return null;
        }
      } else {
        print('Error: Failed to load ${moduleName.toLowerCase()}');
        return null;
      }
    } catch (e) {
      print('Error: \$e');
      return null;
    }
  }
}
''';
  File(path).writeAsStringSync(content);
}

void _generateRoutes(String moduleName, String path) {
  String content = '''
import '../imports.dart';
import 'package:get/get.dart';

class ${moduleName}Routes {
  static const ${moduleName.toLowerCase()}Index = '/${moduleName.toLowerCase()}/index';
  static const update${moduleName} = '/update${moduleName}';

  static final routes = [
    GetPage(
      name: ${moduleName.toLowerCase()}Index,
      page: () => ${moduleName}Index(),
    ),
    GetPage(
      name: update${moduleName},
      page: () => Update${moduleName}Page(),
    ),
  ];
}
''';
  File(path).writeAsStringSync(content);
}

void _generateView(String moduleName, String path) {
  String content = '''
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../imports.dart';
import '../../../includes/MainHeader.dart';

class ${moduleName}Index extends StatelessWidget {
  const ${moduleName}Index({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainHeader(),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/components/${moduleName.toLowerCase()}_graphic.png',
                    height: 250,
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Get.toNamed(${moduleName}Routes.${moduleName.toLowerCase()}Index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Explore ${moduleName}",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Update${moduleName}Page extends StatelessWidget {
  const Update${moduleName}Page({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(${moduleName}Controller());
    return AppLayout(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: controller.nameInput,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: controller.emailInput,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: controller.phoneInput,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: controller.companyIdInput,
                decoration: InputDecoration(labelText: 'Company ID'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.update${moduleName}(),
                child: Text('Update ${moduleName}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';
  File(path).writeAsStringSync(content);
}

void _generateImports(String moduleName, String path) {
  String content = '''
// Packages exports
export 'package:flutter/material.dart';
export 'package:get/get.dart';
export 'views/${moduleName}Index.dart';

// Others
export '../../../layouts/AppLayout.dart';
export '../../../includes/Drawer.dart';
export 'package:techspiderhunter/global/controllers/MainController.dart';
export 'package:techspiderhunter/includes/Footer.dart';
export 'package:techspiderhunter/modules/Setting/imports.dart';

// Routes
export 'routes/${moduleName}Routes.dart';

// Views
export 'views/widgets/${moduleName}CardWidget.dart';

// Models
export 'models/${moduleName}Model.dart';

// Controllers
export 'controllers/${moduleName}Controller.dart';

// Requests
export 'requests/${moduleName}Request.dart';
export '../../global/helpers/Request.dart';
''';
  File(path).writeAsStringSync(content);
}

void _generateWidget(String moduleName, String path) {
  String content = '''
import 'package:flutter/material.dart';
import '../imports.dart';

class ${moduleName}CardWidget extends StatelessWidget {
  const ${moduleName}CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('${moduleName} Card Widget'),
      ),
    );
  }
}
''';
  File(path).writeAsStringSync(content);
}

void _generateMock(String moduleName, String path) {
  String content = '''
// Mock data for ${moduleName}
class ${moduleName}Mock {
  static Map<String, dynamic> getMock${moduleName}() {
    return {
      "id": "1",
      "name": "Mock ${moduleName}",
      "email": "mock@${moduleName.toLowerCase()}.com",
      "mobile": "1234567890",
      "company_id": "mock_company",
      "created_at": "2025-05-22T00:00:00Z",
    };
  }
}
''';
  File(path).writeAsStringSync(content);
}

void _generateShimmer(String moduleName, String path) {
  String content = '''
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ${moduleName}Shimmer extends StatelessWidget {
  const ${moduleName}Shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        color: Colors.white,
        margin: const EdgeInsets.all(8.0),
      ),
    );
  }
}
''';
  File(path).writeAsStringSync(content);
}

void _generateService(String moduleName, String path) {
  String content = '''
import '../imports.dart';

class ${moduleName}Service {
  // Add service methods for ${moduleName}
}
''';
  File(path).writeAsStringSync(content);
}
import 'dart:io';
import 'package:path/path.dart' as path;


/// Example: dart run packages/module/full_module_create.dart UserSetting
String getFileContent(String relativePath, {String moduleCapitalName = 'Folder'}) {
  final basePath = Directory.current.path; // Dynamic project root
  final file = File(path.join(basePath, 'packages/module/Folder', relativePath));
  try {
    if (!file.existsSync()) {
      print('Warning: File not found: ${file.path}. Using default content.');
      switch (relativePath) {
        case 'controllers/FolderController.dart':
          return '// Default controller\nclass ${moduleCapitalName}Controller extends GetxController {}';
        case 'models/FolderModel.dart':
          return '// Default model\nclass ${moduleCapitalName}Model {}';
        case 'requests/FolderRequest.dart':
          return '// Default request\nclass ${moduleCapitalName}Request {}';
        case 'routes/FolderRoutes.dart':
          return '// Default routes\nclass ${moduleCapitalName}Routes {}';
        case 'views/FolderIndex.dart':
          return '// Default view\nimport \'package:flutter/material.dart\';\nclass ${moduleCapitalName}Index extends StatelessWidget { const ${moduleCapitalName}Index({super.key}); @override Widget build(BuildContext context) => Scaffold(); }';
        case 'mocks/FolderMock.dart':
          return '// Default mock\nclass ${moduleCapitalName}Mock {}';
        case 'shimmers/FolderShimmer.dart':
          return '// Default shimmer\nimport \'package:flutter/material.dart\';\nclass ${moduleCapitalName}Shimmer extends StatelessWidget { const ${moduleCapitalName}Shimmer({super.key}); @override Widget build(BuildContext context) => Container(); }';
        case 'services/FolderService.dart':
          return '// Default service\nclass ${moduleCapitalName}Service {}';
        case 'imports.dart':
          return '// Default imports';
        default:
          return '// Default content';
      }
    }
    return file.readAsStringSync();
  } catch (e) {
    print('Error reading file: $e');
    return '// Error reading content\nclass ${moduleCapitalName}Controller extends GetxController {}';
  }
}

void main(List<String> args) {
  if (args.isEmpty) {
    print('Please provide a module name (e.g., dart run lib/full_module_create.dart UserSetting)');
    exit(1);
  }

  // Capitalize the module name (e.g., userSetting -> UserSetting)
  String moduleCapitalName = args[0]
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join('');

  // Define paths
  String modulePath = 'lib/modules/$moduleCapitalName';
  String controllersPath = '$modulePath/controllers';
  String modelsPath = '$modulePath/models';
  String requestsPath = '$modulePath/requests';
  String routesPath = '$modulePath/routes';
  String viewsPath = '$modulePath/views';
  String widgetsPath = '$viewsPath/widgets';
  String mocksPath = '$modulePath/mocks';
  String shimmersPath = '$modulePath/shimmers';

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
  ];

  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
  }

  // Generate files with content
  _generateController(moduleCapitalName, '$controllersPath/${moduleCapitalName}Controller.dart');
  _generateModel(moduleCapitalName, '$modelsPath/${moduleCapitalName}Model.dart');
  _generateRequest(moduleCapitalName, '$requestsPath/${moduleCapitalName}Request.dart');
  _generateRoutes(moduleCapitalName, '$routesPath/${moduleCapitalName}Routes.dart');
  _generateView(moduleCapitalName, '$viewsPath/${moduleCapitalName}Index.dart');
  _generateImports(moduleCapitalName, '$modulePath/imports.dart');
  _generateMock(moduleCapitalName, '$mocksPath/${moduleCapitalName}Mock.dart');
  _generateShimmer(moduleCapitalName, '$shimmersPath/${moduleCapitalName}Shimmer.dart');

  print('Module $moduleCapitalName created successfully at $modulePath');
}

void _generateController(String moduleCapitalName, String path) {
  String controllerFileCode = getFileContent('controllers/FolderControllers.dart', moduleCapitalName: moduleCapitalName);

  // Replace 'Folder' with moduleCapitalName
  controllerFileCode = controllerFileCode
      .replaceAll('FolderController', '${moduleCapitalName}Controller')
      .replaceAll('FolderMock', '${moduleCapitalName}Mock')
      .replaceAll('FolderModel', '${moduleCapitalName}Model')
      .replaceAll('FolderRequest', '${moduleCapitalName}Request')
      .replaceAll('folderController', '${moduleCapitalName.toLowerCase()}Controller');

  File(path).writeAsStringSync(controllerFileCode);
}

void _generateModel(String moduleCapitalName, String path) {
  String content = getFileContent('models/FolderModel.dart', moduleCapitalName: moduleCapitalName);

  content = content
      .replaceAll('FolderModel', '${moduleCapitalName}Model')
      .replaceAll('folderModel', '${moduleCapitalName.toLowerCase()}Model');

  File(path).writeAsStringSync(content);
}

void _generateRequest(String moduleCapitalName, String path) {
  String content = getFileContent('requests/FolderRequest.dart', moduleCapitalName: moduleCapitalName);

  content = content
      .replaceAll('FolderRequest', '${moduleCapitalName}Request')
      .replaceAll('FolderModel', '${moduleCapitalName}Model')
      .replaceAll('folders', '${moduleCapitalName.toLowerCase()}s')
      .replaceAll('folder', moduleCapitalName.toLowerCase());

  File(path).writeAsStringSync(content);
}

void _generateRoutes(String moduleCapitalName, String path) {
  String content = getFileContent('routes/FolderRoutes.dart', moduleCapitalName: moduleCapitalName);

  content = content
      .replaceAll('FolderRoutes', '${moduleCapitalName}Routes')
      .replaceAll('FolderIndex', '${moduleCapitalName}Index')
      .replaceAll('UpdateFolderPage', 'Update${moduleCapitalName}Page')
      .replaceAll('folderIndex', '${moduleCapitalName.toLowerCase()}Index')
      .replaceAll('updateFolder', 'update$moduleCapitalName')
      .replaceAll('folder', moduleCapitalName.toLowerCase());

  File(path).writeAsStringSync(content);
}

void _generateView(String moduleCapitalName, String path) {
  String content = getFileContent('views/FolderIndex.dart', moduleCapitalName: moduleCapitalName);

  content = content
      .replaceAll('FolderIndex', '${moduleCapitalName}Index')
      .replaceAll('UpdateFolderPage', 'Update${moduleCapitalName}Page')
      .replaceAll('FolderController', '${moduleCapitalName}Controller')
      .replaceAll('FolderRoutes', '${moduleCapitalName}Routes')
      .replaceAll('folder_graphic.png', '${moduleCapitalName.toLowerCase()}_graphic.png')
      .replaceAll('Explore Folder', 'Explore $moduleCapitalName')
      .replaceAll('Update Folder', 'Update $moduleCapitalName')
      .replaceAll('folder', moduleCapitalName.toLowerCase());

  File(path).writeAsStringSync(content);
}

void _generateImports(String moduleCapitalName, String path) {
  String content = getFileContent('imports.dart', moduleCapitalName: moduleCapitalName);

  content = content
      .replaceAll('FolderIndex', '${moduleCapitalName}Index')
      .replaceAll('FolderRoutes', '${moduleCapitalName}Routes')
      .replaceAll('FolderCardWidget', '${moduleCapitalName}CardWidget')
      .replaceAll('FolderModel', '${moduleCapitalName}Model')
      .replaceAll('FolderController', '${moduleCapitalName}Controller')
      .replaceAll('FolderRequest', '${moduleCapitalName}Request')
      .replaceAll('folder', moduleCapitalName.toLowerCase());

  File(path).writeAsStringSync(content);
}

void _generateMock(String moduleCapitalName, String path) {
  String content = getFileContent('mocks/FolderMock.dart', moduleCapitalName: moduleCapitalName);

  content = content
      .replaceAll('FolderMock', '${moduleCapitalName}Mock')
      .replaceAll('getMockFolder', 'getMock$moduleCapitalName')
      .replaceAll('Mock Folder', 'Mock $moduleCapitalName')
      .replaceAll('folder.com', '${moduleCapitalName.toLowerCase()}.com')
      .replaceAll('folder', moduleCapitalName.toLowerCase());

  File(path).writeAsStringSync(content);
}

void _generateShimmer(String moduleCapitalName, String path) {
  String content = getFileContent('shimmers/FolderShimmer.dart', moduleCapitalName: moduleCapitalName);

  content = content.replaceAll('FolderShimmer', '${moduleCapitalName}Shimmer');

  File(path).writeAsStringSync(content);
}

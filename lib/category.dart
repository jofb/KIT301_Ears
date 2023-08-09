import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class Category {
  final String categoryName;
  final List<Question> questions;
  final String identifier;

  Category.fromJson(Map<String, dynamic> json)
      : categoryName = json['category_name'],
        identifier = json['identifier'],
        questions = List<Question>.from(
            json['questions'].map((question) => Question.fromJson(question)));

  Map<String, dynamic> toJson() => {
        'category_name': categoryName,
        'identifier': identifier,
        'questions': questions,
      };
}

class Question {
  final String full;
  final String short;
  final String type;
  final String audioId;
  final String identifier;
  final List<String> audioAvailable = [];

  Question.fromJson(Map<String, dynamic> json)
      : full = json['full_question'],
        short = json['short_question'],
        type = json['type'],
        identifier = json['identifier'],
        audioId = json['audioId'];

  Question(this.full, this.short, this.type, this.identifier, this.audioId);

  bool hasAudioAvailable(String lang) {
    return audioAvailable.contains(lang);
  }
}

class CategoriesModel extends ChangeNotifier {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Categories');

  List<Category> categories = [];
  late final Directory categoryDirectory;

  CategoriesModel() {
    initModel();
  }

  Future initModel() async {
    await initFilePath();
    initCategories();
  }

  // initializes the global file path for categories
  // if doing audio can also do here
  Future initFilePath() async {
    if (kIsWeb) return;
    const String categoryPath = 'categories';
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$categoryPath');
    // ensure categories directory exists
    if (!await Directory(dir.path).exists()) {
      await Directory(dir.path).create();
    }
    categoryDirectory = dir;
  }

  // initializes category list
  Future initCategories() async {
    print("Initializing categories");
    List<Category> tempCategoryList = [];

    // create an index of every single audio file
    // first we need the language labels
    final languageLabels = await jsonDecode(
            await rootBundle.loadString('assets/ml/label_maps.json'))
        .map((e) => e['code'])
        .toList();
    // now get the directory for the audio files
    // for now this is in assets
    // TODO move this to application directory
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> map = json.decode(manifest);

    final audioPaths = map.keys
        .where((String key) => key.contains('audio/'))
        .map((e) => e.split('audio/')[1])
        .toList();
    print(languageLabels);

    // if in web, just load from assets for testing
    if (kIsWeb) {
      // get the asset manifest map
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // find all our json files inside categories dir
      final categoryPaths = manifestMap.keys
          .where((String key) => key.contains('categories/'))
          .where((String key) => key.contains('.json'))
          .toList();

      // decode them and append to list
      for (var path in categoryPaths) {
        final rawJson = await rootBundle.loadString(path);
        final category = Category.fromJson(jsonDecode(rawJson));
        tempCategoryList.add(category);
      }
    } else {
      await for (var file in categoryDirectory.list()) {
        // get all json files in the directory then add them to the list
        if (file is File && file.path.endsWith(".json")) {
          final json = await file.readAsString();
          final category = Category.fromJson(jsonDecode(json));
          // check each question for audio
          for (Question question in category.questions) {
            // for each question we're going to iterate over the languages and check if the audio exists
            String id = question.audioId;
            for (var label in languageLabels) {
              String path = "$label/${label}_$id.mp3";
              if (audioPaths.contains(path)) {
                // add this to the question
                question.audioAvailable.add(label);
              }
            }
          }
          // loop over questions
          // check audio directory if they exist
          // we dont need to index every file, we can just
          tempCategoryList.add(category);
        }
      }
    }
    // sort categories list by identifiers
    tempCategoryList.sort(
        (a, b) => int.parse(a.identifier).compareTo(int.parse(b.identifier)));

    categories = tempCategoryList;
    update();
  }

  // loads the collection from firebase and saves locally
  Future loadCollection() async {
    // don't load anything if in web
    if (kIsWeb) return;

    // get the categories
    var query = await collection.orderBy('identifier').get();

    for (var category in query.docs) {
      // items is a collection inside of the category, need to fetch that
      var items = await category.reference
          .collection('Items')
          .orderBy('identifier')
          .get();

      // get the questions as a list of maps
      var questions = List<Map<String, dynamic>>.empty(growable: true);
      for (var q in items.docs) {
        var que = q.data();
        questions.add(que);
      }

      //identifier is a string, need to order by it but as a int
      questions.sort((a, b) =>
          int.parse(a['identifier']).compareTo(int.parse(b['identifier'])));

      // convert to a map object
      var categoryData = {
        'category_name': category.get('category_name'),
        'identifier': category.get('identifier'),
        'questions': questions.toList()
      };

      // encode as json
      String jsonString = json.encode(categoryData);
      // finally save to file
      // using id as file name
      var file = File("${categoryDirectory.path}/category_${category.id}.json");
      await file.writeAsString(jsonString);
    }
    initCategories();
  }

  // clears the directory containing category files
  void clearCollection() async {
    if (categoryDirectory.existsSync()) {
      for (var file in categoryDirectory.listSync()) {
        file.deleteSync();
      }
    }
    categories.clear();
    print('Categories cache cleared');
  }

  void update() {
    notifyListeners();
  }
}

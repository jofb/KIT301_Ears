import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../utils/log.dart';

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
  List<String> audioAvailable = [];

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
  bool loading = false;

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
    logger.i("Initializing categories");
    List<Category> tempCategoryList = [];

    // directory for audio files
    final appDir = await getApplicationDocumentsDirectory();
    // ensure audio directory exists
    final audioDir = Directory("${appDir.path}/audio");

    if (!await Directory(audioDir.path).exists()) {
      await Directory(audioDir.path).create();
    }
    final audioPaths = audioDir
        .listSync(recursive: true)
        .map((e) => e.path.split('audio/')[1])
        .where((e) => e.contains('/'))
        .toList();

    final Map<String, List<String>> audioAvailableById = {};

    // loop over every audio path
    // split the id from the langauge
    // add to a map which maps id to language list

    for (String audio in audioPaths) {
      String lang = audio.split('/')[0];
      String id = audio.split('_')[1].split('.')[0];
      // get the list for id and add our langauge
      List<String> list = audioAvailableById.putIfAbsent(id, () => []);
      list.add(lang);
    }

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
          // get the list of available audio and append to list
          for (Question q in category.questions) {
            q.audioAvailable = audioAvailableById[q.audioId] ?? [];
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
    loading = false;
    update();
  }

  // loads the collection from firebase and saves locally
  Future loadCollection() async {
    loading = true;
    update();
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
      var questions = items.docs.map((item) => item.data()).toList();
      // var questions = List<Map<String, dynamic>>.empty(growable: true);
      // for (var q in items.docs) {
      //   var que = q.data();
      //   questions.add(que);
      // }

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
    logger.i('Categories cache cleared');
  }

  void update() {
    notifyListeners();
  }
}

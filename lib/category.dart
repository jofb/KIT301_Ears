import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Category {
  final String categoryName;
  final List<Question> questions;

  Category.fromJson(Map<String, dynamic> json)
  :
    categoryName = json['category_name'],
    questions = List<Question>.from(json['questions'].map((question) => Question.fromJson(question)));

  Map<String, dynamic> toJson() =>
      {  
        'category_name': categoryName,
        'questions': questions,
      };
}

class Question {
  final String full;
  final String short;
  final String type;
  final String id;
  late String audioId;

  Question.fromJson(Map<String, dynamic> json)
      : full = json['full_question'],
        short = json['short_question'],
        type = json['type'],
        id = json['identifier'],
        audioId = json['audioId'];

  Question(this.full, this.short, this.type, this.id);
}

class CategoriesModel extends ChangeNotifier {
  CollectionReference collection =
      FirebaseFirestore.instance.collection('Categories');

  List<Category> categories = [];
  late final Directory categoryDirectory;

  CategoriesModel() {
    initModel();
    // TODO do we want to load the collection on startup everytime?
    // loadCollection();
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
    print("I'm initializing categories");
    List<Category> tempCategoryList = [];

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
      // other devices grab from documents directory (app data)
      // final dir = await getApplicationDocumentsDirectory();
      // TODO this should be different based on where we place the category data
      await for (var file in categoryDirectory.list()) {
        // get all json files in the directory then add them to the list
        if (file is File && file.path.endsWith(".json")) {
          final json = await file.readAsString();
          final category = Category.fromJson(jsonDecode(json));
          tempCategoryList.add(category);
        }
      }
    }

    categories = tempCategoryList;
    update();
  }

  // loads the collection from firebase and saves locally
  Future loadCollection() async {
    // don't load anything if in web
    if (kIsWeb) return;

    var query = await collection.get();

    for (var category in query.docs) {
      // items is a collection inside of the category, need to fetch that
      var items = await category.reference.collection('Items').orderBy("identifier").get();
      
      // get the questions as a list of maps
      var questions = List<Map<String, dynamic>>.empty(growable: true);
      for (var q in items.docs) {
        var que = q.data();
        que['audioId'] = q.id;
        questions.add(que);
      }
      
      // convert to a map object
      var categoryData = {
        'category_name': category.get('category_name'),
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
    print('categories cache cleared');
  }

  void update() {
    notifyListeners();
  }
}

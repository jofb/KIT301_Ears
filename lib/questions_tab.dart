import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:kit301_ears/audio_procesing/language.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'category.dart';

final player = AudioPlayer();

class QuestionsTab extends StatefulWidget {
  const QuestionsTab({super.key});

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab> {
  List<Category> _categoryList = [];

  Future initCategories() async {
    final dir = await getApplicationDocumentsDirectory();
    List<Category> tempCategoryList = [];

    await for (var file in dir.list()) {
      if (file is File && file.path.endsWith(".json")) {
        final json = await file.readAsString();
        print(json);
        final category = Category.fromJson(jsonDecode(json));
        tempCategoryList.add(category);
      }
    }

    setState(() {
      _categoryList = tempCategoryList;
    });
  }

  @override
  void initState() {
    super.initState();
    CategoriesModel().addListener(() {
      initCategories(); 
      setState(() {});
    });
  }

  int _selectedCategoryIndex = 0;
  int _selectedItemIndex = -1;

  @override
  void dispose() async{
    await player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categoryList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blueGrey,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.zero,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final isLastItem = index == _categoryList.length - 1;
                    return Container(
                      margin: EdgeInsets.fromLTRB(8, 8, 8, isLastItem ? 8 : 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        tileColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(
                          _categoryList[index].categoryName,
                          style: TextStyle(
                              color: index == _selectedCategoryIndex
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        selected: index == _selectedCategoryIndex,
                        selectedTileColor: Colors.redAccent[100],
                        trailing: index == _selectedCategoryIndex
                            ? Icon(Icons.arrow_forward_ios_rounded,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                            _selectedItemIndex = -1;
                          });
                        },
                      ),
                    );
                  },
                  itemCount: _categoryList.length,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      List<Question> categoryItems =
                          _categoryList[_selectedCategoryIndex].questions;
                      final isLastItem = index == categoryItems.length - 1;
                      return Container(
                        margin:
                            EdgeInsets.fromLTRB(8, 8, 8, isLastItem ? 8 : 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          tileColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(
                            categoryItems[index].short,
                            style: TextStyle(
                                color: index == _selectedItemIndex
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          selected: index == _selectedItemIndex,
                          selectedTileColor: Colors.redAccent[100],
                          onTap: () async{
                            print("This is the player id of button clicked: ${player.playerId}");
                            //await player.setSource(AssetSource("audio/filtered_audio.wav"));
                            //await player.resume();
                            await player.play(AssetSource("audio/00${categoryItems[index].id}.mp3"));
                          },
                          onLongPress: () {
                            setState(() {
                              _selectedItemIndex = index;
                            });
                            showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.75),
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: WillPopScope(
                                    onWillPop: () async {
                                      setState(() {
                                        _selectedItemIndex = -1;
                                      });
                                      return true;
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.7, //Gets dimension of the screen * 70%
                                        height: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.7, //Gets dimension of the screen * 70%
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(
                                            30.0, 25.0, 30.0, 25.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              categoryItems[index].short,
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20.0),
                                            Text(
                                              categoryItems[index].full,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            Text(
                                              categoryItems[index].audioId,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 20.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedItemIndex = -1;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 30.0,
                                                      horizontal: 60.0,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                  ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 5), () {
                                                      setState(() {
                                                        _selectedItemIndex = -1;
                                                      });
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 30.0,
                                                            horizontal: 60.0,
                                                          ),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          backgroundColor:
                                                              Colors.green),
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                    itemCount:
                        _categoryList[_selectedCategoryIndex].questions.length,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}

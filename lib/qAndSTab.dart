import 'package:flutter/material.dart';

class QuestionsTab extends StatefulWidget {
  const QuestionsTab({super.key});

  @override
  State<QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<QuestionsTab> {
  final List<String> _Categories = [
    "Category 1",
    "Category 2",
    "Category 3"
  ];

  final List<String> _CategoryOneItems = [
    "Category 1 Item 1",
    "Category 1 Item 2",
    "Category 1 Item 3",
    "Category 1 Item 4",
    "Category 1 Item 5"
  ];

  final List<String> _CategoryTwoItems = [
    "Category 2 Item 1",
    "Category 2 Item 2",
    "Category 2 Item 3",
    "Category 2 Item 4",
    "Category 2 Item 5"
  ];

  final List<String> _CategoryThreeItems = [
    "Category 3 Item 1",
    "Category 3 Item 2",
    "Category 3 Item 3",
    "Category 3 Item 4",
    "Category 3 Item 5"
  ];

  int _selectedIndex = 0;
  int _selectedItemIndex = 0;  
  

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final isLastItem = index == _Categories.length - 1;
                  return Container(
                    margin: EdgeInsets.fromLTRB(8, 8, 8, isLastItem ? 8 : 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 2
                        ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        tileColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.5),
                        ),
                        title: Text(
                          _Categories[index],
                          style: TextStyle(
                            color: index == _selectedIndex ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                        selected: index == _selectedIndex,
                        selectedTileColor: Colors.redAccent[100],
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                            _selectedItemIndex = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
                itemCount: _Categories.length,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2
                  ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  List<String> _CategoryItems = []; {
                    switch (_selectedIndex) {
                      case 0:
                        _CategoryItems = _CategoryOneItems;
                        break;
                      case 1:
                        _CategoryItems = _CategoryTwoItems;
                        break;
                      case 2:
                        _CategoryItems = _CategoryThreeItems;
                        break;
                    }
                    final isLastItem = index == _CategoryItems.length - 1;
                    return Container(
                      margin: EdgeInsets.fromLTRB(8, 8, 8, isLastItem ? 8 : 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2
                          ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: ListTile(
                          tileColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.5),
                          ),
                          title: Text(
                            _CategoryItems[index],
                            style: TextStyle(
                              color: index == _selectedItemIndex ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                            ),
                          selected: index == _selectedItemIndex,
                          selectedTileColor: Colors.redAccent[100],
                          onTap: () {
                            setState(() {
                              _selectedItemIndex = index;
                            });
                          },
                        ),
                      ),
                    );
                  }
                },
                itemCount: _CategoryOneItems.length,               
              )
            ),
          ),
        ),
      ],
    );
  }
}
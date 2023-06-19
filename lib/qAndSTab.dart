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
    "Category 3",
    "Category 4",
    "Category 5"
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
            padding: const EdgeInsets.all(8.0),
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
                        title: Text(_Categories[index]),
                      ),
                    ),
                  );
                },
                itemCount: _Categories.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
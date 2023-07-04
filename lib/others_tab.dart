import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'category.dart';

class OthersTab extends StatefulWidget {
  const OthersTab({super.key});

  @override
  State<OthersTab> createState() => _OthersTabState();
}

class _OthersTabState extends State<OthersTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesModel>(builder: buildTab);
  }

  Widget buildTab(BuildContext context, CategoriesModel model, _) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, //ttest
      children: <Widget>[
        Text("Others Page"),
        ElevatedButton(
          onPressed: () => {model.loadCollection()},
          child: Text("Update Question Files"),
        ),
        ElevatedButton(
          onPressed: () => {model.clearCollection()},
          child: Text("Clear Question Files"),
        ),
      ],
    );
  }
}

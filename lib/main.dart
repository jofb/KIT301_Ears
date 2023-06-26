import 'package:flutter/material.dart';
import 'package:kit301_ears/invitation_tab.dart';
import 'package:kit301_ears/questions_tab.dart';
import 'package:kit301_ears/others_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'EARS Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 32,
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          bottom: TabBar( //hit the little arrow on this line, hide all this garbage styling
            labelColor: Colors.blueGrey,
            unselectedLabelColor: Theme.of(context).scaffoldBackgroundColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)
              ),
              color: Theme.of(context).scaffoldBackgroundColor
              ),
            tabs: const [
              SizedBox(
                height: 60,
                child: Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Others",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ),
              ),
              SizedBox(
                height: 60,
                child: Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Questions and Statements",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ),
              ),
              SizedBox(
                height: 60,
                child: Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Invitation to Speak",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ),
              ),
              ]
          ),
        ),
        body: const TabBarView(
          children: [
            OthersTab(),
            QuestionsTab(),
            InvitationTab(),
          ],
        ),
      ),
    );
  }
}

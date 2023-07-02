import 'package:flutter/material.dart';
import 'package:kit301_ears/invitation_tab.dart';
import 'package:kit301_ears/questions_tab.dart';
import 'package:kit301_ears/others_tab.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoriesModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'EARS Project'),
      ),
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
      // initialIndex: 2, // change default tab to inv to speak
      length: 3,
      child: Scaffold(
        drawer: BurgerMenu(), // custom widget
        appBar: AppBar(
          toolbarHeight: 32,
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
                80), // (toby) this sets the distance between the BurgerMenu and TabBar
            child: TabBar(
                //hit the little arrow on this line, hide all this garbage styling
                labelColor: Colors.blueGrey,
                unselectedLabelColor: Theme.of(context).scaffoldBackgroundColor,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Theme.of(context).scaffoldBackgroundColor),
                tabs: const [
                  NavigationTab(text: "Others"),
                  NavigationTab(text: "Questions and Statements"),
                  NavigationTab(text: "Invitation to Speak"),
                ]),
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

// custom navigation tab for tab menu
class NavigationTab extends StatelessWidget {
  const NavigationTab({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class BurgerMenu extends StatelessWidget {
  const BurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 90,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(''),
            ),
          ),
          ListTile(
            title: const Text('Override Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Bring up language override menu
            },
          ),
          ListTile(
            title: const Text('View Manual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Open Manual PDF
            },
          ),
          ListTile(
            title: const Text('View Answer History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to answer history page
            },
          ),
        ],
      ),
    );
  }
}

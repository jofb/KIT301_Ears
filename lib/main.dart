import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'category.dart';
import 'others_tab.dart';
import 'invitation_tab.dart';
import 'questions_tab.dart';
import 'audio_procesing/language.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoriesModel()),
        ChangeNotifierProvider(create: (context) => LanguageModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 32,
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: TabBar(
                    labelColor: Colors.blueGrey,
                    unselectedLabelColor:
                        Theme.of(context).scaffoldBackgroundColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    tabs: const [
                      NavigationTab(text: "Others"),
                      NavigationTab(text: "Questions and Statements"),
                      NavigationTab(text: "Invitation to Speak"),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  onPressed: () {
                    _openDrawer();
                  },
                ),
              ],
            ),
          ),
        ),
        drawer: const BurgerMenu(),
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
    return Consumer<LanguageModel>(builder: buildMenu);
  }

  Widget buildMenu(context, LanguageModel language, _) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 70,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
                child: Text(
                  'EARS Project',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                )),
          ),
          ListTile(
            title: const Text('Change Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Bring up language override menu
              showDialog(
                  context: context,
                  builder: (_) {
                    return LanguageDialog(language: language);
                  });
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

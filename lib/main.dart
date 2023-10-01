import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kit301_ears/providers/audo_downloader.dart';
import 'utils/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/themes.dart';
import 'widgets/pdf_viewer.dart';
import 'settings_screen.dart';
import 'providers/category.dart';
import 'answers_tab.dart';
import 'invitation_tab.dart';
import 'questions_tab.dart';
import 'providers/answers.dart';
import 'providers/language.dart';
import 'utils/log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  logger.i('Connect to Firebase App ${app.options.projectId}');
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
        ChangeNotifierProvider(create: (context) => AnswersModel()),
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => AudioDownloader()),
      ],
      child: const MyHomePage(title: 'EARS Project'),
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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  void initState() {
    // init default user preferences
    final userPrefsFuture = SharedPreferences.getInstance();
    userPrefsFuture.then((userPrefs) {
      if (!userPrefs.containsKey('questionsNav')) {
        userPrefs.setBool('questionsNav', true);
      }
      if (!userPrefs.containsKey('colourTheme')) {
        userPrefs.setInt('colourTheme', 1);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: buildScaffold);
  }

  Widget buildScaffold(BuildContext context, ThemeModel themeModel, _) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: themeModel.currentTheme,
      home: DefaultTabController(
        initialIndex: 2,
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 32,
            backgroundColor: themeModel.currentTheme.primaryColor,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: TabBar(
                      labelColor: themeModel.currentTheme.primaryColor,
                      unselectedLabelColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        color: themeModel.currentTheme.scaffoldBackgroundColor,
                      ),
                      tabs: const [
                        NavigationTab(text: "Answers History"),
                        NavigationTab(text: "Questions and Statements"),
                        NavigationTab(text: "Invitation to Speak"),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    color: themeModel.currentTheme.scaffoldBackgroundColor,
                    onPressed: () {
                      _openDrawer();
                    },
                  ),
                ],
              ),
            ),
          ),
          drawer: ScaffoldMessenger(
            child: BurgerMenu(
              scaffoldMessengerKey: _scaffoldMessengerKey,
            ),
          ),
          body: TabBarView(
            children: [
              const AnswersTab(),
              const QuestionsTab(),
              InvitationTab(
                scaffoldMessengerKey: _scaffoldMessengerKey,
              ),
            ],
          ),
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
  const BurgerMenu({super.key, required this.scaffoldMessengerKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageModel, AnswersModel>(builder: buildMenu);
  }

  Widget buildMenu(
      context, LanguageModel language, AnswersModel answersModel, _) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 94,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
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
                    return LanguageDialog(
                      language: language,
                      onFinished: () {
                        answersModel.newHistory(language.toString());
                      },
                    );
                  });
            },
            leading: const Icon(Icons.spellcheck_sharp),
          ),
          ListTile(
            title: const Text('User Manual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Open Manual PDF
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PDFViewerFromAsset(
                  title: 'User Manual',
                  pdfAssetPath: 'assets/pdf/user_manual.pdf',
                );
              }));
            },
            leading: const Icon(Icons.book),
          ),
          ListTile(
            title: const Text('Technical Manual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Open Manual PDF
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PDFViewerFromAsset(
                  title: 'Technical Manual',
                  pdfAssetPath: 'assets/pdf/technical_manual.pdf',
                );
              }));
            },
            leading: const Icon(Icons.book),
          ),
          ListTile(
            title: const Text('Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to answer history page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsWidget(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                  ),
                ),
              );
            },
            leading: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}






/*    Developed at UTAS by the EARS team, for the State Emergency Services, 2023.

      - Brayden Ransom-Frost
      - Leo Headley
      - Jordan Wylde-Browne
      - Theodore Ing Ting Tiong
      - Thomas Ambrose
      - Toby Coy

                                  ...                                      ..^^~~~~^:
            :7?????7!~~!!777?7!?P5J!^:     :                           .^7?7~:...:^~!7?~
          ^PY^.     .::.    !JJJ~        .Y5J?.                    .^7?7^.  .^!7!!~^:.:::
          G5             .^5!.    ^!75U53J!  ~G:        .~7??7777?7!^.    !55!:.      .^!777!777~.
          ?G~        .Y?!!^    .JJ^..        .G~      :YJ~.               ..^~J0RD4N!!^:........^??.
          :G5J?!^:..^P5    .:^?Y^7J?!.       7P      :G~   ^!777!.   .7!^.            .!???7777!!!YP:
          ~B^  .!G5!!^    :B7:.   .           P~     YJ  .57.  .YG   Y5:^!7?7!^^::^!??!:            .
          !B?:. ~B^        ~5.               ^G~:    5?  ^B.   :YY!!Y?       .::^::.
        .PI3K4R7~.        .!P?~^~~.      :7YG5JJP.  ~G:  !Y~.    .         ....::^^~~!!!!7YJ!7Y?!!!~.
      .Y7!:    ~G5!      .!!7PGJ77^      ....   7G.  ^57.  ^!2L!N35!!!!!!~~^^::....     .^  :~. ~P5^
      ^G^      ?Y.YY        ^G~.::.              ?P    ^??!:..............::^^~~!!!!77777!!!^.  ^G7
        Y5:   ..YJ 7P        .JY!~JG?         ^!!^:P7      .:^~!!!!!!~~~~^^::....           .~YY. .5^
        Y5:   ^G!  PY           .?Y^            .~YGP                                          ?G. ^5
        ^GP??YG:  ^57.        !P~          ..     ?G^...::::^~!7????????7~:                   !G. :P
        .GJ  JGP~   :!7!^.  .5J            .^?7.  ^G7!!!~~~~^^:..      ..~?YY7~^::.......::^!??. .5~
        :G7  PY.5?     .:!7?P?         :^.    ^P! YY                        .7GG~~~~~~~~^^^::::^7?:
        ^B~ :B!  J5...      .           .7J.   .PYP.                          :PY~~~~~!!!!!!!~^.
        ~B^ ?G.   ~PP.            .?      ^G^   5P:                            ^G?..         .
        ~B: P5     .JY!7   :7     .G.      !G.^5?          ~7                   :TH0M45??JJ?5Y                             
        !G..B!       ^PY. ~PG!     !P:     .GPJ.      7JJ??YP5:                     ......    P7
        !G.7G.         ~5JG:.5J.    ^5J^ .!Y7.      ~5?GJ    ^5Y^                         .^~^?G.
        !G~G?            ~~   ~Y7.   .TH30~     .:7Y?..G^      :LE0!:                        :?G^
        .5PJ                   ~G5J7J?!:   ^!!?J?7:    PJ         .!GPJ?7!^::.....:^~!~   .::. P~
              :~!!!!:        .!Y?: ..       .P?         .PJ          55  .::^~~!!!!!~:~G7    .!JG~
            .^G?..:J5:   :!YJ~        ^7.   Y5           J5:        :PJ:              :G!     :G.
              !P~    JG?JJ?^.      !~   .G7757.            ^PJ         ^7??5J           ^G:    ?5
            YP.      :.            ?5:^?5?^                 Y5      .    !G^            5J   :G^
            !GP:            ^57~~~!7J5J!:                    .B~     .7?.7G^            ^P7   :JJ.
            ..~YYY^   :G?   .G?.::..                         .G^  ^~   YBY.          :?Y7:      !P.
                JG. .7P~7???7^                               ?G.   ~P~?5^           JY:         ^G:
                :GPYY!                       .:^^^:..       ?G^    :G5~            .B~ .^   .5T0BY~.
                ::                        !5J~^^~!7JY?^ .!5?.   .YJ:               !GJ!P?^!5?
                                          ?GP7:.      .75J~.     :B^                 :! .YP:
                                          7. YG!            .!YJ.JG.                      .
                                            ~G?     .     ~Y?^.YBY.
                                            !BR4YD3N~    .G~   ~:
                                            ~..^^:YG!.^7P!
                                                    7GG!^.
                                                      ~
*/
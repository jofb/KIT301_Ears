import 'package:flutter/material.dart';
import 'package:kit301_ears/invitation_tab.dart';
import 'package:kit301_ears/questions_tab.dart';
import 'package:kit301_ears/others_tab.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      .Y7!:    ~G5!      .!!7PGJ77^      ....   7G.  ^57.  ^!77!!!!!!!!!!!~~^^::....     .^  :~. ~P5^
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

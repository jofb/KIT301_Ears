import 'package:flutter/material.dart';

class InvitationTab extends StatefulWidget {
  const InvitationTab({super.key});

  @override
  State<InvitationTab> createState() => _InvitationTabState();
}

class _InvitationTabState extends State<InvitationTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Text("Invitation to Speak Page")
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/session.dart';

class SessionCheckList extends StatefulWidget {
  late List<Session> sessions;
  final Function(String?) onSelectionChanges;
  late String? lastSavedSession;
  SessionCheckList({required this.sessions, required this.onSelectionChanges, required this.lastSavedSession});
  @override
  _SessionCheckListState createState() => _SessionCheckListState();
}

class _SessionCheckListState extends State<SessionCheckList> {

  @override
  void initState() {
    super.initState();
    widget.sessions.sort((a, b) => a.sessionStartTime.compareTo(b.sessionStartTime));
    for(int i=0; i<widget.sessions.length;i++){
      if(widget.sessions[i].sessionID==widget.lastSavedSession){
        _selectedIndex = i;
      }
    }
  }
  int? _selectedIndex;

  bool isValidSession(Session s){
    DateTime now = DateTime.now();
    return s.sessionEndTime.isAfter(now);
  }
  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.sessions.length,
        itemBuilder: (context, index) {
          final session = widget.sessions[index];
          final date = DateFormat("MMM dd, yyyy").format(session.sessionStartTime);
          final startTime = "${session.sessionStartTime.hour > 12 ? (session.sessionStartTime.hour - 12) : session.sessionStartTime.hour}:${session.sessionStartTime.minute.toString().padLeft(2, '0')} ${session.sessionStartTime.hour >= 12 ? 'PM' : 'AM'}";
          final endTime = "${session.sessionEndTime.hour > 12 ? (session.sessionEndTime.hour - 12) : session.sessionEndTime.hour}:${session.sessionEndTime.minute.toString().padLeft(2, '0')} ${session.sessionEndTime.hour >= 12 ? 'PM' : 'AM'}";
          return Column(
            children: [
              CheckboxListTile(
                title: Text(date),
                subtitle: Text("$startTime - $endTime"),
                value: _selectedIndex == index,
                onChanged:
                    isValidSession(session)
                    ?
                        (bool? value) {
                  setState(() {
                    _selectedIndex = value == true ? index : null;
                    print("selected is $_selectedIndex");
                    widget.onSelectionChanges(_selectedIndex == null? null:session.sessionID);
                  });
                }
                    : null,
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Theme.of(context).primaryColor,
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ],
          );
        },
      );
  }
}

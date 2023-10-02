import 'package:flutter/material.dart';
import 'package:ivychat/pages/chat_page.dart';
import 'package:ivychat/widgets/widgets.dart';

class enclaveTile extends StatefulWidget {
  final String userName;
  final String enclaveId;
  final String enclaveName;
  const enclaveTile(
      {Key? key,
      required this.enclaveId,
      required this.enclaveName,
      required this.userName})
      : super(key: key);

  @override
  State<enclaveTile> createState() => _enclaveTileState();
}

class _enclaveTileState extends State<enclaveTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              enclaveId: widget.enclaveId,
              enclaveName: widget.enclaveName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.enclaveName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.enclaveName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Join the conversation as ${widget.userName}",
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}

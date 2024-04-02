import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_taker/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FireStoreService fireStoreService = FireStoreService();
  //text controller
  final TextEditingController textController = TextEditingController();
  //open a dialog box to add a note
  void openNoteBox({String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                //button to save
                ElevatedButton(
                    onPressed: () {
                      //add a new note
                      if (docId == null) {
                        fireStoreService.addNote(textController.text);
                        Navigator.pop(context);
                        textController.clear();
                      } else {
                        //update an existing note
                        fireStoreService.updateNote(docId,textController.text);
                        Navigator.pop(context);
                      }
                    },
                    child: docId==null?Text("Add"):Text("Update"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text("Notes"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getNotesStream(),
        builder: (context, snapshot) {
          //if we have data,get all the docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            //display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each individual doc
                DocumentSnapshot document = notesList[index];
                String docId = document.id;
                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                //display as a list tile
                return Padding(
                  padding: const EdgeInsets.all(25),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                      
                    ),
                    tileColor: Colors.white,
                  contentPadding: const EdgeInsets.all(25),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(onTap: () => openNoteBox(docId: docId),child: const Icon(Icons.settings)),
                        GestureDetector(onTap: () => fireStoreService.deleteNote(docId),child: const Icon(Icons.delete)),
                      ],
                    ),
                    title: Text(
                      noteText,
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ),
                );
              },
            );
            //if there is no data
          } else {
            return const Center(child: Text("You haven't add any notes yet"));
          }
        },
      ),
    );
  }
}

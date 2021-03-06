import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:saborissimo/data/model/Memory.dart';
import 'package:saborissimo/data/service/MemoriesDataService.dart';
import 'package:saborissimo/res/names.dart';
import 'package:saborissimo/res/palette.dart';
import 'package:saborissimo/res/styles.dart';
import 'package:saborissimo/ui/drawer/drawer_app.dart';
import 'package:saborissimo/ui/memories/add_memory.dart';
import 'package:saborissimo/utils/PreferencesUtils.dart';
import 'package:saborissimo/utils/utils.dart';
import 'package:saborissimo/widgets/material_dialog_yes_no.dart';

class Memories extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _MemoriesState createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  MemoriesDataService _service;
  List<Memory> _memories;
  bool _logged = false;

  @override
  void initState() {
    PreferencesUtils.getPreferences()
        .then(
          (preferences) => {
            if (preferences.getBool(PreferencesUtils.LOGGED_KEY) ?? false)
              setState(() => _logged = true)
            else
              _logged = false
          },
        )
        .then((_) => refreshList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title: Text(Names.memoriesAppBar, style: Styles.title(Colors.white)),
        backgroundColor: Palette.primary,
        actions: [createRefreshButton()],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        backgroundColor: Palette.accent,
        onPressed: () =>
            Utils.pushRoute(context, AddMemory()).then((_) => refreshList()),
      ),
      drawer: DrawerApp(),
      body: createList(),
    );
  }

  void refreshList() {
    _service = MemoriesDataService('');
    _service.get().then(
        (response) => setState(() => _memories = response.reversed.toList()));
  }

  void attemptToDelete(String token, Memory memory) {
    String child = Utils.getFirebaseName(memory.picture);
    MemoriesDataService service = MemoriesDataService(token);

    service
        .delete(memory.id.toString())
        .then(
          (success) => {
            if (success)
              {
                refreshList(),
                Firebase.initializeApp().then(
                    (_) => FirebaseStorage.instance.ref().child(child).delete())
              }
            else
              Utils.showSnack(
                widget._scaffoldKey,
                'Error, inicie sesión e intente de nuevo',
              )
          },
        )
        .catchError(
          (_) => Utils.showSnack(
            widget._scaffoldKey,
            'Error, inicie sesión e intente de nuevo',
          ),
        );
  }

  void deleteMemory(Memory memory) {
    String token = '';

    PreferencesUtils.getPreferences().then(
      (preferences) => {
        if (preferences.getBool(PreferencesUtils.LOGGED_KEY) ?? false)
          {
            token = preferences.getString(PreferencesUtils.TOKEN_KEY),
            attemptToDelete(token, memory),
          }
      },
    );
  }

  void showPictureDialog(Memory memory) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(
          memory.title,
          textAlign: TextAlign.center,
          style: Styles.title(Colors.black),
        ),
        content: Row(
          children: [
            Expanded(
              child: Image.network(
                memory.picture,
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDialog(Memory memory) {
    if (_logged) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => MaterialDialogYesNo(
          title: 'Eliminar recuerdo',
          body:
              'Esta acción eliminará el recuerdo ${memory.title} para siempre.',
          positiveActionLabel: 'Eliminar',
          positiveAction: () => {deleteMemory(memory), Navigator.pop(context)},
          negativeActionLabel: "Cancelar",
          negativeAction: () => Navigator.pop(context),
        ),
      );
    }
  }

  Widget createRefreshButton() {
    return IconButton(
      icon: Icon(Icons.refresh),
      tooltip: 'Refrescar',
      onPressed: () => refreshList(),
    );
  }

  Widget createList() {
    if (_memories == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Palette.accent),
        ),
      );
    }

    if (_memories.isEmpty) {
      return Center(
        child: Utils.createNoItemsMessage(
          'No se han publicado nuevos recuerdos',
        ),
      );
    }

    return ListView.builder(
      itemBuilder: (_, index) => createPictureCard(_memories[index]),
      itemCount: _memories.length,
    );
  }

  Widget createPictureCard(Memory memory) {
    return InkWell(
      onTap: () => showPictureDialog(memory),
      onLongPress: () => showDeleteDialog(memory),
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  memory.picture,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                memory.title,
                textAlign: TextAlign.center,
                style: Styles.legend(25),
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

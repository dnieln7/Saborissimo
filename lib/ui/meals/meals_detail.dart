import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:saborissimo/data/model/Meal.dart';
import 'package:saborissimo/data/service/MealsDataService.dart';
import 'package:saborissimo/res/palette.dart';
import 'package:saborissimo/res/styles.dart';
import 'package:saborissimo/utils/PreferencesUtils.dart';
import 'package:saborissimo/utils/utils.dart';
import 'package:saborissimo/widgets/material_dialog_yes_no.dart';

class MealsDetail extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Meal meal;

  MealsDetail(this.meal);

  @override
  _MealsDetailState createState() => _MealsDetailState();
}

class _MealsDetailState extends State<MealsDetail> {
  bool _logged = false;
  bool _working;

  @override
  void initState() {
    _working = false;

    PreferencesUtils.getPreferences().then(
      (preferences) => {
        if (preferences.getBool(PreferencesUtils.LOGGED_KEY) ?? false)
          setState(() => _logged = true)
        else
          _logged = false
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title: Text(widget.meal.name, style: Styles.title(Colors.white)),
        backgroundColor: Palette.primary,
      ),
      floatingActionButton: createFAB(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.meal.picture,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                widget.meal.description,
                textAlign: TextAlign.justify,
                style: Styles.body(Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void attemptToDelete(String token) {
    String child = Utils.getFirebaseName(widget.meal.picture);
    MealsDataService service = MealsDataService(token);

    service
        .delete(widget.meal.id.toString())
        .then(
          (success) => {
            if (success)
              {
                Firebase.initializeApp().then(
                  (_) => FirebaseStorage.instance.ref().child(child).delete(),
                ),
                Navigator.pop(context),
              }
            else
              {
                Utils.showSnack(
                  widget._scaffoldKey,
                  'Error, inicie sesión e intente de nuevo',
                ),
                setState(() => _working = true),
              }
          },
        )
        .catchError((_) => {
              Utils.showSnack(
                widget._scaffoldKey,
                'Error, inicie sesión e intente de nuevo',
              ),
              setState(() => _working = true),
            });
  }

  void deleteMeal() {
    String token = '';
    setState(() => _working = true);
    PreferencesUtils.getPreferences().then(
      (preferences) => {
        if (preferences.getBool(PreferencesUtils.LOGGED_KEY) ?? false)
          {
            token = preferences.getString(PreferencesUtils.TOKEN_KEY),
            attemptToDelete(token),
          }
      },
    );
  }

  Widget createFAB() {
    if (_working) {
      return Container();
    }

    return FloatingActionButton(
      backgroundColor: Palette.accent,
      child: Icon(Icons.delete),
      onPressed: () => showDialog(
        context: context,
        builder: (_) => MaterialDialogYesNo(
          title: 'Eliminar platillo',
          body:
              'Esta acción eliminará el platillo ${this.widget.meal.name} para siempre.',
          positiveActionLabel: 'Eliminar',
          positiveAction: () => {deleteMeal(), Navigator.pop(context)},
          negativeActionLabel: "Cancelar",
          negativeAction: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

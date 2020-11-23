import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saborissimo/data/model/Meal.dart';
import 'package:saborissimo/data/service/MealDataService.dart';
import 'package:saborissimo/res/names.dart';
import 'package:saborissimo/res/palette.dart';
import 'package:saborissimo/res/styles.dart';
import 'package:saborissimo/utils/utils.dart';

class CreateMeal extends StatefulWidget {
  final _key = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _CreateMealState createState() => _CreateMealState();
}

class _CreateMealState extends State<CreateMeal> {
  MealDataService _service = MealDataService();

  File _selectedPicture;

  String _name;
  String _description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title: Text(Names.createMealAppBar, style: Styles.title(Colors.white)),
        backgroundColor: Palette.primary,
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Palette.accent,
          child: Icon(Icons.save),
          onPressed: _validateForm),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: widget._key,
            child: Column(
              children: [
                InkWell(
                  onTap: () => _showPicker(context),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Palette.primaryLight,
                    child: createPicture(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: Utils.createHint('Nombre *'),
                  style: Styles.body(Colors.black),
                  onChanged: (value) => setState(() => _name = value),
                  validator: (text) => _getErrorMessage(text.isEmpty),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: Utils.createHint('Descripción *'),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 20,
                  style: Styles.body(Colors.black),
                  onChanged: (value) => setState(() => _description = value),
                  validator: (text) => _getErrorMessage(text.isEmpty),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  child: Text(
                    '* Campos obligatorios',
                    style: Styles.body(Colors.black54),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectFromCamera() async {
    File file = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _selectedPicture = file;
    });
  }

  void _selectFromGallery() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedPicture = file;
    });
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library, color: Palette.primary),
              title: Text(
                'Seleccionar de la galeria',
                style: Styles.body(Colors.black),
              ),
              onTap: () => {_selectFromGallery(), Navigator.of(context).pop()},
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: Palette.primary),
              title: Text(
                'Tomar una foto ahora',
                style: Styles.body(Colors.black),
              ),
              onTap: () => {_selectFromCamera(), Navigator.of(context).pop()},
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(bool empty) {
    if (empty) {
      return 'Este campo no puede estar vacío';
    }
    return null;
  }

  void _validateForm() {
    if (widget._key.currentState.validate()) {
      if (_selectedPicture == null) {
        Utils.showSnack(widget._scaffoldKey, 'Debe seleccionar una imagen');
      } else {

        final Meal meal = Meal(0, _name, _description, uploadToFirebase());
        _service.saveMeal(meal).then((value) => Navigator.pop(context));
      }
    }
  }

  String uploadToFirebase() {
    return _selectedPicture.path;
  }

  Widget createPicture() {
    if (_selectedPicture != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.file(
          _selectedPicture,
          width: 190,
          height: 190,
          fit: BoxFit.fill,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Palette.primaryMedium,
        borderRadius: BorderRadius.circular(100),
      ),
      width: 190,
      height: 190,
      child: Icon(
        Icons.add_a_photo,
        color: Colors.white,
        size: 100,
      ),
    );
  }
}

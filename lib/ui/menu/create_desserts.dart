import 'package:flutter/material.dart';
import 'package:saborissimo/data/model/Meal.dart';
import 'package:saborissimo/data/service/MealsDataService.dart';
import 'package:saborissimo/res/names.dart';
import 'package:saborissimo/res/palette.dart';
import 'package:saborissimo/res/styles.dart';
import 'package:saborissimo/utils/PreferencesUtils.dart';
import 'package:saborissimo/utils/utils.dart';

import 'create_drinks.dart';

class CreateDesserts extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Meal> entrances;
  final List<Meal> middles;
  final List<Meal> stews;

  CreateDesserts(this.entrances, this.middles, this.stews);

  @override
  _CreateDessertsState createState() => _CreateDessertsState();
}

class _CreateDessertsState extends State<CreateDesserts> {
  String _token;
  MealsDataService _service;
  List<Meal> _meals = [];
  Map<Meal, bool> _selected = {};

  @override
  void initState() {
    PreferencesUtils.getPreferences()
        .then((preferences) => {
              if (preferences.getString(PreferencesUtils.TOKEN_KEY) != null)
                _token = preferences.getString(PreferencesUtils.TOKEN_KEY)
              else
                _token = 'N/A'
            })
        .then((_) => refreshList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      appBar: AppBar(
        title:
            Text(Names.createDessertsAppBar, style: Styles.title(Colors.white)),
        backgroundColor: Palette.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        mini: true,
        backgroundColor: Palette.accent,
        onPressed: () => attemptToGoNext(),
      ),
      body: createList(),
    );
  }

  void refreshList() {
    _service = MealsDataService(_token);
    _service.get().then((response) => setState(() => _meals = response));
  }

  void attemptToGoNext() {
    final List<Meal> selectedMeals = [];

    _selected.forEach((key, value) => {
          if (value) {selectedMeals.add(key)}
        });

    if (selectedMeals.isNotEmpty) {
      if (selectedMeals.length <= 3) {
        Utils.pushRoute(
          context,
          CreateDrinks(
            widget.entrances,
            widget.middles,
            widget.stews,
            selectedMeals,
          ),
        );
      } else {
        Utils.showSnack(
            widget._scaffoldKey, "Solo puede agregar un máximo de 3 platillos");
      }
    } else {
      Utils.showSnack(
          widget._scaffoldKey, "Debe agregar por lo menos 1 platillo");
    }
  }

  Widget createList() {
    if (_meals.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Palette.accent),
        ),
      );
    }

    List<Meal> shortedMeals =
        _meals.where((meal) => meal.type == 'postre').toList();

    return ListView.builder(
      itemBuilder: (context, index) => createListTile(shortedMeals[index]),
      itemCount: shortedMeals.length,
    );
  }

  Widget createListTile(Meal meal) {
    _selected.putIfAbsent(meal, () => false);

    return CheckboxListTile(
      contentPadding: EdgeInsets.all(10),
      title: Text(meal.name, style: Styles.subTitle(Colors.black)),
      secondary: Utils.createThumbnail(meal.picture),
      activeColor: Palette.done,
      value: _selected[meal],
      onChanged: (value) =>
          setState(() => _selected.update(meal, (old) => !old)),
    );
  }
}

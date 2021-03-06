import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:seasoncalendar/components/loading_scaffold.dart';

import 'package:seasoncalendar/models/food.dart';
import 'package:seasoncalendar/models/food_display_configuration.dart';
import 'package:seasoncalendar/components/food_tile.dart';
import 'package:seasoncalendar/l10n/app_localizations.dart';
import 'package:seasoncalendar/helpers/db_provider.dart';

class FoodView extends StatelessWidget {
  List<Food> _selectedFoods;
  final int _monthIndex;
  final String _viewContext;

  FoodView(FoodDisplayConfiguration fdc)
      : _selectedFoods = fdc.foodsToDisplay,
        _monthIndex = fdc.monthIndex,
        _viewContext = fdc.favoritesSelected ? "fav" : "main";

  FoodView.fromSearchResult(List<Food> searchResultFoods, int monthIndex)
      : _selectedFoods = searchResultFoods,
        _monthIndex = monthIndex,
        _viewContext = "search";

  @override
  Widget build(BuildContext context) {
    if (_selectedFoods.length < 1) {
      return _buildEmpty(context, _viewContext);
    }
    return FutureBuilder(
        future: DBProvider.db.getFoods(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // update food data on every build
            List<Food> _newestFoodCatalog = snapshot.data;
            _selectedFoods = _selectedFoods
                .map((Food f) =>
                    _newestFoodCatalog.firstWhere((Food nf) => nf.id == f.id))
                .toList();

            return GridView.builder(
              itemCount: _selectedFoods.length,
              padding: const EdgeInsets.all(5.0),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
              ),
              itemBuilder: (context, i) {
                return FoodTile(_selectedFoods[i], _monthIndex);
              },
            );
          } else {
            return LoadingWidget();
          }
        });
  }

  Widget _buildEmpty(BuildContext context, String viewContext) {
    IconData emptyIcon = Icons.spa;
    String emptyText = AppLocalizations.of(context).emptyFoodsViewText;
    Widget favAddHint = Container();

    if (viewContext.startsWith("fav")) {
      emptyIcon = Icons.star_border;
      emptyText = AppLocalizations.of(context).emptyFavoritesViewText;
      favAddHint = Text(
        AppLocalizations.of(context).emptyFavoritesViewHint,
        style: const TextStyle(color: Colors.black54),
        textAlign: TextAlign.center,
      );
    } else if (viewContext == "search") {
      emptyIcon = Icons.search;
      emptyText = AppLocalizations.of(context).emptySearchViewText;
    }
    return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 35,
                child: Container(),
              ),
              Expanded(
                flex: 20,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 1,
                      child: new LayoutBuilder(builder: (context, constraint) {
                        var cst =
                            constraint.biggest.width < constraint.biggest.height
                                ? constraint.biggest.width
                                : constraint.biggest.height;
                        return new Icon(
                          emptyIcon,
                          size: cst,
                          color: Colors.black45,
                        );
                      }),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 20,
                  child: Text(
                    emptyText,
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )),
              Expanded(
                  flex: 20,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: favAddHint,
                  )),
              Expanded(
                flex: 2,
                child: Container(),
              ),
            ],
          ),
        ));
  }
}

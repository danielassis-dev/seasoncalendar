import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/json_asset_loader.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> _initialSettings;
  final Map<String, dynamic> _settingsText;
  Map<String, dynamic> _settings;
  String _versionInfo = "...";

  SettingsPage(
      Map<String, dynamic> initialSettings, Map<String, dynamic> settingsText)
      : _initialSettings = initialSettings,
        _settingsText = settingsText;

  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static Future<Map<String, dynamic>> getSettings() async {
    final initialSettings =
        await loadAssetFromJson("assets/initialsettings.json");
    return getSettingsI(initialSettings);
  }

  static Future<Map<String, dynamic>> getSettingsI(
      Map<String, dynamic> initialSettings) async {
    Map<String, dynamic> settings = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();

    initialSettings.keys.forEach((key) {
      settings[key] = prefs.get(key) ?? initialSettings[key];
    });
    return settings;
  }

  setSettingI(String key, dynamic newVal) async {
    widget._settings[key] = newVal;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setValue(prefs, key, newVal);
  }

  setValue(SharedPreferences prefs, String key, dynamic value) {
    setState(() {
      if (value is bool) {
        prefs.setBool(key, value);
      } else if (value is double) {
        prefs.setDouble(key, value);
      } else if (value is int) {
        prefs.setInt(key, value);
      } else if (value is String) {
        prefs.setString(key, value);
      } else if (value is List<String>) {
        prefs.setStringList(key, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget._settingsText['settingsPageTitle'])),
        body: SingleChildScrollView(
            child: FutureBuilder(
                future: Future.wait(
                    [getSettingsI(widget._initialSettings), getVersionInfo()]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> settings = snapshot.data[0];
                    widget._settings = settings;
                    widget._versionInfo = snapshot.data[1];
                  }
                  return _buildSettings(context);
                })));
  }

  Future<String> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version + "+" + packageInfo.buildNumber;
  }

  Widget _buildSettings(BuildContext context) {
    if (widget._settings == null) {
      return Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
          margin: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.folder_special),
                  title: Text(widget._settingsText['settingsUncommonTitle']),
                  subtitle: Text(widget._settingsText['settingsUncommonText']),
                  value: widget._settings["includeUncommon"],
                  dense: false,
                  onChanged: (newVal) {
                    setSettingI("includeUncommon", newVal);
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.sort),
                  title: Text(widget._settingsText['settingsSortingTitle']),
                  value: widget._settings["foodSorting"],
                  dense: false,
                  onChanged: (newVal) {
                    setSettingI("foodSorting", newVal);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text(widget._settingsText['settingsFilterTitle']),
                  isThreeLine: false,
                  dense: false,
                  onTap: () =>
                      Navigator.of(context).pushNamed("/settings/filter"),
                ),
                const Divider(),
                ListTileTheme(
                  selectedColor: Colors.lightGreen[700],
                  child: ListTile(
                    leading: Icon(Icons.account_balance),
                    title: Text(widget._settingsText['imprintPageTitle']),
                    isThreeLine: false,
                    dense: false,
                    selected: true,
                    onTap: () => {Navigator.of(context).pushNamed("/imprint")},
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  enabled: false,
                  title: Text('Version'),
                  trailing: Text(
                    widget._versionInfo,
                    style: const TextStyle(color: Colors.black38),
                  ),
                  isThreeLine: false,
                  dense: false,
                ),
              ],
            ),
          ));
    }
  }
}

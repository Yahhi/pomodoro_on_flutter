//
// Generated file. Do not edit.
//

// ignore: unused_import
import 'dart:ui';

import 'package:audioplayers/audioplayers_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';

void registerPlugins(PluginRegistry registry) {
  AudioplayersPlugin.registerWith(registry.registrarFor(AudioplayersPlugin));
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  SharedPreferencesPlugin.registerWith(
      registry.registrarFor(SharedPreferencesPlugin));
  registry.registerMessageHandler();
}

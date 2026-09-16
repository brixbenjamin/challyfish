import 'dart:io';

import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';

/// A fresh in-memory database, the way almost every test wants one.
///
/// The one line this replaces was duplicated in roughly thirty `setUp` blocks.
FeralDatabase memoryDatabase() => FeralDatabase(NativeDatabase.memory());

/// A database backed by a real file, for the tests that close and reopen it.
///
/// Persistence across a restart cannot be shown in memory: the point of those
/// tests is that the bytes survive the process, not the object.
FeralDatabase fileDatabase(File file) => FeralDatabase(NativeDatabase(file));

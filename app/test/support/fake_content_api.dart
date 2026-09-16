import 'dart:io';

import 'package:feral/src/data/remote/content_api.dart';

/// Serves a fixed row set whole, the way the real API serves it.
///
/// [version] is what the refresh gate reads. A test that changes [rows] and wants
/// the change picked up must move [version] too, exactly as the server does.
class FakeContentApi implements ContentApi {
  FakeContentApi(this.rows, {this.version = 1});

  final Map<String, List<Map<String, dynamic>>> rows;
  int version;

  /// Tables asked for, in order, so a test can assert that a gated refresh asked
  /// for nothing at all.
  final List<String> fetched = [];
  int versionCalls = 0;

  /// Set to make the fetch of one table fail, for the half-finished-refresh case.
  final Map<String, Object> failTable = {};

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    fetched.add(table);
    final failure = failTable[table];
    if (failure != null) throw failure;
    return rows[table] ?? const [];
  }

  @override
  Future<int> fetchVersion() async {
    versionCalls++;
    return version;
  }
}

/// Stands in for a phone in airplane mode: every call fails the way a real one
/// does, rather than quietly returning nothing.
class OfflineContentApi implements ContentApi {
  int attempts = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    attempts++;
    throw const SocketException('offline');
  }

  @override
  Future<int> fetchVersion() async {
    attempts++;
    throw const SocketException('offline');
  }
}

/// A server holding no library at all. A refresh against it is a no-op rather
/// than an error, which is what lets a test boot the app on the bundled snapshot
/// without the network being part of the subject.
class SilentContentApi implements ContentApi {
  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async => const [];

  @override
  Future<int> fetchVersion() async => 0;
}

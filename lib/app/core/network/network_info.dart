abstract class NetworkInfo {
  Future<bool> get isOnline;

  Stream<bool> get onStatusChanged;
}

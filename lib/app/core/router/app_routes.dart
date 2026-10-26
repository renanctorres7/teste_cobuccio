abstract final class AppRoutes {
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const transactionDetail = '/transactions/:id';

  static String transactionDetailPath(String id) => '/transactions/$id';
}

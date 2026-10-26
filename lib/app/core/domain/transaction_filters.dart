import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_entity.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

final class TransactionFilters extends Equatable {
  const TransactionFilters({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.query,
  });

  final TransactionTypeEnum? type;
  final TransactionStatusEnum? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? query;

  bool matches(TransactionEntity transaction) {
    if (type != null && transaction.type != type) {
      return false;
    }
    if (status != null && transaction.status != status) {
      return false;
    }
    final occurredAt = transaction.occurredAt.toUtc();
    if (startDate != null && occurredAt.isBefore(startDate!.toUtc())) {
      return false;
    }
    if (endDate != null && occurredAt.isAfter(endDate!.toUtc())) {
      return false;
    }
    final normalizedQuery = query?.trim().toLowerCase();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      if (!transaction.description.toLowerCase().contains(normalizedQuery)) {
        return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [type, status, startDate, endDate, query];
}

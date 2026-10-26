import 'package:equatable/equatable.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_status_enum.dart';
import 'package:teste_cobuccio/app/core/domain/transaction_type_enum.dart';

final class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.description,
    required this.amount,
    required this.occurredAt,
    required this.type,
    required this.status,
    this.metadata = const {},
  });

  final String id;
  final String description;
  final Money amount;
  final DateTime occurredAt;
  final TransactionTypeEnum type;
  final TransactionStatusEnum status;
  final Map<String, String> metadata;

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        occurredAt,
        type,
        status,
        metadata,
      ];
}

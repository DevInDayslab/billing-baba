import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_result.freezed.dart';
part 'create_order_result.g.dart';

@freezed
abstract class CreateOrderResult with _$CreateOrderResult {
  const factory CreateOrderResult({
  @JsonKey(name: 'paymentUuid') required String paymentUuid,
  @JsonKey(name: 'razorpayOrderId') required String razorpayOrderId,
  @JsonKey(name: 'razorpayKey') required String razorpayKey,
    required int amount,
    required String currency,
    @JsonKey(name: 'businessName') required String businessName,
    @JsonKey(name: 'ownerName') required String ownerName,
    @JsonKey(name: 'businessEmail') required String businessEmail,
    @JsonKey(name: 'businessPhone') required String businessPhone,
  }) = _CreateOrderResult;

  factory CreateOrderResult.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResultFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateOrderResult _$CreateOrderResultFromJson(Map<String, dynamic> json) =>
    _CreateOrderResult(
      paymentUuid: json['paymentUuid'] as String,
      razorpayOrderId: json['razorpayOrderId'] as String,
      razorpayKey: json['razorpayKey'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      businessName: json['businessName'] as String,
      ownerName: json['ownerName'] as String,
      businessEmail: json['businessEmail'] as String,
      businessPhone: json['businessPhone'] as String,
    );

Map<String, dynamic> _$CreateOrderResultToJson(_CreateOrderResult instance) =>
    <String, dynamic>{
      'paymentUuid': instance.paymentUuid,
      'razorpayOrderId': instance.razorpayOrderId,
      'razorpayKey': instance.razorpayKey,
      'amount': instance.amount,
      'currency': instance.currency,
      'businessName': instance.businessName,
      'ownerName': instance.ownerName,
      'businessEmail': instance.businessEmail,
      'businessPhone': instance.businessPhone,
    };

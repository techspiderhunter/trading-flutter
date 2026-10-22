import 'dart:convert';

ApiRequest apiRequestModelFromJson(String str) => ApiRequest.fromJson(json.decode(str));

String apiRequestModelToJson(ApiRequest data) => json.encode(data.toJson());

class ApiRequest {
  ApiRequest({
    this.status,
    this.message,
    this.validationError,
    this.data,
  });

  String? status;
  String? message;
  String? validationError;
  dynamic data;

  factory ApiRequest.fromJson(Map<String, dynamic> json) => ApiRequest(
    status: json["status"] == null ? "error" : json["status"].toString(),
    message: json["message"] == null ? null : json["message"],
    validationError: (() {
      final errors = json['errors'];
      final message = json['message'];

      // Case 1: old format → {"errors": {"field": ["message"]}}
      if (errors != null && errors is Map) {
        return errors[errors.keys.first]?.first.toString();
      }

      // Case 2: new format → {"errors": ["message"]}
      if (errors != null && errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }

      // Case 3: your latest format → "message": [ {line, field, error} ]
      if (message != null && message is List && message.isNotEmpty) {
        // Combine all errors with comma separation
        final msgs = message.map((e) => e['error']).where((m) => m != null).join(', ');
        return msgs.isNotEmpty ? msgs : null;
      }

      return null;
    })(),

    // validationError: (() {
    //   final errors = json['errors'];
    //   if (errors == null) return null;
    //
    //   if (errors is Map) {
    //     // old format: {"field": ["message"]}
    //     return errors[errors.keys.first]?.first;
    //   } else if (errors is List && errors.isNotEmpty) {
    //     // new format: ["message"]
    //     return errors.first.toString();
    //   } else {
    //     return null;
    //   }
    // })(),
    data: json["data"] == null ? null : json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status == null ? "error" : status.toString(),
    "message": message == null ? null : message,
    "errors": validationError == null ? null : validationError,
    "data": data == null ? null : data,
  };

  ApiRequest copyWith({String? status, String? message, dynamic validationError, dynamic data}) {
    return ApiRequest(
      status: status ?? this.status,
      message: message ?? this.message,
      validationError: validationError ?? this.validationError,
      data: data ?? this.data,
    );
  }

  ApiRequest withSuccess() {
    return ApiRequest(
      status: 'success',
      message: this.message,
      validationError: this.validationError,
      data: this.data,
    );
  }

  ApiRequest withMessage({String? message}) {
    return ApiRequest(
      status: 'success',
      message: message ?? this.message,
      validationError: this.validationError,
      data: this.data,
    );
  }

  bool isOk() => status == "success";

  bool isSuccessful() => status == 'success';

  bool hasError() => status == 'error';

  bool hasValidationErrors() => validationError != null;

  bool hasData() {
    if (data == null) {
      return false;
    } else if (data is List) {
      if (data.length > 0) return true;
    } else if (data is Map) {
      if (data.length > 0) return true;
    }

    return false;
  }
}

import '../../../global/requests/GlobalRequest.dart';
import '../../../global/requests/ApiResponse.dart';
import '../../../models/InvoiceModel.dart';

class InvoiceDataResponse {
  final List<InvoiceModel> invoices;
  final Map<String, dynamic> metrics;

  InvoiceDataResponse({
    required this.invoices,
    required this.metrics,
  });
}

/// Module-specific Request File for Tax Invoices
class InvoiceRequest {
  final GlobalRequest _network = GlobalRequest();

  /// Fetch User Tax Invoices & Summary Metrics: GET /api/client/invoices
  Future<ApiResponse<InvoiceDataResponse>> getInvoices({
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _network.get<InvoiceDataResponse>(
      '/api/client/invoices',
      queryParameters: queryParams,
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        final rawInvoices = data['invoices'];
        final List<InvoiceModel> list = [];
        if (rawInvoices is List) {
          for (final item in rawInvoices) {
            if (item is Map) {
              list.add(InvoiceModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
        final metrics = data['metrics'] is Map
            ? Map<String, dynamic>.from(data['metrics'] as Map)
            : <String, dynamic>{};

        return InvoiceDataResponse(
          invoices: list,
          metrics: metrics,
        );
      },
    );
    return response;
  }

  /// Fetch single Invoice details: GET /api/client/invoices/{id}
  Future<ApiResponse<InvoiceModel>> getInvoiceDetail(int id) async {
    final response = await _network.get<InvoiceModel>(
      '/api/client/invoices/$id',
      fromJson: (json) {
        final data = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
        return InvoiceModel.fromJson(data);
      },
    );
    return response;
  }
}

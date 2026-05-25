class InspectionParams {
  final String inspectionId;
  final String productCode;
  final String lineNo;
  final String shift;
  final String operatorId;
  final String date;
  final List<String> shellAssemblyParams;
  final List<String> qciParams;

  InspectionParams({
    required this.inspectionId,
    required this.productCode,
    required this.lineNo,
    required this.shift,
    required this.operatorId,
    required this.date,
    required this.shellAssemblyParams,
    required this.qciParams,
  });

  factory InspectionParams.fromJson(Map<String, dynamic> json) {
    return InspectionParams(
      inspectionId: json['inspectionId'] ?? '',
      productCode: json['productCode'] ?? '',
      lineNo: json['lineNo'] ?? '',
      shift: json['shift'] ?? '',
      operatorId: json['operatorId'] ?? '',
      date: json['date'] ?? '',
      shellAssemblyParams: List<String>.from(json['shellAssemblyParams'] ?? []),
      qciParams: List<String>.from(json['qciParams'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'inspectionId': inspectionId,
        'productCode': productCode,
        'lineNo': lineNo,
        'shift': shift,
        'operatorId': operatorId,
        'date': date,
        'shellAssemblyParams': shellAssemblyParams,
        'qciParams': qciParams,
      };
}

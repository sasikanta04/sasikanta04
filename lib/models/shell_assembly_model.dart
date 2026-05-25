class ShellAssemblyModel {
  final String inspectionId;
  String shellSerialNo;
  String shellWeight;
  String shellDiameter;
  String shellLength;
  String weldQuality;
  String surfaceFinish;
  String dimensionalAccuracy;
  String leakTest;
  String remarks;
  String status;
  bool isSynced;

  ShellAssemblyModel({
    required this.inspectionId,
    this.shellSerialNo = '',
    this.shellWeight = '',
    this.shellDiameter = '',
    this.shellLength = '',
    this.weldQuality = 'OK',
    this.surfaceFinish = 'OK',
    this.dimensionalAccuracy = 'OK',
    this.leakTest = 'OK',
    this.remarks = '',
    this.status = 'Pending',
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'inspectionId': inspectionId,
        'shellSerialNo': shellSerialNo,
        'shellWeight': shellWeight,
        'shellDiameter': shellDiameter,
        'shellLength': shellLength,
        'weldQuality': weldQuality,
        'surfaceFinish': surfaceFinish,
        'dimensionalAccuracy': dimensionalAccuracy,
        'leakTest': leakTest,
        'remarks': remarks,
        'status': status,
        'isSynced': isSynced,
      };

  factory ShellAssemblyModel.fromJson(Map<String, dynamic> json) {
    return ShellAssemblyModel(
      inspectionId: json['inspectionId'] ?? '',
      shellSerialNo: json['shellSerialNo'] ?? '',
      shellWeight: json['shellWeight'] ?? '',
      shellDiameter: json['shellDiameter'] ?? '',
      shellLength: json['shellLength'] ?? '',
      weldQuality: json['weldQuality'] ?? 'OK',
      surfaceFinish: json['surfaceFinish'] ?? 'OK',
      dimensionalAccuracy: json['dimensionalAccuracy'] ?? 'OK',
      leakTest: json['leakTest'] ?? 'OK',
      remarks: json['remarks'] ?? '',
      status: json['status'] ?? 'Pending',
      isSynced: json['isSynced'] ?? false,
    );
  }
}

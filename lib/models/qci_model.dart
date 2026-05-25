class QciModel {
  final String inspectionId;
  String qciSerialNo;
  String visualInspection;
  String dimensionCheck;
  String hardnessTest;
  String torqueCheck;
  String assemblyVerification;
  String finalAppearance;
  String packagingCheck;
  String qciRemarks;
  String qciStatus;
  bool isSynced;

  QciModel({
    required this.inspectionId,
    this.qciSerialNo = '',
    this.visualInspection = 'Pass',
    this.dimensionCheck = 'Pass',
    this.hardnessTest = 'Pass',
    this.torqueCheck = 'Pass',
    this.assemblyVerification = 'Pass',
    this.finalAppearance = 'Pass',
    this.packagingCheck = 'Pass',
    this.qciRemarks = '',
    this.qciStatus = 'Pending',
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'inspectionId': inspectionId,
        'qciSerialNo': qciSerialNo,
        'visualInspection': visualInspection,
        'dimensionCheck': dimensionCheck,
        'hardnessTest': hardnessTest,
        'torqueCheck': torqueCheck,
        'assemblyVerification': assemblyVerification,
        'finalAppearance': finalAppearance,
        'packagingCheck': packagingCheck,
        'qciRemarks': qciRemarks,
        'qciStatus': qciStatus,
        'isSynced': isSynced,
      };

  factory QciModel.fromJson(Map<String, dynamic> json) {
    return QciModel(
      inspectionId: json['inspectionId'] ?? '',
      qciSerialNo: json['qciSerialNo'] ?? '',
      visualInspection: json['visualInspection'] ?? 'Pass',
      dimensionCheck: json['dimensionCheck'] ?? 'Pass',
      hardnessTest: json['hardnessTest'] ?? 'Pass',
      torqueCheck: json['torqueCheck'] ?? 'Pass',
      assemblyVerification: json['assemblyVerification'] ?? 'Pass',
      finalAppearance: json['finalAppearance'] ?? 'Pass',
      packagingCheck: json['packagingCheck'] ?? 'Pass',
      qciRemarks: json['qciRemarks'] ?? '',
      qciStatus: json['qciStatus'] ?? 'Pending',
      isSynced: json['isSynced'] ?? false,
    );
  }
}

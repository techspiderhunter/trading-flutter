class SubmitKycParams {
  final String fullName;
  final String fatherName;
  final String dob;
  final String gender;
  final String maritalStatus;
  final String email;
  final String phone;
  final String pan;
  final String aadhaar;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String occupation;
  final String incomeRange;
  final String experience;
  final int isPep;

  final String? panFilePath;
  final String? panBackFilePath;
  final String? aadhaarFrontFilePath;
  final String? aadhaarBackFilePath;

  final bool isUpdate;

  SubmitKycParams({
    required this.fullName,
    required this.fatherName,
    required this.dob,
    required this.gender,
    required this.maritalStatus,
    required this.email,
    required this.phone,
    required this.pan,
    required this.aadhaar,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.occupation,
    required this.incomeRange,
    required this.experience,
    this.isPep = 0,
    this.panFilePath,
    this.panBackFilePath,
    this.aadhaarFrontFilePath,
    this.aadhaarBackFilePath,
    this.isUpdate = false,
  });

  Map<String, dynamic> toFieldsMap() {
    return {
      'fullName': fullName,
      'full_name': fullName,
      'name': fullName,
      'fatherName': fatherName,
      'father_name': fatherName,
      'dob': dob,
      'date_of_birth': dob,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'marital_status': maritalStatus,
      'email': email,
      'phone': phone,
      'mobile': phone,
      'pan': pan,
      'pan_number': pan,
      'panNumber': pan,
      'aadhaar': aadhaar,
      'aadhaar_number': aadhaar,
      'aadhaarNumber': aadhaar,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'pin_code': pincode,
      'occupation': occupation,
      'incomeRange': incomeRange,
      'income_range': incomeRange,
      'experience': experience,
      'tradingExperience': experience,
      'is_pep': isPep,
    };
  }
}

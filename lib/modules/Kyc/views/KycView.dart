import '../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/KycModel.dart';
import '../../../themes/AppColors.dart';
import '../controllers/KycController.dart';
import '../../../global/Validator/Validators.dart';
import 'widgets/KycDocumentViewerModal.dart';

class KycView extends StatelessWidget {
  const KycView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<KycController>()
        ? Get.find<KycController>()
        : Get.put(KycController());

    return Obx(() {
      final isLoading = controller.isLoadingKyc.value;
      final isEditing = controller.isEditing.value;
      final kyc = controller.currentKyc.value;
      final status = controller.currentKycStatus.value.trim().toLowerCase();

      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.scaffoldBackground,
        appBar: DeskAppBar(
            group: 'KYC',
            onBack: () {
              if (isEditing && kyc != null && !kyc.isNotSubmitted) {
                controller.cancelEditing();
              } else {
                Get.back();
              }
            },
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.textSecondary, size: 22),
                tooltip: 'Refresh Status',
                onPressed: controller.loadExistingKycOrPrefill,
              ),
              const SizedBox(width: 6),
            ]),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.primary),
                );
              }

              // 1. If user is in Form/Edit mode (new KYC submission OR re-submitting after rejection)
              if (isEditing || status == 'not_submitted' || kyc == null) {
                return Column(
                  children: [
                    // TOP STEPPER PROGRESS INDICATOR (4 STEPS)
                    _buildStepperHeader(controller),

                    // STEP CONTENT (ALL FIELDS COL-12 FULL WIDTH)
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Obx(() {
                          switch (controller.currentStep.value) {
                            case 0:
                              return _buildStep1Personal(controller, context);
                            case 1:
                              return _buildStep2AddressAndIds(controller);
                            case 2:
                              return _buildStep3FinancialAndRisk(controller);
                            case 3:
                            default:
                              return _buildStep4DocumentsAndConsent(
                                  controller, context);
                          }
                        }),
                      ),
                    ),
                  ],
                );
              }

              // 2. Direct Show Page when Verified / Approved
              if (status == 'verified' || kyc.isVerified) {
                return _buildVerifiedShowPage(controller, kyc, context);
              }

              // 3. Under Review / Pending State
              if (status == 'pending' ||
                  status == 'under_review' ||
                  kyc.isPending) {
                return _buildUnderReviewPage(controller, kyc, context);
              }

              // 4. Rejected / Action Required State
              if (status == 'rejected' ||
                  status == 'declined' ||
                  kyc.isRejected) {
                return _buildRejectedPage(controller, kyc, context);
              }

              // Fallback to Form
              return Column(
                children: [
                  _buildStepperHeader(controller),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: _buildStep1Personal(controller, context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  // =========================================================
  // STEPPER PROGRESS HEADER
  // =========================================================
  Widget _buildStepperHeader(KycController controller) {
    return Obx(() {
      final current = controller.currentStep.value;
      return Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STEP 0${current + 1} / 04',
                style: deskText.copyWith(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
                children: List.generate(
                    4,
                    (index) => Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(right: index < 3 ? 9 : 0),
                            child: GestureDetector(
                                onTap: () {
                                  if (index <= current)
                                    controller.goToStep(index);
                                },
                                child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: index <= current
                                            ? AppColors.primary
                                            : AppColors.border,
                                        borderRadius:
                                            BorderRadius.circular(2)))))))),
          ]));
    });
  }

  // =========================================================
  // STEP 1: PERSONAL DETAILS (STRICTLY COL-12 FULL WIDTH)
  // =========================================================
  Widget _buildStep1Personal(KycController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          icon: Icons.person_outline_rounded,
          title: '1. Personal Information',
          subtitle: 'Legal information exactly as printed on official records.',
        ),
        const SizedBox(height: 25),
        _buildCard([
          // Field 1: Full Legal Name (col-12)
          _buildInputLabel('Full Legal Name *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.fullNameController,
              textCapitalization: TextCapitalization.words,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => Validators.name(v, 'Full Legal Name'),
              decoration: _buildInputDecor(
                hint: 'Enter your name as per PAN / Aadhaar',
                icon: Icons.badge_outlined,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field 2: Father's / Spouse's Name (col-12)
          _buildInputLabel("Father's / Spouse's Full Name *"),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.fatherNameController,
              textCapitalization: TextCapitalization.words,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => Validators.name(v, "Father's / Spouse's Name"),
              decoration: _buildInputDecor(
                hint: "Enter father's or spouse's name",
                icon: Icons.people_outline_rounded,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field 3: Date of Birth (col-12)
          _buildInputLabel('Date of Birth *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.dobController,
              readOnly: true,
              onTap: () => controller.pickDob(context),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.dob,
              decoration: _buildInputDecor(
                hint: 'Select Date of Birth (YYYY-MM-DD)',
                icon: Icons.calendar_today_outlined,
                suffix: IconButton(
                  icon: Icon(
                    Icons.date_range_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => controller.pickDob(context),
                ),
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field 4: Gender (col-12)
          _buildInputLabel('Gender *'),
          const SizedBox(height: 6),
          Obx(
            () => DropdownButtonFormField<String>(
              isExpanded: true,
              value:
                  ['Male', 'Female', 'Other'].contains(controller.gender.value)
                      ? controller.gender.value
                      : null,
              hint: const Text(
                'Select Gender',
                style: TextStyle(
                    fontFamily: 'DeskSans',
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5),
              ),
              decoration: _buildInputDecor(
                hint: 'Select Gender',
                icon: Icons.transgender_rounded,
              ),
              items: ['Male', 'Female', 'Other'].map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (val) {
                controller.gender.value = val;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Field 5: Marital Status (col-12)
          _buildInputLabel('Marital Status *'),
          const SizedBox(height: 6),
          Obx(
            () => DropdownButtonFormField<String>(
              isExpanded: true,
              value: ['Single', 'Married', 'Other']
                      .contains(controller.maritalStatus.value)
                  ? controller.maritalStatus.value
                  : null,
              hint: const Text(
                'Select Marital Status',
                style: TextStyle(
                    fontFamily: 'DeskSans',
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5),
              ),
              decoration: _buildInputDecor(
                hint: 'Select Marital Status',
                icon: Icons.favorite_border_rounded,
              ),
              items: ['Single', 'Married', 'Other'].map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (val) {
                controller.maritalStatus.value = val;
              },
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Stepper Navigation Actions
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DeskButton(label: 'Continue', onPressed: controller.nextStep)
        ]),
      ],
    );
  }

  // =========================================================
  // STEP 2: ADDRESS & REGULATORY IDS (STRICTLY COL-12 FULL WIDTH)
  // =========================================================
  Widget _buildStep2AddressAndIds(KycController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          icon: Icons.contact_mail_outlined,
          title: '2. Permanent Address & Identification',
          subtitle:
              'Contact details, statutory tax numbers and residential address.',
        ),
        const SizedBox(height: 25),
        _buildCard([
          // Field: Registered Email (col-12)
          _buildInputLabel('Registered Email *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.email,
              decoration: _buildInputDecor(
                hint: 'Enter registered email address',
                icon: Icons.mail_outline_rounded,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: Phone Number (col-12)
          _buildInputLabel('Phone Number *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.phone,
              decoration: _buildInputDecor(
                hint: 'Enter 10-digit mobile number',
                icon: Icons.phone_outlined,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: PAN Card Number (col-12)
          _buildInputLabel('PAN Card Number *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.panNumberController,
              textCapitalization: TextCapitalization.characters,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.pan,
              decoration: _buildInputDecor(
                hint: 'Enter your 10-character PAN number',
                icon: Icons.credit_card_rounded,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: Aadhaar Number (col-12)
          _buildInputLabel('Aadhaar Card Number *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.aadhaarNumberController,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.aadhaar,
              decoration: _buildInputDecor(
                hint: '12-digit Aadhaar Number',
                icon: Icons.fingerprint_rounded,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: Address Line (col-12)
          _buildInputLabel('Permanent Address Line *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.addressController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.address,
              decoration: _buildInputDecor(
                hint: 'House / Street / Area',
                icon: Icons.location_on_outlined,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: City (col-12 - NO Row, full width)
          _buildInputLabel('City *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.cityController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.city,
              decoration: _buildInputDecor(
                hint: 'City',
                icon: Icons.location_city_outlined,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: State (col-12)
          _buildInputLabel('State *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.stateController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.state,
              decoration: _buildInputDecor(
                hint: 'State',
                icon: Icons.map_outlined,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: Pin Code (col-12)
          _buildInputLabel('Pin Code *'),
          const SizedBox(height: 6),
          TextFormField(
              controller: controller.pincodeController,
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.pincode,
              decoration: _buildInputDecor(
                hint: '6-digit Pincode',
                icon: Icons.pin_drop_outlined,
              ),
              style: deskText),
          const SizedBox(height: 16),

          // Field: Country (col-12)
          _buildInputLabel('Country'),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: 'India'),
            readOnly: true,
            decoration: _buildInputDecor(
              hint: 'India',
              icon: Icons.public_rounded,
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Stepper Navigation Actions
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DeskButton(label: 'Continue', onPressed: controller.nextStep),
          const SizedBox(height: 20),
          DeskButton(
              label: 'Previous',
              secondary: true,
              onPressed: controller.prevStep)
        ]),
      ],
    );
  }

  // =========================================================
  // STEP 3: FINANCIAL & RISK PROFILING (100% CRASH-PROOF & COL-12)
  // =========================================================
  Widget _buildStep3FinancialAndRisk(KycController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          icon: Icons.trending_up_rounded,
          title: '3. Financial & Risk Profile',
          subtitle:
              'Statutory profiling mandated by SEBI for suitability categorization.',
        ),
        const SizedBox(height: 25),
        _buildCard([
          // Field: Annual Income (col-12)
          _buildInputLabel('Annual Income Range *'),
          const SizedBox(height: 6),
          Obx(
            () {
              final currentVal = KycController.incomeOptions
                      .contains(controller.annualIncome.value)
                  ? controller.annualIncome.value
                  : null;

              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: currentVal,
                hint: const Text(
                  'Select Annual Income',
                  style: TextStyle(
                      fontFamily: 'DeskSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5),
                ),
                decoration: _buildInputDecor(
                  hint: 'Select Annual Income',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                items: KycController.incomeOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  controller.annualIncome.value = val;
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Field: Occupation (col-12)
          _buildInputLabel('Occupation *'),
          const SizedBox(height: 6),
          Obx(
            () {
              final currentVal = KycController.occupationOptions
                      .contains(controller.occupation.value)
                  ? controller.occupation.value
                  : null;

              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: currentVal,
                hint: const Text(
                  'Select Occupation',
                  style: TextStyle(
                      fontFamily: 'DeskSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5),
                ),
                decoration: _buildInputDecor(
                  hint: 'Select Occupation',
                  icon: Icons.work_outline_rounded,
                ),
                items: KycController.occupationOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  controller.occupation.value = val;
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Field: Trading Experience (col-12)
          _buildInputLabel('Trading Experience *'),
          const SizedBox(height: 6),
          Obx(
            () {
              final currentVal = KycController.experienceOptions
                      .contains(controller.tradingExperience.value)
                  ? controller.tradingExperience.value
                  : null;

              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: currentVal,
                hint: const Text(
                  'Select Trading Experience',
                  style: TextStyle(
                      fontFamily: 'DeskSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5),
                ),
                decoration: _buildInputDecor(
                  hint: 'Select Trading Experience',
                  icon: Icons.history_rounded,
                ),
                items: KycController.experienceOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  controller.tradingExperience.value = val;
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Field: Risk Appetite (col-12)
          _buildInputLabel('Risk Appetite *'),
          const SizedBox(height: 6),
          Obx(
            () {
              final currentVal = KycController.riskOptions
                      .contains(controller.riskAppetite.value)
                  ? controller.riskAppetite.value
                  : null;

              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: currentVal,
                hint: const Text(
                  'Select Risk Appetite',
                  style: TextStyle(
                      fontFamily: 'DeskSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5),
                ),
                decoration: _buildInputDecor(
                  hint: 'Select Risk Appetite',
                  icon: Icons.speed_rounded,
                ),
                items: KycController.riskOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) {
                  controller.riskAppetite.value = val;
                },
              );
            },
          ),
        ]),
        const SizedBox(height: 16),

        // Stepper Navigation Actions
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DeskButton(label: 'Continue', onPressed: controller.nextStep),
          const SizedBox(height: 20),
          DeskButton(
              label: 'Previous',
              secondary: true,
              onPressed: controller.prevStep)
        ]),
      ],
    );
  }

  // =========================================================
  // STEP 4: DOCUMENTS & REGULATORY DECLARATIONS (STRICTLY COL-12)
  // =========================================================
  Widget _buildStep4DocumentsAndConsent(
      KycController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          icon: Icons.file_upload_outlined,
          title: '4. Document Proofs & Declarations',
          subtitle:
              'Upload legible identity proofs and authorize SEBI verification.',
        ),
        const SizedBox(height: 25),
        _buildCard([
          // Doc 1: Aadhaar Card (col-12)
          _buildInputLabel('1. Aadhaar Card (UIDAI Proof) *'),
          const SizedBox(height: 6),
          _buildUploadBox(
            title: 'Aadhaar Card (Front)',
            isUploaded: controller.aadhaarFrontUploaded,
            defaultHint: 'Upload PDF / JPG up to 5MB',
            onTap: controller.pickAadhaarFrontDocument,
            onPreview: () => KycDocumentViewerModal.show(
              context,
              title: 'Aadhaar Card (Front)',
              localFilePath: controller.aadhaarFrontFilePath.value,
              imageUrl: controller.currentKyc.value?.secureAadhaarFrontUrl,
            ),
          ),
          const SizedBox(height: 12),
          _buildUploadBox(
            title: 'Aadhaar Card (Back)',
            isUploaded: controller.aadhaarBackUploaded,
            defaultHint: 'Upload back side of Aadhaar card',
            onTap: controller.pickAadhaarBackDocument,
            onPreview: () => KycDocumentViewerModal.show(
              context,
              title: 'Aadhaar Card (Back)',
              localFilePath: controller.aadhaarBackFilePath.value,
              imageUrl: controller.currentKyc.value?.secureAadhaarBackUrl,
            ),
          ),
          const SizedBox(height: 16),

          // Doc 2: PAN Card (col-12)
          _buildInputLabel('2. PAN Card (Income Tax Department) *'),
          const SizedBox(height: 6),
          _buildUploadBox(
            title: 'Permanent Account Number (PAN) Card',
            isUploaded: controller.panFrontUploaded,
            defaultHint: 'Upload clear front image',
            onTap: controller.pickPanDocument,
            onPreview: () => KycDocumentViewerModal.show(
              context,
              title: 'PAN Card (Front)',
              localFilePath: controller.panFilePath.value,
              imageUrl: controller.currentKyc.value?.securePanDocumentUrl,
            ),
          ),
          const SizedBox(height: 16),

          // Doc 3: Bank Proof (col-12)
          // _buildInputLabel('3. Bank Proof (Cheque / Statement) *'),
          // const SizedBox(height: 6),
          // _buildUploadBox(
          //   title: 'Cancelled Cheque Leaf / Passbook',
          //   isUploaded: controller.bankProofUploaded,
          //   defaultHint: 'Upload recent 3 months statement / cheque',
          // ),
          // const SizedBox(height: 20),

          // Statutory Declarations (col-12 - Initially Unchecked)
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: controller.declareTrueInfo.value,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) =>
                        controller.declareTrueInfo.value = val ?? false,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'I declare that the information provided is true, accurate, and matches my official government identity records.',
                    style: TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: controller.declareSebiCompliance.value,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) =>
                        controller.declareSebiCompliance.value = val ?? false,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'I confirm I am not a Politically Exposed Person (PEP) and authorize verification under SEBI & PMLA rules.',
                    style: TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Stepper Navigation Actions & Submit (DIRECT TO DASHBOARD)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Obx(() => DeskButton(
              label: 'Submit KYC',
              loading: controller.isSubmitting.value,
              onPressed:
                  controller.isSubmitting.value ? null : controller.submitKyc)),
          const SizedBox(height: 20),
          DeskButton(
              label: 'Previous',
              secondary: true,
              onPressed: controller.prevStep)
        ]),
      ],
    );
  }

  // =========================================================
  // HELPER WIDGETS
  // =========================================================
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return DeskHero(
        title: title.startsWith('1.')
            ? 'Personal information'
            : title.startsWith('2.')
                ? 'Address & identification'
                : title.startsWith('3.')
                    ? 'Financial & risk profile'
                    : 'Documents & declarations',
        subtitle: 'Keep details consistent with your official records.');
  }

  Widget _buildCard(List<Widget> children) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _buildInputLabel(String text) {
    return Text(text,
        style: deskText.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600));
  }

  InputDecoration _buildInputDecor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return deskInputDecoration(hintText: hint, suffixIcon: suffix);
  }

  Widget _buildUploadBox({
    required String title,
    required RxBool isUploaded,
    required String defaultHint,
    VoidCallback? onTap,
    VoidCallback? onPreview,
  }) {
    return Obx(() => DeskUpload(
        title: title,
        attached: isUploaded.value,
        hint: defaultHint,
        onTap: onTap ??
            () {
              isUploaded.toggle();
            },
        onPreview: onPreview));
  }

  // =========================================================================
  // VERIFIED SHOW PAGE (Direct view when KYC is verified & approved)
  // =========================================================================
  Widget _buildVerifiedShowPage(
      KycController controller, KycModel kyc, BuildContext context) {
    final addressText = [kyc.address, kyc.city, kyc.state, kyc.pincode]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    return DeskBody(children: [
      const DeskHero(title: 'Identity verification.'),
      const SizedBox(height: 25),
      ComplianceStatus(
          reference: kyc.displayReferenceId,
          title: 'Verified',
          description: 'Your identity verification is complete.',
          color: AppColors.success,
          icon: Icons.check_rounded),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Personal information',
          icon: Icons.person_outline_rounded,
          children: [
            _buildKycInfoRow(
                'Full Legal Name', kyc.fullName ?? 'Verified Client'),
            if (kyc.fatherName != null && kyc.fatherName!.isNotEmpty)
              _buildKycInfoRow('Father\'s Name', kyc.fatherName!),
            if (kyc.dateOfBirth != null && kyc.dateOfBirth!.isNotEmpty)
              _buildKycInfoRow('Date of Birth', kyc.dateOfBirth!),
            if (kyc.gender != null && kyc.gender!.isNotEmpty)
              _buildKycInfoRow('Gender', kyc.gender!),
          ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Identity & address',
          icon: Icons.badge_outlined,
          children: [
            _buildKycInfoRow('Permanent Account (PAN)',
                kyc.panNumber ?? 'Verified on record'),
            if (kyc.aadhaarNumber != null && kyc.aadhaarNumber!.isNotEmpty)
              _buildKycInfoRow(
                'Aadhaar Number',
                kyc.aadhaarNumber!.length >= 4
                    ? 'XXXX-XXXX-${kyc.aadhaarNumber!.substring(kyc.aadhaarNumber!.length - 4)}'
                    : kyc.aadhaarNumber!,
              ),
            if (addressText.isNotEmpty)
              _buildKycInfoRow('Residential Address', addressText),
          ]),
      const SizedBox(height: 16),
      if ((kyc.occupation?.isNotEmpty ?? false) ||
          (kyc.incomeRange?.isNotEmpty ?? false) ||
          (kyc.experience?.isNotEmpty ?? false))
        ComplianceGroup(
            title: 'Financial profile',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              if (kyc.occupation != null && kyc.occupation!.isNotEmpty)
                _buildKycInfoRow('Occupation', kyc.occupation!),
              if (kyc.incomeRange != null && kyc.incomeRange!.isNotEmpty)
                _buildKycInfoRow('Annual Income', kyc.incomeRange!),
              if (kyc.experience != null && kyc.experience!.isNotEmpty)
                _buildKycInfoRow('Trading Experience', kyc.experience!),
            ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Compliance details',
          icon: Icons.verified_user_outlined,
          children: [
            if (kyc.verifiedAt != null && kyc.verifiedAt!.isNotEmpty)
              _buildKycInfoRow('Verified On', kyc.verifiedAt!),
            _buildKycInfoRow(
                'Compliance Standard', 'SEBI (RA) Regulations, 2014'),
          ]),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Identity documents',
          icon: Icons.folder_outlined,
          children: [
            _buildDocItem(
              context: context,
              title: 'PAN Card (Front)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'PAN Card (Front)',
                imageUrl: kyc.securePanDocumentUrl,
                localFilePath: controller.panFilePath.value,
              ),
            ),
            _buildDocItem(
              context: context,
              title: 'Aadhaar Card (Front)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'Aadhaar Card (Front)',
                imageUrl: kyc.secureAadhaarFrontUrl,
                localFilePath: controller.aadhaarFrontFilePath.value,
              ),
            ),
            _buildDocItem(
              context: context,
              title: 'Aadhaar Card (Back)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'Aadhaar Card (Back)',
                imageUrl: kyc.secureAadhaarBackUrl,
                localFilePath: controller.aadhaarBackFilePath.value,
              ),
            ),
            if (kyc.panBackImage != null && kyc.panBackImage!.isNotEmpty)
              _buildDocItem(
                context: context,
                title: 'PAN Card (Back)',
                isAttached: true,
                onPreview: () => KycDocumentViewerModal.show(
                  context,
                  title: 'PAN Card (Back)',
                  imageUrl: kyc.securePanBackUrl,
                ),
              ),
          ]),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildUnderReviewPage(
      KycController controller, KycModel kyc, BuildContext context) {
    final addressText = [kyc.address, kyc.city, kyc.state, kyc.pincode]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    return DeskBody(children: [
      const DeskHero(title: 'Identity verification.'),
      const SizedBox(height: 25),
      ComplianceStatus(
          reference: kyc.displayReferenceId,
          title: 'Under Review',
          description: 'Your submission is under review.',
          color: AppColors.warning,
          icon: Icons.schedule_rounded),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Personal information',
          icon: Icons.person_outline_rounded,
          children: [
            _buildKycInfoRow(
                'Full Legal Name', kyc.fullName ?? 'Verified Client'),
            if (kyc.fatherName != null && kyc.fatherName!.isNotEmpty)
              _buildKycInfoRow('Father\'s Name', kyc.fatherName!),
            if (kyc.dateOfBirth != null && kyc.dateOfBirth!.isNotEmpty)
              _buildKycInfoRow('Date of Birth', kyc.dateOfBirth!),
            if (kyc.gender != null && kyc.gender!.isNotEmpty)
              _buildKycInfoRow('Gender', kyc.gender!),
          ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Identity & address',
          icon: Icons.badge_outlined,
          children: [
            _buildKycInfoRow('Permanent Account (PAN)',
                kyc.panNumber ?? 'Verified on record'),
            if (kyc.aadhaarNumber != null && kyc.aadhaarNumber!.isNotEmpty)
              _buildKycInfoRow(
                'Aadhaar Number',
                kyc.aadhaarNumber!.length >= 4
                    ? 'XXXX-XXXX-${kyc.aadhaarNumber!.substring(kyc.aadhaarNumber!.length - 4)}'
                    : kyc.aadhaarNumber!,
              ),
            if (addressText.isNotEmpty)
              _buildKycInfoRow('Residential Address', addressText),
          ]),
      const SizedBox(height: 16),
      if ((kyc.occupation?.isNotEmpty ?? false) ||
          (kyc.incomeRange?.isNotEmpty ?? false) ||
          (kyc.experience?.isNotEmpty ?? false))
        ComplianceGroup(
            title: 'Financial profile',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              if (kyc.occupation != null && kyc.occupation!.isNotEmpty)
                _buildKycInfoRow('Occupation', kyc.occupation!),
              if (kyc.incomeRange != null && kyc.incomeRange!.isNotEmpty)
                _buildKycInfoRow('Annual Income', kyc.incomeRange!),
              if (kyc.experience != null && kyc.experience!.isNotEmpty)
                _buildKycInfoRow('Trading Experience', kyc.experience!),
            ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Compliance details',
          icon: Icons.verified_user_outlined,
          children: [
            if (kyc.verifiedAt != null && kyc.verifiedAt!.isNotEmpty)
              _buildKycInfoRow('Verified On', kyc.verifiedAt!),
            _buildKycInfoRow(
                'Compliance Standard', 'SEBI (RA) Regulations, 2014'),
          ]),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Identity documents',
          icon: Icons.folder_outlined,
          children: [
            _buildDocItem(
              context: context,
              title: 'PAN Card (Front)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'PAN Card (Front)',
                imageUrl: kyc.securePanDocumentUrl,
                localFilePath: controller.panFilePath.value,
              ),
            ),
            _buildDocItem(
              context: context,
              title: 'Aadhaar Card (Front)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'Aadhaar Card (Front)',
                imageUrl: kyc.secureAadhaarFrontUrl,
                localFilePath: controller.aadhaarFrontFilePath.value,
              ),
            ),
            _buildDocItem(
              context: context,
              title: 'Aadhaar Card (Back)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'Aadhaar Card (Back)',
                imageUrl: kyc.secureAadhaarBackUrl,
                localFilePath: controller.aadhaarBackFilePath.value,
              ),
            ),
            if (kyc.panBackImage != null && kyc.panBackImage!.isNotEmpty)
              _buildDocItem(
                context: context,
                title: 'PAN Card (Back)',
                isAttached: true,
                onPreview: () => KycDocumentViewerModal.show(
                  context,
                  title: 'PAN Card (Back)',
                  imageUrl: kyc.securePanBackUrl,
                ),
              ),
          ]),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildRejectedPage(
      KycController controller, KycModel kyc, BuildContext context) {
    final addressText = [kyc.address, kyc.city, kyc.state, kyc.pincode]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    final reason =
        kyc.rejectionReason != null && kyc.rejectionReason!.isNotEmpty
            ? kyc.rejectionReason!
            : 'Identity proofs were incomplete or unreadable.';
    return DeskBody(children: [
      const DeskHero(title: 'Identity verification.'),
      const SizedBox(height: 25),
      ComplianceStatus(
          reference: kyc.displayReferenceId,
          title: 'Rejected',
          description: reason,
          color: AppColors.error,
          icon: Icons.priority_high_rounded),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Personal information',
          icon: Icons.person_outline_rounded,
          children: [
            _buildKycInfoRow(
                'Full Legal Name', kyc.fullName ?? 'Verified Client'),
            if (kyc.fatherName != null && kyc.fatherName!.isNotEmpty)
              _buildKycInfoRow('Father\'s Name', kyc.fatherName!),
            if (kyc.dateOfBirth != null && kyc.dateOfBirth!.isNotEmpty)
              _buildKycInfoRow('Date of Birth', kyc.dateOfBirth!),
            if (kyc.gender != null && kyc.gender!.isNotEmpty)
              _buildKycInfoRow('Gender', kyc.gender!),
          ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Identity & address',
          icon: Icons.badge_outlined,
          children: [
            _buildKycInfoRow('Permanent Account (PAN)',
                kyc.panNumber ?? 'Verified on record'),
            if (kyc.aadhaarNumber != null && kyc.aadhaarNumber!.isNotEmpty)
              _buildKycInfoRow(
                'Aadhaar Number',
                kyc.aadhaarNumber!.length >= 4
                    ? 'XXXX-XXXX-${kyc.aadhaarNumber!.substring(kyc.aadhaarNumber!.length - 4)}'
                    : kyc.aadhaarNumber!,
              ),
            if (addressText.isNotEmpty)
              _buildKycInfoRow('Residential Address', addressText),
          ]),
      const SizedBox(height: 16),
      if ((kyc.occupation?.isNotEmpty ?? false) ||
          (kyc.incomeRange?.isNotEmpty ?? false) ||
          (kyc.experience?.isNotEmpty ?? false))
        ComplianceGroup(
            title: 'Financial profile',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              if (kyc.occupation != null && kyc.occupation!.isNotEmpty)
                _buildKycInfoRow('Occupation', kyc.occupation!),
              if (kyc.incomeRange != null && kyc.incomeRange!.isNotEmpty)
                _buildKycInfoRow('Annual Income', kyc.incomeRange!),
              if (kyc.experience != null && kyc.experience!.isNotEmpty)
                _buildKycInfoRow('Trading Experience', kyc.experience!),
            ]),
      const SizedBox(height: 16),
      ComplianceGroup(
          title: 'Compliance details',
          icon: Icons.verified_user_outlined,
          children: [
            if (kyc.verifiedAt != null && kyc.verifiedAt!.isNotEmpty)
              _buildKycInfoRow('Verified On', kyc.verifiedAt!),
            _buildKycInfoRow(
                'Compliance Standard', 'SEBI (RA) Regulations, 2014'),
          ]),
      const SizedBox(height: 18),
      ComplianceGroup(
          title: 'Identity documents',
          icon: Icons.folder_outlined,
          children: [
            _buildDocItem(
              context: context,
              title: 'PAN Card (Front)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'PAN Card (Front)',
                imageUrl: kyc.securePanDocumentUrl,
                localFilePath: controller.panFilePath.value,
              ),
            ),
            _buildDocItem(
              context: context,
              title: 'Aadhaar Card (Front)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'Aadhaar Card (Front)',
                imageUrl: kyc.secureAadhaarFrontUrl,
                localFilePath: controller.aadhaarFrontFilePath.value,
              ),
            ),
            _buildDocItem(
              context: context,
              title: 'Aadhaar Card (Back)',
              isAttached: true,
              onPreview: () => KycDocumentViewerModal.show(
                context,
                title: 'Aadhaar Card (Back)',
                imageUrl: kyc.secureAadhaarBackUrl,
                localFilePath: controller.aadhaarBackFilePath.value,
              ),
            ),
            if (kyc.panBackImage != null && kyc.panBackImage!.isNotEmpty)
              _buildDocItem(
                context: context,
                title: 'PAN Card (Back)',
                isAttached: true,
                onPreview: () => KycDocumentViewerModal.show(
                  context,
                  title: 'PAN Card (Back)',
                  imageUrl: kyc.securePanBackUrl,
                ),
              ),
          ]),
      const SizedBox(height: 16),
      const SizedBox(height: 16),
      DeskButton(
          label: 'Update & Re-submit KYC',
          onPressed: controller.startResubmission),
    ]);
  }

  Widget _buildKycInfoRow(String label, String value) {
    return ComplianceField(label, value);
  }

  Widget _buildDocItem({
    required BuildContext context,
    required String title,
    required bool isAttached,
    VoidCallback? onPreview,
  }) {
    return ComplianceDocumentTile(
        title: title, attached: isAttached, onPreview: onPreview);
  }
}

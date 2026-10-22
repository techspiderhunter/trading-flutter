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

      String title = 'Complete Client KYC';
      if (!isEditing && kyc != null) {
        if (status == 'verified' || kyc.isVerified) {
          title = 'KYC Verification';
        } else if (status == 'pending' || kyc.isPending) {
          title = 'KYC Under Review';
        } else if (status == 'rejected' || kyc.isRejected) {
          title = 'KYC Verification Status';
        }
      }

      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
            onPressed: () {
              if (isEditing && kyc != null && !kyc.isNotSubmitted) {
                controller.cancelEditing();
              } else {
                Get.back();
              }
            },
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
              tooltip: 'Refresh Status',
              onPressed: controller.loadExistingKycOrPrefill,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
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
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                              return _buildStep4DocumentsAndConsent(controller, context);
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
              if (status == 'pending' || status == 'under_review' || kyc.isPending) {
                return _buildUnderReviewPage(controller, kyc, context);
              }

              // 4. Rejected / Action Required State
              if (status == 'rejected' || status == 'declined' || kyc.isRejected) {
                return _buildRejectedPage(controller, kyc, context);
              }

              // Fallback to Form
              return Column(
                children: [
                  _buildStepperHeader(controller),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
    final stepTitles = [
      'Personal Details',
      'Address & IDs',
      'Financial & Risk Profile',
      'Documents & Declarations'
    ];

    final stepShortLabels = ['Personal', 'Address', 'Financial', 'Docs'];

    return Obx(() {
      final current = controller.currentStep.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Indicator row with circles and connecting lines
            Row(
              children: List.generate(4, (index) {
                final isCompleted = index < current;
                final isActive = index == current;

                return Expanded(
                  child: Row(
                    children: [
                      // Step Circle Node
                      GestureDetector(
                        onTap: () {
                          // Allow jumping back to previous completed steps or active
                          if (index <= current) {
                            controller.goToStep(index);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted || isActive
                                    ? AppColors.primary
                                    : Colors.white,
                                border: Border.all(
                                  color: isCompleted || isActive
                                      ? AppColors.primary
                                      : const Color(0xFFCBD5E1),
                                  width: 2,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 18)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: isActive
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stepShortLabels[index],
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? AppColors.primary
                                    : (isCompleted
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Connecting Line (except after the last item)
                      if (index < 3)
                        Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.only(
                                left: 6, right: 6, bottom: 16),
                            color: index < current
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Subtext: Step X of 4: Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Step ${current + 1} of 4 • ${stepTitles[current]}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
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
        const SizedBox(height: 12),
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
          ),
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
          ),
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
                icon: const Icon(
                  Icons.date_range_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => controller.pickDob(context),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 4: Gender (col-12)
          _buildInputLabel('Gender *'),
          const SizedBox(height: 6),
          Obx(
            () => DropdownButtonFormField<String>(
              value: ['Male', 'Female', 'Other'].contains(controller.gender.value)
                  ? controller.gender.value
                  : null,
              hint: const Text(
                'Select Gender',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
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
              value: ['Single', 'Married', 'Other']
                      .contains(controller.maritalStatus.value)
                  ? controller.maritalStatus.value
                  : null,
              hint: const Text(
                'Select Marital Status',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
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
        const SizedBox(height: 24),

        // Stepper Navigation Actions
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next: Address & IDs',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
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
        const SizedBox(height: 12),
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
          ),
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
          ),
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
          ),
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
          ),
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
          ),
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
          ),
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
          ),
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
          ),
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
        const SizedBox(height: 24),

        // Stepper Navigation Actions
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: controller.prevStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '← Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next: Risk Profile',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
        const SizedBox(height: 12),
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
                value: currentVal,
                hint: const Text(
                  'Select Annual Income',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
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
                value: currentVal,
                hint: const Text(
                  'Select Occupation',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
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
                value: currentVal,
                hint: const Text(
                  'Select Trading Experience',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
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
                value: currentVal,
                hint: const Text(
                  'Select Risk Appetite',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
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
        const SizedBox(height: 24),

        // Stepper Navigation Actions
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: controller.prevStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '← Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next: Documents',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 24),

        // Stepper Navigation Actions & Submit (DIRECT TO DASHBOARD)
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: controller.prevStep,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '← Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitKyc,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit KYC ',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.check_circle_outline_rounded,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required RxBool isUploaded,
    required String defaultHint,
    VoidCallback? onTap,
    VoidCallback? onPreview,
  }) {
    return Obx(() {
      final uploaded = isUploaded.value;

      return InkWell(
        onTap: onTap ?? () {
          isUploaded.toggle();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: uploaded ? AppColors.primaryLight : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: uploaded
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: uploaded ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Icon(
                  uploaded
                      ? Icons.check_circle_rounded
                      : Icons.cloud_upload_outlined,
                  color: uploaded ? AppColors.primary : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uploaded
                          ? 'Document attached successfully ✓'
                          : defaultHint,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: uploaded
                            ? AppColors.primaryDark
                            : const Color(0xFF94A3B8),
                        fontWeight:
                            uploaded ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (uploaded && onPreview != null) ...[
                InkWell(
                  onTap: onPreview,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: uploaded ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: uploaded ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  uploaded ? 'Change' : 'Upload',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: uploaded ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // =========================================================================
  // VERIFIED SHOW PAGE (Direct view when KYC is verified & approved)
  // =========================================================================
  Widget _buildVerifiedShowPage(
      KycController controller, KycModel kyc, BuildContext context) {
    final addressText = [
      kyc.address,
      kyc.city,
      kyc.state,
      kyc.pincode,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verified Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SEBI Regulatory KYC Verified',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ref: ${kyc.displayReferenceId}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Verified Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Verified Investor Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                _buildKycInfoRow('Full Legal Name', kyc.fullName ?? 'Verified Client'),
                if (kyc.fatherName != null && kyc.fatherName!.isNotEmpty)
                  _buildKycInfoRow('Father\'s Name', kyc.fatherName!),
                if (kyc.dateOfBirth != null && kyc.dateOfBirth!.isNotEmpty)
                  _buildKycInfoRow('Date of Birth', kyc.dateOfBirth!),
                if (kyc.gender != null && kyc.gender!.isNotEmpty)
                  _buildKycInfoRow('Gender', kyc.gender!),
                _buildKycInfoRow('Permanent Account (PAN)', kyc.panNumber ?? 'Verified on record'),
                if (kyc.aadhaarNumber != null && kyc.aadhaarNumber!.isNotEmpty)
                  _buildKycInfoRow(
                    'Aadhaar Number',
                    kyc.aadhaarNumber!.length >= 4
                        ? 'XXXX-XXXX-${kyc.aadhaarNumber!.substring(kyc.aadhaarNumber!.length - 4)}'
                        : kyc.aadhaarNumber!,
                  ),
                if (addressText.isNotEmpty)
                  _buildKycInfoRow('Residential Address', addressText),
                if (kyc.occupation != null && kyc.occupation!.isNotEmpty)
                  _buildKycInfoRow('Occupation', kyc.occupation!),
                if (kyc.incomeRange != null && kyc.incomeRange!.isNotEmpty)
                  _buildKycInfoRow('Annual Income', kyc.incomeRange!),
                if (kyc.experience != null && kyc.experience!.isNotEmpty)
                  _buildKycInfoRow('Trading Experience', kyc.experience!),
                if (kyc.verifiedAt != null && kyc.verifiedAt!.isNotEmpty)
                  _buildKycInfoRow('Verified On', kyc.verifiedAt!),
                _buildKycInfoRow('Compliance Standard', 'SEBI (RA) Regulations, 2014'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Attached Documents Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.folder_shared_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Verified Documents on Record',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Click on any document below to view its verified proof preview.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
          const SizedBox(height: 18),

          // SEBI Statutory Compliance Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your KYC verification has been officially verified by Moneyara Compliance Desk. All research advisories and communications are fully active.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // UNDER REVIEW / PENDING STATE
  // =========================================================================
  Widget _buildUnderReviewPage(
      KycController controller, KycModel kyc, BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFD97706),
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'KYC Under Compliance Review',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your SEBI Regulatory KYC verification documents have been submitted and are under audit by Moneyara Compliance Desk.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Reference ID Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reference ID: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  Text(
                    kyc.displayReferenceId,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Audit is typically completed within 1-2 business hours. You will receive an immediate notification once approved.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submitted Documents on Record (Under Review)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_shared_outlined,
                          color: Color(0xFF00B074), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Submitted Documents',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Click on any document below to view its submitted preview.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // REJECTED / ACTION REQUIRED STATE
  // =========================================================================
  Widget _buildRejectedPage(
      KycController controller, KycModel kyc, BuildContext context) {
    final reason = kyc.rejectionReason != null && kyc.rejectionReason!.isNotEmpty
        ? kyc.rejectionReason!
        : 'Identity proofs or PAN card documents were incomplete or unreadable.';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFFEF4444),
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'KYC Verification Rejected',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance Desk Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F1D1D),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please review the compliance desk feedback, correct the required documents or information, and re-submit your KYC.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),

            // Re-submit Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.startResubmission,
                icon: const Icon(Icons.edit_document, size: 18, color: Colors.white),
                label: const Text(
                  'Re-submit KYC Documents',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
  Widget _buildKycInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem({
    required BuildContext context,
    required String title,
    required bool isAttached,
    VoidCallback? onPreview,
  }) {
    return InkWell(
      onTap: isAttached ? onPreview : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isAttached ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAttached ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAttached ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isAttached ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (isAttached)
                    const Text(
                      'Tap to view document preview',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00B074),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (isAttached)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF00B074)),
                    SizedBox(width: 4),
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00B074),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Not Attached',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

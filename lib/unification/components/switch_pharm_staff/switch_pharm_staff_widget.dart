import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/rbac/rbac.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'switch_pharm_staff_model.dart';
export 'switch_pharm_staff_model.dart';

class SwitchPharmStaffWidget extends StatefulWidget {
  const SwitchPharmStaffWidget({super.key, required this.staffId});

  final DocumentReference? staffId;

  @override
  State<SwitchPharmStaffWidget> createState() => _SwitchPharmStaffWidgetState();
}

class _SwitchPharmStaffWidgetState extends State<SwitchPharmStaffWidget> {
  late SwitchPharmStaffModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SwitchPharmStaffModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).pop();

  Future<void> _switchPharmacy() async {
    final staffRef = widget.staffId;
    final pharmacyPath = _model.dropDownValue;
    if (staffRef == null || pharmacyPath == null || pharmacyPath.isEmpty) return;

    logFirebaseEvent('SWITCH_PHARM_STAFF_SWITCH_BTN_ON_TAP');
    await staffRef.update(createStaffRecordData(
      pharmId: FirebaseFirestore.instance.doc(pharmacyPath),
    ));
    if (mounted) _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: Colors.transparent,
          elevation: 12,
          shadowColor: Colors.black.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 540,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.person_pin_circle_outlined,
                            color: theme.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Move staff to another pharmacy',
                              style: theme.titleLarge.override(
                                fontFamily: theme.titleLargeFamily,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryText,
                                useGoogleFonts: !theme.titleLargeIsCustom,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose the pharmacy where this staff member will work.',
                              style: theme.bodySmall.override(
                                fontFamily: theme.bodySmallFamily,
                                color: theme.secondaryText,
                                useGoogleFonts: !theme.bodySmallIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close staff transfer dialog',
                        onPressed: _dismiss,
                        icon: const Icon(Icons.close_rounded),
                        color: theme.secondaryText,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.alternate),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: StreamBuilder<List<PharmacyRecord>>(
                      stream: queryPharmacyRecord(
                        parent: AccessControl.networkWideQueryParent(context),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildStatus(
                            icon: Icons.cloud_off_rounded,
                            title: 'Pharmacies are unavailable',
                            message: 'Check your connection and try again.',
                          );
                        }
                        if (!snapshot.hasData) {
                          return SizedBox(
                            height: 118,
                            child: Center(
                              child: SpinKitRing(
                                color: theme.primary,
                                size: 30,
                              ),
                            ),
                          );
                        }

                        final pharmacies = snapshot.data!
                            .where((p) =>
                                !p.deleted &&
                                p.networkStatus.toLowerCase() == 'active')
                            .toList()
                          ..sort((a, b) => a.name
                              .toLowerCase()
                              .compareTo(b.name.toLowerCase()));
                        if (pharmacies.isEmpty) {
                          return _buildStatus(
                            icon: Icons.local_pharmacy_outlined,
                            title: 'No active pharmacies available',
                            message:
                                'Add or approve a pharmacy before moving staff.',
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destination pharmacy',
                              style: theme.labelLarge.override(
                                fontFamily: theme.labelLargeFamily,
                                color: theme.primaryText,
                                fontWeight: FontWeight.w600,
                                useGoogleFonts: !theme.labelLargeIsCustom,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FlutterFlowDropDown<String>(
                              controller: _model.dropDownValueController ??=
                                  FormFieldController<String>(null),
                              options:
                                  pharmacies.map((p) => p.reference.path).toList(),
                              optionLabels: pharmacies
                                  .map((p) => p.address.isEmpty
                                      ? p.name
                                      : '${p.name} · ${p.address}')
                                  .toList(),
                              onChanged: (value) => safeSetState(
                                  () => _model.dropDownValue = value),
                              width: double.infinity,
                              height: 52,
                              textStyle: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                color: theme.primaryText,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                              hintText: 'Select a pharmacy',
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: theme.secondaryText),
                              fillColor: theme.primaryBackground,
                              elevation: 8,
                              borderColor: theme.alternate,
                              focusBorderColor: theme.primary,
                              borderWidth: 1.2,
                              borderRadius: 12,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  14, 0, 14, 0),
                              hidesUnderline: true,
                              isOverButton: false,
                              isSearchable: true,
                              isMultiSelect: false,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'The staff assignment is updated immediately after you confirm.',
                              style: theme.bodySmall.override(
                                fontFamily: theme.bodySmallFamily,
                                color: theme.secondaryText,
                                useGoogleFonts: !theme.bodySmallIsCustom,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.alternate),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: _dismiss, child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _model.dropDownValue == null
                            ? null
                            : _switchPharmacy,
                        icon: const Icon(Icons.person_pin_circle_outlined,
                            size: 18),
                        label: const Text('Move staff'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 32, color: theme.secondaryText),
          const SizedBox(height: 10),
          Text(title,
              style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts: !theme.titleSmallIsCustom)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  useGoogleFonts: !theme.bodySmallIsCustom)),
        ],
      ),
    );
  }
}

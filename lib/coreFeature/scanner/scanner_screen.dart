import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pinlink/config/color/app_color.dart';
import 'package:pinlink/coreFeature/scanner/cubit/scanner_cubit.dart';
import 'package:pinlink/coreFeature/scanner/cubit/scanner_state.dart';
import 'package:pinlink/utils/formatters.dart';

@RoutePage()
class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerCubit(),
      child: const _ScannerScreenView(),
    );
  }
}

class _ScannerScreenView extends StatefulWidget {
  const _ScannerScreenView();

  @override
  State<_ScannerScreenView> createState() => _ScannerScreenViewState();
}

class _ScannerScreenViewState extends State<_ScannerScreenView> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeFocusNode.addListener(_onFocusChange);
    _quantityFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final hasFocus = _codeFocusNode.hasFocus || _quantityFocusNode.hasFocus;
    if (mounted) {
      context.read<ScannerCubit>().setFieldsFocus(hasFocus);
    }
  }

  @override
  void dispose() {
    _codeFocusNode.removeListener(_onFocusChange);
    _quantityFocusNode.removeListener(_onFocusChange);
    _codeController.dispose();
    _quantityController.dispose();
    _codeFocusNode.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScannerCubit>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Scanner')),
        body: BlocBuilder<ScannerCubit, ScannerState>(
          builder: (context, state) {
            if (!_codeFocusNode.hasFocus &&
                _codeController.text != state.scannedCode) {
              _codeController.text = state.scannedCode;
            }
            final quantityText = state.quantity.toString();
            if (!_quantityFocusNode.hasFocus &&
                _quantityController.text != quantityText) {
              _quantityController.text = quantityText;
            }
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: MockupColors.cardBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: state.isOcrMode
                              ? (state.isCameraInitialized &&
                                        cubit.cameraController != null
                                    ? CameraPreview(cubit.cameraController!)
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      ))
                              : MobileScanner(
                                  controller: cubit.barcodeController,
                                  onDetect: cubit.onBarcodeDetect,
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: cubit.toggleFlash,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isFlashOn
                                    ? Icons.flashlight_on_outlined
                                    : Icons.flashlight_off_outlined,
                                size: 16,
                                color: state.isFlashOn
                                    ? MockupColors.warningAmber
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!state.isOcrMode && !state.isScanning)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 6,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    color: MockupColors.errorRed,
                    alignment: Alignment.center,
                    child: const Text(
                      'Scanning Stopped...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                // Secondary read-only readout of the last detected value
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: MockupColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.lastScannedCode,
                      style: const TextStyle(
                        color: MockupColors.textWhite,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                // BR/QR | OCR segmented toggle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeTab(
                          label: 'BR/QR',
                          selected: !state.isOcrMode,
                          onTap: () => cubit.toggleMode(false),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _ModeTab(
                          label: 'OCR',
                          selected: state.isOcrMode,
                          onTap: () => cubit.toggleMode(true),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scan Button
                const SizedBox(height: 8),
                _buttonFunction(
                  onTap: cubit.scanButtonPressed,
                  title: 'Scan',
                  fontSize: 20,
                ),

                const SizedBox(height: 4),

                if (state.isScanning) ...[
                  Row(
                    children: [
                      _buttonFunction(
                        title: 'Code',
                        fontSize: 14,
                        verticalPadding: 6,
                        horizontalPadding: 8,
                        onTap: () {},
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: _textField(
                            controller: _codeController,
                            focusNode: _codeFocusNode,
                            onChanged: cubit.updateCode,
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      _buttonFunction(
                        title: 'Quantity',
                        verticalPadding: 6,
                        fontSize: 14,
                        horizontalPadding: 8,
                        onTap: () {},
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 80,
                        height: 40,
                        child: _textField(
                          controller: _quantityController,
                          focusNode: _quantityFocusNode,
                          onChanged: cubit.updateQuantity,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _saveOrUpdateButton(cubit, state),
                ],

                // Code / Quantity inputs
                if (!state.isScanning) _initial(cubit, state),

                Expanded(flex: 5, child: _inspectionList(state, cubit)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required void Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,

      decoration: const InputDecoration(
        contentPadding: .symmetric(horizontal: 8),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MockupColors.textSubtle, width: 1),
          borderRadius: .all(.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MockupColors.textSubtle, width: 1),
          borderRadius: .all(.circular(8)),
        ),
      ),
    );
  }

  Widget _buttonFunction({
    required VoidCallback onTap,
    required String title,
    required double fontSize,
    double? horizontalPadding,
    double? verticalPadding,
  }) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding ?? 16,
            horizontal: horizontalPadding ?? 40,
          ),
          textStyle: TextStyle(fontSize: fontSize),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize, fontWeight: .bold),
        ),
      ),
    );
  }

  Widget _saveOrUpdateButton(ScannerCubit cubit, ScannerState state) {
    final isEditing = cubit.isEditing;
    return _buttonFunction(
      title: isEditing ? 'Update' : 'Save',
      fontSize: 20,
      onTap: () async {
        if (isEditing) {
          cubit.updateCurrentItem();
        } else {
          final success = await cubit.saveAndExport();
          if (success && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  Column _initial(ScannerCubit cubit, ScannerState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFieldCard(
                  label: 'Code',
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  onChanged: cubit.updateCode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFieldCard(
                  label: 'Quantity',
                  controller: _quantityController,
                  focusNode: _quantityFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: cubit.updateQuantity,
                ),
              ),
            ],
          ),
        ),

        // Save / Update Button (hidden until the list has at least one item)
        if (state.inspectionList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _saveOrUpdateButton(cubit, state),
          ),
      ],
    );
  }

  Column _inspectionList(ScannerState state, ScannerCubit cubit) {
    return Column(
      children: [
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.grid_view, size: 16, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                'Inspection List',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: MockupColors.textWhite,
                ),
              ),
            ],
          ),
        ),

        // Inspection List
        Expanded(
          child: state.inspectionList.isEmpty
              ? const Center(
                  child: Text(
                    'There is no Data.',
                    style: TextStyle(color: MockupColors.warningAmber),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: MockupColors.cardBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(80),
                        1: FlexColumnWidth(),
                        2: FixedColumnWidth(80),
                      },
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          color: MockupColors.cardBorder,
                          width: 1,
                        ),
                      ),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: MockupColors.cardBackground,
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: MockupColors.textWhite,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: MockupColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: MockupColors.textWhite,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...state.inspectionList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isEditing = state.editingIndex == index;
                          return TableRow(
                            children: [
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => cubit.selectItemForEdit(index),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isEditing
                                              ? MockupColors.warningAmber
                                              : MockupColors.mint,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Reset',
                                          style: TextStyle(
                                            color: MockupColors.pageBackground,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  child: ExpandableTextWidget(
                                    text: item.value,
                                    threshold: 30,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(
                                        color: MockupColors.textWhite,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
  }) {
    return _FieldCard(
      label: label,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,

        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        textAlign: textAlign,
        style: const TextStyle(color: MockupColors.textWhite, fontSize: 13),
        decoration: const InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const double radious = 8;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MockupColors.mint),
        borderRadius: BorderRadius.circular(radious),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: MockupColors.mint,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: MockupColors.pageBackground,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Container(color: MockupColors.cardBackground, child: child),
          Container(
            height: 8,
            decoration: const BoxDecoration(
              color: MockupColors.cardBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(radious),
                bottomRight: Radius.circular(radious),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? MockupColors.tealTabActive.withValues(alpha: .3)
              : MockupColors.cardBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? MockupColors.tealTabActive
                : MockupColors.cardBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: selected ? MockupColors.textWhite : MockupColors.textSubtle,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

/// Nahlásit závadu — bottom-sheet-style formulář (text + fotky).
/// Ported 1:1 from FaultReport.jsx (rendered as a full screen here).
class FaultReportScreen extends ConsumerStatefulWidget {

  const FaultReportScreen({super.key});

  @override
  ConsumerState<FaultReportScreen> createState() => _FaultReportScreenState();
}

class _FaultReportScreenState extends ConsumerState<FaultReportScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  // Photo placeholders — no real picker; each tap adds a tile.
  int _photoCount = 0;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canSubmit => _ctrl.text.trim().isNotEmpty;

  String _photoLabel(int n) {
    if (n == 0) return 'volitelné';
    final word = n == 1 ? 'foto' : n < 5 ? 'fotky' : 'fotek';
    return '$n $word';
  }

  void _submit() {
    if (!_canSubmit) return;
    final text = _ctrl.text.trim();
    final photoSuffix = _photoCount > 0 ? '  (${_photoLabel(_photoCount)})' : '';
    ref
        .read(storeProvider)
        .sendMessage('pavel', 'Závada: $text$photoSuffix', from: 'pavel');
    navCb(context)('board', toast: 'Závada odeslána');
  }

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);

    return ScreenFrame(
      child: Stack(
        children: [
          // Dark scrim look behind the sheet.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => nav('back'),
              child: const ColoredBox(color: Color(0xA6000000)),
            ),
          ),
          // Sheet pinned to the bottom of the screen.
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 376),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: T.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 40,
                      offset: Offset(0, -20),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle.
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(top: 4, bottom: 14),
                            decoration: BoxDecoration(
                              color: T.surface2,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Header.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nahlásit závadu',
                                    style: AppType.ui(
                                      size: 20,
                                      weight: FontWeight.w700,
                                      color: T.text,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Co se pokazilo, co nejde? Pošli to Oldovi, on vyřídí.',
                                    style: AppType.ui(
                                      size: 13,
                                      color: T.text2,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => nav('back'),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: T.surface2,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: AppIcon('x', size: 14, color: T.text2),
                              ),
                            ),
                          ],
                        ),

                        // Textarea.
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: T.bg,
                            border: Border.all(
                              color: _focused ? T.accent : T.border,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: TextField(
                            controller: _ctrl,
                            focusNode: _focus,
                            maxLines: 4,
                            minLines: 4,
                            cursorColor: T.accent,
                            style: AppType.ui(
                              size: 14,
                              color: T.text,
                              height: 1.5,
                              letterSpacing: -0.1,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText:
                                  'Třeba: bench č. 2 má rozsekané lano nebo ve sprše č. 3 protéká kohoutek.',
                              hintStyle: AppType.ui(
                                size: 14,
                                color: T.text3,
                                height: 1.5,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),

                        // Photos.
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FOTKY',
                                style: AppType.ui(
                                  size: 11.5,
                                  weight: FontWeight.w600,
                                  color: T.text2,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                _photoLabel(_photoCount),
                                style: AppType.ui(
                                  size: 11.5,
                                  color: T.text3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (int i = 0; i < _photoCount; i++)
                              _PhotoTile(
                                onRemove: () =>
                                    setState(() => _photoCount -= 1),
                              ),
                            // Add-photo tile.
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _photoCount += 1),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: T.bg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: T.border),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppIcon('plus', size: 18, color: T.text2),
                                    const SizedBox(height: 4),
                                    Text(
                                      'fotka',
                                      style: AppType.ui(
                                        size: 10,
                                        color: T.text2,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Submit.
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: _canSubmit ? 1 : 0.4,
                          child: AppButton(
                            label: 'Odeslat',
                            full: true,
                            onTap: _canSubmit ? _submit : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo placeholder tile (no real image — dashed-look filler with remove btn).
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: T.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: T.border),
            ),
            alignment: Alignment.center,
            child: AppIcon('alert', size: 20, color: T.text3),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xB3000000),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AppIcon('x', size: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

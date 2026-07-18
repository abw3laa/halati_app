import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localization.dart';
import '../models/update_manifest.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';

enum _Stage { prompt, downloading, readyToInstall, error }

/// Full-flow "new version available" dialog:
///   • shows the version number + release notes
///   • lets the user start the download, watches progress live
///   • once complete, offers an "Install now" button that hands the APK
///     to the system installer (asking for the one-time "install unknown
///     apps" permission along the way if needed)
///
/// Call [showUpdateDialog] rather than constructing this directly.
class UpdateDialog extends StatefulWidget {
  final UpdateCheckResult result;

  const UpdateDialog({super.key, required this.result});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  _Stage _stage = _Stage.prompt;
  double _progress = 0;
  String? _errorMessage;
  CancelToken? _cancelToken;
  File? _apkFile;

  bool get _mandatory => widget.result.isMandatory;

  Future<void> _startDownload() async {
    setState(() {
      _stage = _Stage.downloading;
      _progress = 0;
      _errorMessage = null;
    });
    _cancelToken = CancelToken();
    try {
      final file = await UpdateService.instance.downloadApk(
        widget.result.manifest,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
        cancelToken: _cancelToken,
      );
      if (!mounted) return;
      setState(() {
        _apkFile = file;
        _stage = _Stage.readyToInstall;
      });
      // Convenience: jump straight into the installer once ready, the
      // user can still re-tap "Install" below if the system sheet is
      // dismissed accidentally.
      unawaited(_install());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _install() async {
    final file = _apkFile;
    if (file == null) return;
    final result = await UpdateService.instance.installApk(file);
    if (!mounted) return;
    if (result == InstallApkResult.permissionDenied) {
      setState(() {
        _stage = _Stage.error;
        _errorMessage = T(context, 'update_permission_denied');
      });
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final manifest = widget.result.manifest;
    final lang = AppLocalizationScope.of(context).language;

    return PopScope(
      canPop: !_mandatory,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.system_update_alt,
                        color: scheme.secondaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(T(context, 'update_available_title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'v${manifest.latestVersion}',
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (manifest.notesFor(lang.code).isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    manifest.notesFor(lang.code),
                    style: TextStyle(color: scheme.onSurface, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 20),
              _buildStageBody(context, scheme),
              const SizedBox(height: 16),
              _buildActions(context, scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageBody(BuildContext context, ColorScheme scheme) {
    switch (_stage) {
      case _Stage.prompt:
        return const SizedBox.shrink();

      case _Stage.downloading:
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        );

      case _Stage.readyToInstall:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: AppColors.waGreenStart, size: 20),
            const SizedBox(width: 8),
            Text(T(context, 'update_downloaded'),
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        );

      case _Stage.error:
        return Row(
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage ?? T(context, 'update_generic_error'),
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    switch (_stage) {
      case _Stage.prompt:
        return Row(
          children: [
            if (!_mandatory)
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(T(context, 'update_later')),
                ),
              ),
            if (!_mandatory) const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download, size: 18),
                label: Text(T(context, 'update_download_now')),
              ),
            ),
          ],
        );

      case _Stage.downloading:
        return Row(
          children: [
            if (!_mandatory)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _cancelToken?.cancel();
                    Navigator.of(context).pop();
                  },
                  child: Text(T(context, 'update_cancel')),
                ),
              ),
          ],
        );

      case _Stage.readyToInstall:
        return FilledButton.icon(
          onPressed: _install,
          icon: const Icon(Icons.install_mobile, size: 18),
          label: Text(T(context, 'update_install_now')),
        );

      case _Stage.error:
        return Row(
          children: [
            if (!_mandatory)
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(T(context, 'update_close')),
                ),
              ),
            if (!_mandatory) const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _startDownload,
                child: Text(T(context, 'update_retry')),
              ),
            ),
          ],
        );
    }
  }
}

/// Shows the update dialog whenever [result] indicates a newer version is
/// available. There is no permanent per-version dismissal: a pending
/// update is offered again on every app launch (mandatory updates on top
/// of that also can't be dismissed at all) until the user installs it.
Future<void> showUpdateDialogIfNeeded(
  BuildContext context,
  UpdateCheckResult? result,
) async {
  if (result == null || !result.isUpdateAvailable) return;
  if (!context.mounted) return;
  await showDialog(
    context: context,
    barrierDismissible: !result.isMandatory,
    builder: (_) => UpdateDialog(result: result),
  );
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/theme_colors.dart';
import 'app_input.dart';

/// Componente universal e responsivo para upload e preview de imagens
/// Suporta Mobile (Galeria), Web (Seletor de Arquivos) e Desktop (Explorador Nativo).
class AppImageUpload extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialImageUrl;
  final ValueChanged<String>? onChanged;
  final String? helperText;
  final double? width;
  final double height;
  final BoxShape shape;
  final bool allowUrlInput;

  const AppImageUpload({
    super.key,
    required this.label,
    this.controller,
    this.initialImageUrl,
    this.onChanged,
    this.helperText,
    this.width,
    this.height = 140,
    this.shape = BoxShape.rectangle,
    this.allowUrlInput = true,
  });

  @override
  State<AppImageUpload> createState() => _AppImageUploadState();
}

class _AppImageUploadState extends State<AppImageUpload> {
  late TextEditingController _textController;
  bool _showUrlField = false;
  bool _isLoading = false;
  Uint8List? _localBytes;
  String? _currentValue;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController(text: widget.initialImageUrl ?? '');
    _currentValue = _textController.text;
    _textController.addListener(_onControllerChanged);
    _decodeIfBase64(_currentValue);
  }

  @override
  void didUpdateWidget(covariant AppImageUpload oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      _textController.removeListener(_onControllerChanged);
      _textController = widget.controller!;
      _textController.addListener(_onControllerChanged);
      _currentValue = _textController.text;
      _decodeIfBase64(_currentValue);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    } else {
      _textController.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (_textController.text != _currentValue) {
      setState(() {
        _currentValue = _textController.text;
        _decodeIfBase64(_currentValue);
      });
    }
  }

  void _decodeIfBase64(String? val) {
    if (val != null && val.startsWith('data:image')) {
      try {
        final commaIndex = val.indexOf(',');
        if (commaIndex != -1) {
          final base64Str = val.substring(commaIndex + 1);
          _localBytes = base64Decode(base64Str);
        }
      } catch (_) {
        _localBytes = null;
      }
    } else {
      _localBytes = null;
    }
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'svg'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.xFile.readAsBytes();

        final ext = file.extension?.toLowerCase() ?? 'png';
        final mimeType = ext == 'svg' ? 'image/svg+xml' : 'image/$ext';
        final base64String = 'data:$mimeType;base64,${base64Encode(bytes)}';

        setState(() {
          _localBytes = bytes;
          _currentValue = base64String;
          _textController.text = base64String;
        });

        widget.onChanged?.call(base64String);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar imagem: $e'),
            backgroundColor: ThemeColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() {
      _localBytes = null;
      _currentValue = '';
      _textController.text = '';
    });
    widget.onChanged?.call('');
  }

  Widget _buildImageWidget() {
    if (_localBytes != null) {
      return Image.memory(
        _localBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (_currentValue != null && _currentValue!.trim().isNotEmpty) {
      return Image.network(
        _currentValue!.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: ThemeColors.primary),
            ),
          );
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(height: 8),
          Text(
            'Clique para selecionar imagem',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          if (widget.helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = (_localBytes != null) || (_currentValue != null && _currentValue!.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (widget.allowUrlInput)
              InkWell(
                onTap: () => setState(() => _showUrlField = !_showUrlField),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    _showUrlField ? 'Ocultar Link (URL)' : 'Inserir Link (URL)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Área visual de upload / preview
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.darkSurface : Colors.grey.shade50,
                borderRadius: widget.shape == BoxShape.circle ? null : BorderRadius.circular(8),
                shape: widget.shape,
                border: Border.all(
                  color: isDark ? ThemeColors.darkBorder : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: _buildImageWidget()),

                  // Loading overlay
                  if (_isLoading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: ThemeColors.primary),
                      ),
                    ),

                  // Overlay com ações caso já tenha imagem
                  if (hasImage && !_isLoading)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Trocar Imagem',
                            onTap: _pickImage,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            tooltip: 'Remover Imagem',
                            onTap: _removeImage,
                            isDanger: true,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Campo opcional para colar URL diretamente
        if (_showUrlField && widget.allowUrlInput) ...[
          const SizedBox(height: 10),
          AppInput(
            label: 'Link direto da Imagem (URL)',
            placeholder: 'https://exemplo.com/imagem.png',
            controller: _textController,
            onChanged: (val) {
              setState(() {
                _currentValue = val;
                _decodeIfBase64(val);
              });
              widget.onChanged?.call(val);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isDanger = false,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDanger ? ThemeColors.danger.withValues(alpha: 0.6) : Colors.white24,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDanger ? ThemeColors.danger : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

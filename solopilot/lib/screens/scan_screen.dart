import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_services.dart';
import '../widgets/offline_badge.dart';
import '../widgets/primary_action_button.dart';
import 'review_screen.dart';

/// 2. Scan / Capture Screen.
/// Three input modes: camera photo, pasted text, or voice dictation.
/// Shows OCR progress, "Prepare offline models" card on first use.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _pasteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isPreparingModels = false;
  bool _isListening = false;

  /// Run extraction on text, then navigate to Review.
  Future<void> _processText(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final services = Provider.of<AppServices>(context, listen: false);
    try {
      final fields = await services.extract.extract(text);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(initialFields: fields),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Error extracting details. Please try manually.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Download ML Kit models for offline use.
  Future<void> _prepareModels() async {
    setState(() => _isPreparingModels = true);
    final services = Provider.of<AppServices>(context, listen: false);
    try {
      final ready = await services.extract.ensureModelsReady();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ready
                ? 'Offline models ready!'
                : 'Models could not be prepared. You can still type manually.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPreparingModels = false);
    }
  }

  /// Take a photo and run OCR.
  Future<void> _scanReceipt() async {
    final services = Provider.of<AppServices>(context, listen: false);
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final text = await services.ocr.readTextFromImage(pickedFile.path);
      if (text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No text found in photo. Try pasting or typing instead.')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }
      await _processText(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not read the photo. Please paste or type.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// F5 — Voice dictation: hold to record, release to extract.
  Future<void> _startListening() async {
    final services = Provider.of<AppServices>(context, listen: false);
    final ready = await services.voice.init();
    if (!ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Microphone not available on this device.')),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    _pasteController.clear();

    await services.voice.start((text) {
      if (mounted) {
        setState(() {
          _pasteController.text = text;
        });
      }
    });
  }

  Future<void> _stopListening() async {
    final services = Provider.of<AppServices>(context, listen: false);
    await services.voice.stop();
    setState(() => _isListening = false);

    // Automatically extract when voice stops
    final text = _pasteController.text.trim();
    if (text.isNotEmpty) {
      _processText(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan or Paste'),
        actions: const [
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: OfflineBadge())
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Prepare offline models card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.offline_bolt, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prepare offline models',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Download once while online for full offline use.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _isPreparingModels ? null : _prepareModels,
                      child: Text(
                          _isPreparingModels ? 'Working...' : 'Prepare'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Take Photo button
            PrimaryActionButton(
              label: 'Take Photo',
              icon: Icons.camera_alt,
              onPressed: _scanReceipt,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // Divider
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            // Paste field with mic button
            TextField(
              controller: _pasteController,
              decoration: InputDecoration(
                hintText: 'Paste a client message here...',
                alignLabelWithHint: true,
                suffixIcon: GestureDetector(
                  onLongPressStart: (_) => _startListening(),
                  onLongPressEnd: (_) => _stopListening(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.grey,
                      semanticLabel: 'Hold to dictate',
                    ),
                  ),
                ),
              ),
              maxLines: 5,
              enabled: !_isLoading,
            ),
            if (_isListening)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Listening... release to extract',
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 16),

            // Extract button
            FilledButton.tonalIcon(
              onPressed: _isLoading
                  ? null
                  : () => _processText(_pasteController.text),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Extract'),
            ),
          ],
        ),
      ),
    );
  }
}

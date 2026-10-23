import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/api_service.dart';

class PairDeviceScreen extends ConsumerStatefulWidget {
  const PairDeviceScreen({super.key});
  @override
  ConsumerState<PairDeviceScreen> createState() => _PairDeviceScreenState();
}

class _PairDeviceScreenState extends ConsumerState<PairDeviceScreen> {
  final _code = TextEditingController();
  bool _pairing = false;

  @override
  void dispose() { _code.dispose(); super.dispose(); }

  Future<void> _pair() async {
    final value = _code.text.trim();
    if (value.isEmpty || _pairing) return;
    final accepted = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Share device location?'),
      content: const Text('Pairing links this phone with the code owner and allows location sharing between the paired devices.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Pair')),
      ],
    ));
    if (accepted != true || !mounted) return;
    setState(() => _pairing = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.registerCurrentDevice();
      await api.pairWithCode(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device paired successfully')));
      context.pop();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally { if (mounted) setState(() => _pairing = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pair a device')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.devices_other, size: 64),
        const SizedBox(height: 20),
        const Text('Enter the 6 digit pairing code shown on the other device. Both devices must be signed in.'),
        const SizedBox(height: 20),
        TextField(controller: _code, keyboardType: TextInputType.number, maxLength: 6, textAlign: TextAlign.center,
          decoration: const InputDecoration(labelText: 'Pairing code', hintText: '123456', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _pairing ? null : _pair,
          icon: _pairing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.link),
          label: Text(_pairing ? 'Pairing…' : 'Pair device')),
      ],
    ))),
  );
}

import 'package:flutter/material.dart';

import '../../services/subnet_calculator.dart';
import '../../theme/app_colors.dart';

class SubnetCalcPage extends StatefulWidget {
  const SubnetCalcPage({super.key, this.initial});

  final String? initial;

  @override
  State<SubnetCalcPage> createState() => _SubnetCalcPageState();
}

class _SubnetCalcPageState extends State<SubnetCalcPage> {
  late final TextEditingController _input;
  final _calc = SubnetCalculator();
  SubnetInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController(text: widget.initial ?? '192.168.1.0/24');
    _compute();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _compute() {
    final info = _calc.calculate(_input.text);
    setState(() {
      _info = info;
      _error = info == null ? 'Enter IP/CIDR like 192.168.1.10/24' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subnet Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _input,
            decoration: const InputDecoration(
              labelText: 'IP / CIDR',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _compute(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _compute,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: const Text('Calculate'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          if (_info != null) ...[
            const SizedBox(height: 16),
            _row('Network', _info!.network),
            _row('Broadcast', _info!.broadcast),
            _row('First host', _info!.firstHost),
            _row('Last host', _info!.lastHost),
            _row('Hosts', '${_info!.hostCount}'),
            _row('Mask', _info!.mask),
            _row('Wildcard', _info!.wildcard),
            _row('CIDR', '/${_info!.cidr}'),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(k, style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

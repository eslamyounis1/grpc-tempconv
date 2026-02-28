import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:grpc/grpc_or_grpcweb.dart';

import 'generated/tempconv.pb.dart' as rpc;
import 'generated/tempconv.pbgrpc.dart' as rpc_grpc;

void main() {
  runApp(const TempConvApp());
}

class TempConvApp extends StatelessWidget {
  const TempConvApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B9AAA),
      brightness: Brightness.light,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Temp Converter',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, height: 1.4),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        ),
      ),
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _valueController = TextEditingController();
  late final TextEditingController _urlController;

  static const String _envBackendOverride =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');
  static const String _prodBackendUrl = 'http://34.31.122.97';
  String _fromUnit = 'C';
  String _toUnit = 'F';
  String? _result;
  String? _error;
  bool _loading = false;
  bool _autoConvert = false;
  String _rounding = '2';

  static const List<String> _roundingOptions = ['0', '1', '2', '3'];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _defaultBaseUrl());
  }

  @override
  void dispose() {
    _valueController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final rawValue = _valueController.text.trim();
    final baseUrl = _urlController.text.trim();

    setState(() {
      _error = null;
      _result = null;
    });

    if (rawValue.isEmpty) {
      setState(() => _error = 'Enter a temperature value.');
      return;
    }
    final value = double.tryParse(rawValue);
    if (value == null) {
      setState(() => _error = 'Enter a valid number.');
      return;
    }
    if (baseUrl.isEmpty) {
      setState(() => _error = 'Enter the backend URL.');
      return;
    }
    final endpoint = _parseEndpoint(baseUrl);
    if (endpoint == null) {
      setState(() => _error = 'Enter a valid backend URL.');
      return;
    }

    setState(() => _loading = true);
    final channel = _createChannel(endpoint);
    final client = rpc_grpc.TempConverterClient(channel);
    try {
      final response = await client.convert(
        rpc.ConvertRequest(value: value, from: _fromUnit, to: _toUnit),
      );
      setState(() => _result = _formatResult(response.result));
    } on grpc.GrpcError catch (err) {
      final reason = err.message?.isNotEmpty == true
          ? err.message!
          : 'gRPC error: ${_grpcCode(err)}';
      setState(() => _error = reason);
    } catch (err) {
      setState(() => _error = 'Request failed: $err');
    } finally {
      await channel.shutdown();
      setState(() => _loading = false);
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _maybeAutoConvert();
  }

  void _maybeAutoConvert() {
    if (_autoConvert) {
      _convert();
    }
  }

  String _formatResult(dynamic value) {
    if (value == null) return '';
    final numValue = value is num
        ? value.toDouble()
        : double.tryParse('$value');
    if (numValue == null) return '$value';
    final digits = int.tryParse(_rounding) ?? 2;
    return numValue.toStringAsFixed(digits);
  }

  GrpcOrGrpcWebClientChannel _createChannel(Uri endpoint) {
    final secure = endpoint.scheme == 'https';
    final port = endpoint.hasPort
        ? endpoint.port
        : secure
            ? 443
            : 80;
    return GrpcOrGrpcWebClientChannel.toSingleEndpoint(
      host: endpoint.host,
      port: port,
      transportSecure: secure,
    );
  }

  Uri? _parseEndpoint(String baseUrl) {
    if (baseUrl.isEmpty) return null;
    Uri? uri;
    try {
      uri = Uri.parse(baseUrl);
    } catch (_) {
      return null;
    }
    if (!uri.hasScheme) {
      uri = Uri.parse('http://${uri.toString()}');
    }
    if (uri.host.isEmpty) {
      return null;
    }
    return uri;
  }

  static const Map<int, String> _grpcCodeNames = {
    grpc.StatusCode.ok: 'ok',
    grpc.StatusCode.cancelled: 'cancelled',
    grpc.StatusCode.unknown: 'unknown',
    grpc.StatusCode.invalidArgument: 'invalid argument',
    grpc.StatusCode.deadlineExceeded: 'deadline exceeded',
    grpc.StatusCode.notFound: 'not found',
    grpc.StatusCode.alreadyExists: 'already exists',
    grpc.StatusCode.permissionDenied: 'permission denied',
    grpc.StatusCode.resourceExhausted: 'resource exhausted',
    grpc.StatusCode.failedPrecondition: 'failed precondition',
    grpc.StatusCode.aborted: 'aborted',
    grpc.StatusCode.outOfRange: 'out of range',
    grpc.StatusCode.unimplemented: 'unimplemented',
    grpc.StatusCode.internal: 'internal',
    grpc.StatusCode.unavailable: 'unavailable',
    grpc.StatusCode.dataLoss: 'data loss',
    grpc.StatusCode.unauthenticated: 'unauthenticated',
  };

  String _grpcCode(grpc.GrpcError error) {
    return _grpcCodeNames[error.code] ?? 'code ${error.code}';
  }

  String _defaultBaseUrl() {
    if (kIsWeb) {
      final queryBackend = Uri.base.queryParameters['backend'];
      if (queryBackend != null && queryBackend.isNotEmpty) {
        return queryBackend;
      }
      if (_envBackendOverride.isNotEmpty) {
        return _envBackendOverride;
      }
      if (kReleaseMode ||
          (Uri.base.host.isNotEmpty && Uri.base.host != 'localhost')) {
        return _prodBackendUrl;
      }
      return 'http://localhost:8080';
    }
    if (_envBackendOverride.isNotEmpty) {
      return _envBackendOverride;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      default:
        return 'http://localhost:8080';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE7F6F8), Color(0xFFFDF4E7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: -40,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -60,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _heroPanel(context)),
                                const SizedBox(width: 24),
                                Expanded(child: _converterCard(context)),
                              ],
                            )
                          : ListView(
                              children: [
                                _heroPanel(context),
                                const SizedBox(height: 24),
                                _converterCard(context),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _unitDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Unit',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'C', child: Text('Celsius (C)')),
        DropdownMenuItem(value: 'F', child: Text('Fahrenheit (F)')),
      ],
      onChanged: onChanged,
    );
  }

  Widget _heroPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Go + Flutter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Temperature Converter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Convert Celsius and Fahrenheit instantly with a clean API and a responsive UI.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _featureChip(context, 'Mobile + Web'),
              _featureChip(context, 'Live Convert'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white70),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _converterCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Convert now', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Temperature value',
                hintText: 'e.g., 36.6',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _maybeAutoConvert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _unitDropdown(_fromUnit, (value) {
                    if (value == null) return;
                    setState(() => _fromUnit = value);
                    _maybeAutoConvert();
                  }),
                ),
                IconButton(
                  onPressed: _swapUnits,
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap',
                ),
                Expanded(
                  child: _unitDropdown(_toUnit, (value) {
                    if (value == null) return;
                    setState(() => _toUnit = value);
                    _maybeAutoConvert();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    value: _autoConvert,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto convert'),
                    onChanged: (value) {
                      setState(() => _autoConvert = value);
                      _maybeAutoConvert();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _rounding,
                    decoration: const InputDecoration(
                      labelText: 'Decimals',
                      border: OutlineInputBorder(),
                    ),
                    items: _roundingOptions
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _rounding = value);
                      _maybeAutoConvert();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Backend URL',
                helperText:
                    'gRPC endpoint, Android emulator: http://10.0.2.2:8080',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _maybeAutoConvert(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _convert,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: const Text('Convert'),
              ),
            ),
            const SizedBox(height: 20),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.thermostat, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Result: $_result $_toUnit',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

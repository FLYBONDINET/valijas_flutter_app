
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(ValijaApp());
}

class ValijaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valijas por Vuelo',
      home: ValijaHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ValijaHomePage extends StatefulWidget {
  @override
  _ValijaHomePageState createState() => _ValijaHomePageState();
}

class _ValijaHomePageState extends State<ValijaHomePage> {
  final TextEditingController vueloController = TextEditingController();
  Map<String, List<String>> valijasPorVuelo = {};
  String? codigoEscaneado;

  void escanearCodigo() async {
    final controller = MobileScannerController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 400,
          child: MobileScanner(
            controller: controller,
            onDetect: (barcode, args) {
              final String? code = barcode.rawValue;
              if (code != null) {
                setState(() {
                  codigoEscaneado = code;
                  String vuelo = vueloController.text.trim();
                  if (vuelo.isNotEmpty) {
                    valijasPorVuelo.putIfAbsent(vuelo, () => []);
                    valijasPorVuelo[vuelo]!.add(code);
                  }
                });
                controller.dispose();
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Valijas por Vuelo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: vueloController,
              decoration: InputDecoration(labelText: 'Número de vuelo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: escanearCodigo,
              child: Text('Escanear Código de Valija'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: valijasPorVuelo.entries.map((entry) {
                  return Card(
                    child: ExpansionTile(
                      title: Text('Vuelo ${entry.key} - ${entry.value.length} valijas'),
                      children: entry.value
                          .map((codigo) => ListTile(title: Text(codigo)))
                          .toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

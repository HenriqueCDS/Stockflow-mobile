// Wireframe 03-C: CTA "Pronta para escanear?" com instruções
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';

class ScannerLandingPage extends StatelessWidget {
  const ScannerLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner NFC-e')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Hero icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: context.hs.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 56,
                    color: context.hs.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Pronta para escanear?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'Leia o QR Code da NFC-e (Nota Fiscal do Consumidor Eletrônica) para importar os itens automaticamente para o estoque.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: context.hs.text2, height: 1.5),
              ),
              const SizedBox(height: 32),
              // Steps
              _StepItem(
                number: '1',
                text: 'Abra a câmera e aponte para o QR Code da nota',
              ),
              const SizedBox(height: 14),
              _StepItem(
                number: '2',
                text: 'O app lê e processa os produtos automaticamente',
              ),
              const SizedBox(height: 14),
              _StepItem(
                number: '3',
                text: 'Confirme para dar entrada no estoque',
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push('/scan/camera'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Abrir Câmera'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.hs.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
                color: context.hs.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style:
                TextStyle(fontSize: 13, color: context.hs.text2, height: 1.4),
          ),
        ),
      ],
    );
  }
}

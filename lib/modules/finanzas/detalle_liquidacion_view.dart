import 'dart:typed_data'; // <--- Para manejar los bytes del archivo PDF
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart'; // <--- Plugin PDF
import 'package:pdf/widgets.dart' as pw; // <--- Widgets del PDF
import 'package:printing/printing.dart'; // <--- Plugin Printing
import 'package:share_plus/share_plus.dart'; // <--- Plugin Share Plus

class DetalleLiquidacionView extends StatefulWidget {
  const DetalleLiquidacionView({super.key});

  @override
  State<DetalleLiquidacionView> createState() => _DetalleLiquidacionViewState();
}

class _DetalleLiquidacionViewState extends State<DetalleLiquidacionView> {
  int _tabActivo = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D2214)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle de Liquidación',
          style: TextStyle(color: Color(0xFF4D2214), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Color(0xFF4D2214)), 
            onPressed: () => _mostrarAccionFactura(context, 'compartir'),
          ),
          IconButton(
            icon: const Icon(Icons.description_outlined, color: Color(0xFF4D2214)), 
            onPressed: () => _mostrarAccionFactura(context, 'imprimir'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTopTag(0, 'Monto Bruto'),
                      const SizedBox(width: 8),
                      _buildTopTag(1, 'Comisión'),
                      const SizedBox(width: 8),
                      _buildTopTag(2, 'Impuestos'),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 35, 24, 20),
                    child: Text('Desglose financiero', style: TextStyle(color: Color(0xFF4D2214), fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _construirContenidoDinamico(),
                  const SizedBox(height: 30),
                  _buildGananciaNetaCard(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTag(int index, String text) {
    bool isSelected = _tabActivo == index;
    return GestureDetector(
      onTap: () => setState(() => _tabActivo = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE26112) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF4D2214), fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _construirContenidoDinamico() {
    if (_tabActivo == 0) {
      return Column(children: [
        _buildFinanceItem(icon: Icons.attach_money, label: 'Monto Bruto', value: '+\$1250.00', color: const Color(0xFF2E7D32)),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.credit_card_outlined, label: 'Comisión App', value: '-\$70.00', color: const Color(0xFFE26112)),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.assignment_turned_in_outlined, label: 'Retención Impuestos', value: '-\$0.00', color: Colors.grey),
      ]);
    } else if (_tabActivo == 1) {
      return Column(children: [
        _buildFinanceItem(icon: Icons.pie_chart_outline, label: 'Tarifa de plataforma (5%)', value: '-\$62.50', color: const Color(0xFFE26112)),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.local_atm, label: 'Costo fijo por transacción', value: '-\$7.50', color: const Color(0xFFE26112)),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.functions, label: 'Total Comisión', value: '-\$70.00', color: const Color(0xFF4D2214)),
      ]);
    } else {
      return Column(children: [
        _buildFinanceItem(icon: Icons.account_balance, label: 'Monto Gravable Base', value: '\$1180.00', color: Colors.grey.shade700),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.receipt_long, label: 'Retención de IVA (8%)', value: '-\$0.00', color: Colors.grey),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.request_quote_outlined, label: 'Retención de ISR (1%)', value: '-\$0.00', color: Colors.grey),
      ]);
    }
  }

  Widget _buildFinanceItem({required IconData icon, required String label, required String value, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: Icon(icon, color: Colors.grey.shade700, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF4D2214), fontSize: 14, fontWeight: FontWeight.w600))),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGananciaNetaCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFE26112), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ganancia Neta', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('\$800.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('MXN', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.card_giftcard, color: Colors.white, size: 24))
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(width: double.infinity, height: 6, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
              Container(width: 220, height: 6, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            ],
          ),
          const SizedBox(height: 10),
          const Text('80% del monto bruto', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- INICIO INTEGRACIÓN PDF ---
  Future<Uint8List> _generarPdfFactura() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('JOBHUB - RECIBO DE LIQUIDACION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange800)),
                    pw.Text('Folio #20033'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Fecha de emision: 12 May 2026'),
              pw.Text('Colaborador: Eduardo (Demo)'),
              pw.SizedBox(height: 30),
              pw.TableHelper.fromTextArray(
                context: context,
                data: const <List<String>>[
                  ['Concepto', 'Monto'],
                  ['Ingreso Bruto por Servicio', '\$1250.00'],
                  ['Comision App (5%)', '-\$62.50'],
                  ['Costo Fijo Transaccion', '-\$7.50'],
                  ['Retencion Impuestos', '\$0.00'],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GANANCIA NETA:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$800.00 MXN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Center(child: pw.Text('Documento generado automaticamente por JobHub App.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    return pdf.save(); // Retorna el archivo en formato de bytes
  }
  // --- FIN INTEGRACIÓN PDF ---

  // Lógica funcional de Facturación actualizada con Plugins
  void _mostrarAccionFactura(BuildContext context, String accion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Icon(accion == 'compartir' ? Icons.ios_share : Icons.picture_as_pdf, size: 60, color: const Color(0xFFE26112)),
              const SizedBox(height: 16),
              Text(accion == 'compartir' ? 'Compartir Recibo' : 'Descargar Factura', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4D2214))),
              const SizedBox(height: 8),
              Text(accion == 'compartir' ? '¿Deseas enviar el recibo del folio #20033 a través de WhatsApp o Correo?' : 'La factura fiscal en formato PDF está lista para guardarse en tu dispositivo.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  
                  // ---> INICIO INTEGRACIÓN SHARE_PLUS Y PRINTING <---
                  onPressed: () async {
                    Navigator.pop(context); // Cierra el modal de inmediato
                    
                    // Mostramos indicador de carga nativo
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando documento PDF...')));
                    
                    try {
                      // 1. Generamos el PDF en memoria usando el plugin 'pdf'
                      final Uint8List pdfBytes = await _generarPdfFactura();
                      
                      if (accion == 'compartir') {
                        // 2. Usamos share_plus para enviarlo
                        final xFile = XFile.fromData(pdfBytes, name: 'JobHub_Recibo_20033.pdf', mimeType: 'application/pdf');
                        await Share.shareXFiles([xFile], text: 'Aquí tienes el recibo de liquidación de mi servicio en JobHub.');
                      } else {
                        // 3. Usamos printing para mostrar la vista previa y guardar
                        await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => pdfBytes,
                          name: 'JobHub_Factura_20033',
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
                  // ---> FIN INTEGRACIÓN <---
                  
                  child: Text(accion == 'compartir' ? 'Compartir ahora' : 'Guardar / Imprimir PDF', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
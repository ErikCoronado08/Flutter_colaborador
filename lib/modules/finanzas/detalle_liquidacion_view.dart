import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw; 
import 'package:printing/printing.dart'; 
import 'package:share_plus/share_plus.dart'; 
import 'package:intl/intl.dart';
import '../../services/finanzas_service.dart';

class DetalleLiquidacionView extends StatefulWidget {
  const DetalleLiquidacionView({super.key});

  @override
  State<DetalleLiquidacionView> createState() => _DetalleLiquidacionViewState();
}

class _DetalleLiquidacionViewState extends State<DetalleLiquidacionView> {
  int _tabActivo = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _datos;
  final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  String? _idServicio; // Variable para almacenar el ID que viene de la pantalla anterior

  @override
  void initState() {
    super.initState();
    // Quitamos la carga de datos de aquí porque necesitamos esperar al context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ATRAPAMOS EL ID ENVIADO DESDE EL HISTORIAL
    if (_idServicio == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _idServicio = args;
        _cargarDetalle(); 
      } else {
        // Manejo de error en caso de entrar a la pantalla sin argumentos
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cargarDetalle() async {
    if (_idServicio == null) return;
    try {
      // USAMOS EL ID DINÁMICO PARA CONSULTAR A LARAVEL
      final data = await FinanzasService().obtenerDetalle(_idServicio!); 
      setState(() {
        _datos = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF4D2214)), onPressed: () => Navigator.pop(context)),
        title: const Text('Detalle de Liquidación', style: TextStyle(color: Color(0xFF4D2214), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.ios_share, color: Color(0xFF4D2214)), onPressed: () => _mostrarAccionFactura(context, 'compartir')),
          IconButton(icon: const Icon(Icons.description_outlined, color: Color(0xFF4D2214)), onPressed: () => _mostrarAccionFactura(context, 'imprimir')),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
        : _datos == null 
            ? const Center(child: Text("Error al cargar los datos del servicio"))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 6))]),
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
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFE26112) : Colors.white, borderRadius: BorderRadius.circular(20), border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF4D2214), fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _construirContenidoDinamico() {
    final bruto = formatoMoneda.format(double.parse(_datos!['monto_bruto'].toString()));
    final comision = formatoMoneda.format(double.parse(_datos!['comision_app'].toString()));
    final costoTrans = formatoMoneda.format(double.parse(_datos!['costo_transaccion'].toString()));

    if (_tabActivo == 0) {
      return Column(children: [
        _buildFinanceItem(icon: Icons.attach_money, label: 'Monto Bruto', value: '+$bruto', color: const Color(0xFF2E7D32)),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.credit_card_outlined, label: 'Comisión App', value: comision, color: const Color(0xFFE26112)),
      ]);
    } else {
      return Column(children: [
        _buildFinanceItem(icon: Icons.pie_chart_outline, label: 'Tarifa de plataforma', value: comision, color: const Color(0xFFE26112)),
        const Divider(height: 24, indent: 24, endIndent: 24),
        _buildFinanceItem(icon: Icons.local_atm, label: 'Costo por transacción', value: costoTrans, color: const Color(0xFFE26112)),
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
    final neta = formatoMoneda.format(double.parse(_datos!['ganancia_neta'].toString()));
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ganancia Neta', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(neta, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.card_giftcard, color: Colors.white, size: 24))
            ],
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generarPdfFactura() async {
    final pdf = pw.Document();
    final bruto = formatoMoneda.format(double.parse(_datos!['monto_bruto'].toString()));
    final neta = formatoMoneda.format(double.parse(_datos!['ganancia_neta'].toString()));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('JOBHUB - RECIBO DE LIQUIDACION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange800)), pw.Text('Folio #${_datos!['id_servicio']}')])),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  ['Concepto', 'Monto'],
                  ['Ingreso Bruto por Servicio', bruto],
                  ['Comision App', _datos!['comision_app'].toString()],
                  ['Costo Fijo Transaccion', _datos!['costo_transaccion'].toString()],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GANANCIA NETA:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)), pw.Text(neta, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green700))]),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando documento PDF...')));
                    try {
                      final Uint8List pdfBytes = await _generarPdfFactura();
                      if (accion == 'compartir') {
                        final xFile = XFile.fromData(pdfBytes, name: 'JobHub_Recibo_${_datos!['id_servicio']}.pdf', mimeType: 'application/pdf');
                        await Share.shareXFiles([xFile], text: 'Aquí tienes el recibo de liquidación.');
                      } else {
                        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes, name: 'JobHub_Factura_${_datos!['id_servicio']}');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                    }
                  },
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
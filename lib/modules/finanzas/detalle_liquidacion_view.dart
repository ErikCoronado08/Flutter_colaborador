import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:printing/printing.dart'; 
import 'package:pdf/pdf.dart'; 
import 'package:pdf/widgets.dart' as pw; 
import '../../services/finanzas_service.dart';

class DetalleLiquidacionView extends StatefulWidget {
  const DetalleLiquidacionView({super.key});

  @override
  State<DetalleLiquidacionView> createState() => _DetalleLiquidacionViewState();
}

class _DetalleLiquidacionViewState extends State<DetalleLiquidacionView> {
  bool _isLoading = true;
  Map<String, dynamic>? _datos;
  Map<String, dynamic>? _argsBusqueda;
  final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsBusqueda == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _argsBusqueda = args;
        _cargarDetalle(); 
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cargarDetalle() async {
    if (_argsBusqueda == null) return;
    try {
      final data = await FinanzasService().obtenerDetalle(_argsBusqueda!); 
      setState(() {
        _datos = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- MOTOR GENERADOR DEL PDF (DISEÑO TÉRMICO PROFESIONAL) ---
  Future<pw.Document> _generarPDFTicket(String folio, String fecha, String estado, String subtotal, String impuestos, String total) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Formato de ticket de 80mm
        margin: const pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('JOBHUB', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('COMPROBANTE DE OPERACION', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              
              // Datos generales
              _buildPdfRow('Folio:', folio),
              _buildPdfRow('Fecha:', fecha),
              _buildPdfRow('Estado:', estado.toUpperCase()),
              
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              
              pw.Text('DETALLE DE IMPORTES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              
              // Desgloses
              _buildPdfRow('Subtotal:', '$subtotal MXN'),
              _buildPdfRow('Retenciones:', '-$impuestos MXN'),
              
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.solid),
              pw.SizedBox(height: 8),
              
              // Total
              _buildPdfRow('TOTAL NETO:', '$total MXN', isBold: true, size: 12),
              
              pw.SizedBox(height: 24),
              pw.Text('Este documento es un comprobante digital.', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
              pw.Text('jobhub.utptics.com', style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }

  // Fila auxiliar para el PDF
  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false, double size = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: size, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: size, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  // Lógica principal al dar click en "Ver Ticket"
  void _verFacturaTXT() async {
    if (_datos == null || _datos!['liquidacion'] == null) return;
    
    final folio = _datos!['factura']?['folio'] ?? _datos!['liquidacion']['folio_servicio'];
    final subtotal = formatoMoneda.format(double.parse(_datos!['liquidacion']['desgloses']['monto_bruto'].toString()));
    final impuestos = formatoMoneda.format(double.parse(_datos!['liquidacion']['desgloses']['impuestos'].toString()));
    final total = formatoMoneda.format(double.parse(_datos!['liquidacion']['monto'].toString()));
    final fecha = _datos!['factura']?['fecha'] ?? _datos!['liquidacion']['fecha'];
    final estado = _datos!['liquidacion']['estado'];

    // Texto embellecido para compartir por WhatsApp
    final String textoParaCompartir = """
🧾 *JOBHUB - COMPROBANTE* 🧾
━━━━━━━━━━━━━━━━━━━━
*Folio:* $folio
*Fecha:* $fecha
*Estado:* $estado

*DETALLE DE IMPORTES*
----------------------------------------
Subtotal:          $subtotal MXN
Retenciones:    -$impuestos MXN
━━━━━━━━━━━━━━━━━━━━
*TOTAL NETO:*  $total MXN
━━━━━━━━━━━━━━━━━━━━
""";

    // Mostramos la previsualización visual del ticket
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- CABECERA DEL TICKET ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE26112).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long, color: Color(0xFFE26112), size: 36),
              ),
              const SizedBox(height: 16),
              const Text('JOBHUB', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black87)),
              const Text('COMPROBANTE DE OPERACIÓN', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 32),
              
              // --- DATOS DEL TICKET ---
              _buildTicketRow('Folio', folio),
              const SizedBox(height: 12),
              _buildTicketRow('Fecha', fecha),
              const SizedBox(height: 12),
              _buildTicketRow('Estado', estado.toUpperCase(), valueColor: Colors.green),
              
              // --- LÍNEA PUNTEADA DIVISORIA ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -', 
                  maxLines: 1, 
                  overflow: TextOverflow.clip, 
                  style: TextStyle(color: Colors.grey.shade400)
                ),
              ),
              
              // --- IMPORTES ---
              _buildTicketRow('Subtotal', '$subtotal MXN'),
              const SizedBox(height: 12),
              _buildTicketRow('Retenciones', '-$impuestos MXN', valueColor: Colors.red),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(thickness: 1, height: 1),
              ),
              
              // --- TOTAL ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('$total MXN', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFE26112))),
                ],
              ),
              const SizedBox(height: 40),
              
              // --- BOTONES DE ACCIÓN FLOTANTES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón Compartir (Texto formateado para WhatsApp)
                  Column(
                    children: [
                      InkWell(
                        onTap: () => Share.share(textoParaCompartir, subject: 'Factura de Operación $folio'),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                          child: const Icon(Icons.share, color: Colors.black87, size: 24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Compartir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54))
                    ],
                  ),
                  const SizedBox(width: 40),
                  // Botón Imprimir (Genera el PDF real y lanza la impresora)
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          final pdf = await _generarPDFTicket(folio, fecha, estado, subtotal, impuestos, total);
                          await Printing.layoutPdf(
                            onLayout: (PdfPageFormat format) async => pdf.save(),
                            name: 'JobHub_Factura_$folio',
                          );
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(color: Color(0xFFE26112), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
                          child: const Icon(Icons.print, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Imprimir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE26112)))
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Cerrar
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Cerrar comprobante', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las filas del Ticket visual
  Widget _buildTicketRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Recibo de Operación', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
        : _datos == null || _datos!['liquidacion'] == null
            ? const Center(child: Text("Error al cargar los datos del servicio"))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: NetworkImage(_datos!['cliente']['avatar'] ?? ''),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_datos!['cliente']['nombre'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(_datos!['servicio']['titulo'] ?? 'Servicio', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Detalle de cobro', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(_datos!['liquidacion']['fecha'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          _buildReceiptRow('Monto Bruto Cobrado', formatoMoneda.format(double.parse(_datos!['liquidacion']['desgloses']['monto_bruto'].toString())), Colors.black87),
                          const SizedBox(height: 12),
                          _buildReceiptRow('Comisión Plataforma (10%)', '- ${formatoMoneda.format(double.parse(_datos!['liquidacion']['desgloses']['comision'].toString()))}', Colors.red),
                          const SizedBox(height: 12),
                          _buildReceiptRow('Impuestos Retenidos (16%)', '- ${formatoMoneda.format(double.parse(_datos!['liquidacion']['desgloses']['impuestos'].toString()))}', Colors.red),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(thickness: 1, height: 1),
                          ),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tu Ganancia Neta', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(formatoMoneda.format(double.parse(_datos!['liquidacion']['monto'].toString())), style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 30),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Folio Operativo', _datos!['liquidacion']['folio_servicio']),
                                const SizedBox(height: 12),
                                _buildInfoRow('Método de pago', _datos!['servicio']['metodo']),
                                const SizedBox(height: 12),
                                _buildInfoRow('Estado', _datos!['liquidacion']['estado']),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // BOTÓN PARA ABRIR EL COMPROBANTE
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _verFacturaTXT,
                              icon: const Icon(Icons.receipt, color: Color(0xFFE26112), size: 20),
                              label: const Text('VER TICKET DE OPERACIÓN', style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFE26112)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildReceiptRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
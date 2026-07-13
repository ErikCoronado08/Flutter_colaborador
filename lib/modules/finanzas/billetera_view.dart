import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; 
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart'; 
import 'package:flutter_svg/flutter_svg.dart'; 
import '../../services/finanzas_service.dart'; 

class BilleteraView extends StatefulWidget { 
  const BilleteraView({super.key});

  @override
  State<BilleteraView> createState() => _BilleteraViewState();
}

class _BilleteraViewState extends State<BilleteraView> {
  bool _isLoading = true; 
  double saldoDisponible = 0.0;
  double saldoTransito = 0.0;
  final FinanzasService _finanzasService = FinanzasService();

  @override
  void initState() {
    super.initState();
    _sincronizarDatos(); 
  }

  // Método modificado para que funcione perfectamente con el RefreshIndicator
  Future<void> _sincronizarDatos() async {
    try {
      final datos = await _finanzasService.obtenerSaldoUsuario();
      setState(() {
        saldoDisponible = double.parse(datos['saldoDisponible'].toString());
        saldoTransito = double.parse(datos['saldoTransito'].toString());
        _isLoading = false; 
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Color(0xFFE26112)), SizedBox(height: 20), Text('Conectando con Laravel...', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))]))
            // 1. AÑADIMOS EL REFRESH INDICATOR AQUÍ
            : RefreshIndicator(
                color: const Color(0xFFE26112),
                onRefresh: _sincronizarDatos, // Llama a la API al deslizar hacia abajo
                child: SingleChildScrollView(
                  // physics es obligatorio para que funcione el RefreshIndicator aunque la pantalla sea corta
                  physics: const AlwaysScrollableScrollPhysics(), 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // 1. TOP BAR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Text('JOB', style: TextStyle(color: Color(0xFFE26112), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)), Text('HUB', style: TextStyle(color: Color(0xFF4D2214), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2))]),
                                Text('CONECTANDO OPORTUNIDADES', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                              ],
                            ),
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]), child: const Icon(Icons.notifications_none_outlined, color: Color(0xFF4D2214), size: 26))
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 2. TARJETA PRINCIPAL
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: const Color(0xFFE26112), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFFE26112).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 6))]),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [const Text('Saldo disponible', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)), const SizedBox(width: 8), Icon(Icons.visibility_outlined, color: Colors.white.withOpacity(0.8), size: 18)]),
                                    const SizedBox(height: 10),
                                    AutoSizeText(formatoMoneda.format(saldoDisponible), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold), maxLines: 1, minFontSize: 18),
                                    const Text('MXN', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () => _mostrarModalRetiro(context),
                                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Text('Listo para retirar', style: TextStyle(color: Color(0xFFE26112), fontSize: 13, fontWeight: FontWeight.bold))),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(right: 24, top: 24, child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withOpacity(0.15), size: 44)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. TARJETA TRÁNSITO
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/historial_transito'),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                            child: Row(
                              children: [
                                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFBECE3), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.trending_up, color: Color(0xFFE26112), size: 24)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Dinero en tránsito', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Row(children: [Text(formatoMoneda.format(saldoTransito), style: const TextStyle(color: Color(0xFF4D2214), fontSize: 18, fontWeight: FontWeight.bold)), const Text(' MXN', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500))]),
                                      const SizedBox(height: 4),
                                      const Text('Historial de movimientos', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. GANANCIAS SEMANALES (GRAFICA)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ganancias semanales', style: TextStyle(color: Color(0xFF4D2214), fontSize: 15, fontWeight: FontWeight.bold)),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE26112), borderRadius: BorderRadius.circular(8)), child: const Text('+12%', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                                ],
                              ),
                              const SizedBox(height: 30),
                              SizedBox(height: 150, width: double.infinity, child: _buildGraficaGanancias()),
                              const SizedBox(height: 20),
                              Center(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/historial'), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE26112)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), minimumSize: const Size(double.infinity, 45)), child: const Text('Ver historial de servicios', style: TextStyle(color: Color(0xFFE26112))))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGraficaGanancias() {
    return BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: 100, barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipColor: (group) => const Color(0xFF4D2214), getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem('\$${rod.toY.round()}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
      const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
      String text; switch (value.toInt()) {case 0: text = 'Lun'; break; case 1: text = 'Mar'; break; case 2: text = 'Mié'; break; case 3: text = 'Jue'; break; case 4: text = 'Vie'; break; case 5: text = 'Sáb'; break; case 6: text = 'Dom'; break; default: text = ''; break;} return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
    })), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false), barGroups: [_crearBarra(0, 40, false), _crearBarra(1, 55, false), _crearBarra(2, 35, false), _crearBarra(3, 85, true), _crearBarra(4, 50, false), _crearBarra(5, 65, false), _crearBarra(6, 45, false)]));
  }

  BarChartGroupData _crearBarra(int x, double y, bool isHighlighted) {
    return BarChartGroupData(x: x, barRods: [BarChartRodData(toY: y, color: isHighlighted ? const Color(0xFFE26112) : const Color(0xFFFBECE3), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]);
  }

  void _mostrarModalRetiro(BuildContext context) {
    final TextEditingController montoController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              const Text('Retirar Ganancias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4D2214))),
              const SizedBox(height: 8),
              const Text('Ingresa el monto que deseas enviar a tu cuenta bancaria registrada.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto a retirar',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFE26112)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE26112), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFBECE3), borderRadius: BorderRadius.circular(8)),
                      child: SvgPicture.asset('assets/images/banco.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFFE26112), BlendMode.srcIn)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cuenta BBVA', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4D2214))), Text('**** **** 5432', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () async {
                    double? monto = double.tryParse(montoController.text);
                    if (monto != null) {
                      bool exito = await _finanzasService.solicitarRetiro(monto, 'cta_bbva_5432');
                      Navigator.pop(context); // Cierra el modal de retiro
                      
                      // Mostramos el mensaje de éxito o error
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exito ? 'Retiro exitoso de \$$monto' : 'Error al retirar'), backgroundColor: exito ? Colors.green : Colors.red));
                      
                      // 2. ACTUALIZACIÓN AUTOMÁTICA DEL SALDO
                      // Si el retiro se procesó correctamente en Laravel, actualizamos la vista
                      if (exito) {
                        _sincronizarDatos();
                      }
                    }
                  }, 
                  child: const Text('Confirmar Retiro', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
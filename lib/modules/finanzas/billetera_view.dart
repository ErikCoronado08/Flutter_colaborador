import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; 
import 'package:intl/intl.dart'; 
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
  List<dynamic> transaccionesRecientes = [];
  final FinanzasService _finanzasService = FinanzasService();

  @override
  void initState() {
    super.initState();
    _sincronizarDatos(); 
  }

  Future<void> _sincronizarDatos() async {
    setState(() => _isLoading = true);
    try {
      final datos = await _finanzasService.obtenerBilletera();
      setState(() {
        if (datos['perfil'] != null) {
          saldoDisponible = double.parse(datos['perfil']['saldo_disponible'].toString());
          saldoTransito = double.parse(datos['perfil']['dinero_en_transito'].toString());
        }
        transaccionesRecientes = datos['transacciones'] ?? [];
        _isLoading = false; 
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión con Billetera')));
    }
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
              const Text('Retirar Ganancias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              const Text('Ingresa el monto que deseas enviar a tu cuenta bancaria registrada.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              TextField(
                controller: montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto a retirar',
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFE26112)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE26112), width: 2)),
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
                      Navigator.pop(context); // Cerramos el modal primero
                      
                      bool exito = await _finanzasService.solicitarRetiro(monto);
                      if (mounted) {
                        if (exito) {
                          setState(() => saldoDisponible -= monto);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fondos retirados con éxito'), backgroundColor: Colors.green));
                          _sincronizarDatos();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al retirar o saldo insuficiente'), backgroundColor: Colors.red));
                        }
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

  @override
  Widget build(BuildContext context) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
            : RefreshIndicator(
                color: const Color(0xFFE26112),
                onRefresh: _sincronizarDatos,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Text('JOB', style: TextStyle(color: Color(0xFFE26112), fontSize: 22, fontWeight: FontWeight.bold)), Text('HUB', style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold))]),
                                Text('FINANZAS Y RETIROS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                              ],
                            ),
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]), child: const Icon(Icons.account_balance_wallet, color: Colors.black87, size: 24))
                          ],
                        ),
                        const SizedBox(height: 30),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFE26112), Color(0xFFD1510B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(24), 
                            boxShadow: [BoxShadow(color: const Color(0xFFE26112).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
                          ),
                          child: Stack(
                            children: [
                              Positioned(right: -20, top: -20, child: Icon(Icons.attach_money, color: Colors.white.withOpacity(0.1), size: 120)),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(children: [Text('Saldo disponible', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)), SizedBox(width: 8), Icon(Icons.check_circle, color: Colors.white70, size: 16)]),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Expanded(child: AutoSizeText(formatoMoneda.format(saldoDisponible), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold), maxLines: 1, minFontSize: 20)),
                                        const Padding(padding: EdgeInsets.only(bottom: 6, left: 8), child: Text('MXN', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    GestureDetector(
                                      onTap: () => _mostrarModalRetiro(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]), 
                                        child: const Text('Retirar fondos', style: TextStyle(color: Color(0xFFE26112), fontSize: 14, fontWeight: FontWeight.bold))
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.pending_actions, color: Color(0xFFE26112), size: 24)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Dinero en tránsito', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text('${formatoMoneda.format(saldoTransito)} MXN', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text('Movimientos recientes', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (transaccionesRecientes.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No hay movimientos recientes.', style: TextStyle(color: Colors.grey))))
                        else
                          ...transaccionesRecientes.take(5).map((trx) => _buildTransaccionItem(trx)).toList(),
                        
                        const SizedBox(height: 20),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/historial'),
                            icon: const Icon(Icons.history, color: Color(0xFFE26112), size: 20),
                            label: const Text(
                              'VER HISTORIAL COMPLETO', 
                              style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 15)
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFE26112).withOpacity(0.06),
                              side: const BorderSide(color: Color(0xFFE26112), width: 1.5), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                              padding: const EdgeInsets.symmetric(vertical: 16) 
                            ),
                          )
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // 💡 LÓGICA DE COLOR DE ESTADO APLICADA AQUÍ
  Widget _buildTransaccionItem(dynamic trx) {
    bool esRetiro = trx['tipo'] == 'retiro';
    String estado = trx['estado'] ?? 'Pendiente';
    bool esCompletada = estado.toLowerCase() == 'completada' || estado.toLowerCase() == 'liberado';
    
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    
    // Determinar colores según estado
    Color colorIcono = esRetiro ? Colors.red : (esCompletada ? Colors.green : Colors.orange);
    Color colorFondo = esRetiro ? Colors.red.shade50 : (esCompletada ? Colors.green.shade50 : Colors.orange.shade50);
    IconData icono = esRetiro ? Icons.arrow_upward : (esCompletada ? Icons.arrow_downward : Icons.pending_actions);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/liquidacion', arguments: {'id': trx['id'].toString()}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorFondo, 
              child: Icon(icono, color: colorIcono, size: 20)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trx['cliente'] ?? 'Movimiento', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(trx['fecha_transaccion'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorFondo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          estado.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colorIcono),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (esRetiro ? '-' : '+') + formatoMoneda.format(double.parse(trx['monto'].toString())),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorIcono),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text('Ver recibo', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Icon(Icons.chevron_right, size: 12, color: Colors.grey)
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
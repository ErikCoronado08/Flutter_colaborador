import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class Documents extends StatelessWidget {
  const Documents({super.key});

  Widget documentCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(color: const Color(0xFFFBECE3), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.description_outlined, color: Color(0xFFE26112), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF777777), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFE26112),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Subir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFE26112)),
                  label: const Text("Volver", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 90),
                    const SizedBox(height: 15),
                    const Text("CONECTANDO OPORTUNIDADES", style: TextStyle(color: Color(0xFFE26112), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    const Text("Paso 2 de 2", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Expediente de Seguridad y Documentación", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF111111), fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Por favor, carga los siguientes documentos", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF666666))),
                    const SizedBox(height: 25),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(value: 0.95, minHeight: 8, backgroundColor: Color(0xFFE5E5E5), color: Color(0xFFE26112)),
                    ),
                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBECE3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x33E26112)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.schedule, color: Color(0xFFE26112)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text("Tu expediente está siendo revisado por nuestro equipo.", style: TextStyle(color: Color(0xFF444444))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    documentCard("Identificación Oficial (INE)", "PDF o JPG"),
                    documentCard("Comprobante de domicilio", "PDF o JPG"),
                    documentCard("Foto de perfil", "JPG cuadrado"),
                    documentCard("Constancia de antecedentes no penales", "PDF o JPG"),
                    const SizedBox(height: 25),

                    CustomButton(
                      text: "ENVIAR EXPEDIENTE",
                      onTap: () {
                        // Simula el envío y regresa al login
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expediente enviado con éxito.')));
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
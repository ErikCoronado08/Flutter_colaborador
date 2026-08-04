import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CentroAyudaScreen extends StatefulWidget {
  const CentroAyudaScreen({super.key});

  @override
  State<CentroAyudaScreen> createState() => _CentroAyudaScreenState();
}

class _CentroAyudaScreenState extends State<CentroAyudaScreen> {
  bool _isLoading = true;
  List<dynamic> _faqs = [];
  List<dynamic> _faqsFiltradas = [];
  String _busqueda = '';
  String _categoriaSeleccionada = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarFAQs();
  }

  Future<void> _cargarFAQs() async {
    final datos = await ApiService.obtenerCentroAyuda();
    setState(() {
      _faqs = datos;
      _faqsFiltradas = datos;
      _isLoading = false;
    });
  }

  void _filtrarPreguntas() {
    setState(() {
      _faqsFiltradas = _faqs.where((faq) {
        final coincideCategoria = _categoriaSeleccionada == 'Todas' || faq['categoria'] == _categoriaSeleccionada;
        final coincideBusqueda = faq['titulo'].toString().toLowerCase().contains(_busqueda.toLowerCase()) || 
                                 faq['contenido'].toString().toLowerCase().contains(_busqueda.toLowerCase());
        return coincideCategoria && coincideBusqueda;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extraemos categorías únicas
    final categoriasSet = <String>{'Todas'};
    for (var faq in _faqs) {
      if (faq['categoria'] != null) categoriasSet.add(faq['categoria']);
    }
    final categoriasList = categoriasSet.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Centro de Ayuda', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : Column(
              children: [
                // BUSCADOR
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const Text('¿Cómo podemos ayudarte hoy?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (val) {
                          _busqueda = val;
                          _filtrarPreguntas();
                        },
                        decoration: InputDecoration(
                          hintText: 'Escribe tu duda aquí...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),

                // FILTROS (Categorías)
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: categoriasList.length,
                    itemBuilder: (context, index) {
                      final cat = categoriasList[index];
                      final isSelected = _categoriaSeleccionada == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: const Color(0xFFE26112),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? const Color(0xFFE26112) : Colors.grey.shade300),
                          onSelected: (bool selected) {
                            setState(() => _categoriaSeleccionada = cat);
                            _filtrarPreguntas();
                          },
                        ),
                      );
                    },
                  ),
                ),

                // LISTA DE ACORDEONES
                Expanded(
                  child: _faqsFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              const Text('No encontramos resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _faqsFiltradas.length,
                          itemBuilder: (context, index) {
                            final faq = _faqsFiltradas[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              // 💡 CORRECCIÓN APLICADA AQUÍ: side: BorderSide en lugar de border: Border.all
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16), 
                                side: BorderSide(color: Colors.grey.shade200)
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  title: Text(faq['titulo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                                  subtitle: Text(faq['categoria'] ?? '', style: const TextStyle(color: Color(0xFFE26112), fontSize: 11, fontWeight: FontWeight.bold)),
                                  childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                  children: [
                                    Text(faq['contenido'] ?? '', style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
                                  ],
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
}
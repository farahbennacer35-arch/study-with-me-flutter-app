import 'package:flutter/material.dart';
class SubjectColors {
  static const Color blue = Color(0xFF7777EE); // Bleu ciel principal
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color orange = Color(0xFFFF8800);
  static const Color purple = Color(0xFF9C27B0);
  static const Color teal = Color(0xFF009688);
  static const Color pink = Color(0xFFE91E63);
}

class AddEditSubjectPage extends StatefulWidget {
  final Color? color;

  const AddEditSubjectPage({super.key, this.color});

  @override
  State<AddEditSubjectPage> createState() => _AddEditSubjectPageState();
}

class _AddEditSubjectPageState extends State<AddEditSubjectPage> {
  static const Color primaryColor = Color(0xFF7777EE);
  
  Color? selectedColor;
  final nameController = TextEditingController();

  final List<Color> availableColors = [
    SubjectColors.blue,
    SubjectColors.red,
    SubjectColors.green,
    SubjectColors.yellow,
    SubjectColors.orange,
    SubjectColors.purple,
    SubjectColors.teal,
    SubjectColors.pink,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.color ?? SubjectColors.blue;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un nom de matière"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Sauvegarder la matière dans Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Matière sauvegardée !"),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter/Modifier matière',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la matière
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nom de la matière",
                hintText: "Ex: Mathématiques",
                prefixIcon: Icon(Icons.book, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Titre Section Couleur
            const Text(
              'Choisir une couleur',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Grille de couleurs
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableColors.map((color) {
                return _colorCircle(color);
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Aperçu couleur sélectionnée
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedColor?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedColor ?? primaryColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor?.withValues(alpha: 0.4) ?? Colors.transparent,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Couleur sélectionnée',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Bouton Sauvegarder
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Sauvegarder",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    final isSelected = selectedColor == color;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 30)
            : null,
      ),
    );
  }
}
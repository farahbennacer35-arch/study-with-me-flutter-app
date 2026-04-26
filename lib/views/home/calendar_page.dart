// lib/pages/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'day_details_page.dart'; // ✅ Import de la page détails

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

//models
class EventModel {
  final String id;
  final DateTime date;
  final String title;
  final String type;
  final String time;
  EventModel({
    required this.id,
    required this.date,
    required this.title,
    required this.type,
    required this.time,
  });
  // factory method bech tnajem tcreate objet
  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['date'] as Timestamp?;
    final date = ts?.toDate() ?? DateTime.now();
    return EventModel(
      id: doc.id,
      date: date,
      title: data['title'] ?? '',
      type: data['type'] ?? 'study',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'title': title,
    'type': type,
    'time': time,
  };
}

class SubjectModel {
  final String id;
  final String name;
  final int colorIndex;
  SubjectModel({
    required this.id,
    required this.name,
    required this.colorIndex,
  });
  factory SubjectModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      colorIndex: (data['colorIndex'] as int?) ?? 0,
    );
  }
  Map<String, dynamic> toMap() => {'name': name, 'colorIndex': colorIndex};
}

//state
class _CalendarPageState extends State<CalendarPage> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // Couleurs mt3 application
  static const Color primaryColor = Color(0xFF7777EE);
  static const List<Color> subjectColors = [
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.deepOrange,
    Colors.purple,
  ];
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  String? get _uid => _auth.currentUser?.uid;
  CollectionReference<Map<String, dynamic>> get _subjectsRef =>
      _fire.collection('users').doc(_uid).collection('subjects');
  CollectionReference<Map<String, dynamic>> get _eventsRef =>
      _fire.collection('users').doc(_uid).collection('events');
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  Map<DateTime, List<EventModel>> _groupEvents(List<EventModel> events) {
    //nrateb event 7asb nhar
    final map = <DateTime, List<EventModel>>{};
    for (final e in events) {
      //normalize date tna7ii wlwa9t w tjm3 3la nhar bark
      final k = _normalize(e.date);
      // map.putIfAbsent n9oso wa9t w n5aliw ken nhar
      map.putIfAbsent(k, () => []).add(e);
    }
    return map;
  }

  //hetha crud bech tzid w tn7i w t3adel
  Future<void> _addSubject(String name, int colorIndex) async {
    await _subjectsRef.add(
      SubjectModel(id: '', name: name, colorIndex: colorIndex).toMap(),
    );
  }

  //nfas555 objet
  Future<void> _deleteSubject(String id) async {
    final confirm = await _showDeleteConfirmation('cette matière');
    if (confirm != true) return;
    await _subjectsRef.doc(id).delete();
  }

  Future<void> _addEvent(
    DateTime day,
    String title,
    String type,
    TimeOfDay pickedTime,
  ) async {
    //tdmej date w time mta3 event
    final dateTime = DateTime(
      day.year,
      day.month,
      day.day,
      //picked t7wael se3a w d9aye9 l wa9t kamel (nas)
      pickedTime.hour,
      pickedTime.minute,
    );
    await _eventsRef.add({
      'date': Timestamp.fromDate(dateTime),
      'title': title,
      'type': type,
      'time': pickedTime.format(context),
    });
  }

  Future<void> _deleteEvent(String id) async {
    final confirm = await _showDeleteConfirmation('cet événement');
    if (confirm != true) return;

    await _eventsRef.doc(id).delete();
  }

  Future<bool?> _showDeleteConfirmation(String item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer $item ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSubjectDialog() async {
    final ctrl = TextEditingController();
    int selectedColor = 0;
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSt) {
          return AlertDialog(
            title: const Text('Nouvelle matière'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la matière',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choisir une couleur :',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(subjectColors.length, (i) {
                    final selected = i == selectedColor;
                    return GestureDetector(
                      onTap: () => setSt(() => selectedColor = i),
                      child: CircleAvatar(
                        backgroundColor: subjectColors[i],
                        radius: selected ? 22 : 18,
                        child: selected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final text = ctrl.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Le nom de la matière est requis'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  await _addSubject(text, selectedColor);

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Matière "$text" ajoutée !')),
                  );
                },
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddEventDialog(DateTime day) async {
    final titleCtrl = TextEditingController();
    String type = 'study';
    TimeOfDay pickedTime = TimeOfDay.now();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSt) {
          return AlertDialog(
            title: const Text('Nouvel événement'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Type d\'événement',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'study',
                        child: Row(
                          children: [
                            Icon(Icons.menu_book, size: 20),
                            SizedBox(width: 8),
                            Text('Révision'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'exam',
                        child: Row(
                          children: [
                            Icon(Icons.assignment, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('DS/Examen'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'presentation',
                        child: Row(
                          children: [
                            Icon(
                              Icons.present_to_all,
                              size: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text('Présentation'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (v) => setSt(() => type = v ?? 'study'),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: pickedTime,
                      );
                      if (t != null) setSt(() => pickedTime = t);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Heure',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        pickedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Le titre est requis'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  await _addEvent(day, title, type, pickedTime);

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Événement "$title" ajouté !')),
                  );
                },
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'exam':
        return Colors.red;
      case 'presentation':
        return Colors.orange;
      default:
        return primaryColor;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'exam':
        return Icons.assignment;
      case 'presentation':
        return Icons.present_to_all;
      default:
        return Icons.menu_book;
    }
  }

  //build
  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Connecte-toi pour voir ton calendrier')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Légende'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(
                        Icons.menu_book,
                        'Révision',
                        primaryColor,
                      ),
                      _buildLegendItem(
                        Icons.assignment,
                        'DS/Examen',
                        Colors.red,
                      ),
                      _buildLegendItem(
                        Icons.present_to_all,
                        'Présentation',
                        Colors.orange,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      //QuerYSnapshot FIH les events m3netha
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _eventsRef.orderBy('date').snapshots(),
        builder: (context, eventsSnap) {
          if (eventsSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventsSnap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${eventsSnap.error}'),
                ],
              ),
            );
          }

          final eventsList =
              eventsSnap.data?.docs
                  .map((d) => EventModel.fromDoc(d))
                  .toList() ??
              [];
          final grouped = _groupEvents(eventsList);

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _subjectsRef.snapshots(),
            builder: (context, subjectsSnap) {
              if (subjectsSnap.hasError) {
                return Center(child: Text('Erreur: ${subjectsSnap.error}'));
              }

              final subjectsList =
                  subjectsSnap.data?.docs
                      .map((d) => SubjectModel.fromDoc(d))
                      .toList() ??
                  [];

              return Column(
                children: [
                  // Calendrier
                  TableCalendar<EventModel>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    //hethi ena 7atitha bech tnajem tbadel format mta3 calendrier (week, month...)
                    calendarFormat: _calendarFormat,
                    // heth t3ml appel ki nbadel format
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    eventLoader: (day) => grouped[_normalize(day)] ?? [],
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                    ),
                  ),

                  // Boutons d'action
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showAddSubjectDialog,
                          icon: const Icon(Icons.book),
                          label: const Text('Nouvelle matière'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEventDialog(
                            _selectedDay ?? DateTime.now(),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Nouvel événement'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Liste des matières
                  if (subjectsList.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: subjectsList
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Chip(
                                  label: Text(
                                    s.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      subjectColors[s.colorIndex %
                                          subjectColors.length],
                                  onDeleted: () => _deleteSubject(s.id),
                                  deleteIconColor: Colors.white,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Liste des événements du jour sélectionné
                  Expanded(child: _buildEventsList(grouped)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventsList(Map<DateTime, List<EventModel>> grouped) {
    final events = grouped[_normalize(_selectedDay ?? DateTime.now())] ?? [];

    return Column(
      children: [
        //  Bouton pour voir les sessions du jour
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayDetailsPage(
                      selectedDate: _selectedDay ?? DateTime.now(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.view_day),
              label: const Text('Voir les sessions du jour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Liste des événements
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun événement pour ce jour',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            _showAddEventDialog(_selectedDay ?? DateTime.now()),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un événement'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final e = events[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _colorForType(
                            e.type,
                          ).withValues(alpha: 0.2),
                          child: Icon(
                            _iconForType(e.type),
                            color: _colorForType(e.type),
                          ),
                        ),
                        title: Text(
                          e.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Heure: ${e.time}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(e.id),
                          tooltip: 'Supprimer',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

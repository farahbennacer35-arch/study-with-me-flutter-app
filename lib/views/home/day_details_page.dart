// lib/pages/day_details_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class DayDetailsPage extends StatefulWidget {
  final DateTime selectedDate;

  const DayDetailsPage({super.key, required this.selectedDate});

  @override
  State<DayDetailsPage> createState() => _DayDetailsPageState();
}

/* -----------------------------
   MODELS
----------------------------- */
class SubjectSession {
  final String id;
  final String subjectId;
  final String subjectName;
  final int colorIndex;
  final int plannedMinutes;
  final int studiedMinutes;
  final bool completed;
  final DateTime date;

  SubjectSession({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.colorIndex,
    required this.plannedMinutes,
    required this.studiedMinutes,
    required this.completed,
    required this.date,
  });

  factory SubjectSession.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['date'] as Timestamp?;
    
    return SubjectSession(
      id: doc.id,
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      colorIndex: (data['colorIndex'] as int?) ?? 0,
      plannedMinutes: (data['plannedMinutes'] as int?) ?? 25,
      studiedMinutes: (data['studiedMinutes'] as int?) ?? 0,
      completed: data['completed'] ?? false,
      date: ts?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'colorIndex': colorIndex,
        'plannedMinutes': plannedMinutes,
        'studiedMinutes': studiedMinutes,
        'completed': completed,
        'date': Timestamp.fromDate(date),
      };

  String get status {
    if (studiedMinutes == 0) return 'not_started';
    if (studiedMinutes >= plannedMinutes) return 'success';
    if (studiedMinutes >= plannedMinutes * 0.7) return 'warning';
    return 'danger';
  }

  Color get statusColor {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'danger':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  String get statusEmoji {
    switch (status) {
      case 'success':
        return '🟩 Objectif atteint !';
      case 'warning':
        return '🟨 Presque !';
      case 'danger':
        return '🟥 Continue !';
      default:
        return '⏳ Pas encore commencé';
    }
  }

  double get progressPercent {
    if (plannedMinutes == 0) return 0;
    return (studiedMinutes / plannedMinutes).clamp(0.0, 1.0);
  }
}

/* -----------------------------
   STATE
----------------------------- */
class _DayDetailsPageState extends State<DayDetailsPage> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  static const Color primaryColor = Color(0xFF7777EE);
  static const List<Color> subjectColors = [
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.deepOrange,
    Colors.purple
  ];

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _fire.collection('users').doc(_uid).collection('sessions');

  CollectionReference<Map<String, dynamic>> get _subjectsRef =>
      _fire.collection('users').doc(_uid).collection('subjects');

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  /* -----------------------------
     CRUD OPERATIONS
  ----------------------------- */
  Future<void> _addSession(String subjectId, String subjectName, int colorIndex, int plannedMinutes) async {
    final session = SubjectSession(
      id: '',
      subjectId: subjectId,
      subjectName: subjectName,
      colorIndex: colorIndex,
      plannedMinutes: plannedMinutes,
      studiedMinutes: 0,
      completed: false,
      date: widget.selectedDate,
    );

    await _sessionsRef.add(session.toMap());
  }

  Future<void> _updateStudiedMinutes(String sessionId, int additionalMinutes) async {
    final doc = await _sessionsRef.doc(sessionId).get();
    if (!doc.exists) return;

    final session = SubjectSession.fromDoc(doc);
    final newStudied = session.studiedMinutes + additionalMinutes;
    final completed = newStudied >= session.plannedMinutes;

    await _sessionsRef.doc(sessionId).update({
      'studiedMinutes': newStudied,
      'completed': completed,
    });
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette session ?'),
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

    if (confirm == true) {
      await _sessionsRef.doc(sessionId).delete();
    }
  }

  /* -----------------------------
     UI DIALOGS
  ----------------------------- */
  Future<void> _showAddSessionDialog() async {
    if (!mounted) return;

    final subjectsSnapshot = await _subjectsRef.get();
    if (subjectsSnapshot.docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez d\'abord des matières dans le calendrier'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedSubjectId;
    String selectedSubjectName = '';
    int selectedColorIndex = 0;
    int plannedMinutes = 25;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSt) {
          return AlertDialog(
            title: const Text('Ajouter une session'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ CORRECTION: Utiliser value au lieu de initialValue
                  DropdownButtonFormField<String>(
                    value: selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Choisir une matière',
                      border: OutlineInputBorder(),
                    ),
                    items: subjectsSnapshot.docs.map((doc) {
                      final data = doc.data();
                      final name = data['name'] ?? '';
                      final colorIndex = (data['colorIndex'] as int?) ?? 0;
                      
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: subjectColors[colorIndex % subjectColors.length],
                              radius: 12,
                            ),
                            const SizedBox(width: 12),
                            Text(name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setSt(() {
                        selectedSubjectId = value;
                        final doc = subjectsSnapshot.docs.firstWhere((d) => d.id == value);
                        final data = doc.data();
                        selectedSubjectName = data['name'] ?? '';
                        selectedColorIndex = (data['colorIndex'] as int?) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Durée planifiée (minutes)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: '25'),
                    onChanged: (value) {
                      plannedMinutes = int.tryParse(value) ?? 25;
                    },
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
                  if (selectedSubjectId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sélectionnez une matière'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  await _addSession(
                    selectedSubjectId!,
                    selectedSubjectName,
                    selectedColorIndex,
                    plannedMinutes,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Session "$selectedSubjectName" ajoutée !'),
                    ),
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

  Future<void> _showPomodoroDialog(SubjectSession session) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PomodoroTimerPage(
          session: session,
          onComplete: (minutes) async {
            await _updateStudiedMinutes(session.id, minutes);
          },
        ),
      ),
    );
  }

  String _getMotivationalMessage(SubjectSession session) {
    if (session.studiedMinutes == 0) {
      return '💪 C\'est parti ! Lance ta première session.';
    } else if (session.status == 'success') {
      return '🎉 Excellent ! Tu as atteint ton objectif !';
    } else if (session.status == 'warning') {
      return '🔥 Encore un petit effort, tu y es presque !';
    } else {
      return '💪 Continue, chaque minute compte !';
    }
  }

  /* -----------------------------
     BUILD
  ----------------------------- */
  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Connecte-toi pour voir tes sessions')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sessions du ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
        ),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _sessionsRef
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(_normalize(widget.selectedDate)))
            .where('date',
                isLessThan: Timestamp.fromDate(_normalize(widget.selectedDate).add(const Duration(days: 1))))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                ],
              ),
            );
          }

          final sessions = snapshot.data?.docs
                  .map((d) => SubjectSession.fromDoc(d))
                  .toList() ??
              [];

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune session planifiée',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddSessionDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une session'),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  ),
                ],
              ),
            );
          }

          final totalPlanned = sessions.fold(0, (sum, s) => sum + s.plannedMinutes);
          final totalStudied = sessions.fold(0, (sum, s) => sum + s.studiedMinutes);
          final completedCount = sessions.where((s) => s.completed).length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('📚', '$completedCount/${sessions.length}', 'Complétées'),
                    _buildStatCard('⏱️', '$totalStudied min', 'Étudiées'),
                    _buildStatCard('🎯', '$totalPlanned min', 'Planifiées'),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _buildSessionCard(session);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSessionDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SubjectSession session) {
    final color = subjectColors[session.colorIndex % subjectColors.length];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: session.statusColor, width: 6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(Icons.book, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.subjectName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          session.statusEmoji,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSession(session.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: session.progressPercent,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(session.statusColor),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${session.studiedMinutes} / ${session.plannedMinutes} min',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(session.progressPercent * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: session.statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: session.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getMotivationalMessage(session),
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPomodoroDialog(session),
                  icon: const Icon(Icons.timer),
                  label: const Text('Lancer Pomodoro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -----------------------------
   POMODORO TIMER PAGE
----------------------------- */
class PomodoroTimerPage extends StatefulWidget {
  final SubjectSession session;
  final Function(int) onComplete;

  const PomodoroTimerPage({
    super.key,
    required this.session,
    required this.onComplete,
  });

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  static const int pomodoroMinutes = 25;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = pomodoroMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _completeSession() {
    _timer?.cancel();
    widget.onComplete(pomodoroMinutes);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Bravo !'),
        content: const Text('Tu as terminé ta session Pomodoro !'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = const [
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.indigo,
      Colors.deepOrange,
      Colors.purple
    ][widget.session.colorIndex % 7];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.subjectName),
        backgroundColor: color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.session.subjectName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: _remainingSeconds / (pomodoroMinutes * 60),
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Démarrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
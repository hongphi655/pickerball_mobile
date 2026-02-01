import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({Key? key}) : super(key: key);

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().getTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: Consumer2<TournamentProvider, AuthProvider>(
        builder: (context, tournamentProvider, authProvider, _) {
          // Check if auth failed
          if (tournamentProvider.errorMessage != null && 
              (tournamentProvider.errorMessage!.contains('401') || 
               !authProvider.isTokenValid)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Session hết hạn'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Đăng nhập lại'),
                  ),
                ],
              ),
            );
          }

          final isAdmin = authProvider.currentUser?.roles.contains('Admin') ?? false;
          if (tournamentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tournamentProvider.tournaments.isEmpty) {
            return const Center(child: Text('No tournaments available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tournamentProvider.tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournamentProvider.tournaments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tournament.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Format: ${tournament.format}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(tournament.status),
                            backgroundColor: tournament.status == 'Open'
                                ? Colors.green
                                : Colors.orange,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Entry Fee',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₫ ${tournament.entryFee.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prize Pool',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₫ ${tournament.prizePool.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Participants',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${tournament.participantCount}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${tournament.startDate.toString().substring(0, 10)} - ${tournament.endDate.toString().substring(0, 10)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (isAdmin)
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showEditDialog(context, tournament),
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('Confirm delete'),
                                        content: const Text('Delete this tournament?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      final ok = await context.read<TournamentProvider>().deleteTournament(tournament.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(ok ? 'Deleted' : (context.read<TournamentProvider>().errorMessage ?? 'Delete failed'))),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final ok = await context.read<TournamentProvider>().generateSchedule(tournament.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(ok ? 'Schedule generated' : (context.read<TournamentProvider>().errorMessage ?? 'Failed'))),
                                    );
                                  },
                                  child: const Text('Generate'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    await context.read<TournamentProvider>().getParticipants(tournament.id);
                                    final parts = context.read<TournamentProvider>().participants;
                                    showDialog(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('Participants'),
                                        content: SizedBox(
                                          width: 400,
                                          child: parts.isEmpty
                                              ? const Text('No participants')
                                              : SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: parts
                                                        .map((p) => ListTile(
                                                              title: Text(p.memberFullName ?? 'Member ${p.memberId}'),
                                                              subtitle: Text(p.teamName ?? ''),
                                                              trailing: Text(p.registeredDate.toString().substring(0, 10)),
                                                            ))
                                                        .toList(),
                                                  ),
                                                ),
                                        ),
                                        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
                                      ),
                                    );
                                  },
                                  child: const Text('Participants'),
                                ),
                              ],
                            )
                          else
                            if (tournament.status == 'Open')
                              ElevatedButton(
                                onPressed: () => _showJoinDialog(tournament.id),
                                child: const Text('Join'),
                              )
                            else
                              ElevatedButton(
                                onPressed: null,
                                child: const Text('Full'),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showJoinDialog(int tournamentId) {
    final teamNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Tournament'),
        content: TextField(
          controller: teamNameController,
          decoration: const InputDecoration(
            labelText: 'Team Name (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await context.read<TournamentProvider>().joinTournament(
                    tournamentId,
                    teamName: teamNameController.text.isEmpty
                        ? null
                        : teamNameController.text,
                  );

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Joined tournament successfully'),
                  ),
                );
              } else if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<TournamentProvider>().errorMessage ?? 'Join failed',
                    ),
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic tournament) {
    final nameController = TextEditingController(text: tournament.name);
    final entryFeeController = TextEditingController(text: tournament.entryFee.toStringAsFixed(0));
    final prizeController = TextEditingController(text: tournament.prizePool.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit Tournament'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: entryFeeController, decoration: const InputDecoration(labelText: 'Entry Fee'), keyboardType: TextInputType.number),
              TextField(controller: prizeController, decoration: const InputDecoration(labelText: 'Prize Pool'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final entry = double.tryParse(entryFeeController.text) ?? 0;
              final prize = double.tryParse(prizeController.text) ?? 0;
              // Use existing dates and format for quick edit
              final start = DateTime.parse(tournament.startDate);
              final end = DateTime.parse(tournament.endDate);
              final ok = await context.read<TournamentProvider>().updateTournament(tournament.id, name, start, end, tournament.format ?? 'Knockout', entry, prize);
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Updated' : (context.read<TournamentProvider>().errorMessage ?? 'Update failed'))));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

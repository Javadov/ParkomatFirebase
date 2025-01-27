import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/dashboard/dashboard_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => DashboardBloc(context.read())
          ..add(LoadDashboardData()),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grundläggande Statistik',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Statistics Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DashboardCard(
                          title: 'Aktiva Parkeringar',
                          value: '${state.activeParkingCount}',
                          icon: Icons.local_parking,
                          color: Colors.blueAccent,
                        ),
                        DashboardCard(
                          title: 'Parkeringsplatser',
                          value: '${state.totalParkingSpaces}',
                          icon: Icons.location_on,
                          color: Colors.orange,
                        ),
                        DashboardCard(
                          title: 'Total Inkomst',
                          value: '${state.totalIncome.toStringAsFixed(2)} kr',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Popular Parking Spaces Section
                    const Text(
                      'Populäraste Parkeringsplatserna',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: state.popularParkingSpaces.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Inga data tillgängliga.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: state.popularParkingSpaces.length,
                                  itemBuilder: (context, index) {
                                    final entry = state.popularParkingSpaces[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blueAccent,
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text('Plats-ID: ${entry.key}'),
                                      subtitle: Text('Antal bokningar: ${entry.value}'),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is DashboardError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 160,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
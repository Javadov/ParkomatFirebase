import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/parking/parking_bloc.dart';
// import 'package:parking_admin/blocs/parking/parking_event.dart';
// import 'package:parking_admin/blocs/parking/parking_state.dart';
import 'package:parking_admin/repositories/parking_repository.dart';
import 'package:parking_admin/utilities/license_plate.dart';
import 'package:parking_shared/models/parking.dart';


class ParkingsView extends StatelessWidget {
  const ParkingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ParkingBloc(parkingRepository: ParkingRepository())..add(LoadParkings()),
      child: const ParkingViewContent(),
    );
  }
}

class ParkingViewContent extends StatefulWidget {
  const ParkingViewContent({Key? key}) : super(key: key);

  @override
  State<ParkingViewContent> createState() => _ParkingViewContentState();
}

class _ParkingViewContentState extends State<ParkingViewContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'By ID';
  final List<String> _sortOptions = ['By ID', 'By Vehicle', 'By Start Date', 'By End Date'];
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Parkeringar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ParkingBloc, ParkingState>(
          builder: (context, state) {
            if (state is ParkingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParkingLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktiva Parkeringar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  state.activeParkings.isEmpty
                      ? const Text(
                          'Inga aktiva parkeringar just nu.',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Column(
                          children: state.activeParkings
                              .map((parking) => _buildParkingCard(context, parking, isActive: true))
                              .toList(),
                        ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historik',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(_showHistory ? Icons.expand_less : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            _showHistory = !_showHistory;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_showHistory) _buildHistorySection(context, state),
                ],
              );
            } else if (state is ParkingError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No parkings available.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, ParkingLoaded state) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Sök historik...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (query) {
                    context.read<ParkingBloc>().add(FilterParkings(query));
                  },
                ),
              ),
              const SizedBox(width: 10),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSort = value;
                      });
                      context.read<ParkingBloc>().add(SortParkings(value));
                    }
                  },
                  icon: const Icon(Icons.sort),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: state.filteredParkings.length,
              itemBuilder: (context, index) {
                final parking = state.filteredParkings[index];
                return _buildParkingCard(context, parking, isActive: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingCard(BuildContext context, Parking parking, {required bool isActive}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showParkingDetails(context, parking),
        child: ListTile(
          leading: LicensePlate(registrationNumber: parking.vehicleRegistrationNumber),
          title: Text('Plats: ${parking.parkingSpaceId}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Starttid: ${_formatTime(parking.startTime)}'),
              if (parking.endTime != null)
                Text('Sluttid: ${_formatTime(parking.endTime)}'),
            ],
          ),
          trailing: isActive
              ? ElevatedButton(
                  onPressed: () => _stopParking(context, parking),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stoppa'),
                )
              : null,
        ),
      ),
    );
  }

  void _showParkingDetails(BuildContext context, Parking parking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Parkering Detaljer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow('Plats-ID', parking.parkingSpaceId.toString()),
              _detailRow('Fordon', parking.vehicleRegistrationNumber),
              _detailRow('Starttid', _formatTime(parking.startTime)),
              _detailRow('Sluttid', _formatTime(parking.endTime)),
              _detailRow('Kostnad', '${parking.totalCost.toStringAsFixed(2)} kr'),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _stopParking(BuildContext context, Parking parking) {
    final now = DateTime.now();
    context.read<ParkingBloc>().add(StopParking(parking.id, now));
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Ej tillgänglig';
    return '${time.year}/${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
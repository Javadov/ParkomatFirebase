import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_admin/blocs/parking_space/parking_space_event.dart';
import 'package:parking_admin/blocs/parking_space/parking_space_state.dart';
import 'package:parking_shared/models/parking_space.dart';

class ParkingSpacesView extends StatelessWidget {
  const ParkingSpacesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParkingSpaceBloc(context.read())..add(LoadParkingSpaces()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parking Spaces'),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocConsumer<ParkingSpaceBloc, ParkingSpaceState>(
          listener: (context, state) {
            if (state is ParkingSpaceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            } else if (state is ParkingSpaceActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ParkingSpaceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ParkingSpaceLoaded) {
              return _buildParkingSpaceList(context, state.parkingSpaces);
            } else if (state is ParkingSpaceError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return const Center(child: Text('No parking spaces available.'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOrEditDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildParkingSpaceList(BuildContext context, List<ParkingSpace> spaces) {
    return ListView.builder(
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(space.address),
            subtitle: Text('Price: ${space.pricePerHour.toStringAsFixed(2)} kr/h'),
            onTap: () => _showParkingSpaceDetails(context, space),
          ),
        );
      },
    );
  }

  void _showParkingSpaceDetails(BuildContext context, ParkingSpace parkingSpace) {
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
              Text(
                parkingSpace.address,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('City: ${parkingSpace.city}'),
              Text('Zip Code: ${parkingSpace.zipCode}'),
              Text('Country: ${parkingSpace.country}'),
              Text('Position: (${parkingSpace.latitude}, ${parkingSpace.longitude})'),
              Text('Price: ${parkingSpace.pricePerHour.toStringAsFixed(2)} kr/h'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddOrEditDialog(context, parkingSpace),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.read<ParkingSpaceBloc>().add(DeleteParkingSpace(parkingSpace.id));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddOrEditDialog(BuildContext context, [ParkingSpace? parkingSpace]) {
    final addressController = TextEditingController(text: parkingSpace?.address);
    final cityController = TextEditingController(text: parkingSpace?.city);
    final zipCodeController = TextEditingController(text: parkingSpace?.zipCode);
    final countryController = TextEditingController(text: parkingSpace?.country);
    final latitudeController = TextEditingController(
      text: parkingSpace != null ? parkingSpace.latitude.toString() : '',
    );
    final longitudeController = TextEditingController(
      text: parkingSpace != null ? parkingSpace.longitude.toString() : '',
    );
    final priceController = TextEditingController(
      text: parkingSpace != null ? parkingSpace.pricePerHour.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(parkingSpace == null ? 'Add Parking Space' : 'Edit Parking Space'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                TextField(controller: zipCodeController, decoration: const InputDecoration(labelText: 'Zip Code')),
                TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
                TextField(controller: latitudeController, decoration: const InputDecoration(labelText: 'Latitude')),
                TextField(controller: longitudeController, decoration: const InputDecoration(labelText: 'Longitude')),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price Per Hour'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newSpace = ParkingSpace(
                  id: parkingSpace?.id ?? '',
                  address: addressController.text,
                  city: cityController.text,
                  zipCode: zipCodeController.text,
                  country: countryController.text,
                  latitude: double.tryParse(latitudeController.text) ?? 0.0,
                  longitude: double.tryParse(longitudeController.text) ?? 0.0,
                  pricePerHour: double.tryParse(priceController.text) ?? 0.0,
                );

                if (parkingSpace == null) {
                  context.read<ParkingSpaceBloc>().add(AddParkingSpace(newSpace));
                } else {
                  context.read<ParkingSpaceBloc>().add(UpdateParkingSpace(newSpace));
                }
                Navigator.pop(context);
              },
              child: Text(parkingSpace == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
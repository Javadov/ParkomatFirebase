import 'package:flutter/material.dart';
import 'package:parking_user/repositories/profile_repository.dart';
import 'package:parking_user/utilities/user_session.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final TextEditingController _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Laddar den aktuella e-posten från UserSession
    _emailController.text = UserSession().email ?? '';
  }

  Future<void> _saveEmail() async {
    final newEmail = _emailController.text.trim();
    final currentEmail = UserSession().email;

    if (newEmail.isEmpty || newEmail == currentEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inga ändringar att spara.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _profileRepository.updateUserEmail(currentEmail!, newEmail);
      if (success) {
        // Uppdatera sessionens e-post
        UserSession().email = newEmail;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posten har uppdaterats.')),
        );
        Navigator.pop(context); // Gå tillbaka till profilvyn
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Det gick inte att uppdatera e-posten.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ett fel inträffade: $e')),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personuppgifter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-post'),
            ),
            const SizedBox(height: 20),
            if (_isSaving)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveEmail,
                child: const Text('Spara'),
              ),
          ],
        ),
      ),
    );
  }
}
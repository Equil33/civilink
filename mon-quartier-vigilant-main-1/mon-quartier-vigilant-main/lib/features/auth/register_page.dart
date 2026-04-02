import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/provider/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nom = TextEditingController();
  final prenoms = TextEditingController();
  final idNumber = TextEditingController();
  final idExpiration = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  String idType = 'CNI';
  DateTime? idExpirationDate;
  String selectedQuartier = quartierNames.first;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void dispose() {
    nom.dispose();
    prenoms.dispose();
    idNumber.dispose();
    idExpiration.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final submitting = authProvider.isRegisteringCitizen;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inscription citoyen', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 10),
                    Text(
                      'Creez votre compte mobile pour envoyer et suivre vos signalements.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    _requiredField(controller: nom, label: 'Nom', icon: Icons.badge_outlined),
                    const SizedBox(height: 12),
                    _requiredField(controller: prenoms, label: 'Prenoms', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: idType,
                      items: const [
                        DropdownMenuItem(value: 'CNI', child: Text('CNI')),
                        DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                        DropdownMenuItem(value: 'Carte ANID', child: Text('Carte ANID')),
                        DropdownMenuItem(value: 'Electeur', child: Text('Electeur')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Type de piece',
                        prefixIcon: Icon(Icons.credit_card_rounded),
                      ),
                      onChanged: (value) => setState(() => idType = value ?? idType),
                    ),
                    const SizedBox(height: 12),
                    _requiredField(controller: idNumber, label: 'Numero de piece', icon: Icons.confirmation_number_outlined),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      controller: idExpiration,
                      decoration: const InputDecoration(
                        labelText: 'Date expiration piece',
                        prefixIcon: Icon(Icons.event_outlined),
                      ),
                      onTap: _selectExpirationDate,
                      validator: (_) {
                        if (idExpirationDate == null) return 'Date requise';
                        final now = DateTime.now();
                        if (idExpirationDate!.isBefore(DateTime(now.year, now.month, now.day))) {
                          return 'Piece expiree';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telephone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Telephone requis';
                        if (v.length < 8) return 'Telephone invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Email requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedQuartier,
                      items: quartierNames.map((quartier) => DropdownMenuItem(
                        value: quartier,
                        child: Text(quartier),
                      )).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Quartier',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      onChanged: (value) => setState(() => selectedQuartier = value ?? selectedQuartier),
                      validator: (value) => value == null || value.isEmpty ? 'Quartier requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hidePassword = !hidePassword),
                          icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Mot de passe requis';
                        if (v.length < 6) return 'Minimum 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPassword,
                      obscureText: hideConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmer mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hideConfirmPassword = !hideConfirmPassword),
                          icon: Icon(hideConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Confirmation requise';
                        if (v != password.text.trim()) return 'Mot de passe different';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Creer mon compte'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/connexion'),
                      child: const Text('Deja inscrit ? Se connecter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requiredField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) => (value == null || value.trim().isEmpty) ? '$label requis' : null,
    );
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
      initialDate: idExpirationDate ?? DateTime(now.year + 5),
    );

    if (picked == null) return;

    setState(() {
      idExpirationDate = picked;
      idExpiration.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isRegisteringCitizen) return;

    try {
      await authProvider.registerCitizen(
        nom: nom.text.trim(),
        prenoms: prenoms.text.trim(),
        idType: idType,
        idNumber: idNumber.text.trim(),
        idExpirationDate: _toIsoDate(idExpirationDate!),
        phone: phone.text.trim(),
        email: email.text.trim(),
        password: password.text.trim(),
        quartier: selectedQuartier,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/accueil', (route) => false);
      }
    } catch (error) {
      if (mounted) {
        final message = authProvider.error ?? error.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  String _toIsoDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

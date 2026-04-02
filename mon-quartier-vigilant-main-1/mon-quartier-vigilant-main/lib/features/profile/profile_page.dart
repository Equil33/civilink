import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/store/app_store.dart';
import '../../core/widgets/app_shell.dart';

class ProfilePage extends StatelessWidget {
  final AppStore store;

  const ProfilePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      store: store,
      title: 'Profil',
      currentIndex: 3,
      actions: [
        IconButton(
          tooltip: 'Deconnexion',
          onPressed: () async {
            await store.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      body: ListView(
        padding: context.pagePadding,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      _initials(store.userName),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.userName, style: Theme.of(context).textTheme.titleMedium),
                        Text(_roleLabel(store.role)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informations', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _InfoLine(label: 'Nom et prenom', value: store.userName),
                  _InfoLine(
                    label: 'Email',
                    value: store.isCitizen && store.hasCitizenProfile
                        ? (store.citizenProfile['email'] ?? '-')
                        : '-',
                  ),
                  _InfoLine(label: 'Role', value: _roleLabel(store.role)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parametres', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _LanguageSetting(store: store),
                  const SizedBox(height: 12),
                  _ThemeSetting(store: store),
                  const SizedBox(height: 12),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  _ContactCard(context: context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'CL';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _roleLabel(String role) {
    return switch (role) {
      'citoyen' => 'Citoyen',
      'guest' => 'Invite',
      _ => 'Utilisateur',
    };
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 170, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSetting extends StatelessWidget {
  final AppStore store;

  const _LanguageSetting({required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Langue',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Choisir votre langue préférée',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: store.language,
          items: const [
            DropdownMenuItem(value: 'fr', child: Text('Français')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) async {
            if (value != null) {
              await store.changeLanguage(value);
            }
          },
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final BuildContext context;

  const _ContactCard({required this.context});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/contacts'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nous contacter',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accéder à nos coordonnées et FAQs',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ThemeSetting extends StatelessWidget {
  final AppStore store;

  const _ThemeSetting({required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Mode clair ou sombre',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: store.themeMode,
          items: const [
            DropdownMenuItem(value: 'light', child: Text('Clair')),
            DropdownMenuItem(value: 'dark', child: Text('Sombre')),
            DropdownMenuItem(value: 'system', child: Text('Système')),
          ],
          onChanged: (value) async {
            if (value != null) {
              await store.changeThemeMode(value);
            }
          },
        ),
      ],
    );
  }
}

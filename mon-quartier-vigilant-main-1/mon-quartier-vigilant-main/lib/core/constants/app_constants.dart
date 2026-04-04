const categories = {
  'route': 'Route',
  'eclairage': 'Eclairage',
  'inondation': 'Inondation',
  'incendie': 'Incendie',
  'accident_circulation': 'Accident de circulation',
  'dechets': 'Dechets',
  'autre': 'Autre',
};

const categoryImageUrls = {
  'route': 'assets/images/theme/road_pothole.jpg',
  'eclairage': 'assets/images/theme/street_light.jpg',
  'inondation': 'assets/images/theme/flood_1.jpg',
  'incendie': 'assets/images/theme/fire_1.jpg',
  'accident_circulation': 'assets/images/theme/accident_1.jpg',
  'dechets': 'assets/images/theme/waste_1.jpg',
  'autre': 'assets/images/theme/other_urban.jpg',
};

// Communes avec leurs quartiers
const communes = {
  'Golfe 1': [
    'Baguida',
    'Kpogan',
    'Bè-Est',
    'Bè-Apéyémé',
    'Akodessewa',
    'Ablogamé',
    'Bè-Kpota',
    'Kagome',
    'Adamavo',
    'Avépozo',
  ],
  'Golfe 2': [
    'Tokoin Wuiti',
    'Tokoin Tamé',
    'Tokoin Enyonam',
    'Hédzranawoé (1 et 2)',
    'Hedzranawoé 2',
    'Bè-Hédzranawoé',
    'Tokoin Aviation',
    'Kégué',
    'Atiégouvi',
    'Aéroport',
    'Attikpa',
  ],
  'Golfe 3': [
    'Tokoin Elavagnon',
    'Gbonvié',
    'Doumasséssé (Adewi)',
    'Doumasséssé',
    'Cité OUA',
    'Lomé II',
    'Kélégouvi',
    'Hanoukopé',
    'Tokoin-Ouest',
    'Agbalépédogan',
    'Gbadago',
  ],
  'Golfe 4': [
    'Dékon',
    'Hanoukopé',
    'Bassadji',
    "N'tifafa-komé",
    'Aguiakomé',
    'Assivito',
    'Kodjoviakopé',
    'Amoutiévé',
    'Nyékonakpoé',
    'Octaviano Netimé',
    'Xwlacome',
  ],
  'Golfe 5': [
    'Adidogomé',
    'Sagbado',
    'Akossombo',
    'Totsi',
    'Gakli',
    'Djidjolé',
    'Aflao',
    'Agotimé',
    'Soviépé',
    'Nkafu',
  ],
  'Golfe 6': ['Baguida', 'Avépozo', 'Devego', 'Boboloè', 'Togblékopé'],
  'Golfe 7': ['Baguida', 'Togblékopé', 'Sagbado', 'Klémé', 'Shishee', 'Wonyomée', 'Awatame', 'Akato'],
  'Agoè-Nyivé 1': [
    'Agoè-nyivé',
    'Agbalépédogan',
    'Attikoumè',
    'Avédji',
    'Agoè-Assiyéyé',
    'Agoè-Cacavéli',
    'Agoè-Nyivé',
    'Fidokpui',
    'Télessou',
  ],
  'Agoè-Nyivé 5': [
    'Sanguéra',
    'Klikamé',
    'Kohé',
    'Togblékopé',
    'Zossimé',
    'Dékpor',
    'Afiadényigban',
    'Anyronkopé',
    'Gbamakopé',
  ],
  'Adétikopé': ['Adétikopé', 'Fidokpui (nord)', 'Kpogan'],
  'Vakpossito': ['Vakpossito', 'Kleve', 'Amandahome'],
  'Légbassito': ['Légbassito', 'Sogbossito', 'Madjikpé'],
};

// Types d'institutions
const institutionTypes = ['mairie', 'police', 'gendarmerie', 'pompiers', 'hopital', 'clinique', 'voirie'];

// Mapping catÃ©gorie -> types d'institutions
const categoryToInstitutionTypes = {
  'route': ['mairie', 'police', 'gendarmerie', 'pompiers'],
  'eclairage': ['mairie', 'police'],
  'inondation': ['mairie', 'pompiers', 'hopital', 'clinique'],
  'incendie': ['mairie', 'pompiers', 'hopital', 'clinique'],
  'accident_circulation': ['mairie', 'police', 'gendarmerie', 'pompiers', 'hopital', 'clinique'],
  'dechets': ['mairie', 'voirie'],
  'autre': ['mairie'],
};

// Institutions par commune
const communesInstitutions = {
  'Golfe 1': {
    'mairie': 'Mairie de Golfe 1',
    'police': 'Police de Golfe 1',
    'gendarmerie': 'Gendarmerie de Golfe 1',
    'pompiers': 'Sapeurs-Pompiers de Golfe 1',
    'hopital': 'Hopital de Golfe 1',
    'clinique': 'Clinique de Golfe 1',
    'voirie': 'Voirie de Golfe 1',
  },
  'Golfe 2': {
    'mairie': 'Mairie de Golfe 2',
    'police': 'Police de Golfe 2',
    'gendarmerie': 'Gendarmerie de Golfe 2',
    'pompiers': 'Sapeurs-Pompiers de Golfe 2',
    'hopital': 'Hopital de Golfe 2',
    'clinique': 'Clinique de Golfe 2',
    'voirie': 'Voirie de Golfe 2',
  },
  'Golfe 3': {
    'mairie': 'Mairie de Golfe 3',
    'police': 'Police de Golfe 3',
    'gendarmerie': 'Gendarmerie de Golfe 3',
    'pompiers': 'Sapeurs-Pompiers de Golfe 3',
    'hopital': 'Hopital de Golfe 3',
    'clinique': 'Clinique de Golfe 3',
    'voirie': 'Voirie de Golfe 3',
  },
  'Golfe 4': {
    'mairie': 'Mairie de Golfe 4',
    'police': 'Police de Golfe 4',
    'gendarmerie': 'Gendarmerie de Golfe 4',
    'pompiers': 'Sapeurs-Pompiers de Golfe 4',
    'hopital': 'Hopital de Golfe 4',
    'clinique': 'Clinique de Golfe 4',
    'voirie': 'Voirie de Golfe 4',
  },
  'Golfe 5': {
    'mairie': 'Mairie de Golfe 5',
    'police': 'Police de Golfe 5',
    'gendarmerie': 'Gendarmerie de Golfe 5',
    'pompiers': 'Sapeurs-Pompiers de Golfe 5',
    'hopital': 'Hopital de Golfe 5',
    'clinique': 'Clinique de Golfe 5',
    'voirie': 'Voirie de Golfe 5',
  },
  'Golfe 6': {
    'mairie': 'Mairie de Golfe 6',
    'police': 'Police de Golfe 6',
    'gendarmerie': 'Gendarmerie de Golfe 6',
    'pompiers': 'Sapeurs-Pompiers de Golfe 6',
    'hopital': 'Hopital de Golfe 6',
    'clinique': 'Clinique de Golfe 6',
    'voirie': 'Voirie de Golfe 6',
  },
  'Golfe 7': {
    'mairie': 'Mairie de Golfe 7',
    'police': 'Police de Golfe 7',
    'gendarmerie': 'Gendarmerie de Golfe 7',
    'pompiers': 'Sapeurs-Pompiers de Golfe 7',
    'hopital': 'Hopital de Golfe 7',
    'clinique': 'Clinique de Golfe 7',
    'voirie': 'Voirie de Golfe 7',
  },
  'Agoè-Nyivé 1': {
    'mairie': 'Mairie de Agoè-Nyivé 1',
    'police': 'Police de Agoè-Nyivé 1',
    'gendarmerie': 'Gendarmerie de Agoè-Nyivé 1',
    'pompiers': 'Sapeurs-Pompiers de Agoè-Nyivé 1',
    'hopital': 'Hopital de Agoè-Nyivé 1',
    'clinique': 'Clinique de Agoè-Nyivé 1',
    'voirie': 'Voirie de Agoè-Nyivé 1',
  },
  'Agoè-Nyivé 5': {
    'mairie': 'Mairie de Agoè-Nyivé 5',
    'police': 'Police de Agoè-Nyivé 5',
    'gendarmerie': 'Gendarmerie de Agoè-Nyivé 5',
    'pompiers': 'Sapeurs-Pompiers de Agoè-Nyivé 5',
    'hopital': 'Hopital de Agoè-Nyivé 5',
    'clinique': 'Clinique de Agoè-Nyivé 5',
    'voirie': 'Voirie de Agoè-Nyivé 5',
  },
  'Adétikopé': {
    'mairie': 'Mairie de Adétikopé',
    'police': 'Police de Adétikopé',
    'gendarmerie': 'Gendarmerie de Adétikopé',
    'pompiers': 'Sapeurs-Pompiers de Adétikopé',
    'hopital': 'Hopital de Adétikopé',
    'clinique': 'Clinique de Adétikopé',
    'voirie': 'Voirie de Adétikopé',
  },
  'Vakpossito': {
    'mairie': 'Mairie de Vakpossito',
    'police': 'Police de Vakpossito',
    'gendarmerie': 'Gendarmerie de Vakpossito',
    'pompiers': 'Sapeurs-Pompiers de Vakpossito',
    'hopital': 'Hopital de Vakpossito',
    'clinique': 'Clinique de Vakpossito',
    'voirie': 'Voirie de Vakpossito',
  },
  'Légbassito': {
    'mairie': 'Mairie de Légbassito',
    'police': 'Police de Légbassito',
    'gendarmerie': 'Gendarmerie de Légbassito',
    'pompiers': 'Sapeurs-Pompiers de Légbassito',
    'hopital': 'Hopital de Légbassito',
    'clinique': 'Clinique de Légbassito',
    'voirie': 'Voirie de Légbassito',
  },
};

String _normalizeQuartierKey(String value) {
  var normalized = value.trim();
  final parts = normalized.split(' - ');
  if (parts.length > 1) {
    normalized = parts.sublist(1).join(' - ');
  }
  normalized = normalized.toLowerCase();
  normalized = normalized.replaceAll(RegExp(r"['â€™]"), ' ');
  normalized = normalized.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized;
}

// Fonction pour obtenir la commune d'un quartier
String? getCommuneFromQuartier(String quartier) {
  final target = _normalizeQuartierKey(quartier);
  for (final entry in communes.entries) {
    for (final q in entry.value) {
      if (_normalizeQuartierKey(q) == target) {
        return entry.key;
      }
    }
  }
  return null;
}

// Fonction pour obtenir les institutions pour un signalement
List<String> getNearbyOrganisations(String quartier, String category) {
  final commune = getCommuneFromQuartier(quartier);
  if (commune == null) return [];

  final institutions = communesInstitutions[commune] ?? const <String, String>{};
  final institutionTypesForCategory = categoryToInstitutionTypes[category] ?? const <String>[];
  final results = <String>{};

  final mairie = institutions['mairie'];
  if (mairie != null && mairie.trim().isNotEmpty) {
    results.add(mairie);
  } else {
    results.add('Mairie de $commune');
  }

  for (final type in institutionTypesForCategory) {
    final name = institutions[type];
    if (name != null && name.trim().isNotEmpty) {
      results.add(name);
    }
  }

  return results.toList();
}

const quartierNames = [
  'Baguida',
  'Kpogan',
  'Bè-Est',
  'Bè-Apéyémé',
  'Akodessewa',
  'Ablogamé',
  'Bè-Kpota',
  'Kagome',
  'Adamavo',
  'Avépozo',
  'Tokoin Wuiti',
  'Tokoin Tamé',
  'Tokoin Enyonam',
  'Hédzranawoé (1 et 2)',
  'Hedzranawoé 2',
  'Bè-Hédzranawoé',
  'Tokoin Aviation',
  'Kégué',
  'Atiégouvi',
  'Aéroport',
  'Attikpa',
  'Tokoin Elavagnon',
  'Gbonvié',
  'Doumasséssé (Adewi)',
  'Doumasséssé',
  'Cité OUA',
  'Lomé II',
  'Kélégouvi',
  'Hanoukopé',
  'Tokoin-Ouest',
  'Agbalépédogan',
  'Gbadago',
  'Dékon',
  'Bassadji',
  "N'tifafa-komé",
  'Aguiakomé',
  'Assivito',
  'Kodjoviakopé',
  'Amoutiévé',
  'Nyékonakpoé',
  'Octaviano Netimé',
  'Xwlacome',
  'Adidogomé',
  'Sagbado',
  'Akossombo',
  'Totsi',
  'Gakli',
  'Djidjolé',
  'Aflao',
  'Agotimé',
  'Soviépé',
  'Nkafu',
  'Devego',
  'Boboloè',
  'Togblékopé',
  'Klémé',
  'Shishee',
  'Wonyomée',
  'Awatame',
  'Akato',
  'Agoè-nyivé',
  'Attikoumè',
  'Avédji',
  'Agoè-Assiyéyé',
  'Agoè-Cacavéli',
  'Agoè-Nyivé',
  'Fidokpui',
  'Télessou',
  'Sanguéra',
  'Klikamé',
  'Kohé',
  'Zossimé',
  'Dékpor',
  'Afiadényigban',
  'Anyronkopé',
  'Gbamakopé',
  'Adétikopé',
  'Fidokpui (nord)',
  'Vakpossito',
  'Kleve',
  'Amandahome',
  'Légbassito',
  'Sogbossito',
  'Madjikpé',
];

const organisationIncidentScopes = {
  'Mairie': ['route', 'eclairage', 'inondation', 'autre'],
  'Police': ['route', 'accident_circulation', 'autre'],
  'Pompiers': ['inondation', 'incendie', 'autre'],
  'Hopital': ['accident_circulation', 'inondation', 'autre'],
  'Clinique': ['accident_circulation', 'inondation', 'autre'],
  'Gendarmerie': ['route', 'accident_circulation', 'autre'],
  'Lavoirie': ['dechets'],
};

const categoryOrganisationTypes = {
  'route': ['mairie', 'police', 'gendarmerie'],
  'eclairage': ['mairie'],
  'inondation': ['mairie', 'pompiers', 'hopital', 'clinique'],
  'incendie': ['pompiers'],
  'accident_circulation': ['hopital', 'clinique', 'police', 'gendarmerie'],
  'dechets': ['mairie', 'lavoirie'],
  'autre': [
    'mairie',
    'police',
    'gendarmerie',
    'pompiers',
    'hopital',
    'clinique',
    'lavoirie',
  ],
};

const organisationTypeLabels = {
  'mairie': 'Mairie',
  'police': 'Police',
  'pompiers': 'Pompiers',
  'hopital': 'Hopital',
  'clinique': 'Clinique',
  'gendarmerie': 'Gendarmerie',
  'lavoirie': 'Lavoirie',
};

const togoOrganisations = <Map<String, String>>[
  {'name': 'Mairie de Lome Golfe 1', 'type': 'mairie', 'localite': 'Lome - Adidogome', 'phone': '+228 22 20 11 11', 'green': '8200'},
  {'name': 'Commissariat Adidogome', 'type': 'police', 'localite': 'Lome - Adidogome', 'phone': '+228 22 25 10 10', 'green': '117'},
  {'name': 'Gendarmerie Agoe', 'type': 'gendarmerie', 'localite': 'Lome - Agoe', 'phone': '+228 22 51 20 20', 'green': '172'},
  {'name': 'CHU Sylvanus Olympio', 'type': 'hopital', 'localite': 'Lome - Tokoin', 'phone': '+228 22 20 08 80', 'green': '8202'},
  {'name': 'Clinique Esperance Tokoin', 'type': 'clinique', 'localite': 'Lome - Tokoin', 'phone': '+228 90 10 20 30', 'green': '8202'},
  {'name': 'Caserne Sapeurs Pompiers Lome', 'type': 'pompiers', 'localite': 'Lome - Be', 'phone': '+228 22 21 33 33', 'green': '118'},
  {'name': 'Mairie de Golfe 6', 'type': 'mairie', 'localite': 'Lome - Baguida', 'phone': '+228 22 23 44 44', 'green': '8200'},
  {'name': 'Commissariat Baguida', 'type': 'police', 'localite': 'Lome - Baguida', 'phone': '+228 22 27 77 77', 'green': '117'},
  {'name': 'Mairie d Agoe-Nyive', 'type': 'mairie', 'localite': 'Lome - Agoe', 'phone': '+228 22 50 66 66', 'green': '8200'},
  {'name': 'Clinique Saint Joseph', 'type': 'clinique', 'localite': 'Lome - Hedzranawoe', 'phone': '+228 91 45 67 89', 'green': '8202'},
  {'name': 'Mairie de Kara', 'type': 'mairie', 'localite': 'Kara - Tomde', 'phone': '+228 26 60 11 11', 'green': '8200'},
  {'name': 'Commissariat Kara', 'type': 'police', 'localite': 'Kara - Tomde', 'phone': '+228 26 60 20 20', 'green': '117'},
  {'name': 'CHR Kara Tomde', 'type': 'hopital', 'localite': 'Kara - Tomde', 'phone': '+228 26 61 30 30', 'green': '8202'},
  {'name': 'Caserne Pompiers Kara', 'type': 'pompiers', 'localite': 'Kara - Tchitchao', 'phone': '+228 26 61 44 44', 'green': '118'},
  {'name': 'Brigade Gendarmerie Kara', 'type': 'gendarmerie', 'localite': 'Kara - Dongoyo', 'phone': '+228 26 61 55 55', 'green': '172'},
  {'name': 'Mairie de Sokode', 'type': 'mairie', 'localite': 'Sokode - Komah', 'phone': '+228 25 50 11 22', 'green': '8200'},
  {'name': 'Commissariat Sokode', 'type': 'police', 'localite': 'Sokode - Kpangalam', 'phone': '+228 25 50 23 23', 'green': '117'},
  {'name': 'CHR Sokode', 'type': 'hopital', 'localite': 'Sokode - Komah', 'phone': '+228 25 50 33 33', 'green': '8202'},
  {'name': 'Mairie d Atakpame', 'type': 'mairie', 'localite': 'Atakpame - Agbonou', 'phone': '+228 24 40 10 10', 'green': '8200'},
  {'name': 'Commissariat Atakpame', 'type': 'police', 'localite': 'Atakpame - Kpessi', 'phone': '+228 24 40 20 20', 'green': '117'},
  {'name': 'Hopital Regional Atakpame', 'type': 'hopital', 'localite': 'Atakpame - Gadzape', 'phone': '+228 24 40 30 30', 'green': '8202'},
  {'name': 'Mairie de Dapaong', 'type': 'mairie', 'localite': 'Dapaong - Nassable', 'phone': '+228 27 70 11 11', 'green': '8200'},
  {'name': 'Commissariat Dapaong', 'type': 'police', 'localite': 'Dapaong - Cinkasse', 'phone': '+228 27 70 20 20', 'green': '117'},
  {'name': 'Hopital de Dapaong', 'type': 'hopital', 'localite': 'Dapaong - Nano', 'phone': '+228 27 70 30 30', 'green': '8202'},
  {'name': 'Brigade Gendarmerie Dapaong', 'type': 'gendarmerie', 'localite': 'Dapaong - Cinkasse', 'phone': '+228 27 70 40 40', 'green': '172'},
  {'name': 'Mairie de Tsevie', 'type': 'mairie', 'localite': 'Tsevie - Davie', 'phone': '+228 23 30 11 11', 'green': '8200'},
  {'name': 'Commissariat Tsevie', 'type': 'police', 'localite': 'Tsevie - Mission-Tove', 'phone': '+228 23 30 22 22', 'green': '117'},
  {'name': 'Mairie d Aneho', 'type': 'mairie', 'localite': 'Aneho - Glidji', 'phone': '+228 23 31 11 11', 'green': '8200'},
  {'name': 'Commissariat Aneho', 'type': 'police', 'localite': 'Aneho - Zebe', 'phone': '+228 23 31 22 22', 'green': '117'},
  {'name': 'Mairie de Kpalime', 'type': 'mairie', 'localite': 'Kpalime - Nyive', 'phone': '+228 24 45 11 11', 'green': '8200'},
  {'name': 'Hopital de Kpalime', 'type': 'hopital', 'localite': 'Kpalime - Agou', 'phone': '+228 24 45 33 33', 'green': '8202'},
  {'name': 'Mairie de Mango', 'type': 'mairie', 'localite': 'Mango - Oti', 'phone': '+228 27 71 11 11', 'green': '8200'},
  {'name': 'Brigade Gendarmerie Mango', 'type': 'gendarmerie', 'localite': 'Mango - Oti', 'phone': '+228 27 71 22 22', 'green': '172'},
  {'name': 'Poste Sante Togoville', 'type': 'clinique', 'localite': 'Village de Togoville', 'phone': '+228 93 10 11 12', 'green': '8202'},
  {'name': 'Poste Sante Agbodrafo', 'type': 'clinique', 'localite': 'Village d Agbodrafo', 'phone': '+228 93 40 11 12', 'green': '8202'},
  {'name': 'Lavoirie Municipale Lome', 'type': 'lavoirie', 'localite': 'Lome - Akodessewa', 'phone': '+228 22 28 90 90', 'green': '8280'},
  {'name': 'Lavoirie Municipale Kara', 'type': 'lavoirie', 'localite': 'Kara - Tomde', 'phone': '+228 26 62 90 90', 'green': '8280'},
  {'name': 'Lavoirie Municipale Sokode', 'type': 'lavoirie', 'localite': 'Sokode - Komah', 'phone': '+228 25 50 88 88', 'green': '8280'},
  {'name': 'Lavoirie Municipale Atakpame', 'type': 'lavoirie', 'localite': 'Atakpame - Agbonou', 'phone': '+228 24 40 88 88', 'green': '8280'},
  {'name': 'Lavoirie Municipale Dapaong', 'type': 'lavoirie', 'localite': 'Dapaong - Nassable', 'phone': '+228 27 70 88 88', 'green': '8280'},
];

String normalizeOrganisationName(String rawName) {
  if (rawName == 'Sapeurs-Pompiers') return 'Pompiers';
  if (rawName == 'Commissariat') return 'Police';
  return rawName;
}

String labelForOrganisationType(String type) {
  return organisationTypeLabels[type] ?? type;
}

String inferOrganisationTypeFromName(String organisationName) {
  final lowered = organisationName.toLowerCase();
  final matched = togoOrganisations.where(
    (entry) => (entry['name'] ?? '').toLowerCase() == lowered,
  );
  if (matched.isNotEmpty) {
    return matched.first['type'] ?? 'mairie';
  }
  if (lowered.contains('gendarmerie')) return 'gendarmerie';
  if (lowered.contains('police') || lowered.contains('commissariat')) return 'police';
  if (lowered.contains('pompiers')) return 'pompiers';
  if (lowered.contains('hopital') || lowered.contains('chu') || lowered.contains('chr')) {
    return 'hopital';
  }
  if (lowered.contains('clinique')) return 'clinique';
  if (lowered.contains('lavoirie')) return 'lavoirie';
  return 'mairie';
}

List<Map<String, String>> organisationsByLocalite(String localite) {
  return togoOrganisations
      .where((entry) => entry['localite'] == localite)
      .toList();
}

List<Map<String, String>> nearbyOrganisationsForIncident({
  required String localite,
  required String category,
}) {
  final allowedTypes = categoryOrganisationTypes[category] ?? const <String>[];
  return togoOrganisations.where((entry) {
    return entry['localite'] == localite && allowedTypes.contains(entry['type']);
  }).toList();
}

List<Map<String, String>> notifiedOrganisationsForIncident({
  required String localite,
  required String category,
}) {
  if (category == 'dechets') {
    return togoOrganisations.where((entry) {
      return entry['localite'] == localite && entry['type'] == 'lavoirie';
    }).toList();
  }
  return nearbyOrganisationsForIncident(localite: localite, category: category);
}

String organisationPhoneLabel(Map<String, String> organisation) {
  final direct = organisation['phone'];
  final green = organisation['green'];
  if (direct != null && green != null) {
    return 'Tel: $direct  |  Numero vert: $green';
  }
  if (direct != null) return 'Tel: $direct';
  if (green != null) return 'Numero vert: $green';
  return 'Numero indisponible';
}





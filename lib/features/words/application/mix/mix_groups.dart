import 'package:flutter/foundation.dart';

@immutable
class MixGroup {
  final String title;
  final List<String> items;
  const MixGroup(this.title, this.items);
}

@immutable
class MixSearchResult {
  final String group;
  final String item;
  const MixSearchResult({required this.group, required this.item});
}

/// Quelle für Gruppen (später leicht ersetzbar durch Taxonomy aus Supabase)
const mixGroups = <MixGroup>[
  MixGroup('Deine Sammlungen', ['Möchte ich lernen']),
  MixGroup('Action & Abenteuer', ['Gaming', 'Sport', 'Verkehr', 'Reisen']),
  MixGroup('Kultur & Kreativität', [
    'Kunst & Literatur',
    'Musik & Unterhaltung',
  ]),
  MixGroup('Sprachwerkzeuge', [
    'Grammatik & Syntax',
    'Unregelmäßige Verben',
    'Phrasen & Redewendungen',
    'Top 500 Wörter',
  ]),
  MixGroup('Level & Fortschritt', ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']),
  MixGroup('Alltag & Leben', [
    'Essen & Kochen',
    'Gesundheit & Fitness',
    'Wohnen & Zuhause',
    'Geld & Einkaufen',
    'Produktivität',
    'Stil & Mode',
  ]),
  MixGroup('Natur & Weltall', [
    'Tiere',
    'Umwelt',
    'Natur',
    'Wissenschaft',
    'Weltall',
  ]),
  MixGroup('Menschen & Gedanken', [
    'Gefühle',
    'Persönlichkeit',
    'Beziehungen',
    'Gedanken',
  ]),
  MixGroup('Gesellschaft & Systeme', [
    'Recht & Politik',
    'Medien & Nachrichten',
    'Schule & Studium',
    'Technik & Innovation',
    'Arbeit & Karriere',
  ]),
];

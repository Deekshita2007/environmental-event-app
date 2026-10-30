import 'package:flutter/material.dart';

import '../utils/constants.dart';

class EnvironmentalAwarenessPage extends StatelessWidget {
  const EnvironmentalAwarenessPage({super.key});

  static const _topics = [
    _AwarenessTopic(
      icon: Icons.park_outlined,
      title: 'Trees',
      subtitle: 'Planting and caring for trees',
      color: Color(0xFF2E7D32),
      overview: 'Trees absorb carbon dioxide, store carbon, filter some air pollutants and cool nearby areas through shade and evaporation. They also provide food and shelter for birds, insects and other wildlife.',
      actions: [
        'Choose native trees suited to your local climate and soil.',
        'Care for young trees with watering and protection while they establish.',
        'Protect existing trees and join local planting or restoration projects.',
      ],
    ),
    _AwarenessTopic(
      icon: Icons.recycling_outlined,
      title: 'Recycling',
      subtitle: 'Keep useful materials in circulation',
      color: Color(0xFF00897B),
      overview: 'Recycling can reduce the amount of waste sent to landfill and lower demand for some virgin materials. The right process depends on local facilities, so checking collection rules helps prevent recyclable materials from being rejected.',
      actions: [
        'Check local guidance for accepted plastics, paper, glass and metals.',
        'Keep food and liquids out of recycling containers when required.',
        'Reduce and reuse first, then recycle materials accepted locally.',
      ],
    ),
    _AwarenessTopic(
      icon: Icons.water_drop_outlined,
      title: 'Water',
      subtitle: 'Use fresh water thoughtfully',
      color: Color(0xFF1976D2),
      overview: 'Clean water is essential for people, agriculture and ecosystems. Treating and moving water also uses energy, while overuse can put pressure on rivers, reservoirs and groundwater, especially during dry periods.',
      actions: [
        'Fix leaking taps and toilets promptly.',
        'Use only the water you need when washing dishes or brushing teeth.',
        'Water gardens during cooler hours and choose plants suited to local rainfall.',
      ],
    ),
    _AwarenessTopic(
      icon: Icons.public_outlined,
      title: 'Climate',
      subtitle: 'Reduce emissions and prepare communities',
      color: Color(0xFFEF6C00),
      overview: 'Climate change is driven primarily by greenhouse gas emissions from human activities. Reducing emissions, protecting natural carbon stores and preparing for local climate risks all contribute to more resilient communities.',
      actions: [
        'Walk, cycle, carpool or use public transport when practical.',
        'Avoid wasting energy by switching off unused lights and equipment.',
        'Support community projects that reduce emissions and protect local habitats.',
      ],
    ),
    _AwarenessTopic(
      icon: Icons.pets_outlined,
      title: 'Wildlife',
      subtitle: 'Make room for healthy habitats',
      color: Color(0xFF7B5E00),
      overview: 'Wildlife depends on connected, healthy habitats for food, shelter and breeding. Habitat loss, pollution, invasive species and disturbance can put pressure on local species and the ecosystems they are part of.',
      actions: [
        'Keep a respectful distance from wild animals and never feed them unless local experts advise it.',
        'Plant native flowers and shrubs to support local pollinators and birds.',
        'Dispose of litter safely and join habitat restoration or wildlife monitoring efforts.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Environmental Awareness',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Small choices add up',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore how everyday actions can support healthier communities and ecosystems.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          ..._topics.map(_topicCard),
        ],
      ),
    );
  }

  Widget _topicCard(_AwarenessTopic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(topic.icon, color: topic.color),
        title: Text(
          topic.title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(topic.subtitle),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.overview,
            style: const TextStyle(color: AppColors.textGrey, height: 1.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'What you can do',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...topic.actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, color: topic.color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AwarenessTopic {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String overview;
  final List<String> actions;

  const _AwarenessTopic({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.overview,
    required this.actions,
  });
}

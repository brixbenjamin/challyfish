import 'package:flutter/material.dart';

import '../core/l10n_ext.dart';
import '../domain/campaign.dart';

class CampaignListScreen extends StatelessWidget {
  const CampaignListScreen({
    required this.campaigns,
    required this.onStart,
    super.key,
  });

  final List<Campaign> campaigns;
  final void Function(Campaign campaign) onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.campaignsTitle)),
      body: ListView.builder(
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];
          return ListTile(
            title: Text(campaign.title),
            subtitle: Text(context.l10n.lengthInDays(campaign.lengthDays)),
            onTap: () => onStart(campaign),
          );
        },
      ),
    );
  }
}

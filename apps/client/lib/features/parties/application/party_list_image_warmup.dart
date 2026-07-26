import 'dart:async';

import 'package:billing_baba/shared/media/image_display_context.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/shared/image/image_service.dart';
import 'package:billing_baba/shared/image/image_urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Prefetches visible party avatar thumbnails for long lists.
class PartyListImageWarmup {
  PartyListImageWarmup(this._ref);

  final Ref _ref;

  void warmParty(PartyModel party) {
    final url = normalizeImageUrl(party.profileImageUrl);
    final mediaId = party.profileMediaAssetId?.trim();
    if (url == null && (mediaId == null || mediaId.isEmpty)) return;

    if (mediaId != null && mediaId.isNotEmpty) {
      unawaited(
        _ref
            .read(imageServiceProvider)
            .prefetchResolved(
              sourceMediaAssetId: mediaId,
              context: ImageDisplayContext.list,
              fallbackUrl: url ?? '',
            ),
      );
      return;
    }

    unawaited(_ref.read(imageServiceProvider).prefetchUrl(url));
  }

  void warmParties(Iterable<PartyModel> parties, {int limit = 60}) {
    var count = 0;
    for (final party in parties) {
      if (count >= limit) break;
      warmParty(party);
      count++;
    }
  }
}

final partyListImageWarmupProvider = Provider<PartyListImageWarmup>(
  PartyListImageWarmup.new,
);

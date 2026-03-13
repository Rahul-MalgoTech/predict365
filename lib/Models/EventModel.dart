// lib/Models/EventModel.dart

// Safe helper — accepts String, DateTime, or null without throwing
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

class MarketPrice {
  final double? bestBid;
  final double? bestAsk;

  MarketPrice({this.bestBid, this.bestAsk});

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      bestBid: (json['bestBid'] as num?)?.toDouble(),
      bestAsk: (json['bestAsk'] as num?)?.toDouble(),
    );
  }
}

class MarketPrices {
  final MarketPrice yes;
  final MarketPrice no;

  MarketPrices({required this.yes, required this.no});

  factory MarketPrices.fromJson(Map<String, dynamic> json) {
    return MarketPrices(
      yes: MarketPrice.fromJson(json['Yes'] ?? {}),
      no:  MarketPrice.fromJson(json['No']  ?? {}),
    );
  }
}

class SubMarket {
  final String    id;
  final String    name;
  final String    eventId;
  final String    marketImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final double    dollarVolume;
  final String    status;
  final String?   result;
  final bool      canCloseEarly;
  final int       settlementTime;
  final String    resolutionState;
  final int       disputeCount;
  final double    bondAmount;
  final int       resolutionWindow;
  final String    side1;
  final String    side2;
  final double?   lastTradedSide1Price;
  final MarketPrices marketPrices;

  SubMarket({
    required this.id,
    required this.name,
    required this.eventId,
    required this.marketImage,
    this.startDate,
    this.endDate,
    required this.dollarVolume,
    required this.status,
    this.result,
    required this.canCloseEarly,
    required this.settlementTime,
    required this.resolutionState,
    required this.disputeCount,
    required this.bondAmount,
    required this.resolutionWindow,
    required this.side1,
    required this.side2,
    this.lastTradedSide1Price,
    required this.marketPrices,
  });

  factory SubMarket.fromJson(Map<String, dynamic> json) {
    return SubMarket(
      id:                   json['_id']              ?? '',
      name:                 json['name']             ?? '',
      eventId:              json['event_id']         ?? '',
      marketImage:          json['market_image']     ?? '',
      startDate:            _parseDate(json['start_date']),
      endDate:              _parseDate(json['end_date']),
      dollarVolume:         (json['dollar_volume'] as num?)?.toDouble() ?? 0,
      status:               json['status']           ?? '',
      result:               json['result'],
      canCloseEarly:        json['can_close_early']  ?? false,
      settlementTime:       (json['settlement_time'] as num?)?.toInt() ?? 0,
      resolutionState:      json['resolution_state'] ?? '',
      disputeCount:         (json['dispute_count'] as num?)?.toInt() ?? 0,
      bondAmount:           (json['bond_amount'] as num?)?.toDouble() ?? 0,
      resolutionWindow:     (json['resolution_window'] as num?)?.toInt() ?? 0,
      side1:                json['side_1'] ?? 'Yes',
      side2:                json['side_2'] ?? 'No',
      lastTradedSide1Price: (json['lastTradedSide1Price'] as num?)?.toDouble(),
      marketPrices:         MarketPrices.fromJson(json['marketPrices'] ?? {}),
    );
  }

  bool get isOpen => status.toLowerCase() == 'open';
  bool get isResolutionProposed => resolutionState == 'resolution_proposed';
}

class EventRegion {
  final String id;
  final String name;
  final String code;

  EventRegion({required this.id, required this.name, required this.code});

  factory EventRegion.fromJson(Map<String, dynamic> json) {
    return EventRegion(
      id:   json['_id']  ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class EventModel {
  final String          id;
  final String          eventTitle;
  final String          eventImage;
  final String          category;
  final String          subCategory;
  final bool            hasSubMarkets;
  final List<SubMarket> subMarkets;
  final DateTime?       listDate;
  final String          marketSummary;
  final String          rulesSummary;
  final List<String>    settlementSources;
  final String          fullRulesDocUrl;
  final double          totalPoolInUsd;
  final bool            isLiveSports;
  final List<EventRegion> regions;
  final DateTime?       createdAt;
  final DateTime?       updatedAt;

  EventModel({
    required this.id,
    required this.eventTitle,
    required this.eventImage,
    required this.category,
    required this.subCategory,
    required this.hasSubMarkets,
    required this.subMarkets,
    this.listDate,
    required this.marketSummary,
    required this.rulesSummary,
    required this.settlementSources,
    required this.fullRulesDocUrl,
    required this.totalPoolInUsd,
    required this.isLiveSports,
    required this.regions,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // ── Parse sub_markets / markets ────────────────────────────────────────
    // The API may return markets as:
    //   1. A Map<String, dynamic> keyed by market _id  ← actual API shape
    //   2. A List<dynamic>                             ← fallback / future
    List<SubMarket> parseMarkets(dynamic raw) {
      if (raw == null) return [];

      if (raw is Map) {
        // Shape: { "marketId": { ...marketFields }, ... }
        return raw.values
            .whereType<Map<String, dynamic>>()
            .map((m) => SubMarket.fromJson(m))
            .toList();
      }

      if (raw is List) {
        // Shape: [ { ...marketFields }, ... ]
        return raw
            .whereType<Map<String, dynamic>>()
            .map((m) => SubMarket.fromJson(m))
            .toList();
      }

      return [];
    }

    // The list-events endpoint uses "markets"; the single-event endpoint may
    // use "sub_markets" — handle both keys gracefully.
    final marketsRaw =
        json['markets'] ?? json['sub_markets'];

    return EventModel(
      id:            json['_id']           ?? '',
      eventTitle:    json['event_title']   ?? '',
      eventImage:    json['event_image']   ?? '',
      category:      json['category']      ?? '',
      subCategory:   json['sub_category']  ?? '',
      hasSubMarkets: json['has_sub_markets'] ?? false,
      subMarkets:    parseMarkets(marketsRaw),
      listDate:      _parseDate(json['list_date']),
      marketSummary: json['market_summary'] ?? '',
      rulesSummary:  json['rules_summary']  ?? '',
      settlementSources: (json['settlement_sources'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      fullRulesDocUrl: json['full_rules_doc_url'] ?? '',
      totalPoolInUsd:  (json['total_pool_in_usd'] as num?)?.toDouble() ?? 0,
      isLiveSports:    json['is_live_sports'] ?? false,
      // regions field is a list of IDs (strings) on the list endpoint,
      // but could be populated objects on the single-event endpoint.
      regions: _parseRegions(json['regions']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  /// Convenience: the first (or only) sub-market
  SubMarket? get primaryMarket => subMarkets.isNotEmpty ? subMarkets.first : null;

  /// True if at least one sub-market is open
  bool get isOpen => subMarkets.any((m) => m.isOpen);
}

/// Handles regions as either a list of populated objects OR a list of ID strings.
List<EventRegion> _parseRegions(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) return [];
  return raw.map((r) {
    if (r is Map<String, dynamic>) return EventRegion.fromJson(r);
    // raw string ID — create a minimal placeholder
    return EventRegion(id: r.toString(), name: '', code: '');
  }).toList();
}

// ── Pagination ────────────────────────────────────────────────────
class PaginationModel {
  final int total;
  final int currentPage;
  final int totalPages;

  PaginationModel({
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total:       (json['total'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      totalPages:  (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

// ── API Response Wrapper ──────────────────────────────────────────
// The /api/events endpoint returns:
// {
//   "success": true,
//   "events": {                         ← MAP, not array
//     "<_id>": { ...eventFields },
//     ...
//   },
//   "pagination": { "total": 11 }
// }
class EventsResponseModel {
  final bool               success;
  final List<EventModel>   events;
  final PaginationModel?   pagination;

  EventsResponseModel({
    required this.success,
    required this.events,
    this.pagination,
  });

  factory EventsResponseModel.fromJson(Map<String, dynamic> json) {
    // events can be a Map<id, eventObj> OR a List — handle both
    List<EventModel> parseEvents(dynamic raw) {
      if (raw == null) return [];

      if (raw is Map) {
        // Actual API shape: { "<_id>": { ...fields }, ... }
        return raw.values
            .whereType<Map<String, dynamic>>()
            .map((e) => EventModel.fromJson(e))
            .toList();
      }

      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => EventModel.fromJson(e))
            .toList();
      }

      return [];
    }

    return EventsResponseModel(
      success:    json['success'] ?? false,
      events:     parseEvents(json['events']),
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ── Single Event Response ─────────────────────────────────────────
// Shape from /api/events/:id may wrap the event under an "event" key
// OR return it at the top level — handle both.
class EventSingleResponseModel {
  final bool        success;
  final EventModel? event;

  EventSingleResponseModel({required this.success, this.event});

  factory EventSingleResponseModel.fromJson(Map<String, dynamic> json) {
    final rawEvent = json['event'] ?? json['data'];

    EventModel? parsed;
    if (rawEvent is Map<String, dynamic>) {
      parsed = EventModel.fromJson(rawEvent);
    } else if (json['_id'] != null) {
      // top-level IS the event
      parsed = EventModel.fromJson(json);
    }

    return EventSingleResponseModel(
      success: json['success'] ?? parsed != null,
      event:   parsed,
    );
  }
}
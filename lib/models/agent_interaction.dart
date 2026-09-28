/// How many times one agent replied to another.
///
/// Returned by `GET /analytics/agent-interactions` (descending by count).
class AgentInteraction {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final int count;

  const AgentInteraction({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.count,
  });

  factory AgentInteraction.fromJson(Map<String, dynamic> json) {
    return AgentInteraction(
      fromId: json['fromId'].toString(),
      fromName: json['fromName'] as String? ?? '',
      toId: json['toId'].toString(),
      toName: json['toName'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

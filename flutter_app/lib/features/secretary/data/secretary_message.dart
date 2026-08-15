/// Shared mock inbox data for the Secretary Messages flow. The inbox list and
/// the message-detail screen both read from [secretaryMockMessages] so a row
/// tapped in the inbox resolves to the same record by `id` (this build has no
/// messages API — the React prototype used inline mock data too).
class SecretaryMessage {
  const SecretaryMessage({
    required this.id,
    required this.from,
    required this.initials,
    required this.subject,
    required this.preview,
    required this.body,
    required this.time,
    required this.unread,
    required this.category,
  });

  final String id;
  final String from;
  final String initials;
  final String subject;
  final String preview;
  final String body;
  final String time;
  final bool unread;
  final String category; // parents | clinic | sent

  static SecretaryMessage? byId(String id) {
    for (final m in secretaryMockMessages) {
      if (m.id == id) return m;
    }
    return null;
  }
}

const List<SecretaryMessage> secretaryMockMessages = [
  SecretaryMessage(
    id: '1',
    from: 'James Thompson',
    initials: 'JT',
    subject: "Re: Maya's medication schedule",
    preview: "Re: Maya's medication schedule - Thank you for the clarification...",
    body:
        "Thank you for the clarification on Maya's medication schedule. I've updated "
        "my notes to reflect the 2:00 PM dose. Please let me know if the timing "
        "changes again before the field trip next week.\n\nBest regards,\nJames Thompson",
    time: '10:45 AM',
    unread: true,
    category: 'parents',
  ),
  SecretaryMessage(
    id: '2',
    from: 'Sarah Williams',
    initials: 'SW',
    subject: 'Document expiry reminder',
    preview: 'Document expiry reminder - Could you help me understand which...',
    body:
        "Could you help me understand which of Ethan's documents are expiring soon? "
        "I received a reminder that one of his forms needs renewal but I'm not sure "
        "which one, or how to submit the updated copy. Any guidance would be "
        "appreciated.\n\nThank you,\nSarah Williams",
    time: '9:30 AM',
    unread: true,
    category: 'parents',
  ),
  SecretaryMessage(
    id: '3',
    from: 'Nurse Chen',
    initials: 'NC',
    subject: '[Copy] Emergency consent sent',
    preview: "[Copy] Emergency consent sent to Maya Thompson's parent",
    body:
        "[Automated copy] An emergency treatment consent request was sent to Maya "
        "Thompson's parent/guardian. This copy is retained in the clinic record for "
        "administrative reference. No action is required from the front office.",
    time: 'Yesterday',
    unread: false,
    category: 'clinic',
  ),
  SecretaryMessage(
    id: '4',
    from: 'Carlos Martinez',
    initials: 'CM',
    subject: 'Pickup authorization',
    preview: 'Pickup authorization - I need to add my mother to the approved...',
    body:
        "I need to add my mother, Elena Martinez, to the approved pickup list for "
        "Sophia. She will be collecting Sophia on Wednesdays going forward. Please "
        "let me know what documentation you need from us to authorise this.\n\n"
        "Regards,\nCarlos Martinez",
    time: 'Yesterday',
    unread: false,
    category: 'parents',
  ),
  SecretaryMessage(
    id: '5',
    from: 'Nurse Chen',
    initials: 'NC',
    subject: '[Copy] Medication administered',
    preview: '[Copy] Medication administered - Ethan Williams',
    body:
        "[Automated copy] Ethan Williams received his scheduled medication (Albuterol "
        "inhaler, 2 puffs) at 10:15 AM. Vitals were within normal range afterwards. "
        "This copy is retained for administrative records.",
    time: '05/30',
    unread: false,
    category: 'clinic',
  ),
];

/// A single question in an event's registration form. Stored on the event
/// as `customFormSchema: { fields: [ {label, hint, type, options, required} ] }`.
class RegistrationField {
  final String label;
  final String hint;
  final FieldType type;
  final List<String> options; // for dropdown
  final bool isRequired;

  const RegistrationField({
    required this.label,
    this.hint = '',
    this.type = FieldType.text,
    this.options = const [],
    this.isRequired = true,
  });

  factory RegistrationField.fromMap(Map<String, dynamic> map) {
    return RegistrationField(
      label: map['label'] as String? ?? 'Question',
      hint: map['hint'] as String? ?? '',
      type: FieldType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => FieldType.text,
      ),
      options: (map['options'] as List?)?.whereType<String>().toList() ?? const [],
      isRequired: map['required'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'hint': hint,
        'type': type.name,
        'options': options,
        'required': isRequired,
      };

  RegistrationField copyWith({
    String? label,
    FieldType? type,
    List<String>? options,
    bool? isRequired,
  }) {
    return RegistrationField(
      label: label ?? this.label,
      hint: hint,
      type: type ?? this.type,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  static List<RegistrationField> listFromSchema(Object? schema) {
    final fields = schema is Map ? schema['fields'] : schema;
    if (fields is! List) return const [];
    return fields
        .whereType<Map>()
        .map((m) => RegistrationField.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }
}

enum FieldType { text, email, phone, dropdown, multiline }

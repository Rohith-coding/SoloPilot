/// Represents a client/customer that the freelancer works with.
/// Stored locally in the SQLite database.
class Client {
  int? id;
  String name;
  String? contact;

  Client({this.id, required this.name, this.contact});

  /// Create a Client from a database row (Map).
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as int?,
      name: map['name'] as String,
      contact: map['contact'] as String?,
    );
  }

  /// Convert to a Map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'contact': contact,
    };
  }

  @override
  String toString() => 'Client(id: $id, name: $name)';
}

class Sticker {
  final String name;

  Sticker({
    required this.name,
  });
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sticker && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

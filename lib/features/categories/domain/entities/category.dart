import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? icon;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  @override
  List<Object?> get props => [id, name, slug, icon];
}

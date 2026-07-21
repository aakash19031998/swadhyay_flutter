import 'package:equatable/equatable.dart';

enum BagMediaType { image, video }

/// One photo or video attached to a bag, shown in the full-screen media
/// viewer opened from [BagListItem]'s thumbnail.
class BagMediaEntity extends Equatable {
  const BagMediaEntity({required this.url, required this.type});

  final String url;
  final BagMediaType type;

  @override
  List<Object?> get props => [url, type];
}

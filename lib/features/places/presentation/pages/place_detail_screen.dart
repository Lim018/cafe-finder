import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/place_detail_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../reviews/presentation/bloc/reviews_bloc.dart';

class PlaceDetailScreen extends StatefulWidget {
  final int placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _reviewRating = 5.0;

  @override
  void initState() {
    super.initState();
    context.read<PlaceDetailBloc>().add(LoadPlaceDetail(widget.placeId));
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tulis Ulasan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _reviewRating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _reviewRating.round().toString(),
                    onChanged: (val) {
                      setState(() {
                        _reviewRating = val;
                      });
                    },
                  ),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Bagaimana pengalaman Anda?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReviewsBloc>().add(SubmitReview(
                          placeId: widget.placeId,
                          rating: _reviewRating.round(),
                          content: _reviewController.text,
                        ));
                    context.pop();
                    _reviewController.clear();
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewsSubmittedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<PlaceDetailBloc>().add(LoadPlaceDetail(widget.placeId)); // Reload to show new review
        }
      },
      child: Scaffold(
        body: BlocBuilder<PlaceDetailBloc, PlaceDetailState>(
          builder: (context, state) {
            if (state is PlaceDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PlaceDetailError) {
              return Center(child: Text(state.message));
            } else if (state is PlaceDetailLoaded) {
              final place = state.place;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: place.photos.isNotEmpty
                          ? PageView.builder(
                              itemCount: place.photos.length,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: place.photos[index].url,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Container(color: Colors.grey.shade300, child: const Icon(Icons.image, size: 50)),
                    ),
                    actions: [
                      BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, favState) {
                          bool isFavorite = false;
                          if (favState is FavoritesLoaded) {
                            isFavorite = favState.favorites.any((f) => f.placeId == place.id);
                          }
                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              context.read<FavoritesBloc>().add(ToggleFavorite(place.id));
                            },
                          );
                        },
                      )
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  place.name,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('${place.avgRating.toStringAsFixed(1)} (${place.recommendationCount})'),
                                ],
                              ),
                            ],
                          ),
                          if (place.categoryName != null) ...[
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(place.categoryName!),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(place.address, style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 16),
                          if (place.description != null) ...[
                            const Text('Tentang Kafe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(place.description!),
                            const SizedBox(height: 16),
                          ],
                          
                          // Action Buttons (Maps, Web, IG)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (place.googleMapsUrl != null)
                                ActionChip(
                                  avatar: const Icon(Icons.map, size: 16),
                                  label: const Text('Maps'),
                                  onPressed: () => _launchUrl(place.googleMapsUrl!),
                                ),
                              if (place.instagramUrl != null)
                                ActionChip(
                                  avatar: const Icon(Icons.camera_alt, size: 16),
                                  label: const Text('IG'),
                                  onPressed: () => _launchUrl(place.instagramUrl!),
                                ),
                              if (place.websiteUrl != null)
                                ActionChip(
                                  avatar: const Icon(Icons.language, size: 16),
                                  label: const Text('Web'),
                                  onPressed: () => _launchUrl(place.websiteUrl!),
                                ),
                            ],
                          ),
                          const Divider(height: 32),
                          
                          // Tags/Facilities
                          if (place.tags.isNotEmpty) ...[
                            const Text('Fasilitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: place.tags.map((t) => Chip(label: Text(t))).toList(),
                            ),
                            const Divider(height: 32),
                          ],

                          // Reviews Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ulasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Tulis Ulasan'),
                                onPressed: _showAddReviewDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (place.recentReviews.isEmpty)
                            const Text('Belum ada ulasan.')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: place.recentReviews.length,
                              itemBuilder: (context, index) {
                                final rev = place.recentReviews[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: rev.userAvatarUrl != null 
                                          ? CachedNetworkImageProvider(rev.userAvatarUrl!) 
                                          : null,
                                      child: rev.userAvatarUrl == null ? const Icon(Icons.person) : null,
                                    ),
                                    title: Text(rev.userName),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(5, (i) => Icon(
                                            i < rev.rating ? Icons.star : Icons.star_border,
                                            size: 14,
                                            color: Colors.amber,
                                          )),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(rev.content),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

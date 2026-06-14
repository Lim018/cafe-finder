import 'package:flutter/material.dart';

class SmartListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, int, T) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool hasMoreData;
  final bool isLoadingMore;
  final Widget? emptyState;
  final Widget? separator;

  const SmartListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.hasMoreData,
    this.isLoadingMore = false,
    this.emptyState,
    this.separator,
  });

  @override
  State<SmartListView<T>> createState() => _SmartListViewState<T>();
}

class _SmartListViewState<T> extends State<SmartListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load more when user scrolls to within 200 pixels of the bottom
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!widget.isLoadingMore && widget.hasMoreData) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.emptyState != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 24,
            ),
            child: widget.emptyState!,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.items.length + (widget.hasMoreData ? 1 : 0),
        separatorBuilder: (context, index) => widget.separator ?? const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == widget.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return widget.itemBuilder(context, index, widget.items[index]);
        },
      ),
    );
  }
}

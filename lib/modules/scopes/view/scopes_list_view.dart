import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_plus/models/scope.dart';
import 'package:portfolio_plus/modules/scopes/provider/scope_provider.dart';
import 'package:portfolio_plus/modules/scopes/view/add_edit_scope_view.dart';
import 'package:portfolio_plus/utils/colors.dart';
import 'package:portfolio_plus/utils/ts.dart';
import 'package:portfolio_plus/utils/custom_widgets/input_text_field.dart';

class ScopesListView extends ConsumerStatefulWidget {
  const ScopesListView({super.key});

  @override
  ConsumerState<ScopesListView> createState() => _ScopesListViewState();
}

class _ScopesListViewState extends ConsumerState<ScopesListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      ref.read(scopeListProvider.notifier).searchScopes(_searchQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scopesAsync = ref.watch(scopeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baskets'),
        backgroundColor: AppColors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditScopeView(),
                ),
              );
            },
            tooltip: 'Add Basket',
          ),
        ],
      ),
      body: scopesAsync.when(
        data: (scopes) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(scopeListProvider.notifier).loadScopes();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomInputField(
                      controller: _searchController,
                      hint: 'Search baskets...',
                      prefixIcon: const Icon(Icons.search),
                      borderRadius: 12,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                if (scopes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No baskets yet'
                                : 'No baskets found',
                            style: Ts.regular18(Colors.grey[600] ?? Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          if (_searchQuery.isEmpty)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddEditScopeView(),
                                  ),
                                );
                              },
                              child: const Text('Create Your First Basket'),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final scope = scopes[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ScopeCard(
                            scope: scope,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditScopeView(scope: scope),
                                ),
                              );
                            },
                            onDelete: () {
                              _showDeleteDialog(context, scope);
                            },
                          ),
                        );
                      },
                      childCount: scopes.length,
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading baskets',
                style: Ts.regular18(Colors.red[600] ?? Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Ts.regular14(Colors.grey[600] ?? Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(scopeListProvider.notifier).loadScopes();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ScopeModel scope) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Basket'),
        content: Text('Are you sure you want to delete "${scope.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(scopeListProvider.notifier).deleteScope(scope.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ScopeCard extends StatelessWidget {
  final ScopeModel scope;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScopeCard({
    super.key,
    required this.scope,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scope.name,
                      style: Ts.semiBold16(AppColors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(scope.createdAt)}',
                      style: Ts.regular12(AppColors.grey),
                    ),
                    if (scope.baseCurrency != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Currency: ${scope.baseCurrency}',
                          style: Ts.regular12(AppColors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Colors.red[400],
                tooltip: 'Delete Basket',
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
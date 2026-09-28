import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';

import '../data/models/skill_model.dart';
import '../data/repo/skill_repo.dart';
import 'cubit/skill_cubit.dart';
import 'cubit/skill_state.dart';


class SkillSwapScreen extends StatelessWidget {
  const SkillSwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkillCubit(getIt<SkillRepo>(), getIt<FirebaseAuth>()),
      child: const _SkillSwapView(),
    );
  }
}

class _SkillSwapView extends StatelessWidget {
  const _SkillSwapView();

  Future<void> _showAddPostSheet(BuildContext context) async {
    final cubit = context.read<SkillCubit>();
    final offeredController = TextEditingController();
    final wantedController = TextEditingController();
    final descController = TextEditingController();
    final contactController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Skill Swap Offer',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: MyColors().textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: offeredController,
                  decoration: const InputDecoration(
                    labelText: 'Skill you can teach',
                    hintText: 'e.g. UI/UX Design',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: wantedController,
                  decoration: const InputDecoration(
                    labelText: 'Skill you want to learn',
                    hintText: 'e.g. Flutter',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Short description',
                    hintText: 'Your level, availability, etc.',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp number or email',
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: MyColors().button),
                  onPressed: () {
                    if (offeredController.text.trim().isEmpty ||
                        contactController.text.trim().isEmpty) {
                      return;
                    }
                    cubit.addPost(
                      skillOffered: offeredController.text,
                      skillWanted: wantedController.text,
                      description: descController.text,
                      contactInfo: contactController.text,
                    );
                    Navigator.pop(sheetContext);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Post Offer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _postCard(BuildContext context, SkillPostModel post, bool isMine) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: post.skillOffered,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: MyColors().textPrimary,
                          ),
                        ),
                        if (post.skillWanted.isNotEmpty) ...[
                          const TextSpan(text: '   ⇄   '),
                          TextSpan(
                            text: post.skillWanted,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: MyColors().primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isMine)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => context.read<SkillCubit>().deletePost(post.id),
                  ),
              ],
            ),
            if (post.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(post.description, style: TextStyle(color: MyColors().textSecondary)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: MyColors().textSecondary),
                const SizedBox(width: 4),
                Text(post.userName, style: TextStyle(fontSize: 12, color: MyColors().textSecondary)),
                const Spacer(),
                Icon(Icons.phone_outlined, size: 16, color: MyColors().button),
                const SizedBox(width: 4),
                Text(post.contactInfo, style: TextStyle(fontSize: 12, color: MyColors().button, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _postList(BuildContext context, List<SkillPostModel> posts, String emptyText, String? currentUid) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyText, textAlign: TextAlign.center, style: TextStyle(color: MyColors().textSecondary)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _postCard(context, post, post.userId == currentUid);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyColors().background,
        appBar: AppBar(
          backgroundColor: MyColors().background,
          elevation: 0,
          foregroundColor: MyColors().textPrimary,
          title: const Text('Skill Swap'),
          bottom: const TabBar(tabs: [Tab(text: 'All Offers'), Tab(text: 'My Offers')]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                await getIt<FirebaseAuth>().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<SkillCubit, SkillState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Something went wrong: ${state.error}', style: const TextStyle(color: Colors.red)),
                ),
              );
            }
            return TabBarView(
              children: [
                _postList(context, state.posts, 'No offers yet, be the first to post one', state.currentUid),
                _postList(context, state.myPosts, 'You haven\'t posted any offers yet', state.currentUid),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: MyColors().button,
          onPressed: () => _showAddPostSheet(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
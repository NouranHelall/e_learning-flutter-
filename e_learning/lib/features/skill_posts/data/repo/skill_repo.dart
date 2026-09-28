import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_model.dart';


class SkillRepo {
  final FirebaseFirestore _firestore;
  SkillRepo(this._firestore);

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection('skill_posts');

  Stream<List<SkillPostModel>> watchAllPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => SkillPostModel.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> addPost({
    required String userId,
    required String userName,
    required String skillOffered,
    required String skillWanted,
    required String description,
    required String contactInfo,
  }) async {
    await _postsCollection.add({
      'userId': userId,
      'userName': userName,
      'skillOffered': skillOffered,
      'skillWanted': skillWanted,
      'description': description,
      'contactInfo': contactInfo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }
}
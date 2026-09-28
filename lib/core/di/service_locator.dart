import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repo/auth_repo.dart';
import '../../features/auth/data/user_repo.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';
import '../../features/requests/domain/usecases/accept_request_usecase.dart';
import '../../features/skill_posts/data/repo/skill_repo.dart';
import '../../features/matching/data/repo/match_repo.dart';
import '../../features/requests/data/repo/request_repo.dart';
import '../../features/exchanges/data/repo/exchange_repo.dart';
import '../../features/exchanges/domain/usecase/complete_exchange_usecase.dart';
import '../../features/reviews/data/repo/review_repo.dart';
import '../../features/reviews/domain/usecase/rate_exchange_usecase.dart';
import '../../features/chat/data/repo/chat_repo.dart';
import '../../features/notifications/data/repo/notification_repo.dart';
import '../services/notification_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt.registerLazySingleton<FirebaseAuth>(
        () => FirebaseAuth.instance,
  );

  getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseMessaging>(
        () => FirebaseMessaging.instance,
  );

  getIt.registerLazySingleton<AuthRepo>(
        () => AuthRepo(getIt()),
  );

  getIt.registerLazySingleton<UserRepo>(
        () => UserRepo(getIt()),
  );

  getIt.registerLazySingleton<SkillRepo>(
        () => SkillRepo(getIt()),
  );

  getIt.registerLazySingleton<MatchRepo>(
        () => MatchRepo(getIt()),
  );

  getIt.registerLazySingleton<RequestRepo>(
        () => RequestRepo(getIt()),
  );

  getIt.registerLazySingleton<ExchangeRepo>(
        () => ExchangeRepo(getIt()),
  );

  getIt.registerLazySingleton<ReviewRepo>(
        () => ReviewRepo(getIt()),
  );

  getIt.registerLazySingleton<ChatRepo>(
        () => ChatRepo(getIt()),
  );

  getIt.registerLazySingleton<NotificationRepo>(
        () => NotificationRepo(getIt()),
  );

  getIt.registerLazySingleton<NotificationService>(
        () => NotificationService(
      getIt(),
      getIt(),
      getIt(),
    ),
  );

  getIt.registerLazySingleton<LoginUsecase>(
        () => LoginUsecase(getIt()),
  );

  getIt.registerLazySingleton<RegisterUsecase>(
        () => RegisterUsecase(getIt(), getIt()),
  );

  getIt.registerLazySingleton<AcceptRequestUsecase>(
        () => AcceptRequestUsecase(getIt(), getIt()),
  );

  getIt.registerLazySingleton<CompleteExchangeUsecase>(
        () => CompleteExchangeUsecase(getIt(), getIt()),
  );

  getIt.registerLazySingleton<RateExchangeUsecase>(
        () => RateExchangeUsecase(getIt(), getIt()),
  );
}
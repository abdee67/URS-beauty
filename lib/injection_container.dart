import 'package:get_it/get_it.dart';
import 'package:urs_beauty/api/stripe/stripe_api_service.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_location_data_source.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_location_data_source_impl.dart';
import 'package:urs_beauty/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:urs_beauty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urs_beauty/features/auth/domain/repositories/auth_repository.dart';
import 'package:urs_beauty/features/auth/domain/usecases/forgot_password.dart';
import 'package:urs_beauty/features/auth/domain/usecases/get_current_location_address.dart'
    as auth_usecases;
import 'package:urs_beauty/features/auth/domain/usecases/get_current_client.dart';
import 'package:urs_beauty/features/auth/domain/usecases/create_customer_address.dart';
import 'package:urs_beauty/features/auth/domain/usecases/reset_password.dart';
import 'package:urs_beauty/features/auth/domain/usecases/send_otp.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_in.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_out.dart';
import 'package:urs_beauty/features/auth/domain/usecases/sign_up.dart';
import 'package:urs_beauty/features/auth/domain/usecases/update_client_profile.dart';
import 'package:urs_beauty/features/auth/domain/usecases/verify_otp.dart';
import 'package:urs_beauty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_categories_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_categories_remote_data_source_impl.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_remote_data_source.dart';
import 'package:urs_beauty/features/beauty_services/data/datasources/service_remote_data_source_impl.dart';
import 'package:urs_beauty/features/beauty_services/data/repositories/service_categories_repository_impl.dart';
import 'package:urs_beauty/features/beauty_services/data/repositories/service_repository_impl.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/service_categories_repository.dart';
import 'package:urs_beauty/features/beauty_services/domain/repositories/services_repository.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_categories.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_by_category.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_by_stylists.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_service_detail.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/get_services.dart';
import 'package:urs_beauty/features/beauty_services/domain/usecases/search_services.dart';
import 'package:urs_beauty/features/beauty_services/presentation/bloc/service_bloc.dart';
import 'package:urs_beauty/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:urs_beauty/features/bookings/data/datasources/booking_remote_data_source_impl.dart';
import 'package:urs_beauty/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/add_notes_to_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/cancel_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/create_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/create_booking_with_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_current_location_address.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_by_customer_id.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_by_status.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_by_sylist_id.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_booking_services.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_bookings.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/get_bookings_by_id.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/reschedule_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/search_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/update_booking.dart';
import 'package:urs_beauty/features/bookings/domain/usecases/update_booking_status.dart';
import 'package:urs_beauty/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:urs_beauty/features/deals/data/datasource/deals_remote_data_source.dart';
import 'package:urs_beauty/features/deals/data/datasource/deals_remote_data_source_impl.dart';
import 'package:urs_beauty/features/deals/data/repository/deals_repository_impl.dart';
import 'package:urs_beauty/features/deals/domain/repository/deals_repository.dart';
import 'package:urs_beauty/features/deals/domain/usescases/get_deals.dart';
import 'package:urs_beauty/features/reviews/data/datasource/review_remote_data_source.dart';
import 'package:urs_beauty/features/reviews/data/datasource/review_remote_data_source_impl.dart';
import 'package:urs_beauty/features/reviews/data/repository/review_repository_impl.dart';
import 'package:urs_beauty/features/reviews/domain/repository/review_repository.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_rating_summary.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_review_by_booking_id_usecase.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_review_by_cutomer_id_usecase.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/get_review_by_stylist_id_usecase.dart';
import 'package:urs_beauty/features/reviews/domain/usecase/submit_review_usecase.dart';
import 'package:urs_beauty/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_data_source.dart';
import 'package:urs_beauty/features/stylists/data/datasources/stylists_remote_datasource_impl.dart';
import 'package:urs_beauty/features/stylists/data/repository/stylists_repository_impl.dart';
import 'package:urs_beauty/features/stylists/domain/repository/stylists_repository.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_available_slots.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_client_location.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_nearby_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_by_service.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_detail.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_recommendations.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists.dart';
import 'package:urs_beauty/features/stylists/presentation/bloc/bloc/stylists_bloc.dart';
import 'package:urs_beauty/features/home/presentation/bloc/home_bloc.dart';
import 'package:urs_beauty/features/payments/data/dataSources/payment_remote_data_source';
import 'package:urs_beauty/features/payments/data/dataSources/payment_remote_data_source_impl.dart';
import 'package:urs_beauty/features/payments/data/repository/payment_repository_impl.dart';
import 'package:urs_beauty/features/payments/domain/repository/payment_repostiory';
import 'package:urs_beauty/features/payments/domain/usecases/cancel_pending_card_payment.dart';
import 'package:urs_beauty/features/payments/domain/usecases/confirm_card_payment.dart';
import 'package:urs_beauty/features/payments/domain/usecases/create_card_payment.dart';
import 'package:urs_beauty/features/payments/domain/usecases/get_card_payment_status.dart';
import 'package:urs_beauty/features/payments/domain/usecases/handle_card_payment_faillure.dart';
import 'package:urs_beauty/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability_by_day.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_availability_by_time.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylist_services.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/get_stylists_service.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/search_stylists.dart';
import 'package:urs_beauty/features/stylists/domain/usecases/update_stylists_availability.dart';

final getit = GetIt.instance;
void initDependency() {
  //==================injecting auth data source===================
  getit.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<AuthLocationDataSource>(
    () => AuthLocationDataSourceImpl(),
  );
  getit.registerLazySingleton<ServiceCategoriesRemoteDataSource>(
    () => ServiceCategoriesRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<StylistsRemoteDataSource>(
    () => StylistsRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<DealsRemoteDataSource>(
    () => DealsRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(),
  );
  getit.registerLazySingleton(() => StripeApiService());
  getit.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(apiService: getit()),
  );

  //================== injecting  repository===================
  getit.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getit(), getit()),
  );
  getit.registerLazySingleton<ServiceCategoriesRepository>(
    () => ServiceCategoriesRepositoryImpl(remoteDataSource: getit()),
  );
  getit.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(remoteDataSource: getit()),
  );
  getit.registerLazySingleton<StylistsRepository>(
    () => StylistsRepositoryImpl(remoteDataSource: getit()),
  );
  getit.registerLazySingleton<DealsRepository>(
    () => DealsRepositoryImpl(remoteDataSource: getit()),
  );
  getit.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: getit(),
      locationDataSource: getit(),
    ),
  );
  getit.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: getit()),
  );
  getit.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(paymentRemoteDataSource: getit()),
  );

  // ===============injectin use case=================
  // Auth use cases
  getit.registerLazySingleton(() => SignIn(getit()));
  getit.registerLazySingleton(() => SignUp(getit()));
  getit.registerLazySingleton(() => SignOut(getit()));
  getit.registerLazySingleton(() => SendOtp(getit()));
  getit.registerLazySingleton(() => VerifyOTP(getit()));
  getit.registerLazySingleton(
    () => auth_usecases.GetCurrentLocationAddress(getit()),
  );
  getit.registerLazySingleton(() => ForgotPassword(getit()));
  getit.registerLazySingleton(() => ResetPassword(getit()));
  getit.registerLazySingleton(() => GetCurrentCustomer(getit()));
  getit.registerLazySingleton(() => CreateCustomerAddress(getit()));
  getit.registerLazySingleton(() => UpdateCustomerProfile(getit()));

  // Beauty services use cases
  getit.registerLazySingleton(() => GetServices(getit()));
  getit.registerLazySingleton(() => GetServiceCategory(getit()));
  getit.registerLazySingleton(() => GetServiceByCategory(getit()));
  getit.registerLazySingleton(() => GetServiceByStylists(repository: getit()));
  getit.registerLazySingleton(() => GetServiceDetail(getit()));
  getit.registerLazySingleton(() => SearchService(getit()));

  // Home use cases
  getit.registerLazySingleton(() => GetStylists(getit()));
  getit.registerLazySingleton(() => GetDeals(getit()));

  // Stylists use cases
  getit.registerLazySingleton(() => GetStylistDetail(getit()));
  getit.registerLazySingleton(() => GetStylistServices(getit()));
  getit.registerLazySingleton(() => GetNearbyStylists(getit()));
  getit.registerLazySingleton(() => GetStylistByService(getit()));
  getit.registerLazySingleton(() => GetStylistsAvailability(getit()));
  getit.registerLazySingleton(() => GetStylistsAvailabilityByTime(getit()));
  getit.registerLazySingleton(() => GetStylistsAvailabilityByDay(getit()));
  getit.registerLazySingleton(() => UpdateStylistsAvailability(getit()));
  getit.registerLazySingleton(() => SearchStylists(getit()));
  getit.registerLazySingleton(() => GetStylistsService(getit()));

  // Discover use cases
  getit.registerLazySingleton(() => GetClientLocation(getit()));
  getit.registerLazySingleton(() => GetStylistRecommendations(getit()));
  getit.registerLazySingleton(() => GetAvailableSlots(getit()));

  // Booking use cases
  getit.registerLazySingleton(() => CreateBooking(getit()));
  getit.registerLazySingleton(() => CreateBookingWithServices(getit()));
  getit.registerLazySingleton(() => GetCurrentLocationAddress(getit()));
  getit.registerLazySingleton(() => UpdateBooking(repository: getit()));
  getit.registerLazySingleton(() => CancelBooking(getit()));
  getit.registerLazySingleton(() => AddNotesToBooking(repository: getit()));
  getit.registerLazySingleton(() => RescheduleBooking(repository: getit()));
  getit.registerLazySingleton(() => UpdateBookingStatus(repository: getit()));
  getit.registerLazySingleton(() => SearchBookings(getit()));
  getit.registerLazySingleton(() => GetBookings(getit()));
  getit.registerLazySingleton(() => GetBookingById(repository: getit()));
  getit.registerLazySingleton(() => GetBookingsByCustomerId(getit()));
  getit.registerLazySingleton(() => GetBookingsByStylistId(getit()));
  getit.registerLazySingleton(() => GetBookingsByStatus(getit()));
  getit.registerLazySingleton(() => GetBookingServices(getit()));

  // Payment use cases
  getit.registerLazySingleton(
    () => CreateCardPaymentUseCase(paymentRepository: getit()),
  );
  getit.registerLazySingleton(
    () => ConfirmCardPaymentUseCase(paymentRepository: getit()),
  );
  getit.registerLazySingleton(
    () => HandleCardPaymentFailureUseCase(paymentRepository: getit()),
  );
  getit.registerLazySingleton(
    () => GetCardPaymentStatusUseCase(paymentRepository: getit()),
  );
  getit.registerLazySingleton(
    () => CancelPendingCardPaymentUseCase(paymentRepository: getit()),
  );

  // Review use cases
  getit.registerLazySingleton(() => SubmitReviewUsecase(getit()));
  getit.registerLazySingleton(() => GetReviewByStylistIdUsecase(getit()));
  getit.registerLazySingleton(() => GetReviewByCutomerIdUsecase(getit()));
  getit.registerLazySingleton(() => GetReviewByBookingIdUsecase(getit()));
  getit.registerLazySingleton(() => GetRatingSummary(getit()));

  // ===========injectin bloc=================
  getit.registerFactory(
    () => AuthBloc(
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
      getit(),
    ),
  );
  getit.registerFactory(
    () =>
        HomeBloc(getDeals: getit(), getStylists: getit(), getServices: getit()),
  );
  getit.registerFactory(
    () => ServiceBloc(
      getServices: getit(),
      getServiceByCategory: getit(),
      getServiceByStylists: getit(),
      getServiceDetail: getit(),
      searchServices: getit(),
    ),
  );
  getit.registerFactory(
    () => StylistsBloc(
      getit(), // GetStylistsAvailability
      getit(), // GetStylistsAvailabilityByDay
      getit(), // GetStylistsAvailabilityByTime
      getit(), // UpdateStylistsAvailability
      getit(), // GetStylistsService
      getit(), // GetStylists
      getit(), // GetStylistByService
      getit(), // GetStylistDetail
      getit(), // SearchStylists
      getit(), // GetNearbyStylists
      getit(), // GetClientLocation
      getit(), // GetStylistRecommendations
    ),
  );
  getit.registerFactory(
    () => BookingBloc(
      createBooking: getit(),
      createBookingWithServices: getit(),
      updateBooking: getit(),
      cancelBooking: getit(),
      getBookings: getit(),
      getBookingById: getit(),
      getBookingsByCustomerId: getit(),
      getBookingServices: getit(),
      getBookingsByStylistId: getit(),
      getBookingsByStatus: getit(),
      rescheduleBooking: getit(),
      addNotesToBooking: getit(),
      updateBookingStatus: getit(),
      searchBookings: getit(),
      createCustomerAddress: getit(),
      getCurrentLocationAddress: getit(),
      getCurrentCustomer: getit(),
      getStylistServices: getit(),
    ),
  );
  getit.registerFactory(
    () => ReviewBloc(
      submitReview: getit(),
      getReviewsByStylistId: getit(),
      getReviewsByCustomerId: getit(),
      getReviewByBookingId: getit(),
      getRatingSummary: getit(),
    ),
  );
  getit.registerFactory(
    () => PaymentBloc(
      createCardPayment: getit(),
      confirmCardPayment: getit(),
      handleCardPaymentFailure: getit(),
      getCardPaymentStatus: getit(),
      cancelPendingCardPayment: getit(),
    ),
  );

  //
}

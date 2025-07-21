#!/bin/bash

# Main files
touch lib/main.dart
touch lib/injection_container.dart
touch lib/firebase_options.dart

# Config files
touch lib/config/supabase_config.dart
touch lib/config/env.dart
touch lib/config/router_config.dart

# Core files
touch lib/core/constants/app_colors.dart
touch lib/core/constants/app_text_styles.dart
touch lib/core/constants/app_icons.dart
touch lib/core/constants/app_images.dart
touch lib/core/constants/supabase_constants.dart
touch lib/core/constants/app_strings.dart

touch lib/core/errors/exceptions.dart
touch lib/core/errors/failures.dart
touch lib/core/errors/error_handler.dart

touch lib/core/network/network_info.dart
touch lib/core/network/dio_client.dart

touch lib/core/theme/app_theme.dart
touch lib/core/theme/theme_provider.dart
touch lib/core/theme/dark_theme.dart

touch lib/core/utils/validators.dart
touch lib/core/utils/formatters.dart
touch lib/core/utils/extensions.dart
touch lib/core/utils/date_time_utils.dart
touch lib/core/utils/debouncer.dart
touch lib/core/utils/logger.dart

touch lib/core/widgets/loading_indicator.dart
touch lib/core/widgets/error_snackbar.dart
touch lib/core/widgets/custom_app_bar.dart
touch lib/core/widgets/empty_state.dart
touch lib/core/widgets/retry_button.dart

# Shared files
touch lib/shared/models/booking_model.dart
touch lib/shared/models/review_model.dart

touch lib/shared/widgets/booking/booking_status_chip.dart
touch lib/shared/widgets/booking/reschedule_button.dart

touch lib/shared/widgets/beauty/service_rating_bar.dart
touch lib/shared/widgets/beauty/beautician_card.dart

# Routes files
touch lib/routes/app_router.dart
touch lib/routes/route_names.dart
touch lib/routes/route_transitions.dart

# Auth feature
touch lib/features/auth/data/datasources/auth_remote_data_source.dart
touch lib/features/auth/data/datasources/auth_local_data_source.dart
touch lib/features/auth/data/models/client_model.dart
touch lib/features/auth/data/repositories/auth_repository_impl.dart

touch lib/features/auth/domain/entities/client.dart
touch lib/features/auth/domain/repositories/auth_repository.dart
touch lib/features/auth/domain/usecases/sign_in.dart
touch lib/features/auth/domain/usecases/sign_up.dart
touch lib/features/auth/domain/usecases/sign_out.dart
touch lib/features/auth/domain/usecases/get_current_client.dart
touch lib/features/auth/domain/usecases/update_client_profile.dart

touch lib/features/auth/presentation/bloc/auth_bloc.dart
touch lib/features/auth/presentation/bloc/auth_event.dart
touch lib/features/auth/presentation/bloc/auth_state.dart

touch lib/features/auth/presentation/screens/welcome_screen.dart
touch lib/features/auth/presentation/screens/login_screen.dart
touch lib/features/auth/presentation/screens/signup_screen.dart
touch lib/features/auth/presentation/screens/forgot_password_screen.dart

touch lib/features/auth/presentation/widgets/auth_header.dart
touch lib/features/auth/presentation/widgets/auth_footer.dart
touch lib/features/auth/presentation/widgets/client_auth_form.dart
touch lib/features/auth/presentation/widgets/password_strength_meter.dart
touch lib/features/auth/presentation/widgets/password_visibility_toggle.dart

# Home feature
touch lib/features/home/data/repositories/home_repository_impl.dart

touch lib/features/home/domain/usecases/get_featured_pros.dart
touch lib/features/home/domain/usecases/get_deals.dart

touch lib/features/home/presentation/bloc/home_bloc.dart
touch lib/features/home/presentation/screens/home_screen.dart

touch lib/features/home/presentation/widgets/greeting_header.dart
touch lib/features/home/presentation/widgets/search_bar.dart
touch lib/features/home/presentation/widgets/category_grid.dart
touch lib/features/home/presentation/widgets/featured_pros.dart
touch lib/features/home/presentation/widgets/special_offers.dart
touch lib/features/home/presentation/widgets/trending_services.dart

# Services feature
touch lib/features/services/data/datasources/service_remote_data_source.dart
touch lib/features/services/data/models/service_model.dart
touch lib/features/services/data/models/category_model.dart
touch lib/features/services/data/repositories/service_repository_impl.dart

touch lib/features/services/domain/entities/service.dart
touch lib/features/services/domain/entities/category.dart
touch lib/features/services/domain/repositories/service_repository.dart
touch lib/features/services/domain/usecases/get_services.dart
touch lib/features/services/domain/usecases/get_categories.dart
touch lib/features/services/domain/usecases/get_service_detail.dart
touch lib/features/services/domain/usecases/search_services.dart

touch lib/features/services/presentation/bloc/service_bloc.dart
touch lib/features/services/presentation/bloc/category_bloc.dart

touch lib/features/services/presentation/screens/service_list_screen.dart
touch lib/features/services/presentation/screens/service_detail_screen.dart
touch lib/features/services/presentation/screens/category_screen.dart

touch lib/features/services/presentation/widgets/service_card.dart
touch lib/features/services/presentation/widgets/category_chip.dart
touch lib/features/services/presentation/widgets/service_detail_header.dart
touch lib/features/services/presentation/widgets/service_info_section.dart
touch lib/features/services/presentation/widgets/service_provider_card.dart
touch lib/features/services/presentation/widgets/review_list.dart

# Bookings feature
touch lib/features/bookings/data/datasources/booking_remote_data_source.dart
touch lib/features/bookings/data/models/booking_model.dart
touch lib/features/bookings/data/repositories/booking_repository_impl.dart

touch lib/features/bookings/domain/entities/booking.dart
touch lib/features/bookings/domain/repositories/booking_repository.dart
touch lib/features/bookings/domain/usecases/create_booking.dart
touch lib/features/bookings/domain/usecases/cancel_booking.dart
touch lib/features/bookings/domain/usecases/get_bookings.dart
touch lib/features/bookings/domain/usecases/reschedule_booking.dart

touch lib/features/bookings/presentation/bloc/booking_bloc.dart

touch lib/features/bookings/presentation/screens/booking_list_screen.dart
touch lib/features/bookings/presentation/screens/booking_detail_screen.dart
touch lib/features/bookings/presentation/screens/booking_confirmation_screen.dart
touch lib/features/bookings/presentation/screens/booking_reschedule_screen.dart

touch lib/features/bookings/presentation/widgets/booking_card.dart
touch lib/features/bookings/presentation/widgets/booking_timeline.dart
touch lib/features/bookings/presentation/widgets/booking_status_badge.dart
touch lib/features/bookings/presentation/widgets/calendar_picker.dart

# Professionals feature
touch lib/features/professionals/data/models/professional_model.dart

touch lib/features/professionals/presentation/screens/professional_detail_screen.dart

touch lib/features/professionals/presentation/widgets/professional_card.dart
touch lib/features/professionals/presentation/widgets/rating_bar.dart

# Profile feature
touch lib/features/profile/data/repositories/profile_repository_impl.dart

touch lib/features/profile/domain/usecases/get_profile.dart
touch lib/features/profile/domain/usecases/update_profile.dart

touch lib/features/profile/presentation/bloc/profile_bloc.dart

touch lib/features/profile/presentation/screens/profile_screen.dart
touch lib/features/profile/presentation/screens/edit_profile_screen.dart
touch lib/features/profile/presentation/screens/past_bookings_screen.dart
touch lib/features/profile/presentation/screens/settings_screen.dart
touch lib/features/profile/presentation/screens/help_center_screen.dart

touch lib/features/profile/presentation/widgets/profile_header.dart
touch lib/features/profile/presentation/widgets/profile_menu_item.dart
touch lib/features/profile/presentation/widgets/setting_tile.dart

# Notifications feature
touch lib/features/notifications/presentation/screens/notifications_screen.dart
touch lib/features/notifications/presentation/widgets/notification_item.dart

# Payments feature
touch lib/features/payments/data/models/payment_model.dart

touch lib/features/payments/presentation/screens/payment_methods_screen.dart
touch lib/features/payments/presentation/screens/payment_success_screen.dart

# Reviews feature
touch lib/features/reviews/presentation/screens/write_review_screen.dart
touch lib/features/reviews/presentation/widgets/review_form.dart

echo "All files created successfully!"
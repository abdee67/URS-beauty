# URS Beauty

Customer-facing Flutter app for the UR Beauty platform.

This app lets customers discover beauty services, find nearby stylists, book
appointments, manage bookings, make card payments, review services, and manage
their profile.

## Related Repositories

This app is part of the UR Beauty workspace:

```text
C:\flutterApps\ur_beauty\
  ur_backend\   # Supabase backend repo
  urs_beauty\   # Customer Flutter app
  ur_stylist\   # Stylist Flutter app
```

Backend changes should be made in `ur_backend`, not inside this app repo. This
keeps Supabase migrations, Edge Functions, RLS policies, and payment logic in one
shared source of truth for both apps.

## Main Features

- Customer sign up, sign in, password reset, and OTP verification
- Customer profile and address management
- Beauty service categories, service listings, and service detail pages
- Stylist discovery, search, profile pages, and nearby stylist recommendations
- Location-based discovery using maps and device location
- Booking creation, scheduling, cancellation, and rescheduling
- Payment flow using Stripe and Supabase Edge Functions
- Booking history and booking status tracking
- Reviews and rating summaries
- Deals, notifications, chat screens, and profile settings

## Tech Stack

- Flutter and Dart
- Supabase Auth, Database, Storage, and Edge Functions
- Stripe payments through `flutter_stripe`
- `flutter_bloc` for state management
- `get_it` for dependency injection
- `go_router` for navigation
- `provider` for app-level providers
- Google Maps, geolocation, and geocoding packages

## Project Structure

```text
lib/
  api/                 # API helpers and Stripe API service
  config/              # Supabase and routing config
  core/                # Shared constants, errors, theme, utilities, widgets
  features/            # App features organized by domain
  routes/              # App router and route names
  shared/              # Shared models and reusable widgets
  injection_container.dart
  main.dart
```

Feature modules generally follow a layered structure:

```text
features/<feature>/
  data/
  domain/
  presentation/
```

## Environment Setup

The app loads environment values from:

```text
assets/.env
```

Required keys:

```env
SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=
STRIPE_PUBLISHABLE_KEY=
```

Optional Stripe key:

```env
STRIPE_MERCHANT_IDENTIFIER=
```

`assets/.env` is already ignored by Git. Do not commit real Supabase, Stripe, or
payment-related secrets.

## Backend Dependency

This app depends on the shared Supabase backend in:

```text
C:\flutterApps\ur_beauty\ur_backend
```

Expected backend resources include:

- Supabase auth configuration
- Customer, stylist, service, booking, review, and payment tables
- RLS policies for customer access
- Booking RPC/functions and availability logic
- Payment Edge Functions:
  - `create-card-payment`
  - `verify-card-payment`
  - `cancel-card-payment`
  - `calculate-refund-payment`
  - `process-refund-payment`

When an app feature requires a database or Edge Function change, update and
deploy the backend from `ur_backend` first.

## Local Development

Install dependencies:

```powershell
flutter pub get
```

Run the app:

```powershell
flutter run
```

Run static analysis:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

## Platform Notes

The app includes Android, iOS, web, Windows, macOS, and Linux Flutter folders.
Mobile platforms are the primary target for customer booking, location, and
payment flows.

Stripe uses the URL scheme:

```text
ursbeauty
```

Keep Android and iOS payment configuration aligned with the Stripe settings in
`lib/main.dart`.

## Development Rules

- Keep Flutter UI and customer app behavior in this repo.
- Keep Supabase schema, migrations, RLS, and Edge Functions in `ur_backend`.
- Do not recreate a `supabase/` folder in this app unless there is a deliberate
  reason to change the architecture.
- Do not commit `.env` files, keys, local build outputs, or generated caches.
- Update this README when setup steps, required environment keys, or backend
  dependencies change.

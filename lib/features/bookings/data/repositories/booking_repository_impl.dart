import 'package:dartz/dartz.dart';
import 'package:urs_beauty/core/errors/failures.dart';
import 'package:urs_beauty/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:urs_beauty/features/bookings/data/models/booking_model.dart';
import 'package:urs_beauty/features/bookings/data/models/create_booking_request_model.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_entity.dart';
import 'package:urs_beauty/features/bookings/domain/entities/booking_services.dart';
import 'package:urs_beauty/features/bookings/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({required this.remoteDataSource});

  final BookingRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failures, BookingEntity>> createBooking(
    BookingEntity booking,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.createBooking(
        _mapBookingEntityToModel(booking),
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, BookingEntity>> createBookingWithServices(
    CreateBookingRequestModel request,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.createBookingWithServices(request);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, BookingEntity>> updateBooking(
    BookingEntity booking,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.updateBooking(
        _mapBookingEntityToModel(booking),
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, void>> cancelBooking(String bookingId) async {
    return _runOperation(() async {
      await remoteDataSource.cancelBooking(bookingId);
    });
  }

  @override
  Future<Either<Failures, List<BookingEntity>>> getBookings() async {
    return _runOperation(() async {
      final result = await remoteDataSource.getBookings();
      return result
          .map<BookingEntity>((booking) => booking.toEntity())
          .toList();
    });
  }

  @override
  Future<Either<Failures, BookingEntity>> getBookingById(
    String bookingId,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.getBookingById(bookingId);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, List<BookingEntity>>> getBookingsByCustomerId(
    String customerId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getBookingsByCustomerId(customerId);
      return result
          .map<BookingEntity>((booking) => booking.toEntity())
          .toList();
    });
  }

  @override
  Future<Either<Failures, List<BookingServicesEntity>>> getBookingServices(
    String bookingId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getBookingServices(bookingId);
      return result
          .map<BookingServicesEntity>((service) => service.toEntity())
          .toList();
    });
  }

  @override
  Future<Either<Failures, List<BookingEntity>>> getBookingsByStylistId(
    String stylistId,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getBookingsByStylistId(stylistId);
      return result
          .map<BookingEntity>((booking) => booking.toEntity())
          .toList();
    });
  }

  @override
  Future<Either<Failures, List<BookingEntity>>> getBookingsByStatus(
    String status,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.getBookingsByStatus(status);
      return result
          .map<BookingEntity>((booking) => booking.toEntity())
          .toList();
    });
  }

  @override
  Future<Either<Failures, BookingEntity>> rescheduleBooking(
    String bookingId,
    DateTime newScheduledAt,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.rescheduleBooking(
        bookingId,
        newScheduledAt,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, BookingEntity>> addNotesToBooking(
    String bookingId,
    String notes,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.addNotesToBooking(bookingId, notes);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    return _runBookingOperation(() async {
      final result = await remoteDataSource.updateBookingStatus(
        bookingId,
        status,
      );
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failures, List<BookingEntity>>> searchBookings(
    String query,
  ) async {
    return _runOperation(() async {
      final result = await remoteDataSource.searchBookings(query);
      return result
          .map<BookingEntity>((booking) => booking.toEntity())
          .toList();
    });
  }

  Future<Either<Failures, BookingEntity>> _runBookingOperation(
    Future<BookingEntity> Function() operation,
  ) async {
    return _runOperation(operation);
  }

  Future<Either<Failures, T>> _runOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return Right(await operation());
    } on Failures catch (failure) {
      return Left(failure);
    } catch (error) {
      return Left(Failures(message: error.toString()));
    }
  }

  BookingModel _mapBookingEntityToModel(BookingEntity booking) {
    return BookingModel(
      id: booking.id,
      customerId: booking.customerId,
      stylistId: booking.stylistId,
      status: booking.status,
      notes: booking.notes,
      address: booking.address,
      totalAmount: booking.totalAmount,
      scheduledAt: booking.scheduledAt,
      endAt: booking.endAt,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }
}

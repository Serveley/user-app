import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/vendor.dart';
import '../services/api_service.dart';

// Events
abstract class VendorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVendors extends VendorEvent {
  final String? serviceId;
  final double? lat;
  final double? lng;
  LoadVendors({this.serviceId, this.lat, this.lng});
  @override
  List<Object?> get props => [serviceId, lat, lng];
}

class SearchVendors extends VendorEvent {
  final String? query;
  final String? serviceId;
  final double? lat;
  final double? lng;
  SearchVendors({this.query, this.serviceId, this.lat, this.lng});
  @override
  List<Object?> get props => [query, serviceId, lat, lng];
}

class LoadVendorDetails extends VendorEvent {
  final String vendorId;
  LoadVendorDetails(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

// States
abstract class VendorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorsLoaded extends VendorState {
  final List<Vendor> vendors;
  VendorsLoaded(this.vendors);
  @override
  List<Object?> get props => [vendors];
}

class VendorDetailsLoaded extends VendorState {
  final Vendor vendor;
  VendorDetailsLoaded(this.vendor);
  @override
  List<Object?> get props => [vendor];
}

class VendorError extends VendorState {
  final String message;
  VendorError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class VendorBloc extends Bloc<VendorEvent, VendorState> {
  VendorBloc() : super(VendorInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<SearchVendors>(_onSearchVendors);
    on<LoadVendorDetails>(_onLoadVendorDetails);
  }

  Future<void> _onLoadVendors(LoadVendors event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      final vendors = await ApiService.getVendors(
        serviceId: event.serviceId,
        lat: event.lat,
        lng: event.lng,
      );
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError('Failed to load vendors'));
    }
  }

  Future<void> _onSearchVendors(SearchVendors event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      final vendors = await ApiService.searchVendors(
        query: event.query,
        serviceId: event.serviceId,
        lat: event.lat,
        lng: event.lng,
      );
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorError('Failed to search vendors'));
    }
  }

  Future<void> _onLoadVendorDetails(LoadVendorDetails event, Emitter<VendorState> emit) async {
    emit(VendorLoading());
    try {
      final vendor = await ApiService.getVendorById(event.vendorId);
      if (vendor != null) {
        emit(VendorDetailsLoaded(vendor));
      } else {
        emit(VendorError('Vendor not found'));
      }
    } catch (e) {
      emit(VendorError('Failed to load vendor details'));
    }
  }
}

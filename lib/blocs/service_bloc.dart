import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/service.dart';
import '../services/api_service.dart';

// Events
abstract class ServiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadServices extends ServiceEvent {}

class LoadServicesByCategory extends ServiceEvent {
  final String category;
  LoadServicesByCategory(this.category);
  @override
  List<Object?> get props => [category];
}

// States
abstract class ServiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServicesLoaded extends ServiceState {
  final List<Service> services;
  final List<String> categories;
  ServicesLoaded(this.services, this.categories);
  @override
  List<Object?> get props => [services, categories];
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServices>(_onLoadServices);
    on<LoadServicesByCategory>(_onLoadServicesByCategory);
  }

  Future<void> _onLoadServices(LoadServices event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    try {
      final services = await ApiService.getServices();
      final categories = await ApiService.getCategories();
      emit(ServicesLoaded(services, categories));
    } catch (e) {
      emit(ServiceError('Failed to load services'));
    }
  }

  Future<void> _onLoadServicesByCategory(LoadServicesByCategory event, Emitter<ServiceState> emit) async {
    emit(ServiceLoading());
    try {
      final services = await ApiService.getServicesByCategory(event.category);
      final categories = await ApiService.getCategories();
      emit(ServicesLoaded(services, categories));
    } catch (e) {
      emit(ServiceError('Failed to load services'));
    }
  }
}

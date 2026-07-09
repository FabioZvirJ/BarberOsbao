import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<Customer> createCustomer(Customer customer);
}

class MockCustomerRepository implements CustomerRepository {
  final List<Customer> _customers = [
    const Customer(
      id: 'c_1',
      name: 'Ana Silva',
      email: 'ana@example.com',
      phone: '(11) 98888-8888',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&width=150',
    ),
    const Customer(
      id: 'c_2',
      name: 'Bruno Gomes',
      email: 'bruno@example.com',
      phone: '(11) 97777-7777',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&width=150',
    ),
    const Customer(
      id: 'c_3',
      name: 'Carlos Sousa',
      email: 'carlos@example.com',
      phone: '(11) 96666-6666',
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?q=80&width=150',
    ),
    const Customer(
      id: 'c_4',
      name: 'Diego Lima',
      email: 'diego@example.com',
      phone: '(11) 95555-5555',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&width=150',
    ),
    const Customer(
      id: 'c_5',
      name: 'Eduardo Rocha',
      email: 'edu@example.com',
      phone: '(11) 94444-4444',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&width=150',
    ),
  ];

  @override
  Future<List<Customer>> getCustomers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_customers);
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newCustomer = customer.copyWith(id: 'c_${_customers.length + 1}');
    _customers.add(newCustomer);
    return newCustomer;
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return MockCustomerRepository();
});

final customersListProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return await repo.getCustomers();
});

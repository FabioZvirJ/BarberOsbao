import 'package:barber_osbao/packages/core/models/user.dart';
import 'package:barber_osbao/packages/core/models/customer.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/plan.dart';
import 'package:barber_osbao/packages/core/models/membership.dart';
import 'package:barber_osbao/packages/core/models/review.dart';
import 'package:barber_osbao/packages/core/models/notification_model.dart';

class MockData {
  MockData._();

  static final User loggedUser = User(
    id: 'usr_1',
    name: 'Fabio Zvir',
    email: 'fabio@barberosbao.com.br',
    phone: '(11) 99999-9999',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
    theme: 'dark',
    language: 'pt-BR',
    emailNotifications: true,
    pushNotifications: true,
    whatsappNotifications: false,
  );

  static final List<Barber> barbers = [
    const Barber(
      id: 'barb_1',
      name: 'Marcos Silva',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&width=150',
      rating: 4.9,
      specialties: ['Corte Clássico', 'Barboterapia', 'Degradê'],
      bio: 'Especialista em cortes clássicos e barboterapia com mais de 8 anos de experiência.',
      availableDays: ['2026-07-08', '2026-07-09', '2026-07-10', '2026-07-11', '2026-07-13', '2026-07-14'],
      availableHours: ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'],
    ),
    const Barber(
      id: 'barb_2',
      name: 'Arthur Santos',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&width=150',
      rating: 4.8,
      specialties: ['Corte Moderno', 'Platinado', 'Design de Sobrancelha'],
      bio: 'Referência em cortes modernos, fade e colorimetria avançada.',
      availableDays: ['2026-07-08', '2026-07-09', '2026-07-10', '2026-07-11', '2026-07-13', '2026-07-14'],
      availableHours: ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'],
    ),
    const Barber(
      id: 'barb_3',
      name: 'Gabriel Neves',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&width=150',
      rating: 4.7,
      specialties: ['Corte na Tesoura', 'Barba Tradicional'],
      bio: 'Especialista em visagismo e finalizações clássicas na tesoura.',
      availableDays: ['2026-07-08', '2026-07-09', '2026-07-10', '2026-07-11', '2026-07-13', '2026-07-14'],
      availableHours: ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'],
    ),
  ];

  static final List<ServiceModel> services = [
    const ServiceModel(
      id: 'srv_1',
      name: 'Corte de Cabelo',
      category: 'cabelo',
      price: 45.0,
      durationMinutes: 30,
      iconName: 'scissors',
      description: 'Corte completo com lavagem inclusa e finalização com pomada premium.',
    ),
    const ServiceModel(
      id: 'srv_2',
      name: 'Barba Completa',
      category: 'barba',
      price: 35.0,
      durationMinutes: 30,
      iconName: 'beard',
      description: 'Modelagem de barba com toalha quente, óleo hidratante e massagem facial.',
    ),
    const ServiceModel(
      id: 'srv_3',
      name: 'Design de Sobrancelha',
      category: 'sobrancelha',
      price: 20.0,
      durationMinutes: 15,
      iconName: 'eye',
      description: 'Limpeza e alinhamento de sobrancelha com navalha ou pinça.',
    ),
    const ServiceModel(
      id: 'srv_4',
      name: 'Combo Cabelo + Barba',
      category: 'combo',
      price: 70.0,
      durationMinutes: 60,
      iconName: 'combo',
      description: 'O serviço completo dos reis: corte personalizado e barba completa com toalha quente.',
    ),
  ];

  static final List<Plan> plans = [
    const Plan(
      id: 'plan_1',
      name: 'Plano Cavalheiro',
      price: 89.90,
      period: 'mensal',
      benefits: [
        'Até 2 cortes de cabelo por mês',
        'Reserva online com prioridade',
        '1 dose de Chopp cortesia por visita',
      ],
      recommended: false,
    ),
    const Plan(
      id: 'plan_2',
      name: 'Plano Barão',
      price: 139.90,
      period: 'mensal',
      benefits: [
        'Cortes de cabelo ilimitados',
        'Até 2 barbas por mês',
        'Chopp e água liberados',
        '10% de desconto em produtos',
      ],
      recommended: true,
    ),
    const Plan(
      id: 'plan_3',
      name: 'Plano Imperial',
      price: 199.90,
      period: 'mensal',
      benefits: [
        'Cabelo e barba ilimitados',
        'Sobrancelha inclusa',
        'Atendimento exclusivo VIP sem fila',
        'Bebidas liberadas no bar',
        '15% de desconto em produtos',
      ],
      recommended: false,
    ),
  ];

  static final Membership activeMembership = Membership(
    id: 'mem_1',
    userId: 'usr_1',
    planId: 'plan_2',
    planName: 'Plano Barão',
    startDate: '2026-06-07',
    endDate: '2026-07-07',
    status: 'active',
    remainingBenefits: [
      'Cortes de Cabelo Ilimitados',
      '1 Barba Restante (de 2)',
      '10% Desconto em Produtos',
    ],
    discountsUsed: 3,
    nextRenewalDate: '2026-07-07',
  );

  static final List<Appointment> appointments = [
    Appointment(
      id: 'apt_1',
      userId: 'usr_1',
      barberId: 'barb_1',
      barberName: 'Marcos Silva',
      barberAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&width=150',
      services: [services[0]],
      date: '2026-07-08',
      time: '14:00',
      totalValue: 45.0,
      status: 'confirmed',
      notes: 'Gostaria de degradê baixo nas laterais.',
    ),
    Appointment(
      id: 'apt_2',
      userId: 'usr_1',
      barberId: 'barb_2',
      barberName: 'Arthur Santos',
      barberAvatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&width=150',
      services: [services[3]],
      date: '2026-06-20',
      time: '10:00',
      totalValue: 70.0,
      status: 'completed',
    ),
  ];

  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'not_1',
      userId: 'usr_1',
      title: 'Lembrete de Agendamento',
      message: 'Seu corte de cabelo com Marcos Silva está agendado para amanhã às 14:00.',
      type: 'info',
      read: false,
      createdAt: '2026-07-07T18:00:00Z',
    ),
    NotificationModel(
      id: 'not_2',
      userId: 'usr_1',
      title: 'Assinatura Ativada',
      message: 'Parabéns, você agora é um membro oficial do Clube Cavalheiro (Plano Barão)!',
      type: 'success',
      read: true,
      createdAt: '2026-06-07T10:00:00Z',
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'rev_1',
      scheduleId: 'apt_2',
      userId: 'usr_1',
      userName: 'Fabio Zvir',
      barberId: 'barb_2',
      rating: 5,
      comment: 'Corte excelente e atendimento sensacional do Arthur. Barba impecável!',
      createdAt: '2026-06-20T11:15:00Z',
    ),
  ];
}

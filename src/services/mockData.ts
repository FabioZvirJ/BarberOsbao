import { User, Barber, Service, Schedule, Plan, Membership, Notification, Review } from '../types';

// Helper to load/save from localStorage
const LOCAL_STORAGE_KEY = 'barber_osbao_mock_db';

export interface MockDatabase {
  currentUser: User;
  barbers: Barber[];
  services: Service[];
  plans: Plan[];
  memberships: Membership[];
  schedules: Schedule[];
  notifications: Notification[];
  reviews: Review[];
}

const INITIAL_USER: User = {
  id: 'usr-1',
  name: 'Fábio Zvir',
  email: 'fabio@barberosbao.com.br',
  phone: '(11) 98765-4321',
  avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=150&h=150',
  preferences: {
    theme: 'dark',
    language: 'pt-BR',
    notifications: {
      email: true,
      push: true,
      whatsapp: true
    },
    privacy: {
      shareData: false,
      profilePublic: true
    }
  }
};

const INITIAL_SERVICES: Service[] = [
  {
    id: 'srv-1',
    name: 'Corte de Cabelo',
    category: 'cabelo',
    price: 45.00,
    durationMinutes: 30,
    iconName: 'scissors',
    description: 'Corte clássico ou moderno, adaptado ao seu estilo. Inclui lavagem simples.'
  },
  {
    id: 'srv-2',
    name: 'Barba',
    category: 'barba',
    price: 35.00,
    durationMinutes: 30,
    iconName: 'beard',
    description: 'Aparado, alinhamento com toalha quente e finalização com balm premium.'
  },
  {
    id: 'srv-3',
    name: 'Sobrancelha',
    category: 'sobrancelha',
    price: 20.00,
    durationMinutes: 15,
    iconName: 'eyebrow',
    description: 'Design de sobrancelha na pinça ou na navalha para realçar o olhar.'
  },
  {
    id: 'srv-4',
    name: 'Combo',
    category: 'combo',
    price: 90.00,
    durationMinutes: 75,
    iconName: 'combo',
    description: 'O pacote completo: Corte de Cabelo, Barba, Sobrancelha e uma massagem capilar.'
  }
];

const INITIAL_BARBERS: Barber[] = [
  {
    id: 'brb-1',
    name: 'Marcos Silva (Mestre)',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150&h=150',
    rating: 4.9,
    specialties: ['Corte Clássico', 'Fade/Degradê', 'Barba Terapia'],
    bio: 'Mais de 10 anos de experiência com tesoura e navalha. Especialista em visagismo.',
    availableDays: [], // Dynamically generated
    availableHours: ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00']
  },
  {
    id: 'brb-2',
    name: 'Thiago Neves',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150&h=150',
    rating: 4.8,
    specialties: ['Corte Moderno', 'Platinados', 'Desenho/Risco'],
    bio: 'Especialista em cortes urbanos e tendências modernas de penteado.',
    availableDays: [],
    availableHours: ['09:30', '10:30', '11:30', '13:30', '14:30', '15:30', '16:30', '17:30', '18:30']
  },
  {
    id: 'brb-3',
    name: 'Lucas Souza',
    avatarUrl: 'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?auto=format&fit=crop&q=80&w=150&h=150',
    rating: 4.7,
    specialties: ['Barboterapia', 'Sobrancelha', 'Penteados'],
    bio: 'Foco no bem-estar e no relaxamento durante os cuidados com a barba.',
    availableDays: [],
    availableHours: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00', '18:00']
  }
];

const INITIAL_PLANS: Plan[] = [
  {
    id: 'pln-1',
    name: 'Plano Cavalheiro',
    price: 89.90,
    period: 'mensal',
    benefits: [
      '2 Cortes de Cabelo por mês',
      '1 Design de Sobrancelha grátis',
      '10% de desconto em produtos',
      'Atendimento prioritário sem fila'
    ]
  },
  {
    id: 'pln-2',
    name: 'Plano Barão (Mais Popular)',
    price: 139.90,
    period: 'mensal',
    benefits: [
      'Cortes de Cabelo ILIMITADOS',
      '2 Serviços de Barba por mês',
      'Sobrancelha livre inclusa',
      '15% de desconto em produtos',
      '1 Cerveja ou café cortesia por visita'
    ],
    recommended: true
  },
  {
    id: 'pln-3',
    name: 'Plano Imperial',
    price: 199.90,
    period: 'mensal',
    benefits: [
      'Cortes e Barbas ILIMITADOS',
      'Todos os serviços extras inclusos (Sobrancelha, Selagem)',
      '20% de desconto em produtos',
      'Bebidas liberadas no bar (Cerveja/Café/Água)',
      'Acesso ao lounge VIP da barbearia'
    ]
  }
];

const INITIAL_NOTIFICATIONS: Notification[] = [
  {
    id: 'ntf-1',
    userId: 'usr-1',
    title: 'Bem-vindo à Barbearia Osbão!',
    message: 'Obrigado por criar sua conta. Explore nossos serviços e agende seu horário.',
    type: 'success',
    read: false,
    createdAt: new Date().toISOString()
  },
  {
    id: 'ntf-2',
    userId: 'usr-1',
    title: 'Clube do Assinante',
    message: 'Assine um de nossos planos e ganhe cortes ilimitados com descontos imperdíveis.',
    type: 'info',
    read: false,
    createdAt: new Date(Date.now() - 3600000 * 2).toISOString()
  }
];

const INITIAL_REVIEWS: Review[] = [
  {
    id: 'rev-1',
    scheduleId: 'sch-past-1',
    userId: 'usr-1',
    userName: 'Fábio Zvir',
    barberId: 'brb-1',
    rating: 5,
    comment: 'Atendimento excepcional do Marcos, corte perfeito e café maravilhoso.',
    createdAt: new Date(Date.now() - 3600000 * 24 * 18).toISOString()
  }
];

const INITIAL_SCHEDULES: Schedule[] = [
  {
    id: 'sch-past-1',
    userId: 'usr-1',
    barberId: 'brb-1',
    barberName: 'Marcos Silva (Mestre)',
    barberAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=150&h=150',
    services: [INITIAL_SERVICES[0]], // Corte
    date: new Date(Date.now() - 3600000 * 24 * 18).toISOString().split('T')[0], // 18 days ago
    time: '14:00',
    totalValue: 45.00,
    status: 'completed'
  }
];

// Helper to fill next 14 days availability for barbers
const populateBarberAvailability = (barbers: Barber[]): Barber[] => {
  const next14Days: string[] = [];
  for (let i = 0; i < 14; i++) {
    const d = new Date();
    d.setDate(d.getDate() + i);
    next14Days.push(d.toISOString().split('T')[0]);
  }
  return barbers.map(barber => ({
    ...barber,
    availableDays: next14Days
  }));
};

export const getInitialDB = (): MockDatabase => {
  const stored = localStorage.getItem(LOCAL_STORAGE_KEY);
  if (stored) {
    try {
      return JSON.parse(stored);
    } catch (e) {
      console.error('Failed to parse mock database, resetting', e);
    }
  }

  const db: MockDatabase = {
    currentUser: INITIAL_USER,
    barbers: populateBarberAvailability(INITIAL_BARBERS),
    services: INITIAL_SERVICES,
    plans: INITIAL_PLANS,
    memberships: [], // Initially no active plan as per mockup
    schedules: INITIAL_SCHEDULES,
    notifications: INITIAL_NOTIFICATIONS,
    reviews: INITIAL_REVIEWS
  };

  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(db));
  return db;
};

export const saveDB = (db: MockDatabase) => {
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(db));
};

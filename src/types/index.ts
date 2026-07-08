export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  avatarUrl: string;
  preferences: {
    theme: 'dark' | 'light';
    language: 'pt-BR' | 'en';
    notifications: {
      email: boolean;
      push: boolean;
      whatsapp: boolean;
    };
    privacy: {
      shareData: boolean;
      profilePublic: boolean;
    };
  };
}

export interface Barber {
  id: string;
  name: string;
  avatarUrl: string;
  rating: number;
  specialties: string[];
  bio: string;
  availableDays: string[]; // e.g. ["2026-07-08", "2026-07-09"]
  availableHours: string[]; // e.g. ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00"]
}

export type ServiceCategory = 'cabelo' | 'barba' | 'sobrancelha' | 'combo';

export interface Service {
  id: string;
  name: string;
  category: ServiceCategory;
  price: number;
  durationMinutes: number;
  iconName: string; // e.g. "Scissors", "Beard" (Lucide icon name representation)
  description: string;
}

export type ScheduleStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled';

export interface Schedule {
  id: string;
  userId: string;
  barberId: string;
  barberName: string;
  barberAvatar: string;
  services: Service[];
  date: string; // "YYYY-MM-DD"
  time: string; // "HH:MM"
  totalValue: number;
  status: ScheduleStatus;
  notes?: string;
}

export interface Plan {
  id: string;
  name: string;
  price: number;
  period: 'mensal' | 'anual';
  benefits: string[];
  recommended?: boolean;
}

export interface Membership {
  id: string;
  userId: string;
  planId: string;
  planName: string;
  startDate: string;
  endDate: string;
  status: 'active' | 'inactive' | 'expired';
  remainingBenefits: string[];
  discountsUsed: number;
  nextRenewalDate: string;
}

export interface Notification {
  id: string;
  userId: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'alert';
  read: boolean;
  createdAt: string;
}

export type PaymentMethod = 'pix' | 'credit_card' | 'stripe' | 'mercado_pago';
export type PaymentStatus = 'pending' | 'paid' | 'failed' | 'refunded';

export interface Payment {
  id: string;
  scheduleId?: string;
  membershipId?: string;
  amount: number;
  method: PaymentMethod;
  status: PaymentStatus;
  transactionCode: string;
  qrCodeData?: string; // For Pix
  createdAt: string;
}

export interface Review {
  id: string;
  scheduleId: string;
  userId: string;
  userName: string;
  barberId: string;
  rating: number; // 1-5
  comment: string;
  createdAt: string;
}

export interface Address {
  id: string;
  street: string;
  number: string;
  neighborhood: string;
  city: string;
  state: string;
  zipCode: string;
  complement?: string;
}

import { useState, useEffect } from 'react';
import { Sidebar, SidebarTab } from './components/Sidebar';
import { Header } from './components/Header';
import { DashboardCards } from './components/DashboardCards';
import { ServicesSection } from './components/ServicesSection';
import { LastVisitCard } from './components/LastVisitCard';
import { BookingModal } from './components/BookingModal';
import { ScheduleManagement } from './components/ScheduleManagement';
import { ProfileView } from './components/ProfileView';
import { MembershipView } from './components/MembershipView';
import { PlansView } from './components/PlansView';
import { SettingsView } from './components/SettingsView';
import { FeedbackToast, Toast } from './components/FeedbackToast';
import { StateContainer } from './components/StateContainer';

// Services
import { UserService } from './services/userService';
import { BarberService } from './services/barberService';
import { ServiceService } from './services/serviceService';
import { ScheduleService } from './services/scheduleService';
import { MembershipService } from './services/membershipService';
import { NotificationService } from './services/notificationService';

// Types
import { User, Barber, Service, Schedule, Plan, Membership } from './types';

function App() {
  const [activeTab, setActiveTab] = useState<SidebarTab>('home');
  const [user, setUser] = useState<User | null>(null);
  const [barbers, setBarbers] = useState<Barber[]>([]);
  const [services, setServices] = useState<Service[]>([]);
  const [plans, setPlans] = useState<Plan[]>([]);
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [activeMembership, setActiveMembership] = useState<Membership | null>(null);

  // System Loading States
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Booking Modal
  const [bookingOpen, setBookingOpen] = useState(false);
  const [preselectedService, setPreselectedService] = useState<Service | null>(null);

  // Toasts
  const [toasts, setToasts] = useState<Toast[]>([]);

  const addToast = (title: string, message: string, type: 'success' | 'error' | 'info' | 'warning' = 'success') => {
    const id = Math.random().toString(36).substring(2, 9);
    setToasts(prev => [...prev, { id, title, message, type }]);
    
    // Auto-remove toast after 4s
    setTimeout(() => {
      removeToast(id);
    }, 4000);
  };

  const removeToast = (id: string) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  };

  // Initial Fetch Data (Simulated with Skeletons)
  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      // Parallel requests
      const [u, b, srv, pln, sch, mem] = await Promise.all([
        UserService.getCurrentUser(),
        BarberService.getBarbers(),
        ServiceService.getServices(),
        MembershipService.getPlans(),
        ScheduleService.getSchedules(),
        MembershipService.getActiveMembership()
      ]);

      setUser(u);
      setBarbers(b);
      setServices(srv);
      setPlans(pln);
      setSchedules(sch);
      setActiveMembership(mem);
    } catch (e: any) {
      setError(e.message || 'Falha ao carregar dados do sistema. Recarregue a página.');
      addToast('Erro de Carregamento', 'Falha ao recuperar dados do servidor.', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  // Handle Booking creation
  const handleBooking = async (bookingDetails: {
    barberId: string;
    services: Service[];
    date: string;
    time: string;
  }) => {
    try {
      const newSch = await ScheduleService.createSchedule(bookingDetails);
      setSchedules(prev => [newSch, ...prev]);
      
      // Send notification mock
      await NotificationService.addNotification({
        title: 'Agendamento Confirmado',
        message: `Seu agendamento para ${newSch.services.map(s => s.name).join(', ')} no dia ${newSch.date.split('-').reverse().join('/')} às ${newSch.time} foi confirmado com sucesso.`,
        type: 'success'
      });

      addToast('Agendamento Confirmado', 'Seu agendamento foi salvo com sucesso!', 'success');
    } catch (e: any) {
      addToast('Erro no Agendamento', e.message || 'Erro ao realizar agendamento.', 'error');
      throw e;
    }
  };

  // Handle Cancel Booking
  const handleCancelBooking = async (scheduleId: string) => {
    if (window.confirm('Tem certeza que deseja cancelar este agendamento?')) {
      try {
        const cancelledSch = await ScheduleService.cancelSchedule(scheduleId);
        setSchedules(prev => prev.map(s => s.id === scheduleId ? cancelledSch : s));
        
        await NotificationService.addNotification({
          title: 'Agendamento Cancelado',
          message: `Seu agendamento do dia ${cancelledSch.date.split('-').reverse().join('/')} foi cancelado.`,
          type: 'warning'
        });

        addToast('Cancelado', 'Agendamento cancelado com sucesso.', 'info');
      } catch (e: any) {
        addToast('Erro', 'Não foi possível cancelar o agendamento.', 'error');
      }
    }
  };

  // Handle Reschedule (open modal with preselected)
  const handleReschedule = (schedule: Schedule) => {
    if (schedule.services.length > 0) {
      setPreselectedService(schedule.services[0]);
    }
    setBookingOpen(true);
    addToast('Reagendar', 'Selecione a nova data e profissional para reagendar.', 'info');
    // Once rescheduled, the user can cancel the old one, or we can automate it.
    // For simplicity, we just guide them to create a new appointment or cancel the old one.
  };

  // Handle Plan Subscription
  const handleSubscribe = async (planId: string) => {
    try {
      const newMem = await MembershipService.subscribeToPlan(planId);
      setActiveMembership(newMem);
      
      await NotificationService.addNotification({
        title: 'Assinatura Ativada',
        message: `Parabéns! Sua assinatura do ${newMem.planName} está ativa. Aproveite os benefícios.`,
        type: 'success'
      });

      addToast('Assinatura Ativada', `Seja bem-vindo ao ${newMem.planName}!`, 'success');
      setActiveTab('membership'); // Redirect to membership screen
    } catch (e) {
      addToast('Erro', 'Não foi possível assinar o plano.', 'error');
    }
  };

  // Handle Cancel Subscription
  const handleCancelSubscription = async () => {
    try {
      await MembershipService.cancelMembership();
      // Reload active membership
      const mem = await MembershipService.getActiveMembership();
      setActiveMembership(mem);

      addToast('Assinatura Cancelada', 'Sua assinatura foi desativada.', 'info');
    } catch (e) {
      addToast('Erro', 'Erro ao cancelar assinatura.', 'error');
    }
  };

  // Handle User Update
  const handleUpdateUser = async (updatedData: Partial<User>) => {
    try {
      const updated = await UserService.updateUser(updatedData);
      setUser(updated);
      addToast('Perfil Atualizado', 'Suas informações de perfil foram atualizadas.', 'success');
    } catch (e) {
      addToast('Erro', 'Erro ao atualizar perfil.', 'error');
    }
  };

  // Mock Logout
  const handleLogout = () => {
    if (window.confirm('Deseja sair do sistema?')) {
      addToast('Desconectado', 'Você saiu da sua conta.', 'info');
      // Reset user to login mock or simulation
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    }
  };

  const getUpcomingSchedule = () => {
    const todayStr = new Date().toISOString().split('T')[0];
    return schedules.find(s => s.date >= todayStr && s.status === 'confirmed') || null;
  };

  const getLastCompletedVisit = () => {
    return schedules.find(s => s.status === 'completed') || null;
  };

  const renderActiveTabContent = () => {
    switch (activeTab) {
      case 'home':
        return (
          <div className="dashboard-grid">
            <div className="dashboard-left-col">
              <ServicesSection
                services={services}
                onSelectService={(service) => {
                  setPreselectedService(service);
                  setBookingOpen(true);
                }}
                onViewAllServices={() => setActiveTab('services')}
              />
              <LastVisitCard
                lastVisit={getLastCompletedVisit()}
                review={null}
                onViewHistory={() => setActiveTab('schedules')}
              />
            </div>
            <div className="dashboard-right-col">
              <DashboardCards
                upcomingSchedule={getUpcomingSchedule()}
                activeMembership={activeMembership}
                onOpenBooking={() => {
                  setPreselectedService(null);
                  setBookingOpen(true);
                }}
                onCancelBooking={handleCancelBooking}
                onReschedule={handleReschedule}
                onViewPlans={() => setActiveTab('plans')}
                onViewMembership={() => setActiveTab('membership')}
              />
            </div>
          </div>
        );
      case 'schedules':
        return (
          <ScheduleManagement
            schedules={schedules}
            loading={loading}
            error={error}
            onCancel={handleCancelBooking}
            onReschedule={handleReschedule}
            onRetry={fetchData}
          />
        );
      case 'services':
        return (
          <div className="animate-fade-in" style={{ padding: '30px 40px' }}>
            <div className="section-title-row" style={{ marginBottom: '25px' }}>
              <h3 className="section-title" style={{ fontSize: '1.5rem' }}>Serviços Disponíveis</h3>
            </div>
            <div className="plans-grid">
              {services.map(service => (
                <div key={service.id} className="plan-card">
                  <h4 className="plan-name" style={{ color: 'var(--color-gold)' }}>{service.name}</h4>
                  <p className="card-description" style={{ flexGrow: 1 }}>{service.description}</p>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px', fontSize: '0.9rem', fontWeight: 600 }}>
                    <span style={{ color: 'var(--color-light-text-secondary)' }}>Duração:</span>
                    <span>{service.durationMinutes} min</span>
                  </div>
                  <div className="plan-price-row">
                    <span className="plan-price">R$ {service.price.toFixed(2).split('.')[0]}</span>
                    <span style={{ fontSize: '1.2rem', fontWeight: 800 }}>,{service.price.toFixed(2).split('.')[1]}</span>
                  </div>
                  <button 
                    className="btn-primary" 
                    style={{ width: '100%' }}
                    onClick={() => {
                      setPreselectedService(service);
                      setBookingOpen(true);
                    }}
                  >
                    Agendar este serviço
                  </button>
                </div>
              ))}
            </div>
          </div>
        );
      case 'membership':
        return (
          <MembershipView
            membership={activeMembership}
            plans={plans}
            onSubscribe={handleSubscribe}
            onCancelSubscription={handleCancelSubscription}
            onViewPlans={() => setActiveTab('plans')}
          />
        );
      case 'plans':
        return (
          <PlansView
            plans={plans}
            activePlanId={activeMembership?.planId}
            onSubscribe={handleSubscribe}
          />
        );
      case 'profile':
        if (!user) return null;
        return (
          <ProfileView
            user={user}
            onSave={handleUpdateUser}
          />
        );
      case 'settings':
        if (!user) return null;
        return (
          <SettingsView
            user={user}
            onUpdateSettings={handleUpdateUser}
            addToast={addToast}
          />
        );
      default:
        return null;
    }
  };

  return (
    <div className={`app-container ${user?.preferences.theme === 'dark' ? 'theme-dark' : ''}`}>
      <Sidebar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        onLogout={handleLogout}
        userRole="customer"
      />
      
      <main className="main-wrapper">
        <StateContainer
          loading={loading && !user} // Show global skeleton on mount only if user data is missing
          error={error}
          isEmpty={false}
          skeletonType="card"
          skeletonCount={3}
          onRetry={fetchData}
        >
          {user && (
            <>
              <Header
                user={user}
                onNavigate={setActiveTab}
                onLogout={handleLogout}
              />
              {renderActiveTabContent()}
            </>
          )}
        </StateContainer>
      </main>

      <BookingModal
        isOpen={bookingOpen}
        onClose={() => {
          setBookingOpen(false);
          setPreselectedService(null);
        }}
        barbers={barbers}
        services={services}
        preselectedService={preselectedService}
        onBookingSuccess={handleBooking}
        addToast={addToast}
      />

      <FeedbackToast toasts={toasts} removeToast={removeToast} />
    </div>
  );
}

export default App;

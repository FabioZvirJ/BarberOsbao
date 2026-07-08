import React from 'react';
import { Calendar, Star, Gem, ArrowRight, CalendarX, AlertCircle } from 'lucide-react';
import { Schedule, Membership } from '../types';

interface DashboardCardsProps {
  upcomingSchedule: Schedule | null;
  activeMembership: Membership | null;
  onOpenBooking: (preselectedServiceId?: string) => void;
  onCancelBooking: (scheduleId: string) => void;
  onReschedule: (schedule: Schedule) => void;
  onViewPlans: () => void;
  onViewMembership: () => void;
}

export const DashboardCards: React.FC<DashboardCardsProps> = ({
  upcomingSchedule,
  activeMembership,
  onOpenBooking,
  onCancelBooking,
  onReschedule,
  onViewPlans,
  onViewMembership
}) => {
  const formatDateString = (dateStr: string) => {
    // Format YYYY-MM-DD to DD/MM/YYYY
    const parts = dateStr.split('-');
    if (parts.length === 3) {
      return `${parts[2]}/${parts[1]}/${parts[0]}`;
    }
    return dateStr;
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'confirmed': return 'Confirmado';
      case 'pending': return 'Pendente';
      case 'completed': return 'Concluído';
      case 'cancelled': return 'Cancelado';
      default: return status;
    }
  };

  return (
    <>
      {/* Próximo Agendamento Card */}
      <div className="card-premium animate-fade-in" style={{ gridColumn: 'span 2' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '15px' }}>
          <div className="card-title-badge" style={{ marginBottom: 0 }}>
            <div className="card-header-icon" style={{ marginBottom: 0, marginRight: '10px' }}>
              <Calendar />
            </div>
            Próximo agendamento
          </div>
        </div>

        {upcomingSchedule ? (
          <div className="active-booking-info">
            <div className="booking-detail-row">
              <span className="booking-detail-label">Profissional</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <img 
                  src={upcomingSchedule.barberAvatar} 
                  alt={upcomingSchedule.barberName} 
                  style={{ width: '24px', height: '24px', borderRadius: '50%', objectFit: 'cover' }} 
                />
                <span className="booking-detail-value">{upcomingSchedule.barberName}</span>
              </div>
            </div>
            <div className="booking-detail-row">
              <span className="booking-detail-label">Serviços</span>
              <span className="booking-detail-value">
                {upcomingSchedule.services.map(s => s.name).join(', ')}
              </span>
            </div>
            <div className="booking-detail-row">
              <span className="booking-detail-label">Data e Horário</span>
              <span className="booking-detail-value">
                {formatDateString(upcomingSchedule.date)} às {upcomingSchedule.time}
              </span>
            </div>
            <div className="booking-detail-row">
              <span className="booking-detail-label">Valor Total</span>
              <span className="booking-detail-value" style={{ color: 'var(--color-gold)', fontWeight: 700 }}>
                R$ {upcomingSchedule.totalValue.toFixed(2)}
              </span>
            </div>
            <div className="booking-detail-row">
              <span className="booking-detail-label">Status</span>
              <span className={`booking-status-tag status-${upcomingSchedule.status}`}>
                {getStatusText(upcomingSchedule.status)}
              </span>
            </div>

            <div className="booking-actions-group">
              <button 
                className="btn-secondary" 
                style={{ flex: 1, padding: '10px' }}
                onClick={() => onReschedule(upcomingSchedule)}
              >
                Reagendar
              </button>
              <button 
                className="btn-secondary" 
                style={{ flex: 1, color: '#dc2626', borderColor: 'rgba(220, 38, 38, 0.2)', padding: '10px' }}
                onClick={() => onCancelBooking(upcomingSchedule.id)}
              >
                Cancelar
              </button>
            </div>
          </div>
        ) : (
          <div className="next-booking-container">
            {/* Calendar Icon illustration matching layout */}
            <div className="next-booking-illustration">
              <svg viewBox="0 0 100 100" width="80" height="80" style={{ opacity: 0.85 }}>
                {/* Calendar Body */}
                <rect x="25" y="25" width="50" height="50" rx="8" fill="none" stroke="currentColor" strokeWidth="3" />
                <line x1="25" y1="42" x2="75" y2="42" stroke="currentColor" strokeWidth="3" />
                {/* Binder rings */}
                <rect x="35" y="18" width="6" height="12" rx="2" fill="currentColor" />
                <rect x="59" y="18" width="6" height="12" rx="2" fill="currentColor" />
                {/* Grid dots */}
                <circle cx="38" cy="54" r="3" fill="currentColor" opacity="0.4" />
                <circle cx="50" cy="54" r="3" fill="currentColor" opacity="0.4" />
                <circle cx="62" cy="54" r="3" fill="currentColor" opacity="0.4" />
                <circle cx="38" cy="64" r="3" fill="currentColor" opacity="0.4" />
                <circle cx="50" cy="64" r="3" fill="currentColor" opacity="0.4" />
                {/* Cancel sign overlay on bottom right */}
                <circle cx="68" cy="68" r="12" fill="#ffffff" />
                <circle cx="68" cy="68" r="10" fill="none" stroke="currentColor" strokeWidth="2.5" />
                <line x1="61" y1="61" x2="75" y2="75" stroke="currentColor" strokeWidth="2.5" />
              </svg>
            </div>
            <p className="next-booking-text">Você ainda não possui agendamentos.</p>
            <button className="btn-primary" onClick={() => onOpenBooking()}>
              Agendar agora <ArrowRight size={16} />
            </button>
          </div>
        )}
      </div>

      {/* Clube do Assinante Card */}
      <div className="card-premium animate-fade-in">
        <div className="card-title-badge">
          <div className="card-header-icon" style={{ marginBottom: 0, marginRight: '10px' }}>
            <Star />
          </div>
          Clube do Assinante
        </div>

        {activeMembership ? (
          <div>
            <p className="card-description" style={{ marginBottom: '10px' }}>
              Seu clube de benefícios exclusivo está ativo. Aproveite suas vantagens!
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '0.85rem', marginBottom: '15px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--color-light-text-secondary)' }}>Plano:</span>
                <span style={{ fontWeight: 600 }}>{activeMembership.planName}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--color-light-text-secondary)' }}>Vencimento:</span>
                <span style={{ fontWeight: 600 }}>{formatDateString(activeMembership.endDate)}</span>
              </div>
            </div>
            <button className="link-gold" onClick={onViewMembership}>
              Ver meus benefícios <ArrowRight />
            </button>
          </div>
        ) : (
          <div>
            <p className="card-description">
              Descontos e benefícios exclusivos para você.
            </p>
            <button className="link-gold" onClick={onViewMembership}>
              Quero conhecer <ArrowRight />
            </button>
          </div>
        )}
      </div>

      {/* Plano Card */}
      <div className="card-premium animate-fade-in">
        <div className="card-title-badge">
          <div className="card-header-icon" style={{ marginBottom: 0, marginRight: '10px' }}>
            <Gem />
          </div>
          Plano
        </div>

        {activeMembership ? (
          <div>
            <p className="card-description" style={{ marginBottom: '10px' }}>
              Você possui um plano ativo que garante cortes e atendimentos exclusivos.
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '0.85rem', marginBottom: '15px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--color-light-text-secondary)' }}>Plano Atual:</span>
                <span style={{ fontWeight: 600, color: 'var(--color-gold)' }}>{activeMembership.planName}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: 'var(--color-light-text-secondary)' }}>Status:</span>
                <span className="booking-status-tag status-confirmed" style={{ padding: '2px 8px' }}>Ativo</span>
              </div>
            </div>
            <button className="link-gold" onClick={onViewPlans}>
              Gerenciar plano <ArrowRight />
            </button>
          </div>
        ) : (
          <div>
            <p className="card-description">
              Você não possui um plano ativo.
            </p>
            <button className="link-gold" onClick={onViewPlans}>
              Assinar plano <ArrowRight />
            </button>
          </div>
        )}
      </div>
    </>
  );
};

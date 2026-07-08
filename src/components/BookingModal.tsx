import React, { useState, useEffect } from 'react';
import { Calendar, User, Scissors, Clock, DollarSign, X, Check, Loader2 } from 'lucide-react';
import { Service, Barber } from '../types';
import { ScheduleService } from '../services/scheduleService';
import { StateContainer } from './StateContainer';

interface BookingModalProps {
  isOpen: boolean;
  onClose: () => void;
  barbers: Barber[];
  services: Service[];
  preselectedService?: Service | null;
  onBookingSuccess: (bookingDetails: {
    barberId: string;
    services: Service[];
    date: string;
    time: string;
  }) => Promise<void>;
  addToast: (title: string, message: string, type: 'success' | 'error') => void;
}

export const BookingModal: React.FC<BookingModalProps> = ({
  isOpen,
  onClose,
  barbers,
  services,
  preselectedService,
  onBookingSuccess,
  addToast
}) => {
  const [step, setStep] = useState(1);
  const [selectedServices, setSelectedServices] = useState<Service[]>([]);
  const [selectedBarber, setSelectedBarber] = useState<Barber | null>(null);
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [selectedTime, setSelectedTime] = useState<string>('');
  const [availableSlots, setAvailableSlots] = useState<string[]>([]);
  const [loadingSlots, setLoadingSlots] = useState(false);
  const [bookingInProgress, setBookingInProgress] = useState(false);

  // Initialize preselected service if provided
  useEffect(() => {
    if (preselectedService && isOpen) {
      setSelectedServices([preselectedService]);
      setStep(2); // Go to barber selection directly if service is preselected
    } else if (isOpen) {
      setSelectedServices([]);
      setSelectedBarber(null);
      setSelectedDate('');
      setSelectedTime('');
      setStep(1);
    }
  }, [preselectedService, isOpen]);

  // Load available times when barber and date are selected
  useEffect(() => {
    const loadSlots = async () => {
      if (selectedBarber && selectedDate) {
        setLoadingSlots(true);
        try {
          const slots = await ScheduleService.getAvailableSlots(selectedBarber.id, selectedDate);
          setAvailableSlots(slots);
        } catch (e) {
          addToast('Erro', 'Não foi possível carregar os horários disponíveis.', 'error');
        } finally {
          setLoadingSlots(false);
        }
      }
    };
    loadSlots();
  }, [selectedBarber, selectedDate]);

  if (!isOpen) return null;

  const handleServiceToggle = (service: Service) => {
    setSelectedServices(prev => {
      const exists = prev.find(s => s.id === service.id);
      if (exists) {
        return prev.filter(s => s.id !== service.id);
      } else {
        return [...prev, service];
      }
    });
  };

  const getNext14Days = () => {
    const days = [];
    const weekdayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    for (let i = 0; i < 14; i++) {
      const date = new Date();
      date.setDate(date.getDate() + i);
      const dateString = date.toISOString().split('T')[0];
      days.push({
        dateString,
        dayOfMonth: date.getDate(),
        weekday: weekdayNames[date.getDay()],
        isWeekend: date.getDay() === 0 // e.g. Sunday closed
      });
    }
    return days;
  };

  const getTotalDuration = () => {
    return selectedServices.reduce((acc, s) => acc + s.durationMinutes, 0);
  };

  const getTotalPrice = () => {
    return selectedServices.reduce((acc, s) => acc + s.price, 0);
  };

  const handleNextStep = () => {
    if (step === 1 && selectedServices.length === 0) {
      addToast('Atenção', 'Selecione pelo menos um serviço para continuar.', 'error');
      return;
    }
    if (step === 2 && !selectedBarber) {
      addToast('Atenção', 'Selecione um profissional para continuar.', 'error');
      return;
    }
    if (step === 3 && !selectedDate) {
      addToast('Atenção', 'Selecione uma data para continuar.', 'error');
      return;
    }
    if (step === 4 && !selectedTime) {
      addToast('Atenção', 'Selecione um horário para continuar.', 'error');
      return;
    }
    setStep(prev => prev + 1);
  };

  const handlePrevStep = () => {
    if (step === 2 && preselectedService) {
      setStep(1); // Allow going back to change service
    }
    setStep(prev => prev - 1);
  };

  const handleConfirmBooking = async () => {
    if (!selectedBarber || selectedServices.length === 0 || !selectedDate || !selectedTime) return;
    setBookingInProgress(true);
    try {
      await onBookingSuccess({
        barberId: selectedBarber.id,
        services: selectedServices,
        date: selectedDate,
        time: selectedTime
      });
      onClose();
    } catch (e) {
      addToast('Erro', 'Ocorreu um erro ao salvar o agendamento.', 'error');
    } finally {
      setBookingInProgress(false);
    }
  };

  const renderStepContent = () => {
    switch (step) {
      case 1:
        return (
          <div className="animate-fade-in">
            <h4 style={{ fontSize: '1rem', fontWeight: 600, marginBottom: '15px' }}>Selecione um ou mais serviços:</h4>
            <div className="services-select-list">
              {services.map(service => {
                const isSelected = selectedServices.some(s => s.id === service.id);
                return (
                  <div
                    key={service.id}
                    className={`services-select-item ${isSelected ? 'selected' : ''}`}
                    onClick={() => handleServiceToggle(service)}
                  >
                    <div>
                      <span style={{ fontWeight: 700, display: 'block' }}>{service.name}</span>
                      <span style={{ fontSize: '0.85rem', color: 'var(--color-light-text-secondary)' }}>
                        {service.durationMinutes} min • R$ {service.price.toFixed(2)}
                      </span>
                    </div>
                    <div className="checkbox-circle" />
                  </div>
                );
              })}
            </div>
          </div>
        );
      case 2:
        return (
          <div className="animate-fade-in">
            <h4 style={{ fontSize: '1rem', fontWeight: 600, marginBottom: '15px' }}>Selecione o profissional:</h4>
            <div className="barbers-select-grid">
              {barbers.map(barber => {
                const isSelected = selectedBarber?.id === barber.id;
                return (
                  <div
                    key={barber.id}
                    className={`barber-select-card ${isSelected ? 'selected' : ''}`}
                    onClick={() => setSelectedBarber(barber)}
                  >
                    <img src={barber.avatarUrl} alt={barber.name} className="barber-select-avatar" />
                    <span className="barber-select-name">{barber.name}</span>
                    <span className="barber-select-rating">★ {barber.rating.toFixed(1)}</span>
                    <span style={{ fontSize: '0.75rem', color: 'var(--color-light-text-secondary)', marginTop: '8px' }}>
                      {barber.specialties.slice(0, 2).join(', ')}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        );
      case 3:
        return (
          <div className="animate-fade-in date-picker-container">
            <h4 style={{ fontSize: '1rem', fontWeight: 600 }}>Selecione a data do atendimento:</h4>
            <div className="calendar-grid">
              {['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'].map(h => (
                <div key={h} className="calendar-day-header">{h}</div>
              ))}
              {getNext14Days().map(day => (
                <button
                  key={day.dateString}
                  disabled={day.isWeekend}
                  className={`calendar-day-btn ${selectedDate === day.dateString ? 'selected' : ''}`}
                  onClick={() => {
                    setSelectedDate(day.dateString);
                    setSelectedTime(''); // Reset time selection
                  }}
                >
                  <span style={{ fontSize: '0.7rem', display: 'block', textTransform: 'uppercase' }}>{day.weekday}</span>
                  <span style={{ fontSize: '1.1rem', fontWeight: 700 }}>{day.dayOfMonth}</span>
                </button>
              ))}
            </div>
          </div>
        );
      case 4:
        return (
          <div className="animate-fade-in">
            <h4 style={{ fontSize: '1rem', fontWeight: 600 }}>Selecione o horário disponível:</h4>
            <StateContainer loading={loadingSlots} error={null} isEmpty={availableSlots.length === 0} emptyTitle="Sem horários livres" emptyMessage="Não há horários disponíveis para este profissional nesta data. Tente outra data.">
              <div className="time-slots-grid">
                {availableSlots.map(time => (
                  <button
                    key={time}
                    className={`time-slot-btn ${selectedTime === time ? 'selected' : ''}`}
                    onClick={() => setSelectedTime(time)}
                  >
                    {time}
                  </button>
                ))}
              </div>
            </StateContainer>
          </div>
        );
      case 5:
        return (
          <div className="animate-fade-in">
            <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '20px', textAlign: 'center' }}>Resumo do seu agendamento</h4>
            <div className="active-booking-info" style={{ backgroundColor: 'var(--color-light-bg)', padding: '20px', borderRadius: 'var(--border-radius-md)' }}>
              <div className="booking-detail-row">
                <span className="booking-detail-label">Serviços Selecionados</span>
                <span className="booking-detail-value">{selectedServices.map(s => s.name).join(', ')}</span>
              </div>
              <div className="booking-detail-row">
                <span className="booking-detail-label">Profissional</span>
                <span className="booking-detail-value">{selectedBarber?.name}</span>
              </div>
              <div className="booking-detail-row">
                <span className="booking-detail-label">Data</span>
                <span className="booking-detail-value">{selectedDate.split('-').reverse().join('/')}</span>
              </div>
              <div className="booking-detail-row">
                <span className="booking-detail-label">Horário</span>
                <span className="booking-detail-value">{selectedTime}</span>
              </div>
              <div className="booking-detail-row">
                <span className="booking-detail-label">Duração Estimada</span>
                <span className="booking-detail-value">{getTotalDuration()} minutos</span>
              </div>
              <div className="booking-detail-row" style={{ borderBottom: 'none' }}>
                <span className="booking-detail-label" style={{ fontSize: '1rem', fontWeight: 700 }}>Valor Total</span>
                <span className="booking-detail-value" style={{ fontSize: '1.2rem', fontWeight: 800, color: 'var(--color-gold)' }}>
                  R$ {getTotalPrice().toFixed(2)}
                </span>
              </div>
            </div>
            <p style={{ fontSize: '0.8rem', color: 'var(--color-light-text-secondary)', textAlign: 'center', marginTop: '15px' }}>
              O pagamento será realizado diretamente na barbearia no momento do atendimento.
            </p>
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <div className="modal-header">
          <h3 className="modal-title">Novo Agendamento</h3>
          <button className="modal-close-btn" onClick={onClose} disabled={bookingInProgress}>
            <X size={20} />
          </button>
        </div>

        <div className="modal-body">
          <div className="wizard-steps">
            {[1, 2, 3, 4, 5].map(stepNum => (
              <div
                key={stepNum}
                className={`wizard-step-node ${step === stepNum ? 'active' : ''} ${step > stepNum ? 'completed' : ''}`}
              >
                {step > stepNum ? <Check size={14} /> : stepNum}
              </div>
            ))}
          </div>

          {renderStepContent()}
        </div>

        <div className="modal-footer">
          {step > 1 ? (
            <button
              className="btn-secondary"
              onClick={handlePrevStep}
              disabled={bookingInProgress}
            >
              Voltar
            </button>
          ) : (
            <div />
          )}

          {step < 5 ? (
            <button className="btn-primary" onClick={handleNextStep}>
              Avançar
            </button>
          ) : (
            <button
              className="btn-primary"
              onClick={handleConfirmBooking}
              disabled={bookingInProgress}
            >
              {bookingInProgress ? (
                <>
                  <Loader2 className="spinner" size={16} /> Confirmando...
                </>
              ) : (
                'Confirmar Agendamento'
              )}
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

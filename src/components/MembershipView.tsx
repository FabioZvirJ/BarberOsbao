import React, { useState } from 'react';
import { Membership, Plan } from '../types';
import { Star, CheckCircle, Clock, AlertTriangle, ArrowRight, Loader2 } from 'lucide-react';

interface MembershipViewProps {
  membership: Membership | null;
  plans: Plan[];
  onSubscribe: (planId: string) => Promise<void>;
  onCancelSubscription: () => Promise<void>;
  onViewPlans: () => void;
}

export const MembershipView: React.FC<MembershipViewProps> = ({
  membership,
  plans,
  onSubscribe,
  onCancelSubscription,
  onViewPlans
}) => {
  const [cancelling, setCancelling] = useState(false);

  const handleCancel = async () => {
    if (window.confirm('Tem certeza de que deseja cancelar sua assinatura? Você continuará com acesso até o final do período vigente.')) {
      setCancelling(true);
      try {
        await onCancelSubscription();
      } finally {
        setCancelling(false);
      }
    }
  };

  const formatDate = (dateStr: string) => {
    const parts = dateStr.split('-');
    return parts.length === 3 ? `${parts[2]}/${parts[1]}/${parts[0]}` : dateStr;
  };

  return (
    <div className="animate-fade-in" style={{ padding: '30px 40px', maxWidth: '900px' }}>
      <div className="section-title-row" style={{ marginBottom: '25px' }}>
        <h3 className="section-title" style={{ fontSize: '1.5rem' }}>Clube do Assinante</h3>
      </div>

      {membership && membership.status === 'active' ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
          {/* Active plan card */}
          <div className="card-premium" style={{ borderLeft: '5px solid var(--color-gold)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '15px' }}>
              <div>
                <span className="booking-status-tag status-confirmed" style={{ marginBottom: '10px', display: 'inline-block' }}>Assinatura Ativa</span>
                <h4 style={{ fontSize: '1.5rem', fontWeight: 800, color: 'var(--color-light-text-primary)' }}>{membership.planName}</h4>
                <p style={{ fontSize: '0.9rem', color: 'var(--color-light-text-secondary)', marginTop: '5px' }}>
                  Sua assinatura renova automaticamente em: <strong>{formatDate(membership.nextRenewalDate)}</strong>
                </p>
              </div>
              <button 
                className="btn-secondary" 
                style={{ color: '#dc2626', borderColor: 'rgba(220,38,38,0.2)' }}
                onClick={handleCancel}
                disabled={cancelling}
              >
                {cancelling ? <Loader2 className="spinner" size={16} /> : 'Cancelar Assinatura'}
              </button>
            </div>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px' }}>
            {/* Benefits left */}
            <div className="card-premium">
              <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                <CheckCircle color="#10b981" /> Benefícios Restantes
              </h4>
              <div className="benefits-check-list">
                {membership.remainingBenefits.map((benefit, index) => (
                  <div key={index} className="benefits-check-item">
                    <CheckCircle size={16} />
                    <span>{benefit}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Loyalty and history */}
            <div className="card-premium">
              <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Star color="var(--color-gold)" /> Próximas Vantagens
              </h4>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
                <div style={{ display: 'flex', gap: '15px', alignItems: 'flex-start' }}>
                  <div style={{ padding: '8px', borderRadius: '50%', backgroundColor: 'var(--color-gold-bg)', color: 'var(--color-gold)' }}>
                    <Clock size={20} />
                  </div>
                  <div>
                    <span style={{ fontWeight: 600, display: 'block', fontSize: '0.95rem' }}>Upgrade de Bebida</span>
                    <span style={{ fontSize: '0.85rem', color: 'var(--color-light-text-secondary)' }}>Ganhe uma dose dupla de Chopp no seu próximo agendamento de Combo.</span>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: '15px', alignItems: 'flex-start' }}>
                  <div style={{ padding: '8px', borderRadius: '50%', backgroundColor: 'var(--color-gold-bg)', color: 'var(--color-gold)' }}>
                    <Star size={20} />
                  </div>
                  <div>
                    <span style={{ fontWeight: 600, display: 'block', fontSize: '0.95rem' }}>Desconto Especial de Aniversário</span>
                    <span style={{ fontSize: '0.85rem', color: 'var(--color-light-text-secondary)' }}>Ganhe 50% de desconto em qualquer serviço no mês do seu aniversário.</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="card-premium animate-fade-in" style={{ textAlign: 'center', padding: '40px' }}>
          <div className="card-header-icon" style={{ margin: '0 auto 20px' }}>
            <Star />
          </div>
          <h4 style={{ fontSize: '1.3rem', fontWeight: 800, marginBottom: '10px' }}>Você ainda não faz parte do clube</h4>
          <p className="card-description" style={{ maxWidth: '500px', margin: '0 auto 25px' }}>
            Assine um plano e tenha cortes ilimitados, descontos especiais em produtos, bebidas de cortesia e atendimento VIP sem filas.
          </p>
          <button className="btn-primary" onClick={onViewPlans}>
            Conhecer Planos Disponíveis <ArrowRight size={16} />
          </button>
        </div>
      )}
    </div>
  );
};

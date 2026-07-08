import React, { useState } from 'react';
import { Plan } from '../types';
import { Check, Loader2 } from 'lucide-react';

interface PlansViewProps {
  plans: Plan[];
  activePlanId?: string;
  onSubscribe: (planId: string) => Promise<void>;
}

export const PlansView: React.FC<PlansViewProps> = ({ plans, activePlanId, onSubscribe }) => {
  const [subscribingId, setSubscribingId] = useState<string | null>(null);

  const handleSubscribe = async (planId: string) => {
    setSubscribingId(planId);
    try {
      await onSubscribe(planId);
    } finally {
      setSubscribingId(null);
    }
  };

  return (
    <div className="animate-fade-in" style={{ padding: '30px 40px' }}>
      <div className="section-title-row" style={{ marginBottom: '10px' }}>
        <h3 className="section-title" style={{ fontSize: '1.5rem' }}>Planos Disponíveis</h3>
      </div>
      <p style={{ color: 'var(--color-light-text-secondary)', marginBottom: '30px' }}>
        Escolha o plano que melhor se adapta à sua rotina e economize nos cuidados com seu estilo.
      </p>

      <div className="plans-grid">
        {plans.map((plan) => {
          const isActive = activePlanId === plan.id;
          const isSubscribing = subscribingId === plan.id;
          return (
            <div
              key={plan.id}
              className={`plan-card ${plan.recommended ? 'recommended' : ''} animate-fade-in`}
            >
              {plan.recommended && <div className="plan-badge">Mais Popular</div>}
              
              <h4 className="plan-name">{plan.name}</h4>
              
              <div className="plan-price-row">
                <span className="plan-price">R$ {plan.price.toFixed(2).split('.')[0]}</span>
                <span style={{ fontSize: '1.2rem', fontWeight: 800 }}>,{plan.price.toFixed(2).split('.')[1]}</span>
                <span className="plan-period">/{plan.period}</span>
              </div>

              <div className="plan-benefits-list">
                {plan.benefits.map((benefit, index) => (
                  <div key={index} style={{ display: 'flex', gap: '10px', alignItems: 'flex-start', fontSize: '0.9rem' }}>
                    <Check size={16} color="var(--color-gold)" style={{ flexShrink: 0, marginTop: '2px' }} />
                    <span style={{ color: 'var(--color-light-text-primary)' }}>{benefit}</span>
                  </div>
                ))}
              </div>

              {isActive ? (
                <button
                  className="btn-secondary"
                  disabled
                  style={{ width: '100%', cursor: 'default', backgroundColor: 'var(--color-gold-bg)', color: 'var(--color-gold)', borderColor: 'var(--color-gold)' }}
                >
                  Plano Atual
                </button>
              ) : (
                <button
                  className={plan.recommended ? 'btn-primary' : 'btn-secondary'}
                  style={{ width: '100%' }}
                  onClick={() => handleSubscribe(plan.id)}
                  disabled={subscribingId !== null}
                >
                  {isSubscribing ? (
                    <>
                      <Loader2 className="spinner" size={16} /> Contratando...
                    </>
                  ) : (
                    'Assinar Plano'
                  )}
                </button>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};

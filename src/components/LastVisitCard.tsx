import React from 'react';
import { Scissors, Star, ArrowRight } from 'lucide-react';
import { Schedule, Review } from '../types';

interface LastVisitCardProps {
  lastVisit: Schedule | null;
  review: Review | null;
  onViewHistory: () => void;
}

export const LastVisitCard: React.FC<LastVisitCardProps> = ({
  lastVisit,
  review,
  onViewHistory
}) => {
  const calculateDaysAgo = (dateStr: string) => {
    const today = new Date();
    today.setHours(0,0,0,0);
    const visitDate = new Date(dateStr);
    visitDate.setHours(0,0,0,0);
    
    const diffTime = Math.abs(today.getTime() - visitDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return 'hoje';
    if (diffDays === 1) return 'ontem';
    return `há ${diffDays} dias`;
  };

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }).map((_, i) => (
      <Star 
        key={i} 
        size={14} 
        fill={i < rating ? 'currentColor' : 'none'} 
        color="var(--color-gold)" 
      />
    ));
  };

  return (
    <div className="card-premium animate-fade-in" style={{ padding: '20px' }}>
      <h4 style={{ fontSize: '0.95rem', fontWeight: 700, color: 'var(--color-light-text-secondary)', marginBottom: '16px' }}>
        Última visita
      </h4>

      {lastVisit ? (
        <div className="last-visit-container">
          <div className="last-visit-left">
            <div 
              className="service-card-icon" 
              style={{ width: '48px', height: '48px', margin: 0, backgroundColor: 'rgba(184, 134, 11, 0.08)' }}
            >
              <Scissors size={20} color="var(--color-gold)" />
            </div>
            <div className="last-visit-details">
              <span className="last-visit-title">
                {lastVisit.services.map(s => s.name).join(' + ')}
              </span>
              <span className="last-visit-date">
                {calculateDaysAgo(lastVisit.date)}
              </span>
              <div className="rating-stars">
                {renderStars(review?.rating || 5)}
              </div>
            </div>
          </div>

          <button className="btn-secondary" onClick={onViewHistory} style={{ padding: '8px 16px', fontSize: '0.85rem' }}>
            Ver histórico <ArrowRight size={14} />
          </button>
        </div>
      ) : (
        <div style={{ textAlign: 'center', padding: '15px 0' }}>
          <p style={{ fontSize: '0.9rem', color: 'var(--color-light-text-secondary)', marginBottom: '12px' }}>
            Parece que você ainda não nos visitou. Agende seu primeiro corte conosco!
          </p>
          <button className="link-gold" onClick={() => onViewHistory()}>
            Ver histórico <ArrowRight size={14} />
          </button>
        </div>
      )}
    </div>
  );
};

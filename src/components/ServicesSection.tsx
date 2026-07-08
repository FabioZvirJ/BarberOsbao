import React from 'react';
import { Scissors, Flame, ArrowRight } from 'lucide-react';
import { Service } from '../types';

interface ServicesSectionProps {
  services: Service[];
  onSelectService: (service: Service) => void;
  onViewAllServices: () => void;
}

export const ServicesSection: React.FC<ServicesSectionProps> = ({
  services,
  onSelectService,
  onViewAllServices
}) => {
  const getServiceIcon = (iconName: string) => {
    switch (iconName.toLowerCase()) {
      case 'scissors':
        return <Scissors size={24} />;
      case 'beard':
        return (
          // Customized Beard SVG matching layout
          <svg viewBox="0 0 100 100" width="24" height="24" fill="currentColor">
            <path d="M50,15 C45,15 40,25 40,32 C40,40 45,45 50,45 C55,45 60,40 60,32 C60,25 55,15 50,15 Z M25,48 C25,65 35,85 50,85 C65,85 75,65 75,48 C70,52 62,55 50,55 C38,55 30,52 25,48 Z" />
          </svg>
        );
      case 'eyebrow':
        return (
          // Customized Eyebrow SVG matching layout
          <svg viewBox="0 0 100 100" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="6" strokeLinecap="round">
            <path d="M20,55 Q50,25 80,45" />
            <path d="M20,70 Q50,85 80,70" strokeWidth="2" opacity="0.3" />
          </svg>
        );
      case 'combo':
      default:
        return <Flame size={24} />;
    }
  };

  return (
    <div className="services-section animate-fade-in" style={{ marginTop: '10px' }}>
      <div className="section-title-row">
        <h3 className="section-title">Nossos serviços</h3>
        <button className="link-gold" onClick={onViewAllServices}>
          Ver todos <ArrowRight size={16} />
        </button>
      </div>

      <div className="services-grid">
        {services.slice(0, 4).map((service) => (
          <div
            key={service.id}
            className="service-card"
            onClick={() => onSelectService(service)}
          >
            <div className="service-card-icon">
              {getServiceIcon(service.iconName)}
            </div>
            <span className="service-card-name">{service.name}</span>
            <span className="service-card-price">R$ {service.price.toFixed(2)}</span>
            <span className="service-card-meta">{service.durationMinutes} min</span>
          </div>
        ))}
      </div>
    </div>
  );
};

import React from 'react';
import { Home, Calendar, Scissors, Star, Gem, User, Settings, LogOut } from 'lucide-react';

export type SidebarTab = 'home' | 'schedules' | 'services' | 'membership' | 'plans' | 'profile' | 'settings';

interface SidebarProps {
  activeTab: SidebarTab;
  setActiveTab: (tab: SidebarTab) => void;
  onLogout: () => void;
  userRole?: string; // Prepared for future roles / permissions
}

export const Sidebar: React.FC<SidebarProps> = ({ activeTab, setActiveTab, onLogout, userRole = 'customer' }) => {
  // Prepared for permissions: Define which roles can access which tabs
  const tabPermissions: Record<SidebarTab, string[]> = {
    home: ['customer', 'barber', 'admin'],
    schedules: ['customer', 'barber', 'admin'],
    services: ['customer', 'barber', 'admin'],
    membership: ['customer', 'admin'],
    plans: ['customer', 'admin'],
    profile: ['customer', 'barber', 'admin'],
    settings: ['customer', 'barber', 'admin'],
  };

  const hasPermission = (tab: SidebarTab) => {
    return tabPermissions[tab].includes(userRole);
  };

  const menuItems = [
    { id: 'home' as SidebarTab, label: 'Início', icon: Home },
    { id: 'schedules' as SidebarTab, label: 'Agendamentos', icon: Calendar },
    { id: 'services' as SidebarTab, label: 'Serviços', icon: Scissors },
    { id: 'membership' as SidebarTab, label: 'Assinaturas', icon: Star },
    { id: 'plans' as SidebarTab, label: 'Plano', icon: Gem },
    { id: 'profile' as SidebarTab, label: 'Perfil', icon: User },
  ];

  const bottomItems = [
    { id: 'settings' as SidebarTab, label: 'Configurações', icon: Settings },
  ];

  return (
    <aside className="sidebar">
      <div className="logo-container">
        <div className="logo-icon-wrapper">
          {/* Barber logo SVG matching layout */}
          <svg viewBox="0 0 100 100" className="logo-icon-svg">
            {/* Laurel wreaths */}
            <path d="M25,65 C18,50 18,35 25,25" stroke="currentColor" strokeWidth="2.5" fill="none" strokeLinecap="round" />
            <path d="M75,65 C82,50 82,35 75,25" stroke="currentColor" strokeWidth="2.5" fill="none" strokeLinecap="round" />
            <path d="M25,55 L20,53 M25,45 L18,43 M25,35 L20,33" stroke="currentColor" strokeWidth="2" />
            <path d="M75,55 L80,53 M75,45 L82,43 M75,35 L80,33" stroke="currentColor" strokeWidth="2" />
            {/* Pole body */}
            <rect x="42" y="20" width="16" height="50" rx="3" fill="none" stroke="currentColor" strokeWidth="3" />
            <path d="M43,26 L55,34 M43,38 L55,46 M43,50 L55,58" stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" />
            {/* Top and bottom spheres */}
            <circle cx="50" cy="16" r="6" fill="currentColor" />
            <circle cx="50" cy="74" r="6" fill="currentColor" />
            {/* Bottom holder stand */}
            <rect x="36" y="78" width="28" height="4" rx="2" fill="currentColor" />
          </svg>
        </div>
        <h1 className="logo-title">Sua Barbearia</h1>
        <span className="logo-subtitle">Cuidando do seu estilo</span>
      </div>

      <nav className="sidebar-nav">
        {menuItems.map((item) => {
          if (!hasPermission(item.id)) return null;
          const Icon = item.icon;
          return (
            <button
              key={item.id}
              className={`sidebar-item ${activeTab === item.id ? 'active' : ''}`}
              onClick={() => setActiveTab(item.id)}
            >
              <Icon size={20} />
              {item.label}
            </button>
          );
        })}

        <div className="sidebar-divider" />

        {bottomItems.map((item) => {
          if (!hasPermission(item.id)) return null;
          const Icon = item.icon;
          return (
            <button
              key={item.id}
              className={`sidebar-item ${activeTab === item.id ? 'active' : ''}`}
              onClick={() => setActiveTab(item.id)}
            >
              <Icon size={20} />
              {item.label}
            </button>
          );
        })}

        <button className="sidebar-item" onClick={onLogout} style={{ marginTop: 'auto' }}>
          <LogOut size={20} />
          Sair
        </button>
      </nav>
    </aside>
  );
};

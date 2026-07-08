import React, { useState, useEffect, useRef } from 'react';
import { ChevronDown, User as UserIcon, Settings, LogOut } from 'lucide-react';
import { User } from '../types';

interface HeaderProps {
  user: User;
  onNavigate: (tab: 'profile' | 'settings') => void;
  onLogout: () => void;
}

export const Header: React.FC<HeaderProps> = ({ user, onNavigate, onLogout }) => {
  const [greeting, setGreeting] = useState('');
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const updateGreeting = () => {
      const hour = new Date().getHours();
      if (hour >= 6 && hour < 12) {
        setGreeting('Bom dia');
      } else if (hour >= 12 && hour < 18) {
        setGreeting('Boa tarde');
      } else {
        setGreeting('Boa noite');
      }
    };
    updateGreeting();
    // Update every hour
    const interval = setInterval(updateGreeting, 3600000);
    return () => clearInterval(interval);
  }, []);

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <header className="header-banner">
      <div className="header-content animate-fade-in">
        <div>
          <span className="header-greeting">
            {greeting}, {user.name}! 👋
          </span>
          <h2 className="header-title">Seja bem-vindo!</h2>
          <span className="header-subtitle">Estamos prontos para cuidar de você.</span>
        </div>

        <div className="header-user-wrapper" ref={dropdownRef}>
          <div className="header-user" onClick={() => setDropdownOpen(!dropdownOpen)}>
            <img src={user.avatarUrl} alt={user.name} className="header-avatar" />
            <ChevronDown className="header-chevron" />
          </div>

          {dropdownOpen && (
            <div className="user-dropdown">
              <button
                className="user-dropdown-item"
                onClick={() => {
                  onNavigate('profile');
                  setDropdownOpen(false);
                }}
              >
                <UserIcon size={16} />
                Meu Perfil
              </button>
              <button
                className="user-dropdown-item"
                onClick={() => {
                  onNavigate('settings');
                  setDropdownOpen(false);
                }}
              >
                <Settings size={16} />
                Configurações
              </button>
              <div style={{ height: '1px', backgroundColor: 'var(--color-light-border)', margin: '5px 0' }} />
              <button
                className="user-dropdown-item"
                onClick={() => {
                  onLogout();
                  setDropdownOpen(false);
                }}
                style={{ color: '#dc2626' }}
              >
                <LogOut size={16} />
                Sair
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

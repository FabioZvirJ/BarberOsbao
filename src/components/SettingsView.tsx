import React, { useState } from 'react';
import { User, Shield, HelpCircle, Bell, Loader2 } from 'lucide-react';
import { User as UserType } from '../types';

interface SettingsViewProps {
  user: UserType;
  onUpdateSettings: (updatedUser: Partial<UserType>) => Promise<void>;
  addToast: (title: string, message: string, type: 'success' | 'error') => void;
}

export const SettingsView: React.FC<SettingsViewProps> = ({ user, onUpdateSettings, addToast }) => {
  const [theme, setTheme] = useState(user.preferences.theme);
  const [language, setLanguage] = useState(user.preferences.language);
  const [emailNotif, setEmailNotif] = useState(user.preferences.notifications.email);
  const [pushNotif, setPushNotif] = useState(user.preferences.notifications.push);
  const [whatsappNotif, setWhatsappNotif] = useState(user.preferences.notifications.whatsapp);
  const [shareData, setShareData] = useState(user.preferences.privacy.shareData);
  const [profilePublic, setProfilePublic] = useState(user.preferences.privacy.profilePublic);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    try {
      await onUpdateSettings({
        preferences: {
          theme,
          language,
          notifications: {
            email: emailNotif,
            push: pushNotif,
            whatsapp: whatsappNotif
          },
          privacy: {
            shareData,
            profilePublic
          }
        }
      });
      addToast('Sucesso', 'Configurações salvas com sucesso.', 'success');
    } catch (e) {
      addToast('Erro', 'Não foi possível salvar as configurações.', 'error');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="animate-fade-in" style={{ padding: '30px 40px', maxWidth: '800px' }}>
      <div className="section-title-row" style={{ marginBottom: '25px' }}>
        <h3 className="section-title" style={{ fontSize: '1.5rem' }}>Configurações</h3>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '30px' }}>
        {/* Preferências do App */}
        <div className="card-premium">
          <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <User size={20} color="var(--color-gold)" /> Preferências do Aplicativo
          </h4>
          
          <div className="settings-section">
            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Tema do Sistema</span>
                <span className="settings-desc">Selecione o tema claro ou escuro do aplicativo</span>
              </div>
              <div style={{ display: 'flex', gap: '10px' }}>
                <button 
                  className={`btn-secondary ${theme === 'dark' ? 'active' : ''}`}
                  style={{ padding: '6px 12px', fontSize: '0.85rem', backgroundColor: theme === 'dark' ? 'var(--color-gold-bg)' : 'transparent', color: theme === 'dark' ? 'var(--color-gold)' : 'inherit', borderColor: theme === 'dark' ? 'var(--color-gold)' : 'var(--color-light-border)' }}
                  onClick={() => setTheme('dark')}
                >
                  Escuro
                </button>
                <button 
                  className={`btn-secondary ${theme === 'light' ? 'active' : ''}`}
                  style={{ padding: '6px 12px', fontSize: '0.85rem', backgroundColor: theme === 'light' ? 'var(--color-gold-bg)' : 'transparent', color: theme === 'light' ? 'var(--color-gold)' : 'inherit', borderColor: theme === 'light' ? 'var(--color-gold)' : 'var(--color-light-border)' }}
                  onClick={() => setTheme('light')}
                >
                  Claro
                </button>
              </div>
            </div>

            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Idioma</span>
                <span className="settings-desc">Escolha o idioma de exibição dos menus</span>
              </div>
              <select 
                className="form-input" 
                style={{ padding: '8px 12px', fontSize: '0.85rem', width: '130px' }}
                value={language}
                onChange={(e) => setLanguage(e.target.value as 'pt-BR' | 'en')}
              >
                <option value="pt-BR">Português</option>
                <option value="en">English</option>
              </select>
            </div>
          </div>
        </div>

        {/* Notificações */}
        <div className="card-premium">
          <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Bell size={20} color="var(--color-gold)" /> Notificações
          </h4>
          
          <div className="settings-section">
            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Notificações por E-mail</span>
                <span className="settings-desc">Receba lembretes de agendamentos no seu e-mail</span>
              </div>
              <label className="switch-control">
                <input 
                  type="checkbox" 
                  checked={emailNotif}
                  onChange={(e) => setEmailNotif(e.target.checked)}
                />
                <span className="switch-slider"></span>
              </label>
            </div>

            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Notificações Push</span>
                <span className="settings-desc">Notificações em tempo real no navegador ou celular</span>
              </div>
              <label className="switch-control">
                <input 
                  type="checkbox" 
                  checked={pushNotif}
                  onChange={(e) => setPushNotif(e.target.checked)}
                />
                <span className="switch-slider"></span>
              </label>
            </div>

            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Alertas por WhatsApp</span>
                <span className="settings-desc">Receba confirmações rápidas via mensagem no WhatsApp</span>
              </div>
              <label className="switch-control">
                <input 
                  type="checkbox" 
                  checked={whatsappNotif}
                  onChange={(e) => setWhatsappNotif(e.target.checked)}
                />
                <span className="switch-slider"></span>
              </label>
            </div>
          </div>
        </div>

        {/* Privacidade e Segurança */}
        <div className="card-premium">
          <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Shield size={20} color="var(--color-gold)" /> Privacidade e Segurança
          </h4>
          
          <div className="settings-section">
            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Perfil Público</span>
                <span className="settings-desc">Permitir que barbeiros vejam seu histórico antes do atendimento</span>
              </div>
              <label className="switch-control">
                <input 
                  type="checkbox" 
                  checked={profilePublic}
                  onChange={(e) => setProfilePublic(e.target.checked)}
                />
                <span className="switch-slider"></span>
              </label>
            </div>

            <div className="settings-item">
              <div className="settings-info">
                <span className="settings-title">Compartilhamento de Dados</span>
                <span className="settings-desc">Compartilhar dados de agendamentos para fins estatísticos do app</span>
              </div>
              <label className="switch-control">
                <input 
                  type="checkbox" 
                  checked={shareData}
                  onChange={(e) => setShareData(e.target.checked)}
                />
                <span className="switch-slider"></span>
              </label>
            </div>
          </div>
        </div>

        {/* Ajuda e Suporte */}
        <div className="card-premium">
          <h4 style={{ fontSize: '1.1rem', fontWeight: 700, marginBottom: '15px', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <HelpCircle size={20} color="var(--color-gold)" /> Ajuda e Suporte
          </h4>
          <p style={{ fontSize: '0.85rem', color: 'var(--color-light-text-secondary)', marginBottom: '15px' }}>
            Precisa de ajuda com o aplicativo ou quer falar sobre algum agendamento?
          </p>
          <a 
            href="mailto:suporte@barberosbao.com.br" 
            className="link-gold"
            style={{ width: 'fit-content' }}
          >
            Falar com Suporte (suporte@barberosbao.com.br)
          </a>
        </div>

        {/* Save button */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '10px' }}>
          <button className="btn-primary" onClick={handleSave} disabled={saving}>
            {saving ? (
              <>
                <Loader2 className="spinner" size={16} /> Salvando...
              </>
            ) : (
              'Salvar Configurações'
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

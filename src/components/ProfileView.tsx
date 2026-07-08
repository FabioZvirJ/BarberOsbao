import React, { useState } from 'react';
import { User, Loader2 } from 'lucide-react';
import { User as UserType } from '../types';

interface ProfileViewProps {
  user: UserType;
  onSave: (updatedUser: Partial<UserType>) => Promise<void>;
}

export const ProfileView: React.FC<ProfileViewProps> = ({ user, onSave }) => {
  const [name, setName] = useState(user.name);
  const [email, setEmail] = useState(user.email);
  const [phone, setPhone] = useState(user.phone);
  const [avatarUrl, setAvatarUrl] = useState(user.avatarUrl);
  const [password, setPassword] = useState('••••••••');
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await onSave({
        name,
        email,
        phone,
        avatarUrl
      });
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="animate-fade-in" style={{ padding: '30px 40px', maxWidth: '800px' }}>
      <div className="section-title-row" style={{ marginBottom: '25px' }}>
        <h3 className="section-title" style={{ fontSize: '1.5rem' }}>Meu Perfil</h3>
      </div>

      <div className="card-premium">
        <form onSubmit={handleSubmit}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '30px', flexWrap: 'wrap' }}>
            <img 
              src={avatarUrl} 
              alt={name} 
              style={{ width: '80px', height: '80px', borderRadius: '50%', objectFit: 'cover', border: '3px solid var(--color-gold)' }} 
            />
            <div style={{ flexGrow: 1 }}>
              <h4 style={{ fontSize: '1.1rem', fontWeight: 700 }}>Foto de Perfil</h4>
              <p style={{ fontSize: '0.85rem', color: 'var(--color-light-text-secondary)', marginBottom: '8px' }}>
                Insira uma URL de imagem válida para atualizar sua foto
              </p>
              <input 
                type="text" 
                className="form-input" 
                style={{ width: '100%', maxWidth: '400px', padding: '8px 12px', fontSize: '0.85rem' }} 
                value={avatarUrl}
                onChange={(e) => setAvatarUrl(e.target.value)}
                placeholder="https://exemplo.com/foto.jpg"
              />
            </div>
          </div>

          <div className="form-grid">
            <div className="form-group">
              <label className="form-label">Nome Completo</label>
              <input 
                type="text" 
                className="form-input" 
                value={name} 
                onChange={(e) => setName(e.target.value)} 
                required 
              />
            </div>

            <div className="form-group">
              <label className="form-label">Celular / WhatsApp</label>
              <input 
                type="text" 
                className="form-input" 
                value={phone} 
                onChange={(e) => setPhone(e.target.value)} 
                required 
              />
            </div>

            <div className="form-group">
              <label className="form-label">E-mail</label>
              <input 
                type="email" 
                className="form-input" 
                value={email} 
                onChange={(e) => setEmail(e.target.value)} 
                required 
              />
            </div>

            <div className="form-group">
              <label className="form-label">Senha</label>
              <input 
                type="password" 
                className="form-input" 
                value={password} 
                onChange={(e) => setPassword(e.target.value)} 
                disabled 
                style={{ backgroundColor: 'var(--color-light-bg)', cursor: 'not-allowed' }}
              />
            </div>
          </div>

          <div style={{ marginTop: '30px', display: 'flex', justifyContent: 'flex-end' }}>
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? (
                <>
                  <Loader2 className="spinner" size={16} /> Salvando...
                </>
              ) : (
                'Salvar Alterações'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

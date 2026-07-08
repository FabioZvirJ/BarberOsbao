import React from 'react';
import { Skeleton } from './Skeleton';
import { AlertCircle, FolderOpen, RefreshCw } from 'lucide-react';

interface StateContainerProps {
  loading: boolean;
  error: string | null;
  isEmpty: boolean;
  skeletonType?: 'text' | 'title' | 'circle' | 'card' | 'table-row';
  skeletonCount?: number;
  emptyTitle?: string;
  emptyMessage?: string;
  onRetry?: () => void;
  children: React.ReactNode;
}

export const StateContainer: React.FC<StateContainerProps> = ({
  loading,
  error,
  isEmpty,
  skeletonType = 'text',
  skeletonCount = 3,
  emptyTitle = 'Nenhum registro encontrado',
  emptyMessage = 'Não há dados disponíveis para exibição no momento.',
  onRetry,
  children
}) => {
  if (loading) {
    return (
      <div className="animate-fade-in" style={{ width: '100%' }}>
        <Skeleton type={skeletonType} count={skeletonCount} />
      </div>
    );
  }

  if (error) {
    return (
      <div className="state-container animate-fade-in">
        <AlertCircle className="state-icon error" size={48} />
        <h3 className="state-title">Ops! Ocorreu um erro</h3>
        <p className="state-message">{error}</p>
        {onRetry && (
          <button className="btn-secondary" onClick={onRetry}>
            <RefreshCw size={16} /> Tentar Novamente
          </button>
        )}
      </div>
    );
  }

  if (isEmpty) {
    return (
      <div className="state-container animate-fade-in">
        <FolderOpen className="state-icon empty" size={48} />
        <h3 className="state-title">{emptyTitle}</h3>
        <p className="state-message">{emptyMessage}</p>
      </div>
    );
  }

  return <div className="animate-fade-in">{children}</div>;
};

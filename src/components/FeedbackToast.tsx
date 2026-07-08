import React from 'react';
import { CheckCircle, AlertTriangle, Info, X, AlertCircle } from 'lucide-react';

export type ToastType = 'success' | 'error' | 'info' | 'warning';

export interface Toast {
  id: string;
  title: string;
  message: string;
  type: ToastType;
}

interface FeedbackToastProps {
  toasts: Toast[];
  removeToast: (id: string) => void;
}

export const FeedbackToast: React.FC<FeedbackToastProps> = ({ toasts, removeToast }) => {
  const getIcon = (type: ToastType) => {
    switch (type) {
      case 'success':
        return <CheckCircle className="toast-icon success" color="#10b981" size={20} />;
      case 'error':
        return <AlertCircle className="toast-icon error" color="#ef4444" size={20} />;
      case 'warning':
        return <AlertTriangle className="toast-icon warning" color="#f59e0b" size={20} />;
      case 'info':
      default:
        return <Info className="toast-icon info" color="#3b82f6" size={20} />;
    }
  };

  return (
    <div className="toast-container">
      {toasts.map((toast) => (
        <div key={toast.id} className={`toast-item ${toast.type} animate-fade-in`}>
          <div className="toast-icon-wrapper">
            {getIcon(toast.type)}
          </div>
          <div className="toast-content">
            <div className="toast-title">{toast.title}</div>
            <div className="toast-message">{toast.message}</div>
          </div>
          <button className="toast-close" onClick={() => removeToast(toast.id)}>
            <X size={16} />
          </button>
        </div>
      ))}
    </div>
  );
};

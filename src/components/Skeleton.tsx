import React from 'react';

interface SkeletonProps {
  className?: string;
  type?: 'text' | 'title' | 'circle' | 'card' | 'table-row';
  count?: number;
}

export const Skeleton: React.FC<SkeletonProps> = ({ className = '', type = 'text', count = 1 }) => {
  const getSkeletonClass = () => {
    switch (type) {
      case 'title':
        return 'skeleton-title skeleton-pulse';
      case 'circle':
        return 'skeleton-circle skeleton-pulse';
      case 'card':
        return 'skeleton-card skeleton-pulse';
      case 'table-row':
        return 'skeleton-text skeleton-pulse';
      case 'text':
      default:
        return 'skeleton-text skeleton-pulse';
    }
  };

  const renderSingle = (index: number) => {
    if (type === 'card') {
      return (
        <div key={index} className="skeleton-card skeleton-pulse" style={{ marginBottom: '15px' }}>
          <div className="skeleton-circle skeleton-pulse" style={{ width: '40px', height: '40px', marginBottom: '10px' }} />
          <div className="skeleton-title skeleton-pulse" style={{ width: '50%', height: '16px' }} />
          <div className="skeleton-text skeleton-pulse" style={{ width: '80%', height: '12px' }} />
        </div>
      );
    }

    if (type === 'table-row') {
      return (
        <div key={index} style={{ display: 'flex', gap: '15px', padding: '16px 20px', borderBottom: '1px solid var(--color-light-border)' }}>
          <div className="skeleton-text skeleton-pulse" style={{ width: '20%' }} />
          <div className="skeleton-text skeleton-pulse" style={{ width: '15%' }} />
          <div className="skeleton-text skeleton-pulse" style={{ width: '30%' }} />
          <div className="skeleton-text skeleton-pulse" style={{ width: '15%' }} />
          <div className="skeleton-text skeleton-pulse" style={{ width: '10%' }} />
          <div className="skeleton-text skeleton-pulse" style={{ width: '10%' }} />
        </div>
      );
    }

    return <div key={index} className={`${getSkeletonClass()} ${className}`} style={{ margin: '8px 0' }} />;
  };

  return (
    <>
      {Array.from({ length: count }).map((_, i) => renderSingle(i))}
    </>
  );
};

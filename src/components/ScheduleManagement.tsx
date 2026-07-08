import React, { useState, useMemo } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  flexRender,
  createColumnHelper
} from '@tanstack/react-table';
import { Schedule } from '../types';
import { StateContainer } from './StateContainer';
import { Search, Calendar, RefreshCw, XCircle } from 'lucide-react';

interface ScheduleManagementProps {
  schedules: Schedule[];
  loading: boolean;
  error: string | null;
  onCancel: (id: string) => Promise<void>;
  onReschedule: (schedule: Schedule) => void;
  onRetry: () => void;
}

type FilterTab = 'all' | 'today' | 'upcoming' | 'completed' | 'cancelled';

export const ScheduleManagement: React.FC<ScheduleManagementProps> = ({
  schedules,
  loading,
  error,
  onCancel,
  onReschedule,
  onRetry
}) => {
  const [activeTab, setActiveTab] = useState<FilterTab>('all');
  const [globalFilter, setGlobalFilter] = useState('');

  // Apply filters based on tabs and date
  const filteredData = useMemo(() => {
    const todayStr = new Date().toISOString().split('T')[0];
    return schedules.filter(schedule => {
      // Tab filter
      if (activeTab === 'today') {
        return schedule.date === todayStr && schedule.status !== 'cancelled';
      }
      if (activeTab === 'upcoming') {
        return schedule.date >= todayStr && (schedule.status === 'confirmed' || schedule.status === 'pending');
      }
      if (activeTab === 'completed') {
        return schedule.status === 'completed';
      }
      if (activeTab === 'cancelled') {
        return schedule.status === 'cancelled';
      }
      return true;
    });
  }, [schedules, activeTab]);

  const columnHelper = createColumnHelper<Schedule>();

  const columns = useMemo(() => [
    columnHelper.accessor('date', {
      header: 'Data',
      cell: info => {
        const parts = info.getValue().split('-');
        return parts.length === 3 ? `${parts[2]}/${parts[1]}/${parts[0]}` : info.getValue();
      }
    }),
    columnHelper.accessor('time', {
      header: 'Horário',
      cell: info => info.getValue()
    }),
    columnHelper.accessor('services', {
      header: 'Serviços',
      cell: info => info.getValue().map(s => s.name).join(', ')
    }),
    columnHelper.accessor('barberName', {
      header: 'Barbeiro',
      cell: info => (
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <img
            src={info.row.original.barberAvatar}
            alt={info.getValue()}
            style={{ width: '24px', height: '24px', borderRadius: '50%', objectFit: 'cover' }}
          />
          <span>{info.getValue()}</span>
        </div>
      )
    }),
    columnHelper.accessor('totalValue', {
      header: 'Valor',
      cell: info => `R$ ${info.getValue().toFixed(2)}`
    }),
    columnHelper.accessor('status', {
      header: 'Status',
      cell: info => {
        const status = info.getValue();
        const getStatusLabel = (s: string) => {
          switch (s) {
            case 'confirmed': return 'Confirmado';
            case 'pending': return 'Pendente';
            case 'completed': return 'Concluído';
            case 'cancelled': return 'Cancelado';
            default: return s;
          }
        };
        return (
          <span className={`booking-status-tag status-${status}`}>
            {getStatusLabel(status)}
          </span>
        );
      }
    }),
    columnHelper.display({
      id: 'actions',
      header: 'Ações',
      cell: info => {
        const schedule = info.row.original;
        const isUpcoming = schedule.status === 'confirmed' || schedule.status === 'pending';
        return (
          <div style={{ display: 'flex', gap: '8px' }}>
            {isUpcoming ? (
              <>
                <button
                  className="btn-secondary"
                  style={{ padding: '6px 12px', fontSize: '0.8rem' }}
                  onClick={() => onReschedule(schedule)}
                  title="Reagendar atendimento"
                >
                  <RefreshCw size={12} /> Reagendar
                </button>
                <button
                  className="btn-secondary"
                  style={{ padding: '6px 12px', fontSize: '0.8rem', color: '#dc2626', borderColor: 'rgba(220,38,38,0.2)' }}
                  onClick={() => onCancel(schedule.id)}
                  title="Cancelar agendamento"
                >
                  <XCircle size={12} /> Cancelar
                </button>
              </>
            ) : (
              <span style={{ fontSize: '0.85rem', color: 'var(--color-light-text-secondary)' }}>Sem ações</span>
            )}
          </div>
        );
      }
    })
  ], [onCancel, onReschedule]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: {
      globalFilter,
    },
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel()
  });

  return (
    <div className="animate-fade-in" style={{ padding: '30px 40px' }}>
      <div className="section-title-row">
        <h3 className="section-title" style={{ fontSize: '1.5rem' }}>Gerenciamento de Agendamentos</h3>
      </div>

      <div className="table-filter-bar">
        <div className="table-tabs">
          <button
            className={`table-tab-btn ${activeTab === 'all' ? 'active' : ''}`}
            onClick={() => setActiveTab('all')}
          >
            Todos
          </button>
          <button
            className={`table-tab-btn ${activeTab === 'today' ? 'active' : ''}`}
            onClick={() => setActiveTab('today')}
          >
            Hoje
          </button>
          <button
            className={`table-tab-btn ${activeTab === 'upcoming' ? 'active' : ''}`}
            onClick={() => setActiveTab('upcoming')}
          >
            Próximos
          </button>
          <button
            className={`table-tab-btn ${activeTab === 'completed' ? 'active' : ''}`}
            onClick={() => setActiveTab('completed')}
          >
            Concluídos
          </button>
          <button
            className={`table-tab-btn ${activeTab === 'cancelled' ? 'active' : ''}`}
            onClick={() => setActiveTab('cancelled')}
          >
            Cancelados
          </button>
        </div>

        <div style={{ position: 'relative' }}>
          <Search size={16} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--color-light-text-secondary)' }} />
          <input
            type="text"
            className="table-search-input"
            style={{ paddingLeft: '36px' }}
            placeholder="Pesquisar agendamento..."
            value={globalFilter}
            onChange={(e) => setGlobalFilter(e.target.value)}
          />
        </div>
      </div>

      <StateContainer
        loading={loading}
        error={error}
        isEmpty={filteredData.length === 0}
        skeletonType="table-row"
        skeletonCount={5}
        emptyTitle="Nenhum agendamento encontrado"
        emptyMessage="Não encontramos agendamentos para o filtro selecionado."
        onRetry={onRetry}
      >
        <div className="table-container">
          <table className="premium-table">
            <thead>
              {table.getHeaderGroups().map(headerGroup => (
                <tr key={headerGroup.id}>
                  {headerGroup.headers.map(header => (
                    <th key={header.id}>
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody>
              {table.getRowModel().rows.map(row => (
                <tr key={row.id}>
                  {row.getVisibleCells().map(cell => (
                    <td key={cell.id}>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </StateContainer>
    </div>
  );
};

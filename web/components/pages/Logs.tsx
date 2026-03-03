import { useState, useEffect } from 'react';
import { Trash2, Download, AlertCircle, Info, CheckCircle, RotateCw, Copy } from 'lucide-react';
import { fetchNui } from '../../hooks/useNui';

interface Log {
  id: number;
  timestamp: string;
  type: 'info' | 'warning' | 'error';
  action: string;
  admin: string;
  target?: string;
  details: string;
}

interface LogsFeatures {
  viewLogs?: boolean;
  exportLogs?: boolean;
  clearLogs?: boolean;
}

interface LogsProps {
  darkMode: boolean;
  features: LogsFeatures;
}

const SAMPLE_LOGS: Log[] = [
  {
    id: 1,
    timestamp: '2024-01-15 14:32:45',
    type: 'warning',
    action: 'Player Kicked',
    admin: 'Admin#001',
    target: 'Player#123',
    details: 'Kicked for rule violation',
  },
  {
    id: 2,
    timestamp: '2024-01-15 14:25:12',
    type: 'info',
    action: 'Money Given',
    admin: 'Admin#001',
    target: 'Player#456',
    details: 'Given $50000',
  },
  {
    id: 3,
    timestamp: '2024-01-15 14:15:33',
    type: 'error',
    action: 'Ban Executed',
    admin: 'Admin#002',
    target: 'Player#789',
    details: 'Permanent ban for cheating',
  },
  {
    id: 4,
    timestamp: '2024-01-15 14:05:11',
    type: 'info',
    action: 'Server Restarted',
    admin: 'Admin#001',
    details: 'Scheduled maintenance restart',
  },
  {
    id: 5,
    timestamp: '2024-01-15 13:55:44',
    type: 'warning',
    action: 'Teleported',
    admin: 'Admin#001',
    target: 'Player#111',
    details: 'Teleported to jail',
  },
];

export default function Logs({ darkMode, features }: LogsProps) {
  const [logs, setLogs] = useState<Log[]>([]);
  const [filterType, setFilterType] = useState<'all' | 'info' | 'warning' | 'error'>('all');
  const [loading, setLoading] = useState(true);
  const [clearConfirm, setClearConfirm] = useState(false);
  const [exportStatus, setExportStatus] = useState<'idle' | 'exporting' | 'success' | 'error'>('idle');

  const fetchLogs = () => {
    setLoading(true);
    fetchNui('getLogs', {}, SAMPLE_LOGS).then((result: any) => {
      if (result?.logs) {
        setLogs(result.logs);
      } else if (Array.isArray(result)) {
        setLogs(result);
      } else {
        setLogs(SAMPLE_LOGS);
      }
      setLoading(false);
    }).catch(() => {
      setLogs(SAMPLE_LOGS);
      setLoading(false);
    });
  };

  // Fetch logs on mount
  useEffect(() => {
    fetchLogs();
  }, []);

  const filtered = filterType === 'all' ? logs : logs.filter(log => log.type === filterType);

  const handleClearLogs = () => {
    fetchNui('clearLogs', {});
    setLogs([]);
    setClearConfirm(false);
  };

  const handleExport = async () => {
    if (logs.length === 0) return;
    
    setExportStatus('exporting');
    
    const csv = [
      ['Timestamp', 'Type', 'Action', 'Admin', 'Target', 'Details'].join(','),
      ...logs.map(log => [
        log.timestamp,
        log.type,
        log.action,
        log.admin,
        log.target || '-',
        `"${log.details.replace(/"/g, '""')}"`,
      ].join(',')),
    ].join('\n');

    try {
      // Send to server to save as file
      const result = await fetchNui('exportLogs', { csv, filename: `admin-logs-${Date.now()}.csv` });
      if (result?.success) {
        setExportStatus('success');
        setTimeout(() => setExportStatus('idle'), 2000);
      } else {
        throw new Error('Export failed');
      }
    } catch (error) {
      // Fallback: try to copy to clipboard
      try {
        await navigator.clipboard.writeText(csv);
        setExportStatus('success');
        setTimeout(() => setExportStatus('idle'), 2000);
      } catch {
        setExportStatus('error');
        setTimeout(() => setExportStatus('idle'), 2000);
      }
    }
  };

  const bgClass = darkMode ? 'bg-stone-900' : 'bg-stone-50';
  const cardClass = darkMode ? 'bg-stone-800 border-stone-700' : 'bg-white border-stone-200';
  const textClass = darkMode ? 'text-stone-100' : 'text-stone-900';
  const secondaryText = darkMode ? 'text-stone-400' : 'text-stone-600';

  const typeColors = {
    info: { bg: darkMode ? 'bg-blue-900/30' : 'bg-blue-50', border: darkMode ? 'border-blue-700' : 'border-blue-200', text: darkMode ? 'text-blue-300' : 'text-blue-700', icon: Info },
    warning: { bg: darkMode ? 'bg-yellow-900/30' : 'bg-yellow-50', border: darkMode ? 'border-yellow-700' : 'border-yellow-200', text: darkMode ? 'text-yellow-300' : 'text-yellow-700', icon: AlertCircle },
    error: { bg: darkMode ? 'bg-red-900/30' : 'bg-red-50', border: darkMode ? 'border-red-700' : 'border-red-200', text: darkMode ? 'text-red-300' : 'text-red-700', icon: CheckCircle },
  };

  return (
    <div className={`p-6 ${bgClass} h-full`}>
      <div className="max-w-5xl">
        {/* Controls */}
        <div className="flex gap-3 mb-6">
          {(['all', 'info', 'warning', 'error'] as const).map((type) => (
            <button
              key={type}
              onClick={() => setFilterType(type)}
              className={`px-4 py-2 rounded-lg font-medium text-sm transition-colors ${
                filterType === type
                  ? darkMode
                    ? 'bg-blue-600 text-white'
                    : 'bg-blue-500 text-white'
                  : darkMode
                    ? 'bg-stone-700 text-stone-300 hover:bg-stone-600'
                    : 'bg-stone-200 text-stone-700 hover:bg-stone-300'
              }`}
            >
              {type === 'all' ? 'All' : type.charAt(0).toUpperCase() + type.slice(1)}
            </button>
          ))}
          <div className="flex-1" />
          <button
            onClick={fetchLogs}
            disabled={loading}
            className={`px-4 py-2 rounded-lg font-medium text-sm transition-colors flex items-center gap-2 ${
              darkMode
                ? 'bg-stone-700 text-stone-300 hover:bg-stone-600'
                : 'bg-stone-200 text-stone-700 hover:bg-stone-300'
            } ${loading ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            <RotateCw size={16} className={loading ? 'animate-spin' : ''} />
            Refresh
          </button>
          {features.exportLogs !== false && (
          <button
            onClick={handleExport}
            disabled={exportStatus === 'exporting' || logs.length === 0}
            className={`px-4 py-2 rounded-lg font-medium text-sm transition-colors flex items-center gap-2 ${
              exportStatus === 'success'
                ? 'bg-green-600 text-white'
                : exportStatus === 'error'
                  ? 'bg-red-600 text-white'
                  : darkMode
                    ? 'bg-stone-700 text-stone-300 hover:bg-stone-600'
                    : 'bg-stone-200 text-stone-700 hover:bg-stone-300'
            } ${exportStatus === 'exporting' || logs.length === 0 ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            {exportStatus === 'success' ? <CheckCircle size={16} /> : exportStatus === 'exporting' ? <RotateCw size={16} className="animate-spin" /> : <Download size={16} />}
            {exportStatus === 'success' ? 'Exported!' : exportStatus === 'error' ? 'Failed' : exportStatus === 'exporting' ? 'Exporting...' : 'Export'}
          </button>
          )}
          {features.clearLogs !== false && (
          <button
            onClick={() => setClearConfirm(true)}
            className={`px-4 py-2 rounded-lg font-medium text-sm transition-colors flex items-center gap-2 ${
              darkMode
                ? 'bg-red-600/20 text-red-400 hover:bg-red-600/30'
                : 'bg-red-100 text-red-700 hover:bg-red-200'
            }`}
          >
            <Trash2 size={16} />
            Clear
          </button>
          )}
        </div>

        {/* Logs List */}
        <div className="space-y-2">
          {loading ? (
            <div className={`text-center py-8 ${secondaryText}`}>
              Loading logs...
            </div>
          ) : filtered.length === 0 ? (
            <div className={`text-center py-8 ${secondaryText}`}>
              No logs found
            </div>
          ) : (
            filtered.map((log) => {
              const typeConfig = typeColors[log.type] || typeColors.info;
              const Icon = typeConfig?.icon || Info;
              return (
                <div
                  key={log.id}
                  className={`${cardClass} border ${typeConfig.border} rounded-lg p-4 ${typeConfig.bg}`}
                >
                  <div className="flex items-start gap-3">
                    <Icon className={`flex-shrink-0 ${typeConfig.text}`} size={18} style={{ marginTop: '2px' }} />
                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className={`font-semibold ${textClass}`}>{log.action}</p>
                          <p className={`text-xs ${secondaryText} mt-1`}>{log.timestamp}</p>
                        </div>
                        <div className={`text-xs px-2 py-1 rounded font-medium ${typeConfig.bg} ${typeConfig.text}`}>
                          {log.type.toUpperCase()}
                        </div>
                      </div>
                      <div className={`text-sm mt-2 ${secondaryText}`}>
                        <p><span className="font-medium">Admin:</span> {log.admin}</p>
                        {log.target && <p><span className="font-medium">Target:</span> {log.target}</p>}
                        <p><span className="font-medium">Details:</span> {log.details}</p>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Clear Confirmation Modal */}
      {clearConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setClearConfirm(false)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Clear All Logs</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>
              Are you sure you want to clear all logs? This action cannot be undone.
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setClearConfirm(false)}
                className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium transition-colors text-sm`}
              >
                Cancel
              </button>
              <button
                onClick={handleClearLogs}
                className="flex-1 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white font-medium transition-colors text-sm"
              >
                Clear Logs
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

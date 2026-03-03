import { Users, Package, MapPin, FileText, Moon, Sun, User, Car, CloudSun } from 'lucide-react';

type Page = 'players' | 'items' | 'teleport' | 'logs' | 'self' | 'vehicle' | 'world';

interface SidebarProps {
  currentPage: Page;
  onPageChange: (page: Page) => void;
  darkMode: boolean;
  onThemeToggle: () => void;
}

export default function Sidebar({ currentPage, onPageChange, darkMode, onThemeToggle }: SidebarProps) {
  const bgClass = darkMode ? 'bg-stone-950' : 'bg-white';
  const borderClass = darkMode ? 'border-stone-700' : 'border-stone-200';
  const hoverClass = darkMode 
    ? 'hover:bg-stone-800 text-stone-300 hover:text-stone-100' 
    : 'hover:bg-stone-100 text-stone-700 hover:text-stone-900';

  const menuItems: { id: Page; label: string; icon: typeof Users }[] = [
    { id: 'self', label: 'Self', icon: User },
    { id: 'players', label: 'Players', icon: Users },
    { id: 'vehicle', label: 'Vehicle', icon: Car },
    { id: 'world', label: 'World', icon: CloudSun },
    { id: 'items', label: 'Items', icon: Package },
    { id: 'teleport', label: 'Teleport', icon: MapPin },
    { id: 'logs', label: 'Logs', icon: FileText },
  ];

  return (
    <aside className={`w-48 h-full border-r ${borderClass} ${bgClass} flex flex-col`}>
      {/* Logo/Header */}
      <div className={`h-12 border-b ${borderClass} flex items-center px-4`}>
        <h2 className={`text-xs font-semibold uppercase tracking-wider ${darkMode ? 'text-stone-400' : 'text-stone-500'}`}>
          Admin Panel
        </h2>
      </div>

      {/* Menu */}
      <nav className="flex-1 overflow-y-auto p-3 space-y-2">
        {menuItems.map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            onClick={() => onPageChange(id)}
            className={`w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
              currentPage === id
                ? darkMode
                  ? 'bg-blue-600/20 text-blue-400 border border-blue-500/30'
                  : 'bg-blue-100 text-blue-700 border border-blue-300/50'
                : hoverClass
            }`}
          >
            <Icon size={16} />
            <span>{label}</span>
          </button>
        ))}
      </nav>

      {/* Footer */}
      <div className={`border-t ${borderClass} p-3 space-y-2`}>
        <button
          onClick={onThemeToggle}
          className={`w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${hoverClass}`}
        >
          {darkMode ? <Sun size={16} /> : <Moon size={16} />}
          <span>{darkMode ? 'Light' : 'Dark'}</span>
        </button>
      </div>
    </aside>
  );
}

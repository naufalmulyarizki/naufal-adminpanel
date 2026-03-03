import { useState, useCallback, useEffect } from 'react';
import { isDebug, useNuiEvent, fetchNui } from './hooks/useNui';
import Sidebar from './components/Sidebar';
import Players from './components/pages/Players';
import Items from './components/pages/Items';
import Teleport from './components/pages/Teleport';
import Logs from './components/pages/Logs';
import Self from './components/pages/Self';
import Vehicle from './components/pages/Vehicle';
import World from './components/pages/World';

type Page = 'players' | 'items' | 'teleport' | 'logs' | 'self' | 'vehicle' | 'world';

interface Player {
  id: number;
  name: string;
  license: string;
  money: number;
  bank: number;
}

interface SelfOptions {
  godMode: boolean;
  invisible: boolean;
  noclip: boolean;
  infiniteStamina: boolean;
  noRagdoll: boolean;
  fastRun: boolean;
  superJump: boolean;
  showBlips: boolean;
  showPlayerNames: boolean;
}

interface WorldOptions {
  weather: string;
  freezeTime: boolean;
  blackout: boolean;
}

interface PlayerOptions {
  frozenPlayers: number[];
  mutedPlayers: number[];
  spectatingPlayer: number | null;
}

// Feature permissions interface
export interface Features {
  self?: {
    healSelf?: boolean;
    reviveSelf?: boolean;
    tpToWaypoint?: boolean;
    toggleDuty?: boolean;
    openClothingMenu?: boolean;
    copyCoords?: boolean;
    godMode?: boolean;
    invisible?: boolean;
    noclip?: boolean;
    infiniteStamina?: boolean;
    noRagdoll?: boolean;
    fastRun?: boolean;
    superJump?: boolean;
    showBlips?: boolean;
    showPlayerNames?: boolean;
  };
  players?: {
    viewPlayers?: boolean;
    giveMoney?: boolean;
    giveCar?: boolean;
    giveItem?: boolean;
    freezePlayer?: boolean;
    mutePlayer?: boolean;
    spectatePlayer?: boolean;
    kickPlayer?: boolean;
    banPlayer?: boolean;
    makePlayerDrunk?: boolean;
    openPlayerInventory?: boolean;
    removeMoneyPlayer?: boolean;
    removeStress?: boolean;
    reviveRadius?: boolean;
    setPlayerPed?: boolean;
    setRoutingBucket?: boolean;
    giveClothingMenu?: boolean;
    fixPlayerVehicle?: boolean;
    clearInventory?: boolean;
  };
  vehicle?: {
    spawnVehicle?: boolean;
    deleteVehicle?: boolean;
    repairVehicle?: boolean;
    flipVehicle?: boolean;
    maxUpgrades?: boolean;
    setFuel?: boolean;
    engineToggle?: boolean;
    lockToggle?: boolean;
  };
  world?: {
    setWeather?: boolean;
    setTime?: boolean;
    freezeTime?: boolean;
    blackout?: boolean;
  };
  items?: {
    giveItemToSelf?: boolean;
    giveMoneyToSelf?: boolean;
    giveItemToAll?: boolean;
    giveMoneyToAll?: boolean;
    openStash?: boolean;
    openTrunk?: boolean;
  };
  teleport?: {
    teleportToLocation?: boolean;
    teleportToPlayer?: boolean;
    teleportPlayer?: boolean;
    bringPlayer?: boolean;
  };
  logs?: {
    viewLogs?: boolean;
    exportLogs?: boolean;
    clearLogs?: boolean;
  };
}

// Default features for debug mode (all enabled)
const defaultFeatures: Features = {
  self: {
    healSelf: true, reviveSelf: true, tpToWaypoint: true, toggleDuty: true,
    openClothingMenu: true, copyCoords: true, godMode: true, invisible: true,
    noclip: true, infiniteStamina: true, noRagdoll: true, fastRun: true,
    superJump: true, showBlips: true, showPlayerNames: true,
  },
  players: {
    viewPlayers: true, giveMoney: true, giveCar: true, giveItem: true,
    freezePlayer: true, mutePlayer: true, spectatePlayer: true, kickPlayer: true,
    banPlayer: true, makePlayerDrunk: true, openPlayerInventory: true,
    removeMoneyPlayer: true, removeStress: true, reviveRadius: true,
    setPlayerPed: true, setRoutingBucket: true, giveClothingMenu: true,
    fixPlayerVehicle: true, clearInventory: true,
  },
  vehicle: {
    spawnVehicle: true, deleteVehicle: true, repairVehicle: true, flipVehicle: true,
    maxUpgrades: true, setFuel: true, engineToggle: true, lockToggle: true,
  },
  world: {
    setWeather: true, setTime: true, freezeTime: true, blackout: true,
  },
  items: {
    giveItemToSelf: true, giveMoneyToSelf: true, giveItemToAll: true,
    giveMoneyToAll: true, openStash: true, openTrunk: true,
  },
  teleport: {
    teleportToLocation: true, teleportToPlayer: true, teleportPlayer: true, bringPlayer: true,
  },
  logs: {
    viewLogs: true, exportLogs: true, clearLogs: true,
  },
};

export default function App() {
  const [visible, setVisible] = useState(isDebug);
  const [currentPage, setCurrentPage] = useState<Page>('players');
  const [darkMode, setDarkMode] = useState(true);
  const [players, setPlayers] = useState<Player[]>([]);
  const [features, setFeatures] = useState<Features>(isDebug ? defaultFeatures : {});
  const [selfOptions, setSelfOptions] = useState<SelfOptions>({
    godMode: false,
    invisible: false,
    noclip: false,
    infiniteStamina: false,
    noRagdoll: false,
    fastRun: false,
    superJump: false,
    showBlips: false,
    showPlayerNames: false,
  });
  const [worldOptions, setWorldOptions] = useState<WorldOptions>({
    weather: 'CLEAR',
    freezeTime: false,
    blackout: false,
  });
  const [playerOptions, setPlayerOptions] = useState<PlayerOptions>({
    frozenPlayers: [],
    mutedPlayers: [],
    spectatingPlayer: null,
  });

  useNuiEvent('open', (data: any) => {
    if (data?.players) setPlayers(data.players);
    if (data?.selfOptions) setSelfOptions(data.selfOptions);
    if (data?.worldOptions) setWorldOptions(data.worldOptions);
    if (data?.playerOptions) setPlayerOptions(data.playerOptions);
    if (data?.features) setFeatures(data.features);
    setVisible(true);
  });

  useNuiEvent('close', () => setVisible(false));

  useNuiEvent('playersUpdated', (data: any) => {
    setPlayers(data.players || []);
  });

  const handleClose = useCallback(() => {
    setVisible(false);
    fetchNui('close', {}, { success: true });
  }, []);

  useEffect(() => {
    const onKeyDown = (e: any) => {
      if (e.key === 'Escape') handleClose();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [handleClose]);

  if (!visible) return null;

  const bgClass = darkMode ? 'bg-stone-900' : 'bg-stone-50';
  const textClass = darkMode ? 'text-stone-100' : 'text-stone-900';
  const borderClass = darkMode ? 'border-stone-700' : 'border-stone-200';

  return (
    <div className="fixed inset-0 flex items-center justify-center" style={{ fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", "San Francisco", Helvetica, Arial, sans-serif' }}>
      <div className={`flex ${bgClass} rounded-xl shadow-2xl overflow-hidden border ${borderClass}`} style={{ width: '900px', height: '600px', maxWidth: '95vw', maxHeight: '90vh' }}>
        <Sidebar 
          currentPage={currentPage} 
          onPageChange={setCurrentPage}
          darkMode={darkMode}
          onThemeToggle={() => setDarkMode(!darkMode)}
        />
        
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Top bar */}
          <div className={`h-12 border-b ${borderClass} flex items-center justify-between px-6 ${darkMode ? 'bg-stone-800/50' : 'bg-white/50'}`}>
            <h1 className={`text-sm font-semibold ${textClass}`}>
              {currentPage === 'players' && 'Player Management'}
              {currentPage === 'items' && 'Item Management'}
              {currentPage === 'teleport' && 'Teleportation'}
              {currentPage === 'logs' && 'System Logs'}
              {currentPage === 'self' && 'Self Options'}
              {currentPage === 'vehicle' && 'Vehicle Manager'}
              {currentPage === 'world' && 'World Settings'}
            </h1>
            <button
              onClick={handleClose}
              className={`text-lg leading-none transition-colors ${
                darkMode 
                  ? 'text-stone-500 hover:text-stone-300' 
                  : 'text-stone-400 hover:text-stone-600'
              }`}
            >
              ✕
            </button>
          </div>

          {/* Content */}
          <div className="flex-1 overflow-auto">
            {currentPage === 'players' && <Players players={players} darkMode={darkMode} playerOptions={playerOptions} onPlayerOptionsChange={setPlayerOptions} features={features.players || {}} />}
            {currentPage === 'items' && <Items darkMode={darkMode} features={features.items || {}} />}
            {currentPage === 'teleport' && <Teleport darkMode={darkMode} features={features.teleport || {}} />}
            {currentPage === 'logs' && <Logs darkMode={darkMode} features={features.logs || {}} />}
            {currentPage === 'self' && <Self darkMode={darkMode} selfOptions={selfOptions} onSelfOptionsChange={setSelfOptions} features={features.self || {}} />}
            {currentPage === 'vehicle' && <Vehicle darkMode={darkMode} features={features.vehicle || {}} />}
            {currentPage === 'world' && <World darkMode={darkMode} worldOptions={worldOptions} onWorldOptionsChange={setWorldOptions} features={features.world || {}} />}
          </div>
        </div>
      </div>
    </div>
  );
}

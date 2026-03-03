import { useState, useEffect } from 'react';
import { Shield, Eye, Zap, Heart, Wind, ArrowUp, Copy, Crosshair, EyeOff, Briefcase, MapPin, Users, Shirt } from 'lucide-react';
import { fetchNui, useNuiEvent } from '../../hooks/useNui';

interface SelfToggles {
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

interface SelfFeatures {
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
}

interface SelfProps {
  darkMode: boolean;
  selfOptions: SelfToggles;
  onSelfOptionsChange: (options: SelfToggles) => void;
  features: SelfFeatures;
}

export default function Self({ darkMode, selfOptions, onSelfOptionsChange, features }: SelfProps) {
  const [coords, setCoords] = useState({ x: 0, y: 0, z: 0, heading: 0 });
  const [copied, setCopied] = useState(false);

  // Listen for coords updates
  useNuiEvent('updateCoords', (data: any) => {
    setCoords(data);
  });

  const handleToggle = (key: keyof SelfToggles) => {
    const newValue = !selfOptions[key];
    onSelfOptionsChange({ ...selfOptions, [key]: newValue });
    fetchNui('selfToggle', { option: key, enabled: newValue });
  };

  const handleHealSelf = () => {
    fetchNui('healSelf', {});
  };

  const handleReviveSelf = () => {
    fetchNui('reviveSelf', {});
  };

  const handleTpToWaypoint = () => {
    fetchNui('tpToWaypoint', {});
  };

  const handleToggleDuty = () => {
    fetchNui('toggleDuty', {});
  };

  const handleOpenClothingMenu = () => {
    fetchNui('openClothingMenu', {});
  };

  const handleCopyCoords = () => {
    const coordString = `vector3(${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)})`;
    navigator.clipboard.writeText(coordString);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const bgClass = darkMode ? 'bg-stone-900' : 'bg-stone-50';
  const cardClass = darkMode ? 'bg-stone-800 border-stone-700' : 'bg-white border-stone-200';
  const textClass = darkMode ? 'text-stone-100' : 'text-stone-900';
  const secondaryText = darkMode ? 'text-stone-400' : 'text-stone-600';

  const toggleItems = [
    { key: 'godMode' as const, label: 'God Mode', icon: Shield, description: 'Invincibility' },
    { key: 'invisible' as const, label: 'Invisible', icon: EyeOff, description: 'Hidden from others' },
    { key: 'noclip' as const, label: 'NoClip', icon: Wind, description: 'Fly through walls' },
    { key: 'infiniteStamina' as const, label: 'Infinite Stamina', icon: Zap, description: 'Never get tired' },
    { key: 'noRagdoll' as const, label: 'No Ragdoll', icon: ArrowUp, description: 'No falling down' },
    { key: 'fastRun' as const, label: 'Fast Run', icon: Zap, description: '1.5x run speed' },
    { key: 'superJump' as const, label: 'Super Jump', icon: ArrowUp, description: 'Jump higher' },
    { key: 'showBlips' as const, label: 'Show Blips', icon: MapPin, description: 'Show player blips' },
    { key: 'showPlayerNames' as const, label: 'Player Names', icon: Users, description: 'Show overhead names' },
  ].filter(item => features[item.key] !== false);

  return (
    <div className={`p-6 ${bgClass} h-full overflow-auto`}>
      <div className="max-w-4xl">
        {/* Quick Actions */}
        <div className="grid grid-cols-5 gap-3 mb-6">
          {features.healSelf !== false && (
            <button
              onClick={handleHealSelf}
              className="py-3 px-4 rounded-lg bg-green-600 hover:bg-green-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Heart size={18} />
              Heal Self
            </button>
          )}
          {features.reviveSelf !== false && (
            <button
              onClick={handleReviveSelf}
              className="py-3 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Heart size={18} />
              Revive Self
            </button>
          )}
          {features.tpToWaypoint !== false && (
            <button
              onClick={handleTpToWaypoint}
              className="py-3 px-4 rounded-lg bg-purple-600 hover:bg-purple-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Crosshair size={18} />
              TP to Waypoint
            </button>
          )}
          {features.toggleDuty !== false && (
            <button
              onClick={handleToggleDuty}
              className="py-3 px-4 rounded-lg bg-orange-600 hover:bg-orange-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Briefcase size={18} />
              Toggle Duty
            </button>
          )}
          {features.openClothingMenu !== false && (
            <button
              onClick={handleOpenClothingMenu}
              className="py-3 px-4 rounded-lg bg-pink-600 hover:bg-pink-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Shirt size={18} />
              Clothing
            </button>
          )}
        </div>

        {/* Toggles */}
        <div className={`${cardClass} border rounded-lg p-6 mb-6`}>
          <h2 className={`text-lg font-semibold ${textClass} mb-4`}>Self Options</h2>
          <div className="grid grid-cols-2 gap-3">
            {toggleItems.map(({ key, label, icon: Icon, description }) => (
              <button
                key={key}
                onClick={() => handleToggle(key)}
                className={`p-4 rounded-lg border transition-colors text-left ${
                  selfOptions[key]
                    ? darkMode
                      ? 'bg-blue-600/20 border-blue-500 text-blue-400'
                      : 'bg-blue-100 border-blue-400 text-blue-700'
                    : cardClass
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`p-2 rounded-lg ${selfOptions[key] ? 'bg-blue-500/20' : darkMode ? 'bg-stone-700' : 'bg-stone-100'}`}>
                    <Icon size={18} className={selfOptions[key] ? 'text-blue-400' : secondaryText} />
                  </div>
                  <div className="flex-1">
                    <p className={`font-medium ${selfOptions[key] ? (darkMode ? 'text-blue-300' : 'text-blue-700') : textClass}`}>
                      {label}
                    </p>
                    <p className={`text-xs ${secondaryText}`}>{description}</p>
                  </div>
                  <div className={`w-10 h-6 rounded-full transition-colors ${selfOptions[key] ? 'bg-blue-500' : darkMode ? 'bg-stone-600' : 'bg-stone-300'}`}>
                    <div className={`w-5 h-5 rounded-full bg-white shadow-sm transition-transform mt-0.5 ${selfOptions[key] ? 'translate-x-4 ml-0.5' : 'translate-x-0.5'}`} />
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Coordinates Display */}
        <div className={`${cardClass} border rounded-lg p-6`}>
          <div className="flex items-center justify-between mb-4">
            <h2 className={`text-lg font-semibold ${textClass}`}>Current Position</h2>
            <button
              onClick={handleCopyCoords}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors flex items-center gap-2 ${
                copied
                  ? 'bg-green-600 text-white'
                  : darkMode
                    ? 'bg-stone-700 text-stone-300 hover:bg-stone-600'
                    : 'bg-stone-200 text-stone-700 hover:bg-stone-300'
              }`}
            >
              <Copy size={14} />
              {copied ? 'Copied!' : 'Copy Coords'}
            </button>
          </div>
          <div className="grid grid-cols-4 gap-4">
            <div className={`${darkMode ? 'bg-stone-700/50' : 'bg-stone-100'} rounded-lg p-4 text-center`}>
              <p className={`text-xs ${secondaryText} mb-1`}>X</p>
              <p className={`font-mono font-semibold ${textClass}`}>{coords.x.toFixed(2)}</p>
            </div>
            <div className={`${darkMode ? 'bg-stone-700/50' : 'bg-stone-100'} rounded-lg p-4 text-center`}>
              <p className={`text-xs ${secondaryText} mb-1`}>Y</p>
              <p className={`font-mono font-semibold ${textClass}`}>{coords.y.toFixed(2)}</p>
            </div>
            <div className={`${darkMode ? 'bg-stone-700/50' : 'bg-stone-100'} rounded-lg p-4 text-center`}>
              <p className={`text-xs ${secondaryText} mb-1`}>Z</p>
              <p className={`font-mono font-semibold ${textClass}`}>{coords.z.toFixed(2)}</p>
            </div>
            <div className={`${darkMode ? 'bg-stone-700/50' : 'bg-stone-100'} rounded-lg p-4 text-center`}>
              <p className={`text-xs ${secondaryText} mb-1`}>Heading</p>
              <p className={`font-mono font-semibold ${textClass}`}>{coords.heading.toFixed(1)}°</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

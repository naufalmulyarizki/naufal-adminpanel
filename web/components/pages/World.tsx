import { useState } from 'react';
import { Sun, Cloud, CloudRain, CloudSnow, CloudLightning, Moon, Clock, Pause, Play, Zap } from 'lucide-react';
import { fetchNui } from '../../hooks/useNui';

interface WorldOptions {
  weather: string;
  freezeTime: boolean;
  blackout: boolean;
}

interface WorldFeatures {
  setWeather?: boolean;
  setTime?: boolean;
  freezeTime?: boolean;
  blackout?: boolean;
}

interface WorldProps {
  darkMode: boolean;
  worldOptions: WorldOptions;
  onWorldOptionsChange: (options: WorldOptions) => void;
  features: WorldFeatures;
}

const WEATHER_OPTIONS = [
  { id: 'EXTRASUNNY', label: 'Extra Sunny', icon: Sun },
  { id: 'CLEAR', label: 'Clear', icon: Sun },
  { id: 'CLOUDS', label: 'Cloudy', icon: Cloud },
  { id: 'OVERCAST', label: 'Overcast', icon: Cloud },
  { id: 'RAIN', label: 'Rain', icon: CloudRain },
  { id: 'THUNDER', label: 'Thunder', icon: CloudLightning },
  { id: 'CLEARING', label: 'Clearing', icon: Cloud },
  { id: 'SMOG', label: 'Smog', icon: Cloud },
  { id: 'FOGGY', label: 'Foggy', icon: Cloud },
  { id: 'XMAS', label: 'Snow', icon: CloudSnow },
  { id: 'SNOWLIGHT', label: 'Light Snow', icon: CloudSnow },
  { id: 'BLIZZARD', label: 'Blizzard', icon: CloudSnow },
];

const TIME_PRESETS = [
  { hour: 6, label: 'Dawn', icon: Sun },
  { hour: 12, label: 'Noon', icon: Sun },
  { hour: 18, label: 'Dusk', icon: Sun },
  { hour: 0, label: 'Midnight', icon: Moon },
  { hour: 3, label: 'Night', icon: Moon },
  { hour: 9, label: 'Morning', icon: Sun },
];

export default function World({ darkMode, worldOptions, onWorldOptionsChange, features }: WorldProps) {
  const [customHour, setCustomHour] = useState('12');
  const [customMinute, setCustomMinute] = useState('0');

  const handleSetWeather = (weather: string) => {
    onWorldOptionsChange({ ...worldOptions, weather });
    fetchNui('setWeather', { weather });
  };

  const handleSetTime = (hour: number, minute: number = 0) => {
    fetchNui('setTime', { hour, minute });
  };

  const handleCustomTime = () => {
    const hour = parseInt(customHour) || 0;
    const minute = parseInt(customMinute) || 0;
    handleSetTime(Math.min(23, Math.max(0, hour)), Math.min(59, Math.max(0, minute)));
  };

  const handleFreezeTime = () => {
    const newValue = !worldOptions.freezeTime;
    onWorldOptionsChange({ ...worldOptions, freezeTime: newValue });
    fetchNui('freezeTime', { enabled: newValue });
  };

  const handleBlackout = () => {
    const newValue = !worldOptions.blackout;
    onWorldOptionsChange({ ...worldOptions, blackout: newValue });
    fetchNui('setBlackout', { enabled: newValue });
  };

  const bgClass = darkMode ? 'bg-stone-900' : 'bg-stone-50';
  const cardClass = darkMode ? 'bg-stone-800 border-stone-700' : 'bg-white border-stone-200';
  const textClass = darkMode ? 'text-stone-100' : 'text-stone-900';
  const secondaryText = darkMode ? 'text-stone-400' : 'text-stone-600';
  const inputClass = darkMode 
    ? 'bg-stone-700 border-stone-600 text-stone-100 placeholder-stone-500' 
    : 'bg-white border-stone-300 text-stone-900 placeholder-stone-400';

  return (
    <div className={`p-6 ${bgClass} h-full overflow-auto`}>
      <div className="max-w-4xl">
        {/* Weather Control */}
        {features.setWeather !== false && (
        <div className={`${cardClass} border rounded-lg p-6 mb-6`}>
          <h2 className={`text-lg font-semibold ${textClass} mb-4`}>Weather Control</h2>
          <div className="grid grid-cols-4 gap-3">
            {WEATHER_OPTIONS.map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => handleSetWeather(id)}
                className={`p-3 rounded-lg border transition-colors ${
                  worldOptions.weather === id
                    ? darkMode
                      ? 'bg-blue-600/20 border-blue-500 text-blue-400'
                      : 'bg-blue-100 border-blue-400 text-blue-700'
                    : cardClass + ' hover:border-blue-500'
                }`}
              >
                <div className="flex flex-col items-center gap-2">
                  <Icon size={20} className={worldOptions.weather === id ? 'text-blue-400' : secondaryText} />
                  <span className={`text-xs font-medium ${worldOptions.weather === id ? '' : textClass}`}>{label}</span>
                </div>
              </button>
            ))}
          </div>
        </div>
        )}

        {/* Time Control */}
        {(features.setTime !== false || features.freezeTime !== false) && (
        <div className={`${cardClass} border rounded-lg p-6 mb-6`}>
          <h2 className={`text-lg font-semibold ${textClass} mb-4`}>Time Control</h2>
          
          {/* Time Presets */}
          {features.setTime !== false && (
          <>
          <div className="grid grid-cols-6 gap-2 mb-4">
            {TIME_PRESETS.map(({ hour, label, icon: Icon }) => (
              <button
                key={label}
                onClick={() => handleSetTime(hour)}
                className={`p-3 rounded-lg border transition-colors ${cardClass} hover:border-blue-500`}
              >
                <div className="flex flex-col items-center gap-1">
                  <Icon size={16} className={secondaryText} />
                  <span className={`text-xs font-medium ${textClass}`}>{label}</span>
                  <span className={`text-xs ${secondaryText}`}>{hour}:00</span>
                </div>
              </button>
            ))}
          </div>

          {/* Custom Time */}
          <div className="flex gap-2 mb-4">
            <div className="flex-1 flex gap-2">
              <input
                type="number"
                placeholder="Hour (0-23)"
                value={customHour}
                onChange={(e) => setCustomHour(e.target.value)}
                min="0"
                max="23"
                className={`flex-1 px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500`}
              />
              <input
                type="number"
                placeholder="Minute (0-59)"
                value={customMinute}
                onChange={(e) => setCustomMinute(e.target.value)}
                min="0"
                max="59"
                className={`flex-1 px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500`}
              />
            </div>
            <button
              onClick={handleCustomTime}
              className="px-4 py-2 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium transition-colors flex items-center gap-2"
            >
              <Clock size={18} />
              Set Time
            </button>
          </div>
          </>
          )}

          {/* Toggle Options */}
          <div className="grid grid-cols-2 gap-3">
            {features.freezeTime !== false && (
            <button
              onClick={handleFreezeTime}
              className={`p-4 rounded-lg border transition-colors ${
                worldOptions.freezeTime
                  ? darkMode
                    ? 'bg-blue-600/20 border-blue-500'
                    : 'bg-blue-100 border-blue-400'
                  : cardClass
              }`}
            >
              <div className="flex items-center gap-3">
                {worldOptions.freezeTime ? <Pause size={20} className="text-blue-400" /> : <Play size={20} className={secondaryText} />}
                <div className="text-left flex-1">
                  <p className={`font-medium ${textClass}`}>Freeze Time</p>
                  <p className={`text-xs ${secondaryText}`}>{worldOptions.freezeTime ? 'Time is frozen' : 'Time is running'}</p>
                </div>
                <div className={`w-10 h-6 rounded-full transition-colors ${worldOptions.freezeTime ? 'bg-blue-500' : darkMode ? 'bg-stone-600' : 'bg-stone-300'}`}>
                  <div className={`w-5 h-5 rounded-full bg-white shadow-sm transition-transform mt-0.5 ${worldOptions.freezeTime ? 'translate-x-4 ml-0.5' : 'translate-x-0.5'}`} />
                </div>
              </div>
            </button>
            )}

            {features.blackout !== false && (
            <button
              onClick={handleBlackout}
              className={`p-4 rounded-lg border transition-colors ${
                worldOptions.blackout
                  ? darkMode
                    ? 'bg-red-600/20 border-red-500'
                    : 'bg-red-100 border-red-400'
                  : cardClass
              }`}
            >
              <div className="flex items-center gap-3">
                <Zap size={20} className={worldOptions.blackout ? 'text-red-400' : secondaryText} />
                <div className="text-left flex-1">
                  <p className={`font-medium ${textClass}`}>Blackout</p>
                  <p className={`text-xs ${secondaryText}`}>{worldOptions.blackout ? 'Lights are off' : 'Lights are on'}</p>
                </div>
                <div className={`w-10 h-6 rounded-full transition-colors ${worldOptions.blackout ? 'bg-red-500' : darkMode ? 'bg-stone-600' : 'bg-stone-300'}`}>
                  <div className={`w-5 h-5 rounded-full bg-white shadow-sm transition-transform mt-0.5 ${worldOptions.blackout ? 'translate-x-4 ml-0.5' : 'translate-x-0.5'}`} />
                </div>
              </div>
            </button>
            )}
          </div>
        </div>
        )}
      </div>
    </div>
  );
}

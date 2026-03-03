import { useState } from 'react';
import { MapPin, Plus, Trash2 } from 'lucide-react';
import { fetchNui } from '../../hooks/useNui';

interface TeleportFeatures {
  teleportToLocation?: boolean;
  teleportToPlayer?: boolean;
  teleportPlayer?: boolean;
  bringPlayer?: boolean;
}

interface TeleportProps {
  darkMode: boolean;
  features: TeleportFeatures;
}

const PRESET_LOCATIONS = [
  { id: 1, name: 'City Hall', coords: { x: 425.4, y: -979.8, z: 29.4 } },
  { id: 2, name: 'Police Station', coords: { x: 425.1, y: -980.5, z: 29.3 } },
  { id: 3, name: 'Hospital', coords: { x: 350.8, y: -588.5, z: 43.4 } },
  { id: 4, name: 'Airport', coords: { x: -1040.2, y: -2741.5, z: 21.5 } },
  { id: 5, name: 'Beach', coords: { x: -1546.6, y: -1055.9, z: 25.5 } },
];

export default function Teleport({ darkMode, features }: TeleportProps) {
  const [x, setX] = useState('');
  const [y, setY] = useState('');
  const [z, setZ] = useState('');
  const [heading, setHeading] = useState('0');
  const [selectedLocation, setSelectedLocation] = useState<number | null>(null);
  const [targetPlayer, setTargetPlayer] = useState('');

  const handleTeleportPlayer = () => {
    if (!targetPlayer || (!selectedLocation && (!x || !y || !z))) return;

    let coords = { x: 0, y: 0, z: 0 };
    if (selectedLocation) {
      const location = PRESET_LOCATIONS.find(l => l.id === selectedLocation);
      if (location) coords = location.coords;
    } else {
      coords = { x: parseFloat(x), y: parseFloat(y), z: parseFloat(z) };
    }

    fetchNui('teleportPlayer', {
      playerId: parseInt(targetPlayer),
      coords,
      heading: parseFloat(heading) || 0,
    });

    setX('');
    setY('');
    setZ('');
    setHeading('0');
    setTargetPlayer('');
    setSelectedLocation(null);
  };

  const handleTeleportSelf = () => {
    if (!selectedLocation && (!x || !y || !z)) return;

    let coords = { x: 0, y: 0, z: 0 };
    if (selectedLocation) {
      const location = PRESET_LOCATIONS.find(l => l.id === selectedLocation);
      if (location) coords = location.coords;
    } else {
      coords = { x: parseFloat(x), y: parseFloat(y), z: parseFloat(z) };
    }

    fetchNui('teleportSelf', {
      coords,
      heading: parseFloat(heading),
    });
  };

  const bgClass = darkMode ? 'bg-stone-900' : 'bg-stone-50';
  const cardClass = darkMode ? 'bg-stone-800 border-stone-700' : 'bg-white border-stone-200';
  const textClass = darkMode ? 'text-stone-100' : 'text-stone-900';
  const secondaryText = darkMode ? 'text-stone-400' : 'text-stone-600';
  const inputClass = darkMode 
    ? 'bg-stone-700 border-stone-600 text-stone-100 placeholder-stone-500' 
    : 'bg-white border-stone-300 text-stone-900 placeholder-stone-400';

  return (
    <div className={`p-6 ${bgClass} h-full`}>
      <div className="max-w-4xl">
        {/* Preset Locations */}
        <div className="mb-6">
          <h2 className={`text-lg font-semibold ${textClass} mb-4`}>Preset Locations</h2>
          <div className="grid grid-cols-2 gap-3">
            {PRESET_LOCATIONS.map((location) => (
              <button
                key={location.id}
                onClick={() => setSelectedLocation(selectedLocation === location.id ? null : location.id)}
                className={`${cardClass} border rounded-lg p-3 text-left transition-colors ${
                  selectedLocation === location.id
                    ? darkMode
                      ? 'ring-2 ring-blue-500 bg-stone-700'
                      : 'ring-2 ring-blue-500 bg-blue-50'
                    : 'hover:shadow-md'
                }`}
              >
                <p className={`font-semibold ${textClass}`}>{location.name}</p>
                <p className={`text-xs mt-1 ${secondaryText}`}>
                  {location.coords.x.toFixed(1)}, {location.coords.y.toFixed(1)}, {location.coords.z.toFixed(1)}
                </p>
              </button>
            ))}
          </div>
        </div>

        {/* Custom Coordinates */}
        <div className={`${cardClass} border rounded-lg p-6 mb-6`}>
          <h3 className={`font-semibold ${textClass} mb-4`}>Custom Coordinates</h3>
          <div className="grid grid-cols-3 gap-3 mb-4">
            <div>
              <label className={`text-xs font-medium ${textClass} block mb-2`}>X</label>
              <input
                type="number"
                placeholder="X"
                value={x}
                onChange={(e) => setX(e.target.value)}
                step="0.1"
                className={`w-full px-3 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm`}
              />
            </div>
            <div>
              <label className={`text-xs font-medium ${textClass} block mb-2`}>Y</label>
              <input
                type="number"
                placeholder="Y"
                value={y}
                onChange={(e) => setY(e.target.value)}
                step="0.1"
                className={`w-full px-3 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm`}
              />
            </div>
            <div>
              <label className={`text-xs font-medium ${textClass} block mb-2`}>Z</label>
              <input
                type="number"
                placeholder="Z"
                value={z}
                onChange={(e) => setZ(e.target.value)}
                step="0.1"
                className={`w-full px-3 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm`}
              />
            </div>
          </div>
          <div className="mb-4">
            <label className={`text-xs font-medium ${textClass} block mb-2`}>Heading (degrees)</label>
            <input
              type="number"
              placeholder="Heading"
              value={heading}
              onChange={(e) => setHeading(e.target.value)}
              step="1"
              className={`w-full px-3 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm`}
            />
          </div>
        </div>

        {/* Teleport Options */}
        <div className="space-y-3">
          {features.teleportPlayer !== false && (
          <div className={`${cardClass} border rounded-lg p-4`}>
            <label className={`text-sm font-medium ${textClass} block mb-2`}>Teleport Player</label>
            <input
              type="text"
              placeholder="Player ID"
              value={targetPlayer}
              onChange={(e) => setTargetPlayer(e.target.value)}
              className={`w-full px-3 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm mb-2`}
            />
            <button
              onClick={handleTeleportPlayer}
              className="w-full py-2 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium transition-colors text-sm"
            >
              <MapPin size={16} className="inline mr-2" />
              Teleport Player
            </button>
          </div>
          )}

          {features.teleportToLocation !== false && (
          <button
            onClick={handleTeleportSelf}
            className="w-full py-3 rounded-lg bg-purple-600 hover:bg-purple-700 text-white font-medium transition-colors"
          >
            <MapPin size={16} className="inline mr-2" />
            Teleport Yourself
          </button>
          )}
        </div>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { Car, Wrench, Trash2, Fuel, RotateCcw, Plus, Search, FileText } from 'lucide-react';
import { fetchNui } from '../../hooks/useNui';

interface VehicleFeatures {
  spawnVehicle?: boolean;
  deleteVehicle?: boolean;
  repairVehicle?: boolean;
  setFuel?: boolean;
  flipVehicle?: boolean;
  maxUpgrades?: boolean;
  engineToggle?: boolean;
  lockToggle?: boolean;
}

interface VehicleProps {
  darkMode: boolean;
  features: VehicleFeatures;
}

const POPULAR_VEHICLES = [
  { name: 'adder', label: 'Adder' },
  { name: 'zentorno', label: 'Zentorno' },
  { name: 't20', label: 'T20' },
  { name: 'nero', label: 'Nero' },
  { name: 'tempesta', label: 'Tempesta' },
  { name: 'sultan', label: 'Sultan' },
  { name: 'elegy2', label: 'Elegy RH8' },
  { name: 'comet2', label: 'Comet' },
  { name: 'sanchez', label: 'Sanchez' },
  { name: 'bati', label: 'Bati 801' },
  { name: 'akuma', label: 'Akuma' },
  { name: 'buzzard', label: 'Buzzard' },
  { name: 'hydra', label: 'Hydra' },
  { name: 'lazer', label: 'P-996 Lazer' },
  { name: 'insurgent', label: 'Insurgent' },
  { name: 'kuruma', label: 'Kuruma (Armored)' },
];

export default function Vehicle({ darkMode, features }: VehicleProps) {
  const [searchVehicle, setSearchVehicle] = useState('');
  const [customVehicle, setCustomVehicle] = useState('');
  const [newPlate, setNewPlate] = useState('');

  const filteredVehicles = POPULAR_VEHICLES.filter(v => 
    v.name.toLowerCase().includes(searchVehicle.toLowerCase()) ||
    v.label.toLowerCase().includes(searchVehicle.toLowerCase())
  );

  const handleSpawnVehicle = (vehicleName: string) => {
    if (!vehicleName) return;
    fetchNui('spawnVehicle', { vehicle: vehicleName.toLowerCase() });
  };

  const handleDeleteVehicle = () => {
    fetchNui('deleteVehicle', {});
  };

  const handleRepairVehicle = () => {
    fetchNui('repairVehicle', {});
  };

  const handleRefuelVehicle = () => {
    fetchNui('refuelVehicle', {});
  };

  const handleFlipVehicle = () => {
    fetchNui('flipVehicle', {});
  };

  const handleMaxUpgrade = () => {
    fetchNui('maxUpgradeVehicle', {});
  };

  const handleChangePlate = () => {
    if (!newPlate.trim()) return;
    fetchNui('changePlate', { plate: newPlate.trim().toUpperCase() });
    setNewPlate('');
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
        {/* Vehicle Actions */}
        <div className={`${cardClass} border rounded-lg p-6 mb-6`}>
          <h2 className={`text-lg font-semibold ${textClass} mb-4`}>Current Vehicle Actions</h2>
          <div className="grid grid-cols-3 gap-3">
            {features.repairVehicle !== false && (
            <button
              onClick={handleRepairVehicle}
              className="py-3 px-4 rounded-lg bg-green-600 hover:bg-green-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Wrench size={18} />
              Repair
            </button>
            )}
            {features.setFuel !== false && (
            <button
              onClick={handleRefuelVehicle}
              className="py-3 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Fuel size={18} />
              Refuel
            </button>
            )}
            {features.flipVehicle !== false && (
            <button
              onClick={handleFlipVehicle}
              className="py-3 px-4 rounded-lg bg-yellow-600 hover:bg-yellow-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <RotateCcw size={18} />
              Flip
            </button>
            )}
            {features.maxUpgrades !== false && (
            <button
              onClick={handleMaxUpgrade}
              className="py-3 px-4 rounded-lg bg-purple-600 hover:bg-purple-700 text-white font-medium transition-colors flex items-center justify-center gap-2"
            >
              <Plus size={18} />
              Max Upgrade
            </button>
            )}
            {features.deleteVehicle !== false && (
            <button
              onClick={handleDeleteVehicle}
              className="py-3 px-4 rounded-lg bg-red-600 hover:bg-red-700 text-white font-medium transition-colors flex items-center justify-center gap-2 col-span-2"
            >
              <Trash2 size={18} />
              Delete Vehicle
            </button>
            )}
          </div>

          {/* Change Plate */}
          {features.engineToggle !== false && (
          <div className="mt-4 pt-4 border-t border-stone-700">
            <h3 className={`text-sm font-medium ${textClass} mb-2`}>Change Plate</h3>
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="Enter new plate (max 8 chars)..."
                value={newPlate}
                onChange={(e) => setNewPlate(e.target.value.slice(0, 8))}
                maxLength={8}
                className={`flex-1 px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500 uppercase`}
              />
              <button
                onClick={handleChangePlate}
                disabled={!newPlate.trim()}
                className={`px-4 py-2 rounded-lg bg-cyan-600 hover:bg-cyan-700 text-white font-medium transition-colors flex items-center gap-2 ${!newPlate.trim() ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <FileText size={18} />
                Change
              </button>
            </div>
          </div>
          )}
        </div>

        {/* Spawn Vehicle */}
        {features.spawnVehicle !== false && (
        <div className={`${cardClass} border rounded-lg p-6 mb-6`}>
          <h2 className={`text-lg font-semibold ${textClass} mb-4`}>Spawn Vehicle</h2>
          
          {/* Custom Vehicle Input */}
          <div className="flex gap-2 mb-4">
            <input
              type="text"
              placeholder="Enter vehicle spawn name..."
              value={customVehicle}
              onChange={(e) => setCustomVehicle(e.target.value)}
              className={`flex-1 px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500`}
            />
            <button
              onClick={() => { handleSpawnVehicle(customVehicle); setCustomVehicle(''); }}
              disabled={!customVehicle}
              className={`px-4 py-2 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium transition-colors flex items-center gap-2 ${!customVehicle ? 'opacity-50 cursor-not-allowed' : ''}`}
            >
              <Car size={18} />
              Spawn
            </button>
          </div>

          {/* Search */}
          <div className="relative mb-4">
            <Search className={`absolute left-3 top-1/2 -translate-y-1/2 ${secondaryText}`} size={18} />
            <input
              type="text"
              placeholder="Search popular vehicles..."
              value={searchVehicle}
              onChange={(e) => setSearchVehicle(e.target.value)}
              className={`w-full pl-10 pr-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500`}
            />
          </div>

          {/* Popular Vehicles Grid */}
          <div className="grid grid-cols-4 gap-2">
            {filteredVehicles.map((vehicle) => (
              <button
                key={vehicle.name}
                onClick={() => handleSpawnVehicle(vehicle.name)}
                className={`p-3 rounded-lg border transition-colors text-left ${cardClass} hover:border-blue-500`}
              >
                <div className="flex items-center gap-2">
                  <Car size={14} className={secondaryText} />
                  <div className="flex-1 min-w-0">
                    <p className={`font-medium text-sm ${textClass} truncate`}>{vehicle.label}</p>
                    <p className={`text-xs ${secondaryText} truncate`}>{vehicle.name}</p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
        )}
      </div>
    </div>
  );
}

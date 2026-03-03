import { useState } from 'react';
import { 
  Search, Trash2, Ban, Gift, LogOut, Snowflake, Wrench, Car, 
  Beer, VolumeX, Package, DollarSign, Heart, Users,
  UserCog, Radio, Eye, MapPin, Tag, Minus
} from 'lucide-react';
import { fetchNui } from '../../hooks/useNui';

interface Player {
  id: number;
  name: string;
  license: string;
  money: number;
  bank: number;
}

interface PlayerOptions {
  frozenPlayers: number[];
  mutedPlayers: number[];
  spectatingPlayer: number | null;
}

interface PlayerFeatures {
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
}

interface PlayersProps {
  players: Player[];
  darkMode: boolean;
  playerOptions: PlayerOptions;
  onPlayerOptionsChange: (options: PlayerOptions) => void;
  features: PlayerFeatures;
}

export default function Players({ players, darkMode, playerOptions, onPlayerOptionsChange, features }: PlayersProps) {
  const [search, setSearch] = useState('');
  const [selectedPlayer, setSelectedPlayer] = useState<number | null>(null);
  const [giveAmount, setGiveAmount] = useState('');
  const [giveType, setGiveType] = useState<'money' | 'bank'>('money');
  const [kickModal, setKickModal] = useState<number | null>(null);
  const [banModal, setBanModal] = useState<number | null>(null);
  const [giveCarModal, setGiveCarModal] = useState<number | null>(null);
  const [giveItemModal, setGiveItemModal] = useState<number | null>(null);
  const [removeMoneyModal, setRemoveMoneyModal] = useState<number | null>(null);
  const [setPedModal, setSetPedModal] = useState<number | null>(null);
  const [routingBucketModal, setRoutingBucketModal] = useState<number | null>(null);
  const [carModel, setCarModel] = useState('');
  const [carPlate, setCarPlate] = useState('');
  const [reason, setReason] = useState('');
  const [itemName, setItemName] = useState('');
  const [itemAmount, setItemAmount] = useState('1');
  const [removeAmount, setRemoveAmount] = useState('');
  const [removeType, setRemoveType] = useState<'money' | 'bank'>('money');
  const [pedModel, setPedModel] = useState('');
  const [bucketId, setBucketId] = useState('0');
  const [expandedPlayer, setExpandedPlayer] = useState<number | null>(null);

  const filtered = players.filter(p => 
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    p.id.toString().includes(search)
  );

  const handleKick = (id: number) => {
    fetchNui('kick', { playerId: id, reason: reason || 'No reason provided' });
    setKickModal(null);
    setReason('');
  };

  const handleBan = (id: number) => {
    fetchNui('ban', { playerId: id, reason: reason || 'No reason provided', duration: 0 });
    setBanModal(null);
    setReason('');
  };

  const handleGive = (id: number) => {
    if (!giveAmount || isNaN(Number(giveAmount))) return;
    fetchNui('giveMoney', { 
      playerId: id, 
      amount: Number(giveAmount),
      type: giveType 
    });
    setGiveAmount('');
    setSelectedPlayer(null);
  };

  const handleClearInventory = (id: number) => {
    fetchNui('clearInventory', { playerId: id });
  };

  const handleToggleFreeze = (id: number) => {
    const isFrozen = playerOptions.frozenPlayers.includes(id);
    const newFrozenPlayers = isFrozen
      ? playerOptions.frozenPlayers.filter(pid => pid !== id)
      : [...playerOptions.frozenPlayers, id];
    onPlayerOptionsChange({ ...playerOptions, frozenPlayers: newFrozenPlayers });
    fetchNui('freezePlayer', { playerId: id, frozen: !isFrozen });
  };

  const handleToggleMute = (id: number) => {
    const isMuted = playerOptions.mutedPlayers.includes(id);
    const newMutedPlayers = isMuted
      ? playerOptions.mutedPlayers.filter(pid => pid !== id)
      : [...playerOptions.mutedPlayers, id];
    onPlayerOptionsChange({ ...playerOptions, mutedPlayers: newMutedPlayers });
    fetchNui('mutePlayer', { playerId: id, muted: !isMuted });
  };

  const handleFixVehicle = (id: number) => {
    fetchNui('fixPlayerVehicle', { playerId: id });
  };

  const handleGiveCar = (id: number) => {
    if (!carModel.trim()) return;
    fetchNui('giveCarToPlayer', { 
      playerId: id, 
      vehicle: carModel.trim().toLowerCase(),
      plate: carPlate.trim().toUpperCase() || null 
    });
    setCarModel('');
    setCarPlate('');
    setGiveCarModal(null);
  };

  const handleGiveItem = (id: number) => {
    if (!itemName.trim() || !itemAmount) return;
    fetchNui('giveItemToPlayer', { 
      playerId: id, 
      item: itemName.trim().toLowerCase(),
      amount: parseInt(itemAmount) || 1
    });
    setItemName('');
    setItemAmount('1');
    setGiveItemModal(null);
  };

  const handleMakeDrunk = (id: number) => {
    fetchNui('makePlayerDrunk', { playerId: id });
  };

  const handleOpenInventory = (id: number) => {
    fetchNui('openPlayerInventory', { playerId: id });
  };

  const handleRemoveMoney = (id: number) => {
    if (!removeAmount || isNaN(Number(removeAmount))) return;
    fetchNui('removeMoneyPlayer', { 
      playerId: id, 
      amount: Number(removeAmount),
      type: removeType 
    });
    setRemoveAmount('');
    setRemoveMoneyModal(null);
  };

  const handleRemoveStress = (id: number) => {
    fetchNui('removeStress', { playerId: id });
  };

  const handleReviveRadius = (id: number) => {
    fetchNui('reviveRadius', { playerId: id });
  };

  const handleSetPed = (id: number) => {
    if (!pedModel.trim()) return;
    fetchNui('setPlayerPed', { playerId: id, ped: pedModel.trim().toLowerCase() });
    setPedModel('');
    setSetPedModal(null);
  };

  const handleSetRoutingBucket = (id: number) => {
    fetchNui('setRoutingBucket', { playerId: id, bucket: parseInt(bucketId) || 0 });
    setBucketId('0');
    setRoutingBucketModal(null);
  };

  const handleSpectate = (id: number) => {
    const isSpectating = playerOptions.spectatingPlayer === id;
    onPlayerOptionsChange({ ...playerOptions, spectatingPlayer: isSpectating ? null : id });
    fetchNui('spectatePlayer', { playerId: id, spectate: !isSpectating });
  };

  const handleGiveClothing = (id: number) => {
    fetchNui('giveClothingMenu', { playerId: id });
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
      {/* Search bar */}
      <div className="mb-4 relative">
        <Search className={`absolute left-3 top-1/2 -translate-y-1/2 ${secondaryText}`} size={18} />
        <input
          type="text"
          placeholder="Search players..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className={`w-full pl-10 pr-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-blue-500`}
        />
      </div>

      {/* Player list */}
      <div className="space-y-2">
        {filtered.length === 0 ? (
          <div className={`text-center py-8 ${secondaryText}`}>No players found</div>
        ) : (
          filtered.map((player) => (
            <div key={player.id} className={`${cardClass} border rounded-lg p-3 transition-colors hover:shadow-md`}>
              <div className="flex items-center justify-between">
                <div className="flex-1 min-w-0 mr-3">
                  <div className="flex items-center gap-2">
                    <h3 className={`font-semibold ${textClass} truncate`}>{player.name}</h3>
                    {playerOptions.frozenPlayers.includes(player.id) && (
                      <span className="px-1.5 py-0.5 text-xs bg-cyan-600/30 text-cyan-400 rounded">Frozen</span>
                    )}
                    {playerOptions.mutedPlayers.includes(player.id) && (
                      <span className="px-1.5 py-0.5 text-xs bg-red-600/30 text-red-400 rounded">Muted</span>
                    )}
                    {playerOptions.spectatingPlayer === player.id && (
                      <span className="px-1.5 py-0.5 text-xs bg-purple-600/30 text-purple-400 rounded">Spectating</span>
                    )}
                  </div>
                  <p className={`text-xs ${secondaryText}`}>ID: {player.id} • ${player.money.toLocaleString()} / ${player.bank.toLocaleString()}</p>
                </div>

                <div className="flex gap-1 flex-wrap justify-end">
                  {features.giveMoney !== false && (
                    <button onClick={() => setSelectedPlayer(selectedPlayer === player.id ? null : player.id)}
                      className="p-2 rounded-lg bg-blue-600/20 hover:bg-blue-600/30 text-blue-400" title="Give Money"><Gift size={14} /></button>
                  )}
                  {features.giveCar !== false && (
                    <button onClick={() => { setGiveCarModal(player.id); setCarModel(''); setCarPlate(''); }}
                      className="p-2 rounded-lg bg-green-600/20 hover:bg-green-600/30 text-green-400" title="Give Car"><Car size={14} /></button>
                  )}
                  {features.giveItem !== false && (
                    <button onClick={() => { setGiveItemModal(player.id); setItemName(''); setItemAmount('1'); }}
                      className="p-2 rounded-lg bg-teal-600/20 hover:bg-teal-600/30 text-teal-400" title="Give Item"><Package size={14} /></button>
                  )}
                  {features.freezePlayer !== false && (
                    <button onClick={() => handleToggleFreeze(player.id)}
                      className={`p-2 rounded-lg transition-colors ${playerOptions.frozenPlayers.includes(player.id) ? 'bg-cyan-600 text-white' : 'bg-cyan-600/20 hover:bg-cyan-600/30 text-cyan-400'}`}
                      title="Freeze"><Snowflake size={14} /></button>
                  )}
                  {features.mutePlayer !== false && (
                    <button onClick={() => handleToggleMute(player.id)}
                      className={`p-2 rounded-lg transition-colors ${playerOptions.mutedPlayers.includes(player.id) ? 'bg-red-600 text-white' : 'bg-red-600/20 hover:bg-red-600/30 text-red-400'}`}
                      title="Mute"><VolumeX size={14} /></button>
                  )}
                  {features.spectatePlayer !== false && (
                    <button onClick={() => handleSpectate(player.id)}
                      className={`p-2 rounded-lg transition-colors ${playerOptions.spectatingPlayer === player.id ? 'bg-purple-600 text-white' : 'bg-purple-600/20 hover:bg-purple-600/30 text-purple-400'}`}
                      title="Spectate"><Eye size={14} /></button>
                  )}
                  <button onClick={() => setExpandedPlayer(expandedPlayer === player.id ? null : player.id)}
                    className="p-2 rounded-lg bg-stone-600/20 hover:bg-stone-600/30 text-stone-400" title="More Actions">
                    <span className="text-xs font-bold">•••</span>
                  </button>
                </div>
              </div>

              {/* Expanded Actions */}
              {expandedPlayer === player.id && (
                <div className={`mt-3 pt-3 border-t ${darkMode ? 'border-stone-700' : 'border-stone-200'}`}>
                  <div className="grid grid-cols-4 gap-2 text-xs">
                    {features.makePlayerDrunk !== false && (
                      <button onClick={() => handleMakeDrunk(player.id)} className="p-2 rounded bg-amber-600/20 hover:bg-amber-600/30 text-amber-400 flex items-center gap-1 justify-center"><Beer size={12} />Drunk</button>
                    )}
                    {features.openPlayerInventory !== false && (
                      <button onClick={() => handleOpenInventory(player.id)} className="p-2 rounded bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-400 flex items-center gap-1 justify-center"><Package size={12} />Inventory</button>
                    )}
                    {features.removeMoneyPlayer !== false && (
                      <button onClick={() => { setRemoveMoneyModal(player.id); setRemoveAmount(''); }} className="p-2 rounded bg-rose-600/20 hover:bg-rose-600/30 text-rose-400 flex items-center gap-1 justify-center"><Minus size={12} />Remove $</button>
                    )}
                    {features.removeStress !== false && (
                      <button onClick={() => handleRemoveStress(player.id)} className="p-2 rounded bg-lime-600/20 hover:bg-lime-600/30 text-lime-400 flex items-center gap-1 justify-center"><Heart size={12} />Remove Stress</button>
                    )}
                    {features.reviveRadius !== false && (
                      <button onClick={() => handleReviveRadius(player.id)} className="p-2 rounded bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-400 flex items-center gap-1 justify-center"><Users size={12} />Revive Radius</button>
                    )}
                    {features.setPlayerPed !== false && (
                      <button onClick={() => { setSetPedModal(player.id); setPedModel(''); }} className="p-2 rounded bg-sky-600/20 hover:bg-sky-600/30 text-sky-400 flex items-center gap-1 justify-center"><UserCog size={12} />Set Ped</button>
                    )}
                    {features.setRoutingBucket !== false && (
                      <button onClick={() => { setRoutingBucketModal(player.id); setBucketId('0'); }} className="p-2 rounded bg-pink-600/20 hover:bg-pink-600/30 text-pink-400 flex items-center gap-1 justify-center"><Radio size={12} />Bucket</button>
                    )}
                    {features.giveClothingMenu !== false && (
                      <button onClick={() => handleGiveClothing(player.id)} className="p-2 rounded bg-orange-600/20 hover:bg-orange-600/30 text-orange-400 flex items-center gap-1 justify-center"><Tag size={12} />Clothing</button>
                    )}
                    {features.fixPlayerVehicle !== false && (
                      <button onClick={() => handleFixVehicle(player.id)} className="p-2 rounded bg-green-600/20 hover:bg-green-600/30 text-green-400 flex items-center gap-1 justify-center"><Wrench size={12} />Fix Vehicle</button>
                    )}
                    {features.clearInventory !== false && (
                      <button onClick={() => handleClearInventory(player.id)} className="p-2 rounded bg-red-600/20 hover:bg-red-600/30 text-red-400 flex items-center gap-1 justify-center"><Trash2 size={12} />Clear Inv</button>
                    )}
                  </div>
                  <div className="grid grid-cols-2 gap-2 mt-2">
                    {features.kickPlayer !== false && (
                      <button onClick={() => { setKickModal(player.id); setReason(''); }} className="p-2 rounded bg-yellow-600 hover:bg-yellow-700 text-white flex items-center gap-1 justify-center text-xs"><LogOut size={12} />Kick Player</button>
                    )}
                    {features.banPlayer !== false && (
                      <button onClick={() => { setBanModal(player.id); setReason(''); }} className="p-2 rounded bg-red-600 hover:bg-red-700 text-white flex items-center gap-1 justify-center text-xs"><Ban size={12} />Ban Player</button>
                    )}
                  </div>
                </div>
              )}

              {/* Give Money Modal (inline) */}
              {selectedPlayer === player.id && (
                <div className={`mt-3 pt-3 border-t ${darkMode ? 'border-stone-700' : 'border-stone-200'}`}>
                  <div className="grid grid-cols-3 gap-2">
                    <input type="number" placeholder="Amount" value={giveAmount} onChange={(e) => setGiveAmount(e.target.value)}
                      className={`col-span-2 px-3 py-2 rounded border ${inputClass} text-sm`} />
                    <select value={giveType} onChange={(e) => setGiveType(e.target.value as 'money' | 'bank')}
                      className={`px-3 py-2 rounded border ${inputClass} text-sm`}>
                      <option value="money">Cash</option>
                      <option value="bank">Bank</option>
                    </select>
                  </div>
                  <button onClick={() => handleGive(player.id)} className="mt-2 w-full py-2 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium text-sm">Give</button>
                </div>
              )}
            </div>
          ))
        )}
      </div>

      {/* Kick Modal */}
      {kickModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setKickModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Kick Player</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === kickModal)?.name || `ID ${kickModal}`}</p>
            <input type="text" placeholder="Reason (optional)" value={reason} onChange={(e) => setReason(e.target.value)}
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-4`} />
            <div className="flex gap-2">
              <button onClick={() => setKickModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleKick(kickModal)} className="flex-1 py-2 rounded-lg bg-yellow-600 hover:bg-yellow-700 text-white font-medium text-sm">Kick</button>
            </div>
          </div>
        </div>
      )}

      {/* Ban Modal */}
      {banModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setBanModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Ban Player</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === banModal)?.name || `ID ${banModal}`}</p>
            <input type="text" placeholder="Reason (optional)" value={reason} onChange={(e) => setReason(e.target.value)}
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-4`} />
            <div className="flex gap-2">
              <button onClick={() => setBanModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleBan(banModal)} className="flex-1 py-2 rounded-lg bg-red-600 hover:bg-red-700 text-white font-medium text-sm">Ban</button>
            </div>
          </div>
        </div>
      )}

      {/* Give Car Modal */}
      {giveCarModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setGiveCarModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Give Car to Player</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === giveCarModal)?.name}</p>
            <input type="text" placeholder="Vehicle model (e.g., adder)" value={carModel} onChange={(e) => setCarModel(e.target.value)}
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-2`} />
            <input type="text" placeholder="Custom plate (kosong = random)" value={carPlate} onChange={(e) => setCarPlate(e.target.value.slice(0, 8))}
              maxLength={8}
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-4 uppercase`} />
            <div className="flex gap-2">
              <button onClick={() => setGiveCarModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleGiveCar(giveCarModal)} disabled={!carModel.trim()} className={`flex-1 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white font-medium text-sm ${!carModel.trim() ? 'opacity-50' : ''}`}>Give Car</button>
            </div>
          </div>
        </div>
      )}

      {/* Give Item Modal */}
      {giveItemModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setGiveItemModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Give Item to Player</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === giveItemModal)?.name}</p>
            <input type="text" placeholder="Item name (e.g., lockpick)" value={itemName} onChange={(e) => setItemName(e.target.value)}
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-2`} />
            <input type="number" placeholder="Amount" value={itemAmount} onChange={(e) => setItemAmount(e.target.value)} min="1"
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-4`} />
            <div className="flex gap-2">
              <button onClick={() => setGiveItemModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleGiveItem(giveItemModal)} disabled={!itemName.trim()} className={`flex-1 py-2 rounded-lg bg-teal-600 hover:bg-teal-700 text-white font-medium text-sm ${!itemName.trim() ? 'opacity-50' : ''}`}>Give Item</button>
            </div>
          </div>
        </div>
      )}

      {/* Remove Money Modal */}
      {removeMoneyModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setRemoveMoneyModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Remove Money from Player</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === removeMoneyModal)?.name}</p>
            <div className="grid grid-cols-3 gap-2 mb-4">
              <input type="number" placeholder="Amount" value={removeAmount} onChange={(e) => setRemoveAmount(e.target.value)}
                className={`col-span-2 px-3 py-2 rounded border ${inputClass} text-sm`} />
              <select value={removeType} onChange={(e) => setRemoveType(e.target.value as 'money' | 'bank')}
                className={`px-3 py-2 rounded border ${inputClass} text-sm`}>
                <option value="money">Cash</option>
                <option value="bank">Bank</option>
              </select>
            </div>
            <div className="flex gap-2">
              <button onClick={() => setRemoveMoneyModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleRemoveMoney(removeMoneyModal)} disabled={!removeAmount} className={`flex-1 py-2 rounded-lg bg-rose-600 hover:bg-rose-700 text-white font-medium text-sm ${!removeAmount ? 'opacity-50' : ''}`}>Remove</button>
            </div>
          </div>
        </div>
      )}

      {/* Set Ped Modal */}
      {setPedModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setSetPedModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Set Player Ped</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === setPedModal)?.name}</p>
            <input type="text" placeholder="Ped model (e.g., a_m_m_farmer_01)" value={pedModel} onChange={(e) => setPedModel(e.target.value)}
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-4`} />
            <div className="flex gap-2">
              <button onClick={() => setSetPedModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleSetPed(setPedModal)} disabled={!pedModel.trim()} className={`flex-1 py-2 rounded-lg bg-sky-600 hover:bg-sky-700 text-white font-medium text-sm ${!pedModel.trim() ? 'opacity-50' : ''}`}>Set Ped</button>
            </div>
          </div>
        </div>
      )}

      {/* Routing Bucket Modal */}
      {routingBucketModal !== null && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50" onClick={() => setRoutingBucketModal(null)}>
          <div className={`${cardClass} border rounded-lg p-6 w-96 max-w-[90%]`} onClick={(e) => e.stopPropagation()}>
            <h3 className={`font-semibold ${textClass} mb-4`}>Set Routing Bucket</h3>
            <p className={`text-sm ${secondaryText} mb-4`}>Player: {filtered.find(p => p.id === routingBucketModal)?.name}</p>
            <input type="number" placeholder="Bucket ID (0 = default)" value={bucketId} onChange={(e) => setBucketId(e.target.value)} min="0"
              className={`w-full px-3 py-2 rounded border ${inputClass} text-sm mb-4`} />
            <div className="flex gap-2">
              <button onClick={() => setRoutingBucketModal(null)} className={`flex-1 py-2 rounded-lg ${darkMode ? 'bg-stone-700 hover:bg-stone-600' : 'bg-stone-200 hover:bg-stone-300'} ${textClass} font-medium text-sm`}>Cancel</button>
              <button onClick={() => handleSetRoutingBucket(routingBucketModal)} className="flex-1 py-2 rounded-lg bg-pink-600 hover:bg-pink-700 text-white font-medium text-sm">Set Bucket</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

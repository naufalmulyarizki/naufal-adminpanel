import { useState } from 'react';
import { Package, DollarSign, Users, Gift, Warehouse, Car } from 'lucide-react';
import { fetchNui } from '../../hooks/useNui';

interface ItemsFeatures {
  giveItemToSelf?: boolean;
  giveMoneyToSelf?: boolean;
  giveItemToAll?: boolean;
  giveMoneyToAll?: boolean;
  openStash?: boolean;
  openTrunk?: boolean;
}

interface ItemsProps {
  darkMode: boolean;
  features: ItemsFeatures;
}

export default function Items({ darkMode, features }: ItemsProps) {
  const [itemName, setItemName] = useState('');
  const [itemAmount, setItemAmount] = useState('1');
  const [targetPlayer, setTargetPlayer] = useState('');
  const [giveToAll, setGiveToAll] = useState(false);

  const [moneyAmount, setMoneyAmount] = useState('');
  const [moneyType, setMoneyType] = useState<'money' | 'bank'>('money');

  const [stashId, setStashId] = useState('');
  const [trunkPlate, setTrunkPlate] = useState('');

  const handleGiveItem = () => {
    if (!itemName.trim() || !itemAmount) return;
    
    if (giveToAll) {
      fetchNui('giveItemToAll', {
        item: itemName.trim().toLowerCase(),
        amount: parseInt(itemAmount) || 1
      });
    } else {
      if (!targetPlayer) return;
      fetchNui('giveItemToPlayer', {
        playerId: parseInt(targetPlayer),
        item: itemName.trim().toLowerCase(),
        amount: parseInt(itemAmount) || 1
      });
    }
    
    setItemName('');
    setItemAmount('1');
    setTargetPlayer('');
  };

  const handleGiveMoneyToAll = () => {
    if (!moneyAmount || isNaN(Number(moneyAmount))) return;
    fetchNui('giveMoneyToAll', {
      amount: Number(moneyAmount),
      type: moneyType
    });
    setMoneyAmount('');
  };

  const handleOpenStash = () => {
    if (!stashId.trim()) return;
    fetchNui('openStashById', { stashId: stashId.trim() });
    setStashId('');
  };

  const handleOpenTrunk = () => {
    if (!trunkPlate.trim()) return;
    fetchNui('openTrunkByPlate', { plate: trunkPlate.trim().toUpperCase() });
    setTrunkPlate('');
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
      <div className="max-w-2xl space-y-6">
        
        {/* Give Item Section */}
        {(features.giveItemToSelf !== false || features.giveItemToAll !== false) && (
        <div className={`${cardClass} border rounded-lg p-6`}>
          <div className="flex items-center gap-3 mb-4">
            <div className={`p-3 rounded-lg ${darkMode ? 'bg-teal-600/20' : 'bg-teal-100'}`}>
              <Package className="text-teal-500" size={24} />
            </div>
            <div>
              <h2 className={`text-lg font-semibold ${textClass}`}>Give Item</h2>
              <p className={`text-sm ${secondaryText}`}>Give items to players by name</p>
            </div>
          </div>
          
          <div className="space-y-4">
            <div>
              <label className={`text-sm font-medium ${textClass} block mb-1`}>Item Name</label>
              <input
                type="text"
                placeholder="Enter item name (e.g., lockpick, water, bread)"
                value={itemName}
                onChange={(e) => setItemName(e.target.value)}
                className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-teal-500`}
              />
            </div>
            
            <div>
              <label className={`text-sm font-medium ${textClass} block mb-1`}>Amount</label>
              <input
                type="number"
                placeholder="Quantity"
                value={itemAmount}
                onChange={(e) => setItemAmount(e.target.value)}
                min="1"
                className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-teal-500`}
              />
            </div>

            {/* Give to All Toggle */}
            <div className="flex items-center gap-3">
              <button
                onClick={() => setGiveToAll(!giveToAll)}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg border transition-colors ${
                  giveToAll
                    ? 'bg-teal-600 border-teal-600 text-white'
                    : `${cardClass} ${textClass} hover:border-teal-500`
                }`}
              >
                <Users size={18} />
                Give to All Players
              </button>
            </div>
            
            {!giveToAll && (
              <div>
                <label className={`text-sm font-medium ${textClass} block mb-1`}>Player ID</label>
                <input
                  type="number"
                  placeholder="Enter player ID"
                  value={targetPlayer}
                  onChange={(e) => setTargetPlayer(e.target.value)}
                  className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-teal-500`}
                />
              </div>
            )}
            
            <button
              onClick={handleGiveItem}
              disabled={!itemName.trim() || (!giveToAll && !targetPlayer)}
              className={`w-full py-3 rounded-lg bg-teal-600 hover:bg-teal-700 text-white font-medium transition-colors flex items-center justify-center gap-2 ${
                (!itemName.trim() || (!giveToAll && !targetPlayer)) ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              <Gift size={18} />
              {giveToAll ? 'Give Item to All Players' : 'Give Item to Player'}
            </button>
          </div>
        </div>
        )}

        {/* Give Money to All Section */}
        {features.giveMoneyToAll !== false && (
        <div className={`${cardClass} border rounded-lg p-6`}>
          <div className="flex items-center gap-3 mb-4">
            <div className={`p-3 rounded-lg ${darkMode ? 'bg-green-600/20' : 'bg-green-100'}`}>
              <DollarSign className="text-green-500" size={24} />
            </div>
            <div>
              <h2 className={`text-lg font-semibold ${textClass}`}>Give Money to All Players</h2>
              <p className={`text-sm ${secondaryText}`}>Give cash or bank money to everyone online</p>
            </div>
          </div>
          
          <div className="space-y-4">
            <div className="grid grid-cols-3 gap-3">
              <div className="col-span-2">
                <label className={`text-sm font-medium ${textClass} block mb-1`}>Amount</label>
                <input
                  type="number"
                  placeholder="Enter amount"
                  value={moneyAmount}
                  onChange={(e) => setMoneyAmount(e.target.value)}
                  className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-green-500`}
                />
              </div>
              <div>
                <label className={`text-sm font-medium ${textClass} block mb-1`}>Type</label>
                <select
                  value={moneyType}
                  onChange={(e) => setMoneyType(e.target.value as 'money' | 'bank')}
                  className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-green-500`}
                >
                  <option value="money">Cash</option>
                  <option value="bank">Bank</option>
                </select>
              </div>
            </div>
            
            <button
              onClick={handleGiveMoneyToAll}
              disabled={!moneyAmount || isNaN(Number(moneyAmount))}
              className={`w-full py-3 rounded-lg bg-green-600 hover:bg-green-700 text-white font-medium transition-colors flex items-center justify-center gap-2 ${
                (!moneyAmount || isNaN(Number(moneyAmount))) ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              <Users size={18} />
              Give Money to All Players
            </button>
          </div>
        </div>
        )}

        {/* Open Stash Section */}
        {features.openStash !== false && (
        <div className={`${cardClass} border rounded-lg p-6`}>
          <div className="flex items-center gap-3 mb-4">
            <div className={`p-3 rounded-lg ${darkMode ? 'bg-violet-600/20' : 'bg-violet-100'}`}>
              <Warehouse className="text-violet-500" size={24} />
            </div>
            <div>
              <h2 className={`text-lg font-semibold ${textClass}`}>Open Stash (ox_inventory)</h2>
              <p className={`text-sm ${secondaryText}`}>Open any stash by its ID</p>
            </div>
          </div>
          
          <div className="space-y-4">
            <div>
              <label className={`text-sm font-medium ${textClass} block mb-1`}>Stash ID</label>
              <input
                type="text"
                placeholder="Enter stash ID (e.g., police_evidence, hospital_storage)"
                value={stashId}
                onChange={(e) => setStashId(e.target.value)}
                className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-violet-500`}
              />
            </div>
            
            <button
              onClick={handleOpenStash}
              disabled={!stashId.trim()}
              className={`w-full py-3 rounded-lg bg-violet-600 hover:bg-violet-700 text-white font-medium transition-colors flex items-center justify-center gap-2 ${
                !stashId.trim() ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              <Warehouse size={18} />
              Open Stash
            </button>
          </div>
        </div>
        )}

        {/* Open Trunk Section */}
        {features.openTrunk !== false && (
        <div className={`${cardClass} border rounded-lg p-6`}>
          <div className="flex items-center gap-3 mb-4">
            <div className={`p-3 rounded-lg ${darkMode ? 'bg-fuchsia-600/20' : 'bg-fuchsia-100'}`}>
              <Car className="text-fuchsia-500" size={24} />
            </div>
            <div>
              <h2 className={`text-lg font-semibold ${textClass}`}>Open Trunk (ox_inventory)</h2>
              <p className={`text-sm ${secondaryText}`}>Open vehicle trunk by plate number</p>
            </div>
          </div>
          
          <div className="space-y-4">
            <div>
              <label className={`text-sm font-medium ${textClass} block mb-1`}>Vehicle Plate</label>
              <input
                type="text"
                placeholder="Enter vehicle plate (e.g., ABC123)"
                value={trunkPlate}
                onChange={(e) => setTrunkPlate(e.target.value.toUpperCase())}
                maxLength={8}
                className={`w-full px-4 py-2 rounded-lg border ${inputClass} focus:outline-none focus:ring-2 focus:ring-fuchsia-500 uppercase`}
              />
            </div>
            
            <button
              onClick={handleOpenTrunk}
              disabled={!trunkPlate.trim()}
              className={`w-full py-3 rounded-lg bg-fuchsia-600 hover:bg-fuchsia-700 text-white font-medium transition-colors flex items-center justify-center gap-2 ${
                !trunkPlate.trim() ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              <Car size={18} />
              Open Trunk
            </button>
          </div>
        </div>
        )}
      </div>
    </div>
  );
}

import { ArrowLeft, MessageCircle, Plus } from 'lucide-react';
import { useNavigate } from 'react-router';
import { useState } from 'react';

export function PrincipalSMSWallet() {
  const navigate = useNavigate();
  const [balance] = useState(423);
  const [topUpAmount, setTopUpAmount] = useState('');

  const messagesRemaining = Math.floor(balance * 2);

  let balanceColor = 'text-[#10B981]';
  let balanceBg = 'bg-[#D1FAE5]';
  if (balance < 100 && balance >= 20) {
    balanceColor = 'text-[#F59E0B]';
    balanceBg = 'bg-[#FEF3C7]';
  } else if (balance < 20) {
    balanceColor = 'text-[#DC2626]';
    balanceBg = 'bg-[#FEE2E2]';
  }

  const dailyUsage = [
    { day: 'Mon', emergency: 2, routine: 15, reminder: 8 },
    { day: 'Tue', emergency: 0, routine: 22, reminder: 12 },
    { day: 'Wed', emergency: 1, routine: 18, reminder: 10 },
    { day: 'Thu', emergency: 0, routine: 24, reminder: 14 },
    { day: 'Fri', emergency: 3, routine: 20, reminder: 11 },
    { day: 'Sat', emergency: 0, routine: 5, reminder: 2 },
    { day: 'Sun', emergency: 0, routine: 3, reminder: 1 }
  ];

  const maxTotal = Math.max(...dailyUsage.map(d => d.emergency + d.routine + d.reminder));

  const transactions = [
    { id: '1', date: '2026-05-30', type: 'Emergency alerts', count: 12, cost: '$6.00', balanceAfter: '$423.00' },
    { id: '2', date: '2026-05-29', type: 'Routine messages', count: 85, cost: '$42.50', balanceAfter: '$429.00' },
    { id: '3', date: '2026-05-28', type: 'Top-up', count: 0, cost: '-$100.00', balanceAfter: '$471.50' },
    { id: '4', date: '2026-05-27', type: 'Reminders', count: 43, cost: '$21.50', balanceAfter: '$371.50' }
  ];

  const handleTopUp = () => {
    if (topUpAmount) {
      alert(`Processing payment of $${topUpAmount}...`);
      setTopUpAmount('');
    }
  };

  return (
    <div className="min-h-screen bg-[#F8FAFC] flex flex-col" style={{ width: '393px', height: '852px' }}>
      {/* Status Bar */}
      <div className="h-[44px] bg-white" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200 px-4 py-3 flex items-center gap-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors min-w-[44px] min-h-[44px] flex items-center justify-center"
          aria-label="Go back"
        >
          <ArrowLeft className="w-5 h-5 text-[#0F172A]" />
        </button>
        <h1 className="text-[17px] font-medium text-[#0F172A]">
          SMS Wallet
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {/* Balance Card */}
        <div className={`rounded-xl border p-6 ${balanceBg}`}>
          <div className="flex items-center gap-2 mb-2">
            <MessageCircle className={`w-5 h-5 ${balanceColor}`} />
            <span className="text-[13px] font-medium text-[#64748B]">Current Balance</span>
          </div>
          <div className={`text-[36px] font-bold ${balanceColor} mb-1`}>
            ${balance.toFixed(2)}
          </div>
          <div className="text-[13px] text-[#64748B]">
            ≈ {messagesRemaining} messages remaining
          </div>
        </div>

        {/* Usage Chart */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Last 7 Days Usage
          </h2>
          <div className="space-y-2">
            {dailyUsage.map((day) => {
              const total = day.emergency + day.routine + day.reminder;
              const emergencyHeight = (day.emergency / maxTotal) * 100;
              const routineHeight = (day.routine / maxTotal) * 100;
              const reminderHeight = (day.reminder / maxTotal) * 100;

              return (
                <div key={day.day} className="flex items-end gap-2">
                  <div className="w-10 text-[10px] text-[#64748B] flex-shrink-0">
                    {day.day}
                  </div>
                  <div className="flex-1 flex items-end gap-0.5 h-12">
                    {day.emergency > 0 && (
                      <div
                        className="bg-[#DC2626] rounded-t"
                        style={{ width: '33.33%', height: `${emergencyHeight}%` }}
                        title={`Emergency: ${day.emergency}`}
                      />
                    )}
                    {day.routine > 0 && (
                      <div
                        className="bg-[#2563EB] rounded-t"
                        style={{ width: '33.33%', height: `${routineHeight}%` }}
                        title={`Routine: ${day.routine}`}
                      />
                    )}
                    {day.reminder > 0 && (
                      <div
                        className="bg-[#F59E0B] rounded-t"
                        style={{ width: '33.33%', height: `${reminderHeight}%` }}
                        title={`Reminder: ${day.reminder}`}
                      />
                    )}
                  </div>
                  <div className="w-8 text-[11px] text-[#0F172A] font-medium text-right flex-shrink-0">
                    {total}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="mt-3 flex items-center gap-3 text-[10px]">
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-[#DC2626] rounded" />
              <span className="text-[#64748B]">Emergency</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-[#2563EB] rounded" />
              <span className="text-[#64748B]">Routine</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="w-3 h-3 bg-[#F59E0B] rounded" />
              <span className="text-[#64748B]">Reminder</span>
            </div>
          </div>
        </div>

        {/* Top-Up Section */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Add Funds
          </h2>
          <div className="flex gap-2">
            <div className="flex-1">
              <input
                type="number"
                value={topUpAmount}
                onChange={(e) => setTopUpAmount(e.target.value)}
                placeholder="Enter amount"
                className="w-full h-[44px] px-4 bg-white border border-gray-300 rounded-lg text-[15px] text-[#0F172A] placeholder:text-[#94A3B8] focus:outline-none focus:ring-2 focus:ring-[#2563EB] focus:border-transparent"
              />
            </div>
            <button
              onClick={handleTopUp}
              disabled={!topUpAmount}
              className={`h-[44px] px-6 rounded-lg font-medium text-[14px] transition-colors ${
                topUpAmount
                  ? 'bg-[#2563EB] text-white active:bg-[#1D4ED8]'
                  : 'bg-gray-200 text-gray-400 cursor-not-allowed'
              }`}
            >
              Add funds
            </button>
          </div>
          <div className="mt-2 flex gap-2">
            {[25, 50, 100, 200].map((amount) => (
              <button
                key={amount}
                onClick={() => setTopUpAmount(amount.toString())}
                className="flex-1 h-[36px] bg-[#F1F5F9] text-[#0F172A] rounded-lg text-[13px] font-medium active:bg-[#E2E8F0]"
              >
                ${amount}
              </button>
            ))}
          </div>
        </div>

        {/* Transaction History */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <h2 className="text-[14px] font-semibold text-[#0F172A] mb-3">
            Transaction History
          </h2>
          <div className="space-y-3">
            {transactions.map((tx) => (
              <div key={tx.id} className="flex items-start justify-between py-2 border-b border-gray-100 last:border-0">
                <div className="flex-1">
                  <div className="text-[13px] font-medium text-[#0F172A] mb-0.5">
                    {tx.type}
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    {tx.date} {tx.count > 0 && `• ${tx.count} messages`}
                  </div>
                </div>
                <div className="text-right">
                  <div className={`text-[13px] font-medium ${tx.cost.startsWith('-') ? 'text-[#10B981]' : 'text-[#0F172A]'}`}>
                    {tx.cost}
                  </div>
                  <div className="text-[11px] text-[#64748B]">
                    Bal: {tx.balanceAfter}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

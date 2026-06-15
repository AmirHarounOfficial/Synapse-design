import { ArrowUp, ArrowDown } from 'lucide-react';

interface RouteEvent {
  id: string;
  time: string;
  studentName: string;
  stopNumber: number;
  type: 'boarding' | 'deboarding';
}

export function BusRouteHistory() {
  const todaysDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  const routeEvents: RouteEvent[] = [
    {
      id: '1',
      time: '3:42 PM',
      studentName: 'Emma Rodriguez',
      stopNumber: 1,
      type: 'deboarding'
    },
    {
      id: '2',
      time: '3:40 PM',
      studentName: 'Liam Thompson',
      stopNumber: 1,
      type: 'deboarding'
    },
    {
      id: '3',
      time: '3:35 PM',
      studentName: 'Ava Johnson',
      stopNumber: 2,
      type: 'deboarding'
    },
    {
      id: '4',
      time: '7:55 AM',
      studentName: 'Ethan Davis',
      stopNumber: 6,
      type: 'boarding'
    },
    {
      id: '5',
      time: '7:52 AM',
      studentName: 'Olivia Martinez',
      stopNumber: 5,
      type: 'boarding'
    },
    {
      id: '6',
      time: '7:52 AM',
      studentName: 'Noah Williams',
      stopNumber: 5,
      type: 'boarding'
    },
    {
      id: '7',
      time: '7:48 AM',
      studentName: 'Ava Johnson',
      stopNumber: 2,
      type: 'boarding'
    },
    {
      id: '8',
      time: '7:45 AM',
      studentName: 'Liam Thompson',
      stopNumber: 1,
      type: 'boarding'
    },
    {
      id: '9',
      time: '7:45 AM',
      studentName: 'Emma Rodriguez',
      stopNumber: 1,
      type: 'boarding'
    }
  ];

  const morningEvents = routeEvents.filter(e => e.time.includes('AM'));
  const afternoonEvents = routeEvents.filter(e => e.time.includes('PM'));

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[83px]">
      {/* Status Bar */}
      <div className="h-[44px] bg-[#FFFFFF]" />

      {/* Top App Bar */}
      <header className="bg-white border-b border-gray-200">
        <div className="px-4 py-3">
          <h1 className="text-[17px] font-medium text-gray-900">
            Route History
          </h1>
          <p className="text-[13px] text-[#64748B]">
            {todaysDate}
          </p>
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Summary Stats */}
        <div className="bg-white rounded-xl border border-gray-200 p-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center">
              <div className="text-[28px] font-bold text-gray-900">
                {morningEvents.length}
              </div>
              <div className="text-[12px] text-[#64748B]">
                Morning Pickups
              </div>
            </div>
            <div className="text-center border-l border-gray-200">
              <div className="text-[28px] font-bold text-gray-900">
                {afternoonEvents.length}
              </div>
              <div className="text-[12px] text-[#64748B]">
                Afternoon Drop-offs
              </div>
            </div>
          </div>
        </div>

        {/* Afternoon Events */}
        {afternoonEvents.length > 0 && (
          <div>
            <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
              AFTERNOON ROUTE ({afternoonEvents.length})
            </h2>

            <div className="space-y-2">
              {afternoonEvents.map((event) => (
                <div
                  key={event.id}
                  className="bg-white rounded-xl border border-gray-200 p-4"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3 flex-1">
                      <div className="w-10 h-10 rounded-full bg-[#F0FDF4] flex items-center justify-center flex-shrink-0">
                        <ArrowDown className="w-5 h-5 text-[#10B981]" />
                      </div>
                      <div className="flex-1">
                        <div className="text-[16px] font-medium text-gray-900 mb-1">
                          {event.studentName}
                        </div>
                        <div className="text-[13px] text-[#64748B]">
                          Stop {event.stopNumber} — Drop-off
                        </div>
                        <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-[#F0FDF4] text-[#065F46] text-[11px] font-semibold mt-2">
                          Parent notified
                        </div>
                      </div>
                    </div>
                    <div className="text-[15px] font-semibold text-gray-900">
                      {event.time}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Morning Events */}
        {morningEvents.length > 0 && (
          <div>
            <h2 className="text-[13px] font-medium text-[#64748B] uppercase tracking-wide mb-3">
              MORNING ROUTE ({morningEvents.length})
            </h2>

            <div className="space-y-2">
              {morningEvents.map((event) => (
                <div
                  key={event.id}
                  className="bg-white rounded-xl border border-gray-200 p-4"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-3 flex-1">
                      <div className="w-10 h-10 rounded-full bg-[#EFF6FF] flex items-center justify-center flex-shrink-0">
                        <ArrowUp className="w-5 h-5 text-[#2563EB]" />
                      </div>
                      <div className="flex-1">
                        <div className="text-[16px] font-medium text-gray-900 mb-1">
                          {event.studentName}
                        </div>
                        <div className="text-[13px] text-[#64748B]">
                          Stop {event.stopNumber} — Boarding
                        </div>
                        <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-[#EFF6FF] text-[#1E40AF] text-[11px] font-semibold mt-2">
                          Parent notified
                        </div>
                      </div>
                    </div>
                    <div className="text-[15px] font-semibold text-gray-900">
                      {event.time}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Info Notice */}
        <div className="bg-[#F8FAFC] border border-gray-200 rounded-xl p-4">
          <p className="text-[12px] text-[#64748B] leading-relaxed text-center">
            All boarding and drop-off events are logged with automatic parent notifications. Historical records available in the driver portal.
          </p>
        </div>
      </div>
    </div>
  );
}

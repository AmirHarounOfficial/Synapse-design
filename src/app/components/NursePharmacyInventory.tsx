import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import {
  ArrowLeft,
  Search,
  Plus,
  Package,
  AlertTriangle,
  Clock,
  History,
  Edit2,
  Trash2,
  SlidersHorizontal,
  X,
  Check,
  ShieldAlert,
  ArrowUpRight,
  ArrowDownRight,
  UserCheck,
  Info,
  Calendar,
  MapPin,
  Building2,
  Layers,
  Filter
} from 'lucide-react';

export interface PharmacyItem {
  id: number;
  name: string;
  name_ar?: string;
  category: string;
  dosage_form: string;
  stock_quantity: number;
  min_threshold: number;
  unit: string;
  location: string;
  expiry_date: string;
  supplier: string;
  status: 'active' | 'low_stock' | 'expired' | 'out_of_stock';
  notes?: string;
}

export interface InventoryLog {
  id: number;
  item_name: string;
  performed_by_name: string;
  performed_by_role: string;
  action: 'created' | 'updated' | 'stock_adjusted' | 'deleted';
  quantity_change?: number | null;
  new_quantity?: number | null;
  reason?: string | null;
  created_at: string;
}

const INITIAL_ITEMS: PharmacyItem[] = [
  {
    id: 1,
    name: 'Paracetamol 500mg Tablets',
    name_ar: 'باراسيتامول 500 ملغ أقراص',
    category: 'Analgesic',
    dosage_form: '500mg Tablet',
    stock_quantity: 120,
    min_threshold: 30,
    unit: 'tablets',
    location: 'Cabinet A-1',
    expiry_date: '2027-11-15',
    supplier: 'Julphar Pharmaceuticals',
    status: 'active',
    notes: 'General fever & pain relief stock for student clinic.'
  },
  {
    id: 2,
    name: 'Amoxicillin 250mg Oral Suspension',
    name_ar: 'أمكسيسيلين 250 ملغ معلق مفصلي',
    category: 'Antibiotic',
    dosage_form: '250mg/5ml Liquid',
    stock_quantity: 12,
    min_threshold: 15,
    unit: 'bottles',
    location: 'Fridge 1',
    expiry_date: '2027-06-30',
    supplier: 'Gulf Pharmaceutical Industries',
    status: 'low_stock',
    notes: 'Keep refrigerated at 2-8°C. Prescribed dosage requirement.'
  },
  {
    id: 3,
    name: 'Ventolin Inhaler 100mcg',
    name_ar: 'بخاخ فنتولين 100 مكغ',
    category: 'Respiratory',
    dosage_form: '100mcg Inhaler',
    stock_quantity: 25,
    min_threshold: 10,
    unit: 'inhalers',
    location: 'Cabinet B-2',
    expiry_date: '2028-03-20',
    supplier: 'GlaxoSmithKline UAE',
    status: 'active',
    notes: 'Emergency and scheduled asthma rescue inhalers.'
  },
  {
    id: 4,
    name: 'EpiPen Auto-Injector 0.3mg',
    name_ar: 'حقنة إبي بين التلقائية 0.3 ملغ',
    category: 'Emergency',
    dosage_form: '0.3mg Auto-Injector',
    stock_quantity: 4,
    min_threshold: 5,
    unit: 'units',
    location: 'Emergency Crash Cart',
    expiry_date: '2027-09-10',
    supplier: 'Viatris Dubai',
    status: 'low_stock',
    notes: 'Severe anaphylactic reaction immediate response kit.'
  },
  {
    id: 5,
    name: 'Sterile Saline Solution 0.9%',
    name_ar: 'محلول ملحي معقم 0.9%',
    category: 'First Aid',
    dosage_form: '100ml Bottle',
    stock_quantity: 45,
    min_threshold: 10,
    unit: 'bottles',
    location: 'Shelf C-3',
    expiry_date: '2028-01-01',
    supplier: 'Global Medical Supplies',
    status: 'active',
    notes: 'Eye wash and wound irrigation.'
  },
  {
    id: 6,
    name: 'Cetirizine 10mg Tablets',
    name_ar: 'سيتريزين 10 ملغ أقراص',
    category: 'Antihistamine',
    dosage_form: '10mg Tablet',
    stock_quantity: 0,
    min_threshold: 20,
    unit: 'tablets',
    location: 'Cabinet A-2',
    expiry_date: '2027-05-10',
    supplier: 'Julphar Pharmaceuticals',
    status: 'out_of_stock',
    notes: 'Out of stock! Urgent reorder needed.'
  }
];

const INITIAL_LOGS: InventoryLog[] = [
  {
    id: 101,
    item_name: 'Amoxicillin 250mg Oral Suspension',
    performed_by_name: 'Aisha Rahman (Nurse)',
    performed_by_role: 'nurse',
    action: 'stock_adjusted',
    quantity_change: -3,
    new_quantity: 12,
    reason: 'Dispensed for student prescription order #1082',
    created_at: '2026-08-18 14:30'
  },
  {
    id: 102,
    item_name: 'Paracetamol 500mg Tablets',
    performed_by_name: 'Aisha Rahman (Nurse)',
    performed_by_role: 'nurse',
    action: 'stock_adjusted',
    quantity_change: 50,
    new_quantity: 120,
    reason: 'Received monthly inventory shipment from Julphar',
    created_at: '2026-08-18 09:15'
  },
  {
    id: 103,
    item_name: 'EpiPen Auto-Injector 0.3mg',
    performed_by_name: 'Sarah Johnson (Nurse)',
    performed_by_role: 'nurse',
    action: 'updated',
    quantity_change: null,
    new_quantity: 4,
    reason: 'Updated minimum threshold count to 5 units',
    created_at: '2026-08-17 16:45'
  },
  {
    id: 104,
    item_name: 'Cetirizine 10mg Tablets',
    performed_by_name: 'Aisha Rahman (Nurse)',
    performed_by_role: 'nurse',
    action: 'stock_adjusted',
    quantity_change: -20,
    new_quantity: 0,
    reason: 'Stock depleted due to high seasonal allergy demand',
    created_at: '2026-08-17 11:20'
  }
];

export function NursePharmacyInventory() {
  const navigate = useNavigate();
  
  // Current user role simulation (Nurse role granted)
  const currentRole = 'nurse';
  const nurseName = 'Aisha Rahman (Nurse)';

  const [items, setItems] = useState<PharmacyItem[]>(INITIAL_ITEMS);
  const [logs, setLogs] = useState<InventoryLog[]>(INITIAL_LOGS);
  
  const [activeTab, setActiveTab] = useState<'all' | 'low_stock' | 'expiring' | 'out_of_stock' | 'audit_log'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');

  // Modals state
  const [isAddEditOpen, setIsAddEditOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<PharmacyItem | null>(null);

  const [isAdjustOpen, setIsAdjustOpen] = useState(false);
  const [adjustItem, setAdjustItem] = useState<PharmacyItem | null>(null);
  const [adjustQty, setAdjustQty] = useState<number>(0);
  const [adjustReason, setAdjustReason] = useState<string>('');

  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [deletingItem, setDeletingItem] = useState<PharmacyItem | null>(null);

  // Form inputs state
  const [formData, setFormData] = useState({
    name: '',
    name_ar: '',
    category: 'Analgesic',
    dosage_form: '',
    stock_quantity: 0,
    min_threshold: 10,
    unit: 'tablets',
    location: '',
    expiry_date: '',
    supplier: '',
    notes: ''
  });

  // Calculate statistics
  const totalItemsCount = items.length;
  const lowStockCount = items.filter(i => i.stock_quantity <= i.min_threshold && i.stock_quantity > 0).length;
  const outOfStockCount = items.filter(i => i.stock_quantity === 0).length;
  const totalUnitsCount = items.reduce((acc, curr) => acc + curr.stock_quantity, 0);

  // Helper to open Add modal
  const handleOpenAdd = () => {
    setEditingItem(null);
    setFormData({
      name: '',
      name_ar: '',
      category: 'Analgesic',
      dosage_form: '',
      stock_quantity: 20,
      min_threshold: 10,
      unit: 'tablets',
      location: 'Cabinet A-1',
      expiry_date: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      supplier: 'Julphar Pharmaceuticals',
      notes: ''
    });
    setIsAddEditOpen(true);
  };

  // Helper to open Edit modal
  const handleOpenEdit = (item: PharmacyItem) => {
    setEditingItem(item);
    setFormData({
      name: item.name,
      name_ar: item.name_ar || '',
      category: item.category,
      dosage_form: item.dosage_form,
      stock_quantity: item.stock_quantity,
      min_threshold: item.min_threshold,
      unit: item.unit,
      location: item.location,
      expiry_date: item.expiry_date,
      supplier: item.supplier,
      notes: item.notes || ''
    });
    setIsAddEditOpen(true);
  };

  // Helper to save Add / Edit
  const handleSaveItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) return;

    let computedStatus: PharmacyItem['status'] = 'active';
    if (formData.stock_quantity === 0) {
      computedStatus = 'out_of_stock';
    } else if (formData.stock_quantity <= formData.min_threshold) {
      computedStatus = 'low_stock';
    }

    const nowStr = new Date().toISOString().replace('T', ' ').substring(0, 16);

    if (editingItem) {
      // Update item
      const updatedList = items.map(i => {
        if (i.id === editingItem.id) {
          return {
            ...i,
            ...formData,
            status: computedStatus
          };
        }
        return i;
      });
      setItems(updatedList);

      // Record Audit Log
      const newLog: InventoryLog = {
        id: Date.now(),
        item_name: formData.name,
        performed_by_name: nurseName,
        performed_by_role: 'nurse',
        action: 'updated',
        quantity_change: formData.stock_quantity - editingItem.stock_quantity,
        new_quantity: formData.stock_quantity,
        reason: 'Updated item specifications and inventory details',
        created_at: nowStr
      };
      setLogs([newLog, ...logs]);
    } else {
      // Create new item
      const newItem: PharmacyItem = {
        id: Date.now(),
        ...formData,
        status: computedStatus
      };
      setItems([newItem, ...items]);

      // Record Audit Log
      const newLog: InventoryLog = {
        id: Date.now(),
        item_name: formData.name,
        performed_by_name: nurseName,
        performed_by_role: 'nurse',
        action: 'created',
        quantity_change: formData.stock_quantity,
        new_quantity: formData.stock_quantity,
        reason: 'Added new medication item to pharmacy inventory',
        created_at: nowStr
      };
      setLogs([newLog, ...logs]);
    }

    setIsAddEditOpen(false);
  };

  // Helper for Adjust Stock
  const handleOpenAdjust = (item: PharmacyItem) => {
    setAdjustItem(item);
    setAdjustQty(0);
    setAdjustReason('Routine stock intake');
    setIsAdjustOpen(true);
  };

  const handleSaveAdjust = (e: React.FormEvent) => {
    e.preventDefault();
    if (!adjustItem || adjustQty === 0) return;

    const newStock = Math.max(0, adjustItem.stock_quantity + adjustQty);
    let computedStatus: PharmacyItem['status'] = 'active';
    if (newStock === 0) {
      computedStatus = 'out_of_stock';
    } else if (newStock <= adjustItem.min_threshold) {
      computedStatus = 'low_stock';
    }

    const updatedList = items.map(i => {
      if (i.id === adjustItem.id) {
        return {
          ...i,
          stock_quantity: newStock,
          status: computedStatus
        };
      }
      return i;
    });
    setItems(updatedList);

    const nowStr = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const newLog: InventoryLog = {
      id: Date.now(),
      item_name: adjustItem.name,
      performed_by_name: nurseName,
      performed_by_role: 'nurse',
      action: 'stock_adjusted',
      quantity_change: adjustQty,
      new_quantity: newStock,
      reason: adjustReason || (adjustQty > 0 ? 'Stock intake / refill' : 'Dispensed / wasted'),
      created_at: nowStr
    };
    setLogs([newLog, ...logs]);

    setIsAdjustOpen(false);
  };

  // Helper for Delete Item
  const handleOpenDelete = (item: PharmacyItem) => {
    setDeletingItem(item);
    setIsDeleteOpen(true);
  };

  const handleConfirmDelete = () => {
    if (!deletingItem) return;

    setItems(items.filter(i => i.id !== deletingItem.id));

    const nowStr = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const newLog: InventoryLog = {
      id: Date.now(),
      item_name: deletingItem.name,
      performed_by_name: nurseName,
      performed_by_role: 'nurse',
      action: 'deleted',
      quantity_change: -deletingItem.stock_quantity,
      new_quantity: 0,
      reason: 'Item deleted from pharmacy catalog',
      created_at: nowStr
    };
    setLogs([newLog, ...logs]);

    setIsDeleteOpen(false);
  };

  // Filter items
  const filteredItems = items.filter(item => {
    const matchesSearch =
      item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (item.name_ar && item.name_ar.includes(searchQuery)) ||
      item.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.location.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory = categoryFilter === 'all' || item.category === categoryFilter;

    if (!matchesSearch || !matchesCategory) return false;

    if (activeTab === 'low_stock') {
      return item.stock_quantity <= item.min_threshold && item.stock_quantity > 0;
    }
    if (activeTab === 'out_of_stock') {
      return item.stock_quantity === 0;
    }
    if (activeTab === 'expiring') {
      // expiring within 365 days or past
      return true;
    }
    return true;
  });

  const categories = Array.from(new Set(items.map(i => i.category)));

  // If role is NOT nurse
  if (currentRole !== 'nurse') {
    return (
      <div className="min-h-screen bg-[#F8FAFC] flex flex-col items-center justify-center p-6 text-center">
        <div className="w-16 h-16 rounded-full bg-[#FEE2E2] flex items-center justify-center mb-4">
          <ShieldAlert className="w-8 h-8 text-[#DC2626]" />
        </div>
        <h2 className="text-xl font-bold text-gray-900 mb-2">Access Restricted</h2>
        <p className="text-gray-600 text-sm max-w-sm mb-6">
          The Pharmacy Inventory management module can only be accessed by authorized School Nurse personnel.
        </p>
        <button
          onClick={() => navigate('/nurse/medications')}
          className="px-5 py-2.5 bg-[#2563EB] text-white rounded-lg text-sm font-semibold"
        >
          Return to Medications
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFC] pb-[90px]">
      {/* Top Header */}
      <div className="bg-white border-b border-[#E2E8F0] sticky top-0 z-20 shadow-sm">
        <div className="h-[44px] bg-[#FFFFFF]" />
        <div className="px-4 py-3 flex items-center justify-between gap-3">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate('/nurse/medications')}
              className="p-2 min-w-[40px] min-h-[40px] rounded-lg hover:bg-gray-100 flex items-center justify-center text-[#64748B]"
              aria-label="Back to medications"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
            <div>
              <div className="flex items-center gap-2">
                <Package className="w-5 h-5 text-[#2563EB]" />
                <h1 className="text-lg font-bold text-[#0F172A]">Pharmacy Inventory</h1>
              </div>
              <p className="text-[12px] text-[#64748B]">Manage clinic medication stock & recorded audit logs</p>
            </div>
          </div>

          <button
            onClick={handleOpenAdd}
            className="px-3.5 py-2 bg-[#2563EB] hover:bg-[#1D4ED8] text-white rounded-lg text-[13px] font-semibold flex items-center gap-1.5 shadow-sm transition-all min-h-[40px]"
          >
            <Plus className="w-4 h-4" />
            <span>Add Item</span>
          </button>
        </div>

        {/* Audit Log Recorded Badge Banner */}
        <div className="bg-[#EFF6FF] px-4 py-1.5 border-t border-[#DBEAFE] flex items-center justify-between text-[12px] text-[#1E40AF]">
          <div className="flex items-center gap-1.5">
            <UserCheck className="w-4 h-4 text-[#2563EB]" />
            <span>
              Active Session: <strong className="font-semibold">{nurseName}</strong>
            </span>
          </div>
          <span className="text-[11px] bg-[#DBEAFE] text-[#1E40AF] px-2 py-0.5 rounded-full font-medium">
            All Actions Recorded
          </span>
        </div>
      </div>

      {/* Main Body Container */}
      <div className="px-4 py-4 space-y-4 max-w-4xl mx-auto">
        {/* KPI Stats Header */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <div className="bg-white rounded-xl p-3 border border-[#E2E8F0] shadow-sm">
            <div className="flex items-center justify-between text-[#64748B] mb-1">
              <span className="text-[12px] font-medium">Total Items</span>
              <Package className="w-4 h-4 text-[#2563EB]" />
            </div>
            <p className="text-2xl font-bold text-[#0F172A]">{totalItemsCount}</p>
            <span className="text-[11px] text-[#64748B]">{totalUnitsCount} total units</span>
          </div>

          <div className="bg-white rounded-xl p-3 border border-[#E2E8F0] shadow-sm">
            <div className="flex items-center justify-between text-[#64748B] mb-1">
              <span className="text-[12px] font-medium">Low Stock</span>
              <AlertTriangle className="w-4 h-4 text-[#D97706]" />
            </div>
            <p className="text-2xl font-bold text-[#D97706]">{lowStockCount}</p>
            <span className="text-[11px] text-[#D97706] font-medium">Needs reorder</span>
          </div>

          <div className="bg-white rounded-xl p-3 border border-[#E2E8F0] shadow-sm">
            <div className="flex items-center justify-between text-[#64748B] mb-1">
              <span className="text-[12px] font-medium">Out of Stock</span>
              <ShieldAlert className="w-4 h-4 text-[#DC2626]" />
            </div>
            <p className="text-2xl font-bold text-[#DC2626]">{outOfStockCount}</p>
            <span className="text-[11px] text-[#DC2626] font-medium">Depleted stock</span>
          </div>

          <div
            onClick={() => setActiveTab('audit_log')}
            className="bg-white rounded-xl p-3 border border-[#E2E8F0] shadow-sm cursor-pointer hover:border-[#2563EB] transition-colors"
          >
            <div className="flex items-center justify-between text-[#64748B] mb-1">
              <span className="text-[12px] font-medium">Action Logs</span>
              <History className="w-4 h-4 text-[#7C3AED]" />
            </div>
            <p className="text-2xl font-bold text-[#7C3AED]">{logs.length}</p>
            <span className="text-[11px] text-[#7C3AED] font-medium">View audit history</span>
          </div>
        </div>

        {/* Tab Selection */}
        <div className="bg-white p-1.5 rounded-xl border border-[#E2E8F0] flex gap-1 overflow-x-auto scrollbar-hide">
          <button
            onClick={() => setActiveTab('all')}
            className={`flex-1 min-w-[90px] py-2 px-3 rounded-lg text-[13px] font-semibold transition-all whitespace-nowrap text-center ${
              activeTab === 'all' ? 'bg-[#2563EB] text-white shadow-sm' : 'text-[#64748B] hover:text-[#0F172A]'
            }`}
          >
            All Stock ({items.length})
          </button>
          <button
            onClick={() => setActiveTab('low_stock')}
            className={`flex-1 min-w-[90px] py-2 px-3 rounded-lg text-[13px] font-semibold transition-all whitespace-nowrap text-center ${
              activeTab === 'low_stock' ? 'bg-[#D97706] text-white shadow-sm' : 'text-[#64748B] hover:text-[#0F172A]'
            }`}
          >
            Low Stock ({lowStockCount})
          </button>
          <button
            onClick={() => setActiveTab('out_of_stock')}
            className={`flex-1 min-w-[90px] py-2 px-3 rounded-lg text-[13px] font-semibold transition-all whitespace-nowrap text-center ${
              activeTab === 'out_of_stock' ? 'bg-[#DC2626] text-white shadow-sm' : 'text-[#64748B] hover:text-[#0F172A]'
            }`}
          >
            Out of Stock ({outOfStockCount})
          </button>
          <button
            onClick={() => setActiveTab('audit_log')}
            className={`flex-1 min-w-[110px] py-2 px-3 rounded-lg text-[13px] font-semibold transition-all whitespace-nowrap text-center flex items-center justify-center gap-1.5 ${
              activeTab === 'audit_log' ? 'bg-[#7C3AED] text-white shadow-sm' : 'text-[#7C3AED] bg-[#F5F3FF]'
            }`}
          >
            <History className="w-3.5 h-3.5" />
            <span>Audit Trail ({logs.length})</span>
          </button>
        </div>

        {/* Filter Controls (Shown for inventory list tabs) */}
        {activeTab !== 'audit_log' && (
          <div className="flex flex-col sm:flex-row gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#64748B]" />
              <input
                type="text"
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
                placeholder="Search medication name, category or cabinet location..."
                className="w-full h-[42px] pl-9 pr-4 rounded-lg border border-[#E2E8F0] bg-white text-[13px] text-[#0F172A] outline-none focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]/20"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>

            <div className="relative min-w-[160px]">
              <select
                value={categoryFilter}
                onChange={e => setCategoryFilter(e.target.value)}
                className="w-full h-[42px] px-3 pr-8 rounded-lg border border-[#E2E8F0] bg-white text-[13px] text-[#0F172A] appearance-none outline-none focus:border-[#2563EB]"
              >
                <option value="all">All Categories</option>
                {categories.map(cat => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
              <Filter className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
            </div>
          </div>
        )}

        {/* ================= INVENTORY ITEMS TAB ================= */}
        {activeTab !== 'audit_log' && (
          <div className="space-y-3">
            {filteredItems.length === 0 ? (
              <div className="bg-white rounded-xl p-8 text-center border border-[#E2E8F0]">
                <Package className="w-12 h-12 text-gray-300 mx-auto mb-3" />
                <h3 className="text-base font-semibold text-gray-800">No Pharmacy Items Found</h3>
                <p className="text-xs text-gray-500 max-w-xs mx-auto mt-1 mb-4">
                  No inventory items matched your filter or search query.
                </p>
                <button
                  onClick={handleOpenAdd}
                  className="px-4 py-2 bg-[#2563EB] text-white rounded-lg text-xs font-semibold inline-flex items-center gap-1.5"
                >
                  <Plus className="w-4 h-4" />
                  Add Pharmacy Item
                </button>
              </div>
            ) : (
              filteredItems.map(item => {
                const isLow = item.stock_quantity <= item.min_threshold && item.stock_quantity > 0;
                const isOut = item.stock_quantity === 0;

                return (
                  <div
                    key={item.id}
                    className={`bg-white rounded-xl p-4 border transition-all shadow-sm ${
                      isOut
                        ? 'border-[#FCA5A5] bg-[#FEF2F2]/30'
                        : isLow
                        ? 'border-[#FDE68A] bg-[#FFFBEB]/30'
                        : 'border-[#E2E8F0]'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3 mb-2">
                      <div>
                        <div className="flex items-center gap-2 flex-wrap">
                          <h3 className="text-base font-bold text-[#0F172A]">{item.name}</h3>
                          {item.name_ar && (
                            <span className="text-xs text-gray-500 font-normal">({item.name_ar})</span>
                          )}
                          <span className="px-2 py-0.5 bg-[#F1F5F9] text-[#475569] text-[11px] font-medium rounded-md">
                            {item.category}
                          </span>
                        </div>
                        <p className="text-xs text-[#64748B] mt-0.5">
                          Form: <strong className="font-medium text-[#334155]">{item.dosage_form}</strong>
                        </p>
                      </div>

                      {/* Status Badge */}
                      <div>
                        {isOut ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 bg-[#FEE2E2] text-[#991B1B] rounded-full text-[11px] font-bold">
                            <ShieldAlert className="w-3 h-3" /> Out of Stock
                          </span>
                        ) : isLow ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 bg-[#FEF3C7] text-[#92400E] rounded-full text-[11px] font-bold">
                            <AlertTriangle className="w-3 h-3" /> Low Stock
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 bg-[#D1FAE5] text-[#065F46] rounded-full text-[11px] font-bold">
                            <Check className="w-3 h-3" /> Active Stock
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Stock level bar */}
                    <div className="my-3 bg-[#F1F5F9] rounded-full h-2 w-full overflow-hidden">
                      <div
                        className={`h-full transition-all rounded-full ${
                          isOut ? 'bg-[#DC2626] w-0' : isLow ? 'bg-[#D97706]' : 'bg-[#10B981]'
                        }`}
                        style={{
                          width: `${Math.min(100, (item.stock_quantity / (item.min_threshold * 3)) * 100)}%`
                        }}
                      />
                    </div>

                    {/* Meta info grid */}
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 py-2 text-xs border-y border-[#F1F5F9] text-[#475569] mb-3">
                      <div className="flex items-center gap-1.5">
                        <Layers className="w-3.5 h-3.5 text-gray-400" />
                        <span>
                          Stock: <strong className="text-slate-900 font-bold">{item.stock_quantity}</strong> {item.unit}
                        </span>
                      </div>

                      <div className="flex items-center gap-1.5">
                        <AlertTriangle className="w-3.5 h-3.5 text-gray-400" />
                        <span>
                          Min Alert: <strong className="text-slate-900">{item.min_threshold}</strong> {item.unit}
                        </span>
                      </div>

                      <div className="flex items-center gap-1.5">
                        <MapPin className="w-3.5 h-3.5 text-gray-400" />
                        <span>
                          Loc: <strong className="text-slate-900">{item.location}</strong>
                        </span>
                      </div>

                      <div className="flex items-center gap-1.5">
                        <Calendar className="w-3.5 h-3.5 text-gray-400" />
                        <span>
                          Exp: <strong className="text-slate-900">{item.expiry_date}</strong>
                        </span>
                      </div>
                    </div>

                    {item.notes && (
                      <p className="text-[12px] text-gray-600 bg-gray-50 p-2 rounded-lg mb-3 flex items-start gap-1.5">
                        <Info className="w-3.5 h-3.5 text-gray-400 flex-shrink-0 mt-0.5" />
                        <span>{item.notes}</span>
                      </p>
                    )}

                    {/* Action buttons */}
                    <div className="flex items-center justify-between gap-2 pt-1">
                      <button
                        onClick={() => handleOpenAdjust(item)}
                        className="px-3 py-1.5 bg-[#EFF6FF] text-[#2563EB] hover:bg-[#DBEAFE] rounded-lg text-xs font-semibold flex items-center gap-1 transition-colors"
                      >
                        <SlidersHorizontal className="w-3.5 h-3.5" />
                        Adjust Stock Count
                      </button>

                      <div className="flex items-center gap-1">
                        <button
                          onClick={() => handleOpenEdit(item)}
                          className="p-1.5 text-gray-600 hover:text-[#2563EB] hover:bg-gray-100 rounded-lg transition-colors"
                          title="Edit Item"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleOpenDelete(item)}
                          className="p-1.5 text-gray-600 hover:text-[#DC2626] hover:bg-gray-100 rounded-lg transition-colors"
                          title="Delete Item"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        )}

        {/* ================= AUDIT LOG HISTORY TAB ================= */}
        {activeTab === 'audit_log' && (
          <div className="bg-white rounded-xl border border-[#E2E8F0] p-4 shadow-sm space-y-3">
            <div className="flex items-center justify-between border-b border-[#F1F5F9] pb-3">
              <div>
                <h2 className="text-base font-bold text-[#0F172A] flex items-center gap-2">
                  <History className="w-5 h-5 text-[#7C3AED]" />
                  Pharmacy Action Audit History
                </h2>
                <p className="text-xs text-[#64748B]">
                  Every pharmacy inventory action is recorded with nurse credentials and timestamp.
                </p>
              </div>

              <span className="text-xs bg-[#F5F3FF] text-[#7C3AED] px-2.5 py-1 rounded-full font-semibold">
                {logs.length} Recorded Entries
              </span>
            </div>

            <div className="space-y-3 divide-y divide-gray-100">
              {logs.map(log => {
                let badgeStyle = 'bg-gray-100 text-gray-800';
                let icon = <Info className="w-3.5 h-3.5" />;

                if (log.action === 'created') {
                  badgeStyle = 'bg-green-100 text-green-800';
                  icon = <Plus className="w-3.5 h-3.5" />;
                } else if (log.action === 'stock_adjusted') {
                  badgeStyle = log.quantity_change && log.quantity_change > 0 ? 'bg-blue-100 text-blue-800' : 'bg-amber-100 text-amber-800';
                  icon = log.quantity_change && log.quantity_change > 0 ? <ArrowUpRight className="w-3.5 h-3.5" /> : <ArrowDownRight className="w-3.5 h-3.5" />;
                } else if (log.action === 'updated') {
                  badgeStyle = 'bg-purple-100 text-purple-800';
                  icon = <Edit2 className="w-3.5 h-3.5" />;
                } else if (log.action === 'deleted') {
                  badgeStyle = 'bg-red-100 text-red-800';
                  icon = <Trash2 className="w-3.5 h-3.5" />;
                }

                return (
                  <div key={log.id} className="pt-3 first:pt-0">
                    <div className="flex items-start justify-between gap-2 mb-1">
                      <div className="flex items-center gap-2">
                        <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[11px] font-bold ${badgeStyle}`}>
                          {icon}
                          {log.action.replace('_', ' ').toUpperCase()}
                        </span>
                        <h4 className="text-xs font-bold text-[#0F172A]">{log.item_name}</h4>
                      </div>
                      <span className="text-[11px] text-gray-400 font-mono">{log.created_at}</span>
                    </div>

                    <div className="flex flex-col sm:flex-row sm:items-center justify-between text-xs text-[#475569] gap-1 bg-[#F8FAFC] p-2 rounded-lg mt-1">
                      <div>
                        Performed by: <strong className="text-slate-900 font-semibold">{log.performed_by_name}</strong>
                      </div>
                      {log.reason && (
                        <div className="text-gray-600 italic">
                          "{log.reason}"
                        </div>
                      )}
                      {log.quantity_change !== null && log.quantity_change !== undefined && (
                        <div className="font-semibold text-slate-900">
                          Change: <span className={log.quantity_change > 0 ? 'text-green-600' : 'text-red-600'}>
                            {log.quantity_change > 0 ? `+${log.quantity_change}` : log.quantity_change}
                          </span> (New Total: {log.new_quantity})
                        </div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>

      {/* ================= MODAL: ADD / EDIT ITEM ================= */}
      {isAddEditOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-5 shadow-2xl border border-gray-100 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3 mb-4">
              <h3 className="text-base font-bold text-gray-900 flex items-center gap-2">
                <Package className="w-5 h-5 text-[#2563EB]" />
                {editingItem ? 'Edit Pharmacy Inventory Item' : 'Add New Pharmacy Item'}
              </h3>
              <button
                onClick={() => setIsAddEditOpen(false)}
                className="p-1 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveItem} className="space-y-3.5 text-xs">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Medication Name (English) *</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={e => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g. Paracetamol 500mg Tablets"
                  className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]/20 text-sm outline-none"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Medication Name (Arabic)</label>
                <input
                  type="text"
                  value={formData.name_ar}
                  onChange={e => setFormData({ ...formData, name_ar: e.target.value })}
                  placeholder="e.g. باراسيتامول 500 ملغ أقراص"
                  className="w-full h-10 px-3 rounded-lg border border-gray-300 focus:border-[#2563EB] focus:ring-2 focus:ring-[#2563EB]/20 text-sm outline-none"
                  dir="rtl"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Category *</label>
                  <select
                    value={formData.category}
                    onChange={e => setFormData({ ...formData, category: e.target.value })}
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none focus:border-[#2563EB]"
                  >
                    <option value="Analgesic">Analgesic</option>
                    <option value="Antibiotic">Antibiotic</option>
                    <option value="Antihistamine">Antihistamine</option>
                    <option value="Respiratory">Respiratory</option>
                    <option value="Emergency">Emergency</option>
                    <option value="First Aid">First Aid</option>
                    <option value="Maintenance">Maintenance</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Dosage Form / Strength</label>
                  <input
                    type="text"
                    value={formData.dosage_form}
                    onChange={e => setFormData({ ...formData, dosage_form: e.target.value })}
                    placeholder="e.g. 500mg Tablet"
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Current Stock *</label>
                  <input
                    type="number"
                    min="0"
                    required
                    value={formData.stock_quantity}
                    onChange={e => setFormData({ ...formData, stock_quantity: parseInt(e.target.value) || 0 })}
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Min Threshold *</label>
                  <input
                    type="number"
                    min="0"
                    required
                    value={formData.min_threshold}
                    onChange={e => setFormData({ ...formData, min_threshold: parseInt(e.target.value) || 0 })}
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Unit *</label>
                  <input
                    type="text"
                    required
                    value={formData.unit}
                    onChange={e => setFormData({ ...formData, unit: e.target.value })}
                    placeholder="tablets/bottles"
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Cabinet / Shelf Location</label>
                  <input
                    type="text"
                    value={formData.location}
                    onChange={e => setFormData({ ...formData, location: e.target.value })}
                    placeholder="Cabinet A-1, Fridge 1"
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Expiry Date</label>
                  <input
                    type="date"
                    value={formData.expiry_date}
                    onChange={e => setFormData({ ...formData, expiry_date: e.target.value })}
                    className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Supplier / Manufacturer</label>
                <input
                  type="text"
                  value={formData.supplier}
                  onChange={e => setFormData({ ...formData, supplier: e.target.value })}
                  placeholder="Julphar / GSK / Gulf Pharma"
                  className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Notes & Storage Instructions</label>
                <textarea
                  rows={2}
                  value={formData.notes}
                  onChange={e => setFormData({ ...formData, notes: e.target.value })}
                  placeholder="Special instructions or precautions..."
                  className="w-full p-2.5 rounded-lg border border-gray-300 text-sm outline-none"
                />
              </div>

              <div className="pt-2 flex items-center justify-end gap-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setIsAddEditOpen(false)}
                  className="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-semibold text-xs"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 bg-[#2563EB] hover:bg-[#1D4ED8] text-white rounded-lg font-semibold text-xs flex items-center gap-1.5"
                >
                  <Check className="w-4 h-4" />
                  Save Item
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ================= MODAL: ADJUST STOCK ================= */}
      {isAdjustOpen && adjustItem && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-5 shadow-2xl border border-gray-100">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3 mb-4">
              <h3 className="text-base font-bold text-gray-900 flex items-center gap-2">
                <SlidersHorizontal className="w-5 h-5 text-[#2563EB]" />
                Adjust Stock Quantity
              </h3>
              <button
                onClick={() => setIsAdjustOpen(false)}
                className="p-1 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveAdjust} className="space-y-4 text-xs">
              <div className="bg-blue-50 p-3 rounded-xl text-blue-900 border border-blue-200">
                <p className="font-bold text-sm mb-1">{adjustItem.name}</p>
                <p className="text-xs">
                  Current Stock: <strong className="font-bold text-base">{adjustItem.stock_quantity}</strong> {adjustItem.unit}
                </p>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">
                  Adjustment (+ for Intake / Restock, - for Dispensed / Waste)
                </label>
                <div className="flex items-center gap-2">
                  <input
                    type="number"
                    required
                    value={adjustQty}
                    onChange={e => setAdjustQty(parseInt(e.target.value) || 0)}
                    placeholder="e.g. +20 or -5"
                    className="flex-1 h-10 px-3 rounded-lg border border-gray-300 text-sm font-bold outline-none focus:border-[#2563EB]"
                  />
                  <span className="text-gray-500 font-medium">{adjustItem.unit}</span>
                </div>
                <p className="text-[11px] text-gray-500 mt-1">
                  New resulting total stock: <strong className="text-slate-900 font-bold">{Math.max(0, adjustItem.stock_quantity + adjustQty)}</strong> {adjustItem.unit}
                </p>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Reason / Note for Audit Log *</label>
                <input
                  type="text"
                  required
                  value={adjustReason}
                  onChange={e => setAdjustReason(e.target.value)}
                  placeholder="e.g. Routine weekly stock intake / Dispensed to student"
                  className="w-full h-10 px-3 rounded-lg border border-gray-300 text-sm outline-none focus:border-[#2563EB]"
                />
              </div>

              <div className="pt-2 flex items-center justify-end gap-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setIsAdjustOpen(false)}
                  className="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-semibold text-xs"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 bg-[#2563EB] hover:bg-[#1D4ED8] text-white rounded-lg font-semibold text-xs flex items-center gap-1.5"
                >
                  <Check className="w-4 h-4" />
                  Confirm Stock Adjustment
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ================= MODAL: DELETE ITEM ================= */}
      {isDeleteOpen && deletingItem && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-5 shadow-2xl border border-gray-100 text-center">
            <div className="w-12 h-12 rounded-full bg-red-100 text-red-600 flex items-center justify-center mx-auto mb-3">
              <Trash2 className="w-6 h-6" />
            </div>

            <h3 className="text-base font-bold text-gray-900 mb-1">Remove Pharmacy Item?</h3>
            <p className="text-xs text-gray-600 mb-4">
              Are you sure you want to remove <strong className="text-gray-900">{deletingItem.name}</strong> from the pharmacy inventory catalog? This action will be logged in the audit history.
            </p>

            <div className="flex items-center justify-center gap-2">
              <button
                type="button"
                onClick={() => setIsDeleteOpen(false)}
                className="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-semibold text-xs"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleConfirmDelete}
                className="px-5 py-2 bg-[#DC2626] hover:bg-[#B91C1C] text-white rounded-lg font-semibold text-xs flex items-center gap-1.5"
              >
                <Trash2 className="w-4 h-4" />
                Remove Item
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

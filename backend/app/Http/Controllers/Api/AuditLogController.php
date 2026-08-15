<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AuditLogResource;
use App\Models\AuditLog;
use Illuminate\Http\Request;

class AuditLogController extends Controller
{
    /// GET /api/audit-logs?action=
    public function index(Request $request)
    {
        $query = AuditLog::query();

        if ($request->filled('action')) {
            $query->where('action', $request->string('action'));
        }

        return AuditLogResource::collection($query->latest('created_at')->paginate(50));
    }
}

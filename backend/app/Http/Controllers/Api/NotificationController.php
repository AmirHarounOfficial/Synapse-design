<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AppNotificationResource;
use App\Models\AppNotification;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class NotificationController extends Controller
{
    /// GET /api/notifications — the authenticated user's notifications, newest first.
    public function index(Request $request)
    {
        $notifications = AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(50);

        return AppNotificationResource::collection($notifications);
    }

    /// POST /api/notifications/{notification}/read
    public function read(Request $request, AppNotification $notification)
    {
        if ($notification->user_id !== $request->user()->id) {
            throw new AccessDeniedHttpException('This notification does not belong to you.');
        }

        $notification->update(['read_at' => now()]);

        return new AppNotificationResource($notification);
    }
}

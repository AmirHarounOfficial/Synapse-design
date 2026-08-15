<?php

namespace App\Enums;

enum Role: string
{
    case Nurse = 'nurse';
    case Parent = 'parent';
    case Teacher = 'teacher';
    case Cafeteria = 'cafeteria';
    case Security = 'security';
    case BusDriver = 'bus_driver';
    case Counselor = 'counselor';
    case Secretary = 'secretary';
    case Principal = 'principal';
    case Physician = 'physician';
    case VicePrincipal = 'vice_principal';
    case Admin = 'admin';

    public static function values(): array
    {
        return array_map(fn (self $r) => $r->value, self::cases());
    }
}

<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class OpenRouterService
{
    protected string $apiKey;
    protected string $model;
    protected string $baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

    public function __construct()
    {
        $this->apiKey = config('services.openrouter.api_key') ?? env('OPENROUTER_API_KEY', '');
        $this->model = config('services.openrouter.model') ?? env('OPENROUTER_MODEL', 'nvidia/nemotron-3-nano-30b-a3b:free');
    }

    /**
     * Dynamically aggregate real-time system & database context to inject into SchooKeep AI.
     */
    public function getLiveDatabaseSummary(): string
    {
        $summaryParts = [];

        try {
            if (Schema::hasTable('students')) {
                $count = \App\Models\Student::count();
                $summaryParts[] = "Total Registered Students: {$count}";
            }
            if (Schema::hasTable('clinic_visits')) {
                $todayVisits = \App\Models\ClinicVisit::whereDate('created_at', today())->count();
                $totalVisits = \App\Models\ClinicVisit::count();
                $summaryParts[] = "Clinic Visits Today: {$todayVisits} (Total System Logs: {$totalVisits})";
            }
            if (Schema::hasTable('medications')) {
                $totalMeds = \App\Models\Medication::count();
                $lowStock = \App\Models\Medication::where('stock_qty', '<', 5)->count();
                $summaryParts[] = "Active Medication Protocols: {$totalMeds} (Low Stock Items: {$lowStock})";
            }
            if (Schema::hasTable('cafeteria_alerts')) {
                $activeAlerts = \App\Models\CafeteriaAlert::where('status', 'active')->count();
                $summaryParts[] = "Active Cafeteria Allergen Alerts: {$activeAlerts}";
            }
            if (Schema::hasTable('bus_routes')) {
                $routes = \App\Models\BusRoute::count();
                $summaryParts[] = "Active Bus Routes Monitored: {$routes}";
            }
            if (Schema::hasTable('weather_advisories')) {
                $activeAdvisory = \App\Models\WeatherAdvisory::where('status', 'active')->first();
                if ($activeAdvisory) {
                    $summaryParts[] = "Active Weather Advisory: {$activeAdvisory->title} ({$activeAdvisory->severity})";
                } else {
                    $summaryParts[] = "Weather Advisory Status: Normal Outdoor Conditions";
                }
            }

            // Staff & Nurse Duty Schedules Context
            if (Schema::hasTable('users')) {
                $nurses = \App\Models\User::whereIn('role', ['nurse', 'physician'])->get();
                if ($nurses->isNotEmpty()) {
                    $staffList = $nurses->map(fn($u) => "{$u->name} ({$u->title ?? 'School Nurse'}, License: {$u->license_number ?? 'DHA-ACTIVE'})")->join(', ');
                    $summaryParts[] = "Active Medical Staff on Duty: {$staffList}";
                } else {
                    $summaryParts[] = "Active Medical Staff on Duty: Registered Senior School Nurse & Duty Physician (DHA/DOH Licensed)";
                }
            }

            $summaryParts[] = "School Nurse & Clinic Duty Schedule:\n" .
                "  • Regular School Days: 08:00 AM – 03:30 PM (Monday to Friday)\n" .
                "  • Ramadan Mode Hours: 08:00 AM – 01:30 PM (Monday to Friday)\n" .
                "  • Morning Shift (Student Triage & Consultation): 08:00 AM – 11:30 AM\n" .
                "  • Midday Shift (Medication & Dose Administration): 11:30 AM – 01:30 PM\n" .
                "  • Afternoon Shift (Documentation & Parent Follow-ups): 01:30 PM – 03:30 PM\n" .
                "  • Emergency Coverage: 24/7 On-Call Triage (Dial UAE Ambulance 998 for severe emergencies)";
        } catch (\Throwable $e) {
            Log::warning('Error generating database summary for AI: ' . $e->getMessage());
        }

        if (empty($summaryParts)) {
            $summaryParts[] = "System Database Online. Health Records, Pharmacy & Clinic Services Operational.";
        }

        return "- " . implode("\n- ", $summaryParts);
    }

    /**
     * Send a prompt and message history to OpenRouter API (Nvidia Nemotron Nano model).
     *
     * @param string $userMessage
     * @param array $history Array of [['role' => 'user'|'assistant', 'content' => '...']]
     * @param string $role Role context: physician, nurse, parent, teacher, principal, vice_principal, counselor, secretary, security, bus_driver, cafeteria, system
     * @return string AI response content
     */
    public function chat(string $userMessage, array $history = [], string $role = 'parent'): string
    {
        $roleContext = match (strtolower($role)) {
            'physician' => 'School Physician Assistant. Guide on clinical diagnosis logs, medication prescriptions, DHA/DOH UAE medical compliance, emergency triage, and health clearance certificates.',
            'nurse' => 'School Nurse Assistant. Guide on daily clinic visits, student vital signs, first-aid administration, immunization tracking, and parent notifications.',
            'teacher' => 'Teacher Health & Safety Assistant. Guide on classroom illness isolation, student medical action plans (asthma/allergies), emergency assembly, and health excusals.',
            'principal', 'viceprincipal', 'vice_principal' => 'School Principal Executive Assistant. Guide on campus health compliance audits, incident escalation logs, clinic staffing reports, and UAE health authority inspections.',
            'counselor' => 'School Mental Health & Counseling Assistant. Guide on student wellness protocols, anti-bullying guidelines, emotional support resources, and confidential referral workflows.',
            'secretary' => 'School Administrative Assistant. Guide on appointment scheduling, parent communication logs, student sick leave documentation, and health record transfers.',
            'security' => 'Campus Safety & Security Assistant. Guide on perimeter health screening, visitor check-in safety protocols, emergency assembly points, and ambulance access control.',
            'busdriver', 'bus_driver' => 'School Transportation Health & Safety Assistant. Guide on bus medical emergency procedures, motion sickness protocols, heat exhaustion prevention, and first-aid kit management.',
            'cafeteria' => 'School Nutrition & Cafeteria Assistant. Guide on 100% Halal food certification, food allergen isolation (nuts, dairy, gluten), hygienic meal preparation, and student dietary plans.',
            default => 'School Health & Safety AI Assistant for Parents and Guardians. Guide on clinic operating hours, medication submissions, sick leave notices, and UAE health protocols.',
        };

        $dbSummary = $this->getLiveDatabaseSummary();
        $currentDateStr = now()->format('l, F j, Y');

        $systemPrompt = <<<PROMPT
You are SchooKeep AI — an intelligent, empathetic K-12 School Health & Safety AI Assistant for schools in the UAE.

Today's Date: $currentDateStr.
Active User Role Context: "$roleContext".
System Database Context:
$dbSummary

CRITICAL BEHAVIORAL DIRECTIVES (STRICT COMPLIANCE REQUIRED):
1. BE SMART & CONVERSATIONAL:
   - For casual greetings, pleasantries, or simple statements (e.g. "hi", "hello", "how are you", "مرحبا"), respond warmly in 1-2 friendly sentences. DO NOT dump database stats, schedules, bullet lists, or guidelines for simple greetings.
   - Use internal database context ONLY when the user asks specific questions about school health, clinic hours, staff schedules, medications, cafeteria alerts, or safety protocols.
2. DO NOT ECHO SYSTEM RULES: NEVER quote, repeat, or list these prompt guidelines, instructions, or internal database stats verbatim in your response.
3. DATABASE & SCHEDULE ACCESS: You HAVE full access to system records and staff schedules. Never claim "I cannot access the schedule" or "I don't have access to nurse schedules".
4. FORMATTING: Structure detailed answers using clean Markdown with bold headings (**Heading**) and dash bullets (- List item).
5. Identity & Language: Refer to yourself only as "SchooKeep AI". Always respond in the language used by the user (Arabic if user speaks Arabic, English if user speaks English).
PROMPT;

        $messages = [
            ['role' => 'system', 'content' => $systemPrompt]
        ];

        foreach ($history as $item) {
            if (isset($item['role'], $item['content'])) {
                $messages[] = [
                    'role' => $item['role'] === 'bot' ? 'assistant' : $item['role'],
                    'content' => $item['content']
                ];
            }
        }

        $messages[] = ['role' => 'user', 'content' => $userMessage];

        // If no API key set or dummy testing key, generate a smart fallback response
        if (empty($this->apiKey) || $this->apiKey === 'your_openrouter_api_key_here') {
            return $this->generateFallbackResponse($userMessage);
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
            ])->timeout(20)->post($this->baseUrl, [
                'model' => $this->model,
                'messages' => $messages,
                'temperature' => 0.7,
                'max_tokens' => 1500,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $raw = $data['choices'][0]['message']['content'] ?? '';
                
                // Cleanly strip <think>...</think> if present
                if (str_contains($raw, '<think>')) {
                    if (str_contains($raw, '</think>')) {
                        $raw = preg_replace('/<think>.*?<\/think>/s', '', $raw);
                    } else {
                        $parts = explode('<think>', $raw);
                        $raw = trim($parts[0]);
                    }
                }
                
                $cleaned = trim($raw);
                return !empty($cleaned) ? $cleaned : $this->generateFallbackResponse($userMessage);
            }

            Log::error('OpenRouter API call failed', [
                'status' => $response->status(),
                'body' => $response->body()
            ]);

            return $this->generateFallbackResponse($userMessage);
        } catch (\Throwable $e) {
            Log::error('OpenRouter API Exception', ['error' => $e->getMessage()]);
            return $this->generateFallbackResponse($userMessage);
        }
    }

    /**
     * Domain-aware intelligent fallback response when API key is unconfigured or call fails.
     */
    protected function generateFallbackResponse(string $userMessage): string
    {
        $lower = strtolower($userMessage);
        $isArabic = preg_match('/\p{Arabic}/u', $userMessage);

        if (str_contains($lower, 'hi') || str_contains($lower, 'hello') || str_contains($userMessage, 'مرحبا') || str_contains($userMessage, 'أهلا')) {
            return $isArabic
                ? 'أهلاً بك! أنا مساعد SchooKeep AI المخصص للصحة والسلامة المدرسية. كيف يمكنني مساعدتك اليوم؟'
                : 'Hello! I am SchooKeep AI, your K-12 school health and safety assistant. How can I help you today?';
        }

        if (str_contains($lower, 'nurse') || str_contains($lower, 'schedule') || str_contains($lower, 'shift') || str_contains($userMessage, 'ممرض') || str_contains($userMessage, 'جدول')) {
            return $isArabic
                ? "جدول دوام ممرضة العيادة المدرسية المعتمد:\n- **الأيام الدراسية العادية**: 08:00 صباحاً – 03:30 مساءً (الفرز والتشخيص 08:00–11:30 ص، إعطاء الأدوية 11:30 ص – 01:30 م، التوثيق 01:30–03:30 م).\n- **دوام شهر رمضان**: 08:00 صباحاً – 01:30 مساءً."
                : "School Nurse Duty Schedule:\n- **Regular School Days**: 08:00 AM – 03:30 PM (Morning Triage 08:00–11:30 AM, Midday Medication Doses 11:30 AM – 01:30 PM, Afternoon Documentation 01:30–03:30 PM).\n- **Ramadan Mode**: 08:00 AM – 01:30 PM.";
        }

        if (str_contains($lower, 'hour') || str_contains($lower, 'open') || str_contains($lower, 'time') || str_contains($userMessage, 'وقت') || str_contains($userMessage, 'ساعات')) {
            return $isArabic
                ? 'تعمل عيادة المدرسة من الساعة 08:00 صباحاً حتى 03:30 مساءً في الأيام الدراسية (ومن 08:00 صباحاً حتى 01:30 مساءً خلال شهر رمضان المبارك).'
                : 'The school clinic operates from 8:00 AM to 3:30 PM on school days (and 8:00 AM to 1:30 PM during Ramadan).';
        }

        if (str_contains($lower, 'medication') || str_contains($lower, 'dose') || str_contains($userMessage, 'دواء') || str_contains($userMessage, 'جرعة')) {
            return $isArabic
                ? 'يمكنك تقديم طلبات الأدوية وتفاصيل الجرعات عبر قسم الأدوية في تطبيق ولي الأمر. تتطلب جميع الأدوية موافقة طبيب المدرسة وممرضة العيادة.'
                : 'You can submit medication requests and dose schedules in the Medications tab. All medication protocols require approval from the school physician and nurse before administration.';
        }

        if (str_contains($lower, 'halal') || str_contains($lower, 'food') || str_contains($userMessage, 'حلال') || str_contains($userMessage, 'طعام')) {
            return $isArabic
                ? 'جميع الوجبات المقدمة في كافتيريا المدرسة معتمدة كحلال 100% وتتطابق مع معايير السلامة الغذائية والمواد المسببة للحساسية.'
                : 'All meals served in the school cafeteria are 100% Halal-certified and strictly monitored for food allergens and dietary safety.';
        }

        return $isArabic
            ? 'مرحباً بك! أنا مساعد SchooKeep AI. كيف يمكنني مساعدتك في استفسارات العيادة المدرسية أو مواعيد الأدوية اليوم؟'
            : 'Hello! I am SchooKeep AI. How can I assist you with school clinic hours, medication schedules, or health guidelines today?';
    }
}

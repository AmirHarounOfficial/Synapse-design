<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

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
     * Send a prompt and message history to OpenRouter API (Nvidia Nemotron Nano model).
     *
     * @param string $userMessage
     * @param array $history Array of [['role' => 'user'|'assistant', 'content' => '...']]
     * @return string AI response content
     */
    public function chat(string $userMessage, array $history = []): string
    {
        $systemPrompt = <<<PROMPT
You are SchooKeep AI — an intelligent, empathetic K-12 School Health & Safety AI Assistant for schools in the UAE.

Key Guidelines & Context:
1. Primary Role: Help parents and guardians with school health procedures, clinic visit inquiries, medication submission protocols, Halal cafeteria rules, Ramadan operating hours, and UAE medical compliance.
2. Identity: Always refer to yourself as "SchooKeep AI". Never mention internal technical model names, providers, or infrastructure in your messages to parents.
3. Clinic Hours: Standard school days 08:00 AM – 03:30 PM. During Ramadan mode: 08:00 AM – 01:30 PM.
4. Emergency Numbers: UAE Ambulance 998, UAE Police 999. Always emphasize calling 998 for severe medical emergencies.
5. Disclaimer: You do not provide binding clinical diagnoses. Nurse or Physician review is required for prescriptions and treatments.
6. Language: Always respond in the language used by the user (Arabic if user speaks Arabic, English if user speaks English). Keep responses concise, clear, and professional.
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
                'HTTP-Referer' => config('app.url', 'http://localhost'),
                'X-Title' => 'SchooKeep Health App (UAE)',
                'Content-Type' => 'application/json',
            ])->timeout(15)->post($this->baseUrl, [
                'model' => $this->model,
                'messages' => $messages,
                'temperature' => 0.7,
                'max_tokens' => 500,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return $data['choices'][0]['message']['content'] ?? $this->generateFallbackResponse($userMessage);
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

        if (str_contains($lower, 'hour') || str_contains($lower, 'open') || str_contains($lower, 'time') || str_contains($userMessage, 'وقت') || str_contains($userMessage, 'ساعات')) {
            return $isArabic
                ? 'تعمل عيادة المدرسة من الساعة 08:00 صباحاً حتى 03:30 مساءً في الأيام الدراسية (ومن 08:00 صباحاً حتى 01:30 مساءً خلال شهر رمضان المبارك). هل يمكنني مساعدتك في شيء آخر؟'
                : 'The school clinic operates from 8:00 AM to 3:30 PM on school days (and 8:00 AM to 1:30 PM during Ramadan). Is there anything else I can assist you with?';
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
            ? 'مرحباً بك! أنا مساعد SchooKeep AI. يمكنني مساعدتك في استفسارات العيادة المدرسية، مواعيد الأدوية، وإرشادات الصحة والسلامة.'
            : 'Hello! I am SchooKeep AI. How can I assist you with school clinic hours, medication schedules, or health guidelines today?';
    }
}

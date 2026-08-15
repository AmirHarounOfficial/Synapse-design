<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DocumentResource;
use App\Models\Document;
use Illuminate\Http\Request;

class DocumentController extends Controller
{
    /// GET /api/documents?status=&student_id=
    public function index(Request $request)
    {
        $query = Document::query();

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }
        if ($request->filled('student_id')) {
            $query->where('student_id', $request->integer('student_id'));
        }

        return DocumentResource::collection($query->latest()->paginate(50));
    }

    public function show(Document $document)
    {
        return new DocumentResource($document);
    }

    /// POST /api/documents (multipart) — upload a document/photo to local disk.
    public function store(Request $request)
    {
        $data = $request->validate([
            'file' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png,heic,webp', 'max:10240'],
            'student_id' => ['required', 'exists:students,id'],
            'type' => ['nullable', 'string', 'max:64'],
            'title' => ['nullable', 'string', 'max:255'],
            'expiry_date' => ['nullable', 'date'],
        ]);

        $path = $request->file('file')->store('documents', 'public');

        $document = Document::create([
            'student_id' => $data['student_id'],
            'type' => $data['type'] ?? 'other',
            'title' => $data['title'] ?? $request->file('file')->getClientOriginalName(),
            'file_path' => $path,
            'status' => 'pending',
            'expiry_date' => $data['expiry_date'] ?? null,
            'uploaded_by' => $request->user()->id,
        ]);

        return (new DocumentResource($document))->response()->setStatusCode(201);
    }

    /// POST /api/documents/{document}/review {status: approved|rejected, notes?}
    public function review(Request $request, Document $document)
    {
        $data = $request->validate([
            'status' => ['required', 'in:approved,rejected'],
            'notes' => ['nullable', 'string'],
        ]);

        $document->update([
            'status' => $data['status'],
            'notes' => $data['notes'] ?? $document->notes,
            'reviewed_by' => $request->user()->id,
            'reviewed_at' => now(),
        ]);

        return new DocumentResource($document);
    }
}

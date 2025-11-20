// API configuration
const API_BASE_URL = import.meta.env.VITE_API_URL || '/dev/api';

export interface CodeExecutionRequest {
  code: string;
}

export interface CodeExecutionResponse {
  stdout: string;
  stderr: string;
  success: boolean;
  error_message?: string | null;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status?: number,
    public details?: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export async function executeCode(code: string): Promise<CodeExecutionResponse> {
  try {
    const response = await fetch(`${API_BASE_URL}/execute`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code } as CodeExecutionRequest),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new ApiError(
        errorData.detail || 'Failed to execute code',
        response.status,
        JSON.stringify(errorData)
      );
    }

    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }
    
    // Network or other errors
    throw new ApiError(
      error instanceof Error ? error.message : 'Network error occurred',
      undefined,
      String(error)
    );
  }
}

export async function checkHealth(): Promise<{ status: string }> {
  const response = await fetch(`${API_BASE_URL}/health`);
  if (!response.ok) {
    throw new ApiError('Health check failed', response.status);
  }
  return await response.json();
}

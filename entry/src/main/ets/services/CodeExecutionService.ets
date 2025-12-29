/**
 * 代码执行服务
 * 支持多种语言的代码执行，使用 Piston API
 * Piston 是一个开源的代码执行 API: https://github.com/engineer-man/piston
 */
import { http } from '@kit.NetworkKit';

// 执行结果接口
export interface ExecutionResult {
  stdout: string;
  stderr: string;
  exitCode: number;
  duration: number;
  language: string;
}

// 支持的语言配置
interface LanguageConfig {
  name: string;
  pistonLanguage: string;
  pistonVersion: string;
  extensions: string[];
}

interface PistonFileRequest {
  content: string;
}

interface PistonExecuteRequest {
  language: string;
  version: string;
  files: PistonFileRequest[];
}

interface PistonRunResult {
  stdout?: string;
  stderr?: string;
  exitCode?: number;
  cpuTime?: number;
}

interface PistonMessage {
  run?: PistonRunResult;
}

interface PistonResponse {
  run?: PistonRunResult;
  message?: string | PistonMessage;
}

export const SUPPORTED_LANGUAGES: Record<string, LanguageConfig> = {
  'python': {
    name: 'Python',
    pistonLanguage: 'python',
    pistonVersion: '3.10.0',
    extensions: ['.py']
  },
  'javascript': {
    name: 'JavaScript',
    pistonLanguage: 'javascript',
    pistonVersion: '18.15.0',
    extensions: ['.js', '.mjs']
  },
  'typescript': {
    name: 'TypeScript',
    pistonLanguage: 'typescript',
    pistonVersion: '5.0.0',
    extensions: ['.ts']
  },
  'java': {
    name: 'Java',
    pistonLanguage: 'java',
    pistonVersion: '15.0.2',
    extensions: ['.java']
  },
  'c': {
    name: 'C',
    pistonLanguage: 'c',
    pistonVersion: '10.2.1',
    extensions: ['.c']
  },
  'cpp': {
    name: 'C++',
    pistonLanguage: 'c++',
    pistonVersion: '10.2.1',
    extensions: ['.cpp', '.cc', '.cxx']
  },
  'go': {
    name: 'Go',
    pistonLanguage: 'go',
    pistonVersion: '1.18.1',
    extensions: ['.go']
  },
  'rust': {
    name: 'Rust',
    pistonLanguage: 'rust',
    pistonVersion: '1.68.0',
    extensions: ['.rs']
  },
  'ruby': {
    name: 'Ruby',
    pistonLanguage: 'ruby',
    pistonVersion: '3.1.2',
    extensions: ['.rb']
  },
  'php': {
    name: 'PHP',
    pistonLanguage: 'php',
    pistonVersion: '8.1.10',
    extensions: ['.php']
  }
};

@Observed
export class CodeExecutionService {
  private static instance: CodeExecutionService;

  // Piston API 端点列表（主服务器 + 备用服务器）
  private readonly API_ENDPOINTS = [
    'https://emkc.org/api/v2/piston/execute',           // 主服务器（美国）
    'https://piston-demo.realtimechat.shreyasl.com/api/v2/piston/execute', // 备用服务器
    'https://emkc.org/v2/piston/execute'                // 备用路径
  ];

  // 当前使用的 API 端点索引
  private currentApiIndex: number = 0;

  private constructor() {}

  static getInstance(): CodeExecutionService {
    if (!CodeExecutionService.instance) {
      CodeExecutionService.instance = new CodeExecutionService();
    }
    return CodeExecutionService.instance;
  }

  /**
   * 检查语言是否支持远程执行
   */
  isLanguageSupported(language: string): boolean {
    return Object.keys(SUPPORTED_LANGUAGES).includes(language);
  }

  /**
   * 执行代码（使用 Piston API，带自动故障转移）
   * @param code 代码内容
   * @param language 编程语言
   * @param timeout 超时时间（毫秒）
   * @returns 执行结果
   */
  async executeCode(code: string, language: string, timeout: number = 10000): Promise<ExecutionResult> {
    const startTime = Date.now();

    try {
      // 检查语言支持
      const langConfig = SUPPORTED_LANGUAGES[language];
      if (!langConfig) {
        return {
          stdout: '',
          stderr: `Language '${language}' is not supported for execution.`,
          exitCode: 1,
          duration: 0,
          language
        };
      }

      // 对于 JavaScript/TypeScript，如果有本地 WebController，优先使用本地执行
      if ((language === 'javascript' || language === 'typescript') && code.length < 10000) {
        // 返回特殊标记，表示应该使用本地执行
        return {
          stdout: '',
          stderr: '',
          exitCode: -1, // -1 表示使用本地执行
          duration: 0,
          language
        };
      }

      // 准备请求
      const requestPayload: PistonExecuteRequest = {
        language: langConfig.pistonLanguage,
        version: langConfig.pistonVersion,
        files: [{
          content: code
        }]
      };
      const requestBody = JSON.stringify(requestPayload);

      // 尝试所有 API 端点（故障转移）
      for (let i = 0; i < this.API_ENDPOINTS.length; i++) {
        const apiEndpoint = this.API_ENDPOINTS[this.currentApiIndex];

        try {
          const result = await this.tryExecuteCode(apiEndpoint, requestBody, timeout, startTime, language);
          // 成功，重置索引
          this.currentApiIndex = 0;
          return result;
        } catch (error) {
          console.warn(`API endpoint ${apiEndpoint} failed, trying next...`, error);
          // 切换到下一个端点
          this.currentApiIndex = (this.currentApiIndex + 1) % this.API_ENDPOINTS.length;
        }
      }

      // 所有端点都失败
      const duration = Date.now() - startTime;
      return {
        stdout: '',
        stderr: 'All API endpoints failed. Please check your network connection.',
        exitCode: 1,
        duration,
        language
      };

    } catch (error) {
      const duration = Date.now() - startTime;
      const errMsg = error instanceof Error && error.message ? error.message : 'Unknown error';

      return {
        stdout: '',
        stderr: `Execution failed: ${errMsg}`,
        exitCode: 1,
        duration,
        language
      };
    }
  }

  /**
   * 尝试使用指定端点执行代码
   */
  private async tryExecuteCode(
    apiEndpoint: string,
    requestBody: string,
    timeout: number,
    startTime: number,
    language: string
  ): Promise<ExecutionResult> {
    const request: http.HttpRequest = http.createHttp();

    const response: http.HttpResponse = await request.request(apiEndpoint, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      extraData: requestBody,
      connectTimeout: 8000,  // 连接超时 8 秒
      readTimeout: timeout,
      expectDataType: http.HttpDataType.STRING
    });

    const duration = Date.now() - startTime;

    if (response.responseCode === 200) {
      const result: PistonResponse = JSON.parse(response.result as string) as PistonResponse;

      // Piston API 返回格式
      const message = result.message;
      const runResult = result.run || (typeof message === 'object' && message !== null ? message.run : undefined);
      if (runResult) {
        return {
          stdout: runResult.stdout || '',
          stderr: runResult.stderr || '',
          exitCode: runResult.exitCode || 0,
          duration: runResult.cpuTime || duration,
          language
        };
      } else if (typeof message === 'string' && message.length > 0) {
        // 编译错误
        return {
          stdout: '',
          stderr: message,
          exitCode: 1,
          duration,
          language
        };
      }
    }

    // 请求失败
    throw new Error(`HTTP Error: ${response.responseCode}`);
  }

  /**
   * 获取支持的语言列表
   */
  getSupportedLanguages(): string[] {
    return Object.keys(SUPPORTED_LANGUAGES);
  }

  /**
   * 获取语言信息
   */
  getLanguageInfo(language: string): LanguageConfig | null {
    return SUPPORTED_LANGUAGES[language] || null;
  }
}

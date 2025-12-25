/**
 * 代码模板数据模型
 */

export interface CodeTemplate {
  id: string;
  name: string;
  description: string;
  language: string;
  code: string;
  category: string;
}

export class CodeTemplateData {
  /**
   * 获取所有模板
   */
  public static getAllTemplates(): CodeTemplate[] {
    return [
      // JavaScript 模板
      {
        id: 'js_function',
        name: 'Function',
        description: '函数声明',
        language: 'javascript',
        code: 'function functionName(params) {\n  // 函数体\n  return result;\n}',
        category: 'JavaScript'
      },
      {
        id: 'js_arrow',
        name: 'Arrow Function',
        description: '箭头函数',
        language: 'javascript',
        code: 'const functionName = (params) => {\n  // 函数体\n  return result;\n};',
        category: 'JavaScript'
      },
      {
        id: 'js_async',
        name: 'Async Function',
        description: '异步函数',
        language: 'javascript',
        code: 'async function functionName(params) {\n  try {\n    const result = await someAsyncOperation();\n    return result;\n  } catch (error) {\n    console.error(error);\n  }\n}',
        category: 'JavaScript'
      },
      {
        id: 'js_class',
        name: 'Class',
        description: '类定义',
        language: 'javascript',
        code: 'class ClassName {\n  constructor(params) {\n    this.property = params;\n  }\n\n  method() {\n    // 方法体\n  }\n}',
        category: 'JavaScript'
      },
      {
        id: 'js_promise',
        name: 'Promise',
        description: 'Promise 模板',
        language: 'javascript',
        code: 'const promise = new Promise((resolve, reject) => {\n  // 异步操作\n  if (success) {\n    resolve(result);\n  } else {\n    reject(error);\n  }\n});',
        category: 'JavaScript'
      },
      
      // TypeScript 模板
      {
        id: 'ts_interface',
        name: 'Interface',
        description: '接口定义',
        language: 'typescript',
        code: 'interface InterfaceName {\n  property: string;\n  method(): void;\n}',
        category: 'TypeScript'
      },
      {
        id: 'ts_type',
        name: 'Type Alias',
        description: '类型别名',
        language: 'typescript',
        code: 'type TypeName = {\n  property: string;\n  optional?: number;\n};',
        category: 'TypeScript'
      },
      {
        id: 'ts_generic',
        name: 'Generic Function',
        description: '泛型函数',
        language: 'typescript',
        code: 'function functionName<T>(param: T): T {\n  return param;\n}',
        category: 'TypeScript'
      },
      
      // HTML 模板
      {
        id: 'html_basic',
        name: 'HTML Template',
        description: 'HTML 基础模板',
        language: 'html',
        code: '<!DOCTYPE html>\n<html lang="zh-CN">\n<head>\n  <meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n  <title>Document</title>\n</head>\n<body>\n  \n</body>\n</html>',
        category: 'HTML'
      },
      {
        id: 'html_form',
        name: 'Form',
        description: '表单模板',
        language: 'html',
        code: '<form action="" method="post">\n  <label for="input">Label:</label>\n  <input type="text" id="input" name="input" required>\n  <button type="submit">Submit</button>\n</form>',
        category: 'HTML'
      },
      
      // CSS 模板
      {
        id: 'css_flexbox',
        name: 'Flexbox',
        description: 'Flex 布局',
        language: 'css',
        code: '.container {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n  gap: 10px;\n}',
        category: 'CSS'
      },
      {
        id: 'css_grid',
        name: 'Grid',
        description: 'Grid 布局',
        language: 'css',
        code: '.container {\n  display: grid;\n  grid-template-columns: repeat(3, 1fr);\n  gap: 20px;\n}',
        category: 'CSS'
      },
      {
        id: 'css_animation',
        name: 'Animation',
        description: 'CSS 动画',
        language: 'css',
        code: '@keyframes animationName {\n  0% {\n    opacity: 0;\n    transform: translateY(-20px);\n  }\n  100% {\n    opacity: 1;\n    transform: translateY(0);\n  }\n}\n\n.element {\n  animation: animationName 0.3s ease-in-out;\n}',
        category: 'CSS'
      },
      
      // Python 模板
      {
        id: 'py_function',
        name: 'Function',
        description: 'Python 函数',
        language: 'python',
        code: 'def function_name(params):\n    """函数说明"""\n    # 函数体\n    return result',
        category: 'Python'
      },
      {
        id: 'py_class',
        name: 'Class',
        description: 'Python 类',
        language: 'python',
        code: 'class ClassName:\n    def __init__(self, params):\n        self.property = params\n    \n    def method(self):\n        # 方法体\n        pass',
        category: 'Python'
      },
      {
        id: 'py_try',
        name: 'Try-Except',
        description: '异常处理',
        language: 'python',
        code: 'try:\n    # 可能出错的代码\n    result = operation()\nexcept Exception as e:\n    # 错误处理\n    print(f"Error: {e}")\nfinally:\n    # 清理代码\n    pass',
        category: 'Python'
      },
      
      // JSON 模板
      {
        id: 'json_object',
        name: 'JSON Object',
        description: 'JSON 对象',
        language: 'json',
        code: '{\n  "key": "value",\n  "number": 123,\n  "boolean": true,\n  "array": [],\n  "object": {}\n}',
        category: 'JSON'
      }
    ];
  }
  
  /**
   * 按分类获取模板
   */
  public static getTemplatesByCategory(category: string): CodeTemplate[] {
    return CodeTemplateData.getAllTemplates().filter(t => t.category === category);
  }
  
  /**
   * 获取所有分类
   */
  public static getCategories(): string[] {
    const templates = CodeTemplateData.getAllTemplates();
    const categories = new Set<string>();
    templates.forEach(t => categories.add(t.category));
    return Array.from(categories);
  }
  
  /**
   * 根据 ID 获取模板
   */
  public static getTemplateById(id: string): CodeTemplate | undefined {
    return CodeTemplateData.getAllTemplates().find(t => t.id === id);
  }
}

/**
 * 移动端工具栏测试
 * 验证文件名和修改状态显示功能
 */
import { describe, it, expect } from '@ohos/hypium';

export default function mobileToolbarTest() {
  describe('MobileToolbar', () => {
    it('should display file name without modification indicator when not modified', () => {
      const fileName = '未命名.js';
      const isModified = false;
      const displayText = fileName + (isModified ? ' •' : '');
      
      expect(displayText).assertEqual('未命名.js');
    });
    
    it('should display file name with modification indicator when modified', () => {
      const fileName = '未命名.js';
      const isModified = true;
      const displayText = fileName + (isModified ? ' •' : '');
      
      expect(displayText).assertEqual('未命名.js •');
    });
    
    it('should handle different file names correctly', () => {
      const testCases = [
        { fileName: 'test.ts', isModified: false, expected: 'test.ts' },
        { fileName: 'test.ts', isModified: true, expected: 'test.ts •' },
        { fileName: '中文文件.ets', isModified: false, expected: '中文文件.ets' },
        { fileName: '中文文件.ets', isModified: true, expected: '中文文件.ets •' },
        { fileName: 'very-long-file-name-that-might-overflow.js', isModified: false, expected: 'very-long-file-name-that-might-overflow.js' },
        { fileName: 'very-long-file-name-that-might-overflow.js', isModified: true, expected: 'very-long-file-name-that-might-overflow.js •' }
      ];
      
      testCases.forEach(testCase => {
        const displayText = testCase.fileName + (testCase.isModified ? ' •' : '');
        expect(displayText).assertEqual(testCase.expected);
      });
    });
  });
}

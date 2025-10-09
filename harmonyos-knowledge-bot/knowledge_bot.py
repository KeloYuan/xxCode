#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HarmonyOS 知识库自动化学习机器人

功能：
1. 自动搜索和爬取 HarmonyOS 开发资料
2. 提取关键信息和代码示例
3. 生成 Markdown 格式的知识文档
4. 自动更新知识库索引
"""

import os
import sys
import json
import time
import random
import argparse
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional

import requests
from bs4 import BeautifulSoup
import jieba
from colorama import Fore, Style, init
from loguru import logger

# 初始化
init(autoreset=True)

class HarmonyOSKnowledgeBot:
    """HarmonyOS 知识库自动化学习机器人"""
    
    def __init__(self, config_path: str = "config.json"):
        """初始化机器人"""
        self.config = self.load_config(config_path)
        self.setup_logger()
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': self.config['crawl_settings']['user_agent']
        })
        
        self.stats = {
            'searched': 0,
            'found': 0,
            'valid': 0,
            'duplicated': 0,
            'low_quality': 0,
            'new_docs': 0,
            'updated_docs': 0,
            'code_samples': 0
        }
    
    def load_config(self, config_path: str) -> dict:
        """加载配置文件"""
        with open(config_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def setup_logger(self):
        """设置日志"""
        logger.add(
            "logs/knowledge_bot_{time}.log",
            rotation="500 MB",
            retention="10 days",
            level="INFO"
        )
    
    def search_content(self, topic: str) -> List[Dict]:
        """搜索内容"""
        print(f"{Fore.CYAN}🔍 搜索主题: {topic}{Style.RESET_ALL}")
        logger.info(f"搜索主题: {topic}")
        
        results = []
        self.stats['searched'] += 1
        
        # 模拟搜索（实际应用中可以调用搜索 API）
        search_urls = [
            f"https://cn.bing.com/search?q={topic}+site:developer.harmonyos.com",
            f"https://cn.bing.com/search?q={topic}+site:gitee.com/harmonyos_samples",
            f"https://cn.bing.com/search?q={topic}+site:51cto.com",
        ]
        
        for url in search_urls:
            try:
                # 这里应该实现真正的搜索逻辑
                # 现在只是示例
                print(f"  {Fore.GREEN}✓ 搜索: {url[:50]}...{Style.RESET_ALL}")
            except Exception as e:
                logger.error(f"搜索失败: {e}")
        
        return results
    
    def crawl_url(self, url: str) -> Optional[Dict]:
        """爬取网页内容"""
        print(f"{Fore.YELLOW}📥 爬取: {url}{Style.RESET_ALL}")
        
        try:
            response = self.session.get(
                url,
                timeout=self.config['crawl_settings']['timeout']
            )
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'lxml')
            
            # 提取内容
            content = {
                'url': url,
                'title': self.extract_title(soup),
                'content': self.extract_content(soup),
                'code_samples': self.extract_code(soup),
                'timestamp': datetime.now().isoformat()
            }
            
            self.stats['found'] += 1
            return content
            
        except Exception as e:
            logger.error(f"爬取失败 {url}: {e}")
            return None
    
    def extract_title(self, soup: BeautifulSoup) -> str:
        """提取标题"""
        title_tag = soup.find('h1') or soup.find('title')
        return title_tag.get_text().strip() if title_tag else ""
    
    def extract_content(self, soup: BeautifulSoup) -> str:
        """提取正文内容"""
        # 移除脚本和样式
        for script in soup(["script", "style"]):
            script.decompose()
        
        # 提取文本
        text = soup.get_text()
        lines = (line.strip() for line in text.splitlines())
        chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
        text = '\n'.join(chunk for chunk in chunks if chunk)
        
        return text
    
    def extract_code(self, soup: BeautifulSoup) -> List[Dict]:
        """提取代码示例"""
        code_blocks = []
        
        for code_tag in soup.find_all(['code', 'pre']):
            code_text = code_tag.get_text().strip()
            if len(code_text) >= self.config['quality_settings']['min_code_lines']:
                code_blocks.append({
                    'code': code_text,
                    'language': self.detect_language(code_text)
                })
                self.stats['code_samples'] += 1
        
        return code_blocks
    
    def detect_language(self, code: str) -> str:
        """检测代码语言"""
        if '@Component' in code or '@Entry' in code:
            return 'typescript'
        elif 'import' in code and 'from' in code:
            return 'typescript'
        elif 'function' in code or 'const' in code:
            return 'javascript'
        else:
            return 'text'
    
    def analyze_quality(self, content: Dict) -> float:
        """分析内容质量"""
        score = 0.0
        
        # 标题质量
        if content['title']:
            score += 0.2
        
        # 内容长度
        if len(content['content']) >= self.config['quality_settings']['min_content_length']:
            score += 0.3
        
        # 代码示例
        if content['code_samples']:
            score += 0.3
        
        # 关键词匹配
        keywords_count = sum(
            1 for keyword in self.config['filter_keywords']
            if keyword in content['title'] or keyword in content['content']
        )
        score += min(keywords_count * 0.1, 0.2)
        
        return min(score, 1.0)
    
    def check_duplicate(self, content: Dict) -> bool:
        """检查是否重复"""
        # 简化的重复检测
        # 实际应用中可以使用更复杂的相似度算法
        output_dir = Path(self.config['output_dir'])
        
        for md_file in output_dir.glob('*.md'):
            if md_file.name.startswith('00-'):
                continue
            
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    existing_content = f.read()
                    if content['title'] in existing_content:
                        return True
            except:
                continue
        
        return False
    
    def generate_document(self, content: Dict) -> str:
        """生成 Markdown 文档"""
        print(f"{Fore.GREEN}📝 生成文档: {content['title']}{Style.RESET_ALL}")
        
        md_content = f"# {content['title']}\n\n"
        md_content += f"> 来源: {content['url']}\n"
        md_content += f"> 更新时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
        md_content += "## 概述\n\n"
        
        # 添加内容摘要
        summary = self.generate_summary(content['content'])
        md_content += f"{summary}\n\n"
        
        # 添加代码示例
        if content['code_samples']:
            md_content += "## 代码示例\n\n"
            for i, code in enumerate(content['code_samples'], 1):
                md_content += f"### 示例 {i}\n\n"
                md_content += f"```{code['language']}\n{code['code']}\n```\n\n"
        
        md_content += "## 详细内容\n\n"
        md_content += self.format_content(content['content'])
        
        return md_content
    
    def generate_summary(self, content: str, max_length: int = 200) -> str:
        """生成内容摘要"""
        # 简单的摘要生成（取前几句话）
        sentences = content.split('。')
        summary = ""
        for sentence in sentences:
            if len(summary) + len(sentence) < max_length:
                summary += sentence + '。'
            else:
                break
        return summary or content[:max_length] + "..."
    
    def format_content(self, content: str) -> str:
        """格式化内容"""
        # 基础格式化
        lines = content.split('\n')
        formatted = []
        
        for line in lines:
            line = line.strip()
            if line:
                # 检测是否是标题
                if any(keyword in line for keyword in ['一、', '二、', '三、', '1.', '2.', '3.']):
                    formatted.append(f"\n### {line}\n")
                else:
                    formatted.append(line)
        
        return '\n\n'.join(formatted)
    
    def save_document(self, content: Dict, md_content: str):
        """保存文档"""
        output_dir = Path(self.config['output_dir'])
        output_dir.mkdir(exist_ok=True)
        
        # 生成文件名
        timestamp = datetime.now().strftime('%Y%m%d')
        filename = self.generate_filename(content['title'])
        filepath = output_dir / f"{timestamp}-{filename}.md"
        
        # 保存文件
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(md_content)
        
        print(f"{Fore.GREEN}✅ 保存成功: {filepath}{Style.RESET_ALL}")
        logger.info(f"保存文档: {filepath}")
        self.stats['new_docs'] += 1
    
    def generate_filename(self, title: str) -> str:
        """生成文件名"""
        # 移除特殊字符，生成合法的文件名
        filename = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_'))
        filename = filename.replace(' ', '-').lower()[:50]
        return filename
    
    def update_index(self):
        """更新索引文件"""
        if not self.config['output_settings']['auto_update_index']:
            return
        
        print(f"{Fore.CYAN}📑 更新索引...{Style.RESET_ALL}")
        # 这里应该实现索引更新逻辑
        # 现在只是示例
        logger.info("索引已更新")
    
    def generate_report(self):
        """生成运行报告"""
        print(f"\n{Fore.CYAN}{'='*50}{Style.RESET_ALL}")
        print(f"{Fore.GREEN}📊 学习报告{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'='*50}{Style.RESET_ALL}")
        print(f"运行时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"搜索主题: {self.stats['searched']} 个")
        print(f"发现内容: {self.stats['found']} 条")
        print(f"有效内容: {self.stats['valid']} 条")
        print(f"重复内容: {self.stats['duplicated']} 条")
        print(f"低质量: {self.stats['low_quality']} 条")
        print(f"新增文档: {self.stats['new_docs']} 个")
        print(f"更新文档: {self.stats['updated_docs']} 个")
        print(f"代码示例: {self.stats['code_samples']} 个")
        print(f"{Fore.CYAN}{'='*50}{Style.RESET_ALL}\n")
    
    def run_search_mode(self, topic: Optional[str] = None):
        """运行搜索模式"""
        topics = [topic] if topic else self.config['search_topics']
        
        for topic in topics:
            results = self.search_content(topic)
            time.sleep(random.uniform(*self.config['crawl_settings']['delay_range']))
    
    def run_crawl_mode(self, url: str):
        """运行爬取模式"""
        content = self.crawl_url(url)
        
        if content:
            # 质量检测
            quality = self.analyze_quality(content)
            print(f"  质量评分: {quality:.2f}")
            
            if quality < self.config['quality_settings']['quality_threshold']:
                print(f"  {Fore.RED}✗ 质量不达标{Style.RESET_ALL}")
                self.stats['low_quality'] += 1
                return
            
            # 重复检测
            if self.check_duplicate(content):
                print(f"  {Fore.YELLOW}⚠ 内容重复{Style.RESET_ALL}")
                self.stats['duplicated'] += 1
                return
            
            # 生成并保存文档
            self.stats['valid'] += 1
            md_content = self.generate_document(content)
            self.save_document(content, md_content)
    
    def run_auto_mode(self):
        """运行自动模式"""
        print(f"{Fore.GREEN}🤖 启动自动学习模式...{Style.RESET_ALL}\n")
        
        # 搜索所有主题
        for topic in self.config['search_topics']:
            self.run_search_mode(topic)
            
            # 限制文档数量
            if self.stats['new_docs'] >= self.config['output_settings']['max_documents_per_run']:
                print(f"{Fore.YELLOW}⚠ 达到单次运行文档数量上限{Style.RESET_ALL}")
                break
        
        # 更新索引
        self.update_index()
        
        # 生成报告
        self.generate_report()


def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='HarmonyOS 知识库自动化学习机器人')
    parser.add_argument('--mode', choices=['search', 'crawl', 'auto', 'analyze'],
                        default='auto', help='运行模式')
    parser.add_argument('--topic', help='搜索主题')
    parser.add_argument('--url', help='要爬取的 URL')
    parser.add_argument('--repo', help='Gitee 仓库名')
    
    args = parser.parse_args()
    
    # 打印欢迎信息
    print(f"\n{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
    print(f"{Fore.GREEN}🤖 HarmonyOS 知识库自动化学习机器人{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'='*60}{Style.RESET_ALL}\n")
    
    # 创建机器人实例
    bot = HarmonyOSKnowledgeBot()
    
    # 根据模式运行
    if args.mode == 'search':
        bot.run_search_mode(args.topic)
    elif args.mode == 'crawl':
        if not args.url:
            print(f"{Fore.RED}错误: crawl 模式需要提供 --url 参数{Style.RESET_ALL}")
            return
        bot.run_crawl_mode(args.url)
    elif args.mode == 'auto':
        bot.run_auto_mode()
    elif args.mode == 'analyze':
        print(f"{Fore.YELLOW}分析模式开发中...{Style.RESET_ALL}")
    
    print(f"\n{Fore.GREEN}✅ 任务完成！{Style.RESET_ALL}\n")


if __name__ == '__main__':
    main()


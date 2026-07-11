import sys
import threading
import time
import logging
from flask import Flask, render_template, jsonify, request
import webview
from database import DatabaseManager

##
# @brief 全局数据库管理器实例
#
db_manager = DatabaseManager()

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

##
# @brief 创建Flask应用实例
#
app = Flask(__name__)

##
# @brief 首页路由处理函数
# @return 渲染后的HTML页面
#
def index():
    return render_template('index.html')

# ---------------- Categories API ----------------

##
# @brief 获取所有分类
#
def get_categories():
    categories = db_manager.get_all_categories()
    return jsonify(categories)

##
# @brief 添加分类
#
def add_category():
    data = request.json
    name = data.get('name')
    color = data.get('color', '#4a90e2')
    
    if not name:
        return jsonify({'error': 'Name is required'}), 400
        
    cat_id = db_manager.add_category(name, color)
    return jsonify({'id': cat_id, 'message': 'Category added'}), 201

##
# @brief 更新分类
#
def update_category(cat_id):
    data = request.json
    name = data.get('name')
    color = data.get('color')
    
    db_manager.update_category(cat_id, name, color)
    return jsonify({'message': 'Category updated'})

##
# @brief 删除分类
#
def delete_category(cat_id):
    db_manager.delete_category(cat_id)
    logging.info(f"Category {cat_id} deleted")
    return jsonify({'message': 'Category deleted'})

##
# @brief 删除所有分类
#
def delete_all_categories():
    db_manager.delete_all_categories()
    logging.info("All categories deleted")
    return jsonify({'message': 'All categories deleted'})

# ---------------- Tasks API ----------------

##
# @brief 获取所有任务
# @return JSON格式的所有任务列表
#
def get_tasks():
    tasks = db_manager.get_all_tasks()
    return jsonify(tasks)

##
# @brief 添加任务的API
# @details 从请求中获取JSON数据并添加到数据库
# @return JSON格式的操作结果
#
def add_task():
    data = request.json
    name = data.get('name')
    deadline = data.get('deadline')
    category_id = data.get('category_id')
    
    if not name or not deadline:
        return jsonify({'error': 'Missing required fields'}), 400
        
    task_id = db_manager.add_task(name, deadline, category_id)
    return jsonify({'id': task_id, 'message': 'Task added successfully'}), 201

##
# @brief 更新任务的API
# @param task_id 任务ID
# @return JSON格式的操作结果
#
def update_task(task_id):
    data = request.json
    name = data.get('name')
    deadline = data.get('deadline')
    category_id = data.get('category_id')
    completed = data.get('completed')
    
    db_manager.update_task(task_id, name, deadline, category_id, completed)
    return jsonify({'message': 'Task updated successfully'})

##
# @brief 删除任务的API
# @param task_id 任务ID
# @return JSON格式的操作结果
#
def delete_task(task_id):
    db_manager.delete_task(task_id)
    return jsonify({'message': 'Task deleted successfully'})

##
# @brief 删除所有已完成任务的API
# @return JSON格式的操作结果
#
def delete_completed_tasks():
    db_manager.delete_completed_tasks()
    return jsonify({'message': 'Completed tasks deleted successfully'})

# 注册路由（不使用装饰器）
app.add_url_rule('/', 'index', index)

# Categories Routes
app.add_url_rule('/api/categories', 'get_categories', get_categories, methods=['GET'])
app.add_url_rule('/api/categories', 'add_category', add_category, methods=['POST'])
app.add_url_rule('/api/categories/<int:cat_id>', 'update_category', update_category, methods=['PUT'])
app.add_url_rule('/api/categories/<int:cat_id>', 'delete_category', delete_category, methods=['DELETE'])
app.add_url_rule('/api/categories', 'delete_all_categories', delete_all_categories, methods=['DELETE'])

# Tasks Routes
app.add_url_rule('/api/tasks', 'get_tasks', get_tasks, methods=['GET'])
app.add_url_rule('/api/tasks', 'add_task', add_task, methods=['POST'])
app.add_url_rule('/api/tasks/completed', 'delete_completed_tasks', delete_completed_tasks, methods=['DELETE'])
app.add_url_rule('/api/tasks/<int:task_id>', 'update_task', update_task, methods=['PUT'])
app.add_url_rule('/api/tasks/<int:task_id>', 'delete_task', delete_task, methods=['DELETE'])

##
# @brief 启动Flask服务器的函数
# @details 在独立线程中运行
#
def start_server():
    app.run(host='127.0.0.1', port=5000, threaded=True)

##
# @brief 主程序入口
# @details 启动Flask服务器并初始化WebView
#
if __name__ == '__main__':
    # 启动Flask服务器线程
    t = threading.Thread(target=start_server)
    t.daemon = True
    t.start()
    
    # 等待服务器启动
    time.sleep(1)
    
    # 创建WebView窗口
    # 锁定比例 9:20 (e.g., 450x1000)
    # 注意：pywebview原生不支持强制锁定宽高比，这里设置初始大小和最小大小以尽量引导
    window = webview.create_window(
        'DDL out! - 待办事项可视化', 
        'http://127.0.0.1:5000', 
        width=450, 
        height=1000, 
        min_size=(360, 800),
        resizable=True
    )

    # 窗口缩放事件处理 - 强制维持 9:20 比例
    # 实现说明：直接拦截 WM_SIZING 需要底层 Win32 API 挂钩，在 Python pywebview 环境中极不稳定。
    # 此处采用响应式调整策略：当用户调整窗口导致比例偏离时，自动修正回 9:20。
    def on_resized(width, height):
        target_ratio = 0.45 # 9 / 20
        current_ratio = width / height
        
        # 允许 1% 的误差缓冲，防止死循环
        if abs(current_ratio - target_ratio) > 0.01:
            # 以高度为基准修正宽度
            new_width = int(height * target_ratio)
            # 只有差异显著时才调整
            if abs(new_width - width) > 2:
                window.resize(new_width, height)

    window.events.resized += on_resized
    
    # 注册窗口缩放事件监听（通过JS实现自适应比例的尝试较为困难，此处主要依靠初始设置）
    webview.start()

import unittest
import os
import sys
import json
import tempfile

# 添加父目录到路径以便导入
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, db_manager
from database import DatabaseManager

##
# @brief 后端单元测试类
#
class BackendTestCase(unittest.TestCase):
    
    ##
    # @brief 测试前置准备
    #
    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp()
        self.app = app.test_client()
        # 重新初始化数据库管理器使用临时数据库
        self.original_db_path = db_manager.db_path
        db_manager.db_path = self.db_path
        db_manager.init_db()

    ##
    # @brief 测试后置清理
    #
    def tearDown(self):
        os.close(self.db_fd)
        os.unlink(self.db_path)
        # 恢复原来的数据库路径
        db_manager.db_path = self.original_db_path

    ##
    # @brief 测试添加任务
    #
    def test_add_task(self):
        response = self.app.post('/api/tasks', 
            data=json.dumps({
                'name': 'Test Task',
                'deadline': '2025-12-31T23:59',
                'category': 'Test',
                'color': '#ff0000'
            }),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        data = json.loads(response.data)
        self.assertIn('id', data)

    ##
    # @brief 测试获取任务
    #
    def test_get_tasks(self):
        # 先添加一个任务
        self.app.post('/api/tasks', 
            data=json.dumps({
                'name': 'Task 1', 
                'deadline': '2025-01-01T12:00'
            }),
            content_type='application/json'
        )
        
        response = self.app.get('/api/tasks')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['name'], 'Task 1')

    ##
    # @brief 测试更新任务
    #
    def test_update_task(self):
        # 添加
        res = self.app.post('/api/tasks', 
            data=json.dumps({'name': 'Old Name', 'deadline': '2025-01-01'}),
            content_type='application/json'
        )
        task_id = json.loads(res.data)['id']
        
        # 更新
        response = self.app.put(f'/api/tasks/{task_id}',
            data=json.dumps({'name': 'New Name', 'deadline': '2025-01-01'}),
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 200)
        
        # 验证
        get_res = self.app.get('/api/tasks')
        data = json.loads(get_res.data)
        self.assertEqual(data[0]['name'], 'New Name')

    ##
    # @brief 测试删除任务
    #
    def test_delete_task(self):
        res = self.app.post('/api/tasks', 
            data=json.dumps({'name': 'To Delete', 'deadline': '2025-01-01'}),
            content_type='application/json'
        )
        task_id = json.loads(res.data)['id']
        
        response = self.app.delete(f'/api/tasks/{task_id}')
        self.assertEqual(response.status_code, 200)
        
        get_res = self.app.get('/api/tasks')
        data = json.loads(get_res.data)
        self.assertEqual(len(data), 0)

if __name__ == '__main__':
    unittest.main()

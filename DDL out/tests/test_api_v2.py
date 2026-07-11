import unittest
import os
import sys
import json
import tempfile

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, db_manager
from database import DatabaseManager

class ApiV2TestCase(unittest.TestCase):
    
    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp()
        self.app = app.test_client()
        self.original_db_path = db_manager.db_path
        db_manager.db_path = self.db_path
        db_manager.init_db()

    def tearDown(self):
        os.close(self.db_fd)
        os.unlink(self.db_path)
        db_manager.db_path = self.original_db_path

    def test_category_lifecycle(self):
        # 1. Create Category
        res = self.app.post('/api/categories', 
            data=json.dumps({'name': 'Work', 'color': '#ff0000'}),
            content_type='application/json'
        )
        self.assertEqual(res.status_code, 201)
        cat_id = json.loads(res.data)['id']
        
        # 2. Get Categories
        res = self.app.get('/api/categories')
        data = json.loads(res.data)
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['name'], 'Work')
        
        # 3. Update Category
        res = self.app.put(f'/api/categories/{cat_id}',
            data=json.dumps({'name': 'Life', 'color': '#00ff00'}),
            content_type='application/json'
        )
        self.assertEqual(res.status_code, 200)
        
        # 4. Verify Update
        res = self.app.get('/api/categories')
        data = json.loads(res.data)
        self.assertEqual(data[0]['name'], 'Life')
        self.assertEqual(data[0]['color'], '#00ff00')
        
        # 5. Delete Category
        res = self.app.delete(f'/api/categories/{cat_id}')
        self.assertEqual(res.status_code, 200)
        
        res = self.app.get('/api/categories')
        data = json.loads(res.data)
        self.assertEqual(len(data), 0)

    def test_task_with_category(self):
        # Create Category
        res = self.app.post('/api/categories', 
            data=json.dumps({'name': 'Dev', 'color': '#0000ff'}),
            content_type='application/json'
        )
        cat_id = json.loads(res.data)['id']
        
        # Create Task
        res = self.app.post('/api/tasks', 
            data=json.dumps({
                'name': 'Code Review',
                'deadline': '2025-12-31T12:00',
                'category_id': cat_id
            }),
            content_type='application/json'
        )
        self.assertEqual(res.status_code, 201)
        task_id = json.loads(res.data)['id']
        
        # Verify Task
        res = self.app.get('/api/tasks')
        data = json.loads(res.data)
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['category_id'], cat_id)
        
        # Delete Category (Cascade check)
        self.app.delete(f'/api/categories/{cat_id}')
        
        res = self.app.get('/api/tasks')
        data = json.loads(res.data)
        # Should be empty because of CASCADE delete
        self.assertEqual(len(data), 0)

if __name__ == '__main__':
    unittest.main()

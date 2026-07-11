import unittest
import json
import os
import sys
import shutil
import tempfile

# Add parent directory to path to import app and database
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, db_manager
from database import DatabaseManager

class TestPCFeatures(unittest.TestCase):
    def setUp(self):
        # Create a temporary database
        self.test_dir = tempfile.mkdtemp()
        self.db_path = os.path.join(self.test_dir, 'test_tasks.db')
        
        # Initialize DB
        self.db = DatabaseManager(self.db_path)
        self.db.init_db()
        
        # Mock the global db_manager in app
        # Note: In a real scenario, we'd use dependency injection or app config
        # Here we rely on the fact that app imports db_manager instance
        import app as app_module
        app_module.db_manager = self.db
        
        self.app = app.test_client()
        self.app.testing = True

    def tearDown(self):
        shutil.rmtree(self.test_dir)

    def test_task_completion_lifecycle(self):
        """Test creating a task, marking it complete, and verifying status."""
        # 1. Create Category
        res = self.app.post('/api/categories', json={'name': 'Work', 'color': '#000000'})
        cat_id = res.json['id']
        
        # 2. Create Task
        res = self.app.post('/api/tasks', json={
            'name': 'Test Task',
            'deadline': '2025-12-31T23:59',
            'category_id': cat_id
        })
        task_id = res.json['id']
        
        # 3. Verify initial state (completed=0)
        tasks = self.db.get_all_tasks()
        self.assertEqual(len(tasks), 1)
        self.assertEqual(tasks[0]['completed'], 0)
        
        # 4. Mark as completed
        res = self.app.put(f'/api/tasks/{task_id}', json={
            'name': 'Test Task',
            'deadline': '2025-12-31T23:59',
            'category_id': cat_id,
            'completed': 1
        })
        self.assertEqual(res.status_code, 200)
        
        # 5. Verify completed state
        tasks = self.db.get_all_tasks()
        self.assertEqual(tasks[0]['completed'], 1)
        
        # 6. Mark as uncompleted
        res = self.app.put(f'/api/tasks/{task_id}', json={
            'name': 'Test Task',
            'deadline': '2025-12-31T23:59',
            'category_id': cat_id,
            'completed': 0
        })
        
        # 7. Verify uncompleted state
        tasks = self.db.get_all_tasks()
        self.assertEqual(tasks[0]['completed'], 0)

    def test_batch_delete_completed(self):
        """Test deleting all completed tasks."""
        # 1. Create Category
        res = self.app.post('/api/categories', json={'name': 'Work', 'color': '#000000'})
        cat_id = res.json['id']
        
        # 2. Create 3 Tasks
        ids = []
        for i in range(3):
            res = self.app.post('/api/tasks', json={
                'name': f'Task {i}',
                'deadline': '2025-12-31T23:59',
                'category_id': cat_id
            })
            ids.append(res.json['id'])
            
        # 3. Mark Task 0 and Task 2 as completed
        self.app.put(f'/api/tasks/{ids[0]}', json={'name': 'Task 0', 'deadline': '...', 'category_id': cat_id, 'completed': 1})
        self.app.put(f'/api/tasks/{ids[2]}', json={'name': 'Task 2', 'deadline': '...', 'category_id': cat_id, 'completed': 1})
        
        # Verify before delete
        tasks = self.db.get_all_tasks()
        self.assertEqual(len(tasks), 3)
        completed_count = sum(1 for t in tasks if t['completed'] == 1)
        self.assertEqual(completed_count, 2)
        
        # 4. Batch Delete
        res = self.app.delete('/api/tasks/completed')
        self.assertEqual(res.status_code, 200)
        
        # 5. Verify after delete
        tasks = self.db.get_all_tasks()
        self.assertEqual(len(tasks), 1)
        self.assertEqual(tasks[0]['id'], ids[1]) # Only Task 1 remains
        self.assertEqual(tasks[0]['completed'], 0)

if __name__ == '__main__':
    unittest.main()
import sqlite3
import os

##
# @brief 数据库管理类
# @details 负责处理SQLite数据库的连接、初始化和CRUD操作
#
class DatabaseManager:
    ##
    # @brief 构造函数
    # @param db_path 数据库文件路径
    #
    def __init__(self, db_path='tasks.db'):
        self.db_path = db_path
        self.init_db()

    ##
    # @brief 获取数据库连接
    # @return sqlite3.Connection 数据库连接对象
    #
    def get_connection(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute("PRAGMA foreign_keys = ON")
        conn.row_factory = sqlite3.Row
        return conn

    ##
    # @brief 初始化数据库表
    # @details 创建categories和tasks表
    #
    def init_db(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        
        # 启用外键支持
        cursor.execute("PRAGMA foreign_keys = ON")
        
        # 创建分类表
        # id: 主键
        # name: 分类名称
        # color: 分类颜色
        sql_categories = '''
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color TEXT NOT NULL DEFAULT '#4a90e2'
        )
        '''
        cursor.execute(sql_categories)

        # 创建任务表
        # id: 主键
        # name: 任务名称
        # deadline: 截止时间
        # category_id: 所属分类ID (外键)
        # completed: 是否完成 (0: 未完成, 1: 已完成)
        sql_tasks = '''
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            deadline TEXT NOT NULL,
            category_id INTEGER,
            completed INTEGER DEFAULT 0,
            FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
        )
        '''
        cursor.execute(sql_tasks)
        
        # 检查是否需要迁移（如果tasks表有旧结构）
        cursor.execute("PRAGMA table_info(tasks)")
        columns = [column[1] for column in cursor.fetchall()]
        if 'completed' not in columns:
            cursor.execute("ALTER TABLE tasks ADD COLUMN completed INTEGER DEFAULT 0")
        
        conn.commit()
        conn.close()

    # ---------------- Categories CRUD ----------------

    ##
    # @brief 获取所有分类
    # @return list 分类列表
    #
    def get_all_categories(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM categories')
        rows = cursor.fetchall()
        categories = []
        for row in rows:
            categories.append(dict(row))
        conn.close()
        return categories

    ##
    # @brief 添加分类
    # @param name 名称
    # @param color 颜色
    # @return int ID
    #
    def add_category(self, name, color):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute('INSERT INTO categories (name, color) VALUES (?, ?)', (name, color))
        conn.commit()
        cat_id = cursor.lastrowid
        conn.close()
        return cat_id

    ##
    # @brief 更新分类
    # @param cat_id ID
    # @param name 名称
    # @param color 颜色
    #
    def update_category(self, cat_id, name, color):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute('UPDATE categories SET name = ?, color = ? WHERE id = ?', (name, color, cat_id))
        conn.commit()
        conn.close()

    ##
    # @brief 删除分类
    # @param cat_id ID
    #
    def delete_category(self, cat_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        # 由于开启了 ON DELETE CASCADE，关联的任务会自动删除
        cursor.execute('DELETE FROM categories WHERE id = ?', (cat_id,))
        conn.commit()
        conn.close()

    ##
    # @brief 删除所有分类
    #
    def delete_all_categories(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute('DELETE FROM categories')
        conn.commit()
        conn.close()

    # ---------------- Tasks CRUD ----------------

    ##
    # @brief 获取所有任务
    # @return list 任务列表
    #
    def get_all_tasks(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM tasks')
        rows = cursor.fetchall()
        tasks = []
        for row in rows:
            tasks.append(dict(row))
        conn.close()
        return tasks

    ##
    # @brief 添加新任务
    # @param name 任务名称
    # @param deadline 截止时间
    # @param category_id 分类ID
    # @return int 新任务的ID
    #
    def add_task(self, name, deadline, category_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        sql = 'INSERT INTO tasks (name, deadline, category_id) VALUES (?, ?, ?)'
        cursor.execute(sql, (name, deadline, category_id))
        conn.commit()
        task_id = cursor.lastrowid
        conn.close()
        return task_id

    ##
    # @brief 更新任务
    # @param task_id 任务ID
    # @param name 任务名称
    # @param deadline 截止时间
    # @param category_id 分类ID
    # @param completed 是否完成 (0或1, 可选)
    #
    def update_task(self, task_id, name, deadline, category_id, completed=None):
        conn = self.get_connection()
        cursor = conn.cursor()
        if completed is not None:
            sql = 'UPDATE tasks SET name = ?, deadline = ?, category_id = ?, completed = ? WHERE id = ?'
            cursor.execute(sql, (name, deadline, category_id, completed, task_id))
        else:
            sql = 'UPDATE tasks SET name = ?, deadline = ?, category_id = ? WHERE id = ?'
            cursor.execute(sql, (name, deadline, category_id, task_id))
        conn.commit()
        conn.close()

    ##
    # @brief 删除任务
    # @param task_id 任务ID
    #
    def delete_task(self, task_id):
        conn = self.get_connection()
        cursor = conn.cursor()
        sql = 'DELETE FROM tasks WHERE id = ?'
        cursor.execute(sql, (task_id,))
        conn.commit()
        conn.close()

    ##
    # @brief 删除所有已完成任务
    #
    def delete_completed_tasks(self):
        conn = self.get_connection()
        cursor = conn.cursor()
        sql = 'DELETE FROM tasks WHERE completed = 1'
        cursor.execute(sql)
        conn.commit()
        conn.close()

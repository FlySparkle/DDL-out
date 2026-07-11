import time
import sys
import os
import random
import datetime

# 添加父目录到路径
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import DatabaseManager

##
# @brief 压力测试脚本
# @details 测试100个事项时的性能
#
def stress_test():
    print("开始压力测试 (100个事项)...")
    
    # 使用测试数据库
    test_db = 'stress_test.db'
    if os.path.exists(test_db):
        os.remove(test_db)
        
    db = DatabaseManager(test_db)
    
    # 1. 批量插入测试
    start_time = time.time()
    for i in range(100):
        name = f"Task {i}"
        # 随机生成未来72小时内的时间
        hours = random.randint(0, 100)
        deadline = (datetime.datetime.now() + datetime.timedelta(hours=hours)).isoformat()
        category = "Work" if i % 2 == 0 else "Life"
        color = "#ff0000"
        db.add_task(name, deadline, category, color)
    
    end_time = time.time()
    insert_duration = end_time - start_time
    print(f"插入100个任务耗时: {insert_duration:.4f} 秒")
    
    # 2. 读取测试
    start_time = time.time()
    tasks = db.get_all_tasks()
    end_time = time.time()
    read_duration = end_time - start_time
    print(f"读取100个任务耗时: {read_duration:.4f} 秒")
    print(f"读取到的任务数量: {len(tasks)}")
    
    # 清理
    db.get_connection().close()
    os.remove(test_db)
    
    # 判定标准
    if insert_duration < 1.0 and read_duration < 0.1:
        print("压力测试通过！性能符合要求。")
    else:
        print("警告：性能可能存在瓶颈。")

if __name__ == '__main__':
    stress_test()

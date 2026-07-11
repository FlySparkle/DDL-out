# Python Flask 全栈开发实战教程：从零构建待办事项系统

**版本**: 1.1
**适用对象**: Python 初学者、Web 开发入门者
**基于项目**: DDL out! 待办事项管理系统
**字数**: > 5000 字

---

## 目录

1.  [前言](#1-前言)
2.  [第一部分：项目实现结构深度剖析](#2-第一部分项目实现结构深度剖析)
    *   2.1 根目录与文件架构
    *   2.2 核心模块职责详解
    *   2.3 依赖关系与调用链路
    *   2.4 项目启动全流程解析
3.  [第二部分：Flask 框架权威指南](#3-第二部分flask-框架权威指南)
    *   3.1 开发环境从零搭建
    *   3.2 Flask 核心组件剖析
        *   路由 (Routing)
        *   请求处理 (Request)
        *   模板渲染 (Templates)
        *   静态文件 (Static Files)
        *   蓝图 (Blueprints)
        *   中间件 (Middleware)
        *   错误处理 (Error Handling)
    *   3.3 最小化 Flask 应用示例
    *   3.4 开发服务器与调试技巧
    *   3.5 生产环境部署方案
4.  [第三部分：Python 核心特性与语法精讲](#4-第三部分python-核心特性与语法精讲)
    *   4.1 函数定义 (`def`)
    *   4.2 面向对象 (`class`)
    *   4.3 模块导入 (`import/from`)
    *   4.4 入口判断 (`if __name__ == "__main__"`)
    *   4.5 异常捕获 (`try/except`)
    *   4.6 上下文管理 (`with`)
    *   4.7 生成器 (`yield`)
    *   4.8 匿名函数 (`lambda`)
    *   4.9 装饰器 (`Decorators`)
    *   4.10 列表推导式 (`List Comprehensions`)
    *   4.11 字典推导式 (`Dict Comprehensions`)
    *   4.12 可变参数 (`*args/**kwargs`)
    *   4.13 类型标注 (`Type Hinting`)
    *   4.14 异步编程 (`async/await`)
5.  [第四部分：新手学习路径规划](#5-第四部分新手学习路径规划)

---

## 1. 前言

本教程旨在通过解构「DDL out!」项目，为 Python 初学者提供一份详尽的实战指南。不同于枯燥的语法手册，我们将每一个知识点都锚定在实际的工程代码中，让你明白“为什么要这样写”以及“如何在实际项目中运用”。

---

## 2. 第一部分：项目实现结构深度剖析

一个优秀的软件项目，其目录结构应当是自解释的。良好的结构能降低维护成本，提升团队协作效率。

### 2.1 根目录与文件架构

```text
DDL out/
├── .trae/                  # [IDE配置] Trae IDE 的特定配置文件
├── __pycache__/            # [缓存] Python 编译后的字节码文件 (.pyc)，加快加载速度，无需手动管理
├── docs/                   # [文档] 项目文档目录
│   ├── TEST_REPORT.md      # 测试验收报告
│   ├── UI_UX_REPORT.md     # 交互优化报告
│   └── USER_MANUAL.md      # 用户使用手册
├── static/                 # [前端] 静态资源目录（Flask 默认配置）
│   ├── css/
│   │   └── style.css       # 样式表：负责页面的布局、颜色、动画
│   └── js/
│       └── script.js       # 脚本：负责前端逻辑、API 调用、DOM 操作
├── templates/              # [前端] HTML 模板目录（Flask 默认配置）
│   └── index.html          # 主页 HTML 文件，作为单页应用 (SPA) 的载体
├── tests/                  # [测试] 测试代码目录
│   ├── stress_test.py      # 压力测试脚本
│   ├── test_api_v2.py      # API 接口测试
│   └── test_backend.py     # 后端逻辑测试
├── app.py                  # [核心] Flask 应用入口，控制器层 (Controller)
├── database.py             # [核心] 数据库管理类，模型层 (Model)
├── tasks.db                # [数据] SQLite 数据库文件（运行时自动生成）
├── requirements.txt        # [依赖] 项目所需的 Python 第三方库列表
└── README.md               # [文档] 项目说明文件
```

### 2.2 核心模块职责详解

#### `app.py` - 指挥官 (Controller)
这是整个应用程序的**入口点**。它的主要职责包括：
1.  **Web 服务器**：初始化 `Flask` 应用实例。
2.  **路由分发**：定义 URL（如 `/api/tasks`）与 Python 函数（如 `get_tasks`）之间的映射关系。
3.  **API 响应**：接收前端请求，调用 `database.py` 处理数据，并将结果封装为 JSON 格式返回。
4.  **桌面容器**：使用 `pywebview` 启动一个原生窗口来加载 Web 页面，使 Web 应用变身为桌面软件。
5.  **多线程**：在一个独立线程中运行 Flask 服务器，以避免阻塞 UI 线程（Webview）。

#### `database.py` - 数据管家 (Model)
这是**数据持久化层**。它封装了所有 SQL 操作，使上层业务逻辑不需要直接编写 SQL 语句。
1.  **连接管理**：负责建立和关闭与 `tasks.db` 的连接。
2.  **表结构定义**：在 `init_db` 方法中定义了 `tasks` 和 `categories` 表的 Schema。
3.  **CRUD 操作**：提供了 `add_task`, `delete_task`, `update_task` 等原子方法。

#### `static/` & `templates/` - 视觉呈现 (View)
这是标准的 Flask 前端结构。
1.  **Templates**：存放 HTML 文件。Flask 使用 Jinja2 模板引擎，虽然本项目主要是单页应用（SPA），仅用 `index.html` 作为容器，但理解模板目录是 Flask 开发的基础。
2.  **Static**：存放 CSS、JS、图片等资源。Flask 会自动为该目录下的文件提供路由服务（如 `/static/css/style.css`）。

### 2.3 依赖关系与调用链路

```mermaid
graph TD
    User[用户] -->|点击/输入| UI[PyWebview 窗口 / 浏览器];
    UI -->|AJAX/Fetch| Flask[Flask Web Server (app.py)];
    Flask -->|路由匹配| ViewFunc[视图函数 (e.g., get_tasks)];
    ViewFunc -->|方法调用| DBManager[DatabaseManager (database.py)];
    DBManager -->|SQL 执行| SQLite[(tasks.db)];
    SQLite -->|数据返回| DBManager;
    DBManager -->|对象列表| ViewFunc;
    ViewFunc -->|JSON 序列化| Flask;
    Flask -->|HTTP 响应| UI;
    UI -->|DOM 更新| User;
```

### 2.4 项目启动全流程解析

当你在终端输入 `python app.py` 时，发生了什么？

1.  **导入阶段**：Python 解释器加载 `flask`, `webview`, `sqlite3` 等模块。
2.  **实例化阶段**：
    *   `db_manager = DatabaseManager()` 被创建。
    *   `__init__` 方法被调用，检查 `tasks.db` 是否存在，不存在则自动创建表结构。
    *   `app = Flask(__name__)` 创建 Web 应用实例。
3.  **路由注册**：`app.add_url_rule(...)` 将 URL 路径注册到 Flask 内部的路由表中。
4.  **主程序执行** (`if __name__ == '__main__':`)：
    *   **启动服务器线程**：创建一个新线程运行 `start_server()`，进而调用 `app.run()` 启动 HTTP 服务，监听 5000 端口。
    *   **启动 Webview**：主线程执行 `webview.create_window(...)`，弹出一个原生窗口，加载 `http://127.0.0.1:5000`。
    *   **进入事件循环**：`webview.start()` 阻塞主线程，等待用户操作，直到窗口关闭。

---

## 3. 第二部分：Flask 框架权威指南

Flask 是 Python 最流行的微框架之一，核心设计理念是“保持核心简单，扩展功能通过插件实现”。

### 3.1 开发环境从零搭建

#### 3.1.1 检查 Python 版本
Flask 3.x 支持 Python 3.8 及以上版本。
```bash
python --version
# 输出: Python 3.12.x (示例)
```

#### 3.1.2 创建虚拟环境 (Virtual Environment)
**为什么需要？** 不同项目可能依赖同一个库的不同版本。虚拟环境能将它们隔离开。

*   **Windows**:
    ```powershell
    python -m venv venv
    .\venv\Scripts\activate
    ```
*   **macOS / Linux**:
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```
激活成功后，命令行提示符前会出现 `(venv)` 标识。

#### 3.1.3 安装依赖
使用 `pip` 安装 `requirements.txt` 中的库。
```bash
pip install -r requirements.txt
```
本项目核心依赖：`Flask` (Web框架), `pywebview` (桌面封装).

### 3.2 Flask 核心组件剖析

#### 3.2.1 路由 (Routing)
路由是将 URL 映射到 Python 函数的机制。

**本项目写法 (`add_url_rule`)**:
```python
# 显式注册，适合大型项目统一管理或动态注册
app.add_url_rule('/api/tasks', 'get_tasks', get_tasks, methods=['GET'])
```

**装饰器写法 (常见写法)**:
```python
@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    ...
```

**动态路由**:
在 `app.py` 中：
```python
app.add_url_rule('/api/tasks/<int:task_id>', ...)
```
`<int:task_id>` 是一个转换器，它会捕获 URL 中的数字部分（如 `/api/tasks/42`），并将其作为 `task_id=42` 参数传递给视图函数。

#### 3.2.2 请求处理 (Request)
`from flask import request` 是一个全局对象，但在每个请求上下文中是独立的（线程安全）。

*   **`request.json`**: 获取 Content-Type 为 `application/json` 的 POST/PUT 数据（本项目主要使用）。
*   **`request.args`**: 获取 URL 查询参数（如 `?key=value`）。
*   **`request.form`**: 获取表单提交的数据（Content-Type 为 `application/x-www-form-urlencoded`）。
*   **`request.method`**: 获取当前请求的方法（GET, POST...）。

#### 3.2.3 模板渲染 (Templates)
Flask 使用 Jinja2 模板引擎。虽然本项目主要返回 JSON，但了解模板很重要。

```python
# app.py
def index():
    # 渲染 templates/index.html，并可传递变量
    return render_template('index.html', title="DDL out!")
```

**Jinja2 语法示例**:
```html
<!-- 在 HTML 中 -->
<h1>{{ title }}</h1>
<ul>
    {% for task in tasks %}
        <li>{{ task.name }}</li>
    {% endfor %}
</ul>
```

#### 3.2.4 静态文件 (Static Files)
Flask 自动为 `static` 文件夹创建路由。
*   URL: `/static/css/style.css`
*   文件路径: `static/css/style.css`

#### 3.2.5 蓝图 (Blueprints)
**本项目暂未使用，但推荐了解**。随着项目变大，所有路由都写在 `app.py` 会很乱。蓝图用于将应用分割成多个模块。

**示例**:
```python
# auth.py
from flask import Blueprint
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login')
def login():
    return "Login Page"

# app.py
from auth import auth_bp
app.register_blueprint(auth_bp, url_prefix='/auth')
```
这样访问 `/auth/login` 就会触发 `login` 函数。

#### 3.2.6 中间件 (Middleware)
中间件是在请求到达视图函数之前或响应发送给客户端之前执行的代码。

**常见用途**: 身份验证、日志记录。
```python
@app.before_request
def check_login():
    if request.endpoint != 'login' and not is_logged_in():
        return "Unauthorized", 401
```

#### 3.2.7 错误处理 (Error Handling)
Flask 允许你自定义错误页面。
```python
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_server_error(e):
    return jsonify({"error": "Internal Server Error"}), 500
```

### 3.3 最小化 Flask 应用示例

将以下代码保存为 `hello.py` 并运行。

```python
# 1. 导入 Flask 类
from flask import Flask, jsonify

# 2. 实例化应用
app = Flask(__name__)

# 3. 定义根路由
@app.route('/')
def home():
    return "<h1>Hello, Flask!</h1>"

# 4. 定义一个带参数的 API
@app.route('/hello/<name>')
def greet(name):
    return jsonify({"message": f"Hello, {name}!"})

# 5. 启动服务
if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### 3.4 开发服务器与调试技巧

*   **Debug 模式**: `app.run(debug=True)`。
    *   **热重载**: 修改代码后自动重启。
    *   **交互式调试器**: 报错时可在浏览器直接执行 Python 代码检查变量。
*   **VS Code 调试**:
    1.  点击左侧“运行与调试”。
    2.  创建 `launch.json`，选择 "Flask"。
    3.  设置断点，F5 启动。

### 3.5 生产环境部署方案

**切记：永远不要在生产环境使用 `app.run()`。**

#### 3.5.1 WSGI 服务器 (Waitress/Gunicorn)
Flask 自带的服务器是单线程的，无法处理高并发。

*   **Windows (Waitress)**:
    ```bash
    pip install waitress
    waitress-serve --port=8080 app:app
    ```
*   **Linux (Gunicorn)**:
    ```bash
    pip install gunicorn
    gunicorn -w 4 -b 0.0.0.0:8000 app:app
    ```

#### 3.5.2 Nginx 反向代理
Nginx 负责处理静态文件、SSL 加密和负载均衡，将动态请求转发给 WSGI 服务器。

**Nginx 配置示例**:
```nginx
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /static {
        alias /path/to/your/project/static;
    }
}
```

---

## 4. 第三部分：Python 核心特性与语法精讲

本章节深入剖析 Python 中最常用且在本项目中出现的关键字。每个关键字包含定义、用法、易错点及 3 道练习题。

### 4.1 函数定义 (`def`)

**定义**: 用于封装一段可重复使用的代码逻辑。

**基础语法**:
```python
def function_name(param1, param2=default_value):
    """Docstring"""
    # body
    return result
```

**项目实战**: `app.py` 中 `def get_tasks():` 定义了获取任务的逻辑。

**易错点**:
*   **可变默认参数**: `def func(a=[])` 是危险的，因为默认列表在函数定义时创建一次，多次调用会共享同一个列表。
    *   *修正*: `def func(a=None): if a is None: a = []`

**练习题**:
1.  **入门**: 编写函数 `is_even(n)`，判断数字是否为偶数，返回布尔值。
2.  **进阶**: 编写函数 `count_vowels(s)`，统计字符串中元音字母(a,e,i,o,u)的个数。
3.  **挑战**: 编写函数 `merge_lists(l1, l2)`，将两个有序列表合并为一个新的有序列表（不使用 `sort`）。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 1
def is_even(n):
    return n % 2 == 0

# 2
def count_vowels(s):
    return sum(1 for char in s.lower() if char in 'aeiou')

# 3
def merge_lists(l1, l2):
    res = []
    i = j = 0
    while i < len(l1) and j < len(l2):
        if l1[i] < l2[j]:
            res.append(l1[i])
            i += 1
        else:
            res.append(l2[j])
            j += 1
    res.extend(l1[i:])
    res.extend(l2[j:])
    return res
```
</details>

### 4.2 面向对象 (`class`)

**定义**: 定义对象的属性和行为的模板。

**项目实战**: `database.py` 中的 `class DatabaseManager:` 封装了所有数据库操作。

**易错点**:
*   忘记 `self`: 在类的方法中，访问实例属性必须用 `self.variable`，否则会被视为局部变量。

**练习题**:
1.  **入门**: 定义 `Person` 类，有 `name` 和 `age` 属性，以及 `introduce()` 方法打印 "Hi, I am [name]".
2.  **进阶**: 定义 `BankAccount` 类，支持 `deposit(amount)` 和 `withdraw(amount)`，余额不足时 `withdraw` 应提示错误。
3.  **挑战**: 继承 `BankAccount` 创建 `SavingsAccount`，添加 `add_interest(rate)` 方法计算利息。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 1
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    def introduce(self):
        print(f"Hi, I am {self.name}")

# 2
class BankAccount:
    def __init__(self):
        self.balance = 0
    def deposit(self, amount):
        self.balance += amount
    def withdraw(self, amount):
        if self.balance >= amount:
            self.balance -= amount
        else:
            print("Insufficient funds")

# 3
class SavingsAccount(BankAccount):
    def add_interest(self, rate):
        self.balance *= (1 + rate)
```
</details>

### 4.3 模块导入 (`import/from`)

**定义**: 引入外部库或自定义模块。

**项目实战**: `app.py` 中 `from database import DatabaseManager`。

**易错点**:
*   **循环导入**: A 导入 B，B 导入 A。解决方法是重构代码，或将导入语句移到函数内部。

**练习题**:
1.  **入门**: 导入 `math` 模块并计算 25 的平方根。
2.  **进阶**: 创建 `utils.py` 定义一个函数，在 `main.py` 中导入并使用。
3.  **挑战**: 尝试导入一个不存在的模块，并用 `try/except` 捕获 `ImportError`，提示“请先安装依赖”。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 1
import math
print(math.sqrt(25))

# 3
try:
    import pandas
except ImportError:
    print("Please install pandas")
```
</details>

### 4.4 入口判断 (`if __name__ == "__main__"`)

**定义**: 确保代码块仅在脚本被直接运行时执行，而在被导入时不执行。

**项目实战**: `app.py` 末尾，用于启动 Flask 服务器。

**易错点**:
*   拼写错误：`__name__` 和 `__main__` 都有双下划线。

**练习题**:
1.  **入门**: 编写一个脚本，直接运行打印 "Running directly"，被导入时打印 "Imported"。
2.  **进阶**: 解释为什么 Flask 应用通常需要这行代码？(答案：防止被 WSGI 服务器导入时重复启动)。
3.  **挑战**: 编写两个文件 A.py 和 B.py，A 导入 B，观察输出顺序。

### 4.5 异常捕获 (`try/except`)

**定义**: 处理运行时错误，防止程序崩溃。

**项目实战**: `app.py` 窗口缩放逻辑中使用了 `try...except`。

**易错点**:
*   **捕获过于宽泛**: 使用 `except Exception:` 或裸 `except:` 会掩盖真正的 bug（如拼写错误）。应尽量捕获特定异常（如 `ValueError`）。

**练习题**:
1.  **入门**: 处理除以零的异常 `10 / 0`。
2.  **进阶**: 接收用户输入转为整数，如果输入非数字，提示“请输入数字”并让用户重试，直到成功。
3.  **挑战**: 模拟文件读取，同时处理 `FileNotFoundError` 和 `PermissionError`。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 2
while True:
    try:
        val = int(input("Enter number: "))
        break
    except ValueError:
        print("Invalid number")
```
</details>

### 4.6 上下文管理 (`with`)

**定义**: 自动管理资源的分配与释放（如文件关闭、锁释放）。

**项目实战**: `with sqlite3.connect(...)` (推荐写法)。

**易错点**:
*   误以为 `with` 可以处理所有对象，只有实现了 `__enter__` 和 `__exit__` 的对象才支持。

**练习题**:
1.  **入门**: 使用 `with` 写入文件 "hello.txt"。
2.  **进阶**: 使用 `with` 读取文件并打印每一行。
3.  **挑战**: 自定义一个上下文管理器 `Timer`，统计代码块的执行时间。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 3
import time
class Timer:
    def __enter__(self):
        self.start = time.time()
    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"Time: {time.time() - self.start}")

with Timer():
    time.sleep(1)
```
</details>

### 4.7 生成器 (`yield`)

**定义**: `yield` 使函数变为生成器，一次返回一个值，节省内存。

**项目实战**: 本项目虽未直接使用，但在处理大量数据流（如导出大文件）时非常有用。

**易错点**:
*   生成器只能遍历一次，遍历完后需要重新生成。

**练习题**:
1.  **入门**: 编写生成器 `countdown(n)`，从 n 数到 0。
2.  **进阶**: 编写生成器 `fibonacci(n)`，生成前 n 个斐波那契数。
3.  **挑战**: 实现一个读取超大文件的生成器，每次读取一行，不占用大量内存。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 2
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b
```
</details>

### 4.8 匿名函数 (`lambda`)

**定义**: 单行的小函数，通常用于临时使用。

**语法**: `lambda arguments: expression`

**练习题**:
1.  **入门**: 编写 lambda 计算两个数的和。
2.  **进阶**: 使用 lambda 对字典列表 `[{'name': 'a', 'age': 10}, ...]` 按 age 排序。
3.  **挑战**: 结合 `map` 和 lambda，将列表 `[1, 2, 3]` 中的每个数平方。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 2
data = [{'name': 'a', 'age': 20}, {'name': 'b', 'age': 10}]
data.sort(key=lambda x: x['age'])

# 3
list(map(lambda x: x**2, [1, 2, 3]))
```
</details>

### 4.9 装饰器 (`Decorators`)

**定义**: 在不修改原函数代码的情况下，增加额外功能。

**项目实战**: `@app.route` (Flask 路由注册的语法糖)。

**练习题**:
1.  **入门**: 编写装饰器 `@log`，在函数执行前打印 "Start"。
2.  **进阶**: 编写装饰器 `@timer`，计算函数执行时间。
3.  **挑战**: 编写带参数的装饰器 `@repeat(n)`，让函数执行 n 次。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 3
def repeat(n):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(n):
                func(*args, **kwargs)
        return wrapper
    return decorator

@repeat(3)
def say_hi():
    print("Hi")
```
</details>

### 4.10 列表推导式 (`List Comprehensions`)

**定义**: 构建列表的简洁方式。

**项目实战**: `database.py` 中 `columns = [column[1] for column in cursor.fetchall()]`。

**练习题**:
1.  **入门**: 生成 `[0, 2, 4, ..., 18]`。
2.  **进阶**: 将字符串列表 `['a', 'b', 'c']` 转换为大写。
3.  **挑战**: 找出 1-100 中能被 3 整除但不能被 5 整除的数。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 3
[x for x in range(1, 101) if x % 3 == 0 and x % 5 != 0]
```
</details>

### 4.11 字典推导式 (`Dict Comprehensions`)

**定义**: 构建字典的简洁方式。

**练习题**:
1.  **入门**: 将列表 `['a', 'b']` 转为字典 `{'a': 0, 'b': 0}`。
2.  **进阶**: 交换字典 `{'a': 1, 'b': 2}` 的键和值。
3.  **挑战**: 将两个列表 `keys=['name', 'age']` 和 `values=['Tom', 20]` 组合成字典。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 2
d = {'a': 1, 'b': 2}
{v: k for k, v in d.items()}

# 3
{k: v for k, v in zip(keys, values)}
```
</details>

### 4.12 可变参数 (`*args/**kwargs`)

**定义**: 接收不定数量的参数。`*args` 是元组，`**kwargs` 是字典。

**练习题**:
1.  **入门**: 编写函数 `sum_all(*args)`，计算所有传入数字的和。
2.  **进阶**: 编写函数 `print_info(**kwargs)`，打印所有键值对。
3.  **挑战**: 编写包装函数，接受任意参数并传递给另一个函数。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 1
def sum_all(*args):
    return sum(args)

# 3
def wrapper(func, *args, **kwargs):
    print("Calling function...")
    return func(*args, **kwargs)
```
</details>

### 4.13 类型标注 (`Type Hinting`)

**定义**: 静态类型检查辅助。

**练习题**:
1.  **入门**: 为 `def add(a, b): return a + b` 添加 int 类型标注。
2.  **进阶**: 标注一个接收字符串列表并返回字典的函数。
3.  **挑战**: 使用 `Optional` 标注一个可能返回 `None` 的函数。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 2
from typing import List, Dict
def process(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}
```
</details>

### 4.14 异步编程 (`async/await`)

**定义**: 并发执行 I/O 密集型任务。

**练习题**:
1.  **入门**: 定义一个异步函数 `say_hello`，等待 1 秒后打印。
2.  **进阶**: 使用 `asyncio.gather` 并发运行两个异步函数。
3.  **挑战**: 编写异步 HTTP 请求（使用 `httpx` 或 `aiohttp` 概念）。

**参考答案**:
<details>
<summary>点击查看答案</summary>

```python
# 2
import asyncio
async def task(n):
    await asyncio.sleep(1)
    print(n)

async def main():
    await asyncio.gather(task(1), task(2))
# asyncio.run(main())
```
</details>

---

## 5. 第四部分：新手学习路径规划

基于本项目，我们为您制定了为期两周的学习计划。

### 第一阶段：基础夯实 (Week 1)

*   **Day 1: 环境与语法**
    *   任务：安装 Python 3.12 和 VS Code/Trae。配置虚拟环境。
    *   学习：变量、数据类型、流程控制。
    *   实战：编写“猜数字”小游戏。
*   **Day 2: 数据结构**
    *   学习：List, Dict, Set。
    *   重点：字典的键值对操作，JSON 结构理解。
    *   实战：统计一段文本的词频。
*   **Day 3: 函数与模块**
    *   学习：`def`, `import`。
    *   实战：将 Day 1 的游戏重构为函数。
*   **Day 4: 面向对象 (OOP)**
    *   学习：Class, `__init__`, Self。
    *   实战：设计一个简单的“学生管理系统”类。
*   **Day 5: 数据库基础**
    *   学习：SQLite, SQL (SELECT, INSERT)。
    *   实战：使用 Python `sqlite3` 库存储 Day 4 的学生数据。
*   **Day 6-7: 综合小项目**
    *   **项目**: 命令行版待办事项 (CLI Todo)。
    *   功能：添加、查看、删除任务，数据存入 SQLite。

### 第二阶段：Web 开发进阶 (Week 2)

*   **Day 8: HTTP 与 Flask**
    *   学习：HTTP 方法，Flask 路由。
    *   实战：运行 `hello.py`，浏览器访问。
*   **Day 9: API 开发**
    *   学习：`jsonify`, Postman 使用。
    *   实战：为 CLI Todo 编写 API 接口。
*   **Day 10: 前端基础**
    *   学习：HTML 结构, CSS 样式, JS Fetch。
    *   实战：写一个简单的 HTML 页面调用 Day 9 的 API。
*   **Day 11: 深入 DDL out!**
    *   任务：通读 `app.py` 和 `database.py`，画出自己的理解图。
*   **Day 12: 功能扩展**
    *   挑战：给 DDL out! 增加“任务备注”功能。
        1.  修改 DB Schema。
        2.  修改 API。
        3.  修改前端。
*   **Day 13: 部署与维护**
    *   学习：Gunicorn, Nginx, Linux 基础命令。
    *   实战：在虚拟机或云服务器上部署你的应用。
*   **Day 14: 总结与进阶**
    *   方向：学习 Vue/React (前端) 或 Django/FastAPI (后端)。

---

**祝编码愉快！**

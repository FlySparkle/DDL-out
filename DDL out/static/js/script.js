// 全局状态
let state = {
    tasks: [],
    categories: [],
    draggedTask: null,
    // 记录折叠状态
    collapsedCategories: new Set(),
    // 当前时间模式
    activeTimeMode: 'tab-remaining' // 'tab-remaining' or 'tab-absolute'
};

// 本地存储键
const STORAGE_KEYS = {
    LAST_ABS_CONFIG: 'lastAbsTimeModeConfig',
    LAST_REL_CONFIG: 'lastRelTimeModeConfig'
};

// 预设配色方案
const PRESET_COLORS = [
    '#4a90e2', // 蓝
    '#50e3c2', // 青
    '#b8e986', // 绿
    '#f5a623', // 橙
    '#ff4d4f', // 红
    '#9013fe', // 紫
    '#bd10e0', // 品红
    '#4a4a4a'  // 黑灰
];

// 初始化
if (typeof document !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        fetchData();
        setupEventListeners();
        setupDeadlineLogic();
        renderColorPalette();
        // 每分钟刷新一次以更新时间和排序
        setInterval(renderBoard, 60000);
    });
}

// ----------------- Data Fetching -----------------

async function fetchData() {
    try {
        const [catRes, taskRes] = await Promise.all([
            fetch('/api/categories'),
            fetch('/api/tasks')
        ]);
        
        state.categories = await catRes.json();
        state.tasks = await taskRes.json();
        
        renderBoard();
        updateCategorySelect();
        updateClearCompletedBtn();
    } catch (error) {
        console.error('Error fetching data:', error);
    }
}

// ----------------- Rendering -----------------

function renderBoard() {
    const board = document.getElementById('kanban-board');
    board.innerHTML = '';
    
    // 按分类ID分组任务
    const tasksByCat = {};
    state.categories.forEach(cat => {
        tasksByCat[cat.id] = state.tasks.filter(t => t.category_id === cat.id);
        // 自动排序：已完成沉底，未完成按剩余时间排序
        tasksByCat[cat.id].sort((a, b) => {
            if (a.completed && !b.completed) return 1;
            if (!a.completed && b.completed) return -1;
            return new Date(a.deadline) - new Date(b.deadline);
        });
    });
    
    // 渲染每个分类列
    state.categories.forEach(cat => {
        const column = createColumn(cat, tasksByCat[cat.id] || []);
        board.appendChild(column);
    });
}

function createColumn(category, tasks) {
    const col = document.createElement('div');
    col.className = 'column';
    if (state.collapsedCategories.has(category.id)) {
        col.classList.add('collapsed');
    }
    col.dataset.catId = category.id;
    
    // 头部
    const header = document.createElement('div');
    header.className = 'column-header';
    header.style.borderLeftColor = category.color;
    
    // 标题区域 (点击折叠)
    const titleGroup = document.createElement('div');
    titleGroup.className = 'column-title-group';
    titleGroup.onclick = (e) => {
        // 防止点击按钮时触发折叠
        if (e.target.tagName === 'BUTTON') return;
        toggleCategoryCollapse(category.id, col);
    };
    
    titleGroup.innerHTML = `
        <span class="toggle-icon">▼</span>
        <span class="cat-name">${category.name}</span>
    `;
    
    // 长按标题编辑分类 (替换双击)
    const nameEl = titleGroup.querySelector('.cat-name');
    setupLongPress(nameEl, () => {
        openCategoryModal(category);
    });

    // 操作区域
    const actions = document.createElement('div');
    actions.className = 'column-actions';
    
    const addTaskBtn = document.createElement('button');
    addTaskBtn.className = 'btn-add-task';
    addTaskBtn.textContent = '+ 添加待办事项';
    addTaskBtn.title = '在此分类新建任务';
    addTaskBtn.onclick = (e) => {
        e.stopPropagation();
        resetTaskForm();
        // 预选当前分类
        document.getElementById('task-category').value = category.id;
        openModal(document.getElementById('task-modal'));
    };
    
    actions.appendChild(addTaskBtn);
    
    header.appendChild(titleGroup);
    header.appendChild(actions);
    
    // 任务列表容器 (Drop Target)
    const list = document.createElement('div');
    list.className = 'task-list';
    list.dataset.catId = category.id;
    
    // 拖拽事件
    list.addEventListener('dragover', handleDragOver);
    list.addEventListener('drop', handleDrop);
    list.addEventListener('dragleave', handleDragLeave);
    
    // 计算该分类下任务的最大剩余时间（用于进度条基准）
    const activeTasks = tasks.filter(t => !t.completed);
    const maxRemaining = Math.max(...activeTasks.map(t => getRemainingHours(t.deadline)), 0.1);
    
    tasks.forEach(task => {
        const card = createTaskCard(task, category, maxRemaining);
        list.appendChild(card);
    });
    
    col.appendChild(header);
    col.appendChild(list);
    
    return col;
}

function toggleCategoryCollapse(catId, colElement) {
    if (state.collapsedCategories.has(catId)) {
        state.collapsedCategories.delete(catId);
        colElement.classList.remove('collapsed');
    } else {
        state.collapsedCategories.add(catId);
        colElement.classList.add('collapsed');
    }
}

// 长按事件处理工具
function setupLongPress(element, callback, duration = 600) {
    let timer;
    let isPressing = false;

    const start = (e) => {
        if (e.type === 'click' && e.button !== 0) return; // Only left click
        isPressing = true;
        
        // 视觉反馈
        element.closest('.column').classList.add('pressing');
        
        timer = setTimeout(() => {
            if (isPressing) {
                // 长按触发
                callback();
                isPressing = false;
                element.closest('.column').classList.remove('pressing');
            }
        }, duration);
    };

    const cancel = () => {
        isPressing = false;
        clearTimeout(timer);
        element.closest('.column')?.classList.remove('pressing');
    };

    element.addEventListener('mousedown', start);
    element.addEventListener('mouseup', cancel);
    element.addEventListener('mouseleave', cancel);
    
    // 阻止默认上下文菜单
    element.addEventListener('contextmenu', e => {
        e.preventDefault();
        return false;
    });
}

function createTaskCard(task, category, maxRemaining) {
    const card = document.createElement('div');
    card.className = `task-card ${task.completed ? 'completed' : ''}`;
    card.draggable = true;
    card.dataset.taskId = task.id;
    
    // 拖拽开始
    card.addEventListener('dragstart', (e) => {
        state.draggedTask = task;
        e.dataTransfer.effectAllowed = 'move';
        card.classList.add('sortable-ghost');
    });
    
    // 拖拽结束
    card.addEventListener('dragend', () => {
        state.draggedTask = null;
        card.classList.remove('sortable-ghost');
        document.querySelectorAll('.task-list').forEach(el => el.style.backgroundColor = '');
    });
    
    // 点击编辑 (如果是点击checkbox则不触发)
    card.onclick = (e) => {
        if (!e.target.closest('.task-checkbox-btn')) {
            openTaskModal(task);
        }
    };
    
    // 计算剩余时间和进度
    const remainingHours = getRemainingHours(task.deadline);
    const progressPercent = task.completed ? 0 : Math.max(0, Math.min(100, (remainingHours / maxRemaining) * 100));
    const remainingText = task.completed ? '已完成' : getRemainingTimeText(remainingHours);
    
    // 计算颜色深度
    const colorDepth = calculateColorDepth(category.color, remainingHours);
    
    // 设置悬停提示
    card.dataset.progress = task.completed ? '已完成' : `剩余: ${Math.round(progressPercent)}%`;

    // 构造HTML结构：底层进度条 + 上层内容
    card.innerHTML = `
        <div class="task-progress-fill" style="width: ${progressPercent}%; background-color: ${colorDepth}"></div>
        <div class="task-content">
            <button class="task-checkbox-btn" role="checkbox" aria-checked="${task.completed ? 'true' : 'false'}" aria-label="标记为完成">
                <div class="check-indicator"></div>
            </button>
            <span class="task-name" title="${task.name}">${task.name}</span>
            <span class="task-meta">${remainingText}</span>
        </div>
    `;
    
    // 绑定 Checkbox 事件
    const checkboxBtn = card.querySelector('.task-checkbox-btn');
    checkboxBtn.onclick = (e) => {
        e.stopPropagation(); // 阻止冒泡
        toggleTaskStatus(task, !task.completed);
    };
    
    // 阻止 Space 键冒泡防止触发其他操作，并触发点击
    checkboxBtn.onkeydown = (e) => {
        if (e.key === ' ' || e.key === 'Enter') {
            e.preventDefault();
            e.stopPropagation();
            toggleTaskStatus(task, !task.completed);
        }
    };
    
    return card;
}

async function toggleTaskStatus(task, isCompleted) {
    // 乐观更新
    task.completed = isCompleted ? 1 : 0;
    renderBoard();
    updateClearCompletedBtn();
    
    try {
        await fetch(`/api/tasks/${task.id}`, {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                name: task.name,
                deadline: task.deadline,
                category_id: task.category_id,
                completed: task.completed
            })
        });
    } catch (error) {
        console.error('Error updating task status:', error);
        // 回滚
        task.completed = !isCompleted ? 1 : 0;
        renderBoard();
        updateClearCompletedBtn();
    }
}

// ----------------- Logic Helpers -----------------

function getRemainingHours(deadline) {
    const now = new Date();
    const end = new Date(deadline);
    return (end - now) / (1000 * 60 * 60);
}

function getRemainingTimeText(hours) {
    if (hours < 0) return '已过期';
    if (hours < 24) return `${Math.floor(hours)}h ${Math.floor((hours % 1) * 60)}m`;
    return `${Math.floor(hours / 24)}d ${Math.floor(hours % 24)}h`;
}

function calculateColorDepth(hexColor, hours) {
    if (hours < 0) return '#999999'; // 过期灰色
    
    let lightenFactor = 0;
    
    if (hours <= 12) {
        lightenFactor = 0.2;
    } else if (hours <= 24) {
        lightenFactor = 0.4;
    } else if (hours <= 72) {
        lightenFactor = 0.6;
    } else {
        lightenFactor = 0.8;
    }
    
    return lightenColor(hexColor, lightenFactor);
}

function lightenColor(hex, factor) {
    let r = 0, g = 0, b = 0;
    if (hex.length === 4) {
        r = parseInt("0x" + hex[1] + hex[1]);
        g = parseInt("0x" + hex[2] + hex[2]);
        b = parseInt("0x" + hex[3] + hex[3]);
    } else if (hex.length === 7) {
        r = parseInt("0x" + hex[1] + hex[2]);
        g = parseInt("0x" + hex[3] + hex[4]);
        b = parseInt("0x" + hex[5] + hex[6]);
    }
    
    const newR = Math.round(r + (255 - r) * factor);
    const newG = Math.round(g + (255 - g) * factor);
    const newB = Math.round(b + (255 - b) * factor);
    
    return `rgb(${newR}, ${newG}, ${newB})`;
}

// ----------------- Color Palette Logic -----------------

function renderColorPalette() {
    const container = document.getElementById('color-palette');
    container.innerHTML = '';
    
    PRESET_COLORS.forEach(color => {
        const div = document.createElement('div');
        div.className = 'color-option';
        div.style.backgroundColor = color;
        div.onclick = () => selectColor(color, div);
        container.appendChild(div);
    });
    
    const customDiv = document.createElement('div');
    customDiv.className = 'color-option custom';
    customDiv.title = '自定义颜色';
    customDiv.onclick = () => {
        document.getElementById('cat-color-input').click();
    };
    container.appendChild(customDiv);
    
    const colorInput = document.getElementById('cat-color-input');
    colorInput.onchange = (e) => {
        selectColor(e.target.value, customDiv);
    };
}

function selectColor(color, element) {
    document.getElementById('cat-color').value = color;
    document.querySelectorAll('.color-option').forEach(el => el.classList.remove('selected'));
    element.classList.add('selected');
    
    if (element.classList.contains('custom')) {
        element.style.background = color; // 临时覆盖渐变
    }
}

function rgbToHex(rgb) {
    if (!rgb || rgb.startsWith('#')) return rgb;
    const rgbValues = rgb.match(/\d+/g);
    if (!rgbValues) return rgb;
    return "#" + ((1 << 24) + (parseInt(rgbValues[0]) << 16) + (parseInt(rgbValues[1]) << 8) + parseInt(rgbValues[2])).toString(16).slice(1);
}

// ----------------- Drag and Drop Handlers -----------------

function handleDragOver(e) {
    e.preventDefault(); 
    e.currentTarget.style.backgroundColor = 'rgba(0,0,0,0.02)';
}

function handleDragLeave(e) {
    e.currentTarget.style.backgroundColor = '';
}

async function handleDrop(e) {
    e.preventDefault();
    e.currentTarget.style.backgroundColor = '';
    
    const targetList = e.currentTarget;
    const newCatId = parseInt(targetList.dataset.catId);
    
    if (state.draggedTask && state.draggedTask.category_id !== newCatId) {
        state.draggedTask.category_id = newCatId;
        renderBoard();
        
        try {
            await fetch(`/api/tasks/${state.draggedTask.id}`, {
                method: 'PUT',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(state.draggedTask)
            });
        } catch (error) {
            console.error('Error updating task category:', error);
            fetchData(); 
        }
    }
}

// ----------------- Deadline Logic (New) -----------------

const REMAINING_TIME_CONTROLS = [
    { inputId: 'rem-day', wheelId: 'wheel-rem-day', count: 1000, digits: 1, mode: 'tab-remaining', extendable: true },
    { inputId: 'rem-hour', wheelId: 'wheel-rem-hour', count: 24, digits: 2, mode: 'tab-remaining' },
    { inputId: 'rem-minute', wheelId: 'wheel-rem-minute', count: 60, digits: 2, mode: 'tab-remaining' }
];

const ABSOLUTE_TIME_CONTROLS = [
    { inputId: 'abs-hour', wheelId: 'wheel-hour', count: 24, digits: 2, mode: 'tab-absolute' },
    { inputId: 'abs-minute', wheelId: 'wheel-minute', count: 60, digits: 2, mode: 'tab-absolute' }
];

function setupDeadlineLogic() {
    setupTabs();
    setupRemainingTimeMode();
    setupAbsoluteTimeMode();
}

function setupTabs() {
    const tabs = document.querySelectorAll('.tab-btn');
    tabs.forEach(tab => {
        tab.onclick = () => {
            const previousMode = state.activeTimeMode;
            const targetId = tab.dataset.tab;
            commitTimeControls(previousMode);

            if (targetId === previousMode) return;

            // 切换 Tab
            tabs.forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
            
            tab.classList.add('active');
            document.getElementById(targetId).classList.add('active');
            
            state.activeTimeMode = targetId;
            
            // 切换时自动转换值
            syncTimeModes(targetId);
        };
    });
}

// 剩余时间模式逻辑
function setupRemainingTimeMode() {
    REMAINING_TIME_CONTROLS.forEach(control => {
        setupDirectInput(control);
        initWheel(control);
    });
    setRemainingTimeValues(0, 0, 0);
}

function normalizeRemainingTime(days, hours, minutes) {
    const d = Math.max(0, parseInt(days, 10) || 0);
    const h = Math.max(0, parseInt(hours, 10) || 0);
    const m = Math.max(0, parseInt(minutes, 10) || 0);
    const totalMinutes = (d * 24 * 60) + (h * 60) + m;

    return {
        days: Math.floor(totalMinutes / (24 * 60)),
        hours: Math.floor((totalMinutes % (24 * 60)) / 60),
        minutes: totalMinutes % 60
    };
}

function validateRemainingInput() {
    const normalized = normalizeRemainingTime(
        document.getElementById('rem-day').value,
        document.getElementById('rem-hour').value,
        document.getElementById('rem-minute').value
    );
    
    document.getElementById('rem-day').value = normalized.days;
    document.getElementById('rem-hour').value = normalized.hours;
    document.getElementById('rem-minute').value = normalized.minutes;

    checkSubmitButton();
    return normalized;
}

// 绝对时间模式逻辑
function setupAbsoluteTimeMode() {
    ABSOLUTE_TIME_CONTROLS.forEach(control => {
        setupDirectInput(control);
        initWheel(control);
    });
    setAbsoluteTimeValues(0, 0);
    
    // 日期选择器变化
    document.getElementById('abs-date').addEventListener('change', checkSubmitButton);
}

function setupDirectInput(control) {
    const input = document.getElementById(control.inputId);
    input.addEventListener('focus', () => input.select());
    input.addEventListener('input', (e) => {
        const maxLength = Number(e.target.maxLength) || 3;
        const cleanValue = e.target.value.replace(/[^\d]/g, '');

        if (cleanValue.length > maxLength) {
            e.target.value = cleanValue.slice(0, maxLength);
            const group = input.closest('.time-input-group');
            group.classList.remove('input-error');
            void group.offsetWidth;
            group.classList.add('input-error');
        } else {
            e.target.value = cleanValue;
        }
        input.dataset.dirty = 'true';
        checkSubmitButton();
    });

    input.addEventListener('blur', () => syncInputToWheel(control));
}

function syncInputToWheel(control) {
    const input = document.getElementById(control.inputId);
    if (input.value === '') input.value = '0';

    if (control.mode === 'tab-remaining') {
        syncRemainingInputsToWheels();
    } else {
        const value = Math.max(0, Math.min(control.count - 1, parseInt(input.value, 10) || 0));
        input.value = value.toString().padStart(2, '0');
        setWheelValue(control.wheelId, value);
    }
    input.dataset.dirty = 'false';
    checkSubmitButton();
}

function syncWheelToInput(control) {
    const container = document.getElementById(control.wheelId);
    const input = document.getElementById(control.inputId);
    const value = getWheelValue(control.wheelId);
    input.value = control.mode === 'tab-absolute'
        ? value.toString().padStart(2, '0')
        : value;
    container.dataset.dirty = 'false';

    if (control.mode === 'tab-remaining') {
        syncRemainingInputsToWheels();
    }
    checkSubmitButton();
}

function syncRemainingInputsToWheels() {
    const normalized = validateRemainingInput();
    setWheelValue('wheel-rem-day', normalized.days);
    setWheelValue('wheel-rem-hour', normalized.hours);
    setWheelValue('wheel-rem-minute', normalized.minutes);
    REMAINING_TIME_CONTROLS.forEach(control => {
        document.getElementById(control.inputId).dataset.dirty = 'false';
    });
}

function commitTimeControls(mode = state.activeTimeMode) {
    const controls = mode === 'tab-absolute' ? ABSOLUTE_TIME_CONTROLS : REMAINING_TIME_CONTROLS;
    const activeElement = document.activeElement;
    const activeWheel = controls.find(control => control.wheelId === activeElement?.id);

    if (activeWheel && activeElement.dataset.dirty === 'true') {
        syncWheelToInput(activeWheel);
        return;
    }

    if (mode === 'tab-remaining') {
        syncRemainingInputsToWheels();
    } else {
        controls.forEach(syncInputToWheel);
    }
}

function appendWheelItems(container, start, end, digits) {
    const bottomSpacer = container.querySelector('.wheel-spacer:last-child');
    for (let i = start; i < end; i++) {
        const item = document.createElement('div');
        item.className = 'wheel-item';
        item.textContent = i.toString().padStart(digits, '0');
        item.dataset.val = i;
        container.insertBefore(item, bottomSpacer);
    }
    container.dataset.count = end;
}

function initWheel(control) {
    const container = document.getElementById(control.wheelId);
    container.dataset.inputId = control.inputId;
    container.dataset.mode = control.mode;
    container.dataset.extendable = control.extendable ? 'true' : 'false';
    container.dataset.digits = control.digits;
    container.dataset.count = 0;

    const spacerTop = document.createElement('div');
    spacerTop.className = 'wheel-spacer';
    container.appendChild(spacerTop);

    const spacerBottom = document.createElement('div');
    spacerBottom.className = 'wheel-spacer';
    container.appendChild(spacerBottom);
    appendWheelItems(container, 0, control.count, control.digits);

    container.addEventListener('wheel', (e) => {
        e.preventDefault();
        const direction = Math.sign(e.deltaY);
        if (direction === 0) return;
        container.focus({ preventScroll: true });
        selectWheelIndex(container, getWheelValue(control.wheelId) + direction, true, 'smooth');
    }, { passive: false });

    container.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
            e.preventDefault();
            const delta = e.key === 'ArrowUp' ? -1 : 1;
            selectWheelIndex(container, getWheelValue(control.wheelId) + delta, true, 'smooth');
        }
    });

    container.addEventListener('click', (e) => {
        const item = e.target.closest('.wheel-item');
        if (!item) return;
        container.focus({ preventScroll: true });
        selectWheelIndex(container, parseInt(item.dataset.val, 10), true, 'smooth');
    });

    container.addEventListener('blur', () => {
        if (container.dataset.dirty === 'true') syncWheelToInput(control);
    });
}

function selectWheelIndex(container, requestedIndex, userInitiated = false, behavior = 'auto') {
    const itemHeight = 32;
    const count = Number(container.dataset.count);
    const index = Math.max(0, Math.min(count - 1, requestedIndex));
    container.scrollTo({
        top: index * itemHeight,
        behavior
    });

    const items = container.querySelectorAll('.wheel-item');
    items.forEach(el => el.classList.remove('active'));
    if (items[index]) items[index].classList.add('active');
    if (userInitiated) container.dataset.dirty = 'true';
    checkSubmitButton();
}

function getWheelValue(containerId) {
    const container = document.getElementById(containerId);
    const active = container.querySelector('.wheel-item.active');
    return active ? parseInt(active.dataset.val, 10) : 0;
}

function setWheelValue(containerId, value) {
    const container = document.getElementById(containerId);
    const normalizedValue = Math.max(0, parseInt(value, 10) || 0);
    const count = Number(container.dataset.count);

    if (normalizedValue >= count && container.dataset.extendable === 'true') {
        appendWheelItems(container, count, normalizedValue + 1, Number(container.dataset.digits));
    }
    selectWheelIndex(container, normalizedValue);
    container.dataset.dirty = 'false';
}

function setRemainingTimeValues(days, hours, minutes) {
    document.getElementById('rem-day').value = days;
    document.getElementById('rem-hour').value = hours;
    document.getElementById('rem-minute').value = minutes;
    syncRemainingInputsToWheels();
}

function setAbsoluteTimeValues(hours, minutes) {
    const h = Math.max(0, Math.min(23, parseInt(hours, 10) || 0));
    const m = Math.max(0, Math.min(59, parseInt(minutes, 10) || 0));
    document.getElementById('abs-hour').value = h.toString().padStart(2, '0');
    document.getElementById('abs-minute').value = m.toString().padStart(2, '0');
    setWheelValue('wheel-hour', h);
    setWheelValue('wheel-minute', m);
}

// 模式同步
function syncTimeModes(targetMode) {
    if (targetMode === 'tab-absolute') {
        // Remaining -> Absolute
        const d = parseInt(document.getElementById('rem-day').value) || 0;
        const h = parseInt(document.getElementById('rem-hour').value) || 0;
        const m = parseInt(document.getElementById('rem-minute').value) || 0;
        
        const now = new Date();
        const targetDate = new Date(now.getTime() + (d * 24 * 60 * 60 * 1000) + (h * 60 * 60 * 1000) + (m * 60 * 1000));
        
        const yyyy = targetDate.getFullYear();
        const mm = String(targetDate.getMonth() + 1).padStart(2, '0');
        const dd = String(targetDate.getDate()).padStart(2, '0');
        
        document.getElementById('abs-date').value = `${yyyy}-${mm}-${dd}`;
        setAbsoluteTimeValues(targetDate.getHours(), targetDate.getMinutes());
        
    } else {
        // Absolute -> Remaining
        const dateStr = document.getElementById('abs-date').value;
        if (!dateStr) return;
        
        const h = parseInt(document.getElementById('abs-hour').value, 10) || 0;
        const m = parseInt(document.getElementById('abs-minute').value, 10) || 0;
        
        const targetDate = new Date(`${dateStr}T${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:00`);
        const now = new Date();
        
        let diff = targetDate - now;
        if (diff < 0) diff = 0;
        
        const totalMinutes = Math.floor(diff / 60000);
        const remD = Math.floor(totalMinutes / (24 * 60));
        const remH = Math.floor((totalMinutes % (24 * 60)) / 60);
        const remM = totalMinutes % 60;
        
        setRemainingTimeValues(remD, remH, remM);
    }
    checkSubmitButton();
}

function checkSubmitButton() {
    const btn = document.querySelector('#task-form button[type="submit"]');
    const hint = document.getElementById('rem-hint');
    
    // 简单验证：必须有日期（绝对模式）或 合法值
    if (state.activeTimeMode === 'tab-absolute') {
        if (!document.getElementById('abs-date').value) {
            btn.disabled = true;
            hint.textContent = '请选择日期';
            return;
        }
    }
    
    btn.disabled = false;
    hint.textContent = '';
}

function getFinalDeadline() {
    commitTimeControls();
    if (state.activeTimeMode === 'tab-remaining') {
        const d = parseInt(document.getElementById('rem-day').value) || 0;
        const h = parseInt(document.getElementById('rem-hour').value) || 0;
        const m = parseInt(document.getElementById('rem-minute').value) || 0;
        
        const now = new Date();
        const targetDate = new Date(now.getTime() + (d * 24 * 60 * 60 * 1000) + (h * 60 * 60 * 1000) + (m * 60 * 1000));
        return targetDate.toISOString();
    } else {
        const dateStr = document.getElementById('abs-date').value;
        const h = parseInt(document.getElementById('abs-hour').value, 10) || 0;
        const m = parseInt(document.getElementById('abs-minute').value, 10) || 0;
        const targetDate = new Date(`${dateStr}T${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:00`);
        return targetDate.toISOString();
    }
}

// ----------------- Storage Helpers -----------------

function saveConfig(key, data) {
    try {
        const payload = {
            version: '1.0',
            data: data
        };
        localStorage.setItem(key, JSON.stringify(payload));
    } catch (e) {
        console.error('Save config failed', e);
    }
}

function loadConfig(key) {
    try {
        const str = localStorage.getItem(key);
        if (!str) return null;
        const payload = JSON.parse(str);
        return payload.data;
    } catch (e) {
        console.error('Load config failed', e);
        return null;
    }
}

// ----------------- Modal & Confirm Logic -----------------

// 自定义确认弹窗
function showConfirm(message, onConfirm) {
    const modal = document.getElementById('confirm-modal');
    document.getElementById('confirm-message').textContent = message;
    
    const okBtn = document.getElementById('confirm-ok-btn');
    const cancelBtn = document.getElementById('confirm-cancel-btn');
    
    // 解绑旧事件
    const newOkBtn = okBtn.cloneNode(true);
    okBtn.parentNode.replaceChild(newOkBtn, okBtn);
    
    const newCancelBtn = cancelBtn.cloneNode(true);
    cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
    
    // 绑定新事件
    newOkBtn.onclick = () => {
        closeModal(modal);
        onConfirm();
    };
    
    newCancelBtn.onclick = () => {
        closeModal(modal);
    };
    
    openModal(modal);
}

function setupEventListeners() {
    const taskModal = document.getElementById('task-modal');
    const catModal = document.getElementById('category-modal');
    
    // "新建分类" 按钮
    document.getElementById('add-category-btn').onclick = () => {
        resetCategoryForm();
        openModal(catModal);
    };
    
    // "清空分类" 按钮
    document.getElementById('clear-all-btn').onclick = handleClearAll;
    
    // "清除已完成" 按钮
    document.getElementById('clear-completed-btn').onclick = handleClearCompleted;
    
    // 关闭按钮
    document.querySelectorAll('.close, .close-cat').forEach(btn => {
        btn.onclick = (e) => closeModal(e.target.closest('.modal'));
    });
    
    // 点击遮罩关闭
    window.onclick = (e) => {
        if (e.target.classList.contains('modal')) {
            // 确认框强制必须点击按钮关闭，防止误触
            if (e.target.id !== 'confirm-modal') {
                saveDeadlineConfig(); // 尝试保存配置
                closeModal(e.target);
            }
        }
    };
    
    document.getElementById('task-form').onsubmit = handleTaskSubmit;
    document.getElementById('category-form').onsubmit = handleCategorySubmit;
    
    document.getElementById('delete-task-btn').onclick = handleDeleteTask;
    document.getElementById('delete-cat-btn').onclick = handleDeleteCategory;
    
    // 窗口大小调整监听 (用于动态调整弹窗)
    window.addEventListener('resize', () => {
        adjustModalPosition();
    });
}

function adjustModalPosition() {
    // CSS Flexbox handles centering, but we can ensure constraints
    const modals = document.querySelectorAll('.modal.show .modal-content');
    modals.forEach(content => {
        const rect = content.getBoundingClientRect();
        // 简单的边缘检测逻辑 (CSS max-height/width 已经做了大部分工作)
        if (rect.height > window.innerHeight) {
            content.style.maxHeight = (window.innerHeight - 40) + 'px';
        }
    });
}

function openModal(modal) {
    modal.classList.add('show');
}

function closeModal(modal) {
    modal.classList.remove('show');
}

function saveDeadlineConfig() {
    commitTimeControls();
    // 保存当前模式的配置
    if (state.activeTimeMode === 'tab-remaining') {
        saveConfig(STORAGE_KEYS.LAST_REL_CONFIG, {
            d: document.getElementById('rem-day').value,
            h: document.getElementById('rem-hour').value,
            m: document.getElementById('rem-minute').value
        });
    } else {
        saveConfig(STORAGE_KEYS.LAST_ABS_CONFIG, {
            date: document.getElementById('abs-date').value,
            h: document.getElementById('abs-hour').value,
            m: document.getElementById('abs-minute').value
        });
    }
}

function resetTaskForm() {
    document.getElementById('task-id').value = '';
    document.getElementById('task-form').reset();
    document.getElementById('modal-title').textContent = '新建任务';
    document.getElementById('delete-task-btn').style.display = 'none';
    
    // 恢复记忆的配置
    const lastMode = 'tab-remaining'; // 默认剩余时间模式
    document.querySelector(`[data-tab="${lastMode}"]`).click(); // 触发切换
    
    const relConfig = loadConfig(STORAGE_KEYS.LAST_REL_CONFIG);
    if (relConfig) {
        setRemainingTimeValues(relConfig.d || 0, relConfig.h || 0, relConfig.m || 0);
    } else {
        // 默认 0d 0h 0m
        setRemainingTimeValues(0, 0, 0);
    }
    
    const absConfig = loadConfig(STORAGE_KEYS.LAST_ABS_CONFIG);
    if (absConfig) {
        document.getElementById('abs-date').value = absConfig.date || '';
        setAbsoluteTimeValues(absConfig.h || 0, absConfig.m || 0);
    } else {
        // 默认明天
        const now = new Date();
        now.setDate(now.getDate() + 1);
        const yyyy = now.getFullYear();
        const mm = String(now.getMonth() + 1).padStart(2, '0');
        const dd = String(now.getDate()).padStart(2, '0');
        document.getElementById('abs-date').value = `${yyyy}-${mm}-${dd}`;
        setAbsoluteTimeValues(12, 0);
    }
    
    // 如果没有记忆，同步一下
    if (!relConfig && !absConfig) {
         // do nothing, defaults set above
    }
}

function resetCategoryForm() {
    document.getElementById('cat-id').value = '';
    document.getElementById('category-form').reset();
    document.getElementById('delete-cat-btn').style.display = 'none';
    
    // 重置颜色选择状态
    selectColor(PRESET_COLORS[0], document.querySelector('.color-option'));
}

function openTaskModal(task) {
    const modal = document.getElementById('task-modal');
    document.getElementById('task-id').value = task.id;
    document.getElementById('task-name').value = task.name;
    document.getElementById('task-category').value = task.category_id;
    
    // 反解截止时间
    const deadline = new Date(task.deadline);
    const now = new Date();
    
    // 设置剩余时间
    let diff = deadline - now;
    if (diff < 0) diff = 0;
    const totalMinutes = Math.floor(diff / 60000);
    setRemainingTimeValues(
        Math.floor(totalMinutes / (24 * 60)),
        Math.floor((totalMinutes % (24 * 60)) / 60),
        totalMinutes % 60
    );
    
    // 默认打开绝对时间模式用于编辑
    document.querySelector('[data-tab="tab-absolute"]').click();

    // 标签切换完成后恢复任务的精确绝对时间
    const yyyy = deadline.getFullYear();
    const mm = String(deadline.getMonth() + 1).padStart(2, '0');
    const dd = String(deadline.getDate()).padStart(2, '0');
    document.getElementById('abs-date').value = `${yyyy}-${mm}-${dd}`;
    setAbsoluteTimeValues(deadline.getHours(), deadline.getMinutes());
    
    document.getElementById('modal-title').textContent = '编辑任务';
    document.getElementById('delete-task-btn').style.display = 'block';
    openModal(modal);
}

function openCategoryModal(category) {
    const modal = document.getElementById('category-modal');
    document.getElementById('cat-id').value = category.id;
    document.getElementById('cat-name').value = category.name;
    document.getElementById('cat-color').value = category.color;
    
    const colorOptions = document.querySelectorAll('.color-option');
    let matched = false;
    colorOptions.forEach(el => {
        if (rgbToHex(el.style.backgroundColor) === category.color.toLowerCase() || 
            el.style.backgroundColor === category.color) {
            el.classList.add('selected');
            matched = true;
        } else {
            el.classList.remove('selected');
        }
    });
    
    if (!matched) {
        const customBtn = document.querySelector('.color-option.custom');
        customBtn.classList.add('selected');
        customBtn.style.background = category.color;
    }
    
    document.getElementById('delete-cat-btn').style.display = 'block';
    openModal(modal);
}

function updateCategorySelect() {
    const select = document.getElementById('task-category');
    select.innerHTML = '';
    state.categories.forEach(cat => {
        const option = document.createElement('option');
        option.value = cat.id;
        option.textContent = cat.name;
        select.appendChild(option);
    });
}

function updateClearCompletedBtn() {
    const btn = document.getElementById('clear-completed-btn');
    const hasCompleted = state.tasks.some(t => t.completed);
    btn.disabled = !hasCompleted;
    btn.title = hasCompleted ? '清除已完成事项' : '没有可清除的已完成事项';
}

// ----------------- CRUD Handlers -----------------

async function handleTaskSubmit(e) {
    e.preventDefault();
    saveDeadlineConfig(); // Save before submit
    
    const id = document.getElementById('task-id').value;
    const task = {
        name: document.getElementById('task-name').value,
        deadline: getFinalDeadline(),
        category_id: parseInt(document.getElementById('task-category').value)
    };
    
    const url = id ? `/api/tasks/${id}` : '/api/tasks';
    const method = id ? 'PUT' : 'POST';
    
    // If editing, preserve completed status (or fetch latest)
    if (id) {
        const existing = state.tasks.find(t => t.id == id);
        if (existing) task.completed = existing.completed;
    }
    
    await fetch(url, {
        method: method,
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(task)
    });
    
    closeModal(document.getElementById('task-modal'));
    fetchData();
}

async function handleDeleteTask() {
    const id = document.getElementById('task-id').value;
    if (!id) return;
    
    showConfirm('确定要删除这个任务吗？', async () => {
        await fetch(`/api/tasks/${id}`, { method: 'DELETE' });
        closeModal(document.getElementById('task-modal'));
        fetchData();
    });
}

async function handleCategorySubmit(e) {
    e.preventDefault();
    const id = document.getElementById('cat-id').value;
    const category = {
        name: document.getElementById('cat-name').value,
        color: document.getElementById('cat-color').value
    };
    
    const url = id ? `/api/categories/${id}` : '/api/categories';
    const method = id ? 'PUT' : 'POST';
    
    await fetch(url, {
        method: method,
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(category)
    });
    
    closeModal(document.getElementById('category-modal'));
    fetchData();
}

async function handleDeleteCategory() {
    const id = document.getElementById('cat-id').value;
    if (!id) return;
    
    showConfirm('确定要删除这个分类吗？分类下的所有任务也将被删除！', async () => {
        await fetch(`/api/categories/${id}`, { method: 'DELETE' });
        closeModal(document.getElementById('category-modal'));
        fetchData();
    });
}

async function handleClearAll() {
    showConfirm('此操作将删除所有分类数据，且不可恢复！', async () => {
        await fetch('/api/categories', { method: 'DELETE' });
        fetchData();
    });
}

async function handleClearCompleted() {
    showConfirm('确定要清除所有已完成的任务吗？', async () => {
        await fetch('/api/tasks/completed', { method: 'DELETE' });
        fetchData();
    });
}

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { normalizeRemainingTime };
}

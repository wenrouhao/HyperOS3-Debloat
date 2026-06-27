import { exec } from 'kernelsu';

let apps = [];
let changed = false;
let searchQuery = '';
const MODPATH = '/data/adb/modules/HyperOS3_Debloat';

// 危险项分组列表
const DANGEROUS_GROUPS = ['危险项'];

// ============ 主题管理 ============
function initTheme() {
    const saved = localStorage.getItem('theme');
    if (saved) {
        document.documentElement.setAttribute('data-theme', saved);
    } else {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        document.documentElement.setAttribute('data-theme', prefersDark ? 'dark' : 'light');
    }
    updateThemeIcon();
}

function toggleTheme() {
    const current = document.documentElement.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
    updateThemeIcon();
}

function updateThemeIcon() {
    const btn = document.getElementById('btnTheme');
    if (!btn) return;
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    btn.innerHTML = isDark
        ? '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>'
        : '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>';
    btn.setAttribute('aria-label', isDark ? '切换亮色模式' : '切换暗色模式');
}

// ============ 工具函数 ============
function toast(msg) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), 3000);
}

async function log(msg) {
    const ts = new Date().toLocaleString('zh-CN', { hour12: false });
    const line = '[' + ts + '] ' + msg;
    try {
        await exec('echo \'' + line.replace(/'/g, "'\\''") + '\' >> "' + MODPATH + '/webroot/debug.log"');
    } catch(e) {}
}

async function syncReplace(app) {
    const dir = MODPATH + '/' + app.path;
    if (app.status) {
        await exec('mkdir -p "' + dir + '" && touch "' + dir + '/.replace"');
    } else {
        await exec('rm -rf "' + dir + '"');
    }
}

// ============ 危险项确认弹窗 ============
function showDangerConfirm(app, toggleEl) {
    const overlay = document.getElementById('dangerOverlay');
    const nameEl = document.getElementById('dangerAppName');
    const descEl = document.getElementById('dangerDesc');

    nameEl.textContent = app.name;

    // 根据应用设置不同的警告描述
    const warnings = {
        'NFC服务': '精简后门禁卡、公交卡、付款功能可能失效',
        '纯净守护': '精简后可能影响应用安全检测',
        '搜狗输入法': '请确保已安装其他输入法，否则无法输入文字',
        '讯飞输入法': '请确保已安装其他输入法，否则无法输入文字',
        '紧急警报': '精简后收不到地震、灾害等紧急预警通知',
        '小米智能卡': '精简后NFC公交卡、门禁卡、付款功能全部失效',
        '小米智能卡服务': '精简后NFC公交卡、门禁卡、付款功能全部失效',
        '米币支付': '精简后米币相关支付功能失效',
        '小米应用商店': '精简后无法通过官方商店下载应用',
    };
    descEl.textContent = warnings[app.name] || '此应用属于危险项，精简后可能影响系统功能';

    overlay.classList.add('show');

    return new Promise((resolve) => {
        const cancelBtn = document.getElementById('dangerCancel');
        const confirmBtn = document.getElementById('dangerConfirm');

        const cleanup = () => {
            overlay.classList.remove('show');
            cancelBtn.removeEventListener('click', onCancel);
            confirmBtn.removeEventListener('click', onConfirm);
        };

        const onCancel = () => { cleanup(); resolve(false); };
        const onConfirm = () => { cleanup(); resolve(true); };

        cancelBtn.addEventListener('click', onCancel);
        confirmBtn.addEventListener('click', onConfirm);
    });
}

// ============ 搜索 ============
function initSearch() {
    const input = document.getElementById('searchInput');
    if (!input) return;
    input.addEventListener('input', (e) => {
        searchQuery = e.target.value.trim().toLowerCase();
        render();
    });
}

// ============ 版本号同步 ============
async function syncVersion() {
    try {
        const { stdout } = await exec('cat "' + MODPATH + '/module.prop"');
        const match = stdout.match(/^version=(.+)$/m);
        if (match) {
            const el = document.getElementById('headerVersion');
            if (el) el.textContent = match[1].trim() + ' · KernelSU Module';
        }
    } catch(e) {}
}

// ============ 配置加载 ============
async function loadConfig() {
    try {
        const res = await fetch('./apps.conf');
        if (!res.ok) throw new Error('无法读取 apps.conf');
        const text = await res.text();
        apps = text.split(/\r?\n/).reduce((acc, line) => {
            const trimmed = line.trim();
            if (!trimmed || trimmed.startsWith('#')) return acc;
            const parts = trimmed.split('|');
            if (parts.length >= 4) {
                acc.push({
                    path: parts[0], name: parts[1], pkg: parts[2],
                    status: parts[3] === '1', group: parts[4] || '其他'
                });
            }
            return acc;
        }, []);
        render();
    } catch (err) {
        document.getElementById('apps').innerHTML =
            '<div class="empty-state"><div class="empty-icon">⚠️</div><div class="empty-text">加载失败：' + err.message + '</div></div>';
    }
}

// ============ 渲染 ============
function render() {
    const container = document.getElementById('apps');
    const allDisabled = apps.filter(a => a.status).length;
    document.getElementById('stats').innerHTML =
        '共 <b>' + apps.length + '</b> 个应用，已精简 <b>' + allDisabled + '</b> 个';
    container.innerHTML = '';

    const groups = {};
    apps.forEach((app, i) => {
        if (!groups[app.group]) groups[app.group] = [];
        groups[app.group].push({ app, index: i });
    });

    // 分组颜色
    const groupColors = {
        'AI/小爱': '#8b5cf6',
        '游戏中心': '#f59e0b',
        '设备互联/生态': '#06b6d4',
        '广告/追踪': '#ef4444',
        '内容/工具/安全': '#10b981',
        '系统服务': '#6366f1',
        '无障碍/宏': '#ec4899',
        '危险项': '#ff3b3b',
        '其他': '#64748b'
    };

    let groupIdx = 0;
    for (const [groupName, items] of Object.entries(groups)) {
        const filtered = searchQuery
            ? items.filter(({ app }) =>
                app.name.toLowerCase().includes(searchQuery) ||
                app.pkg.toLowerCase().includes(searchQuery))
            : items;

        if (filtered.length === 0) continue;

        const groupDisabled = items.filter(x => x.app.status).length;
        const accentColor = groupColors[groupName] || '#64748b';
        const isDangerous = DANGEROUS_GROUPS.includes(groupName);

        const group = document.createElement('div');
        group.className = groupIdx === 0 ? 'group open' : 'group';
        groupIdx++;
        if (isDangerous) group.classList.add('danger-group');

        const header = document.createElement('div');
        header.className = 'group-header';
        header.setAttribute('role', 'button');
        header.setAttribute('aria-expanded', groupIdx === 1 ? 'true' : 'false');
        header.setAttribute('tabindex', '0');
        header.innerHTML =
            '<div class="group-left">' +
            '  <span class="group-accent" style="background:' + accentColor + (isDangerous ? ';box-shadow:0 0 8px ' + accentColor + '60' : '') + '"></span>' +
            '  <span class="group-name">' + groupName + (isDangerous ? ' <span class="danger-tag">⚠</span>' : '') + '</span>' +
            '  <span class="group-badge" style="background:' + accentColor + '18;color:' + accentColor + ';border:1px solid ' + accentColor + '30">' + groupDisabled + '/' + items.length + '</span>' +
            '</div>' +
            '<svg class="group-arrow" viewBox="0 0 24 24"><path d="M10 6l6 6-6 6z"/></svg>';

        header.addEventListener('click', () => {
            const isOpen = group.classList.contains('open');
            const bodyEl = group.querySelector('.group-body');
            if (isOpen) {
                // 关闭：先设具体高度再过渡到 0
                bodyEl.style.maxHeight = bodyEl.scrollHeight + 'px';
                requestAnimationFrame(() => {
                    bodyEl.style.maxHeight = '0px';
                    bodyEl.style.opacity = '0';
                });
                group.classList.remove('open');
            } else {
                // 打开：过渡到实际高度
                bodyEl.style.maxHeight = bodyEl.scrollHeight + 'px';
                bodyEl.style.opacity = '1';
                group.classList.add('open');
                // 动画结束后移除 max-height 限制（允许内容变化）
                setTimeout(() => { if (group.classList.contains('open')) bodyEl.style.maxHeight = 'none'; }, 300);
            }
            header.setAttribute('aria-expanded', !isOpen);
        });
        header.addEventListener('keydown', e => {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); header.click(); }
        });

        const body = document.createElement('div');
        body.className = 'group-body';
        const inner = document.createElement('div');
        inner.className = 'group-body-inner';

        filtered.forEach(({ app, index }) => {
            const item = document.createElement('div');
            item.className = 'app-item';
            if (isDangerous && app.status) item.classList.add('danger-active');
            item.innerHTML =
                '<div class="app-info">' +
                '  <span class="app-name">' + app.name + (isDangerous ? ' <span class="danger-dot"></span>' : '') + '</span>' +
                '  <span class="app-pkg">' + app.pkg + '</span>' +
                '</div>' +
                '<div class="toggle-wrap' + (app.status ? ' on' : '') + '" ' +
                'role="switch" aria-checked="' + app.status + '" ' +
                'aria-label="' + app.name + '" tabindex="0" data-index="' + index + '" data-danger="' + isDangerous + '">' +
                '  <div class="toggle"></div>' +
                '</div>';
            inner.appendChild(item);
        });

        body.appendChild(inner);
        group.appendChild(header);
        group.appendChild(body);
        container.appendChild(group);
    }

    if (container.children.length === 0 && searchQuery) {
        container.innerHTML = '<div class="empty-state"><div class="empty-icon">🔍</div><div class="empty-text">未找到匹配的应用</div></div>';
    }

    bindToggles();

    // 初始化第一个分组展开状态
    const firstBody = container.querySelector('.group.open .group-body');
    if (firstBody) {
        firstBody.style.maxHeight = firstBody.scrollHeight + 'px';
        firstBody.style.opacity = '1';
        setTimeout(() => { firstBody.style.maxHeight = 'none'; }, 300);
    }
}

function bindToggles() {
    document.querySelectorAll('.toggle-wrap').forEach(toggle => {
        const handler = async function() {
            const idx = parseInt(this.dataset.index);
            const isDanger = this.dataset.danger === 'true';
            const willEnable = !apps[idx].status;

            // 危险项开启时弹窗确认
            if (isDanger && willEnable) {
                const confirmed = await showDangerConfirm(apps[idx], this);
                if (!confirmed) return;
            }

            apps[idx].status = !apps[idx].status;
            this.classList.toggle('on');
            this.setAttribute('aria-checked', apps[idx].status);
            changed = true;

            // 危险项样式
            const appItem = this.closest('.app-item');
            if (isDanger) {
                appItem.classList.toggle('danger-active', apps[idx].status);
            }

            await syncReplace(apps[idx]);
            await log('切换 ' + apps[idx].name + ' → ' + (apps[idx].status ? '精简' : '保留'));

            const disabled = apps.filter(a => a.status).length;
            document.getElementById('stats').innerHTML =
                '共 <b>' + apps.length + '</b> 个应用，已精简 <b>' + disabled + '</b> 个';

            const groupEl = this.closest('.group');
            const gName = groupEl.querySelector('.group-name').textContent.replace(' ⚠', '').trim();
            const gItems = apps.filter(a => a.group === gName);
            const gDisabled = gItems.filter(a => a.status).length;
            groupEl.querySelector('.group-badge').textContent = gDisabled + '/' + gItems.length;
        };
        toggle.addEventListener('click', handler);
        toggle.addEventListener('keydown', e => {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handler.call(toggle); }
        });
    });
}

// ============ 保存 & 重启 ============
async function saveConfig() {
    const btn = document.getElementById('btnSave');
    btn.disabled = true;
    const target = MODPATH + '/webroot/apps.conf';
    const disabled = apps.filter(a => a.status).length;
    await log('保存配置... 已精简 ' + disabled + '/' + apps.length);
    try {
        await exec('cat > "' + target + '" << \'EOF\'\n# HyperOS3 Debloat 配置\n# 格式：路径|显示名|包名|状态（1=精简 0=保留）|分组\nEOF');
        let saved = 0;
        for (const app of apps) {
            const line = app.path + '|' + app.name + '|' + app.pkg + '|' + (app.status ? '1' : '0') + '|' + app.group;
            await exec('echo \'' + line.replace(/'/g, "'\\''") + '\' >> "' + target + '"');
            saved++;
        }
        await log('保存成功，共写入 ' + saved + ' 条');
        toast('配置已保存');
        changed = false;
    } catch (err) {
        await log('保存失败：' + err.message);
        toast('保存失败：' + err.message);
    } finally {
        btn.disabled = false;
    }
}

async function doReboot() {
    await log('用户触发重启');
    try { await exec('svc power reboot'); }
    catch (err) { await log('重启失败：' + err.message); toast('重启失败，请手动重启'); }
}

// ============ 初始化 ============
initTheme();
document.getElementById('btnTheme').addEventListener('click', toggleTheme);
document.getElementById('btnSave').addEventListener('click', saveConfig);
document.getElementById('btnReboot').addEventListener('click', () => {
    document.getElementById('dialogOverlay').classList.add('show');
});
document.getElementById('dialogCancel').addEventListener('click', () => {
    document.getElementById('dialogOverlay').classList.remove('show');
});
document.getElementById('dialogConfirm').addEventListener('click', async () => {
    document.getElementById('dialogOverlay').classList.remove('show');
    await saveConfig();
    await doReboot();
});
window.addEventListener('beforeunload', e => {
    if (changed) { e.preventDefault(); e.returnValue = ''; }
});

initSearch();
syncVersion();
loadConfig();

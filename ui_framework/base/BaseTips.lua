---@class BaseTips : GCHost
---@field _root UI Tips根节点
---@field _localPlayer Player 本地玩家
---@field _localPlayerId integer 本地玩家ID
---@field _pos integer[]|nil 固定位置（nil则跟随鼠标）
---@field _isAttached boolean 是否已完成 attach
---@field _mask          UI.MaskInstance 全屏遮罩实例（点击空白关闭）
---@field mask           UI              遮罩挂载节点（非nil则启用）
local M = Class 'BaseTips'

-- 继承 GCHost，与 BasePanel / LocalUILogic 保持一致
Extends('BaseTips', 'GCHost')

---初始化Tips（由外部调用一次）
---@param uiNode? string UUID或路径
function M:attach(uiNode)
    if not uiNode or self._isAttached then
        return
    end
    self._localPlayer = y3.player.get_by_handle(GameAPI.get_client_role())
    self._localPlayerId = 1
    self._root = y3.ui.get_by_handle(self._localPlayer, uiNode)
    self._isAttached = true
    self._root:set_visible(false)
    -- 调用子类 on_init
    self:on_init(self._root, self._localPlayer)
end

---子类重写：初始化（attach 后只执行一次）
---对应 LocalUILogic:on_init
---@param ui UI Tips根节点
---@param local_player Player 本地玩家
function M:on_init(ui, local_player) end

---子类重写：每次显示/刷新时调用
---对应 LocalUILogic:on_refresh
---@param data? table
function M:on_refresh(data) end

---子类重写：隐藏时调用
---@param data? table
function M:on_hide(data)
    self:_hideRoot()
end

---显示Tips
---@param data? table 传递给 on_refresh 的数据
function M:show(data)
    if self:isOpen() then
        self:hide()
    end
    if self._root then
        self._root:set_visible(true)
    end
    self:on_refresh(data)
    -- 设置了挂载节点 self.mask 的Tips，创建全屏遮罩
    -- 点击空白处自动关闭，同时拦截鼠标穿透到底层界面
    if self.mask then
        self._mask = y3.ui.create_mask(self._localPlayer, self.mask, function()
            self:hide()
        end)
    end
end

---隐藏Tips
---@param data? table 传递给 on_hide 的数据
function M:hide(data)
    -- 已启用遮罩则先移除，再隐藏根节点，最后执行子类 on_hide
    if self.mask then
        y3.ui.remove_mask(self)
    end
    self:_hideRoot()
    self:on_hide(data)
end

---判断Tips是否打开
---@return boolean
function M:isOpen()
    if self._root == nil then
        return false
    end
    return self._root:is_visible()
end

---内部隐藏根节点
function M:_hideRoot()
    if self._root == nil then
        return
    end
    self._root:set_visible(false)
end

---设置坐标（简单模式）
---传入nil则跟随鼠标，否则固定到指定位置
---@param pos? integer[] {x, y}
function M:setPoint(pos)
    self._pos = pos
    local preX = self._localPlayer:get_mouse_ui_x_percent()
    local preY = self._localPlayer:get_mouse_ui_y_percent()
    local x, y = 0, 1
    if preX > 0.5 then
        x = 1
    end
    if preY < 0.5 then
        y = 0
    end
    if not self._pos then
        self._root:set_anchor(x, y)
        self._root:set_follow_mouse(true, 5, 5)
    else
        self._root:set_anchor(x, y)
        self._root:set_follow_mouse(false)
        self._root:set_absolute_pos(self._pos[1], self._pos[2])
    end
end

---设置坐标（根据触发UI的位置动态调整）
---画布坐标系：设计分辨率1920x1080按 窗口高/1080 等比缩放，原点在屏幕左下、Y轴向上
---垂直方向：触发UI在上半屏时提示显示在其下方，下半屏时显示在上方，避免超出屏幕
---水平方向：跟随触发UI居中，并钳制在窗口可见区域内（窗口比16:9窄时画布左右会被裁切）
---@param ui UI 触发tips的UI元素
---@param offset? number[] 偏移量 [x偏移, y偏移]，默认为 [0, 0]
function M:setPointByUI(ui, offset)
    offset = offset or { 0, 0 }
    self._root:set_follow_mouse(false)

    local scale = y3.ui.get_window_height() / 1080.0
    local canvasW = y3.ui.get_screen_width() * scale
    local canvasH = y3.ui.get_window_height()
    local visMinX = math.max((canvasW - y3.ui.get_window_width()) / 2, 0)
    local visMaxX = canvasW - visMinX

    local uiX = ui:get_absolute_x()
    local uiY = ui:get_absolute_y()
    local tipsW = self._root:get_real_width()
    local tipsH = self._root:get_real_height()
    local margin = 5

    local x = math.max(math.min(uiX + offset[1], visMaxX - tipsW / 2), visMinX + tipsW / 2)
    local y
    if (uiY / canvasH) > 0.5 then
        -- 上半屏：枢轴取控件顶边(anchor y=1)，从触发UI底边向下展开
        self._root:set_anchor(0.5, 1)
        y = math.max(uiY - ui:get_real_height() / 2 - offset[2], tipsH + margin)
    else
        -- 下半屏：枢轴取控件底边(anchor y=0)，从触发UI顶边向上展开
        self._root:set_anchor(0.5, 0)
        y = math.min(uiY + ui:get_real_height() / 2 + offset[2], canvasH - tipsH - margin)
    end

    self._root:set_absolute_pos(x, y)
end

return M

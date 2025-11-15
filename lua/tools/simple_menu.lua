-- Original SimpleMenu Updated By AntonisK1 To Handle Pagination

if not SimpleMenu then
    SimpleMenu = class()

    function SimpleMenu:init(title, message, options, page_size)
        self.dialog_data = {
            title = title,
            text = message,
            button_list = {},
            id = tostring(math.random(0, 0xFFFFFFFF))
        }
        self.visible = false
        self.options = options
        self.page_size = page_size or #options  -- default: no pagination
        self.current_page = 1
        self:_update_buttons()
        return self
    end

    function SimpleMenu:_update_buttons()
        self.dialog_data.button_list = {}

        -- Page indicator at the top
        if #self.options > self.page_size then
            self.dialog_data.text = string.format("%s\n(Page %d/%d)", 
                self.dialog_data.title or "", self.current_page, math.ceil(#self.options / self.page_size))
        end

        -- Buttons for current page
        local start_idx = (self.current_page - 1) * self.page_size + 1
        local end_idx = math.min(start_idx + self.page_size - 1, #self.options)
        for i = start_idx, end_idx do
            local opt = self.options[i]
            local elem = {}
            elem.text = opt.text
            opt.data = opt.data or nil
            opt.callback = opt.callback or nil
            elem.callback_func = callback(self, self, "_do_callback", {
                data = opt.data,
                callback = opt.callback
            })
            elem.cancel_button = opt.is_cancel_button or false
            if opt.is_focused_button then
                self.dialog_data.focus_button = #self.dialog_data.button_list + 1
            end
            table.insert(self.dialog_data.button_list, elem)
        end

        -- Add Prev Page button if needed
        if self.current_page > 1 then
            table.insert(self.dialog_data.button_list, 1, {
                text = "« Prev Page",
                callback_func = callback(self, self, "prev_page"),
                cancel_button = false
            })
            table.insert(self.dialog_data.button_list, 2, {})
            if self.dialog_data.focus_button then
                self.dialog_data.focus_button = self.dialog_data.focus_button + 1
            end
        end

        -- Add Next Page button if needed
        if self.current_page * self.page_size < #self.options then
            table.insert(self.dialog_data.button_list, {})
            table.insert(self.dialog_data.button_list, {
                text = "Next Page »",
                callback_func = callback(self, self, "next_page"),
                cancel_button = false
            })
        end
    end

    function SimpleMenu:next_page()
        if self.current_page * self.page_size < #self.options then
            self.current_page = self.current_page + 1
            self:_update_buttons()
            self.dialog_data.focus_button = nil
            if self.visible then
                self.dialog_data.id = tostring(math.random(0, 0xFFFFFFFF))
                managers.system_menu:close(self.dialog_data.id)
                managers.system_menu:show(self.dialog_data)
            end
        end
    end

    function SimpleMenu:prev_page()
        if self.current_page > 1 then
            self.current_page = self.current_page - 1
            self:_update_buttons()
            self.dialog_data.focus_button = nil
            if self.visible then
                self.dialog_data.id = tostring(math.random(0, 0xFFFFFFFF))
                managers.system_menu:close(self.dialog_data.id)
                managers.system_menu:show(self.dialog_data)
            end
        end
    end

    function SimpleMenu:_do_callback(info)
        if info.callback then
            if info.data then
                info.callback(info.data)
            else
                info.callback()
            end
        end
        self.visible = false
    end

    function SimpleMenu:show()
        if self.visible then
            return
        end
        self.visible = true
        managers.system_menu:show(self.dialog_data)
    end

    function SimpleMenu:hide()
        if self.visible then
            managers.system_menu:close(self.dialog_data.id)
            self.visible = false
            return
        end
    end

    -- Adjust controller input to handle pagination
    function SimpleMenu:change_focus_button(dir)
        local focus = self.dialog_data.focus_button or 1
        local new_focus = focus + dir
        local max_buttons = #self.dialog_data.button_list

        if new_focus < 1 then
            if self.current_page > 1 then
                self:prev_page()
                self.dialog_data.focus_button = #self.dialog_data.button_list
            else
                self.dialog_data.focus_button = 1
            end
        elseif new_focus > max_buttons then
            if self.current_page * self.page_size < #self.options then
                self:next_page()
                self.dialog_data.focus_button = 1
            else
                self.dialog_data.focus_button = max_buttons
            end
        else
            self.dialog_data.focus_button = new_focus
        end
        if self.visible then
            managers.system_menu:show(self.dialog_data)
        end
    end

end

-- Patch input to use the new change_focus_button logic
patched_update_input = patched_update_input or function(self, t, dt)
    if self._data.no_buttons then
        return
    end
    local dir, move_time
    local move = self._controller:get_input_axis("menu_move")
    if (self._controller:get_input_bool("menu_down")) then
        dir = 1
    elseif (self._controller:get_input_bool("menu_up")) then
        dir = -1
    end
    if dir == nil then
        if move.y > self.MOVE_AXIS_LIMIT then
            dir = 1
        elseif move.y < -self.MOVE_AXIS_LIMIT then
            dir = -1
        end
    end
    if dir ~= nil then
        if ((self._move_button_dir == dir) and self._move_button_time and
            (t < self._move_button_time + self.MOVE_AXIS_DELAY)) then
            move_time = self._move_button_time or t
        else
            if self._panel_script.change_focus_button then
                self._panel_script:change_focus_button(dir)
            end
            move_time = t
        end
    end
    self._move_button_dir = dir
    self._move_button_time = move_time
    local scroll = self._controller:get_input_axis("menu_scroll")
    if (scroll.y > self.MOVE_AXIS_LIMIT) then
        if self._panel_script.scroll_up then self._panel_script:scroll_up() end
    elseif (scroll.y < -self.MOVE_AXIS_LIMIT) then
        if self._panel_script.scroll_down then self._panel_script:scroll_down() end
    end
end
managers.system_menu.DIALOG_CLASS.update_input = patched_update_input
managers.system_menu.GENERIC_DIALOG_CLASS.update_input = patched_update_input

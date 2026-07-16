return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        local set = vim.keymap.set

        set({ "n", "x" }, "<a-[>", function() mc.lineAddCursor(-1) end, { desc = "MultiCursor: курсор выше" })
        set({ "n", "x" }, "<a-]>", function() mc.lineAddCursor(1) end, { desc = "MultiCursor: курсор ниже" })

        set({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end, { desc = "MultiCursor: добавить совпадение вниз" })
        set({ "n", "x" }, "<leader>s", function() mc.matchSkipCursor(1) end, { desc = "MultiCursor: пропустить совпадение вниз" })
        set({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end, { desc = "MultiCursor: добавить совпадение вверх" })
        set({ "n", "x" }, "<leader>S", function() mc.matchSkipCursor(-1) end, { desc = "MultiCursor: пропустить совпадение вверх" })

        set("n", "<c-leftmouse>", mc.handleMouse, { desc = "MultiCursor: добавить кликом" })
        set("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "MultiCursor: добавить драгом" })
        set("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "MultiCursor: завершить драг" })

        set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "MultiCursor: тоггл курсора" })

        mc.addKeymapLayer(function(layerSet)
            layerSet({ "n", "x" }, "<left>", mc.prevCursor)
            layerSet({ "n", "x" }, "<right>", mc.nextCursor)

            layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

            layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        -- Customize how cursors look.
        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { reverse = true })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn" })
        hl(0, "MultiCursorMatchPreview", { link = "Search" })
        hl(0, "MultiCursorDisabledCursor", { reverse = true })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end
}

return {
    "ahmedkhalf/project.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("project_nvim").setup({
            detection_methods = { "pattern", "lsp" },
            patterns = { ".git", "package.json", "pyproject.toml", "Makefile" },
            silent_chdir = true,
            scope_chdir = 'global',
        })

        -- Автоматическое определение проектов
        require("telescope").load_extension("projects")

        -- Фикс: delete_project оставлял nil-дыры в массиве, ломая повторное удаление
        local history = require("project_nvim.utils.history")
        local orig_delete = history.delete_project
        history.delete_project = function(project)
            for k, v in ipairs(history.recent_projects) do
                if v == project.value then
                    table.remove(history.recent_projects, k)
                    break
                end
            end
        end
    end
}

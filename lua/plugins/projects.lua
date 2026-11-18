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

        -- Удалять проект из истории и текущего сеанса без разрывов в массивах
        local history = require("project_nvim.utils.history")
        history.delete_project = function(project)
            for _, key in ipairs({ "recent_projects", "session_projects" }) do
                local projects = history[key]
                if projects then
                    for i = #projects, 1, -1 do
                        if projects[i] == project.value then
                            table.remove(projects, i)
                        end
                    end
                end
            end
        end
    end
}

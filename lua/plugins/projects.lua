return {
    "ahmedkhalf/project.nvim",
    config = function()
        require("project_nvim").setup({
            detection_methods = { "pattern", "lsp" },
            patterns = { ".git", "package.json", "pyproject.toml", "Makefile" },
            silent_chdir = true,
            scope_chdir = 'global',
        })

        -- Автоматическое определение проектов
        require("telescope").load_extension("projects")
    end
}

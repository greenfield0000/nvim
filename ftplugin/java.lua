local home = os.getenv("HOME")
local jdtls = require("jdtls")
local fn = vim.fn

-- === СОСТОЯНИЕ: 1 JDTLS НА ПРОЕКТ ===
vim.g.jdtls_state = vim.g.jdtls_state or {
    active_root = nil,
    active_workspace = nil,
    running = false
}

-- === РАСШИРЕННЫЙ ПОИСК JAVA_HOME из SDKMAN ===
local function get_java_home()
    -- Fallback на current
    local current = home .. "/.sdkman/candidates/java/current"
    if fn.isdirectory(current) == 1 then return current end

    return nil
end

-- === Все JDK из SDKMAN ===
local function get_all_runtimes()
    local runtimes = {}
    local base = home .. "/.sdkman/candidates/java"
    local handle = io.popen('find "' .. base .. '" -maxdepth 1 -type d -name "[0-9]*" -printf "%f\n" 2>/dev/null')
    if handle then
        for version in handle:lines() do
            local path = base .. "/" .. version
            if version ~= "current" then
                table.insert(runtimes, { name = "JavaSE-" .. version, path = path })
            end
        end
        handle:close()
    end
    return runtimes
end

-- === OS детектор ===
local function detect_os()
    local uname = vim.loop.os_uname().sysname
    if uname == "Darwin" then
        return "mac"
    elseif uname == "Windows_NT" then
        return "win"
    else
        return "linux"
    end
end

-- === DAP для тестов ===
local function setup_dap()
    local dap = require("dap")
    dap.configurations.java = {
        {
            type = 'java',
            request = 'attach',
            name = "Debug (Attach) - Remote",
            hostName = "127.0.0.1",
            port = 5005,
        },
        {
            type = 'java',
            request = 'launch',
            name = "Launch Java File",
            mainClass = "${file}",
            projectName = "${fileBasenameNoExtension}",
        },
        {
            type = 'java',
            request = 'launch',
            name = "Run Current Test",
            vmArgs = "-Xmx2048m -XX:+ShowCodeDetailsInExceptionMessages",
            mainClass = "org.junit.platform.console.ConsoleLauncher",
            args = { "--scan-classpath", "--include-classname", "${file}" },
            projectName = "${fileBasenameNoExtension}",
        }
    }
end

-- === on_attach ===
local on_attach = function(_, bufnr)
    require 'jdtls.setup'.add_commands()
    vim.lsp.codelens.refresh()

    -- local status_ok, signature = pcall(require, "lsp_signature")
    -- if status_ok then
    --     signature.on_attach({
    --         bind = true, padding = "", handler_opts = { border = "rounded" }, hint_prefix = "󱄑 ",
    --     }, bufnr)
    --     require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    -- end

    local map = function(mode, lhs, rhs, desc)
        if desc then desc = "JDTLS: " .. desc end
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr })
    end

    map('n', '<leader>tc', function() require('jdtls').test_class() end, "Test Class")
    map('n', '<leader>tm', function() require('jdtls').test_nearest_method() end, "Test Nearest Method")
    map('n', '<leader>tp', function() require('jdtls').pick_test() end, "Pick Test")
    map('n', '<leader>tdc', function()
        require('jdtls.dap').test_class()
        setup_dap()
    end, "Debug Test Class")
    map('n', '<leader>tdm', function()
        require('jdtls.dap').test_nearest_method()
        setup_dap()
    end, "Debug Test Method")

    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr, callback = function() pcall(vim.lsp.codelens.refresh) end
    })
    -- setup_dap()
end

-- === 🎯 ГЛАВНАЯ ФУНКЦИЯ: АВТОЗАПУСК + SMART ATTACH ===
local function smart_start_jdtls()
    local bufnr = vim.api.nvim_get_current_buf()

    -- 🚀 АВТОЗАПУСК ДЛЯ ЛЮБОГО .java файла
    if vim.bo[bufnr].filetype ~= "java" then return end

    -- 🔍 НАЙДИМ ROOT ПРОЕКТА ДЛЯ ТЕКУЩЕГО ФАЙЛА
    local current_file = vim.api.nvim_buf_get_name(bufnr)
    local current_root = require("jdtls.setup").find_root({
        ".git", "gradlew", "build.gradle", "pom.xml"
    }, current_file)

    if not current_root then
        vim.notify("No Java project root found for: " .. fn.fnamemodify(current_file, ":t"), vim.log.levels.WARN)
        return
    end

    -- ✅ ✅ ✅ ТОТ ЖЕ ПРОЕКТ = ПРОСТО ATTACH (мгновенно!)
    if vim.g.jdtls_state.active_root == current_root then
        local clients = vim.lsp.get_clients({ name = "jdtls" })
        if #clients > 0 then
            vim.lsp.buf_attach_client(bufnr, clients[1].id)
            return
        end
    end

    -- 🛑 НОВЫЙ ПРОЕКТ → УБИРАЕМ СТАРЫЙ JDTLS
    local all_jdtls = vim.lsp.get_active_clients({ name = "jdtls" })
    for _, client in ipairs(all_jdtls) do
        pcall(client.stop)
    end

    -- 🔥 СОХРАНЯЕМ НОВЫЙ ПРОЕКТ
    local project_name = fn.fnamemodify(current_root, ":p:h:t")
    vim.g.jdtls_state = {
        active_root = current_root,
        active_workspace = project_name,
        running = false,
        last_updated = vim.loop.now()
    }

    vim.notify("🚀 jdtls started: " .. project_name, vim.log.levels.INFO)

    -- === НАСТРОЙКИ JDTLS (ВАШИ ОРИГИНАЛЬНЫЕ) ===
    local java_home = get_java_home()
    if not java_home then
        vim.notify("Java home not found in SDKMAN!", vim.log.levels.ERROR)
        return
    end

    local runtimes = get_all_runtimes()
    -- table.insert(runtimes, 1, { name = "JavaSDK", path = java_home, default = true })

    local jdtls_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
    local launcher = fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)[1]
    if not launcher then
        vim.notify("JDTLS launcher not found!", vim.log.levels.ERROR)
        return
    end

    local config_os = detect_os()
    local workspace_dir = home .. "/.workspace/" .. project_name

    local lombok_path = fn.glob(jdtls_dir .. "/lombok.jar")
    local javaagent_opts = {}
    if lombok_path ~= "" then
        table.insert(javaagent_opts, "-javaagent:" .. lombok_path)
    end

    local bundles = {
        fn.glob(
            home ..
            "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
            1)
    }

    local java_test_bundles = fn.split(
        fn.glob(home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", 1), "\n")
    local excluded = { "com.microsoft.java.test.runner-jar-with-dependencies.jar", "jacocoagent.jar" }
    for _, java_test_jar in ipairs(java_test_bundles) do
        if java_test_jar ~= "" then
            local fname = fn.fnamemodify(java_test_jar, ":t")
            if not vim.tbl_contains(excluded, fname) then
                table.insert(bundles, java_test_jar)
            end
        end
    end

    local cmd = {
        java_home .. "/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher,
        "-configuration", jdtls_dir .. "/config_" .. config_os,
        "-data", workspace_dir,
    }

    if #javaagent_opts > 0 then
        for i = #javaagent_opts, 1, -1 do
            table.insert(cmd, 2, javaagent_opts[i])
        end
    end

    local config = {
        cmd = cmd,
        root_dir = current_root,
        init_options = {
            bundles = bundles,
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
        settings = {
            java = {
                search = {
                    scope = "main"
                },
                documentation = {
                    enabled = true,
                    includeLibraryDocumentation = true,
                },
                eclipse = {
                    downloadSources = true,
                },
                configuration = {
                    runtimes = runtimes,
                    updateBuildConfiguration = "interactive",
                },
                format = { enabled = true },
                completion = {
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.junit.jupiter.api.DynamicTest.*",
                        "org.junit.jupiter.api.DynamicContainer.*",
                        "org.mockito.Mockito.*",
                        "org.mockito.ArgumentMatchers.*",
                        "org.mockito.Answers.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                    },
                },
                test = {
                    enabled = true,
                    autoTrack = true,
                    showProgress = true,
                    defaultConfig = "JUnit5",
                    configurations = {
                        {
                            name = "JUnit5",
                            workingDirectory = "${workspaceFolder}",
                            vmargs = "-Xmx1024m",
                            env = {},
                            args = {}
                        },
                        {
                            name = "JUnit4",
                            workingDirectory = "${workspaceFolder}",
                            vmargs = "-Xmx1024m",
                            env = {},
                            args = {}
                        }
                    }
                },
                signatureHelp = { enabled = true, description = { enabled = false } },
                contentProvider = { preferred = "fernflower" },
                saveActions = { organizeImports = false },
                implementationsCodeLens = { enabled = true },
                referencesCodeLens = { enabled = true },
                inlayHints = { parameterNames = { enabled = "all" } },
                codeGeneration = {
                    useBlocks = true,
                    generateComments = true,
                    insertLocation = true,
                    toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" }
                },
                autobuild = { enabled = true },
                progressReports = { enabled = true },
                maven = { downloadSources = true, updateSnapshots = true }
            }
        },
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    jdtls.start_or_attach(config)
    vim.g.jdtls_state.running = true
end

-- === 🚀 АВТОЗАПУСК ПРИ ОТКРЫТИИ ЛЮБОГО .java ФАЙЛА ===
vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufEnter" }, {
    pattern = "*.java",
    group = vim.api.nvim_create_augroup("JdtlsAutoStart", { clear = true }),
    callback = function()
        vim.defer_fn(smart_start_jdtls, 50)
    end,
    desc = "Auto-start jdtls for ANY .java file"
})

-- === РУЧНЫЕ КОМАНДЫ ===
vim.api.nvim_create_user_command('JdtlsRestart', smart_start_jdtls, {})

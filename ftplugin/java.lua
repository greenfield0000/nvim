-- ftplugin/java.lua (улучшенная и исправленная версия)
local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end

local home = os.getenv("HOME")
local fn = vim.fn

-- === HELPERS: проектный корень и чтение файлов ======================
local function project_root()
    return require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle", "mvnw", "gradlew" })
end

---@diagnostic disable-next-line: unused-function
local function read_file_lines(path)
    local lines = {}
    local f = io.open(path, "r")
    if not f then return lines end
    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()
    return lines
end

-- === Получаем все JDK из SDKMAN (как таблицу путей) =================
local function get_all_runtimes()
    local runtimes = {}
    local base = home .. "/.sdkman/candidates/java"
    if fn.isdirectory(base) ~= 1 then
        return runtimes
    end

    local entries = fn.readdir(base) or {}
    for _, name in ipairs(entries) do
        local path = base .. "/" .. name
        if fn.isdirectory(path) == 1 and name ~= "current" then
            table.insert(runtimes, { name = name, path = path })
        end
    end

    -- Ensure 'current' (SDKMAN current) is included as fallback
    local current = home .. "/.sdkman/candidates/java/current"
    if fn.isdirectory(current) == 1 then
        table.insert(runtimes, 1, { name = "current", path = current })
    end

    return runtimes
end

-- === Найти JDK по мажорной версии (например "11" или "17") ===========
local function get_jdk_by_version(version_major)
    if not version_major then
        return nil
    end

    local runtimes = get_all_runtimes()
    -- сначала точное совпадение по началу имени (например "11.0.12-..." или "11")
    for _, runtime in ipairs(runtimes) do
        local n = runtime.name
        if n:match("^" .. vim.pesc(version_major) .. "[.%-%w]*") then
            return runtime.path
        end
    end

    -- далее ищем в пути
    for _, runtime in ipairs(runtimes) do
        if runtime.path:match("/" .. vim.pesc(version_major) .. "[.%-%w]*$") then
            return runtime.path
        end
    end

    -- fallback на current
    local current = home .. "/.sdkman/candidates/java/current"
    if fn.isdirectory(current) == 1 then
        return current
    end

    return nil
end

-- === Извлекаем требуемую версию Java из pom.xml или build.gradle =====
local function java_version_from_build()
    return "21"
    -- local root = project_root()
    -- if not root then return nil end
    --
    -- -- pom.xml
    -- local pom = root .. "/pom.xml"
    -- if fn.filereadable(pom) == 1 then
    --     for _, line in ipairs(read_file_lines(pom)) do
    --         local v = line:match("<maven%.compiler%.source>(%d+)</maven%.compiler%.source>")
    --         if v then return v end
    --         v = line:match("<java%.version>(%d+)</java%.version>")
    --         if v then return v end
    --         v = line:match("<source>(%d+)</source>")
    --         if v then return v end
    --     end
    -- end
    --
    -- -- build.gradle (simple match)
    -- local gradle = root .. "/build.gradle"
    -- if fn.filereadable(gradle) == 1 then
    --     for _, line in ipairs(read_file_lines(gradle)) do
    --         local v = line:match("sourceCompatibility%s*=%s*['\"]?(%d+)['\"]?")
    --         if v then return v end
    --         v = line:match("targetCompatibility%s*=%s*['\"]?(%d+)['\"]?")
    --         if v then return v end
    --     end
    -- end
    --
    -- return nil
end

-- === Получаем java_home для проекта: сначала из build, иначе sdkman current
local function get_java_home()
    local v = java_version_from_build()
    if v then
        local byver = get_jdk_by_version(v)
        if byver then return byver end
    end

    local sdk_current = home .. "/.sdkman/candidates/java/current"
    if fn.isdirectory(sdk_current) == 1 then
        return sdk_current
    end

    return nil
end

local function debug_test(test_fn)
    return function()
        local dapui_ok, dapui = pcall(require, "dapui")
        local dap_ok, dap = pcall(require, "dap")

        -- Если сессия уже запущена, завершаем её
        if dap_ok and dap.session() then
            dap.terminate()
            if dapui_ok then dapui.close() end
            vim.defer_fn(function() end, 200)
        end

        -- Настраиваем listeners
        if dap_ok and dapui_ok then
            local listener_id = "jdtls_test_debug"

            -- Очищаем старые listeners
            dap.listeners.after.event_initialized[listener_id] = nil
            dap.listeners.before.event_terminated[listener_id] = nil
            dap.listeners.before.event_exited[listener_id] = nil

            dap.listeners.after.event_initialized[listener_id] = function()
                dapui.open()
            end

            local cleanup = function()
                dapui.close()
                dap.listeners.after.event_initialized[listener_id] = nil
                dap.listeners.before.event_terminated[listener_id] = nil
                dap.listeners.before.event_exited[listener_id] = nil
            end

            dap.listeners.before.event_terminated[listener_id] = cleanup
            dap.listeners.before.event_exited[listener_id] = cleanup
        end

        test_fn()
    end
end

-- === DAP конфигурация для тестирования ====================
local function setup_dap()
    local dap = require("dap")

    -- Конфигурация для Java
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
            args = {
                "--scan-classpath",
                "--include-classname",
                "${file}",
            },
            projectName = "${fileBasenameNoExtension}",
        }
    }
end

-- Function that will be ran once the language server is attached
local on_attach = function(_, bufnr)
    require('jdtls.setup').add_commands()
    vim.lsp.codelens.refresh()

    -- 1) Включаем DAP интеграцию от jdtls
    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    require('jdtls.dap').setup_dap_main_class_configs()

    -- 2) Автооткрытие DAP UI и REPL при старте сессии
    local ok_dap, dap = pcall(require, 'dap')
    if ok_dap then
        dap.listeners.after.event_initialized['jdtls_repl'] = function()
            -- Откройте REPL; если используете dapui, откройте его тоже
            pcall(function() require('dap').repl.open() end)
            pcall(function() require('dapui').open() end)
        end
        -- Опционально: автозакрытие
        dap.listeners.before.event_terminated['jdtls_repl'] = function()
            pcall(function() require('dapui').close() end)
        end
        dap.listeners.before.event_exited['jdtls_repl'] = function()
            pcall(function() require('dapui').close() end)
        end
    end
    local status_ok, signature = pcall(require, "lsp_signature")
    if status_ok then
        signature.on_attach({
            bind = true,
            padding = "",
            handler_opts = { border = "rounded" },
            hint_prefix = "󱄑 ",
        }, bufnr)
        -- require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    end

    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr })
    end

    -- Тестирование
    map('n', '<leader>tc', function() require('jdtls').test_class() end, "Test Class")
    map('n', '<leader>tm', function() require('jdtls').test_nearest_method() end, "Test Nearest Method")
    map('n', '<leader>tp', function() require('jdtls').pick_test() end, "Pick Test")
    -- Отладка тестов
    map('n', '<leader>tdc', function() require('jdtls.dap').test_class() end, "Debug Test Class")
    map('n', '<leader>tdm', function() require('jdtls.dap').test_nearest_method() end, "Debug Test Method")
    -- Code lens для тестов
    map('n', '<leader>tl', function() vim.lsp.codelens.run() end, "Run Code Lens")
    -- Генерация тестов
    map('n', '<leader>tg', function() require('jdtls').generate_test() end, "Generate Test")

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function() pcall(vim.lsp.codelens.refresh) end
    })
end

-- === Получить список bundles =
local function get_bundles()
    local bundles = {}

    -- java-debug bundle
    local dbg = vim.fn.glob(
        home ..
        "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
        1)
    if dbg ~= "" then table.insert(bundles, dbg) end

    -- java-test bundles (исключаем ненужные файлы)
    local java_test_glob = vim.fn.glob(home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", 1)
    if java_test_glob ~= "" then
        for _, jar in ipairs(vim.split(java_test_glob, "\n")) do
            local fname = vim.fn.fnamemodify(jar, ":t")
            -- Исключаем вспомогательные jar файлы
            if
            -- fname ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar"
            -- and
                fname ~= "jacocoagent.jar"
                and jar ~= "" then
                table.insert(bundles, jar)
            end
        end
    end

    return bundles
end

-- === start_jdtls: собираем cmd, bundles и запускаем ==================
local function start_jdtls()
    local java_home = get_java_home()
    local runtimes = get_all_runtimes()

    -- Приводим runtimes в формат jdtls ожидает
    local runtime_entries = {}
    for _, r in ipairs(runtimes) do
        table.insert(runtime_entries, { name = "JavaSE-" .. r.name, path = r.path })
    end

    -- Вставляем java_home (если есть) как первый runtime с флагом default
    if java_home and fn.isdirectory(java_home) == 1 then
        table.insert(runtime_entries, 1, { name = "ProjectJava", path = java_home, default = true })
    end

    local jdtls_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
    local launcher_list = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)
    if #launcher_list == 0 then
        vim.notify("JDTLS launcher not found in mason packages!", vim.log.levels.ERROR)
        return java_home
    end
    local launcher = launcher_list[1]

    local config_os = (function()
        local uname = vim.loop.os_uname().sysname
        if uname == "Darwin" then return "mac" elseif uname == "Windows_NT" then return "win" else return "linux" end
    end)()

    local config_dir = jdtls_dir .. "/config_" .. config_os
    local project_name = fn.fnamemodify(fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.workspace/" .. project_name

    -- lombok javaagent (если есть)
    local lombok_path = vim.fn.glob(jdtls_dir .. "/lombok.jar")
    local javaagent_opts = {}
    if lombok_path ~= "" then
        table.insert(javaagent_opts, "-javaagent:" .. lombok_path)
    end

    local bundles = get_bundles()

    -- Собираем cmd
    local java_exec = "java"
    if java_home and fn.isdirectory(java_home) == 1 then
        local candidate = java_home .. "/bin/java"
        if fn.filereadable(candidate) == 1 then
            java_exec = candidate
        end
    end

    local cmd = {
        java_exec,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Daether.connector.https.securityMode=insecure",
        "-Dmaven.wagon.http.ssl.insecure=true",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher,
        "-configuration", config_dir,
        "-data", workspace_dir,
    }

    -- Вставляем javaagent опции (в начало аргументов после java_exec)
    if #javaagent_opts > 0 then
        for i = #javaagent_opts, 1, -1 do
            table.insert(cmd, 2, javaagent_opts[i])
        end
    end

    local root_dir = project_root()
    if not root_dir then
        vim.notify("No Java project root found!", vim.log.levels.WARN)
        return java_home
    end

    -- setup_test_icons()
    -- setup_test_notifications()

    local config = {
        cmd = cmd,
        root_dir = root_dir,
        init_options = {
            bundles = bundles,
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
        settings = {
            java = {
                eclipse = {
                    downloadSources = false,
                },
                configuration = {
                    runtimes = runtime_entries,
                    updateBuildConfiguration = "automatic",
                },
                format = {
                    enabled = true,
                },
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
                    result = {
                        success = "✅",
                        failure = "❌",
                        ignored = "⚠️",
                        running = "⏳",
                    },
                    configurations = {
                        {
                            name = "JUnit5",
                            workingDirectory = "${workspaceFolder}",
                            -- vmargs = "-Xmx1024m -javaagent:" ..
                            --     home ..
                            --     "/.local/share/nvim/mason/packages/java-test/extension/server/jacocoagent.jar=destfile=build/jacoco.exec,append=true",
                            env = {},
                            args = {}
                        },
                        {
                            name = "JUnit4",
                            workingDirectory = "${workspaceFolder}",
                            -- vmargs = "-Xmx1024m -javaagent:" ..
                            --     home ..
                            --     "/.local/share/nvim/mason/packages/java-test/extension/server/jacocoagent.jar=destfile=build/jacoco.exec,append=true",
                            env = {},
                            args = {}
                        }
                    }
                },
                signatureHelp = { enabled = true, description = { enabled = true } },
                contentProvider = { preferred = "fernflower" },
                saveActions = { organizeImports = false },
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all"
                    }
                },
                codeGeneration = {
                    useBlocks = true,
                    generateComments = true,
                    insertLocation = true,
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                    }
                },
                autobuild = { enabled = false },
                progressReports = { enabled = false },
                maven = {
                    disableTestClasspathFlag = false,
                    downloadSources = false,
                    updateSnapshots = false
                },
            }
        },
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    jdtls.start_or_attach(config)

    return java_home
end

-- === setup_jdtls: attach or start если нужно =========================
---@diagnostic disable-next-line: unused-function
local function setup_jdtls()
    -- Если клиент уже прикреплён к буферу - выход
    local buf_clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
    for _, client in ipairs(buf_clients) do
        if client.name == "jdtls" then return end
    end

    local global_clients = vim.lsp.get_active_clients()
    local jdtls_running = false
    for _, c in ipairs(global_clients) do
        if c.name == "jdtls" then
            jdtls_running = true; break
        end
    end

    if not jdtls_running then
        start_jdtls()
    else
        -- Attach к существующему клиенту
        local clients = vim.lsp.get_active_clients({ name = 'jdtls' })
        if clients and clients[1] then
            vim.lsp.buf_attach_client(0, clients[1].id)
        end
    end
end

-- === Инициализация =
start_jdtls()

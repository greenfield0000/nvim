local home = os.getenv("HOME")
local jdtls = require("jdtls")
local fn = vim.fn

-- === Определение Java из Maven/Gradle ======================
local function java_from_build()
    local pom = fn.getcwd() .. "/pom.xml"
    if fn.filereadable(pom) == 1 then
        for line in io.lines(pom) do
            local v = line:match("<maven%.compiler%.source>(%d+)</maven%.compiler%.source>")
            if v then
                local path = home .. "/.sdkman/candidates/java/" .. v .. ".0.0" -- SDKMAN использует версии с .0.0
                if fn.isdirectory(path) == 1 then return path end

                -- Попробуем без .0.0
                path = home .. "/.sdkman/candidates/java/" .. v
                if fn.isdirectory(path) == 1 then return path end
            end
        end
    end

    local gradle = fn.getcwd() .. "/build.gradle"
    if fn.filereadable(gradle) == 1 then
        for line in io.lines(gradle) do
            local v = line:match("sourceCompatibility%s*=%s*['\"]?(%d+)['\"]?")
            if v then
                local path = home .. "/.sdkman/candidates/java/" .. v .. ".0.0"
                if fn.isdirectory(path) == 1 then return path end

                path = home .. "/.sdkman/candidates/java/" .. v
                if fn.isdirectory(path) == 1 then return path end
            end
        end
    end

    return nil
end

-- === Получаем JAVA_HOME для проекта ========================
local function get_java_home()
    return java_from_build() or (home .. "/.sdkman/candidates/java/current")
end

-- === Собираем все JDK из SDKMAN ============================
local function get_all_runtimes()
    local runtimes = {}
    local base = home .. "/.sdkman/candidates/java"

    -- Более надежный способ получения версий
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

-- === Определяем OS динамически =============================
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

-- === Получение Java версии из pom.xml ====================
local function get_java_version_from_pom()
    local root_dir = require("jdtls.setup").find_root({ "pom.xml" })
    if not root_dir then
        return nil, "No pom.xml found"
    end

    local pom_file = root_dir .. "/pom.xml"
    if vim.fn.filereadable(pom_file) ~= 1 then
        return nil, "pom.xml not readable"
    end

    -- Парсим pom.xml для получения версии Java
    for line in io.lines(pom_file) do
        -- Ищем версию в properties
        local version = line:match("<maven%.compiler%.source>(%d+)</maven%.compiler%.source>")
        if version then
            return version
        end

        -- Ищем в plugin configuration
        version = line:match("<source>(%d+)</source>")
        if version then
            return version
        end

        -- Ищем в общих properties
        version = line:match("<java%.version>(%d+)</java%.version>")
        if version then
            return version
        end
    end

    return nil, "Java version not found in pom.xml"
end
--
-- === Получение конкретной версии JDK из runtimes =========
local function get_jdk_by_version(version)
    local runtimes = get_all_runtimes()

    -- Ищем точное совпадение
    for _, runtime in ipairs(runtimes) do
        if runtime.path:match(version .. "$") or runtime.path:match(version .. ".%d+$") then
            return runtime
        end
    end

    -- Ищем частичное совпадение (например, "11" в "11.0.2")
    for _, runtime in ipairs(runtimes) do
        local runtime_version = runtime.path:match("/(%d+[%d.]*)$")
        if runtime_version and runtime_version:match("^" .. version) then
            return runtime
        end
    end

    return home .. "/.sdkman/candidates/java/11.0.12-open"
end

-- Специальная функция для JDK 11
local function get_jdk_11()
    return get_jdk_by_version("11")
end

local function show_coverage()
    local root_dir = require("jdtls.setup").find_root({ "pom.xml" })
    if not root_dir then
        vim.notify("❌ No Maven project found!", vim.log.levels.ERROR)
        return
    end

    -- Получаем Java из pom.xml
    local java_version = get_java_version_from_pom()
    -- local java_home = java_version and get_java_home_from_version(java_version) or get_java_home()
    local java_home = get_jdk_11()

    vim.notify("🧪 java home is " .. java_home)

    local index_html = root_dir .. "/target/jacoco-ut/index.html"

    -- Создаем временный файл для логов
    local log_file = "/tmp/maven_test_" .. os.time() .. ".log"

    vim.notify("🧪 Starting Maven tests in background...\nLogs: " .. log_file)

    -- Запускаем Maven wrapper если есть, иначе используем системный Maven
    local mvn_command = vim.fn.filereadable(root_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"


    vim.notify("🧪 Java home " .. java_home)

    -- Команда для запуска в фоне с логированием
    local cmd = string.format(
        -- "cd %s && JAVA_HOME=%s nohup %s clean test -Dmaven.wagon.http.ssl.insecure=true > %s 2>&1 & echo $!",
        "cd %s && mvn clean test -Dmaven.wagon.http.ssl.insecure=true > %s 2>&1 & echo $!",
        -- vim.fn.shellescape(root_dir),
        -- vim.fn.shellescape(java_home),
        mvn_command,
        vim.fn.shellescape(log_file)
    )

    -- Запускаем и получаем PID процесса
    local handle = io.popen(cmd)
    local pid = handle:read("*a"):gsub("%s+", "")
    handle:close()

    if pid and pid ~= "" then
        vim.notify("📝 Maven tests running in background (PID: " .. pid .. ")\nCheck logs: " .. log_file)

        -- Запускаем мониторинг процесса
        vim.fn.jobstart({ "sh", "-c", "while kill -0 " .. pid .. " 2>/dev/null; do sleep 2; done" }, {
            detach = false,
            on_exit = function()
                -- Когда процесс завершился
                vim.defer_fn(function()
                    -- Проверяем exit code через файл логов
                    local log_handle = io.open(log_file, "r")
                    if log_handle then
                        local content = log_handle:read("*a")
                        log_handle:close()

                        if content:find("BUILD SUCCESS") then
                            vim.notify("✅ Background tests completed successfully!")
                            if vim.fn.filereadable(index_html) == 1 then
                                vim.fn.jobstart({ "xdg-open", index_html }, { detach = true })
                            else
                                vim.notify("⚠️ Coverage report not found at: " .. index_html)
                            end
                        else
                            vim.notify("❌ Background tests failed. Check logs: " .. log_file, vim.log.levels.ERROR)
                        end
                    end
                end, 1000)
            end
        })
    else
        vim.notify("❌ Failed to start background tests", vim.log.levels.ERROR)
    end
end

-- === Кастомизация значков тестов =========================
local function setup_test_icons()
    local icons = {
        success = "✅",
        failure = "❌",
        error = "💥",
        running = "⏳",
        skipped = "⚠️",
    }

    jdtls.extendedClientCapabilities = jdtls.extendedClientCapabilities or {}
    jdtls.extendedClientCapabilities.testExplorer = {
        treeIconFailed = icons.failure,
        treeIconErrored = icons.error,
        treeIconRunning = icons.running,
        treeIconSkipped = icons.skipped,
        treeIconPassed = icons.success,

        statusIconFailed = icons.failure,
        statusIconErrored = icons.error,
        statusIconRunning = icons.running,
        statusIconSkipped = icons.skipped,
        statusIconPassed = icons.success,

        codeLensFailed = icons.failure,
        codeLensErrored = icons.error,
        codeLensRunning = icons.running,
        codeLensSkipped = icons.skipped,
        codeLensPassed = icons.success,
    }
end

-- === Кастомные уведомления для тестов ====================
local function setup_test_notifications()
    local notify_ok, notify = pcall(require, "notify")
    if not notify_ok then return end

    -- Переопределяем обработку результатов тестов
    vim.api.nvim_create_autocmd("User", {
        pattern = "JdtTestLaunch",
        callback = function()
            notify("🧪 Запуск тестов...", "info", { title = "Java Tests", timeout = 2000 })
        end
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "JdtTestFinished",
        callback = function(data)
            local result = data.data and data.data.result
            if result then
                local total = result.total or 0
                local passed = result.passed or 0
                local failed = result.failed or 0
                local skipped = result.skipped or 0

                if failed > 0 then
                    notify(string.format("❌ Тесты завершены: %d/%d успешно, %d провалено, %d пропущено",
                        passed, total, failed, skipped), "error", { title = "Java Tests", timeout = 5000 })
                else
                    notify(string.format("✅ Все тесты пройдены: %d/%d успешно, %d пропущено",
                        passed, total, skipped), "info", { title = "Java Tests", timeout = 3000 })
                end
            end
        end
    })
end

-- === DAP конфигурация для тестирования ====================
local function setup_dap()
    local dap_ok, dap = pcall(require, "dap")
    if not dap_ok then return end

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

-- === Умная отладка тестов с DAP UI =======================
local function debug_test(test_fn)
    return function()
        local dapui_ok, dapui = pcall(require, "dapui")
        local dap_ok, dap = pcall(require, "dap")

        -- Закрываем предыдущую сессию если есть
        if dap_ok and dap.session() then
            dap.terminate()
            if dapui_ok then
                dapui.close()
            end
            vim.wait(500) -- Даем время для закрытия
        end

        -- Настраиваем одноразовые listeners для этой сессии
        if dap_ok and dapui_ok then
            local listener_id = "jdtls_test_debug"

            -- Удаляем предыдущие listeners с таким же ID
            dap.listeners.after.event_initialized[listener_id] = nil
            dap.listeners.before.event_terminated[listener_id] = nil
            dap.listeners.before.event_exited[listener_id] = nil

            -- Добавляем новые listeners
            dap.listeners.after.event_initialized[listener_id] = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated[listener_id] = function()
                dapui.close()
                -- Очищаем listeners после завершения
                dap.listeners.after.event_initialized[listener_id] = nil
                dap.listeners.before.event_terminated[listener_id] = nil
                dap.listeners.before.event_exited[listener_id] = nil
            end

            dap.listeners.before.event_exited[listener_id] = function()
                dapui.close()
                -- Очищаем listeners после завершения
                dap.listeners.after.event_initialized[listener_id] = nil
                dap.listeners.before.event_terminated[listener_id] = nil
                dap.listeners.before.event_exited[listener_id] = nil
            end
        end

        -- Запускаем тест
        test_fn()
    end
end

-- Function that will be ran once the language server is attached
local on_attach = function(_, bufnr)
    -- Enable jdtls commands to be used in Neovim
    require 'jdtls.setup'.add_commands()

    -- Refresh the codelens
    vim.lsp.codelens.refresh()

    -- Setup signature help
    local status_ok, signature = pcall(require, "lsp_signature")
    if status_ok then
        signature.on_attach({
            bind = true,
            padding = "",
            handler_opts = {
                border = "rounded",
            },
            hint_prefix = "󱄑 ",
        }, bufnr)
        require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    end

    -- === Ключевые маппинги для тестирования ===============
    local map = function(mode, lhs, rhs, desc)
        -- if desc then
        --     desc = "JDTLS: " .. desc
        -- end
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr })
    end

    -- Тестирование
    map('n', '<leader>tc', function()
        require('jdtls').test_class()
    end, "Test Class")

    map('n', '<leader>tm', function()
        require('jdtls').test_nearest_method()
    end, "Test current Method")

    map('n', '<leader>tp', function()
        require('jdtls').pick_test()
    end, "Pick Test")

    -- Покрытие кода
    map('n', '<leader>tC', show_coverage, "Show Coverage Report")

    -- Отладка тестов
    map('n', '<leader>tdc', debug_test(function()
        require('jdtls.dap').test_class()
    end), "Debug Test Class")

    map('n', '<leader>tdm', debug_test(function()
        require('jdtls.dap').test_nearest_method()
    end), "Debug Test Method")
    --
    -- Если используете nvim-coverage, добавьте также:
    local coverage_ok, _ = pcall(require, "coverage")
    if coverage_ok then
        map('n', '<leader>cS', function()
            require("coverage").summary()
        end, "Coverage Summary")

        map('n', '<leader>cL', function()
            require("coverage").load()
        end, "Coverage Load")

        map('n', '<leader>cH', function()
            require("coverage").hide()
        end, "Coverage Hide")
    end

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function()
            pcall(vim.lsp.codelens.refresh)
        end
    })

    -- Инициализируем DAP
    setup_dap()
end

-- === Конфиг JDTLS с поддержкой Lombok =====================
local function start_jdtls()
    local java_home = get_java_home()
    local runtimes = get_all_runtimes()

    -- Добавляем текущую JAVA_HOME как default runtime
    local default_runtime = { name = "JavaSDK", path = java_home, default = true }
    table.insert(runtimes, 1, default_runtime)

    local jdtls_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
    local launcher = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)
    if #launcher == 0 then
        vim.notify("JDTLS launcher not found!", vim.log.levels.ERROR)
        return java_home
    end
    launcher = launcher[1]

    local config_os = detect_os()
    local config_dir = jdtls_dir .. "/config_" .. config_os
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.workspace/" .. project_name -- Изменен путь для избежания конфликтов

    -- === Авто-подключение lombok =================================
    local lombok_path = vim.fn.glob(jdtls_dir .. "/lombok.jar")
    local javaagent_opts = {}
    if lombok_path ~= "" then
        table.insert(javaagent_opts, "-javaagent:" .. lombok_path)
    end

    -- This bundles definition is the same as in the previous section (java-debug installation)
    local bundles = {
        vim.fn.glob(
            home ..
            "/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
            1)
    }

    -- This is the new part
    local java_test_bundles = vim.split(
        vim.fn.glob(
            home .. "/.local/share/nvim/mason/packages/java-test/extension/server/*.jar", 1
        ), "\n"
    )
    local excluded = {
        "com.microsoft.java.test.runner-jar-with-dependencies.jar",
        "jacocoagent.jar",
    }
    for _, java_test_jar in ipairs(java_test_bundles) do
        local fname = vim.fn.fnamemodify(java_test_jar, ":t")
        if not vim.tbl_contains(excluded, fname) then
            table.insert(bundles, java_test_jar)
        end
    end
    -- End of the new part

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
        "-configuration", config_dir,
        "-data", workspace_dir,
    }

    -- Добавляем javaagent опции в начало если есть
    if #javaagent_opts > 0 then
        for i = #javaagent_opts, 1, -1 do
            table.insert(cmd, 2, javaagent_opts[i])
        end
    end

    local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
    if not root_dir then
        vim.notify("No Java project root found!", vim.log.levels.WARN)
        return java_home
    end

    -- === Настройка кастомных значков тестов ===
    setup_test_icons()

    -- === Настройка кастомных уведомлений тестов ===
    setup_test_notifications()

    local config = {
        cmd = cmd,
        root_dir = root_dir,
        init_options = {
            bundles = bundles,
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
        settings = {
            java = {
                configuration = {
                    runtimes = runtimes,
                    updateBuildConfiguration = "interactive",
                },
                format = {
                    enabled = true,
                    settings = {
                        url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
                        profile = "GoogleStyle"
                    }
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
                -- === НАСТРОЙКИ ТЕСТИРОВАНИЯ =======================
                test = {
                    enabled = true,
                    -- Автоматически обновлять тесты при изменении кода
                    autoTrack = true,
                    -- Показывать отчет о тестировании
                    showProgress = true,
                    -- Конфигурация по умолчанию для запуска тестов
                    defaultConfig = "JUnit5",
                    -- === КАСТОМИЗАЦИЯ ЗНАЧКОВ ТЕСТОВ ===
                    result = {
                        success = "✅", -- Успешный тест
                        failure = "❌", -- Проваленный тест
                        ignored = "⚠️", -- Пропущенный тест
                        running = "⏳", -- Тест выполняется
                    },
                    -- Конфигурации тестов
                    configurations = {
                        {
                            name = "JUnit5",
                            workingDirectory = "${workspaceFolder}",
                            vmargs = "-Xmx1024m -javaagent:" ..
                                home ..
                                "/.local/share/nvim/mason/packages/java-test/extension/server/jacocoagent.jar=destfile=build/jacoco.exec,append=true",
                            env = {},
                            args = {}
                        },
                        {
                            name = "JUnit4",
                            workingDirectory = "${workspaceFolder}",
                            vmargs = "-Xmx1024m -javaagent:" ..
                                home ..
                                "/.local/share/nvim/mason/packages/java-test/extension/server/jacocoagent.jar=destfile=build/jacoco.exec,append=true",
                            env = {},
                            args = {}
                        }
                    }
                },
                signatureHelp = {
                    enabled = false,
                    description = {
                        enabled = true
                    }
                },
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
                autobuild = {
                    enabled = true
                },
                progressReports = {
                    enabled = false
                },
                maven = {
                    downloadSources = true,
                    updateSnapshots = true
                }
            }
        },
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    -- Запускаем JDTLS
    jdtls.start_or_attach(config)

    -- === Автокоманды для тестирования ========================
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
            -- Авто-обновление code lens при входе в буфер
            vim.schedule(function()
                vim.lsp.codelens.refresh()
            end)

            -- Настройка DAP конфигураций без автоматического показа UI
            local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
            if status_ok then
                jdtls_dap.setup_dap_main_class_configs()
            end
        end
    })

    -- Автоматическая загрузка покрытия после тестов
    vim.api.nvim_create_autocmd("User", {
        pattern = "JdtTestFinished",
        callback = function()
            if vim.b.coverage_enabled then
                vim.schedule(function()
                    local status_ok, coverage = pcall(require, "coverage")
                    if status_ok then
                        coverage.load()
                    end
                end)
            end
        end,
    })

    return java_home
end

-- === Основная инициализация ================================
if vim.bo.filetype == "java" then
    -- Отложенный запуск чтобы избежать конфликтов
    vim.defer_fn(function()
        if not vim.g.current_java_home then
            vim.g.current_java_home = start_jdtls()
        else
            local new_java_home = get_java_home()
            if vim.g.current_java_home ~= new_java_home then
                pcall(jdtls.stop)
                vim.g.current_java_home = start_jdtls()
            else
                start_jdtls() -- Просто attach если HOME не изменился
            end
        end
    end, 100)
end

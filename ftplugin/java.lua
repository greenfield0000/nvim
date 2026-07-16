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

-- === Путь к пакетам mason под любую ОС ===
local function mason_dir()
    if detect_os() == "win" then
        return home .. "/AppData/Local/nvim-data/mason/packages"
    else
        return home .. "/.local/share/nvim/mason/packages"
    end
end

-- === on_attach ===
local on_attach = function(_, bufnr)
    require 'jdtls.setup'.add_commands()
    vim.lsp.codelens.enable(true, { bufnr = bufnr })

    local map = function(mode, lhs, rhs, desc)
        if desc then desc = "JDTLS: " .. desc end
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr })
    end

    map('n', '<leader>tc', function() require('jdtls').test_class() end, "Test Class")
    map('n', '<leader>tm', function() require('jdtls').test_nearest_method() end, "Test Nearest Method")
    map('n', '<leader>tp', function() require('jdtls').pick_test() end, "Pick Test")
    map('n', '<leader>tg', function() require('jdtls.tests').generate() end, "Generate Test")

    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr, callback = function() pcall(vim.lsp.codelens.enable, true, { bufnr = bufnr }) end
    })
end

-- === 🎯 ГЛАВНАЯ ФУНКЦИЯ: АВТОЗАПУСК + SMART ATTACH ===
local function smart_start_jdtls()
    local bufnr = vim.api.nvim_get_current_buf()

    -- 🚀 АВТОЗАПУСК ДЛЯ ЛЮБОГО .java файла
    if vim.bo[bufnr].filetype ~= "java" then return end

    -- 🔍 НАЙДИМ ROOT ПРОЕКТА ДЛЯ ТЕКУЩЕГО ФАЙЛА
    local current_file = vim.api.nvim_buf_get_name(bufnr)
    local current_root = require("jdtls.setup").find_root({
        ".git",
        "gradlew",
        "build.gradle",
        "pom.xml"
    }, current_file)
    if current_root then current_root = vim.fn.resolve(current_root) end

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
    local all_jdtls = vim.lsp.get_clients({ name = "jdtls" })
    for _, client in ipairs(all_jdtls) do
        pcall(client.stop)
    end

    -- 🔥 СОХРАНЯЕМ НОВЫЙ ПРОЕКТ
    local project_name = fn.fnamemodify(current_root, ":t")

    vim.notify("🚀 jdtls starting: " .. project_name, vim.log.levels.INFO)

    -- === НАСТРОЙКИ JDTLS (ВАШИ ОРИГИНАЛЬНЫЕ) ===
    local java_home = get_java_home()
    if not java_home then
        vim.notify("Java home not found in SDKMAN!", vim.log.levels.ERROR)
        return
    end

    local runtimes = get_all_runtimes()
    -- table.insert(runtimes, 1, { name = "JavaSDK", path = java_home, default = true })

    local jdtls_dir = mason_dir() .. "/jdtls"
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

    local mason_java = mason_dir()

    local bundles = {}

    -- Совместимый asm для java-test (нужен [9.9.0, 9.10.0))
    local asm_jar = mason_java .. "/java-test/extension/server/org.objectweb.asm_9.9.1.jar"
    if fn.filereadable(asm_jar) == 0 then
        vim.fn.system({
            "curl", "-fsSL", "-o", asm_jar,
            "https://repo1.maven.org/maven2/org/ow2/asm/asm/9.9.1/asm-9.9.1.jar"
        })
    end
    table.insert(bundles, asm_jar)

    local function add_jar(dir, pattern)
        local jar = fn.glob(dir .. "/" .. pattern, 1, 1)
        if type(jar) == "table" and #jar > 0 then
            table.insert(bundles, jar[1])
        end
    end

    add_jar(mason_java .. "/java-debug-adapter/extension/server", "com.microsoft.java.debug.plugin-*.jar")
    add_jar(mason_java .. "/vscode-java-dependency/extension/server", "com.microsoft.jdtls.ext.core-*.jar")

    local java_test_jars = fn.glob(mason_java .. "/java-test/extension/server/*.jar", 1, 1)
    local java_test_excluded = {
        "com.microsoft.java.test.runner-jar-with-dependencies.jar",
        "jacocoagent.jar",
    }
    if type(java_test_jars) == "table" then
        for _, jar in ipairs(java_test_jars) do
            local fname = fn.fnamemodify(jar, ":t")
            if not vim.tbl_contains(java_test_excluded, fname) then
                table.insert(bundles, jar)
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
        -- '-Dmaven.repo.local=' .. vim.fn.expand("~/.m2/repository"),
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

    local cap = jdtls.extendedClientCapabilities

    local config = {
        cmd = cmd,
        root_dir = current_root,
        init_options = {
            bundles = bundles,
            extendedClientCapabilities = cap,
        },
        settings = {
            java = {
                -- implementationCodeLens = "all",
                implementationCodeLens = "none",
                referencesCodeLens = {
                    enabled = false,
                },
                decompiler = {
                    preferred = "fernflower",
                    fernflower = {
                        -- Форматирование
                        indent = "    ",
                        indentSize = 4,

                        -- Комментарии и документация
                        showJavadoc = true,  -- Показывать JavaDoc
                        keepComments = true, -- Сохранять комментарии

                        -- Логика декомпиляции
                        resolveAnonymousClasses = true,
                        hideDefaultConstructor = true,
                        removeSynthetic = true,
                        deobfuscate = true,

                        -- Отладка
                        showBytecode = false,
                        dumpText = true,
                    },
                },
                -- Включаем поддержку ссылок в документации
                signatures = {
                    enabled = true,
                    description = {
                        enabled = true,
                    },
                },
                -- Настройка для переходов
                references = {
                    includeDecompiledSources = true,
                    includeSource = true,
                },
                search = {
                    scope = "main",
                    typeHierarchy = {
                        lazyLoad = true,
                    }
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
                    updateBuildConfiguration = "automatic",
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
                signatureHelp = {
                    enabled = true,
                    description = { enabled = true }
                },
                contentProvider = {
                    preferred = "fernflower"
                },
                saveActions = { organizeImports = false },
                inlayHints = { parameterNames = { enabled = "all" } },
                codeGeneration = {
                    useBlocks = true,
                    generateComments = true,
                    insertLocation = true,
                    toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" }
                },
                autobuild = { enabled = true },
                progressReports = { enabled = true },
                maven = {
                    userSettings = vim.fn.expand("~/.m2/settings.xml"),
                    downloadSources = true,
                    updateSnapshots = true
                },
                gradle = {
                    enabled = false,
                },
                project = {}
            }
        },
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
    }

    -- 🔥 СОХРАНЯЕМ НОВЫЙ ПРОЕКТ
    vim.g.jdtls_state = {
        active_root = current_root,
        active_workspace = project_name,
        running = true,
        last_updated = vim.loop.now()
    }

    jdtls.start_or_attach(config)
end

-- === 🚀 АВТОЗАПУСК ПРИ ОТКРЫТИИ ЛЮБОГО .java ФАЙЛА ===
local jdtls_timer
vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufEnter" }, {
    pattern = "*.java",
    group = vim.api.nvim_create_augroup("JdtlsAutoStart", { clear = true }),
    callback = function()
        if jdtls_timer then pcall(jdtls_timer.close, jdtls_timer) end
        jdtls_timer = vim.defer_fn(smart_start_jdtls, 100)
    end,
    desc = "Auto-start jdtls for ANY .java file"
})

-- === РУЧНЫЕ КОМАНДЫ ===
vim.api.nvim_create_user_command('JdtlsRestart', smart_start_jdtls, {})

vim.api.nvim_create_user_command("JdtlsDownloadJavaSources", function()
    local project_root = vim.fn.getcwd()
    local cmd

    if vim.fn.filereadable(project_root .. "/pom.xml") == 1 then
        local mvn_base = "mvn dependency:sources -q -Dmaven.wagon.http.ssl.insecure=true"
        cmd = mvn_base .. " || " .. mvn_base .. " -Pnexus -Pplatform"
    elseif vim.fn.filereadable(project_root .. "/build.gradle") == 1
        or vim.fn.filereadable(project_root .. "/build.gradle.kts") == 1 then
        cmd = "./gradlew downloadSources 2>/dev/null || gradle dependencies 2>/dev/null || true"
    else
        vim.notify("❌ No Maven/Gradle project found", "error", { title = "Java Sources" })
        return
    end

    vim.notify("📥 Downloading sources...", "info", { title = "Java Sources" })
    vim.fn.jobstart(cmd, {
        cwd = project_root,
        on_exit = function(_, code)
            if code == 0 then
                vim.notify("✅ Sources downloaded! Restarting LSP...", "info", { title = "Java Sources" })
                vim.lsp.buf_restart()
            else
                vim.notify("⚠️ Source download finished with code " .. code .. ". Some sources may be missing.", "warn", { title = "Java Sources" })
            end
        end
    })
end, {})

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

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
        buffer = bufnr,
        callback = function()
            pcall(vim.lsp.codelens.refresh)
        end
    })
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
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*",
                    },
                },
                signatureHelp = {
                    enabled = false,
                    description = {
                        enabled = true
                    }
                },
                contentProvider = { preferred = "fernflower" },
                saveActions = { organizeImports = false },
                referencesCodeLens = { enabled = true },
                inlayHints = { parameterNames = { enabled = "all" } },
                codeGeneration = {
                    useBlocks = true,
                    generateComments = true,
                    insertLocation = true
                },
                autobuild = {
                    enabled = true
                },
                progressReports = {
                    enabled = false
                },
                -- eclipse = {
                --     downloadSources = true
                -- },
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

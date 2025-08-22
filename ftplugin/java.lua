local home = os.getenv("HOME")
local jdtls = require("jdtls")
local fn = vim.fn

-- === Определение Java из Maven/Gradle ======================
local function java_from_build()
    local pom = fn.getcwd() .. "/pom.xml"
    if fn.filereadable(pom) == 1 then
        for line in io.lines(pom) do
            local v = line:match("<maven.compiler.source>(%d+)</maven.compiler.source>")
            if v then
                local path = home .. "/.sdkman/candidates/java/" .. v
                if fn.isdirectory(path) == 1 then return path end
            end
        end
    end

    local gradle = fn.getcwd() .. "/build.gradle"
    if fn.filereadable(gradle) == 1 then
        for line in io.lines(gradle) do
            local v = line:match("sourceCompatibility%s*=%s*['\"]?(%d+)['\"]?")
            if v then
                local path = home .. "/.sdkman/candidates/java/" .. v
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
    local handle = io.popen("ls -1 " .. base)
    if handle then
        for version in handle:lines() do
            local path = base .. "/" .. version
            if fn.isdirectory(path) == 1 and version ~= "current" then
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
    -- Map the Java specific key mappings once the server is attached
    -- Setup the java debug adapter of the JDTLS server
    require('jdtls.dap').setup_dap()
    -- Find the main method(s) of the application so the debug adapter can successfully start up the application
    -- Sometimes this will randomly fail if language server takes to long to startup for the project, if a ClassDefNotFoundException occurs when running
    -- the debug tool, attempt to run the debug tool while in the main class of the application, or restart the neovim instance
    -- Unfortunately I have not found an elegant way to ensure this works 100%
    require('jdtls.dap').setup_dap_main_class_configs()
    -- Enable jdtls commands to be used in Neovim
    require 'jdtls.setup'.add_commands()
    -- Refresh the codelens
    -- Code lens enables features such as code reference counts, implemenation counts, and more.
    vim.lsp.codelens.refresh()

    require("lsp_signature").on_attach({
        bind = true,
        padding = "",
        handler_opts = {
            border = "rounded",
        },
        hint_prefix = "󱄑 ",
    }, bufnr)

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.java" },
        callback = function()
            local _, _ = pcall(vim.lsp.codelens.refresh)
        end
    })
end

-- === Конфиг JDTLS с поддержкой Lombok =====================
local function start_jdtls()
    local java_home = get_java_home()
    local runtimes = get_all_runtimes()
    table.insert(runtimes, 1, { name = "JavaSDK", path = java_home, default = true })

    local jdtls_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
    local launcher = fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local config_os = detect_os()
    local config_dir = jdtls_dir .. "/config_" .. config_os
    local project_name = fn.fnamemodify(fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

    -- === Авто-подключение lombok =================================
    local lombok_path = fn.glob(jdtls_dir .. "/lombok.jar")
    local javaagent_opts = {}
    if lombok_path ~= "" then
        table.insert(javaagent_opts, "-javaagent:" .. lombok_path)
    end

    -- === bundles: Debug + Test =================================
    local bundles = {
        fn.glob(
            "~/.local/share/java/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
            1),
    }
    vim.list_extend(
        bundles,
        vim.split(fn.glob("~/.local/share/java/vscode-java-test/server/*.jar", 1), "\n")
    )

    local cmd = {
        java_home .. "/bin/java",
        unpack(javaagent_opts),
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

    local config = {
        cmd = cmd,
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" }),
        init_options = {
            bundles = bundles,
            downloadSources = true,           -- подтягиваем исходники
            progressReports = true,           -- показывать прогресс
            classFileContents = "fernflower", -- красивый декомпилер
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
        settings = {
            java = {
                import = { enabled = true },
                -- Enable code formatting
                format = {
                    enabled = true,
                    -- -- Use the Google Style guide for code formattingh
                    -- settings = {
                    --     url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
                    --     profile = "GoogleStyle"
                    -- }
                },
                -- Enable downloading archives from eclipse automatically
                eclipse = {
                    downloadSource = true
                },
                -- Enable downloading archives from maven automatically
                maven = {
                    downloadSources = true
                },
                -- Enable method signature help
                signatureHelp = {
                    enabled = true
                },
                -- Use the fernflower decompiler when using the javap command to decompile byte code back to java code
                contentProvider = {
                    preferred = "fernflower"
                },
                -- Setup automatical package import oranization on file save
                saveActions = {
                    organizeImports = true
                },
                -- Customize completion options
                completion = {
                    -- When using an unimported static method, how should the LSP rank possible places to import the static method from
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*",
                    },
                    -- Try not to suggest imports from these packages in the code action window
                    filteredTypes = {
                        "com.sun.*",
                        "io.micrometer.shaded.*",
                        "java.awt.*",
                        "jdk.*",
                        "sun.*",
                    },
                    -- Set the order in which the language server should organize imports
                    importOrder = {
                        "java",
                        "jakarta",
                        "javax",
                        "com",
                        "org",
                    }
                },
                sources = {
                    -- How many classes from a specific package should be imported before automatic imports combine them all into a single import
                    organizeImports = {
                        starThreshold = 2,
                        staticThreshold = 3
                    }
                },
                -- How should different pieces of code be generated?
                codeGeneration = {
                    -- When generating toString use a json format
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                    },
                    -- When generating hashCode and equals methods use the java 7 objects method
                    hashCodeEquals = {
                        useJava7Objects = true
                    },
                    -- When generating code use code blocks
                    useBlocks = true
                },
                -- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
                configuration = {
                    updateBuildConfiguration = "interactive",
                    runtimes = get_all_runtimes(),
                },
                -- enable code lens in the lsp
                referencesCodeLens = {
                    enabled = true
                },
                -- enable inlay hints for parameter names,
                inlayHints = {
                    parameterNames = {
                        enabled = "all"
                    }
                }
            }
        },
        on_attach = on_attach
    }

    vim.api.nvim_create_autocmd("Filetype", {
        pattern = "java",
        callback = function()
            require("jdtls").start_or_attach(config)
        end,
    })

    jdtls.start_or_attach(config)
    return java_home
end

-- === Авто-reload JDTLS =====================================
if not vim.g.current_java_home then
    vim.g.current_java_home = start_jdtls()
else
    local new_java_home = get_java_home()
    if vim.g.current_java_home ~= new_java_home then
        jdtls.stop()
        vim.g.current_java_home = start_jdtls()
    end
end

-- === DAP для Java с портами 5005 и 5006 ====================
local dap = require("dap")

dap.configurations.java = {
    -- Локальный запуск программы
    {
        type = "java",
        request = "launch",
        name = "Launch Java Program",
        mainClass = function()
            return vim.fn.input('Main class > ', '', 'file')
        end,
        projectName = function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end,
        cwd = vim.fn.getcwd(),
        console = "integratedTerminal",
    },

    -- Подключение к JVM на порту 5005
    {
        type = "java",
        request = "attach",
        name = "Attach to Java 5005",
        hostName = "127.0.0.1",
        port = 5005,
    },

    -- Подключение к JVM на порту 5006
    {
        type = "java",
        request = "attach",
        name = "Attach to Java 5006",
        hostName = "127.0.0.1",
        port = 5006,
    },
}

-- === Авто-загрузка launch.json, если есть ==================
local launchjs = fn.getcwd() .. "/.vscode/launch.json"
if fn.filereadable(launchjs) == 1 then
    require("dap.ext.vscode").load_launchjs(launchjs, { java = { "java" } })
end

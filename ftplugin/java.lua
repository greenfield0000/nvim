local home = os.getenv("HOME")
local jdtls = require("jdtls")
local fn = vim.fn

-- === Функция определения Java по Maven/Gradle =================
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

-- === Получаем JAVA_HOME для проекта ==========================
local function get_java_home()
  return java_from_build() or (home .. "/.sdkman/candidates/java/current")
end

-- === Собираем все JDK из SDKMAN ==============================
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

-- === Конфиг JDTLS ===========================================
local function start_jdtls()
  local java_home = get_java_home()
  local runtimes = get_all_runtimes()
  table.insert(runtimes, 1, { name = "JavaSDK", path = java_home, default = true })

  local jdtls_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
  local launcher = fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  local config_os = "mac" -- mac / win
  local config_dir = jdtls_dir .. "/config_" .. config_os
  local project_name = fn.fnamemodify(fn.getcwd(), ":p:h:t")
  local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

  local config = {
    cmd = {
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
    },
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" }),
    settings = {
      java = { configuration = { runtimes = runtimes } }
    },
  }

  jdtls.start_or_attach(config)
  return java_home
end

-- === Авто-reload JDTLS ======================================
if not vim.g.current_java_home then
  vim.g.current_java_home = start_jdtls()
else
  local new_java_home = get_java_home()
  if vim.g.current_java_home ~= new_java_home then
    jdtls.stop()
    vim.g.current_java_home = start_jdtls()
  end
end

-- === DAP =====================================================
local dap = require("dap")
jdtls.setup_dap({ hotcodereplace = "auto" })
jdtls.setup.add_commands()
local launchjs = fn.getcwd() .. "/.vscode/launch.json"
if fn.filereadable(launchjs) == 1 then
  require("dap.ext.vscode").load_launchjs(launchjs, { java = { "java" } })
end

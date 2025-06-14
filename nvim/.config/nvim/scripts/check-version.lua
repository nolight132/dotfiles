local function inspect(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. inspect(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local function check_package_version(name)
    print("Checking version of " .. name .. "...")

    local ok, mod = pcall(require, name)
    if not ok then
        print("Failed to load " .. name .. ": " .. mod)
        return
    end

    local version

    -- Try various ways to get version info
    if name == "mason-lspconfig" then
        pcall(function()
            version = require("mason-lspconfig.version")
        end)
    end

    print("Module structure: " .. inspect(mod))

    if version then
        print("Version: " .. inspect(version))
    else
        print("Couldn't determine version directly.")
    end

    -- Check for setup_handlers function
    if mod.setup_handlers then
        print("setup_handlers function exists")
    else
        print("setup_handlers function does NOT exist")
    end
end

-- Check mason-lspconfig version
check_package_version("mason-lspconfig")

-- Also check if vim.lsp.config exists (new API in Neovim)
if vim.lsp.config then
    print("vim.lsp.config API is available")
else
    print("vim.lsp.config API is NOT available")
end

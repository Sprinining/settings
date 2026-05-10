-- =========================================================
-- lazy.nvim 自动安装与初始化
-- =========================================================
-- lazy.nvim：Neovim 插件管理器
-- 作用：自动安装/加载/管理所有插件
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 如果本地不存在 lazy.nvim，则自动 clone
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"

    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        repo, lazypath
    })

    -- clone 失败直接退出
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "克隆 lazy.nvim 失败：\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\n按任意键退出..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- 加入 runtimepath
vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- 基础编辑器设置
-- =========================================================

-- 编码设置
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- 禁用 more（避免分页卡住输出）
vim.opt.more = false

-- 文件安全机制
vim.opt.swapfile = false   -- 禁用 swap 文件
vim.opt.backup = false     -- 禁用备份文件
vim.opt.undofile = true    -- 启用 undo 持久化

-- 行号
vim.opt.number = true
vim.opt.relativenumber = true

-- 缩进规则（C/C++ 风格）
vim.opt.expandtab = true   -- tab 转空格
vim.opt.tabstop = 4        -- tab 显示宽度
vim.opt.shiftwidth = 4     -- 自动缩进宽度
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true

-- UI 行为
vim.opt.wrap = false        -- 不自动换行
vim.opt.cursorline = true   -- 高亮当前行
vim.opt.signcolumn = "yes"  -- 防止 LSP 抖动
vim.opt.termguicolors = true
vim.opt.scrolloff = 8       -- 光标上下保留行数

-- 输入与系统剪贴板
vim.opt.mouse = "a"              -- 启用鼠标
vim.opt.clipboard = "unnamedplus" -- 系统剪贴板同步

-- 搜索行为
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 命令行补全
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.pumheight = 12

-- Leader 键定义
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- =========================================================
-- 快捷键系统（核心操作）
-- =========================================================
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 插入模式退出（jk 替代 Esc）
keymap("i", "jk", "<Esc>", opts)

-- 保存文件 / 退出
keymap({ "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>", opts)
keymap("n", "<C-q>", ":q<CR>", opts)

-- 清除搜索高亮
keymap("n", "<Esc>", function()
    if vim.v.hlsearch == 1 then
        vim.cmd("nohlsearch")
    else
        return "<Esc>"
    end
end, { noremap = true, expr = true })

-- 滚动并居中（提升阅读体验）
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "%", "%zz", opts)

-- 窗口切换（左下上右）
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 调整窗口大小
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- 禁用 Ctrl+Space（避免补全冲突）
keymap({ "n", "i", "v", "x", "t" }, "<C-Space>", "<Nop>", opts)

-- =========================================================
-- 常用功能快捷键
-- =========================================================

-- 格式化代码
keymap("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = false })
end, opts)

-- Zen 模式（专注写代码）
keymap("n", "<leader>z", function()
    require("zen-mode").toggle()
end, opts)

-- 文件树开关
keymap("n", "<leader>e", function()
    require("nvim-tree.api").tree.toggle()
end, opts)

-- =========================================================
-- 插件管理（lazy.nvim）
-- =========================================================
require("lazy").setup({
    spec = {

        -- =========================
        -- 主题
        -- =========================
        {
            "ellisonleao/gruvbox.nvim",
            priority = 1000,
            config = function()
                vim.cmd.colorscheme("gruvbox")
            end,
        },

        -- 状态栏
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = true,
        },

        -- 自动括号补全
        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            config = true,
        },

        -- 代码格式化工具
        {
            "stevearc/conform.nvim",
            event = { "BufWritePre" },
            config = function()
                require("conform").setup({
                    formatters_by_ft = {
                        c = { "clang_format" },
                        cpp = { "clang_format" },
                        lua = { "stylua" },
                        python = { "black" },
                        javascript = { "prettier" },
                        typescript = { "prettier" },
                    },
                })
            end,
        },

        -- Zen mode
        {
            "folke/zen-mode.nvim",
            opts = {
                window = { width = 100 },
            },
        },

        -- 文件树
        {
            "nvim-tree/nvim-tree.lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                vim.g.loaded_netrw = 1
                vim.g.loaded_netrwPlugin = 1

                require("nvim-tree").setup({
                    view = { width = 30 },
                    renderer = { group_empty = true },
                    filters = { dotfiles = false },
                })
            end,
        },

        -- nvim-cmp 补全系统
        {
            "hrsh7th/nvim-cmp",
            dependencies = { "hrsh7th/cmp-nvim-lsp" },
            config = function()
                local cmp = require("cmp")

                cmp.setup({
                    mapping = cmp.mapping.preset.insert({
                        ["<Tab>"] = cmp.mapping.select_next_item(),
                        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    }),
                    sources = {
                        { name = "nvim_lsp" },
                    },
                })
            end,
        },
    },

    install = { colorscheme = { "gruvbox" } },
    checker = { enabled = true },
})


-- =========================================================
-- LSP（clangd）
-- =========================================================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("clangd", {
    cmd = { 
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=bundled", 
        "--header-insertion=iwyu", 
    },

    capabilities = capabilities,

    on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, silent = true }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
})

vim.lsp.enable("clangd")

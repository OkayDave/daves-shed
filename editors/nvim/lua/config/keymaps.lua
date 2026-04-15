-- Keymaps based on .ideavimrc mappings
local keymap = vim.keymap

-- Disable arrow keys
keymap.set({"n", "i", "v"}, "<Up>", "<Nop>")
keymap.set({"n", "i", "v"}, "<Down>", "<Nop>")
keymap.set({"n", "i", "v"}, "<Left>", "<Nop>")
keymap.set({"n", "i", "v"}, "<Right>", "<Nop>")

-- Escape insert mode with 'jk'
keymap.set("i", "jk", "<Esc>")

-- File actions
keymap.set("n", "<leader>s", ":w<CR>", { desc = "Save" })
keymap.set("n", "<leader>q", ":bd<CR>", { desc = "Close Buffer" })
keymap.set("n", "<leader>x", ":x<CR>", { desc = "Save and Close" })

-- Window management
keymap.set("n", "<leader>we", "<C-w>v", { desc = "Split Vertically" })
keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split Horizontally" })
keymap.set("n", "<leader>wc", "<C-w>c", { desc = "Close Split" })
keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Navigate Left" })
keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Navigate Down" })
keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Navigate Up" })
keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Navigate Right" })
keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize Splits" })

-- Buffer / tab navigation
keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "Next Buffer" })
keymap.set("n", "<leader>bp", ":bp<CR>", { desc = "Previous Buffer" })
keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Close Buffer" })

-- Search / navigation (Plugin-dependent placeholders, mapped in plugin config usually)
-- These are basic fallback for now
keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live Grep" })
keymap.set("n", "<leader>fs", "/", { desc = "Search" })
keymap.set("n", "<leader>fr", ":%s/", { desc = "Replace" })

-- Symbol / structure
keymap.set("n", "<leader>ss", ":Telescope lsp_symbols<CR>", { desc = "Symbols" })
keymap.set("n", "<leader>st", ":Telescope lsp_document_symbols<CR>", { desc = "Document Structure" })

-- Code actions (LSP)
keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
keymap.set("n", "<leader>cf", function() vim.lsp.buf.format { async = true } end, { desc = "Format Code" })

-- Git
keymap.set("n", "<leader>gs", ":Telescope git_status<CR>", { desc = "Git Status" })
keymap.set("n", "<leader>gb", ":Telescope git_branches<CR>", { desc = "Git Branches" })
keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Git Diff" })

-- Testing
keymap.set("n", "<leader>tt", ":lua require('neotest').run.run()<CR>", { desc = "Run Nearest Test" })
keymap.set("n", "<leader>tr", ":lua require('neotest').run.run_last()<CR>", { desc = "Rerun Last Test" })

-- Terminal & tools
keymap.set("n", "<leader>ot", ":terminal<CR>", { desc = "Open Terminal" })
keymap.set("n", "<leader>op", ":NvimTreeToggle<CR>", { desc = "Project Drawer" })

-- Format on save and linters
return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting   -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters

    -- list of formatters & linters for mason to install
    require('mason-null-ls').setup {
      ensure_installed = {
        'prettier',  -- general formatter
        'checkmake', -- makefile linter
        'stylua',    -- lua formatter
        'eslint_d',  -- ts/js linter
        'shfmt',     -- shell script formatter
        'ruff',      -- python linter
      },
      -- auto-install configured formatters & linters (with null-ls)
      automatic_installation = true,
    }

    local sources = {
      formatting.prettier.with {
        filetypes = {
          'css',
          'graphql',
          'html',
          'javascript',
          'javascriptreact',
          'json',
          'less',
          'markdown',
          'scss',
          'typescript',
          'typescriptreact',
          'yaml',
        },
        extra_args = { '--print-width', '120' },                                           -- set print width for prettier
      },
      diagnostics.checkmake,                                                               -- makefile linter
      formatting.stylua,                                                                   -- lua formatter
      formatting.shfmt.with { args = { '-i', '4' } },                                      -- shell script formatter with indentation set to 4 spaces
      formatting.terraform_fmt,                                                            -- terraform formatter

      require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } }, -- python linter with extra args
      require('none-ls.formatting.ruff_format').with {
        extra_args = { '--line-length', '120' },                                           -- set line length for ruff formatter
      },
    }

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {}) -- create a new augroup for LSP formatting

    null_ls.setup {
      -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
      sources = sources, -- set the sources for null-ls
      -- you can reuse a shared lspconfig on_attach callback here
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr } -- clear existing autocmds for the buffer
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { async = false } -- format the buffer before saving
            end,
          })
        end
      end,
    }
  end,
}

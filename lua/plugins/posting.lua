return {
  "YarikYar/posting.nvim",
  dependencies = { "akinsho/toggleterm.nvim" },
  config = function()
    require("posting").setup({
	    border = "single", -- valid options are "single" | "double" | "shadow" | "curved"
    })
  end,
  event = "BufRead",
  keys = {
    {
      "<leader>lp",
      function()
        require("posting").open()
      end,
      desc = "Open Posting floating window",
    },
  },
}

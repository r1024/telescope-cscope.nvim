# telescope-cscope.nvim
## Configure
```
require('telescope').load_extension('cscope')
```

## Usage
- `Telescope cscope list_this_symbol` find symbol in current project
- `Telescope cscope list_calling` list this function calling
- `Telescope cscope list_called` list who call this function
- `Telescope cscope goto_definition` goto this function definition

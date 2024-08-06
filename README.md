# Overview

Sort *almost any* structured text in Neovim using TSSorter, a sorter for Neovim based on Treesitter nodes. This plugin looks for the nearest configured sortable under the cursor and sorts them under the common parent node, maintaining your original
document structure! It strives to work out of the box with minimal configuration. Please see below for examples:

![example](https://github.com/user-attachments/assets/e8d09a69-c1ff-42e9-b2d9-07b04cbb8e7b)

**Note that this plugin is still in the early stages and highly experimental. Breaking changes and bugs should be expected**
If you find any bugs please submit an issue.

# Installation

TSsorter supports the latest stable release of Neovim, currently version `0.10.1.` Other versions may work but are not guaranteed.

This plugin depends on Treesitter so make sure to install the parser for the filetype you are trying to configure!  

You can install using your favorite package manager, here are a few examples:

## Lazy.nvim

```lua
return {
    'mtrajano/tssorter.nvim',
    version = '*', -- latest stable version, use `main` to keep up with the latest changes
    config = function() 
        require('tssorter').setup({
            -- leave empty for the default config or define your own sortables in here. They will add, rather than
            -- replace, the defaults for the given filetype
        }) 
    end
}
```

## Packer

```lua
use {
    'mtrajano/tssorter.nvim',
    tag = '*', -- latest stable version, use `main` to keep up with the latest changes
    config = function() 
        require('tssorter').setup({
            -- leave empty for the default config or define your own sortables in here. They will add, rather than
            -- replace, the defaults for the given filetype
        }) 
    end
  }
```

# Usage

## Default Configuration

The default included sortables can be found [here](https://github.com/mtrajano/tssorter.nvim/blob/main/lua/tssorter/config.lua) which should give you an idea of how to configure your own.
Here is an explanation of what each key means:

```lua
{
   sortables = {
      markdown = { -- filetype
         list = { -- sortable name
            node = 'list_item', -- treesitter node to capture

            -- function that takes in two nodes and returns true when first node should come first
            -- these are just tsnodes so you have all that functionality available to you
            order_by = function(node1, node2)
               -- TODO: add more helpers to make it easier to interact with these
               local line1 = require('tssorter.tshelper').get_text(node1)
               local line2 = require('tssorter.tshelper').get_text(node2)

               return line1 < line2
            end
         }
      }
   },
   logger = {
      level = vim.log.levels.WARN, -- log on warn level and above
      outfile = nil, -- nil prints to messages, or add a path to a file to output logs there
   }

}
```

## Lua API

By default simply calling `sort` should sort the nearest sortable under the cursor. 

```lua
require('tssorter').sort()
```

The method also takes some optional parameters to control which direction to sort by, etc...

```lua
require('tssorter').sort({
    reverse = true -- sort in reverse order
})
```

You may add your own keybindings to make it easier to call these.

# Examples

For brevity I am not including the entire configuration. Assume that these are all included under the appropriate
filetype in the sortables config key. See above for more details on configuration. Also note that for now all sortables must
include a sortable name as a key. This will help with future plans to have something like `:TSSorter heading` to sort
all the headings in a given file.

## Sorting CSS properties
```lua
{
    node = 'declaration',
}
```

## Sorting HTML attributes
```lua
{
    node = 'attribute',
}
```

## Sorting by markdown headers
```lua
{
    node = 'section',
}
```

## Sorting by markdown lists/tasks
```lua
{
    node = 'list_item',
}
```

## Lua lists
```lua
{
    node = 'field',
}
```

---

Yada yada yada, you get the idea... Essentially all you need is to add the node you want to sort on. If this node
contains a nested structure, for example markdown headers, make sure the node you define is the one that encapsulates
all of the nested nodes. In the example of markdown headers this is the `section` node and not the `atx_heading` node
itself!

# TODO

- [ ] Fix undo/redo to be one operation rather than line by line
- [ ] Sort under visual selection / range
- [ ] Add more default configuration for other languages
- [ ] Vim /doc documentation
- [ ] Tests
- [ ] Look into query `.scm` files
- [ ] Sort recursively
- [ ] Sort based on a configurable inner node, example
    * Sort function based on the identifier (function_name)
    * Inner text of the markdown list (rather than the whole list)

# Contribution

See an interesting use case you don't see mentioned here or that is not yet implemented? Create an issue or submit a pr! 
Any help adding documentation would also be appreciated.

local nodes = require('gotools.ts.nodes')
-- local tsutil = require('nvim-treesitter.ts_utils')

local M = {
    query_package = '(package_clause (package_identifier)@package.name)@package.clause',
    query_struct = '(type_declaration (type_spec name:(type_identifier) @struct.name type: (struct_type)))@struct.declaration',
    query_struct_field = '(field_declaration name:(field_identifier)@field.name) @field.declaration',
    query_type_declaration = '(type_declaration (type_spec name:(type_identifier) @type_decl.name)) @type_decl.declaration', -- rename to gotype so not confuse with type
    query_interface = '(type_declaration (type_spec name:(type_identifier) @interface.name type:(interface_type)))@interface.declaration',
    query_interface_method = '(method_spec name: (field_identifier)@method.name)@interface.method.declaration',
    query_func_name = '(function_declaration name: (identifier)@function.name) @function.declaration',
    query_struct_method = '(method_declaration receiver: (parameter_list (parameter_declaration name:(identifier)@method.receiver.name type:(type_identifier)@method.receiver.type)) name:(field_identifier)@method.name)@method.declaration',
    query_pointer_method = '(method_declaration receiver: (parameter_list (parameter_declaration name:(identifier)@method.receiver.name type:(pointer_type)@method.receiver.type)) name:(field_identifier)@method.name)@method.declaration',
    -- query_method_name = '(method_declaration receiver: (parameter_list)@method.receiver name: (field_identifier)@method.name body:(block))@method.declaration',
    query_method_name = '(method_declaration receiver: (parameter_list)@method.receiver name: (field_identifier)@method.name)@method.declaration',
    --   query_method_void = [[((method_declaration
    --    receiver: (parameter_list
    --      (parameter_declaration
    --        name: (identifier)@method.receiver.name
    --        type: (pointer_type)@method.receiver.type)
    --      )
    --    name: (field_identifier)@method.name
    --    parameters: (parameter_list)@method.parameter
    --    body:(block)
    -- )@method.declaration)]],
    -- query_method_multi_ret = [[(method_declaration
    --  receiver: (parameter_list
    --    (parameter_declaration
    --      name: (identifier)@method.receiver.name
    --      type: (pointer_type)@method.receiver.type)
    --    )
    --  name: (field_identifier)@method.name
    --  parameters: (parameter_list)@method.parameter
    --  result: (parameter_list)@method.result
    --  body:(block)
    --  )@method.declaration]],
    -- query_method_single_ret = [[((method_declaration
    --  receiver: (parameter_list
    --    (parameter_declaration
    --      name: (identifier)@method.receiver.name
    --      type: (pointer_type)@method.receiver.type)
    --    )
    --  name: (field_identifier)@method.name
    --  parameters: (parameter_list)@method.parameter
    --  result: (type_identifier)@method.result
    --  body:(block)
    --  )@method.declaration)]],
    --   query_tr_method_void = [[((method_declaration
    --    receiver: (parameter_list
    --      (parameter_declaration
    --        name: (identifier)@method.receiver.name
    --        type: (type_identifier)@method.receiver.type)
    --      )
    --    name: (field_identifier)@method.name
    --    parameters: (parameter_list)@method.parameter
    --    body:(block)
    -- )@method.declaration)]],
    -- query_tr_method_multi_ret = [[((method_declaration
    --  receiver: (parameter_list
    --    (parameter_declaration
    --      name: (identifier)@method.receiver.name
    --      type: (type_identifier)@method.receiver.type)
    --    )
    --  name: (field_identifier)@method.name
    --  parameters: (parameter_list)@method.parameter
    --  result: (parameter_list)@method.result
    --  body:(block)
    --  )@method.declaration)]],
    -- query_tr_method_single_ret = [[((method_declaration
    --  receiver: (parameter_list
    --    (parameter_declaration
    --      name: (identifier)@method.receiver.name
    --      type: (type_identifier)@method.receiver.type)
    --    )
    --  name: (field_identifier)@method.name
    --  parameters: (parameter_list)@method.parameter
    --  result: (type_identifier)@method.result
    --  body:(block)
    --  )@method.declaration)]],
    query_test_func = [[((function_declaration name: (identifier) @test_name
        parameters: (parameter_list
            (parameter_declaration
                     name: (identifier)
                     type: (pointer_type
                         (qualified_type
                          package: (package_identifier) @_param_package
                          name: (type_identifier) @_param_name))))
         ) @testfunc
      (#contains? @test_name "Test")
      (#match? @_param_package "testing")
      (#match? @_param_name "T"))]],
    query_testcase_node = [[(literal_value (literal_element (literal_value .(keyed_element (literal_element (identifier)) (literal_element (interpreted_string_literal) @test.name)))))]],
    query_string_literal = [[((interpreted_string_literal) @string.value)]],
}

local function get_name_defaults()
    return { ['func'] = 'function',['if'] = 'if',['else'] = 'else',['for'] = 'for' }
end

M.get_struct_node_at_cursor = function(bufnr)
    local query = M.query_struct
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_struct_field_node_at_cursor = function(bufnr)
    local query = M.query_struct_field
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_type_node_at_cursor = function(bufnr)
    local query = M.query_type_declaration
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_interface_node_at_cursor = function(bufnr)
    local query = M.query_interface
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_interface_method_node_at_cursor = function(bufnr)
    local query = M.query_interface_method
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufnr)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_func_method_node_at_cursor = function(bufnr)
    local query = M.query_func_name .. ' ' .. M.query_method_name
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_testcase_node_at_cursor = function(bufnr)
    local query = M.query_testcase_node
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn, 'name')
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

M.get_string_node_at_cursor = function(bufnr)
    local query = M.query_string_literal
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn, 'value')
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

-- M.get_import_node_at_cursor = function(bufnr)
--     local bufn = bufnr or vim.api.nvim_get_current_buf()
--
--     local cur_node = tsutil.get_node_at_cursor()
--     if cur_node and (cur_node:type() == 'import_spec' or cur_node:parent():type() == 'import_spec') then
--         return cur_node
--     end
-- end

-- M.get_module_at_cursor = function(bufnr)
--     local node = M.get_import_node_at_cursor(bufnr)
--     if node then
--         local module = vim.treesitter.query.get_node_text(node, vim.api.nvim_get_current_buf())
--         module = string.gsub(module, '"', '')
--         return module
--     end
-- end

M.get_package_node_at_cursor = function(bufnr)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row, col = row, col + 1
    if row > 10 then
        return
    end
    local query = M.query_package
    local bufn = bufnr or vim.api.nvim_get_current_buf()
    local ns = nodes.nodes_at_cursor(query, get_name_defaults(), bufn)
    if ns ~= nil then
        return ns[#ns]
    end
    return nil
end

function M.in_func()
    local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
    if not ok then
        return false
    end
    local current_node = ts_utils.get_node_at_cursor()
    if not current_node then
        return false
    end
    local expr = current_node

    while expr do
        if expr:type() == 'function_declaration' or expr:type() == 'method_declaration' then
            return true
        end
        expr = expr:parent()
    end
    return false
end

return M

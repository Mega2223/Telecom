require('Utils.Utils')

---@class Graph
---@field nodes table<integer,Node>
---@field addConnection fun(self:Graph , from: Node | string, to: Node | string, weight: number | nil, bidirectional: boolean | nil)
---@field removeConnection fun(self:Graph , from: Node | string, to: Node | string, bidirectional: boolean)
---@field getNode fun(self: Graph, node: Node | string): Node | nil
---@field findPath fun(self: Graph, from: Node | string, to: Node | string): table<number,Node> | nil
---@field addNode fun(self: Graph, name: string)
---@field toString fun(self:Graph): string

---@class Node
---@field connections table<integer,Link>
---@field name string
---@field addConnection fun(self: Node, to: Node, weight: number | nil)
---@field removeConnection fun(self: Node, to: Node)

---@class Link
---@field from Node
---@field to Node
---@field weight number

---@class Path: table<number,Node>

---@param self Graph
---@return string
local function graphToString(self)
    local ret = "Graph "
    for i = 1, #self.nodes do ret = ret .. self.nodes[i].name .. " " end
    ret = ret .. "\n"
    for i = 1, #self.nodes do
        for j = 1, #self.nodes[i].connections do
            ret = ret .. 
            self.nodes[i].connections[j].from.name .. "->" ..
            self.nodes[i].connections[j].to.name .. " (" .. self.nodes[i].connections[j].weight .. ")\n"
        end
    end
    return ret
end

---@class PathfindingNode
---@field name string
---@field node Node
---@field distance number
---@field prev PathfindingNode | nil

---Finds a path from A to B using Dijkstra's algorithm
---@param self Graph
---@param from Node | string
---@param to Node | string
---@return table<integer,Node>
local function findPath(self, from, to)

    local from = self:getNode(from)
    local to = self:getNode(to)

    if not (from and to) then return path end
    
    ---@type table <string,PathfindingNode>
    local unvisited = {}

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        local name = node.name
        --print("unvisited["..name.."] = " .. name)
        unvisited[name] = {
            name = name,
            node = node,
            distance = 1.0/0.0
        }
        if unvisited[name].name == from.name then
            unvisited[name].distance = 0
        end

    end

    while true do
        ---@type table<integer, table<string, PathfindingNode>>
        local local_min = nil
        ---@type string
        local local_key = nil
        
        for key, value in pairs(unvisited) do
            if (not local_min) or value.distance < local_min.distance then
                local_min = value
                local_key = key
            end
        end

        if not local_key then break end

        local min_connections = local_min.node.connections

        for key, value in pairs(min_connections) do
            local unvisited_current = unvisited[value.to.name]
            if unvisited_current then
                --unvisited_current.distance = math.min(unvisited_current.distance,local_min.distance + value.weight)
                if local_min.distance + value.weight < unvisited_current.distance then
                    unvisited_current.distance = local_min.distance + value.weight
                    unvisited_current.prev = local_min
                end
                if unvisited_current.name == to.name then
                    local path = {}
                    local current = unvisited_current
                    while current do
                        table.insert(path,1,current.node)
                        current = current.prev
                    end
                    return path
                end
            end
        end
        --print('removing ' .. local_key .. ' d= ' .. local_min.distance)
        unvisited[local_key] = nil
    end
end

---Creates a link object, does not to anything else
---@param from Node
---@param to Node
---@param weight number
---@return Link
function Link(from, to, weight)
    ---@type Link
    return {
        from = from, to = to, weight = weight or 1
    }
end

function Node(name)
    ---@type Node
    return {
        name = name,
        connections = {},
        addConnection = function (self, to, weight)
            table.insert(self.connections,Link(self,to,weight or 1))
        end,
        removeConnection = function (self, to)
            for i = 1, #self.connections do
                if self.connections[i].to.name == to.name then
                    table.remove(self.connections,i)
                    return
                end
            end
        end
    }
end

--- @return Graph
function Graph()
    ---@type Graph
    return {
        nodes = {},
        findPath = findPath,
        addNode = function (self, name)
            local node = Node(name)
            table.insert(self.nodes,node)
        end,
        addConnection = function(self, from, to, weight, bidirectional)
            local from, to = self:getNode(from), self:getNode(to)
            if not from or not to then return end
            from:addConnection(to,weight)
            if bidirectional then
                self:addConnection(to,from,weight,false)
            end
        end,
        removeConnection = function(self,from,to,bidirectional)
            local from = self:getNode(from)
            local to = self:getNode(to)
            if not from or not to then return end
            from:removeConnection(to)
            if bidirectional then
                self:removeConnection(to,from,false)
            end
        end,
        getNode = function(self, node)
            ---@diagnostic disable-next-line: return-type-mismatch
            if type(node) ~= 'string' then return node end
            for i = 1, #self.nodes do
                if self.nodes[i].name == node then
                    return self.nodes[i]
                end
            end
            return nil
        end,
        toString = graphToString
    }
end

return Graph
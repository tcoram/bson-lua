--
-- Pure Lua (5.1) implementation of BSON
--
--
-- Copyright (c) 2013, Todd Coram. All rights reserved.
-- See LICENSE for details.
--

local bson = {}

-- Helper functions

local function toLSB(bytes,value)
  local res = ''
  local size = bytes
  local str = ""
  for j=1,size do
     str = str .. string.char(value % 256)
     value = math.floor(value / 256)
  end
  return str
end

local function toLSB32(value) return toLSB(4,value) end
local function toLSB64(value) return toLSB(8,value) end

local function fromLSB32(s)
   return s:byte(1) + (s:byte(2)*256) + 
      (s:byte(3)*65536) + (s:byte(4)*16777216)
end

local function fromLSB64(s)
   return fromLSB32(s) +
      (s:byte(5)*4294967296) + (s:byte(6)*1099511627776) +
      (s:byte(7)*2.8147497671066e+14) + (s:byte(8)*7.2057594037928e+16)
end


-- BSON generators
--

function bson.to_bool(n,v) 
   local pre = "\008"..n.."\000"
   if v then
      return pre.."\001"
   else
      return pre.."\000"
   end
end

function bson.to_str(n,v) return "\002"..n.."\000"..toLSB32(#v+1)..v.."\000" end
function bson.to_int32(n,v) return "\016"..n.."\000"..toLSB32(v) end
function bson.to_int64(n,v) return "\018"..n.."\000"..toLSB64(v) end
function bson.to_x(n,v) return v(n) end

function bson.utc_datetime(t)
   local t = t or (os.time()*1000)
   f = function (n)
      return "\009"..n.."\000"..toLSB64(t)
   end
   return f
end

-- Binary subtypes
bson.B_GENERIC  = "\000"
bson.B_FUNCTION = "\001"
bson.B_UUID     = "\004"
bson.B_MD5      = "\005"
bson.B_USER_DEFINED = "\128"

function bson.binary(v, subtype)
   local subtype = subtype or bson.B_GENERIC
   f = function (n) 
      return "\005"..n.."\000"..toLSB32(#v)..subtype..v
   end
   return f
end

function bson.to_num(n,v)
   if math.floor(v) ~= v then
      return bson.to_double(n,v)
   elseif v > 2147483647 or v < -2147483648 then
      return bson.to_int64(n,v)
   else
      return bson.to_int32(n,v)
   end
end

function bson.to_doc(n,doc)
   local d=bson.start()
   local doctype = "\003"
   for cnt,v in ipairs(doc) do
      local t = type(v)
      local o = lua_to_bson_tbl[t](tostring(cnt-1),v)
      d = d..o
      doctype = "\004"
   end
   -- do this only if we don't have an array (enumerated pairs)
   if d == "" then
      for nm,v in pairs(doc) do
	 local t = type(v)
	 local o = lua_to_bson_tbl[t](nm,v)
	 d = d..o
      end
   end
   return doctype..n.."\000"..bson.finish(d)
end


-- Mappings between lua and BSON.
-- "function" is a special catchall for non-direct mappings.
--
lua_to_bson_tbl= {
   boolean = bson.to_bool,
   string = bson.to_str,
   number = bson.to_num,
   table = bson.to_doc,
   ["function"] = bson.to_x
}

-- BSON document creation.
--
function bson.start() return "" end

function bson.finish(doc) 
   doc = doc .. "\000"
   return toLSB32(#doc+4)..doc
end

function bson.encode(doc)
   local d=bson.start()
   for e,v in pairs(doc) do
      local t = type(v)
      local o = lua_to_bson_tbl[t](e,v)
      d = d..o
   end
   return bson.finish(d)
end


-- BSON parsers

function bson.from_bool(s)
   return s:byte(1) == 1, s:sub(2)
end

function bson.from_int32(s)
   return fromLSB32(s:sub(1,4)), s:sub(5)
end

function bson.from_int64(s)
   return fromLSB64(s:sub(1,8)), s:sub(9)
end

function bson.from_utc_date_time(s)
   return fromLSB64(s:sub(1,8)), s:sub(9)
end

function bson.from_binary(s)
   local len = fromLSB32(s:sub(1,4))
   s = s:sub(6)
   local str = s:sub(1,len-1)
   return str, s:sub(len+1)
end


function bson.from_str(s)
   local len = fromLSB32(s:sub(1,4))
   s = s:sub(5)
   local str = s:sub(1,len-1)
   return str, s:sub(len+1)
end


function bson.decode_doc(doc,doctype)
   local luatab = {}
   local len = fromLSB32(doc:sub(1,4))
   doc=doc:sub(5)
   repeat
      local val
      local etype = doc:byte(1)
      if etype == 0 then doc=doc:sub(2) break end
      local ename = doc:match("(%Z+)\000",2)
      doc = doc:sub(#ename+3)
      val,doc = bson_to_lua_tbl[etype](doc,etype)
      if doctype == 4 then
	 table.insert(luatab,val)
      else
	 luatab[ename] = val
      end
   until not doc
   return luatab,doc
end

bson_to_lua_tbl= {
   [2] = bson.from_str,
   [16] = bson.from_int32,
   [18] = bson.from_int64,
   [8] = bson.from_bool,
   [3] = bson.decode_doc,
   [4] = bson.decode_doc,
   [5] = bson.from_binary,
   [9] = bson.from_utc_date_time
}

function bson.decode(doc)
   a,d=bson.decode_doc(doc,nil)
   return a,d
end

function bson.decode_next_io(fd)
   local slen = fd:read(4)
   if not slen then return nil end
   local len = fromLSB32(slen) - 4
   local doc = fd:read(len)
   return bson.decode(slen..doc)
end


return bson

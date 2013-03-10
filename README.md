# BSON generator/parser in pure Lua (5.1)
## Introduction

This is a very simple BSON implementation in Lua. It doesn't support all BSON types
(yet). In particular, and ironically, it doesn't support the floating point type.


## Building

There are no external dependencies, Lua 5.1 or LuaJIT should work.

## Supported Types

* int32, int64
* boolean
* string
* number
* array
* document
* UTC datetime

## Limitations

* Only 1 binary subtype (generic).
* No support for floating point (double) until I figure out how to encode/decode it in pure Lua.
* int64 is limited by Lua's double type.
* No javascript-ish types (code, object_id, etc)


## Getting started
Here is an example to get you started:

```
bson=require'bson'
bsondoc1=bson.encode{username="maroc", 
		     info={first="todd",
			     last="coram",
			     age=46,
			     saved=true,
			     ts=bson.utc_datetime(),
			     colors={"Red","Green","Blue"}
		     }}
decoded=bson.decode(bsondoc1)

print("username = "..decoded.username)

for i,v in pairs(decoded) do print(i,v) end
print()
for i,v in pairs(decoded.info) do print(i,v) end
print()
for i,v in ipairs(decoded.info.colors) do print(i,v) end
```

/todd

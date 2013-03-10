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

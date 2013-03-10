bson=require'bson'
bsondoc1=bson.encode{username="maroc", 
		     record={first="todd",
			     last="coram",
			     age=46,
			     saved=true,
			     ts=bson.utc_datetime(),
			     colors={"Red","Green","Blue"}
		     }}
decoded1=bson.decode(bsondoc1)
bsondoc2=bson.encode(decoded1)
decoded2=bson.decode(bsondoc2)
assert(decoded1[username] == decoded2[username])

for i,v in pairs(decoded1) do print(i,v) end
print()
for i,v in pairs(decoded1.record) do print(i,v) end
print()
for i,v in pairs(decoded1.record.colors) do print(i,v) end

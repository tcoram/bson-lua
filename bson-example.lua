bson=require'bson'
epoch=os.time({year=1970, month=1, day=1, hour=0})
bsondoc1=bson.encode{username="maroc", 
		     info={first="todd",
			     last="coram",
			     age=46,
			     signature1=bson.binary("\000\001\002\003",bson.B_GENERIC),
			     signature2=bson.binary("\000\001\002\003"),
			     saved=true,
			     now=bson.utc_datetime(),
			     past=bson.utc_datetime(epoch),
			     colors={"Red","Green","Blue"}
		     }}
decoded=bson.decode(bsondoc1)

print("username = "..decoded.username)

for i,v in pairs(decoded) do print(i,v) end
print()
for i,v in pairs(decoded.info) do print(i,v) end
print()
for i,v in ipairs(decoded.info.colors) do print(i,v) end

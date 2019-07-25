##                                               Mail Task


##### Test task for tarantool solution developer:
 *Key-value store via http* 
 
 #### Uses
+ Tarantool
+ Lua
+ Python3


#### API
 Method | Path | Body  | Specification
--- | --- | --- | --- 
 POST |/kv | ```{key: "test", "value": {SOME ARBITRARY JSON}}  ``` | Add data if key does't exist in the database
PUT |  /kv/:key{id} | ```{"value": {SOME ARBITRARY JSON}} ``` | Update data if key is in the database
GET | /kv/:key{id} |  | Get data by key 
DELETE | /kv/:key{id} | | Delete data if key is in the database

#### Codes
Code | Method | Specification
--- | --- | --- 
400|POST| If key already exist
409|POST, PUT| Body invalid
404|PUT GET DELETE| Key does not exist
200, 201| | all good

*Everything is logging*





#                                                      Mail Task
Test task for solution developer


## API
Path | Method | Body (json) | Description
--- | --- | --- | --- 
/kv | POST | ```{"key": "Your key", "value": ...your object...} ``` | Add a new pair if key was not in the database
/kv/:key | GET |  | Select pair by key and return result
/kv/:key | DELETE | | Delete pair if key was in the database
/kv/:key | PUT | ```{ "value": ...your new object...} ``` | Update new pair if the key was in the database
/info/kv/all_records | GET |  | Return all pairs in database

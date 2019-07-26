import requests
import json

GET = 'GET'
DELETE = 'DELETE'
POST = 'POST'
PUT = 'PUT'


class Key_Value_StoreAPI:

    def __init__(self):
        self.host = '127.0.0.1'
        self.port = 8080
        self.methods = {
            GET: requests.get,
            PUT: requests.put,
            POST: requests.post,
            DELETE: requests.delete
        }

    def load(key, value):
        return json.dumps({'key': key, 'value': value})

    def url(self, path):
        return 'http://{d}:{port}{path}'.format(
            d=self.host,
            port=self.port,
            path=path if path[0] == '/' else path[1:]
        )

    def request(self, method, path, **body):
        r = self.methods[method](self.url(path), **body)
        return r.status_code


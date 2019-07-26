import unittest
from json import dumps
from API import Key_Value_StoreAPI, GET, POST, PUT, DELETE


class Make:
    path = '/kv'

    def __init__(self, expected_code, method, body, expected_body=None, key=None, json=True, text=None):
        self.method = method
        self.expected_code = expected_code

        if json:
            if type(body) == tuple:
                self.body = Key_Value_StoreAPI.load(body[0], body[1])
            else:
                self.body = dumps({'value': body})
        else:
            self.body = body

        self.expected_body = expected_body
        self.key = key if key else None
        self.text = text

    def make(self, test, api):
        code = api.request(self.method, '{}/{}'.format(self.path, self.key) if self.key else self.path,
                           data=self.body if self.body else None)
        test.assertEqual(code, self.expected_code, self.text)


Pull = [
    Make(201, POST, ('key1', "Our string")),

    Make(200, GET, key='key1', body=None),

    Make(400, POST, '{"key2" "k", value: 6}', json=False, text='POST: wrong json'),
    Make(400, POST, '{"key2": "y"}', json=False, text='POST: miss value'),

    Make(404, GET, key='key2', body=None, text='GET: key did not find'),

    Make(404, DELETE, key='key2', body=None, text='DELETE: key did not find'),

    Make(200, PUT, "New string", key='key1'),
    Make(404, PUT, "NEw new string", key=' ', text='empty key'),

    Make(200, DELETE, key='key1', body=None),
    Make(404, GET, key='key1', body=None, text='DELETE: key is deleted'),

    Make(201, POST, ('key2', {'type': "number", 'value': 'japan'})),
    Make(409, POST, ('key2', 'stringg'), text='POST: key already exists'),
    Make(200, GET, body=None, key='key2'),
    Make(200, DELETE, key='key2', body=None),
]


class TestApi(unittest.TestCase):
    api = Key_Value_StoreAPI()

    def test_api(self):
        for m in Pull:
            m.make(self, self.api)


if __name__ == '__main__':
    unittest.main()

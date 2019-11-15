#!/usr/bin/python
# -*- coding: UTF-8 -*-
from urllib import request
import ssl
import json
import base64
import requests
def get_token(option):
    gcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
    # client_id 为官网获取的AK， client_secret 为官网获取的SK  option=1 通用图片识别 2 通用文字识别
    if option==1:
        host = 'https://aip.baidubce.com/oauth/2.0/token?grant_' \
            'type=client_credentials&client_id=w3NmnuHaNIocVV8YmLROav7n&client_secret=YdxGHiS9ReIhN9PqNRYcc1WbL9HRahcV'
    elif option==2:
        host = 'https://aip.baidubce.com/oauth/2.0/token?grant_' \
       'type=client_credentials&client_id=ooWGAPvjmMljkpb0LRNsO9oP&client_secret=XMmQnlpntjzxYFyqGX0aPxEuF6rDomNi'
    req = request.Request(host)
    response = request.urlopen(req, context=gcontext).read().decode('UTF-8')
    result = json.loads(response)
    if (result):
        print(result['session_key'])
        return result['session_key']
    return None


class handle_picture:
    @classmethod
    def get_photo(self,path):
        with open(path, 'rb') as f:
            self.img = base64.b64encode(f.read())
    def detect(self):
        host = 'https://aip.baidubce.com/rest/2.0/image-classify/v2/advanced_general'
        headers={
        'Content-Type':'application/x-www-form-urlencoded'
        }
        access_token= '24.e63da28c3122bf6c02231d3453af185d.2592000.1565139985.282335-16731460'
        host=host+'?access_token='+access_token
        data={}
        data['access_token']=access_token
        data['image'] =self.img
        res = requests.post(url=host,headers=headers,data=data)
        req=res.json()
        print(res.json())
        print(req['result'])
if __name__ == "__main__":
    #get_token(2)
    #handle=handle_picture()
    #handle.get_photo('1.jpg')
    #handle.detect()
    url="http://127.0.0.1:9000/audio/"
    with open('6.jpg', 'rb') as f:
        image = base64.b64encode(f.read())
    data={'img':image}
    res=requests.post(url=url,data=data)
    print(res.content.decode("utf-8"))
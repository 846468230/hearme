#!/usr/bin/python
# -*- coding: UTF-8 -*-
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from urllib import request
import ssl
import json
import base64
import requests
from urllib.parse import urlencode
from urllib.parse import quote_plus
from .settings import BASE_DIR
from django.utils.encoding import smart_str
import os
from django.urls import reverse
def get_token(option):
    gcontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
    # client_id 为官网获取的AK， client_secret 为官网获取的SK  option=1 通用图片识别 2 通用文字识别
    if option==1:
        host = 'https://aip.baidubce.com/oauth/2.0/token?grant_' \
            'type=client_credentials&client_id=w3NmnuHaNIocVV8YmLROav7n&client_secret=YdxGHiS9ReIhN9PqNRYcc1WbL9HRahcV'
    elif option==2:
        host = 'https://aip.baidubce.com/oauth/2.0/token?grant_' \
       'type=client_credentials&client_id=ooWGAPvjmMljkpb0LRNsO9oP&client_secret=XMmQnlpntjzxYFyqGX0aPxEuF6rDomNi'
    elif option==3:
         host = 'https://aip.baidubce.com/oauth/2.0/token?grant_' \
       'type=client_credentials&client_id=7NpoNOzk14No6xUHfN7UR99o&client_secret=wLAAh4AaPSMACEgODrRA0eGXyjH5sXCn'
    req = request.Request(host)
    response = request.urlopen(req, context=gcontext).read().decode('UTF-8')
    result = json.loads(response)
    if (result):
        return result['access_token']
    return None
mp3name="result.mp3"
mp3namedir=os.path.join(BASE_DIR, mp3name)
picture_detect=get_token(1)
word_detect=get_token(2)    
audio_detect = get_token(3)

data=""
result=""
@csrf_exempt
def index(request):
    global data
    global result
    global handle
    if request.method =="GET":
        return HttpResponse("helloworld")
    if request.method =="POST":
        img = request.POST.get("img")
        if data!=img:
            res=handle.detect(img,1)
            data=img
            result=res
        else:
            res=result
        return HttpResponse(res)

picture_data=""
picture_result=""
@csrf_exempt
def word(request):
    global picture_data
    global picture_result
    global handle
    if request.method =="POST":
        img = request.POST.get("img")
        if picture_data!=img:
            res=handle.detect(img,2)
            picture_data=img
            picture_result=res
        else:
            res=picture_result
        return HttpResponse(res)

audio_picture_data=""
audio_result=""

@csrf_exempt
def audio(request):
    global audio_picture_data
    global audio_result
    global handle
    if request.method =="POST":
        img = request.POST.get("img")
        if audio_picture_data!=img:
            res = handle.detect(img,2)
            res = json.loads(res)
            text=""
            for item in res:
                text=text+item['words']
            res=handle.detect("img",3,text)
            audio_picture_data=img
            audio_result=res
        else:
            res=audio_result
        return HttpResponse(res)

def audioResult(request):
    global mp3namedir
    global mp3name
    if request.method =="GET":
        file = open(mp3namedir,"rb").read() 
        response = HttpResponse(content=file,content_type='audio/mpeg')
        response['Content-Disposition'] = 'attachment; filename=%s' % smart_str(mp3name)
        response['Accept-Ranges'] = 'bytes'
        response['X-Sendfile'] = smart_str(mp3namedir)
        return response

class handle_picture:
    @classmethod
    def get_photo(self,path):
        with open(path, 'rb') as f:
            self.img = base64.b64encode(f.read())
    def detect(self,img,option,text=""):
        global picture_detect
        global word_detect
        global mp3name
        global mp3namedir
        if option==1:
            host = 'https://aip.baidubce.com/rest/2.0/image-classify/v2/advanced_general'
            access_token= picture_detect
        elif option==2:
            host = 'https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic'
            access_token= word_detect
        elif option==3:
            host = 'http://tsn.baidu.com/text2audio'
            access_token= audio_detect
            tex = quote_plus(text)
            params = {'tok': access_token, 'tex': tex, 'per': 4, 'spd': 5, 'pit': 5, 'vol': 5, 'aue': 3, 'cuid': '846468230','lan': 'zh', 'ctp': 1}  # lan ctp 固定参数
            data = urlencode(params)
        headers={
            'Content-Type':'application/x-www-form-urlencoded'
        }
        if option in [1,2]:
            host=host+'?access_token='+access_token
            data={}
            data['access_token']=access_token
            data['image'] =img
            res = requests.post(url=host,headers=headers,data=data)
            req=res.json()
        if option==3:
            res = request.urlopen(url=host,data=data.encode('utf-8')).read()
            #print(res)
            with open(mp3namedir, 'wb') as of:
                of.write(res)

        if option==1:
            return json.dumps(req['result'],ensure_ascii=False)
        elif option==2:
            #print(req['words_result'])
            return json.dumps(req['words_result'],ensure_ascii=False)
        elif option==3:
            return reverse('audioresult')
handle=handle_picture()
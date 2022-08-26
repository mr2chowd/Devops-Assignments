from urllib import response
from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse

def hello_view(request):
    return HttpResponse("Ruhi apu is teaching me djannnngo")

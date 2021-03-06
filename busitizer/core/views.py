import random
import uuid
import json
import os
import logging

from celery import group
from celery.result import AsyncResult

from django.conf import settings
from django.core.cache import cache
from django.http import HttpResponse, HttpResponseRedirect, HttpResponseBadRequest
from django.views.generic.detail import DetailView
from django.views.generic.list import ListView
from django.template.loader import render_to_string
from django.template import RequestContext
from django.shortcuts import get_object_or_404, render

from busitizer.core.tasks import busitize as busitize_task
from busitizer.core.models import Image

logger = logging.getLogger('busitizer')

def busitize(request):
    if 'url' not in request.GET:
        raise HttpResponseBadRequest

    url = request.GET['url']
    image, created = Image.objects.get_or_create(url=url)

    if created:
        status_code = 201
        busitize_task.delay(image.id)
        status_text = "Initiated"
    else:
        status_code = image.status
        status_text = image.get_status_display()

    response_data = {
        'status_code': status_code,
        'status_text': status_text,
        'url': url
    }
    if image.status == Image.COMPLETED:
        response_data['busitized'] = image.busitized.url

    logger.debug(request.META.get('HTTP_ACCEPT'))

    if "application/json" in request.META.get('HTTP_ACCEPT', ''):
        response = HttpResponse(json.dumps(response_data), "application/json", status=status_code)
        response['Access-Control-Allow-Origin'] = "*"
        return response

    return render(request, "busitize.html", response_data, status=status_code)
